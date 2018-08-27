Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3277B6B3E08
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 22:02:09 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so10734063pfn.3
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 19:02:09 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id h17-v6si12964984pgj.214.2018.08.26.19.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Aug 2018 19:02:07 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v37 1/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Date: Mon, 27 Aug 2018 09:32:17 +0800
Message-Id: <1535333539-32420-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com>
References: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, dgilbert@redhat.com
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, quintela@redhat.com

Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
support of reporting hints of guest free pages to host via virtio-balloon.
Currenlty, only free page blocks of MAX_ORDER - 1 are reported. They are
obtained one by one from the mm free list via the regular allocation
function.

Host requests the guest to report free page hints by sending a new cmd id
to the guest via the free_page_report_cmd_id configuration register. When
the guest starts to report, it first sends a start cmd to host via the
free page vq, which acks to host the cmd id received. When the guest
finishes reporting free pages, a stop cmd is sent to host via the vq.
Host may also send a stop cmd id to the guest to stop the reporting.

VIRTIO_BALLOON_CMD_ID_STOP: Host sends this cmd to stop the guest
reporting.
VIRTIO_BALLOON_CMD_ID_DONE: Host sends this cmd to tell the guest that
the reported pages are ready to be freed.

Why does the guest free the reported pages when host tells it is ready to
free?
This is because freeing pages appears to be expensive for live migration.
free_pages() dirties memory very quickly and makes the live migraion not
converge in some cases. So it is good to delay the free_page operation
when the migration is done, and host sends a command to guest about that.

Why do we need the new VIRTIO_BALLOON_CMD_ID_DONE, instead of reusing
VIRTIO_BALLOON_CMD_ID_STOP?
This is because live migration is usually done in several rounds. At the
end of each round, host needs to send a VIRTIO_BALLOON_CMD_ID_STOP cmd to
the guest to stop (or say pause) the reporting. The guest resumes the
reporting when it receives a new command id at the beginning of the next
round. So we need a new cmd id to distinguish between "stop reporting" and
"ready to free the reported pages".

TODO:
- Add a batch page allocation API to amortize the allocation overhead.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/virtio/virtio_balloon.c     | 364 ++++++++++++++++++++++++++++++++----
 include/uapi/linux/virtio_balloon.h |   5 +
 2 files changed, 336 insertions(+), 33 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index d1c1f62..a185678 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -41,13 +41,34 @@
 #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+#define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
+					     __GFP_NOMEMALLOC)
+/* The order of free page blocks to report to host */
+#define VIRTIO_BALLOON_FREE_PAGE_ORDER (MAX_ORDER - 1)
+/* The size of a free page block in bytes */
+#define VIRTIO_BALLOON_FREE_PAGE_SIZE \
+	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
+
 #ifdef CONFIG_BALLOON_COMPACTION
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
@@ -57,6 +78,18 @@ struct virtio_balloon {
 	spinlock_t stop_update_lock;
 	bool stop_update;
 
+	/* The list of allocated free pages, waiting to be given back to mm */
+	struct list_head free_page_list;
+	spinlock_t free_page_list_lock;
+	/* The number of free page blocks on the above list */
+	unsigned long num_free_page_blocks;
+	/* The cmd id received from host */
+	u32 cmd_id_received;
+	/* The cmd id that is actively in use */
+	__virtio32 cmd_id_active;
+	/* Buffer to store the stop sign */
+	__virtio32 cmd_id_stop;
+
 	/* Waiting for host to ack the pages we released. */
 	wait_queue_head_t acked;
 
@@ -320,17 +353,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
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
@@ -347,6 +369,60 @@ static inline s64 towards_target(struct virtio_balloon *vb)
 	return target - vb->num_pages;
 }
 
+/* Gives back @num_to_return blocks of free pages to mm. */
+static unsigned long return_free_pages_to_mm(struct virtio_balloon *vb,
+					     unsigned long num_to_return)
+{
+	struct page *page;
+	unsigned long num_returned;
+
+	spin_lock_irq(&vb->free_page_list_lock);
+	for (num_returned = 0; num_returned < num_to_return; num_returned++) {
+		page = balloon_page_pop(&vb->free_page_list);
+		if (!page)
+			break;
+		free_pages((unsigned long)page_address(page),
+			   VIRTIO_BALLOON_FREE_PAGE_ORDER);
+	}
+	vb->num_free_page_blocks -= num_returned;
+	spin_unlock_irq(&vb->free_page_list_lock);
+
+	return num_returned;
+}
+
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
+		if (vb->cmd_id_received == VIRTIO_BALLOON_CMD_ID_DONE) {
+			/* Pass ULONG_MAX to give back all the free pages */
+			return_free_pages_to_mm(vb, ULONG_MAX);
+		} else if (vb->cmd_id_received != VIRTIO_BALLOON_CMD_ID_STOP &&
+			   vb->cmd_id_received !=
+			   virtio32_to_cpu(vdev, vb->cmd_id_active)) {
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
 static void update_balloon_size(struct virtio_balloon *vb)
 {
 	u32 actual = vb->num_pages;
@@ -389,26 +465,44 @@ static void update_balloon_size_func(struct work_struct *work)
 
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
@@ -426,9 +520,145 @@ static int init_vqs(struct virtio_balloon *vb)
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
+	/* There is always 1 entry reserved for the cmd id to use. */
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
+		vb->num_free_page_blocks++;
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
+	struct device *dev = &vb->vdev->dev;
+
+	/* Start by sending the received cmd id to host with an outbuf. */
+	err = send_cmd_id_start(vb);
+	if (unlikely(err))
+		dev_err(dev, "Failed to send a start id, err = %d\n", err);
+
+	err = send_free_pages(vb);
+	if (unlikely(err))
+		dev_err(dev, "Failed to send a free page, err = %d\n", err);
+
+	/* End by sending a stop id to host with an outbuf. */
+	err = send_cmd_id_stop(vb);
+	if (unlikely(err))
+		dev_err(dev, "Failed to send a stop id, err = %d\n", err);
+}
+
 #ifdef CONFIG_BALLOON_COMPACTION
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
@@ -512,14 +742,23 @@ static struct file_system_type balloon_fs = {
 
 #endif /* CONFIG_BALLOON_COMPACTION */
 
-static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
-						  struct shrink_control *sc)
+static unsigned long shrink_free_pages(struct virtio_balloon *vb,
+				       unsigned long pages_to_free)
 {
-	unsigned long pages_to_free, pages_freed = 0;
-	struct virtio_balloon *vb = container_of(shrinker,
-					struct virtio_balloon, shrinker);
+	unsigned long blocks_to_free, blocks_freed;
 
-	pages_to_free = sc->nr_to_scan * VIRTIO_BALLOON_PAGES_PER_PAGE;
+	pages_to_free = round_up(pages_to_free,
+				 1 << VIRTIO_BALLOON_FREE_PAGE_ORDER);
+	blocks_to_free = pages_to_free >> VIRTIO_BALLOON_FREE_PAGE_ORDER;
+	blocks_freed = return_free_pages_to_mm(vb, blocks_to_free);
+
+	return blocks_freed << VIRTIO_BALLOON_FREE_PAGE_ORDER;
+}
+
+static unsigned long shrink_balloon_pages(struct virtio_balloon *vb,
+					  unsigned long pages_to_free)
+{
+	unsigned long pages_freed = 0;
 
 	/*
 	 * One invocation of leak_balloon can deflate at most
@@ -527,12 +766,33 @@ static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
 	 * multiple times to deflate pages till reaching pages_to_free.
 	 */
 	while (vb->num_pages && pages_to_free) {
+		pages_freed += leak_balloon(vb, pages_to_free) /
+					VIRTIO_BALLOON_PAGES_PER_PAGE;
 		pages_to_free -= pages_freed;
-		pages_freed += leak_balloon(vb, pages_to_free);
 	}
 	update_balloon_size(vb);
 
-	return pages_freed / VIRTIO_BALLOON_PAGES_PER_PAGE;
+	return pages_freed;
+}
+
+static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
+						  struct shrink_control *sc)
+{
+	unsigned long pages_to_free, pages_freed = 0;
+	struct virtio_balloon *vb = container_of(shrinker,
+					struct virtio_balloon, shrinker);
+
+	pages_to_free = sc->nr_to_scan * VIRTIO_BALLOON_PAGES_PER_PAGE;
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		pages_freed = shrink_free_pages(vb, pages_to_free);
+
+	if (pages_freed >= pages_to_free)
+		return pages_freed;
+
+	pages_freed += shrink_balloon_pages(vb, pages_to_free - pages_freed);
+
+	return pages_freed;
 }
 
 static unsigned long virtio_balloon_shrinker_count(struct shrinker *shrinker,
@@ -540,8 +800,12 @@ static unsigned long virtio_balloon_shrinker_count(struct shrinker *shrinker,
 {
 	struct virtio_balloon *vb = container_of(shrinker,
 					struct virtio_balloon, shrinker);
+	unsigned long count;
 
-	return vb->num_pages / VIRTIO_BALLOON_PAGES_PER_PAGE;
+	count = vb->num_pages / VIRTIO_BALLOON_PAGES_PER_PAGE;
+	count += vb->num_free_page_blocks >> VIRTIO_BALLOON_FREE_PAGE_ORDER;
+
+	return count;
 }
 
 static void virtio_balloon_unregister_shrinker(struct virtio_balloon *vb)
@@ -604,6 +868,31 @@ static int virtballoon_probe(struct virtio_device *vdev)
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
+		vb->num_free_page_blocks = 0;
+		spin_lock_init(&vb->free_page_list_lock);
+		INIT_LIST_HEAD(&vb->free_page_list);
+	}
 	/*
 	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a
 	 * shrinker needs to be registered to relieve memory pressure.
@@ -611,7 +900,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM)) {
 		err = virtio_balloon_register_shrinker(vb);
 		if (err)
-			goto out_del_vqs;
+			goto out_del_balloon_wq;
 	}
 	virtio_device_ready(vdev);
 
@@ -619,6 +908,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		virtballoon_changed(vdev);
 	return 0;
 
+out_del_balloon_wq:
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		destroy_workqueue(vb->balloon_wq);
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
@@ -652,6 +944,11 @@ static void virtballoon_remove(struct virtio_device *vdev)
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
@@ -703,6 +1000,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 13b8cb5..47c9eb4 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,15 +34,20 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
 
+#define VIRTIO_BALLOON_CMD_ID_STOP	0
+#define VIRTIO_BALLOON_CMD_ID_DONE	1
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
