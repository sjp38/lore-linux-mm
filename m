Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 361A26B02B0
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 09:51:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v25so35012764pfg.14
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 06:51:21 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k91si33600880pld.294.2018.01.02.06.51.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Jan 2018 06:51:19 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] virtio_balloon: use non-blocking allocation
Date: Tue,  2 Jan 2018 23:50:21 +0900
Message-Id: <1514904621-39186-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Wei Wang <wei.w.wang@intel.com>

Commit c7cdff0e864713a0 ("virtio_balloon: fix deadlock on OOM") tried to
avoid OOM lockup by moving memory allocations to outside of balloon_lock.

Now, Wei is trying to allocate far more pages outside of balloon_lock and
some more memory inside of balloon_lock in order to perform efficient
communication between host and guest using scatter-gather API.

Since pages allocated outside of balloon_lock are not visible to the OOM
notifier path until fill_balloon() holds balloon_lock (and enqueues the
pending pages), allocating more pages than now may lead to unacceptably
premature OOM killer invocation.

It would be possible to make the pending pages visible to the OOM notifier
path. But there is no need to try to allocate memory so hard from the
beginning. As of commit 18468d93e53b037e ("mm: introduce a common
interface for balloon pages mobility"), it made sense to try allocation
as hard as possible. But after commit 5a10b7dbf904bfe0 ("virtio_balloon:
free some memory from balloon on OOM"), it no longer makes sense to try
allocation as hard as possible, for fill_balloon() will after all have to
release just allocated memory if some allocation request hits the OOM
notifier path. Therefore, this patch disables __GFP_DIRECT_RECLAIM when
allocating memory for inflating the balloon. Then, memory for inflating
the balloon can be allocated inside balloon_lock, and we can release just
allocated memory as needed.

Also, this patch adds __GFP_NOWARN, for possibility of hitting memory
allocation failure is increased by removing __GFP_DIRECT_RECLAIM, which
might spam the kernel log buffer. At the same time, this patch moves
"puff" messages to outside of balloon_lock, for it is not a good thing to
block the OOM notifier path for 1/5 of a second. (Moreover, it is better
to release the workqueue and allow processing other pending items. But
that change is out of this patch's scope.)

__GFP_NOMEMALLOC is currently not required because workqueue context
which calls balloon_page_alloc() won't cause __gfp_pfmemalloc_flags()
to return ALLOC_OOM. But since some process context might start calling
balloon_page_alloc() in future, this patch does not remove
__GFP_NOMEMALLOC.

(Only compile tested. Please do runtime tests before committing.)

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
---
 drivers/virtio/virtio_balloon.c | 23 +++++++++++++----------
 mm/balloon_compaction.c         |  5 +++--
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index dfe5684..4d9409b 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -141,7 +141,7 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
-static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
+static unsigned fill_balloon(struct virtio_balloon *vb, size_t num, bool *oom)
 {
 	unsigned num_allocated_pages;
 	unsigned num_pfns;
@@ -151,24 +151,19 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
+	mutex_lock(&vb->balloon_lock);
+
 	for (num_pfns = 0; num_pfns < num;
 	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		struct page *page = balloon_page_alloc();
 
 		if (!page) {
-			dev_info_ratelimited(&vb->vdev->dev,
-					     "Out of puff! Can't get %u pages\n",
-					     VIRTIO_BALLOON_PAGES_PER_PAGE);
-			/* Sleep for at least 1/5 of a second before retry. */
-			msleep(200);
+			*oom = true;
 			break;
 		}
-
 		balloon_page_push(&pages, page);
 	}
 
-	mutex_lock(&vb->balloon_lock);
-
 	vb->num_pfns = 0;
 
 	while ((page = balloon_page_pop(&pages))) {
@@ -404,17 +399,25 @@ static void update_balloon_size_func(struct work_struct *work)
 {
 	struct virtio_balloon *vb;
 	s64 diff;
+	bool oom = false;
 
 	vb = container_of(work, struct virtio_balloon,
 			  update_balloon_size_work);
 	diff = towards_target(vb);
 
 	if (diff > 0)
-		diff -= fill_balloon(vb, diff);
+		diff -= fill_balloon(vb, diff, &oom);
 	else if (diff < 0)
 		diff += leak_balloon(vb, -diff);
 	update_balloon_size(vb);
 
+	if (oom) {
+		dev_info_ratelimited(&vb->vdev->dev,
+				     "Out of puff! Can't get %u pages\n",
+				     VIRTIO_BALLOON_PAGES_PER_PAGE);
+		/* Sleep for at least 1/5 of a second before retry. */
+		msleep(200);
+	}
 	if (diff)
 		queue_work(system_freezable_wq, work);
 }
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index ef858d5..067df56 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -21,8 +21,9 @@
  */
 struct page *balloon_page_alloc(void)
 {
-	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
-				       __GFP_NOMEMALLOC | __GFP_NORETRY);
+	struct page *page = alloc_page((balloon_mapping_gfp_mask() |
+					__GFP_NOMEMALLOC | __GFP_NOWARN) &
+				       ~__GFP_DIRECT_RECLAIM);
 	return page;
 }
 EXPORT_SYMBOL_GPL(balloon_page_alloc);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
