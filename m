Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46E456B0069
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:08:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h28so10022265pfh.16
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:08:24 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i85si704365pfj.398.2017.10.20.05.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:08:23 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v1 1/3] virtio-balloon: replace the coarse-grained balloon_lock
Date: Fri, 20 Oct 2017 19:54:24 +0800
Message-Id: <1508500466-21165-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org
Cc: Wei Wang <wei.w.wang@intel.com>

The balloon_lock was used to synchronize the access demand to elements
of struct virtio_balloon and its queue operations (please see commit
e22504296d). This prevents the concurrent run of the leak_balloon and
fill_balloon functions, thereby resulting in a deadlock issue on OOM:

fill_balloon: take balloon_lock and wait for OOM to get some memory;
oom_notify: release some inflated memory via leak_balloon();
leak_balloon: wait for balloon_lock to be released by fill_balloon.

This patch breaks the lock into two fine-grained inflate_lock and
deflate_lock, and eliminates the unnecessary use of the shared data
(i.e. vb->pnfs, vb->num_pfns). This enables leak_balloon and
fill_balloon to run concurrently and solves the deadlock issue.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>
---
 drivers/virtio/virtio_balloon.c | 102 +++++++++++++++++++++-------------------
 1 file changed, 53 insertions(+), 49 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f0b3a0b..1ecd15a 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -67,7 +67,7 @@ struct virtio_balloon {
 	wait_queue_head_t acked;
 
 	/* Number of balloon pages we've told the Host we're not using. */
-	unsigned int num_pages;
+	atomic64_t num_pages;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -76,12 +76,9 @@ struct virtio_balloon {
 	 */
 	struct balloon_dev_info vb_dev_info;
 
-	/* Synchronize access/update to this struct virtio_balloon elements */
-	struct mutex balloon_lock;
-
-	/* The array of pfns we tell the Host about. */
-	unsigned int num_pfns;
-	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
+	/* Synchronize access to inflate_vq and deflate_vq respectively */
+	struct mutex inflate_lock;
+	struct mutex deflate_lock;
 
 	/* Memory statistics */
 	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
@@ -111,12 +108,13 @@ static void balloon_ack(struct virtqueue *vq)
 	wake_up(&vb->acked);
 }
 
-static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
+static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq,
+		      __virtio32 pfns[], unsigned int num_pfns)
 {
 	struct scatterlist sg;
 	unsigned int len;
 
-	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	sg_init_one(&sg, pfns, sizeof(pfns[0]) * num_pfns);
 
 	/* We should always be able to add one buffer to an empty queue. */
 	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
@@ -144,14 +142,14 @@ static void set_page_pfns(struct virtio_balloon *vb,
 static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
-	unsigned num_allocated_pages;
+	unsigned int num_pfns;
+	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
 
 	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	num = min_t(size_t, num, VIRTIO_BALLOON_ARRAY_PFNS_MAX);
 
-	mutex_lock(&vb->balloon_lock);
-	for (vb->num_pfns = 0; vb->num_pfns < num;
-	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
+	for (num_pfns = 0; num_pfns < num;
+	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		struct page *page = balloon_page_enqueue(vb_dev_info);
 
 		if (!page) {
@@ -162,20 +160,20 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			msleep(200);
 			break;
 		}
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
-		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, pfns + num_pfns, page);
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 			adjust_managed_page_count(page, -1);
 	}
 
-	num_allocated_pages = vb->num_pfns;
+	mutex_lock(&vb->inflate_lock);
 	/* Did we get any? */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->inflate_vq);
-	mutex_unlock(&vb->balloon_lock);
+	if (num_pfns != 0)
+		tell_host(vb, vb->inflate_vq, pfns, num_pfns);
+	mutex_unlock(&vb->inflate_lock);
+	atomic64_add(num_pfns, &vb->num_pages);
 
-	return num_allocated_pages;
+	return num_pfns;
 }
 
 static void release_pages_balloon(struct virtio_balloon *vb,
@@ -194,38 +192,39 @@ static void release_pages_balloon(struct virtio_balloon *vb,
 
 static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 {
-	unsigned num_freed_pages;
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	LIST_HEAD(pages);
+	unsigned int num_pfns;
+	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
 
 	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	num = min_t(size_t, num, VIRTIO_BALLOON_ARRAY_PFNS_MAX);
 
-	mutex_lock(&vb->balloon_lock);
 	/* We can't release more pages than taken */
-	num = min(num, (size_t)vb->num_pages);
-	for (vb->num_pfns = 0; vb->num_pfns < num;
-	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
+	num = min_t(size_t, num, atomic64_read(&vb->num_pages));
+	for (num_pfns = 0; num_pfns < num;
+	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		set_page_pfns(vb, pfns + num_pfns, page);
 		list_add(&page->lru, &pages);
-		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
 
-	num_freed_pages = vb->num_pfns;
 	/*
 	 * Note that if
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->deflate_vq);
+	mutex_lock(&vb->deflate_lock);
+	if (num_pfns != 0)
+		tell_host(vb, vb->deflate_vq, pfns, num_pfns);
+	mutex_unlock(&vb->deflate_lock);
 	release_pages_balloon(vb, &pages);
-	mutex_unlock(&vb->balloon_lock);
-	return num_freed_pages;
+	atomic64_sub(num_pfns, &vb->num_pages);
+
+	return num_pfns;
 }
 
 static inline void update_stat(struct virtio_balloon *vb, int idx,
@@ -327,12 +326,12 @@ static inline s64 towards_target(struct virtio_balloon *vb)
 		num_pages = le32_to_cpu((__force __le32)num_pages);
 
 	target = num_pages;
-	return target - vb->num_pages;
+	return target - atomic64_read(&vb->num_pages);
 }
 
 static void update_balloon_size(struct virtio_balloon *vb)
 {
-	u32 actual = vb->num_pages;
+	u32 actual = atomic64_read(&vb->num_pages);
 
 	/* Legacy balloon config space is LE, unlike all other devices. */
 	if (!virtio_has_feature(vb->vdev, VIRTIO_F_VERSION_1))
@@ -465,6 +464,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
 	unsigned long flags;
+	__virtio32 pfns[VIRTIO_BALLOON_PAGES_PER_PAGE];
 
 	/*
 	 * In order to avoid lock contention while migrating pages concurrently
@@ -474,8 +474,12 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	 * recursion in the case it ends up triggering memory compaction
 	 * while it is attempting to inflate the ballon.
 	 */
-	if (!mutex_trylock(&vb->balloon_lock))
+	if (!mutex_trylock(&vb->inflate_lock))
+		return -EAGAIN;
+	if (!mutex_trylock(&vb->deflate_lock)) {
+		mutex_unlock(&vb->inflate_lock);
 		return -EAGAIN;
+	}
 
 	get_page(newpage); /* balloon reference */
 
@@ -485,17 +489,16 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	vb_dev_info->isolated_pages--;
 	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, newpage);
-	tell_host(vb, vb->inflate_vq);
+
+	set_page_pfns(vb, pfns, newpage);
+	tell_host(vb, vb->inflate_vq, pfns, VIRTIO_BALLOON_PAGES_PER_PAGE);
+	mutex_unlock(&vb->inflate_lock);
 
 	/* balloon's page migration 2nd step -- deflate "page" */
 	balloon_page_delete(page);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, page);
-	tell_host(vb, vb->deflate_vq);
-
-	mutex_unlock(&vb->balloon_lock);
+	set_page_pfns(vb, pfns, page);
+	tell_host(vb, vb->deflate_vq, pfns, VIRTIO_BALLOON_PAGES_PER_PAGE);
+	mutex_unlock(&vb->deflate_lock);
 
 	put_page(page); /* balloon reference */
 
@@ -542,8 +545,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
 	spin_lock_init(&vb->stop_update_lock);
 	vb->stop_update = false;
-	vb->num_pages = 0;
-	mutex_init(&vb->balloon_lock);
+	atomic64_set(&vb->num_pages, 0);
+	mutex_init(&vb->inflate_lock);
+	mutex_init(&vb->deflate_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
 
@@ -596,8 +600,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 static void remove_common(struct virtio_balloon *vb)
 {
 	/* There might be pages left in the balloon: free them. */
-	while (vb->num_pages)
-		leak_balloon(vb, vb->num_pages);
+	while (atomic64_read(&vb->num_pages))
+		leak_balloon(vb, atomic64_read(&vb->num_pages));
 	update_balloon_size(vb);
 
 	/* Now we reset the device so we can clean up the queues. */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
