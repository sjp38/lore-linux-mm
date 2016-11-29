Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 676946B0287
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:24:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so424925771pgd.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:24:12 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 1si30866238plp.216.2016.11.29.03.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:24:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 23/36] mm: account huge pages to dirty, writaback, reclaimable, etc.
Date: Tue, 29 Nov 2016 14:22:51 +0300
Message-Id: <20161129112304.90056-24-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to account huge pages according to its size to get background
writaback work properly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/fs-writeback.c           | 10 +++---
 include/linux/backing-dev.h | 10 ++++++
 include/linux/memcontrol.h  | 22 ++-----------
 mm/migrate.c                |  1 +
 mm/page-writeback.c         | 80 +++++++++++++++++++++++++++++----------------
 mm/rmap.c                   |  4 +--
 6 files changed, 74 insertions(+), 53 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index ef600591d96f..e1c9faddc9e1 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -366,8 +366,9 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 		struct page *page = radix_tree_deref_slot_protected(slot,
 							&mapping->tree_lock);
 		if (likely(page) && PageDirty(page)) {
-			__dec_wb_stat(old_wb, WB_RECLAIMABLE);
-			__inc_wb_stat(new_wb, WB_RECLAIMABLE);
+			int nr = hpage_nr_pages(page);
+			__add_wb_stat(old_wb, WB_RECLAIMABLE, -nr);
+			__add_wb_stat(new_wb, WB_RECLAIMABLE, nr);
 		}
 	}
 
@@ -376,9 +377,10 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 		struct page *page = radix_tree_deref_slot_protected(slot,
 							&mapping->tree_lock);
 		if (likely(page)) {
+			int nr = hpage_nr_pages(page);
 			WARN_ON_ONCE(!PageWriteback(page));
-			__dec_wb_stat(old_wb, WB_WRITEBACK);
-			__inc_wb_stat(new_wb, WB_WRITEBACK);
+			__add_wb_stat(old_wb, WB_WRITEBACK, -nr);
+			__add_wb_stat(new_wb, WB_WRITEBACK, nr);
 		}
 	}
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 43b93a947e61..e63487f78824 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -61,6 +61,16 @@ static inline void __add_wb_stat(struct bdi_writeback *wb,
 	__percpu_counter_add(&wb->stat[item], amount, WB_STAT_BATCH);
 }
 
+static inline void add_wb_stat(struct bdi_writeback *wb,
+				 enum wb_stat_item item, s64 amount)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__add_wb_stat(wb, item, amount);
+	local_irq_restore(flags);
+}
+
 static inline void __inc_wb_stat(struct bdi_writeback *wb,
 				 enum wb_stat_item item)
 {
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 61d20c17f3b7..df014eff82da 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@
 #include <linux/mmzone.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/mm.h>
 
 struct mem_cgroup;
 struct page;
@@ -503,18 +504,6 @@ static inline void mem_cgroup_update_page_stat(struct page *page,
 		this_cpu_add(page->mem_cgroup->stat->count[idx], val);
 }
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
-{
-	mem_cgroup_update_page_stat(page, idx, 1);
-}
-
-static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
-{
-	mem_cgroup_update_page_stat(page, idx, -1);
-}
-
 unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
@@ -719,13 +708,8 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
-{
-}
-
-static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
+static inline void mem_cgroup_update_page_stat(struct page *page,
+				 enum mem_cgroup_stat_index idx, int val)
 {
 }
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 0ed24b1fa77b..c274f9d8ac2b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -505,6 +505,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * are mapped to swap space.
 	 */
 	if (newzone != oldzone) {
+		BUG_ON(PageTransHuge(page));
 		__dec_node_state(oldzone->zone_pgdat, NR_FILE_PAGES);
 		__inc_node_state(newzone->zone_pgdat, NR_FILE_PAGES);
 		if (PageSwapBacked(page) && !PageSwapCache(page)) {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 47d5b12c460e..d7b905d66add 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2430,19 +2430,22 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 
 	if (mapping_cap_account_dirty(mapping)) {
 		struct bdi_writeback *wb;
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
 
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
-		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		__inc_node_page_state(page, NR_FILE_DIRTY);
-		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		__inc_node_page_state(page, NR_DIRTIED);
-		__inc_wb_stat(wb, WB_RECLAIMABLE);
-		__inc_wb_stat(wb, WB_DIRTIED);
-		task_io_account_write(PAGE_SIZE);
-		current->nr_dirtied++;
-		this_cpu_inc(bdp_ratelimits);
+		mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_DIRTY, nr);
+		__mod_node_page_state(pgdat, NR_FILE_DIRTY, nr);
+		__mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, nr);
+		__mod_node_page_state(pgdat, NR_DIRTIED, nr);
+		__add_wb_stat(wb, WB_RECLAIMABLE, nr);
+		__add_wb_stat(wb, WB_DIRTIED, nr);
+		task_io_account_write(nr * PAGE_SIZE);
+		current->nr_dirtied += nr;
+		this_cpu_add(bdp_ratelimits, nr);
 	}
 }
 EXPORT_SYMBOL(account_page_dirtied);
@@ -2456,11 +2459,15 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb)
 {
 	if (mapping_cap_account_dirty(mapping)) {
-		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		dec_node_page_state(page, NR_FILE_DIRTY);
-		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		dec_wb_stat(wb, WB_RECLAIMABLE);
-		task_io_account_cancelled_write(PAGE_SIZE);
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
+
+		mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_DIRTY, -nr);
+		mod_node_page_state(pgdat, NR_FILE_DIRTY, -nr);
+		mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, -nr);
+		add_wb_stat(wb, WB_RECLAIMABLE, -nr);
+		task_io_account_cancelled_write(PAGE_SIZE * nr);
 	}
 }
 
@@ -2520,14 +2527,16 @@ void account_page_redirty(struct page *page)
 	struct address_space *mapping = page->mapping;
 
 	if (mapping && mapping_cap_account_dirty(mapping)) {
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
 		bool locked;
 
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
-		current->nr_dirtied--;
-		dec_node_page_state(page, NR_DIRTIED);
-		dec_wb_stat(wb, WB_DIRTIED);
+		current->nr_dirtied -= nr;
+		mod_node_page_state(pgdat, NR_DIRTIED, -nr);
+		add_wb_stat(wb, WB_DIRTIED, -nr);
 		unlocked_inode_to_wb_end(inode, locked);
 	}
 }
@@ -2713,10 +2722,15 @@ int clear_page_dirty_for_io(struct page *page)
 		 */
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
-			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-			dec_node_page_state(page, NR_FILE_DIRTY);
-			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-			dec_wb_stat(wb, WB_RECLAIMABLE);
+			struct zone *zone = page_zone(page);
+			pg_data_t *pgdat = page_pgdat(page);
+			int nr = hpage_nr_pages(page);
+
+			mem_cgroup_update_page_stat(page,
+					MEM_CGROUP_STAT_DIRTY, -nr);
+			mod_node_page_state(pgdat, NR_FILE_DIRTY, -nr);
+			mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, -nr);
+			add_wb_stat(wb, WB_RECLAIMABLE, -nr);
 			ret = 1;
 		}
 		unlocked_inode_to_wb_end(inode, locked);
@@ -2760,10 +2774,15 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
-		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		dec_node_page_state(page, NR_WRITEBACK);
-		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		inc_node_page_state(page, NR_WRITTEN);
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
+
+		mem_cgroup_update_page_stat(page,
+				MEM_CGROUP_STAT_WRITEBACK, -nr);
+		mod_node_page_state(pgdat, NR_WRITEBACK, -nr);
+		mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, -nr);
+		mod_node_page_state(pgdat, NR_WRITTEN, nr);
 	}
 	unlock_page_memcg(page);
 	return ret;
@@ -2815,9 +2834,14 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		ret = TestSetPageWriteback(page);
 	}
 	if (!ret) {
-		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		inc_node_page_state(page, NR_WRITEBACK);
-		inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
+
+		mem_cgroup_update_page_stat(page,
+				MEM_CGROUP_STAT_WRITEBACK, nr);
+		mod_node_page_state(pgdat, NR_WRITEBACK, nr);
+		mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, nr);
 	}
 	unlock_page_memcg(page);
 	return ret;
diff --git a/mm/rmap.c b/mm/rmap.c
index 48c7310639bd..b9570e784405 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1297,7 +1297,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 			goto out;
 	}
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, nr);
-	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, nr);
 out:
 	unlock_page_memcg(page);
 }
@@ -1339,7 +1339,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, -nr);
-	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, -nr);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
