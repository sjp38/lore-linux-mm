Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8983D6B0253
	for <linux-mm@kvack.org>; Sun, 24 Jul 2016 00:57:03 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so270986978pab.0
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 21:57:03 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id c203si26065156pfb.235.2016.07.23.21.57.01
        for <linux-mm@kvack.org>;
        Sat, 23 Jul 2016 21:57:02 -0700 (PDT)
From: chengang@emindsoft.com.cn
Subject: [PATCH v2] mm: page-flags: Use bool return value instead of int for all XXPageXXX functions
Date: Sun, 24 Jul 2016 12:56:24 +0800
Message-Id: <1469336184-1904-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com
Cc: gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

From: Chen Gang <gang.chen.5i5j@gmail.com>

For pure bool function's return value, bool is a little better more or
less than int.

Under source root directory, use `grep -rn Page * | grep "\<int\>"` to
find the area that need be changed.

For the related macro function definiations (e.g. TESTPAGEFLAG), they
use xxx_bit which should be pure bool functions, too. But under most of
architectures, xxx_bit are return int, which need be changed next.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 fs/buffer.c                |  2 +-
 fs/reiserfs/inode.c        |  2 +-
 include/linux/migrate.h    |  4 ++--
 include/linux/page-flags.h | 52 +++++++++++++++++++++++-----------------------
 mm/compaction.c            |  8 +++----
 mm/filemap.c               |  2 +-
 mm/hugetlb.c               |  8 +++----
 mm/swap.c                  | 10 ++++-----
 mm/vmscan.c                |  2 +-
 mm/zsmalloc.c              |  2 +-
 10 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 9c8eb9b..b38c6c4 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -953,7 +953,7 @@ init_page_buffers(struct page *page, struct block_device *bdev,
 {
 	struct buffer_head *head = page_buffers(page);
 	struct buffer_head *bh = head;
-	int uptodate = PageUptodate(page);
+	bool uptodate = PageUptodate(page);
 	sector_t end_block = blkdev_max_block(I_BDEV(bdev->bd_inode), size);
 
 	do {
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index c2c59f9..5559e62 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -2532,7 +2532,7 @@ static int reiserfs_write_full_page(struct page *page,
 	struct buffer_head *head, *bh;
 	int partial = 0;
 	int nr = 0;
-	int checked = PageChecked(page);
+	bool checked = PageChecked(page);
 	struct reiserfs_transaction_handle th;
 	struct super_block *s = inode->i_sb;
 	int bh_per_page = PAGE_SIZE / s->s_blocksize;
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..f715feea 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -72,11 +72,11 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_COMPACTION
-extern int PageMovable(struct page *page);
+extern bool  PageMovable(struct page *page);
 extern void __SetPageMovable(struct page *page, struct address_space *mapping);
 extern void __ClearPageMovable(struct page *page);
 #else
-static inline int PageMovable(struct page *page) { return 0; };
+static inline bool PageMovable(struct page *page) { return false; };
 static inline void __SetPageMovable(struct page *page,
 				struct address_space *mapping)
 {
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda..74d98b3 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -147,12 +147,12 @@ static inline struct page *compound_head(struct page *page)
 	return page;
 }
 
-static __always_inline int PageTail(struct page *page)
+static __always_inline bool PageTail(struct page *page)
 {
 	return READ_ONCE(page->compound_head) & 1;
 }
 
-static __always_inline int PageCompound(struct page *page)
+static __always_inline bool PageCompound(struct page *page)
 {
 	return test_bit(PG_head, &page->flags) || PageTail(page);
 }
@@ -187,7 +187,7 @@ static __always_inline int PageCompound(struct page *page)
  * Macros to create function definitions for page flags
  */
 #define TESTPAGEFLAG(uname, lname, policy)				\
-static __always_inline int Page##uname(struct page *page)		\
+static __always_inline bool Page##uname(struct page *page)		\
 	{ return test_bit(PG_##lname, &policy(page, 0)->flags); }
 
 #define SETPAGEFLAG(uname, lname, policy)				\
@@ -207,11 +207,11 @@ static __always_inline void __ClearPage##uname(struct page *page)	\
 	{ __clear_bit(PG_##lname, &policy(page, 1)->flags); }
 
 #define TESTSETFLAG(uname, lname, policy)				\
-static __always_inline int TestSetPage##uname(struct page *page)	\
+static __always_inline bool TestSetPage##uname(struct page *page)	\
 	{ return test_and_set_bit(PG_##lname, &policy(page, 1)->flags); }
 
 #define TESTCLEARFLAG(uname, lname, policy)				\
-static __always_inline int TestClearPage##uname(struct page *page)	\
+static __always_inline bool TestClearPage##uname(struct page *page)	\
 	{ return test_and_clear_bit(PG_##lname, &policy(page, 1)->flags); }
 
 #define PAGEFLAG(uname, lname, policy)					\
@@ -229,7 +229,7 @@ static __always_inline int TestClearPage##uname(struct page *page)	\
 	TESTCLEARFLAG(uname, lname, policy)
 
 #define TESTPAGEFLAG_FALSE(uname)					\
-static inline int Page##uname(const struct page *page) { return 0; }
+static inline bool Page##uname(const struct page *page) { return false; }
 
 #define SETPAGEFLAG_NOOP(uname)						\
 static inline void SetPage##uname(struct page *page) {  }
@@ -241,10 +241,10 @@ static inline void ClearPage##uname(struct page *page) {  }
 static inline void __ClearPage##uname(struct page *page) {  }
 
 #define TESTSETFLAG_FALSE(uname)					\
-static inline int TestSetPage##uname(struct page *page) { return 0; }
+static inline bool TestSetPage##uname(struct page *page) { return false; }
 
 #define TESTCLEARFLAG_FALSE(uname)					\
-static inline int TestClearPage##uname(struct page *page) { return 0; }
+static inline bool TestClearPage##uname(struct page *page) { return false; }
 
 #define PAGEFLAG_FALSE(uname) TESTPAGEFLAG_FALSE(uname)			\
 	SETPAGEFLAG_NOOP(uname) CLEARPAGEFLAG_NOOP(uname)
@@ -376,18 +376,18 @@ PAGEFLAG(Idle, idle, PF_ANY)
 #define PAGE_MAPPING_KSM	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
 #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
 
-static __always_inline int PageMappingFlags(struct page *page)
+static __always_inline bool PageMappingFlags(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) != 0;
 }
 
-static __always_inline int PageAnon(struct page *page)
+static __always_inline bool PageAnon(struct page *page)
 {
 	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
-static __always_inline int __PageMovable(struct page *page)
+static __always_inline bool __PageMovable(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
 				PAGE_MAPPING_MOVABLE;
@@ -400,7 +400,7 @@ static __always_inline int __PageMovable(struct page *page)
  * is found in VM_MERGEABLE vmas.  It's a PageAnon page, pointing not to any
  * anon_vma, but to that page's node of the stable tree.
  */
-static __always_inline int PageKsm(struct page *page)
+static __always_inline bool PageKsm(struct page *page)
 {
 	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
@@ -412,9 +412,9 @@ TESTPAGEFLAG_FALSE(Ksm)
 
 u64 stable_page_flags(struct page *page);
 
-static inline int PageUptodate(struct page *page)
+static inline bool PageUptodate(struct page *page)
 {
-	int ret;
+	bool ret;
 	page = compound_head(page);
 	ret = test_bit(PG_uptodate, &(page)->flags);
 	/*
@@ -493,8 +493,8 @@ static inline void ClearPageCompound(struct page *page)
 #define PG_head_mask ((1UL << PG_head))
 
 #ifdef CONFIG_HUGETLB_PAGE
-int PageHuge(struct page *page);
-int PageHeadHuge(struct page *page);
+bool PageHuge(struct page *page);
+bool PageHeadHuge(struct page *page);
 bool page_huge_active(struct page *page);
 #else
 TESTPAGEFLAG_FALSE(Huge)
@@ -516,7 +516,7 @@ static inline bool page_huge_active(struct page *page)
  * hugetlbfs pages, but not normal pages. PageTransHuge() can only be
  * called only in the core VM paths where hugetlbfs pages can't exist.
  */
-static inline int PageTransHuge(struct page *page)
+static inline bool PageTransHuge(struct page *page)
 {
 	VM_BUG_ON_PAGE(PageTail(page), page);
 	return PageHead(page);
@@ -527,7 +527,7 @@ static inline int PageTransHuge(struct page *page)
  * and hugetlbfs pages, so it should only be called when it's known
  * that hugetlbfs pages aren't involved.
  */
-static inline int PageTransCompound(struct page *page)
+static inline bool PageTransCompound(struct page *page)
 {
 	return PageCompound(page);
 }
@@ -548,7 +548,7 @@ static inline int PageTransCompound(struct page *page)
  * MMU notifier, otherwise it may result in page->_mapcount < 0 false
  * positives.
  */
-static inline int PageTransCompoundMap(struct page *page)
+static inline bool PageTransCompoundMap(struct page *page)
 {
 	return PageTransCompound(page) && atomic_read(&page->_mapcount) < 0;
 }
@@ -558,7 +558,7 @@ static inline int PageTransCompoundMap(struct page *page)
  * and hugetlbfs pages, so it should only be called when it's known
  * that hugetlbfs pages aren't involved.
  */
-static inline int PageTransTail(struct page *page)
+static inline bool PageTransTail(struct page *page)
 {
 	return PageTail(page);
 }
@@ -576,7 +576,7 @@ static inline int PageTransTail(struct page *page)
  *
  * See also __split_huge_pmd_locked() and page_remove_anon_compound_rmap().
  */
-static inline int PageDoubleMap(struct page *page)
+static inline bool PageDoubleMap(struct page *page)
 {
 	return PageHead(page) && test_bit(PG_double_map, &page[1].flags);
 }
@@ -592,13 +592,13 @@ static inline void ClearPageDoubleMap(struct page *page)
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	clear_bit(PG_double_map, &page[1].flags);
 }
-static inline int TestSetPageDoubleMap(struct page *page)
+static inline bool TestSetPageDoubleMap(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	return test_and_set_bit(PG_double_map, &page[1].flags);
 }
 
-static inline int TestClearPageDoubleMap(struct page *page)
+static inline bool TestClearPageDoubleMap(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	return test_and_clear_bit(PG_double_map, &page[1].flags);
@@ -622,7 +622,7 @@ PAGEFLAG_FALSE(DoubleMap)
  * for a special page.
  */
 #define PAGE_MAPCOUNT_OPS(uname, lname)					\
-static __always_inline int Page##uname(struct page *page)		\
+static __always_inline bool Page##uname(struct page *page)		\
 {									\
 	return atomic_read(&page->_mapcount) ==				\
 				PAGE_##lname##_MAPCOUNT_VALUE;		\
@@ -667,7 +667,7 @@ __PAGEFLAG(Isolated, isolated, PF_ANY);
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
  */
-static inline int PageSlabPfmemalloc(struct page *page)
+static inline bool PageSlabPfmemalloc(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageSlab(page), page);
 	return PageActive(page);
@@ -728,7 +728,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
  * Determine if a page has private stuff, indicating that release routines
  * should be invoked upon it.
  */
-static inline int page_has_private(struct page *page)
+static inline bool page_has_private(struct page *page)
 {
 	return !!(page->flags & PAGE_FLAGS_PRIVATE);
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index 9affb29..f04be22 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -95,19 +95,19 @@ static inline bool migrate_async_suitable(int migratetype)
 
 #ifdef CONFIG_COMPACTION
 
-int PageMovable(struct page *page)
+bool PageMovable(struct page *page)
 {
 	struct address_space *mapping;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	if (!__PageMovable(page))
-		return 0;
+		return false;
 
 	mapping = page_mapping(page);
 	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 EXPORT_SYMBOL(PageMovable);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 3083ded..6ce20c2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -645,7 +645,7 @@ static int __add_to_page_cache_locked(struct page *page,
 				      pgoff_t offset, gfp_t gfp_mask,
 				      void **shadowp)
 {
-	int huge = PageHuge(page);
+	bool huge = PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3b6dc79..ea4aa7e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1321,10 +1321,10 @@ static void prep_compound_gigantic_page(struct page *page, unsigned int order)
  * transparent huge pages.  See the PageTransHuge() documentation for more
  * details.
  */
-int PageHuge(struct page *page)
+bool PageHuge(struct page *page)
 {
 	if (!PageCompound(page))
-		return 0;
+		return false;
 
 	page = compound_head(page);
 	return page[1].compound_dtor == HUGETLB_PAGE_DTOR;
@@ -1335,10 +1335,10 @@ EXPORT_SYMBOL_GPL(PageHuge);
  * PageHeadHuge() only returns true for hugetlbfs head page, but not for
  * normal or transparent huge pages.
  */
-int PageHeadHuge(struct page *page_head)
+bool PageHeadHuge(struct page *page_head)
 {
 	if (!PageHead(page_head))
-		return 0;
+		return false;
 
 	return get_compound_page_dtor(page_head) == free_huge_page;
 }
diff --git a/mm/swap.c b/mm/swap.c
index 75c63bb..410e634 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -249,7 +249,7 @@ void rotate_reclaimable_page(struct page *page)
 }
 
 static void update_page_reclaim_stat(struct lruvec *lruvec,
-				     int file, int rotated)
+				     int file, bool rotated)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
@@ -272,7 +272,7 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 		trace_mm_lru_activate(page);
 
 		__count_vm_event(PGACTIVATE);
-		update_page_reclaim_stat(lruvec, file, 1);
+		update_page_reclaim_stat(lruvec, file, true);
 	}
 }
 
@@ -555,7 +555,7 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
-	update_page_reclaim_stat(lruvec, file, 0);
+	update_page_reclaim_stat(lruvec, file, false);
 }
 
 
@@ -572,7 +572,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 		add_page_to_lru_list(page, lruvec, lru);
 
 		__count_vm_event(PGDEACTIVATE);
-		update_page_reclaim_stat(lruvec, file, 0);
+		update_page_reclaim_stat(lruvec, file, false);
 	}
 }
 
@@ -860,7 +860,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 				 void *arg)
 {
 	int file = page_is_file_cache(page);
-	int active = PageActive(page);
+	bool active = PageActive(page);
 	enum lru_list lru = page_lru(page);
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5af357..46309e7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -743,7 +743,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 void putback_lru_page(struct page *page)
 {
 	bool is_unevictable;
-	int was_unevictable = PageUnevictable(page);
+	bool was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 5e5237c..7483254 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -219,7 +219,7 @@ static void ClearPageHugeObject(struct page *page)
 	ClearPageOwnerPriv1(page);
 }
 
-static int PageHugeObject(struct page *page)
+static bool PageHugeObject(struct page *page)
 {
 	return PageOwnerPriv1(page);
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
