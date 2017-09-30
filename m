Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6530A6B0266
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 00:19:40 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y17so2579267pgc.2
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 21:19:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o7si4216505pgs.795.2017.09.29.21.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 21:19:38 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v16 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
Date: Sat, 30 Sep 2017 12:05:54 +0800
Message-Id: <1506744354-20979-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Add a new vq, ctrl_vq, to handle commands between the host and guest.
With this feature, we will be able to have the control plane and data
plane separated. In other words, the control related commands of each
feature will be sent via the ctrl_vq, meanwhile each feature may have
its own vq used as a data plane.

Free page report is the the first new feature controlled via ctrl_vq,
and a new cmd class, VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE, is added.
Currently, this feature has two cmds:
VIRTIO_BALLOON_FREE_PAGE_F_START: This cmd is sent from host to guest
to start the free page report work.
VIRTIO_BALLOON_FREE_PAGE_F_STOP: This cmd is bidirectional. The guest
would send the cmd to the host to indicate the reporting work is done.
The host would send the cmd to the guest to actively request the stop
of the reporting work.

The free_page_vq is used to transmit the guest free page blocks to the
host.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 drivers/virtio/virtio_balloon.c     | 249 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |  15 +++
 2 files changed, 244 insertions(+), 20 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 6952e19..70dc4ae 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -55,7 +55,13 @@ static struct vfsmount *balloon_mnt;
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *ctrl_vq,
+			 *free_page_vq;
+
+	/* Balloon's own wq for cpu-intensive work items */
+	struct workqueue_struct *balloon_wq;
+	/* The work items submitted to the balloon wq are listed here */
+	struct work_struct report_free_page_work;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -65,6 +71,9 @@ struct virtio_balloon {
 	spinlock_t stop_update_lock;
 	bool stop_update;
 
+	/* Stop reporting free pages */
+	bool report_free_page_stop;
+
 	/* Waiting for host to ack the pages we released. */
 	wait_queue_head_t acked;
 
@@ -93,6 +102,11 @@ struct virtio_balloon {
 
 	/* To register callback in oom notifier call chain */
 	struct notifier_block nb;
+
+	/* Host to guest ctrlq cmd buf for free page report */
+	struct virtio_balloon_ctrlq_cmd free_page_cmd_in;
+	/* Guest to Host ctrlq cmd buf for free page report */
+	struct virtio_balloon_ctrlq_cmd free_page_cmd_out;
 };
 
 static struct virtio_device_id id_table[] = {
@@ -186,6 +200,24 @@ static int send_balloon_page_sg(struct virtio_balloon *vb,
 	return err;
 }
 
+static int send_free_page_sg(struct virtqueue *vq, void *addr, uint32_t size)
+{
+	int ret = 0;
+
+	/*
+	 * Since this is an optimization feature, losing a couplle of free
+	 * pages to report isn't important. We simply resturn without adding
+	 * the page if the vq is full.
+	 */
+	if (vq->num_free) {
+		ret = add_one_sg(vq, addr, size);
+		if (!ret)
+			virtqueue_kick(vq);
+	}
+
+	return ret;
+}
+
 /*
  * Send balloon pages in sgs to host. The balloon pages are recorded in the
  * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
@@ -542,42 +574,210 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
-static int init_vqs(struct virtio_balloon *vb)
+static bool virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
+					   unsigned long nr_pages)
+{
+	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
+	void *addr = (void *)pfn_to_kaddr(pfn);
+	uint32_t len = nr_pages << PAGE_SHIFT;
+
+	if (vb->report_free_page_stop)
+		return false;
+
+	/* If the vq is broken, stop reporting the free pages. */
+	if (send_free_page_sg(vb->free_page_vq, addr, len) < 0)
+		return false;
+
+	return true;
+}
+
+static void ctrlq_add_cmd(struct virtqueue *vq,
+			  struct virtio_balloon_ctrlq_cmd *cmd,
+			  bool inbuf)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
-	int err, nvqs;
+	struct scatterlist sg;
+	int err;
+
+	sg_init_one(&sg, cmd, sizeof(struct virtio_balloon_ctrlq_cmd));
+	if (inbuf)
+		err = virtqueue_add_inbuf(vq, &sg, 1, cmd, GFP_KERNEL);
+	else
+		err = virtqueue_add_outbuf(vq, &sg, 1, cmd, GFP_KERNEL);
+
+	/* Sanity check: this can't really happen */
+	WARN_ON(err);
+}
+
+static void ctrlq_send_cmd(struct virtio_balloon *vb,
+			  struct virtio_balloon_ctrlq_cmd *cmd,
+			  bool inbuf)
+{
+	struct virtqueue *vq = vb->ctrl_vq;
+
+	ctrlq_add_cmd(vq, cmd, inbuf);
+	if (!inbuf) {
+		/*
+		 * All the input cmd buffers are replenished here.
+		 * This is necessary because the input cmd buffers are lost
+		 * after live migration. The device needs to rewind all of
+		 * them from the ctrl_vq.
+		 */
+		ctrlq_add_cmd(vq, &vb->free_page_cmd_in, true);
+	}
+	virtqueue_kick(vq);
+}
 
+static void report_free_page_end(struct virtio_balloon *vb)
+{
 	/*
-	 * We expect two virtqueues: inflate and deflate, and
-	 * optionally stat.
+	 * The host may have already requested to stop the reporting before we
+	 * finish, so no need to notify the host in this case.
 	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
+	if (vb->report_free_page_stop)
+		return;
+
+	vb->free_page_cmd_out.class = VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
+	vb->free_page_cmd_out.cmd = VIRTIO_BALLOON_FREE_PAGE_F_STOP;
+	ctrlq_send_cmd(vb, &vb->free_page_cmd_out, false);
+	vb->report_free_page_stop = true;
+}
+
+static void report_free_page(struct work_struct *work)
+{
+	struct virtio_balloon *vb;
+
+	vb = container_of(work, struct virtio_balloon, report_free_page_work);
+	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
+	report_free_page_end(vb);
+}
+
+static void ctrlq_handle(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+	struct virtio_balloon_ctrlq_cmd *msg;
+	unsigned int class, cmd, len;
+
+	msg = (struct virtio_balloon_ctrlq_cmd *)virtqueue_get_buf(vq, &len);
+	if (unlikely(!msg))
+		return;
+
+	/* The outbuf is sent by the host for recycling, so just return. */
+	if (msg == &vb->free_page_cmd_out)
+		return;
+
+	class = virtio32_to_cpu(vb->vdev, msg->class);
+	cmd =  virtio32_to_cpu(vb->vdev, msg->cmd);
+
+	switch (class) {
+	case VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE:
+		if (cmd == VIRTIO_BALLOON_FREE_PAGE_F_STOP) {
+			vb->report_free_page_stop = true;
+		} else if (cmd == VIRTIO_BALLOON_FREE_PAGE_F_START) {
+			vb->report_free_page_stop = false;
+			queue_work(vb->balloon_wq, &vb->report_free_page_work);
+		}
+		vb->free_page_cmd_in.class =
+					VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
+		ctrlq_send_cmd(vb, &vb->free_page_cmd_in, true);
+	break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: cmd class not supported\n",
+			 __func__);
+	}
+}
+
+static int init_vqs(struct virtio_balloon *vb)
+{
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
+	/* If ctrlq is enabled, the free page vq will also be created */
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CTRL_VQ))
+		nvqs += 2;
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
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CTRL_VQ)) {
+		callbacks[i] = ctrlq_handle;
+		names[i++] = "ctrlq";
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
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CTRL_VQ)) {
+		vb->ctrl_vq = vqs[i++];
+		vb->free_page_vq = vqs[i];
+		/* Prime the ctrlq with an inbuf for the host to send a cmd */
+		vb->free_page_cmd_in.class =
+					VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
+		ctrlq_send_cmd(vb, &vb->free_page_cmd_in, true);
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
@@ -706,6 +906,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
 		xb_init(&vb->page_xb);
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_CTRL_VQ)) {
+		vb->balloon_wq = alloc_workqueue("balloon-wq",
+					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
+		INIT_WORK(&vb->report_free_page_work, report_free_page);
+		vb->report_free_page_stop = true;
+	}
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
@@ -770,6 +977,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	spin_unlock_irq(&vb->stop_update_lock);
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
+	cancel_work_sync(&vb->report_free_page_work);
 
 	remove_common(vb);
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -823,6 +1031,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_SG,
+	VIRTIO_BALLOON_F_CTRL_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 37780a7..dbf0616 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
+#define VIRTIO_BALLOON_F_CTRL_VQ	4 /* Control Virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -83,4 +84,18 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+enum {
+	VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE = 0,
+	VIRTIO_BALLOON_CTRLQ_CLASS_MAX,
+};
+
+struct virtio_balloon_ctrlq_cmd {
+	__virtio32 class;
+	__virtio32 cmd;
+};
+
+/* Ctrlq commands related to VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE */
+#define VIRTIO_BALLOON_FREE_PAGE_F_STOP		0
+#define VIRTIO_BALLOON_FREE_PAGE_F_START	1
+
 #endif /* _LINUX_VIRTIO_BALLOON_H */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
