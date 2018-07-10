Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A88976B026C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 05:56:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g5-v6so278316pgq.5
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 02:56:55 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r3-v6si15637780pgo.606.2018.07.10.02.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 02:56:54 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v35 3/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Date: Tue, 10 Jul 2018 17:31:05 +0800
Message-Id: <1531215067-35472-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
support of reporting hints of guest free pages to host via virtio-balloon.

Host requests the guest to report free page hints by sending a new cmd id
to the guest via the free_page_report_cmd_id configuration register.

As the first step here, virtio-balloon only reports free page hints from
the max order (i.e. 10) free page list to host. This has generated similar
good results as reporting all free page hints during our tests.

When the guest starts to report, it first sends a start cmd to host via
the free page vq, which acks to host the cmd id received, and tells it the
hint size (e.g. 4MB each on x86). When the guest finishes the reporting,
a stop cmd is sent to host via the vq.

TODO:
- support reporting free page hints from smaller order free page lists
  when there is a need/request from users.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/virtio/virtio_balloon.c     | 399 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |  11 +
 2 files changed, 384 insertions(+), 26 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 9356a1a..8754154 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -43,6 +43,14 @@
 #define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+/* The order used to allocate a buffer to load free page hints */
+#define VIRTIO_BALLOON_HINT_BUF_ORDER (MAX_ORDER - 1)
+/* The number of pages a hint buffer has */
+#define VIRTIO_BALLOON_HINT_BUF_PAGES (1 << VIRTIO_BALLOON_HINT_BUF_ORDER)
+/* The size of a hint buffer in bytes */
+#define VIRTIO_BALLOON_HINT_BUF_SIZE (VIRTIO_BALLOON_HINT_BUF_PAGES << \
+				      PAGE_SHIFT)
+
 static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
@@ -51,9 +59,22 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 static struct vfsmount *balloon_mnt;
 #endif
 
+enum virtio_balloon_vq {
+	VIRTIO_BALLOON_VQ_INFLATE,
+	VIRTIO_BALLOON_VQ_DEFLATE,
+	VIRTIO_BALLOON_VQ_STATS,
+	VIRTIO_BALLOON_VQ_FREE_PAGE,
+	VIRTIO_BALLOON_VQ_MAX
+};
+
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
@@ -63,6 +84,15 @@ struct virtio_balloon {
 	spinlock_t stop_update_lock;
 	bool stop_update;
 
+	/* Command buffers to start and stop the reporting of hints to host */
+	struct virtio_balloon_free_page_hints_cmd cmd_start;
+	struct virtio_balloon_free_page_hints_cmd cmd_stop;
+
+	/* The cmd id received from host */
+	u32 cmd_id_received;
+	/* The cmd id that is actively in use */
+	u32 cmd_id_active;
+
 	/* Waiting for host to ack the pages we released. */
 	wait_queue_head_t acked;
 
@@ -326,17 +356,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
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
@@ -353,6 +372,35 @@ static inline s64 towards_target(struct virtio_balloon *vb)
 	return target - vb->num_pages;
 }
 
+static void virtballoon_changed(struct virtio_device *vdev)
+{
+	struct virtio_balloon *vb = vdev->priv;
+	unsigned long flags;
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
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		virtio_cread(vdev, struct virtio_balloon_config,
+			     free_page_report_cmd_id, &vb->cmd_id_received);
+		if (vb->cmd_id_received !=
+		    VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID &&
+		    vb->cmd_id_received != vb->cmd_id_active) {
+			spin_lock_irqsave(&vb->stop_update_lock, flags);
+			if (!vb->stop_update)
+				queue_work(vb->balloon_wq,
+					   &vb->report_free_page_work);
+			spin_unlock_irqrestore(&vb->stop_update_lock, flags);
+		}
+	}
+}
+
 static void update_balloon_size(struct virtio_balloon *vb)
 {
 	u32 actual = vb->num_pages;
@@ -425,28 +473,61 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void virtio_balloon_free_used_hint_buf(struct virtqueue *vq)
+{
+	unsigned int len;
+	void *buf;
+	struct virtio_balloon *vb = vq->vdev->priv;
+
+	do {
+		buf = virtqueue_get_buf(vq, &len);
+		if (buf == &vb->cmd_start || buf == &vb->cmd_stop)
+			continue;
+		free_pages((unsigned long)buf, VIRTIO_BALLOON_HINT_BUF_ORDER);
+	} while (buf);
+}
+
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
-	int err, nvqs;
+	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_MAX];
+	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_MAX];
+	const char *names[VIRTIO_BALLOON_VQ_MAX];
+	int err;
 
 	/*
-	 * We expect two virtqueues: inflate and deflate, and
-	 * optionally stat.
+	 * Inflateq and deflateq are used unconditionally. The names[]
+	 * will be NULL if the related feature is not enabled, which will
+	 * cause no allocation for the corresponding virtqueue in find_vqs.
 	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
+	callbacks[VIRTIO_BALLOON_VQ_INFLATE] = balloon_ack;
+	names[VIRTIO_BALLOON_VQ_INFLATE] = "inflate";
+	callbacks[VIRTIO_BALLOON_VQ_DEFLATE] = balloon_ack;
+	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
+	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
+	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
+		callbacks[VIRTIO_BALLOON_VQ_STATS] = stats_request;
+	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		names[VIRTIO_BALLOON_VQ_FREE_PAGE] = "free_page_vq";
+		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] =
+					virtio_balloon_free_used_hint_buf;
+	}
+
+	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
+					 vqs, callbacks, names, NULL, NULL);
 	if (err)
 		return err;
 
-	vb->inflate_vq = vqs[0];
-	vb->deflate_vq = vqs[1];
+	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
+	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		struct scatterlist sg;
 		unsigned int num_stats;
-		vb->stats_vq = vqs[2];
+		vb->stats_vq = vqs[VIRTIO_BALLOON_VQ_STATS];
 
 		/*
 		 * Prime this virtqueue with one buffer so the hypervisor can
@@ -464,9 +545,246 @@ static int init_vqs(struct virtio_balloon *vb)
 		}
 		virtqueue_kick(vb->stats_vq);
 	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		vb->free_page_vq = vqs[VIRTIO_BALLOON_VQ_FREE_PAGE];
+
 	return 0;
 }
 
+static int send_start_cmd_id(struct virtio_balloon *vb)
+{
+	struct scatterlist sg;
+	struct virtqueue *vq = vb->free_page_vq;
+	int err;
+
+	virtio_balloon_free_used_hint_buf(vq);
+
+	vb->cmd_start.id = cpu_to_virtio32(vb->vdev, vb->cmd_id_active);
+	vb->cmd_start.size = cpu_to_virtio32(vb->vdev,
+					     MAX_ORDER_NR_PAGES * PAGE_SIZE);
+	sg_init_one(&sg, &vb->cmd_start,
+		    sizeof(struct virtio_balloon_free_page_hints_cmd));
+
+	err = virtqueue_add_outbuf(vq, &sg, 1, &vb->cmd_start, GFP_KERNEL);
+	if (!err)
+		virtqueue_kick(vq);
+	return err;
+}
+
+static int send_stop_cmd_id(struct virtio_balloon *vb)
+{
+	struct scatterlist sg;
+	struct virtqueue *vq = vb->free_page_vq;
+	int err;
+
+	virtio_balloon_free_used_hint_buf(vq);
+
+	vb->cmd_stop.id = cpu_to_virtio32(vb->vdev,
+				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
+	vb->cmd_stop.size = 0;
+	sg_init_one(&sg, &vb->cmd_stop,
+		    sizeof(struct virtio_balloon_free_page_hints_cmd));
+	err = virtqueue_add_outbuf(vq, &sg, 1, &vb->cmd_stop, GFP_KERNEL);
+	if (!err)
+		virtqueue_kick(vq);
+	return err;
+}
+
+static int send_hint_buf(struct virtio_balloon *vb, void *buf,
+			 unsigned int size)
+{
+	int err;
+	struct scatterlist sg;
+	struct virtqueue *vq = vb->free_page_vq;
+
+	virtio_balloon_free_used_hint_buf(vq);
+
+	/*
+	 * If a stop id or a new cmd id was just received from host,
+	 * stop the reporting, return -EINTR to indicate an active stop.
+	 */
+	if (vb->cmd_id_received != vb->cmd_id_active)
+		return -EINTR;
+
+	/* There is always one entry reserved for the cmd id to use. */
+	if (vq->num_free < 2)
+		return -ENOSPC;
+
+	sg_init_one(&sg, buf, size);
+	err = virtqueue_add_inbuf(vq, &sg, 1, buf, GFP_KERNEL);
+	if (!err)
+		virtqueue_kick(vq);
+	return err;
+}
+
+static void virtio_balloon_free_hint_bufs(struct list_head *pages)
+{
+	struct page *page, *next;
+
+	list_for_each_entry_safe(page, next, pages, lru) {
+		__free_pages(page, VIRTIO_BALLOON_HINT_BUF_ORDER);
+		list_del(&page->lru);
+	}
+}
+
+/*
+ * virtio_balloon_send_hints - send buffers of hints to host
+ * @vb: the virtio_balloon struct
+ * @pages: the list of page blocks used as buffers
+ * @hint_num: the total number of hints
+ *
+ * Send buffers of hints to host. This begins by sending a start cmd, which
+ * contains a cmd id received from host and the free page block size in bytes
+ * of each hint. At the end, a stop cmd is sent to host to indicate the end
+ * of this reporting. If host actively requests to stop the reporting, free
+ * the buffers that have not been sent.
+ */
+static void virtio_balloon_send_hints(struct virtio_balloon *vb,
+				      struct list_head *pages,
+				      unsigned long hint_num)
+{
+	struct page *page, *next;
+	void *buf;
+	unsigned int buf_size, hint_size;
+	int err;
+
+	/* Start by sending the received cmd id to host with an outbuf. */
+	err = send_start_cmd_id(vb);
+	if (unlikely(err))
+		goto out_free;
+
+	list_for_each_entry_safe(page, next, pages, lru) {
+		/* We've sent all the hints. */
+		if (!hint_num)
+			break;
+		hint_size = hint_num * sizeof(__le64);
+		buf = page_address(page);
+		buf_size = hint_size > VIRTIO_BALLOON_HINT_BUF_SIZE ?
+			   VIRTIO_BALLOON_HINT_BUF_SIZE : hint_size;
+		hint_num -= buf_size / sizeof(__le64);
+		err = send_hint_buf(vb, buf, buf_size);
+		/*
+		 * If host actively stops the reporting or no space to add more
+		 * hint bufs, just stop adding hints and continue to add the
+		 * stop cmd. Other device errors need to bail out with an error
+		 * message.
+		 */
+		if (unlikely(err == -EINTR || err == -ENOSPC))
+			break;
+		else if (unlikely(err))
+			goto out_free;
+		/*
+		 * Remove the buffer from the list only when it has been given
+		 * to host. Otherwise, it will stay on the list and will be
+		 * freed via virtio_balloon_free_hint_bufs.
+		 */
+		list_del(&page->lru);
+	}
+
+	/* End by sending a stop id to host with an outbuf. */
+	err = send_stop_cmd_id(vb);
+out_free:
+	if (err)
+		dev_err(&vb->vdev->dev, "%s: err = %d\n", __func__, err);
+	/* Free all the buffers that are not sent to host. */
+	virtio_balloon_free_hint_bufs(pages);
+}
+
+/*
+ * Allocate a list of buffers to load free page hints. Those buffers are
+ * allocated based on the estimation of the max number of free page blocks
+ * that the system may have, so that they are sufficient to store all the
+ * free page addresses.
+ *
+ * Return 0 on success, otherwise false.
+ */
+static int virtio_balloon_alloc_hint_bufs(struct list_head *pages)
+{
+	struct page *page;
+	unsigned long max_entries, entries_per_page, entries_per_buf,
+		      max_buf_num;
+	int i;
+
+	max_entries = max_free_page_blocks(VIRTIO_BALLOON_HINT_BUF_ORDER);
+	entries_per_page = PAGE_SIZE / sizeof(__le64);
+	entries_per_buf = entries_per_page * VIRTIO_BALLOON_HINT_BUF_PAGES;
+	max_buf_num = max_entries / entries_per_buf +
+		      !!(max_entries % entries_per_buf);
+
+	for (i = 0; i < max_buf_num; i++) {
+		page = alloc_pages(__GFP_ATOMIC | __GFP_NOMEMALLOC,
+				   VIRTIO_BALLOON_HINT_BUF_ORDER);
+		if (!page) {
+			/*
+			 * If any one of the buffers fails to be allocated, it
+			 * implies that the free list that we are interested
+			 * in is empty, and there is no need to continue the
+			 * reporting. So just free what's allocated and return
+			 * -ENOMEM.
+			 */
+			virtio_balloon_free_hint_bufs(pages);
+			return -ENOMEM;
+		}
+		list_add(&page->lru, pages);
+	}
+
+	return 0;
+}
+
+/*
+ * virtio_balloon_load_hints - load free page hints into buffers
+ * @vb: the virtio_balloon struct
+ * @pages: the list of page blocks used as buffers
+ *
+ * Only free pages blocks of MAX_ORDER - 1 are loaded into the buffers.
+ * Each buffer size is MAX_ORDER_NR_PAGES * PAGE_SIZE (e.g. 4MB on x86).
+ * Failing to allocate such a buffer essentially implies that no such free
+ * page blocks could be reported.
+ *
+ * Return the total number of hints loaded into the buffers.
+ */
+static unsigned long virtio_balloon_load_hints(struct virtio_balloon *vb,
+					       struct list_head *pages)
+{
+	unsigned long loaded_hints = 0;
+	int ret;
+
+	do {
+		ret = virtio_balloon_alloc_hint_bufs(pages);
+		if (ret)
+			return 0;
+
+		ret = get_from_free_page_list(VIRTIO_BALLOON_HINT_BUF_ORDER,
+					pages, VIRTIO_BALLOON_HINT_BUF_SIZE,
+					&loaded_hints);
+		/*
+		 * Retry in the case that memory is onlined quickly, which
+		 * causes the allocated buffers to be insufficient to store
+		 * all the free page addresses. Free the hint buffers before
+		 * retry.
+		 */
+		if (unlikely(ret == -ENOSPC))
+			virtio_balloon_free_hint_bufs(pages);
+	} while (ret == -ENOSPC);
+
+	return loaded_hints;
+}
+
+static void report_free_page_func(struct work_struct *work)
+{
+	struct virtio_balloon *vb;
+	unsigned long loaded_hints = 0;
+	LIST_HEAD(pages);
+
+	vb = container_of(work, struct virtio_balloon, report_free_page_work);
+	vb->cmd_id_active = vb->cmd_id_received;
+
+	loaded_hints = virtio_balloon_load_hints(vb, &pages);
+	if (loaded_hints)
+		virtio_balloon_send_hints(vb, &pages, loaded_hints);
+}
+
 #ifdef CONFIG_BALLOON_COMPACTION
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
@@ -580,18 +898,38 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (err)
 		goto out_free_vb;
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		/*
+		 * There is always one entry reserved for cmd id, so the ring
+		 * size needs to be at least two to report free page hints.
+		 */
+		if (virtqueue_get_vring_size(vb->free_page_vq) < 2) {
+			err = -ENOSPC;
+			goto out_del_vqs;
+		}
+		vb->balloon_wq = alloc_workqueue("balloon-wq",
+					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
+		if (!vb->balloon_wq) {
+			err = -ENOMEM;
+			goto out_del_vqs;
+		}
+		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
+		vb->cmd_id_received = VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID;
+		vb->cmd_id_active = VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID;
+	}
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
 	if (err < 0)
-		goto out_del_vqs;
+		goto out_del_balloon_wq;
 
 #ifdef CONFIG_BALLOON_COMPACTION
 	balloon_mnt = kern_mount(&balloon_fs);
 	if (IS_ERR(balloon_mnt)) {
 		err = PTR_ERR(balloon_mnt);
 		unregister_oom_notifier(&vb->nb);
-		goto out_del_vqs;
+		goto out_del_balloon_wq;
 	}
 
 	vb->vb_dev_info.migratepage = virtballoon_migratepage;
@@ -601,7 +939,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		kern_unmount(balloon_mnt);
 		unregister_oom_notifier(&vb->nb);
 		vb->vb_dev_info.inode = NULL;
-		goto out_del_vqs;
+		goto out_del_balloon_wq;
 	}
 	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
 #endif
@@ -612,6 +950,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		virtballoon_changed(vdev);
 	return 0;
 
+out_del_balloon_wq:
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		destroy_workqueue(vb->balloon_wq);
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
@@ -645,6 +986,11 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		cancel_work_sync(&vb->report_free_page_work);
+		destroy_workqueue(vb->balloon_wq);
+	}
+
 	remove_common(vb);
 #ifdef CONFIG_BALLOON_COMPACTION
 	if (vb->vb_dev_info.inode)
@@ -696,6 +1042,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 13b8cb5..b77919b 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,15 +34,26 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
 
+#define VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID	0
 struct virtio_balloon_config {
 	/* Number of pages host wants Guest to give up. */
 	__u32 num_pages;
 	/* Number of pages we've actually got in balloon. */
 	__u32 actual;
+	/* Free page report command id, readonly by guest */
+	__u32 free_page_report_cmd_id;
+};
+
+struct virtio_balloon_free_page_hints_cmd {
+	/* The command id received from host */
+	__virtio32 id;
+	/* The free page block size in bytes */
+	__virtio32 size;
 };
 
 #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
-- 
2.7.4
