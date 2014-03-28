Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 23CA26B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 16:35:38 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id p10so5297989pdj.12
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 13:35:37 -0700 (PDT)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id bp1si4336039pbb.135.2014.03.28.13.35.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 13:35:36 -0700 (PDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so5452523pbb.5
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 13:35:36 -0700 (PDT)
Date: Fri, 28 Mar 2014 13:35:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch stable-3.10] mm: close PageTail race
Message-ID: <alpine.DEB.2.02.1403281333290.18841@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org
Cc: Holger Kiehl <Holger.Kiehl@dwd.de>, Christoph Lameter <cl@linux.com>, Rafael Aquini <aquini@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

commit 668f9abbd4334e6c29fa8acd71635c4f9101caa7 upstream.

Commit bf6bddf1924e ("mm: introduce compaction and migration for
ballooned pages") introduces page_count(page) into memory compaction
which dereferences page->first_page if PageTail(page).

This results in a very rare NULL pointer dereference on the
aforementioned page_count(page).  Indeed, anything that does
compound_head(), including page_count() is susceptible to racing with
prep_compound_page() and seeing a NULL or dangling page->first_page
pointer.

This patch uses Andrea's implementation of compound_trans_head() that
deals with such a race and makes it the default compound_head()
implementation.  This includes a read memory barrier that ensures that
if PageTail(head) is true that we return a head page that is neither
NULL nor dangling.  The patch then adds a store memory barrier to
prep_compound_page() to ensure page->first_page is set.

This is the safest way to ensure we see the head page that we are
expecting, PageTail(page) is already in the unlikely() path and the
memory barriers are unfortunately required.

Hugetlbfs is the exception, we don't enforce a store memory barrier
during init since no race is possible.

Signed-off-by: David Rientjes <rientjes@google.com>
Cc: Holger Kiehl <Holger.Kiehl@dwd.de>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/block/aoe/aoecmd.c      |  2 +-
 drivers/vfio/vfio_iommu_type1.c |  4 ++--
 fs/proc/page.c                  |  2 +-
 include/linux/huge_mm.h         | 18 ------------------
 include/linux/mm.h              | 14 ++++++++++++--
 mm/ksm.c                        |  2 +-
 mm/memory-failure.c             |  2 +-
 mm/page_alloc.c                 |  4 +++-
 mm/swap.c                       |  4 ++--
 virt/kvm/kvm_main.c             |  4 ++--
 10 files changed, 25 insertions(+), 31 deletions(-)

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -899,7 +899,7 @@ bio_pageinc(struct bio *bio)
 		 * but this has never been seen here.
 		 */
 		if (unlikely(PageCompound(page)))
-			if (compound_trans_head(page) != page) {
+			if (compound_head(page) != page) {
 				pr_crit("page tail used for block I/O\n");
 				BUG();
 			}
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -138,12 +138,12 @@ static bool is_invalid_reserved_pfn(unsigned long pfn)
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
@@ -121,7 +121,7 @@ u64 stable_page_flags(struct page *page)
 	 * just checks PG_head/PG_tail, so we need to check PageLRU to make
 	 * sure a given page is a thp, not a non-huge compound page.
 	 */
-	else if (PageTransCompound(page) && PageLRU(compound_trans_head(page)))
+	else if (PageTransCompound(page) && PageLRU(compound_head(page)))
 		u |= 1 << KPF_THP;
 
 	/*
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -159,23 +159,6 @@ static inline int hpage_nr_pages(struct page *page)
 		return HPAGE_PMD_NR;
 	return 1;
 }
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
 
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
@@ -205,7 +188,6 @@ static inline int split_huge_page(struct page *page)
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
@@ -361,8 +361,18 @@ static inline void compound_unlock_irqrestore(struct page *page,
 
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
@@ -1544,7 +1544,7 @@ int soft_offline_page(struct page *page, int flags)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
-	struct page *hpage = compound_trans_head(page);
+	struct page *hpage = compound_head(page);
 
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -360,9 +360,11 @@ void prep_compound_page(struct page *page, unsigned long order)
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
-		__SetPageTail(p);
 		set_page_count(p, 0);
 		p->first_page = page;
+		/* Make sure p->first_page is always valid for PageTail() */
+		smp_wmb();
+		__SetPageTail(p);
 	}
 }
 
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -81,7 +81,7 @@ static void put_compound_page(struct page *page)
 {
 	if (unlikely(PageTail(page))) {
 		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = compound_trans_head(page);
+		struct page *page_head = compound_head(page);
 
 		if (likely(page != page_head &&
 			   get_page_unless_zero(page_head))) {
@@ -219,7 +219,7 @@ bool __get_page_tail(struct page *page)
 	 */
 	unsigned long flags;
 	bool got = false;
-	struct page *page_head = compound_trans_head(page);
+	struct page *page_head = compound_head(page);
 
 	if (likely(page != page_head && get_page_unless_zero(page_head))) {
 		/* Ref to put_compound_page() comment. */
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -105,12 +105,12 @@ bool kvm_is_mmio_pfn(pfn_t pfn)
 	if (pfn_valid(pfn)) {
 		int reserved;
 		struct page *tail = pfn_to_page(pfn);
-		struct page *head = compound_trans_head(tail);
+		struct page *head = compound_head(tail);
 		reserved = PageReserved(head);
 		if (head != tail) {
 			/*
 			 * "head" is not a dangling pointer
-			 * (compound_trans_head takes care of that)
+			 * (compound_head takes care of that)
 			 * but the hugepage may have been splitted
 			 * from under us (and we may not hold a
 			 * reference count on the head page so it can

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
