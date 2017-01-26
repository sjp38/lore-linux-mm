Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE83C6B027C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so308818374pge.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:51 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u5si26287445pgi.223.2017.01.26.03.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 23/37] mm: account huge pages to dirty, writaback, reclaimable, etc.
Date: Thu, 26 Jan 2017 14:58:05 +0300
Message-Id: <20170126115819.58875-24-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
index 254698856b8f..7a341b01937f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@
 #include <linux/mmzone.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/mm.h>
 
 struct mem_cgroup;
 struct page;
@@ -517,18 +518,6 @@ static inline void mem_cgroup_update_page_stat(struct page *page,
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
@@ -739,13 +728,8 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
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
index 366466ed7fdc..20a9ce2fcc64 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -485,6 +485,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
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
index d9daa54dc316..38f1682f8dfc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1154,7 +1154,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 			goto out;
 	}
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, nr);
-	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, nr);
 out:
 	unlock_page_memcg(page);
 }
@@ -1196,7 +1196,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, -nr);
-	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, -nr);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
