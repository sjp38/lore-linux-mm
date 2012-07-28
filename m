Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 402266B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:58:53 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 27 Jul 2012 21:58:52 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3AE9E19D803C
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 03:58:01 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6S3w4ew036894
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 21:58:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6S3w2X2002597
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 21:58:04 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 5/5] [RFC][HACK] Switch volatile/shmem over to LRU_VOLATILE
Date: Fri, 27 Jul 2012 23:57:12 -0400
Message-Id: <1343447832-7182-6-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This changes the earlier shrinker based volatile range
management over to using the LRU_VOLATILE list in mm core.

Again, this is likely has performance issues, as well as
other problems I'm not aware of, so I'd greatly appreciate
any additional feedback or suggestions.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Android Kernel Team <kernel-team@android.com>
CC: Robert Love <rlove@google.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Hugh Dickins <hughd@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Rik van Riel <riel@redhat.com>
CC: Dmitry Adamushko <dmitry.adamushko@gmail.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Neil Brown <neilb@suse.de>
CC: Andrea Righi <andrea@betterlinux.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
CC: Mike Hommey <mh@glandium.org>
CC: Jan Kara <jack@suse.cz>
CC: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
CC: Michel Lespinasse <walken@google.com>
CC: Minchan Kim <minchan@kernel.org>
CC: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/volatile.h |   12 ++----
 mm/shmem.c               |  103 ++++++++++++++++++++++++----------------------
 mm/volatile.c            |   86 ++++++++------------------------------
 3 files changed, 75 insertions(+), 126 deletions(-)

diff --git a/include/linux/volatile.h b/include/linux/volatile.h
index 6f41b98..7bd11c1 100644
--- a/include/linux/volatile.h
+++ b/include/linux/volatile.h
@@ -5,15 +5,11 @@
 
 struct volatile_fs_head {
 	struct mutex lock;
-	struct list_head lru_head;
-	s64 unpurged_page_count;
 };
 
 
 #define DEFINE_VOLATILE_FS_HEAD(name) struct volatile_fs_head name = {	\
 	.lock = __MUTEX_INITIALIZER(name.lock),				\
-	.lru_head = LIST_HEAD_INIT(name.lru_head),			\
-	.unpurged_page_count = 0,					\
 }
 
 
@@ -34,12 +30,10 @@ extern long volatile_range_remove(struct volatile_fs_head *head,
 				struct address_space *mapping,
 				pgoff_t start_index, pgoff_t end_index);
 
-extern s64 volatile_range_lru_size(struct volatile_fs_head *head);
-
 extern void volatile_range_clear(struct volatile_fs_head *head,
 					struct address_space *mapping);
 
-extern s64 volatile_ranges_pluck_lru(struct volatile_fs_head *head,
-				struct address_space **mapping,
-				pgoff_t *start, pgoff_t *end);
+int volatile_page_mark_range_purged(struct volatile_fs_head *head,
+							struct page *page);
+
 #endif /* _LINUX_VOLATILE_H */
diff --git a/mm/shmem.c b/mm/shmem.c
index e5ce04c..79f75af 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -636,6 +636,34 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 
 static DEFINE_VOLATILE_FS_HEAD(shmem_volatile_head);
 
+void modify_range(struct address_space *mapping, pgoff_t start, pgoff_t end,
+			void(*activate_func)(struct page*))
+{
+	struct pagevec pvec;
+	pgoff_t index = start;
+	int i;
+
+	pagevec_init(&pvec, 0);
+	while (index <= end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		mem_cgroup_uncharge_start();
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+
+			/* We rely upon deletion not changing page->index */
+			index = page->index;
+			if (index > end)
+				break;
+
+			activate_func(page);
+		}
+		pagevec_release(&pvec);
+		mem_cgroup_uncharge_end();
+		cond_resched();
+		index++;
+	}
+}
+
 static int shmem_mark_volatile(struct inode *inode, loff_t offset, loff_t len)
 {
 	pgoff_t start, end;
@@ -652,7 +680,11 @@ static int shmem_mark_volatile(struct inode *inode, loff_t offset, loff_t len)
 				((loff_t) start << PAGE_CACHE_SHIFT),
 				((loff_t) end << PAGE_CACHE_SHIFT)-1);
 		ret = 0;
+
 	}
+
+	modify_range(&inode->i_data, start, end-1, &mark_volatile_page);
+
 	volatile_range_unlock(&shmem_volatile_head);
 
 	return ret;
@@ -669,6 +701,9 @@ static int shmem_unmark_volatile(struct inode *inode, loff_t offset, loff_t len)
 	volatile_range_lock(&shmem_volatile_head);
 	ret = volatile_range_remove(&shmem_volatile_head, &inode->i_data,
 								start, end);
+
+	modify_range(&inode->i_data, start, end-1, &mark_nonvolatile_page);
+
 	volatile_range_unlock(&shmem_volatile_head);
 
 	return ret;
@@ -681,55 +716,6 @@ static void shmem_clear_volatile(struct inode *inode)
 	volatile_range_unlock(&shmem_volatile_head);
 }
 
-static
-int shmem_volatile_shrink(struct shrinker *ignored, struct shrink_control *sc)
-{
-	s64 nr_to_scan = sc->nr_to_scan;
-	const gfp_t gfp_mask = sc->gfp_mask;
-	struct address_space *mapping;
-	pgoff_t start, end;
-	int ret;
-	s64 page_count;
-
-	if (nr_to_scan && !(gfp_mask & __GFP_FS))
-		return -1;
-
-	volatile_range_lock(&shmem_volatile_head);
-	page_count = volatile_range_lru_size(&shmem_volatile_head);
-	if (!nr_to_scan)
-		goto out;
-
-	do {
-		ret = volatile_ranges_pluck_lru(&shmem_volatile_head,
-							&mapping, &start, &end);
-		if (ret) {
-			shmem_truncate_range(mapping->host,
-				((loff_t) start << PAGE_CACHE_SHIFT),
-				((loff_t) end << PAGE_CACHE_SHIFT)-1);
-
-			nr_to_scan -= end-start;
-			page_count -= end-start;
-		};
-	} while (ret && (nr_to_scan > 0));
-
-out:
-	volatile_range_unlock(&shmem_volatile_head);
-
-	return page_count;
-}
-
-static struct shrinker shmem_volatile_shrinker = {
-	.shrink = shmem_volatile_shrink,
-	.seeks = DEFAULT_SEEKS,
-};
-
-static int __init shmem_shrinker_init(void)
-{
-	register_shrinker(&shmem_volatile_shrinker);
-	return 0;
-}
-arch_initcall(shmem_shrinker_init);
-
 
 static void shmem_evict_inode(struct inode *inode)
 {
@@ -884,6 +870,24 @@ out:
 	return error;
 }
 
+static int shmem_purgepage(struct page *page, struct writeback_control *wbc)
+{
+	struct address_space *mapping;
+	struct inode *inode;
+	int purge;
+
+	BUG_ON(!PageLocked(page));
+	mapping = page->mapping;
+	inode = mapping->host;
+
+	volatile_range_lock(&shmem_volatile_head);
+	purge = volatile_page_mark_range_purged(&shmem_volatile_head, page);
+	volatile_range_unlock(&shmem_volatile_head);
+
+	return 0;
+}
+
+
 /*
  * Move the page from the page cache to the swap cache.
  */
@@ -2817,6 +2821,7 @@ static const struct address_space_operations shmem_aops = {
 #endif
 	.migratepage	= migrate_page,
 	.error_remove_page = generic_error_remove_page,
+	.purgepage	= shmem_purgepage,
 };
 
 static const struct file_operations shmem_file_operations = {
diff --git a/mm/volatile.c b/mm/volatile.c
index d05a767..b7db12a 100644
--- a/mm/volatile.c
+++ b/mm/volatile.c
@@ -53,7 +53,6 @@
 
 
 struct volatile_range {
-	struct list_head		lru;
 	struct prio_tree_node		node;
 	unsigned int			purged;
 	struct address_space		*mapping;
@@ -159,15 +158,8 @@ static inline void vrange_resize(struct volatile_fs_head *head,
 				struct volatile_range *vrange,
 				pgoff_t start_index, pgoff_t end_index)
 {
-	pgoff_t old_size, new_size;
-
-	old_size = vrange->node.last - vrange->node.start;
-	new_size = end_index-start_index;
-
-	if (!vrange->purged)
-		head->unpurged_page_count += new_size - old_size;
-
 	prio_tree_remove(root, &vrange->node);
+	INIT_PRIO_TREE_NODE(&vrange->node);
 	vrange->node.start = start_index;
 	vrange->node.last = end_index;
 	prio_tree_insert(root, &vrange->node);
@@ -189,15 +181,7 @@ static void vrange_add(struct volatile_fs_head *head,
 				struct prio_tree_root *root,
 				struct volatile_range *vrange)
 {
-
 	prio_tree_insert(root, &vrange->node);
-
-	/* Only add unpurged ranges to LRU */
-	if (!vrange->purged) {
-		head->unpurged_page_count += vrange->node.last - vrange->node.start;
-		list_add_tail(&vrange->lru, &head->lru_head);
-	}
-
 }
 
 
@@ -206,10 +190,6 @@ static void vrange_del(struct volatile_fs_head *head,
 				struct prio_tree_root *root,
 				struct volatile_range *vrange)
 {
-	if (!vrange->purged) {
-		head->unpurged_page_count -= vrange->node.last - vrange->node.start;
-		list_del(&vrange->lru);
-	}
 	prio_tree_remove(root, &vrange->node);
 	kfree(vrange);
 }
@@ -416,62 +396,32 @@ out:
 	return ret;
 }
 
-/**
- * volatile_range_lru_size: Returns the number of unpurged pages on the lru
- * @head: per-fs volatile head
- *
- * Returns the number of unpurged pages on the LRU
- *
- * Must lock the volatile_fs_head before calling!
- *
- */
-s64 volatile_range_lru_size(struct volatile_fs_head *head)
-{
-	WARN_ON(!mutex_is_locked(&head->lock));
-	return head->unpurged_page_count;
-}
-
-
-/**
- * volatile_ranges_pluck_lru: Returns mapping and size of lru unpurged range
- * @head: per-fs volatile head
- * @mapping: dbl pointer to mapping who's range is being purged
- * @start: Pointer to starting address of range being purged
- * @end: Pointer to ending address of range being purged
- *
- * Returns the mapping, start and end values of the least recently used
- * range. Marks the range as purged and removes it from the LRU.
- *
- * Must lock the volatile_fs_head before calling!
- *
- * Returns 1 on success if a range was returned
- * Return 0 if no ranges were found.
- */
-s64 volatile_ranges_pluck_lru(struct volatile_fs_head *head,
-				struct address_space **mapping,
-				pgoff_t *start, pgoff_t *end)
+int volatile_page_mark_range_purged(struct volatile_fs_head *head,
+							struct page *page)
 {
-	struct volatile_range *range;
+	struct prio_tree_root *root;
+	struct prio_tree_node *node;
+	struct prio_tree_iter iter;
+	struct volatile_range *vrange;
+	int ret	= 0;
 
 	WARN_ON(!mutex_is_locked(&head->lock));
 
-	if (list_empty(&head->lru_head))
+	root = mapping_to_root(page->mapping);
+	if (!root)
 		return 0;
 
-	range = list_first_entry(&head->lru_head, struct volatile_range, lru);
-
-	*start = range->node.start;
-	*end = range->node.last;
-	*mapping = range->mapping;
-
-	head->unpurged_page_count -= *end - *start;
-	list_del(&range->lru);
-	range->purged = 1;
+	prio_tree_iter_init(&iter, root, page->index, page->index);
+	node = prio_tree_next(&iter);
+	if (node) {
+		vrange = container_of(node, struct volatile_range, node);
 
-	return 1;
+		vrange->purged = 1;
+		ret = 1;
+	}
+	return ret;
 }
 
-
 /*
  * Cleans up any volatile ranges.
  */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
