Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE4706B0278
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:35:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a5so11143539pgu.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:35:07 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v8si9119558plg.831.2017.12.19.04.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 04:35:06 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v20 6/7] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Date: Tue, 19 Dec 2017 20:17:58 +0800
Message-Id: <1513685879-21823-7-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_VQ feature indicates the
support of reporting hints of guest free pages to host via virtio-balloon.

Host requests the guest to report free pages by sending a new cmd
id to the guest via the free_page_report_cmd_id configuration register.

When the guest starts to report, the first element added to the free page
vq is the cmd id given by host. When the guest finishes the reporting
of all the free pages, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID is added
to the vq to tell host that the reporting is done. Host may also requests
the guest to stop the reporting in advance by sending the stop cmd id to
the guest via the configuration register.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 drivers/virtio/virtio_balloon.c     | 202 ++++++++++++++++++++++++++++++------
 include/uapi/linux/virtio_balloon.h |   4 +
 2 files changed, 174 insertions(+), 32 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index fff0a3f..eae65c1 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -55,7 +55,12 @@ static struct vfsmount *balloon_mnt;
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
+
+	/* Balloon's own wq for cpu-intensive work items */
+	struct workqueue_struct *balloon_wq;
+	/* The free page reporting work item submitted to the balloon wq */
+	struct work_struct report_free_page_work;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -65,6 +70,13 @@ struct virtio_balloon {
 	spinlock_t stop_update_lock;
 	bool stop_update;
 
+	/* Start to report free pages */
+	bool report_free_page;
+	/* Stores the cmd id given by host to start the free page reporting */
+	uint32_t start_cmd_id;
+	/* Stores STOP_ID as a sign to tell host that the reporting is done */
+	uint32_t stop_cmd_id;
+
 	/* Waiting for host to ack the pages we released. */
 	wait_queue_head_t acked;
 
@@ -189,6 +201,28 @@ static void batch_balloon_page_sg(struct virtio_balloon *vb,
 		kick_and_wait(vq, vb->acked);
 }
 
+static void batch_free_page_sg(struct virtqueue *vq,
+			       unsigned long pfn,
+			       uint32_t len)
+{
+	add_one_sg(vq, pfn, len);
+
+	/* Batch till the vq is full */
+	if (!vq->num_free)
+		virtqueue_kick(vq);
+}
+
+static void send_cmd_id(struct virtio_balloon *vb, void *addr)
+{
+	struct scatterlist sg;
+	int err;
+
+	sg_init_one(&sg, addr, sizeof(uint32_t));
+	err = virtqueue_add_outbuf(vb->free_page_vq, &sg, 1, vb, GFP_KERNEL);
+	BUG_ON(err);
+	virtqueue_kick(vb->free_page_vq);
+}
+
 /*
  * Send balloon pages in sgs to host. The balloon pages are recorded in the
  * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
@@ -498,17 +532,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	virtqueue_kick(vq);
 }
 
-static void virtballoon_changed(struct virtio_device *vdev)
-{
-	struct virtio_balloon *vb = vdev->priv;
-	unsigned long flags;
-
-	spin_lock_irqsave(&vb->stop_update_lock, flags);
-	if (!vb->stop_update)
-		queue_work(system_freezable_wq, &vb->update_balloon_size_work);
-	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
-}
-
 static inline s64 towards_target(struct virtio_balloon *vb)
 {
 	s64 target;
@@ -525,6 +548,36 @@ static inline s64 towards_target(struct virtio_balloon *vb)
 	return target - vb->num_pages;
 }
 
+static void virtballoon_changed(struct virtio_device *vdev)
+{
+	struct virtio_balloon *vb = vdev->priv;
+	unsigned long flags;
+	__u32 cmd_id;
+	s64 diff = towards_target(vb);
+
+	if (diff) {
+		spin_lock_irqsave(&vb->stop_update_lock, flags);
+		if (!vb->stop_update)
+			queue_work(system_freezable_wq,
+				   &vb->update_balloon_size_work);
+		spin_unlock_irqrestore(&vb->stop_update_lock, flags);
+	}
+
+	virtio_cread(vb->vdev, struct virtio_balloon_config,
+		     free_page_report_cmd_id, &cmd_id);
+	if (cmd_id == VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID) {
+		WRITE_ONCE(vb->report_free_page, false);
+	} else if (cmd_id != vb->start_cmd_id) {
+		/*
+		 * Host requests to start the reporting by sending a new cmd
+		 * id.
+		 */
+		WRITE_ONCE(vb->report_free_page, true);
+		vb->start_cmd_id = cmd_id;
+		queue_work(vb->balloon_wq, &vb->report_free_page_work);
+	}
+}
+
 static void update_balloon_size(struct virtio_balloon *vb)
 {
 	u32 actual = vb->num_pages;
@@ -602,40 +655,116 @@ static void update_balloon_size_func(struct work_struct *work)
 
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
+		callbacks[i] = NULL;
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
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
+		vb->free_page_vq = vqs[i];
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
+}
+
+static bool virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
+					   unsigned long nr_pages)
+{
+	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
+	uint32_t len = nr_pages << PAGE_SHIFT;
+
+	if (!READ_ONCE(vb->report_free_page))
+		return false;
+
+	batch_free_page_sg(vb->free_page_vq, pfn, len);
+
+	return true;
+}
+
+static void report_free_page(struct work_struct *work)
+{
+	struct virtio_balloon *vb;
+
+	vb = container_of(work, struct virtio_balloon, report_free_page_work);
+	/* Start by sending the obtained cmd id to the host with an outbuf */
+	send_cmd_id(vb, &vb->start_cmd_id);
+	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
+	/*
+	 * End by sending the stop id to the host with an outbuf. Use the
+	 * non-batching mode here to trigger a kick after adding the stop id.
+	 */
+	send_cmd_id(vb, &vb->stop_cmd_id);
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -763,6 +892,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
 		xb_init(&vb->page_xb);
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
+		vb->balloon_wq = alloc_workqueue("balloon-wq",
+					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
+		INIT_WORK(&vb->report_free_page_work, report_free_page);
+		vb->stop_cmd_id = VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID;
+	}
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
@@ -827,6 +963,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	spin_unlock_irq(&vb->stop_update_lock);
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
+	cancel_work_sync(&vb->report_free_page_work);
 
 	remove_common(vb);
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -880,6 +1017,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_SG,
+	VIRTIO_BALLOON_F_FREE_PAGE_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 37780a7..58f1274 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,15 +35,19 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
+#define VIRTIO_BALLOON_F_FREE_PAGE_VQ	4 /* VQ to report free pages */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
 
+#define VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID		0
 struct virtio_balloon_config {
 	/* Number of pages host wants Guest to give up. */
 	__u32 num_pages;
 	/* Number of pages we've actually got in balloon. */
 	__u32 actual;
+	/* Free page report command id, readonly by guest */
+	__u32 free_page_report_cmd_id;
 };
 
 #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
