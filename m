Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB77C6B0278
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so131295875pfk.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:24 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q199si17975234pgq.205.2016.10.24.17.14.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 30/43] mm: account huge pages to dirty, writaback, reclaimable, etc.
Date: Tue, 25 Oct 2016 03:13:29 +0300
Message-Id: <20161025001342.76126-31-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to account huge pages according to its size to get background
writaback work properly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/fs-writeback.c           | 10 ++++---
 include/linux/backing-dev.h | 10 +++++++
 include/linux/memcontrol.h  |  5 ++--
 mm/migrate.c                |  1 +
 mm/page-writeback.c         | 67 +++++++++++++++++++++++++++++----------------
 5 files changed, 64 insertions(+), 29 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 05713a5da083..2feb8677e69e 100644
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
index 61d20c17f3b7..d24092581442 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@
 #include <linux/mmzone.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/mm.h>
 
 struct mem_cgroup;
 struct page;
@@ -506,13 +507,13 @@ static inline void mem_cgroup_update_page_stat(struct page *page,
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
-	mem_cgroup_update_page_stat(page, idx, 1);
+	mem_cgroup_update_page_stat(page, idx, hpage_nr_pages(page));
 }
 
 static inline void mem_cgroup_dec_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
-	mem_cgroup_update_page_stat(page, idx, -1);
+	mem_cgroup_update_page_stat(page, idx, -hpage_nr_pages(page));
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
diff --git a/mm/migrate.c b/mm/migrate.c
index 99250aee1ac1..bfc722959d3e 100644
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
index c76fc90b7039..f903c09940c4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2421,19 +2421,22 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 
 	if (mapping_cap_account_dirty(mapping)) {
 		struct bdi_writeback *wb;
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
 
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		__inc_node_page_state(page, NR_FILE_DIRTY);
-		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		__inc_node_page_state(page, NR_DIRTIED);
-		__inc_wb_stat(wb, WB_RECLAIMABLE);
-		__inc_wb_stat(wb, WB_DIRTIED);
-		task_io_account_write(PAGE_SIZE);
-		current->nr_dirtied++;
-		this_cpu_inc(bdp_ratelimits);
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
@@ -2447,11 +2450,15 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
+
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		dec_node_page_state(page, NR_FILE_DIRTY);
-		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		dec_wb_stat(wb, WB_RECLAIMABLE);
-		task_io_account_cancelled_write(PAGE_SIZE);
+		mod_node_page_state(pgdat, NR_FILE_DIRTY, -nr);
+		mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, -nr);
+		add_wb_stat(wb, WB_RECLAIMABLE, -nr);
+		task_io_account_cancelled_write(PAGE_SIZE * nr);
 	}
 }
 
@@ -2511,14 +2518,16 @@ void account_page_redirty(struct page *page)
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
@@ -2704,10 +2713,14 @@ int clear_page_dirty_for_io(struct page *page)
 		 */
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
+			struct zone *zone = page_zone(page);
+			pg_data_t *pgdat = page_pgdat(page);
+			int nr = hpage_nr_pages(page);
+
 			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-			dec_node_page_state(page, NR_FILE_DIRTY);
-			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-			dec_wb_stat(wb, WB_RECLAIMABLE);
+			mod_node_page_state(pgdat, NR_FILE_DIRTY, -nr);
+			mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, -nr);
+			add_wb_stat(wb, WB_RECLAIMABLE, -nr);
 			ret = 1;
 		}
 		unlocked_inode_to_wb_end(inode, locked);
@@ -2751,10 +2764,14 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
+
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		dec_node_page_state(page, NR_WRITEBACK);
-		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		inc_node_page_state(page, NR_WRITTEN);
+		mod_node_page_state(pgdat, NR_WRITEBACK, -nr);
+		mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, -nr);
+		mod_node_page_state(pgdat, NR_WRITTEN, nr);
 	}
 	unlock_page_memcg(page);
 	return ret;
@@ -2806,9 +2823,13 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		ret = TestSetPageWriteback(page);
 	}
 	if (!ret) {
+		struct zone *zone = page_zone(page);
+		pg_data_t *pgdat = page_pgdat(page);
+		int nr = hpage_nr_pages(page);
+
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		inc_node_page_state(page, NR_WRITEBACK);
-		inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
+		mod_node_page_state(pgdat, NR_WRITEBACK, nr);
+		mod_zone_page_state(zone, NR_ZONE_WRITE_PENDING, nr);
 	}
 	unlock_page_memcg(page);
 	return ret;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
