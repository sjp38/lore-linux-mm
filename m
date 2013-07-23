Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E4A8C6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 18:04:32 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH v2] lib: Make radix_tree_node_alloc() work correctly within interrupt
Date: Wed, 24 Jul 2013 00:04:20 +0200
Message-Id: <1374617060-25805-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jens Axboe <jaxboe@fusionio.com>, Jan Kara <jack@suse.cz>

With users of radix_tree_preload() run from interrupt (block/blk-ioc.c
is one such possible user), the following race can happen:

radix_tree_preload()
...
radix_tree_insert()
  radix_tree_node_alloc()
    if (rtp->nr) {
      ret = rtp->nodes[rtp->nr - 1];
<interrupt>
...
radix_tree_preload()
...
radix_tree_insert()
  radix_tree_node_alloc()
    if (rtp->nr) {
      ret = rtp->nodes[rtp->nr - 1];

And we give out one radix tree node twice. That clearly results in radix
tree corruption with different results (usually OOPS) depending on which
two users of radix tree race.

We fix the problem by making radix_tree_node_alloc() always allocate
fresh radix tree nodes when in interrupt. Using preloading when in
interrupt doesn't make sence since all the allocations have to be atomic
anyway and we cannot steal nodes from process-context users because some
users rely on radix_tree_insert() succeeding after radix_tree_preload().
in_interrupt() check is somewhat ugly but we cannot simply key off
passed gfp_mask as that is acquired from root_gfp_mask() and thus
the same for all preload users.

Another part of the fix is to avoid node preallocation in
radix_tree_preload() when passed gfp_mask doesn't allow waiting. Again,
preallocation in such case doesn't make sence and when preallocation
would happen in interrupt we could possibly leak some allocated nodes.
However, some users of radix_tree_preload() require following
radix_tree_insert() to succeed. To avoid unexpected effects for these
users, radix_tree_preload() only warns if passed gfp mask doesn't allow
waiting and we provide a new function radix_tree_maybe_preload() for
those users which get different gfp mask from different call sites and
which are prepared to handle radix_tree_insert() failure.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 block/blk-ioc.c            |  2 +-
 fs/fscache/page.c          |  2 +-
 include/linux/radix-tree.h |  1 +
 lib/radix-tree.c           | 41 +++++++++++++++++++++++++++++++++++++++--
 mm/filemap.c               |  2 +-
 mm/shmem.c                 |  2 +-
 mm/swap_state.c            |  4 ++--
 7 files changed, 46 insertions(+), 8 deletions(-)

So after some discussions over the first version here comes v2 which should
handle issues we found.

diff --git a/block/blk-ioc.c b/block/blk-ioc.c
index 4464c82..46cd7bd 100644
--- a/block/blk-ioc.c
+++ b/block/blk-ioc.c
@@ -367,7 +367,7 @@ struct io_cq *ioc_create_icq(struct io_context *ioc, struct request_queue *q,
 	if (!icq)
 		return NULL;
 
-	if (radix_tree_preload(gfp_mask) < 0) {
+	if (radix_tree_maybe_preload(gfp_mask) < 0) {
 		kmem_cache_free(et->icq_cache, icq);
 		return NULL;
 	}
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index d479ab3..24350b8 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -890,7 +890,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 		(1 << FSCACHE_OP_WAITING) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
 
-	ret = radix_tree_preload(gfp & ~__GFP_HIGHMEM);
+	ret = radix_tree_maybe_preload(gfp & ~__GFP_HIGHMEM);
 	if (ret < 0)
 		goto nomem_free;
 
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index ffc444c..4039407 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -231,6 +231,7 @@ unsigned long radix_tree_next_hole(struct radix_tree_root *root,
 unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
 int radix_tree_preload(gfp_t gfp_mask);
+int radix_tree_maybe_preload(gfp_t gfp_mask);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e796429..7811ed3 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -32,6 +32,7 @@
 #include <linux/string.h>
 #include <linux/bitops.h>
 #include <linux/rcupdate.h>
+#include <linux/hardirq.h>		/* in_interrupt() */
 
 
 #ifdef __KERNEL__
@@ -207,7 +208,12 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 	struct radix_tree_node *ret = NULL;
 	gfp_t gfp_mask = root_gfp_mask(root);
 
-	if (!(gfp_mask & __GFP_WAIT)) {
+	/*
+	 * Preload code isn't irq safe and it doesn't make sence to use
+	 * preloading in the interrupt anyway as all the allocations have to
+	 * be atomic. So just do normal allocation when in interrupt.
+	 */
+	if (!(gfp_mask & __GFP_WAIT) && !in_interrupt()) {
 		struct radix_tree_preload *rtp;
 
 		/*
@@ -264,7 +270,7 @@ radix_tree_node_free(struct radix_tree_node *node)
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_WAIT being passed to INIT_RADIX_TREE().
  */
-int radix_tree_preload(gfp_t gfp_mask)
+static int __radix_tree_preload(gfp_t gfp_mask)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
@@ -288,9 +294,40 @@ int radix_tree_preload(gfp_t gfp_mask)
 out:
 	return ret;
 }
+
+/*
+ * Load up this CPU's radix_tree_node buffer with sufficient objects to
+ * ensure that the addition of a single element in the tree cannot fail.  On
+ * success, return zero, with preemption disabled.  On error, return -ENOMEM
+ * with preemption not disabled.
+ *
+ * To make use of this facility, the radix tree must be initialised without
+ * __GFP_WAIT being passed to INIT_RADIX_TREE().
+ */
+int radix_tree_preload(gfp_t gfp_mask)
+{
+	/* Warn on non-sensical use... */
+	WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT));
+	return __radix_tree_preload(gfp_mask);
+}
 EXPORT_SYMBOL(radix_tree_preload);
 
 /*
+ * The same as above function, except we don't guarantee preloading happens.
+ * We do it, if we decide it helps. On success, return zero with preemption
+ * disabled. On error, return -ENOMEM with preemption not disabled.
+ */
+int radix_tree_maybe_preload(gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_WAIT)
+		return __radix_tree_preload(gfp_mask);
+	/* Preloading doesn't help anything with this gfp mask, skip it */
+	preempt_disable();
+	return 0;
+}
+EXPORT_SYMBOL(radix_tree_maybe_preload);
+
+/*
  *	Return the maximum key which can be store into a
  *	radix tree with height HEIGHT.
  */
diff --git a/mm/filemap.c b/mm/filemap.c
index 4b51ac1..12b1634 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -469,7 +469,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 	if (error)
 		goto out;
 
-	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
 		page_cache_get(page);
 		page->mapping = mapping;
diff --git a/mm/shmem.c b/mm/shmem.c
index a87990c..762a032 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1205,7 +1205,7 @@ repeat:
 						gfp & GFP_RECLAIM_MASK);
 		if (error)
 			goto decused;
-		error = radix_tree_preload(gfp & GFP_RECLAIM_MASK);
+		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
 							gfp, NULL);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index f24ab0d..e6f15f8 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -122,7 +122,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
 {
 	int error;
 
-	error = radix_tree_preload(gfp_mask);
+	error = radix_tree_maybe_preload(gfp_mask);
 	if (!error) {
 		error = __add_to_swap_cache(page, entry);
 		radix_tree_preload_end();
@@ -328,7 +328,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		/*
 		 * call radix_tree_preload() while we can wait.
 		 */
-		err = radix_tree_preload(gfp_mask & GFP_KERNEL);
+		err = radix_tree_maybe_preload(gfp_mask & GFP_KERNEL);
 		if (err)
 			break;
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
