Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6AD36B026F
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:00:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m4-v6so5562816pgq.19
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:00:44 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w15-v6si1381027pga.30.2018.07.20.02.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:00:42 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v36 3/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Date: Fri, 20 Jul 2018 16:33:03 +0800
Message-Id: <1532075585-39067-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
support of reporting hints of guest free pages to host via virtio-balloon.
Currenlty, only free page blocks of MAX_ORDER - 1 are reported. They are
obtained one by one from the mm free list via the regular allocation
function. The allocated pages are given back to mm after they are put onto
the vq.

Host requests the guest to report free page hints by sending a new cmd id
to the guest via the free_page_report_cmd_id configuration register. When
the guest starts to report, it first sends a start cmd to host via the
free page vq, which acks to host the cmd id received. When the guest
finishes reporting free pages, a stop cmd is sent to host via the vq.

TODO:
- Add a batch page allocation API to amortize the allocation overhead.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/virtio/virtio_balloon.c     | 331 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |   4 +
 2 files changed, 307 insertions(+), 28 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index c6fd406..82cd497 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -42,6 +42,14 @@
 #define DEFAULT_BALLOON_PAGES_TO_SHRINK 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+#define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
+					     __GFP_NOMEMALLOC)
+/* The order of free page blocks to report to host */
+#define VIRTIO_BALLOON_FREE_PAGE_ORDER (MAX_ORDER - 1)
+/* The size of a free page block in bytes */
+#define VIRTIO_BALLOON_FREE_PAGE_SIZE \
+	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
+
 static unsigned long balloon_pages_to_shrink = DEFAULT_BALLOON_PAGES_TO_SHRINK;
 module_param(balloon_pages_to_shrink, ulong, 0600);
 MODULE_PARM_DESC(balloon_pages_to_shrink, "pages to free on memory presure");
@@ -50,9 +58,22 @@ MODULE_PARM_DESC(balloon_pages_to_shrink, "pages to free on memory presure");
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
@@ -62,6 +83,16 @@ struct virtio_balloon {
 	spinlock_t stop_update_lock;
 	bool stop_update;
 
+	/* The list of allocated free pages, waiting to be given back to mm */
+	struct list_head free_page_list;
+	spinlock_t free_page_list_lock;
+	/* The cmd id received from host */
+	u32 cmd_id_received;
+	/* The cmd id that is actively in use */
+	__virtio32 cmd_id_active;
+	/* Buffer to store the stop sign */
+	__virtio32 cmd_id_stop;
+
 	/* Waiting for host to ack the pages we released. */
 	wait_queue_head_t acked;
 
@@ -325,17 +356,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
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
@@ -352,6 +372,52 @@ static inline s64 towards_target(struct virtio_balloon *vb)
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
+		if (vb->cmd_id_received != VIRTIO_BALLOON_CMD_ID_STOP &&
+		    vb->cmd_id_received !=
+				virtio32_to_cpu(vdev, vb->cmd_id_active)) {
+			spin_lock_irqsave(&vb->stop_update_lock, flags);
+			if (!vb->stop_update) {
+				queue_work(vb->balloon_wq,
+					   &vb->report_free_page_work);
+			}
+			spin_unlock_irqrestore(&vb->stop_update_lock, flags);
+		}
+	}
+}
+
+static unsigned long return_free_pages_to_mm(struct virtio_balloon *vb)
+{
+	struct page *page;
+	unsigned long num = 0;
+
+	spin_lock_irq(&vb->free_page_list_lock);
+	while ((page = balloon_page_pop(&vb->free_page_list))) {
+		free_pages((unsigned long)page_address(page),
+			   VIRTIO_BALLOON_FREE_PAGE_ORDER);
+		num++;
+	}
+	spin_unlock_irq(&vb->free_page_list_lock);
+
+	return num;
+}
+
 static void update_balloon_size(struct virtio_balloon *vb)
 {
 	u32 actual = vb->num_pages;
@@ -394,26 +460,44 @@ static void update_balloon_size_func(struct work_struct *work)
 
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
+		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
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
@@ -431,9 +515,145 @@ static int init_vqs(struct virtio_balloon *vb)
 		}
 		virtqueue_kick(vb->stats_vq);
 	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		vb->free_page_vq = vqs[VIRTIO_BALLOON_VQ_FREE_PAGE];
+
+	return 0;
+}
+
+static int send_cmd_id_start(struct virtio_balloon *vb)
+{
+	struct scatterlist sg;
+	struct virtqueue *vq = vb->free_page_vq;
+	int err, unused;
+
+	/* Detach all the used buffers from the vq */
+	while (virtqueue_get_buf(vq, &unused))
+		;
+
+	vb->cmd_id_active = cpu_to_virtio32(vb->vdev, vb->cmd_id_received);
+	sg_init_one(&sg, &vb->cmd_id_active, sizeof(vb->cmd_id_active));
+	err = virtqueue_add_outbuf(vq, &sg, 1, &vb->cmd_id_active, GFP_KERNEL);
+	if (!err)
+		virtqueue_kick(vq);
+	return err;
+}
+
+static int send_cmd_id_stop(struct virtio_balloon *vb)
+{
+	struct scatterlist sg;
+	struct virtqueue *vq = vb->free_page_vq;
+	int err, unused;
+
+	/* Detach all the used buffers from the vq */
+	while (virtqueue_get_buf(vq, &unused))
+		;
+
+	sg_init_one(&sg, &vb->cmd_id_stop, sizeof(vb->cmd_id_stop));
+	err = virtqueue_add_outbuf(vq, &sg, 1, &vb->cmd_id_stop, GFP_KERNEL);
+	if (!err)
+		virtqueue_kick(vq);
+	return err;
+}
+
+static int get_free_page_and_send(struct virtio_balloon *vb)
+{
+	struct virtqueue *vq = vb->free_page_vq;
+	struct page *page;
+	struct scatterlist sg;
+	int err, unused;
+	void *p;
+
+	/* Detach all the used buffers from the vq */
+	while (virtqueue_get_buf(vq, &unused))
+		;
+
+	page = alloc_pages(VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG,
+			   VIRTIO_BALLOON_FREE_PAGE_ORDER);
+	/*
+	 * When the allocation returns NULL, it indicates that we have got all
+	 * the possible free pages, so return -EINTR to stop.
+	 */
+	if (!page)
+		return -EINTR;
+
+	p = page_address(page);
+	sg_init_one(&sg, p, VIRTIO_BALLOON_FREE_PAGE_SIZE);
+	/* There is always one entry reserved for the cmd id to use. */
+	if (vq->num_free > 1) {
+		err = virtqueue_add_inbuf(vq, &sg, 1, p, GFP_KERNEL);
+		if (unlikely(err)) {
+			free_pages((unsigned long)p,
+				   VIRTIO_BALLOON_FREE_PAGE_ORDER);
+			return err;
+		}
+		virtqueue_kick(vq);
+		spin_lock_irq(&vb->free_page_list_lock);
+		balloon_page_push(&vb->free_page_list, page);
+		spin_unlock_irq(&vb->free_page_list_lock);
+	} else {
+		/*
+		 * The vq has no available entry to add this page block, so
+		 * just free it.
+		 */
+		free_pages((unsigned long)p, VIRTIO_BALLOON_FREE_PAGE_ORDER);
+	}
+
 	return 0;
 }
 
+static int send_free_pages(struct virtio_balloon *vb)
+{
+	int err;
+	u32 cmd_id_active;
+
+	while (1) {
+		/*
+		 * If a stop id or a new cmd id was just received from host,
+		 * stop the reporting.
+		 */
+		cmd_id_active = virtio32_to_cpu(vb->vdev, vb->cmd_id_active);
+		if (cmd_id_active != vb->cmd_id_received)
+			break;
+
+		/*
+		 * The free page blocks are allocated and sent to host one by
+		 * one.
+		 */
+		err = get_free_page_and_send(vb);
+		if (err == -EINTR)
+			break;
+		else if (unlikely(err))
+			return err;
+	}
+
+	return 0;
+}
+
+static void report_free_page_func(struct work_struct *work)
+{
+	int err;
+	struct virtio_balloon *vb = container_of(work, struct virtio_balloon,
+						 report_free_page_work);
+
+	/* Start by sending the received cmd id to host with an outbuf. */
+	err = send_cmd_id_start(vb);
+	if (unlikely(err))
+		goto out_err;
+
+	err = send_free_pages(vb);
+	return_free_pages_to_mm(vb);
+	if (unlikely(err))
+		goto out_err;
+
+	/* End by sending a stop id to host with an outbuf. */
+	err = send_cmd_id_stop(vb);
+out_err:
+	if (err)
+		dev_err(&vb->vdev->dev, "%s: err = %d\n", __func__, err);
+}
+
 #ifdef CONFIG_BALLOON_COMPACTION
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
@@ -523,6 +743,16 @@ static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
 	struct virtio_balloon *vb = container_of(shrinker,
 					struct virtio_balloon, shrinker);
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		pages_freed = return_free_pages_to_mm(vb) <<
+			      VIRTIO_BALLOON_FREE_PAGE_ORDER;
+	}
+
+	if (pages_freed >= pages_to_free)
+		return pages_freed;
+
+	pages_to_free -= pages_freed;
+
 	/*
 	 * One invocation of leak_balloon can deflate at most
 	 * VIRTIO_BALLOON_ARRAY_PFNS_MAX balloon pages, so we call it
@@ -530,8 +760,8 @@ static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
 	 * balloon_pages_to_shrink pages.
 	 */
 	while (vb->num_pages && pages_to_free) {
-		pages_to_free = balloon_pages_to_shrink - pages_freed;
 		pages_freed += leak_balloon(vb, pages_to_free);
+		pages_to_free -= pages_freed;
 	}
 	update_balloon_size(vb);
 
@@ -541,6 +771,7 @@ static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
 static unsigned long virtio_balloon_shrinker_count(struct shrinker *shrinker,
 						   struct shrink_control *sc)
 {
+	unsigned long count;
 	struct virtio_balloon *vb = container_of(shrinker,
 					struct virtio_balloon, shrinker);
 
@@ -551,8 +782,18 @@ static unsigned long virtio_balloon_shrinker_count(struct shrinker *shrinker,
 	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 		return 0;
 
-	return min_t(unsigned long, vb->num_pages, balloon_pages_to_shrink) /
-	       VIRTIO_BALLOON_PAGES_PER_PAGE;
+	count = min_t(unsigned long, vb->num_pages, balloon_pages_to_shrink) /
+		VIRTIO_BALLOON_PAGES_PER_PAGE;
+
+	/*
+	 * Just add one block of free pages for the count estimation. We will
+	 * release all of them in shrinker_scan regardless of the count
+	 * returned here.
+	 */
+	if (!list_empty(&vb->free_page_list))
+		count += 1 << VIRTIO_BALLOON_FREE_PAGE_ORDER;
+
+	return count;
 }
 
 static void virtio_balloon_unregister_shrinker(struct virtio_balloon *vb)
@@ -615,13 +856,38 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		err = PTR_ERR(vb->vb_dev_info.inode);
 		kern_unmount(balloon_mnt);
 		vb->vb_dev_info.inode = NULL;
-		goto out_del_vqs;
+		goto out_del_balloon_wq;
 	}
 	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
 #endif
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
+		vb->cmd_id_received = VIRTIO_BALLOON_CMD_ID_STOP;
+		vb->cmd_id_active = cpu_to_virtio32(vb->vdev,
+						  VIRTIO_BALLOON_CMD_ID_STOP);
+		vb->cmd_id_stop = cpu_to_virtio32(vb->vdev,
+						  VIRTIO_BALLOON_CMD_ID_STOP);
+		spin_lock_init(&vb->free_page_list_lock);
+		INIT_LIST_HEAD(&vb->free_page_list);
+	}
+
 	err = virtio_balloon_register_shrinker(vb);
 	if (err)
-		goto out_del_vqs;
+		goto out_del_balloon_wq;
 
 	virtio_device_ready(vdev);
 
@@ -629,6 +895,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		virtballoon_changed(vdev);
 	return 0;
 
+out_del_balloon_wq:
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		destroy_workqueue(vb->balloon_wq);
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
@@ -662,6 +931,11 @@ static void virtballoon_remove(struct virtio_device *vdev)
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
@@ -713,6 +987,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 13b8cb5..18ee430 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,15 +34,19 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
 
+#define VIRTIO_BALLOON_CMD_ID_STOP	0
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
