Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EA1636B018E
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 19:27:06 -0400 (EDT)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH -mmotm 5/5] memcg: dirty pages instrumentation
Date: Mon, 15 Mar 2010 00:26:42 +0100
Message-Id: <1268609202-15581-6-git-send-email-arighi@develer.com>
In-Reply-To: <1268609202-15581-1-git-send-email-arighi@develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Righi <arighi@develer.com>
List-ID: <linux-mm.kvack.org>

Apply the cgroup dirty pages accounting and limiting infrastructure to
the opportune kernel functions.

[ NOTE: for now do not account WritebackTmp pages (FUSE) and NILFS2
bounce pages. This depends on charging also bounce pages per cgroup. ]

As a bonus, make determine_dirtyable_memory() static again: this
function isn't used anymore outside page writeback.

Signed-off-by: Andrea Righi <arighi@develer.com>
---
 fs/nfs/write.c            |    4 +
 include/linux/writeback.h |    2 -
 mm/filemap.c              |    1 +
 mm/page-writeback.c       |  215 ++++++++++++++++++++++++++++-----------------
 mm/rmap.c                 |    4 +-
 mm/truncate.c             |    1 +
 6 files changed, 141 insertions(+), 86 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 53ff70e..3e8b9f8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -440,6 +440,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 			NFS_PAGE_TAG_COMMIT);
 	nfsi->ncommit++;
 	spin_unlock(&inode->i_lock);
+	mem_cgroup_inc_page_stat(req->wb_page, MEMCG_NR_FILE_UNSTABLE_NFS);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
@@ -451,6 +452,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 	struct page *page = req->wb_page;
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_UNSTABLE_NFS);
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 		return 1;
@@ -1277,6 +1279,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
+		mem_cgroup_dec_page_stat(req->wb_page,
+				MEMCG_NR_FILE_UNSTABLE_NFS);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				BDI_RECLAIMABLE);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index dd9512d..39e4cb2 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -117,8 +117,6 @@ extern int vm_highmem_is_dirtyable;
 extern int block_dump;
 extern int laptop_mode;
 
-extern unsigned long determine_dirtyable_memory(void);
-
 extern int dirty_background_ratio_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
diff --git a/mm/filemap.c b/mm/filemap.c
index 62cbac0..bd833fe 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ab84693..fcac9b4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -131,6 +131,111 @@ static struct prop_descriptor vm_completions;
 static struct prop_descriptor vm_dirties;
 
 /*
+ * Work out the current dirty-memory clamping and background writeout
+ * thresholds.
+ *
+ * The main aim here is to lower them aggressively if there is a lot of mapped
+ * memory around.  To avoid stressing page reclaim with lots of unreclaimable
+ * pages.  It is better to clamp down on writers than to start swapping, and
+ * performing lots of scanning.
+ *
+ * We only allow 1/2 of the currently-unmapped memory to be dirtied.
+ *
+ * We don't permit the clamping level to fall below 5% - that is getting rather
+ * excessive.
+ *
+ * We make sure that the background writeout level is below the adjusted
+ * clamping level.
+ */
+
+static unsigned long highmem_dirtyable_memory(unsigned long total)
+{
+#ifdef CONFIG_HIGHMEM
+	int node;
+	unsigned long x = 0;
+
+	for_each_node_state(node, N_HIGH_MEMORY) {
+		struct zone *z =
+			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
+
+		x += zone_page_state(z, NR_FREE_PAGES) +
+		     zone_reclaimable_pages(z);
+	}
+	/*
+	 * Make sure that the number of highmem pages is never larger
+	 * than the number of the total dirtyable memory. This can only
+	 * occur in very strange VM situations but we want to make sure
+	 * that this does not occur.
+	 */
+	return min(x, total);
+#else
+	return 0;
+#endif
+}
+
+static unsigned long get_global_dirtyable_memory(void)
+{
+	unsigned long memory;
+
+	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
+	if (!vm_highmem_is_dirtyable)
+		memory -= highmem_dirtyable_memory(memory);
+	return memory + 1;
+}
+
+static unsigned long get_dirtyable_memory(void)
+{
+	unsigned long memory;
+	s64 memcg_memory;
+
+	memory = get_global_dirtyable_memory();
+	if (!mem_cgroup_has_dirty_limit())
+		return memory;
+	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
+	BUG_ON(memcg_memory < 0);
+
+	return min((unsigned long)memcg_memory, memory);
+}
+
+static long get_reclaimable_pages(void)
+{
+	s64 ret;
+
+	if (!mem_cgroup_has_dirty_limit())
+		return global_page_state(NR_FILE_DIRTY) +
+			global_page_state(NR_UNSTABLE_NFS);
+	ret = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
+	BUG_ON(ret < 0);
+
+	return ret;
+}
+
+static long get_writeback_pages(void)
+{
+	s64 ret;
+
+	if (!mem_cgroup_has_dirty_limit())
+		return global_page_state(NR_WRITEBACK);
+	ret = mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
+	BUG_ON(ret < 0);
+
+	return ret;
+}
+
+static unsigned long get_dirty_writeback_pages(void)
+{
+	s64 ret;
+
+	if (!mem_cgroup_has_dirty_limit())
+		return global_page_state(NR_UNSTABLE_NFS) +
+			global_page_state(NR_WRITEBACK);
+	ret = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
+	BUG_ON(ret < 0);
+
+	return ret;
+}
+
+/*
  * couple the period to the dirty_ratio:
  *
  *   period/2 ~ roundup_pow_of_two(dirty limit)
@@ -142,7 +247,7 @@ static int calc_period_shift(void)
 	if (vm_dirty_bytes)
 		dirty_total = vm_dirty_bytes / PAGE_SIZE;
 	else
-		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
+		dirty_total = (vm_dirty_ratio * get_global_dirtyable_memory()) /
 				100;
 	return 2 + ilog2(dirty_total - 1);
 }
@@ -355,92 +460,34 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
 }
 EXPORT_SYMBOL(bdi_set_max_ratio);
 
-/*
- * Work out the current dirty-memory clamping and background writeout
- * thresholds.
- *
- * The main aim here is to lower them aggressively if there is a lot of mapped
- * memory around.  To avoid stressing page reclaim with lots of unreclaimable
- * pages.  It is better to clamp down on writers than to start swapping, and
- * performing lots of scanning.
- *
- * We only allow 1/2 of the currently-unmapped memory to be dirtied.
- *
- * We don't permit the clamping level to fall below 5% - that is getting rather
- * excessive.
- *
- * We make sure that the background writeout level is below the adjusted
- * clamping level.
- */
-
-static unsigned long highmem_dirtyable_memory(unsigned long total)
-{
-#ifdef CONFIG_HIGHMEM
-	int node;
-	unsigned long x = 0;
-
-	for_each_node_state(node, N_HIGH_MEMORY) {
-		struct zone *z =
-			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
-
-		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z);
-	}
-	/*
-	 * Make sure that the number of highmem pages is never larger
-	 * than the number of the total dirtyable memory. This can only
-	 * occur in very strange VM situations but we want to make sure
-	 * that this does not occur.
-	 */
-	return min(x, total);
-#else
-	return 0;
-#endif
-}
-
-/**
- * determine_dirtyable_memory - amount of memory that may be used
- *
- * Returns the numebr of pages that can currently be freed and used
- * by the kernel for direct mappings.
- */
-unsigned long determine_dirtyable_memory(void)
-{
-	unsigned long x;
-
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
-
-	if (!vm_highmem_is_dirtyable)
-		x -= highmem_dirtyable_memory(x);
-
-	return x + 1;	/* Ensure that we never return 0 */
-}
-
 void
 get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
 		 unsigned long *pbdi_dirty, struct backing_dev_info *bdi)
 {
-	unsigned long background;
-	unsigned long dirty;
-	unsigned long available_memory = determine_dirtyable_memory();
+	unsigned long dirty, background;
+	unsigned long available_memory = get_dirtyable_memory();
 	struct task_struct *tsk;
+	struct vm_dirty_param dirty_param;
 
-	if (vm_dirty_bytes)
-		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
+	get_vm_dirty_param(&dirty_param);
+
+	if (dirty_param.dirty_bytes)
+		dirty = DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);
 	else {
 		int dirty_ratio;
 
-		dirty_ratio = vm_dirty_ratio;
+		dirty_ratio = dirty_param.dirty_ratio;
 		if (dirty_ratio < 5)
 			dirty_ratio = 5;
 		dirty = (dirty_ratio * available_memory) / 100;
 	}
 
-	if (dirty_background_bytes)
-		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
+	if (dirty_param.dirty_background_bytes)
+		background = DIV_ROUND_UP(dirty_param.dirty_background_bytes,
+						PAGE_SIZE);
 	else
-		background = (dirty_background_ratio * available_memory) / 100;
-
+		background = (dirty_param.dirty_background_ratio *
+						available_memory) / 100;
 	if (background >= dirty)
 		background = dirty / 2;
 	tsk = current;
@@ -505,9 +552,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 		get_dirty_limits(&background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
 
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+		nr_reclaimable = get_reclaimable_pages();
+		nr_writeback = get_writeback_pages();
 
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
@@ -593,10 +639,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 	 * In normal mode, we start background writeout at the lower
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
+	nr_reclaimable = get_reclaimable_pages();
 	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
-			       + global_page_state(NR_UNSTABLE_NFS))
-					  > background_thresh)))
+	    (!laptop_mode && (nr_reclaimable > background_thresh)))
 		bdi_start_writeback(bdi, NULL, 0);
 }
 
@@ -660,6 +705,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 	unsigned long dirty_thresh;
 
         for ( ; ; ) {
+		unsigned long dirty;
+
 		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 
                 /*
@@ -668,10 +715,10 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
-                congestion_wait(BLK_RW_ASYNC, HZ/10);
+		dirty = get_dirty_writeback_pages();
+		if (dirty <= dirty_thresh)
+			break;
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
 		 * The caller might hold locks which can prevent IO completion
@@ -1078,6 +1125,7 @@ int __set_page_dirty_no_writeback(struct page *page)
 void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		task_dirty_inc(current);
@@ -1279,6 +1327,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * for more comments.
 		 */
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
@@ -1310,6 +1359,7 @@ int test_clear_page_writeback(struct page *page)
 				__bdi_writeout_inc(bdi);
 			}
 		}
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestClearPageWriteback(page);
@@ -1341,6 +1391,7 @@ int test_set_page_writeback(struct page *page)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestSetPageWriteback(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index b5b2daf..916a660 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -828,8 +828,8 @@ void page_add_new_anon_rmap(struct page *page,
 void page_add_file_rmap(struct page *page)
 {
 	if (atomic_inc_and_test(&page->_mapcount)) {
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_stat(page, MEMCG_NR_FILE_MAPPED, true);
 	}
 }
 
@@ -860,8 +860,8 @@ void page_remove_rmap(struct page *page)
 		mem_cgroup_uncharge_page(page);
 		__dec_zone_page_state(page, NR_ANON_PAGES);
 	} else {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_stat(page, MEMCG_NR_FILE_MAPPED, false);
 	}
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
diff --git a/mm/truncate.c b/mm/truncate.c
index e87e372..83366da 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -73,6 +73,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
