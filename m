Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D17C6B0311
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 23:38:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 85so5260043pgd.9
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:38:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o19si1353342pgk.231.2017.08.16.20.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 20:38:35 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v14 5/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Date: Thu, 17 Aug 2017 11:26:56 +0800
Message-Id: <1502940416-42944-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Add a new vq to report hints of guest free pages to the host.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 drivers/virtio/virtio_balloon.c     | 167 +++++++++++++++++++++++++++++++-----
 include/uapi/linux/virtio_balloon.h |   1 +
 2 files changed, 147 insertions(+), 21 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 72041b4..e6755bc 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -54,11 +54,12 @@ static struct vfsmount *balloon_mnt;
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
 	struct work_struct update_balloon_size_work;
+	struct work_struct report_free_page_work;
 
 	/* Prevent updating balloon when it is being canceled. */
 	spinlock_t stop_update_lock;
@@ -90,6 +91,13 @@ struct virtio_balloon {
 	/* Memory statistics */
 	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
 
+	/*
+	 * Used by the device and driver to signal each other.
+	 * device->driver: start the free page report.
+	 * driver->device: end the free page report.
+	 */
+	__virtio32 report_free_page_signal;
+
 	/* To register callback in oom notifier call chain */
 	struct notifier_block nb;
 };
@@ -174,6 +182,17 @@ static void send_balloon_page_sg(struct virtio_balloon *vb,
 	} while (unlikely(ret == -ENOSPC));
 }
 
+static void send_free_page_sg(struct virtqueue *vq, void *addr, uint32_t size)
+{
+	unsigned int len;
+
+	add_one_sg(vq, addr, size);
+	virtqueue_kick(vq);
+	/* Release entries if there are */
+	while (virtqueue_get_buf(vq, &len))
+		;
+}
+
 /*
  * Send balloon pages in sgs to host. The balloon pages are recorded in the
  * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
@@ -511,42 +530,143 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
+					   unsigned long nr_pages)
+{
+	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
+	void *addr = (void *)pfn_to_kaddr(pfn);
+	uint32_t len = nr_pages << PAGE_SHIFT;
+
+	send_free_page_sg(vb->free_page_vq, addr, len);
+}
+
+static void report_free_page_completion(struct virtio_balloon *vb)
+{
+	struct virtqueue *vq = vb->free_page_vq;
+	struct scatterlist sg;
+	unsigned int len;
+	int ret;
+
+	sg_init_one(&sg, &vb->report_free_page_signal, sizeof(__virtio32));
+retry:
+	ret = virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
+	virtqueue_kick(vq);
+	if (unlikely(ret == -ENOSPC)) {
+		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		goto retry;
+	}
+}
+
+static void report_free_page(struct work_struct *work)
+{
+	struct virtio_balloon *vb;
+
+	vb = container_of(work, struct virtio_balloon, report_free_page_work);
+	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
+	report_free_page_completion(vb);
+}
+
+static void free_page_request(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+
+	queue_work(system_freezable_wq, &vb->report_free_page_work);
+}
+
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
-	int err, nvqs;
+	struct virtqueue **vqs;
+	vq_callback_t **callbacks;
+	const char **names;
+	struct scatterlist sg;
+	int i, nvqs, err = -ENOMEM;
+
+	/* Inflateq and deflateq are used unconditionally */
+	nvqs = 2;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
+		nvqs++;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
+		nvqs++;
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
+	if (!vqs)
+		goto err_vq;
+	callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
+	if (!callbacks)
+		goto err_callback;
+	names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
+	if (!names)
+		goto err_names;
+
+	callbacks[0] = balloon_ack;
+	names[0] = "inflate";
+	callbacks[1] = balloon_ack;
+	names[1] = "deflate";
+
+	i = 2;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		callbacks[i] = stats_request;
+		names[i] = "stats";
+		i++;
+	}
 
-	/*
-	 * We expect two virtqueues: inflate and deflate, and
-	 * optionally stat.
-	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
+		callbacks[i] = free_page_request;
+		names[i] = "free_page_vq";
+	}
+
+	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names,
+					 NULL, NULL);
 	if (err)
-		return err;
+		goto err_find;
 
 	vb->inflate_vq = vqs[0];
 	vb->deflate_vq = vqs[1];
+	i = 2;
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
-		struct scatterlist sg;
-		unsigned int num_stats;
-		vb->stats_vq = vqs[2];
-
+		vb->stats_vq = vqs[i++];
 		/*
 		 * Prime this virtqueue with one buffer so the hypervisor can
 		 * use it to signal us later (it can't be broken yet!).
 		 */
-		num_stats = update_balloon_stats(vb);
-
-		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
+		sg_init_one(&sg, vb->stats, sizeof(vb->stats));
 		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
-		    < 0)
-			BUG();
+		    < 0) {
+			dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
+				 __func__);
+			goto err_find;
+		}
 		virtqueue_kick(vb->stats_vq);
 	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
+		vb->free_page_vq = vqs[i];
+		vb->report_free_page_signal = 0;
+		sg_init_one(&sg, &vb->report_free_page_signal,
+			    sizeof(__virtio32));
+		if (virtqueue_add_outbuf(vb->free_page_vq, &sg, 1, vb,
+					 GFP_KERNEL) < 0) {
+			dev_warn(&vb->vdev->dev, "%s: add signal buf failed\n",
+				 __func__);
+			goto err_find;
+		}
+		virtqueue_kick(vb->free_page_vq);
+	}
+
+	kfree(names);
+	kfree(callbacks);
+	kfree(vqs);
 	return 0;
+
+err_find:
+	kfree(names);
+err_names:
+	kfree(callbacks);
+err_callback:
+	kfree(vqs);
+err_vq:
+	return err;
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -675,6 +795,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
 		xb_init(&vb->page_xb);
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
+		INIT_WORK(&vb->report_free_page_work, report_free_page);
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
@@ -739,6 +862,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	spin_unlock_irq(&vb->stop_update_lock);
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
+	cancel_work_sync(&vb->report_free_page_work);
 
 	remove_common(vb);
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -792,6 +916,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_SG,
+	VIRTIO_BALLOON_F_FREE_PAGE_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 37780a7..8214f84 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
+#define VIRTIO_BALLOON_F_FREE_PAGE_VQ	4 /* Virtqueue to report free pages */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
