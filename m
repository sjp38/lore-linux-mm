Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id D1E676B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 04:00:45 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so8987235pbb.37
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 01:00:44 -0800 (PST)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id n8si21991003pax.160.2014.02.12.01.00.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 01:00:43 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so8320195pdb.24
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 01:00:43 -0800 (PST)
Date: Wed, 12 Feb 2014 01:00:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm: close PageTail race
In-Reply-To: <20140205084235.GA30705@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1402120058370.31209@chino.kir.corp.google.com>
References: <20140203122052.GC2495@dhcp22.suse.cz> <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de> <20140203162036.GJ2495@dhcp22.suse.cz> <52EFC93D.3030106@suse.cz> <alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1402040713220.13901@diagnostix.dwd.de> <alpine.DEB.2.02.1402041557380.10140@chino.kir.corp.google.com> <20140204160641.8f5d369eeb2d0318618d6d5f@linux-foundation.org> <alpine.DEB.2.02.1402041613450.14962@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1402041621350.14962@chino.kir.corp.google.com> <20140205084235.GA30705@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since "mm, compaction: avoid isolating pinned pages", it has been
possible for page_count(page) to race with prep_compound_page() by
finding PageTail(page) set with a NULL or dangling page->first_page.

"mm, page_alloc: make first_page visible before PageTail" adds a store
memory barrier to prep_compound_page() to ensure page->first_page is
set, but nothing is preventing compound_head() from seeing a dangling
head page.

This patch uses Andrea's implementation of compound_trans_head() that
deals with such a race and makes it the default compound_head()
implementation.  This includes a read memory barrier that ensures that
if PageTail(head) is true that we return a head page that is neither
NULL nor dangling.

This is the safest way to ensure we see the head page that we are
expecting, PageTail(page) is already in the unlikely() path and the
memory barriers are unfortunately required.

Hugetlbfs is the exception, we don't enforce a store memory barrier
during init since no race is possible.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Note: this is targeted for -mm because there is a prerequisite patch,
 mm-page_alloc-make-first_page-visible-before-pagetail.patch, in that
 tree which adds a smp_wmb() to prep_compound_page().

 drivers/block/aoe/aoecmd.c      |  4 ++--
 drivers/vfio/vfio_iommu_type1.c |  4 ++--
 fs/proc/page.c                  |  5 ++---
 include/linux/huge_mm.h         | 41 -----------------------------------------
 include/linux/mm.h              | 14 ++++++++++++--
 mm/ksm.c                        |  2 +-
 mm/memory-failure.c             |  2 +-
 mm/swap.c                       |  4 ++--
 8 files changed, 22 insertions(+), 54 deletions(-)

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -874,7 +874,7 @@ bio_pageinc(struct bio *bio)
 		/* Non-zero page count for non-head members of
 		 * compound pages is no longer allowed by the kernel.
 		 */
-		page = compound_trans_head(bv.bv_page);
+		page = compound_head(bv.bv_page);
 		atomic_inc(&page->_count);
 	}
 }
@@ -887,7 +887,7 @@ bio_pagedec(struct bio *bio)
 	struct bvec_iter iter;
 
 	bio_for_each_segment(bv, bio, iter) {
-		page = compound_trans_head(bv.bv_page);
+		page = compound_head(bv.bv_page);
 		atomic_dec(&page->_count);
 	}
 }
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -186,12 +186,12 @@ static bool is_invalid_reserved_pfn(unsigned long pfn)
 	if (pfn_valid(pfn)) {
 		bool reserved;
 		struct page *tail = pfn_to_page(pfn);
-		struct page *head = compound_trans_head(tail);
+		struct page *head = compound_head(tail);
 		reserved = !!(PageReserved(head));
 		if (head != tail) {
 			/*
 			 * "head" is not a dangling pointer
-			 * (compound_trans_head takes care of that)
+			 * (compound_head takes care of that)
 			 * but the hugepage may have been split
 			 * from under us (and we may not hold a
 			 * reference count on the head page so it can
diff --git a/fs/proc/page.c b/fs/proc/page.c
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -121,9 +121,8 @@ u64 stable_page_flags(struct page *page)
 	 * just checks PG_head/PG_tail, so we need to check PageLRU/PageAnon
 	 * to make sure a given page is a thp, not a non-huge compound page.
 	 */
-	else if (PageTransCompound(page) &&
-		 (PageLRU(compound_trans_head(page)) ||
-		  PageAnon(compound_trans_head(page))))
+	else if (PageTransCompound(page) && (PageLRU(compound_head(page)) ||
+					     PageAnon(compound_head(page))))
 		u |= 1 << KPF_THP;
 
 	/*
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -157,46 +157,6 @@ static inline int hpage_nr_pages(struct page *page)
 		return HPAGE_PMD_NR;
 	return 1;
 }
-/*
- * compound_trans_head() should be used instead of compound_head(),
- * whenever the "page" passed as parameter could be the tail of a
- * transparent hugepage that could be undergoing a
- * __split_huge_page_refcount(). The page structure layout often
- * changes across releases and it makes extensive use of unions. So if
- * the page structure layout will change in a way that
- * page->first_page gets clobbered by __split_huge_page_refcount, the
- * implementation making use of smp_rmb() will be required.
- *
- * Currently we define compound_trans_head as compound_head, because
- * page->private is in the same union with page->first_page, and
- * page->private isn't clobbered. However this also means we're
- * currently leaving dirt into the page->private field of anonymous
- * pages resulting from a THP split, instead of setting page->private
- * to zero like for every other page that has PG_private not set. But
- * anonymous pages don't use page->private so this is not a problem.
- */
-#if 0
-/* This will be needed if page->private will be clobbered in split_huge_page */
-static inline struct page *compound_trans_head(struct page *page)
-{
-	if (PageTail(page)) {
-		struct page *head;
-		head = page->first_page;
-		smp_rmb();
-		/*
-		 * head may be a dangling pointer.
-		 * __split_huge_page_refcount clears PageTail before
-		 * overwriting first_page, so if PageTail is still
-		 * there it means the head pointer isn't dangling.
-		 */
-		if (PageTail(page))
-			return head;
-	}
-	return page;
-}
-#else
-#define compound_trans_head(page) compound_head(page)
-#endif
 
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
@@ -226,7 +186,6 @@ static inline int split_huge_page(struct page *page)
 	do { } while (0)
 #define split_huge_page_pmd_mm(__mm, __address, __pmd)	\
 	do { } while (0)
-#define compound_trans_head(page) compound_head(page)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -399,8 +399,18 @@ static inline void compound_unlock_irqrestore(struct page *page,
 
 static inline struct page *compound_head(struct page *page)
 {
-	if (unlikely(PageTail(page)))
-		return page->first_page;
+	if (unlikely(PageTail(page))) {
+		struct page *head = page->first_page;
+
+		/*
+		 * page->first_page may be a dangling pointer to an old
+		 * compound page, so recheck that it is still a tail
+		 * page before returning.
+		 */
+		smp_rmb();
+		if (likely(PageTail(page)))
+			return head;
+	}
 	return page;
 }
 
diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -444,7 +444,7 @@ static void break_cow(struct rmap_item *rmap_item)
 static struct page *page_trans_compound_anon(struct page *page)
 {
 	if (PageTransCompound(page)) {
-		struct page *head = compound_trans_head(page);
+		struct page *head = compound_head(page);
 		/*
 		 * head may actually be splitted and freed from under
 		 * us but it's ok here.
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1649,7 +1649,7 @@ int soft_offline_page(struct page *page, int flags)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
-	struct page *hpage = compound_trans_head(page);
+	struct page *hpage = compound_head(page);
 
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -98,7 +98,7 @@ static void put_compound_page(struct page *page)
 	}
 
 	/* __split_huge_page_refcount can run under us */
-	page_head = compound_trans_head(page);
+	page_head = compound_head(page);
 
 	/*
 	 * THP can not break up slab pages so avoid taking
@@ -253,7 +253,7 @@ bool __get_page_tail(struct page *page)
 	 */
 	unsigned long flags;
 	bool got;
-	struct page *page_head = compound_trans_head(page);
+	struct page *page_head = compound_head(page);
 
 	/* Ref to put_compound_page() comment. */
 	if (!__compound_tail_refcounted(page_head)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
