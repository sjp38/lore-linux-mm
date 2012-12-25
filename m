Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 255AD6B006C
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 12:26:27 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id bi5so4525723pad.13
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 09:26:26 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
Date: Wed, 26 Dec 2012 01:26:07 +0800
Message-Id: <1356456367-14660-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: mhocko@suse.cz, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

This patch adds memcg routines to count dirty pages, which allows memory controller
to maintain an accurate view of the amount of its dirty memory and can provide some
info for users while cgroup's direct reclaim is working.

After Kame's commit 89c06bd5(memcg: use new logic for page stat accounting), we can
use 'struct page' flag to test page state instead of per page_cgroup flag. But memcg
has a feature to move a page from a cgroup to another one and may have race between
"move" and "page stat accounting". So in order to avoid the race we have designed a
bigger lock:

         mem_cgroup_begin_update_page_stat()
         modify page information        -->(a)
         mem_cgroup_update_page_stat()  -->(b)
         mem_cgroup_end_update_page_stat()
It requires (a) and (b)(dirty pages accounting) can stay close enough.
In the previous two prepare patches, we have reworked the vfs set page dirty routines
and now the interfaces are more explicit:
        incrementing (2):
                __set_page_dirty
                __set_page_dirty_nobuffers
        decrementing (2):
                clear_page_dirty_for_io
                cancel_dirty_page

To prevent AB/BA deadlock mentioned by Greg Thelen in previous version
(https://lkml.org/lkml/2012/7/30/227), we adjust the lock order:
->private_lock --> mapping->tree_lock --> memcg->move_lock.
So we need to make mapping->tree_lock ahead of TestSetPageDirty in __set_page_dirty()
and __set_page_dirty_nobuffers(). But in order to avoiding useless spinlock contention,
a prepare PageDirty() checking is added.


Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
Acked-by: Fengguang Wu <fengguang.wu@intel.com>
---
 fs/buffer.c                |   14 +++++++++++++-
 include/linux/memcontrol.h |    1 +
 mm/filemap.c               |   10 ++++++++++
 mm/memcontrol.c            |   29 ++++++++++++++++++++++-------
 mm/page-writeback.c        |   39 ++++++++++++++++++++++++++++++++-------
 mm/truncate.c              |    6 ++++++
 6 files changed, 84 insertions(+), 15 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 762168a..53402d2 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -612,19 +612,31 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
 int __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
+	bool locked;
+	unsigned long flags;
+
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
 
-	if (TestSetPageDirty(page))
+	if (PageDirty(page))
 		return 0;
 
 	spin_lock_irq(&mapping->tree_lock);
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+
+	if (TestSetPageDirty(page)) {
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+		spin_unlock_irq(&mapping->tree_lock);
+		return 0;
+	}
+
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	spin_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5421b8a..2685d8a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -44,6 +44,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 83efee7..b589be5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -62,6 +62,11 @@
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
  *
+ *    ->private_lock		(__set_page_dirty_buffers)
+ *      ->mapping->tree_lock
+ *        ->memcg->move_lock	(mem_cgroup_begin_update_page_stat->
+ *							move_lock_mem_cgroup)
+ *
  *  ->i_mutex
  *    ->i_mmap_mutex		(truncate->unmap_mapping_range)
  *
@@ -112,6 +117,8 @@
 void __delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	bool locked;
+	unsigned long flags;
 
 	/*
 	 * if we're uptodate, flush out into the cleancache, otherwise
@@ -139,10 +146,13 @@ void __delete_from_page_cache(struct page *page)
 	 * Fix it up by doing a final dirty accounting check after
 	 * having removed the page entirely.
 	 */
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /**
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d450c04..c884640 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -95,6 +95,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"rss",
 	"mapped_file",
 	"swap",
+	"dirty",
 };
 
 enum mem_cgroup_events_index {
@@ -3609,6 +3610,19 @@ void mem_cgroup_split_huge_fixup(struct page *head)
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
+	__this_cpu_add(from->stat->count[idx], -nr_pages);
+	__this_cpu_add(to->stat->count[idx], nr_pages);
+	preempt_enable();
+}
+
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
@@ -3654,13 +3668,14 @@ static int mem_cgroup_move_account(struct page *page,
 
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
+	if (PageDirty(page))
+		mem_cgroup_move_account_page_stat(from, to, nr_pages,
+			MEM_CGROUP_STAT_FILE_DIRTY);
+
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
 
 	/* caller should have done css_get */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0713bfb..526ddd7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1978,11 +1978,17 @@ int __set_page_dirty_no_writeback(struct page *page)
 
 /*
  * Helper function for set_page_dirty family.
+ *
+ * The caller must hold mem_cgroup_begin/end_update_page_stat() lock
+ * while modifying struct page state and accounting dirty pages.
+ * See __set_page_dirty for example.
+ *
  * NOTE: This relies on being atomic wrt interrupts.
  */
 void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
@@ -2022,14 +2028,22 @@ EXPORT_SYMBOL(account_page_writeback);
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
+	bool locked;
+	unsigned long flags;
+	struct address_space *mapping = page_mapping(page);
+
+	if (PageDirty(page))
+		return 0;
+
+	if (unlikely(!mapping))
+		return !TestSetPageDirty(page);
+
+	spin_lock_irq(&mapping->tree_lock);
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+
 	if (!TestSetPageDirty(page)) {
-		struct address_space *mapping = page_mapping(page);
 		struct address_space *mapping2;
 
-		if (!mapping)
-			return 1;
-
-		spin_lock_irq(&mapping->tree_lock);
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
@@ -2038,13 +2052,18 @@ int __set_page_dirty_nobuffers(struct page *page)
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 		spin_unlock_irq(&mapping->tree_lock);
+
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 		}
 		return 1;
 	}
+
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
+	spin_unlock_irq(&mapping->tree_lock);
 	return 0;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
@@ -2160,6 +2179,9 @@ EXPORT_SYMBOL(set_page_dirty_lock);
 int clear_page_dirty_for_io(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
+	bool locked;
+	unsigned long flags;
+	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
 
@@ -2201,13 +2223,16 @@ int clear_page_dirty_for_io(struct page *page)
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
index db1b216..c81e6c4 100644
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
