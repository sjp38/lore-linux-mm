Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 68CEE6B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 05:55:47 -0500 (EST)
Date: Thu, 24 Jan 2013 10:55:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Rename page struct field helpers
Message-ID: <20130124105544.GO13304@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
 <1358874762-19717-6-git-send-email-mgorman@suse.de>
 <20130122144659.d512e05c.akpm@linux-foundation.org>
 <20130123142507.GI13304@suse.de>
 <20130123135612.4b383fa7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130123135612.4b383fa7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The function names page_xchg_last_nid(), page_last_nid() and
reset_page_last_nid() were judged to be inconsistent so rename them
to a struct_field_op style pattern. As it looked jarring to have
reset_page_mapcount() and page_nid_reset_last() beside each other in
memmap_init_zone(), this patch also renames reset_page_mapcount() to
page_mapcount_reset(). There are others like init_page_count() but as it
is used throughout the arch code a rename would likely cause more conflicts
than it is worth.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/staging/ramster/zbud.c           |    2 +-
 drivers/staging/zsmalloc/zsmalloc-main.c |    2 +-
 include/linux/mm.h                       |   20 ++++++++++----------
 mm/huge_memory.c                         |    2 +-
 mm/mempolicy.c                           |    2 +-
 mm/migrate.c                             |    4 ++--
 mm/mmzone.c                              |    4 ++--
 mm/page_alloc.c                          |   10 +++++-----
 mm/slob.c                                |    2 +-
 mm/slub.c                                |    2 +-
 10 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/ramster/zbud.c b/drivers/staging/ramster/zbud.c
index a7c4361..cc2deff 100644
--- a/drivers/staging/ramster/zbud.c
+++ b/drivers/staging/ramster/zbud.c
@@ -401,7 +401,7 @@ static inline struct page *zbud_unuse_zbudpage(struct zbudpage *zbudpage,
 	else
 		zbud_pers_pageframes--;
 	zbudpage_spin_unlock(zbudpage);
-	reset_page_mapcount(page);
+	page_mapcount_reset(page);
 	init_page_count(page);
 	page->index = 0;
 	return page;
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 09a9d35..c7785f2 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -475,7 +475,7 @@ static void reset_page(struct page *page)
 	set_page_private(page, 0);
 	page->mapping = NULL;
 	page->freelist = NULL;
-	reset_page_mapcount(page);
+	page_mapcount_reset(page);
 }
 
 static void free_zspage(struct page *first_page)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6e4468f..0aa0944 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -366,7 +366,7 @@ static inline struct page *compound_head(struct page *page)
  * both from it and to it can be tracked, using atomic_inc_and_test
  * and atomic_add_negative(-1).
  */
-static inline void reset_page_mapcount(struct page *page)
+static inline void page_mapcount_reset(struct page *page)
 {
 	atomic_set(&(page)->_mapcount, -1);
 }
@@ -657,28 +657,28 @@ static inline int page_to_nid(const struct page *page)
 
 #ifdef CONFIG_NUMA_BALANCING
 #ifdef LAST_NID_NOT_IN_PAGE_FLAGS
-static inline int page_xchg_last_nid(struct page *page, int nid)
+static inline int page_nid_xchg_last(struct page *page, int nid)
 {
 	return xchg(&page->_last_nid, nid);
 }
 
-static inline int page_last_nid(struct page *page)
+static inline int page_nid_last(struct page *page)
 {
 	return page->_last_nid;
 }
-static inline void reset_page_last_nid(struct page *page)
+static inline void page_nid_reset_last(struct page *page)
 {
 	page->_last_nid = -1;
 }
 #else
-static inline int page_last_nid(struct page *page)
+static inline int page_nid_last(struct page *page)
 {
 	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
 }
 
-extern int page_xchg_last_nid(struct page *page, int nid);
+extern int page_nid_xchg_last(struct page *page, int nid);
 
-static inline void reset_page_last_nid(struct page *page)
+static inline void page_nid_reset_last(struct page *page)
 {
 	int nid = (1 << LAST_NID_SHIFT) - 1;
 
@@ -687,17 +687,17 @@ static inline void reset_page_last_nid(struct page *page)
 }
 #endif /* LAST_NID_NOT_IN_PAGE_FLAGS */
 #else
-static inline int page_xchg_last_nid(struct page *page, int nid)
+static inline int page_nid_xchg_last(struct page *page, int nid)
 {
 	return page_to_nid(page);
 }
 
-static inline int page_last_nid(struct page *page)
+static inline int page_nid_last(struct page *page)
 {
 	return page_to_nid(page);
 }
 
-static inline void reset_page_last_nid(struct page *page)
+static inline void page_nid_reset_last(struct page *page)
 {
 }
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 648c102..c52311a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1642,7 +1642,7 @@ static void __split_huge_page_refcount(struct page *page)
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
-		page_xchg_last_nid(page_tail, page_last_nid(page));
+		page_nid_xchg_last(page_tail, page_nid_last(page));
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e2df1c1..db6fc14 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2308,7 +2308,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * it less likely we act on an unlikely task<->page
 		 * relation.
 		 */
-		last_nid = page_xchg_last_nid(page, polnid);
+		last_nid = page_nid_xchg_last(page, polnid);
 		if (last_nid != polnid)
 			goto out;
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index 8ef1cbf..88422a1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1495,7 +1495,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					  __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
 	if (newpage)
-		page_xchg_last_nid(newpage, page_last_nid(page));
+		page_nid_xchg_last(newpage, page_nid_last(page));
 
 	return newpage;
 }
@@ -1679,7 +1679,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (!new_page)
 		goto out_fail;
 
-	page_xchg_last_nid(new_page, page_last_nid(page));
+	page_nid_xchg_last(new_page, page_nid_last(page));
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/mmzone.c b/mm/mmzone.c
index bce796e..2ac0afb 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -98,14 +98,14 @@ void lruvec_init(struct lruvec *lruvec)
 }
 
 #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NID_NOT_IN_PAGE_FLAGS)
-int page_xchg_last_nid(struct page *page, int nid)
+int page_nid_xchg_last(struct page *page, int nid)
 {
 	unsigned long old_flags, flags;
 	int last_nid;
 
 	do {
 		old_flags = flags = page->flags;
-		last_nid = page_last_nid(page);
+		last_nid = page_nid_last(page);
 
 		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
 		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df2022f..2d525c8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -287,7 +287,7 @@ static void bad_page(struct page *page)
 
 	/* Don't complain about poisoned pages */
 	if (PageHWPoison(page)) {
-		reset_page_mapcount(page); /* remove PageBuddy */
+		page_mapcount_reset(page); /* remove PageBuddy */
 		return;
 	}
 
@@ -319,7 +319,7 @@ static void bad_page(struct page *page)
 	dump_stack();
 out:
 	/* Leave bad fields for debug, except PageBuddy could make trouble */
-	reset_page_mapcount(page); /* remove PageBuddy */
+	page_mapcount_reset(page); /* remove PageBuddy */
 	add_taint(TAINT_BAD_PAGE);
 }
 
@@ -605,7 +605,7 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
-	reset_page_last_nid(page);
+	page_nid_reset_last(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -3871,8 +3871,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		set_page_links(page, zone, nid, pfn);
 		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
-		reset_page_mapcount(page);
-		reset_page_last_nid(page);
+		page_mapcount_reset(page);
+		page_nid_reset_last(page);
 		SetPageReserved(page);
 		/*
 		 * Mark the block movable so that blocks are reserved for
diff --git a/mm/slob.c b/mm/slob.c
index a99fdf7..eeed4a0 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -360,7 +360,7 @@ static void slob_free(void *block, int size)
 			clear_slob_page_free(sp);
 		spin_unlock_irqrestore(&slob_lock, flags);
 		__ClearPageSlab(sp);
-		reset_page_mapcount(sp);
+		page_mapcount_reset(sp);
 		slob_free_pages(b, 0);
 		return;
 	}
diff --git a/mm/slub.c b/mm/slub.c
index ba2ca53..ebcc44e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1408,7 +1408,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	__ClearPageSlab(page);
 
 	memcg_release_pages(s, order);
-	reset_page_mapcount(page);
+	page_mapcount_reset(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
 	__free_memcg_kmem_pages(page, order);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
