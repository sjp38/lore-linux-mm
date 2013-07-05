Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 8EB966B0036
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 13:32:41 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so2318989pbc.7
        for <linux-mm@kvack.org>; Fri, 05 Jul 2013 10:32:40 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V4 3/6] memcg: add per cgroup dirty pages accounting
Date: Sat,  6 Jul 2013 01:30:09 +0800
Message-Id: <1373045409-27617-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: mhocko@suse.cz, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, fengguang.wu@intel.com, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

This patch adds memcg routines to count dirty pages, which allows memory controller
to maintain an accurate view of the amount of its dirty memory.

After Kame's commit 89c06bd5(memcg: use new logic for page stat accounting), we can
use 'struct page' flag to test page state instead of per page_cgroup flag. But memcg
has a feature to move a page from a cgroup to another one and may have race between
"move" and "page stat accounting". So in order to avoid the race we have designed a
bigger lock:

         mem_cgroup_begin_update_page_stat()
         modify page information        -->(a)
         mem_cgroup_update_page_stat()  -->(b)
         mem_cgroup_end_update_page_stat()
It requires both (a) and (b)(dirty pages accounting) to be pretected in
mem_cgroup_{begin/end}_update_page_stat().

Server places should be added accounting:
        incrementing (3):
                __set_page_dirty_buffers
                __set_page_dirty_nobuffers
		mark_buffer_dirty
        decrementing (5):
                clear_page_dirty_for_io
                cancel_dirty_page
		delete_from_page_cache
		__delete_from_page_cache
		replace_page_cache_page

The lock order between memcg lock and mapping lock is:
	--> memcg->move_lock
	  --> mapping->private_lock
            --> mapping->tree_lock

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
cc: Michal Hocko <mhocko@suse.cz>
cc: Greg Thelen <gthelen@google.com>
cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
cc: Andrew Morton <akpm@linux-foundation.org>
cc: Fengguang Wu <fengguang.wu@intel.com>
cc: Mel Gorman <mgorman@suse.de>
---
 fs/buffer.c                |    9 +++++++++
 include/linux/memcontrol.h |    1 +
 mm/filemap.c               |   14 ++++++++++++++
 mm/memcontrol.c            |   30 +++++++++++++++++++++++-------
 mm/page-writeback.c        |   24 ++++++++++++++++++++++--
 mm/truncate.c              |    6 ++++++
 6 files changed, 75 insertions(+), 9 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 695eb14..7c537f4 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -694,10 +694,13 @@ int __set_page_dirty_buffers(struct page *page)
 {
 	int newly_dirty;
 	struct address_space *mapping = page_mapping(page);
+	bool locked;
+	unsigned long flags;
 
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	spin_lock(&mapping->private_lock);
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
@@ -713,6 +716,7 @@ int __set_page_dirty_buffers(struct page *page)
 
 	if (newly_dirty)
 		__set_page_dirty(page, mapping, 1);
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	return newly_dirty;
 }
 EXPORT_SYMBOL(__set_page_dirty_buffers);
@@ -1169,11 +1173,16 @@ void mark_buffer_dirty(struct buffer_head *bh)
 
 	if (!test_set_buffer_dirty(bh)) {
 		struct page *page = bh->b_page;
+		bool locked;
+		unsigned long flags;
+
+		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 		if (!TestSetPageDirty(page)) {
 			struct address_space *mapping = page_mapping(page);
 			if (mapping)
 				__set_page_dirty(page, mapping, 0);
 		}
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	}
 }
 EXPORT_SYMBOL(mark_buffer_dirty);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d166aeb..f952be6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -42,6 +42,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
 	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
+	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 };
diff --git a/mm/filemap.c b/mm/filemap.c
index 4b51ac1..5642de6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -65,6 +65,11 @@
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
  *
+ *  ->memcg->move_lock	(mem_cgroup_begin_update_page_stat->
+ *						move_lock_mem_cgroup)
+ *    ->private_lock		(__set_page_dirty_buffers)
+ *        ->mapping->tree_lock
+ *
  *  ->i_mutex
  *    ->i_mmap_mutex		(truncate->unmap_mapping_range)
  *
@@ -144,6 +149,7 @@ void __delete_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
@@ -161,13 +167,17 @@ void delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 	void (*freepage)(struct page *);
+	bool locked;
+	unsigned long flags;
 
 	BUG_ON(!PageLocked(page));
 
 	freepage = mapping->a_ops->freepage;
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	spin_lock_irq(&mapping->tree_lock);
 	__delete_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	mem_cgroup_uncharge_cache_page(page);
 
 	if (freepage)
@@ -417,6 +427,8 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 	if (!error) {
 		struct address_space *mapping = old->mapping;
 		void (*freepage)(struct page *);
+		bool locked;
+		unsigned long flags;
 
 		pgoff_t offset = old->index;
 		freepage = mapping->a_ops->freepage;
@@ -425,6 +437,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->mapping = mapping;
 		new->index = offset;
 
+		mem_cgroup_begin_update_page_stat(old, &locked, &flags);
 		spin_lock_irq(&mapping->tree_lock);
 		__delete_from_page_cache(old);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
@@ -434,6 +447,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		if (PageSwapBacked(new))
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irq(&mapping->tree_lock);
+		mem_cgroup_end_update_page_stat(old, &locked, &flags);
 		/* mem_cgroup codes must not be called under tree_lock */
 		mem_cgroup_replace_page_cache(old, new);
 		radix_tree_preload_end();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f9acf49..1d31851 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -91,6 +91,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"rss_huge",
 	"mapped_file",
 	"swap",
+	"dirty",
 };
 
 enum mem_cgroup_events_index {
@@ -3743,6 +3744,20 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static inline
+void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
+					struct mem_cgroup *to,
+					unsigned int nr_pages,
+					enum mem_cgroup_stat_index idx)
+{
+	/* Update stat data for mem_cgroup */
+	preempt_disable();
+	WARN_ON_ONCE(from->stat->count[idx] < nr_pages);
+	__this_cpu_add(from->stat->count[idx], -nr_pages);
+	__this_cpu_add(to->stat->count[idx], nr_pages);
+	preempt_enable();
+}
+
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
@@ -3788,13 +3803,14 @@ static int mem_cgroup_move_account(struct page *page,
 
 	move_lock_mem_cgroup(from, &flags);
 
-	if (!anon && page_mapped(page)) {
-		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
-	}
+	if (!anon && page_mapped(page))
+		mem_cgroup_move_account_page_stat(from, to, nr_pages,
+			MEM_CGROUP_STAT_FILE_MAPPED);
+
+	if (!anon && PageDirty(page))
+		mem_cgroup_move_account_page_stat(from, to, nr_pages,
+			MEM_CGROUP_STAT_FILE_DIRTY);
+
 	mem_cgroup_charge_statistics(from, page, anon, -nr_pages);
 
 	/* caller should have done css_get */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4514ad7..3900e62 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1982,6 +1982,11 @@ int __set_page_dirty_no_writeback(struct page *page)
 
 /*
  * Helper function for set_page_dirty family.
+ *
+ * The caller must hold mem_cgroup_begin/end_update_page_stat() lock
+ * while modifying struct page state and accounting dirty pages.
+ * See __set_page_dirty_{nobuffers,buffers} for example.
+ *
  * NOTE: This relies on being atomic wrt interrupts.
  */
 void account_page_dirtied(struct page *page, struct address_space *mapping)
@@ -1989,6 +1994,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 	trace_writeback_dirty_page(page, mapping);
 
 	if (mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
@@ -2028,6 +2034,11 @@ EXPORT_SYMBOL(account_page_writeback);
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
+	bool locked;
+	unsigned long flags;
+
+
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 		struct address_space *mapping2;
@@ -2045,12 +2056,15 @@ int __set_page_dirty_nobuffers(struct page *page)
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
 		spin_unlock_irq(&mapping->tree_lock);
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 		}
 		return 1;
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	return 0;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
@@ -2166,6 +2180,9 @@ EXPORT_SYMBOL(set_page_dirty_lock);
 int clear_page_dirty_for_io(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
+	bool locked;
+	unsigned long flags;
+	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
 
@@ -2207,13 +2224,16 @@ int clear_page_dirty_for_io(struct page *page)
 		 * the desired exclusion. See mm/memory.c:do_wp_page()
 		 * for more comments.
 		 */
+		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
-			return 1;
+			ret = 1;
 		}
-		return 0;
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+		return ret;
 	}
 	return TestClearPageDirty(page);
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index c75b736..9c9aa03 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -73,9 +73,14 @@ static inline void truncate_partial_page(struct page *page, unsigned partial)
  */
 void cancel_dirty_page(struct page *page, unsigned int account_size)
 {
+	bool locked;
+	unsigned long flags;
+
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
@@ -83,6 +88,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 				task_io_account_cancelled_write(account_size);
 		}
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 EXPORT_SYMBOL(cancel_dirty_page);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
