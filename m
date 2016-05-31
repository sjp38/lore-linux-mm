Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9A7F6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 05:12:59 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id j12so65370596lbo.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:12:59 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id o81si18925863lfg.217.2016.05.31.02.12.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 02:12:58 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] reusing of mapping page supplies a way for file page allocation under low memory due to pagecache over size and is controlled by sysctl parameters. it is used only for rw page allocation rather than fault or readahead allocation. it is like relclaim but is lighter than reclaim. it only reuses clean and zero mapcount pages of mapping. for special filesystems using this feature like below:
Date: Tue, 31 May 2016 17:08:22 +0800
Message-ID: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, zhouxianrong@huawei.com, zhouxiyu@huawei.com, wanghaijun5@huawei.com, yuchao0@huawei.com

From: z00281421 <z00281421@notesmail.huawei.com>

const struct address_space_operations special_aops = {
    ...
	.reuse_mapping_page = generic_reuse_mapping_page,
}

Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
---
 fs/buffer.c                   |    2 +
 include/linux/fs.h            |    7 ++++
 include/linux/pagemap.h       |   36 ++++++++++++++++
 include/linux/radix-tree.h    |    2 +-
 include/linux/vm_event_item.h |    2 +-
 kernel/sysctl.c               |    9 ++++
 mm/filemap.c                  |   93 +++++++++++++++++++++++++++++++++++++++--
 mm/page-writeback.c           |    6 +++
 mm/vmstat.c                   |    1 +
 9 files changed, 153 insertions(+), 5 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 754813a..a212720 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -634,6 +634,8 @@ static void __set_page_dirty(struct page *page, struct address_space *mapping,
 		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
+		radix_tree_tag_clear(&mapping->page_tree,
+				page_index(page), PAGECACHE_TAG_REUSE);
 	}
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd28814..a2e33e0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -68,6 +68,7 @@ extern struct inodes_stat_t inodes_stat;
 extern int leases_enable, lease_break_time;
 extern int sysctl_protected_symlinks;
 extern int sysctl_protected_hardlinks;
+extern unsigned long sysctl_cache_reuse_ratio;
 
 struct buffer_head;
 typedef int (get_block_t)(struct inode *inode, sector_t iblock,
@@ -412,6 +413,9 @@ struct address_space_operations {
 	int (*swap_activate)(struct swap_info_struct *sis, struct file *file,
 				sector_t *span);
 	void (*swap_deactivate)(struct file *file);
+
+	/* reuse mapping page support */
+	struct page *(*reuse_mapping_page)(struct address_space *, gfp_t);
 };
 
 extern const struct address_space_operations empty_aops;
@@ -497,6 +501,7 @@ struct block_device {
 #define PAGECACHE_TAG_DIRTY	0
 #define PAGECACHE_TAG_WRITEBACK	1
 #define PAGECACHE_TAG_TOWRITE	2
+#define PAGECACHE_TAG_REUSE	3
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
@@ -2762,6 +2767,8 @@ extern ssize_t __generic_file_write_iter(struct kiocb *, struct iov_iter *);
 extern ssize_t generic_file_write_iter(struct kiocb *, struct iov_iter *);
 extern ssize_t generic_file_direct_write(struct kiocb *, struct iov_iter *);
 extern ssize_t generic_perform_write(struct file *, struct iov_iter *, loff_t);
+extern struct page *generic_reuse_mapping_page(struct address_space *mapping,
+		gfp_t gfp_mask);
 
 ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos);
 ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9735410..c454dbb 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -76,6 +76,16 @@ static inline gfp_t mapping_gfp_constraint(struct address_space *mapping,
 	return mapping_gfp_mask(mapping) & gfp_mask;
 }
 
+static inline struct page *mapping_reuse_page(struct address_space *mapping,
+				gfp_t gfp_mask)
+{
+	if (unlikely(mapping_unevictable(mapping)))
+		return NULL;
+	if (mapping->a_ops->reuse_mapping_page)
+		return mapping->a_ops->reuse_mapping_page(mapping, gfp_mask);
+	return NULL;
+}
+
 /*
  * This is non-atomic.  Only to be used before the mapping is activated.
  * Probably needs a barrier...
@@ -201,11 +211,21 @@ static inline struct page *__page_cache_alloc(gfp_t gfp)
 
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
+	struct page *page;
+
+	page = mapping_reuse_page(x, mapping_gfp_mask(x));
+	if (page)
+		return page;
 	return __page_cache_alloc(mapping_gfp_mask(x));
 }
 
 static inline struct page *page_cache_alloc_cold(struct address_space *x)
 {
+	struct page *page;
+
+	page = mapping_reuse_page(x, mapping_gfp_mask(x)|__GFP_COLD);
+	if (page)
+		return page;
 	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
 }
 
@@ -215,6 +235,22 @@ static inline struct page *page_cache_alloc_readahead(struct address_space *x)
 				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
 }
 
+static inline struct page *page_cache_alloc_fault(struct address_space *x)
+{
+	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
+}
+
+static inline struct page *page_cache_alloc_reuse(struct address_space *x,
+			     gfp_t gfp)
+{
+	struct page *page;
+
+	page = mapping_reuse_page(x, gfp);
+	if (page)
+		return page;
+	return __page_cache_alloc(gfp);
+}
+
 typedef int filler_t(void *, struct page *);
 
 pgoff_t page_cache_next_hole(struct address_space *mapping,
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index cb4b7e8..2e5aa47 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -64,7 +64,7 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 
 /*** radix-tree API starts here ***/
 
-#define RADIX_TREE_MAX_TAGS 3
+#define RADIX_TREE_MAX_TAGS 4
 
 #ifndef RADIX_TREE_MAP_SHIFT
 #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index ec08432..a34b456 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -37,7 +37,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
-		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		PAGEOUTRUN, ALLOCSTALL, PGROTATED, PGREUSED,
 		DROP_PAGECACHE, DROP_SLAB,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 87b2fc3..35e3c7d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1334,6 +1334,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.procname	= "cache_reuse_ratio",
+		.data		= &sysctl_cache_reuse_ratio,
+		.maxlen		= sizeof(sysctl_cache_reuse_ratio),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #ifdef CONFIG_HUGETLB_PAGE
 	{
 		.procname	= "nr_hugepages",
diff --git a/mm/filemap.c b/mm/filemap.c
index 00ae878..f0fed97 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -47,6 +47,8 @@
 
 #include <asm/mman.h>
 
+unsigned long sysctl_cache_reuse_ratio = 100;
+
 /*
  * Shared mappings implemented 30.11.1994. It's not fully working yet,
  * though.
@@ -110,6 +112,18 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
+static unsigned long page_cache_over_reuse_limit(void)
+{
+	unsigned long lru_file, limit;
+
+	limit = totalram_pages * sysctl_cache_reuse_ratio / 100;
+	lru_file = global_page_state(NR_ACTIVE_FILE)
+		+ global_page_state(NR_INACTIVE_FILE);
+	if (lru_file > limit)
+		return lru_file - limit;
+	return 0;
+}
+
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
@@ -1194,7 +1208,7 @@ no_page:
 		if (fgp_flags & FGP_NOFS)
 			gfp_mask &= ~__GFP_FS;
 
-		page = __page_cache_alloc(gfp_mask);
+		page = page_cache_alloc_reuse(mapping, gfp_mask);
 		if (!page)
 			return NULL;
 
@@ -1784,6 +1798,13 @@ readpage:
 			unlock_page(page);
 		}
 
+		if (!page_mapcount(page)) {
+			spin_lock_irq(&mapping->tree_lock);
+			radix_tree_tag_set(&mapping->page_tree,
+					index, PAGECACHE_TAG_REUSE);
+			spin_unlock_irq(&mapping->tree_lock);
+		}
+
 		goto page_ok;
 
 readpage_error:
@@ -1899,7 +1920,7 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 	int ret;
 
 	do {
-		page = __page_cache_alloc(gfp_mask|__GFP_COLD);
+		page = page_cache_alloc_fault(mapping, gfp_mask|__GFP_COLD);
 		if (!page)
 			return -ENOMEM;
 
@@ -2270,6 +2291,72 @@ int generic_file_readonly_mmap(struct file * file, struct vm_area_struct * vma)
 EXPORT_SYMBOL(generic_file_mmap);
 EXPORT_SYMBOL(generic_file_readonly_mmap);
 
+struct page *generic_reuse_mapping_page(struct address_space *mapping,
+				gfp_t gfp_mask)
+{
+	int i;
+	pgoff_t index = 0;
+	struct page *p = NULL;
+	struct pagevec pvec;
+
+	if (!page_cache_over_reuse_limit())
+		return NULL;
+	if (unlikely(!mapping->nrpages))
+		return NULL;
+	if (!mapping_tagged(mapping, PAGECACHE_TAG_REUSE))
+		return NULL;
+	lru_add_drain();
+	pagevec_init(&pvec, 0);
+	while (!p && pagevec_lookup_tag(&pvec, mapping, &index,
+		PAGECACHE_TAG_REUSE, PAGEVEC_SIZE)) {
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+
+			if (PageActive(page))
+				continue;
+			if (PageDirty(page))
+				continue;
+			if (page_mapcount(page))
+				continue;
+			if (!trylock_page(page))
+				continue;
+			if (unlikely(page_mapping(page) != mapping)) {
+				unlock_page(page);
+				continue;
+			}
+			if (invalidate_inode_page(page)) {
+				if (likely(!isolate_lru_page(page))) {
+					get_page(page);
+					ClearPageUptodate(page);
+					WARN_ON(TestClearPageDirty(page));
+					WARN_ON(TestClearPageWriteback(page));
+					WARN_ON(TestClearPageActive(page));
+					WARN_ON(TestClearPageUnevictable(page));
+					ClearPageError(page);
+					ClearPageReferenced(page);
+					ClearPageReclaim(page);
+					ClearPageMappedToDisk(page);
+					ClearPageReadahead(page);
+					unlock_page(page);
+					count_vm_event(PGREUSED);
+					p = page;
+					break;
+				}
+			} else {
+				spin_lock_irq(&mapping->tree_lock);
+				radix_tree_tag_clear(&mapping->page_tree,
+					page->index, PAGECACHE_TAG_REUSE);
+				spin_unlock_irq(&mapping->tree_lock);
+			}
+			unlock_page(page);
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+	}
+	return p;
+}
+EXPORT_SYMBOL(generic_reuse_mapping_page);
+
 static struct page *wait_on_page_read(struct page *page)
 {
 	if (!IS_ERR(page)) {
@@ -2293,7 +2380,7 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
-		page = __page_cache_alloc(gfp | __GFP_COLD);
+		page = page_cache_alloc_reuse(mapping, gfp | __GFP_COLD);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b9956fd..0709df3 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2490,6 +2490,8 @@ int __set_page_dirty_nobuffers(struct page *page)
 		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree, page_index(page),
 				   PAGECACHE_TAG_DIRTY);
+		radix_tree_tag_clear(&mapping->page_tree, page_index(page),
+				   PAGECACHE_TAG_REUSE);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		unlock_page_memcg(page);
 
@@ -2737,6 +2739,10 @@ int test_clear_page_writeback(struct page *page)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
+			if (!PageSwapBacked(page) && !page_mapcount(page))
+				radix_tree_tag_set(&mapping->page_tree,
+							page_index(page),
+							PAGECACHE_TAG_REUSE);
 			if (bdi_cap_account_writeback(bdi)) {
 				struct bdi_writeback *wb = inode_to_wb(inode);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 77e42ef..273cd1d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -773,6 +773,7 @@ const char * const vmstat_text[] = {
 	"allocstall",
 
 	"pgrotated",
+	"pgreused",
 
 	"drop_pagecache",
 	"drop_slab",
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
