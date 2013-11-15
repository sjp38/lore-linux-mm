Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 45B896B0035
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 18:07:11 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lf10so4261128pab.22
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:07:10 -0800 (PST)
Received: from psmtp.com ([74.125.245.152])
        by mx.google.com with SMTP id yd9si3206248pab.176.2013.11.15.15.07.09
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 15:07:09 -0800 (PST)
Subject: [v3][PATCH 2/2] mm: thp: give transparent hugepage code a separate copy_page
From: Dave Hansen <dave@sr71.net>
Date: Fri, 15 Nov 2013 14:55:53 -0800
References: <20131115225550.737E5C33@viggo.jf.intel.com>
In-Reply-To: <20131115225550.737E5C33@viggo.jf.intel.com>
Message-Id: <20131115225553.B0E9DFFB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave@sr71.net>


Changes from v2:
 * 
Changes from v1:
 * removed explicit might_sleep() in favor of the one that we
   get from the cond_resched();

--

From: Dave Hansen <dave.hansen@linux.intel.com>

Right now, the migration code in migrate_page_copy() uses
copy_huge_page() for hugetlbfs and thp pages:

       if (PageHuge(page) || PageTransHuge(page))
                copy_huge_page(newpage, page);

So, yay for code reuse.  But:

void copy_huge_page(struct page *dst, struct page *src)
{
        struct hstate *h = page_hstate(src);

and a non-hugetlbfs page has no page_hstate().  This works 99% of
the time because page_hstate() determines the hstate from the
page order alone.  Since the page order of a THP page matches the
default hugetlbfs page order, it works.

But, if you change the default huge page size on the boot
command-line (say default_hugepagesz=1G), then we might not even
*have* a 2MB hstate so page_hstate() returns null and
copy_huge_page() oopses pretty fast since copy_huge_page()
dereferences the hstate:

void copy_huge_page(struct page *dst, struct page *src)
{
        struct hstate *h = page_hstate(src);
        if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
...

Mel noticed that the migration code is really the only user of
these functions.  This moves all the copy code over to migrate.c
and makes copy_huge_page() work for THP by checking for it
explicitly.

I believe the bug was introduced in b32967ff101:
Author: Mel Gorman <mgorman@suse.de>
Date:   Mon Nov 19 12:35:47 2012 +0000
mm: numa: Add THP migration for the NUMA working set scanning fault case.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/hugetlb.h |    4 --
 linux.git-davehans/mm/hugetlb.c            |   34 --------------------
 linux.git-davehans/mm/migrate.c            |   48 +++++++++++++++++++++++++++++
 3 files changed, 48 insertions(+), 38 deletions(-)

diff -puN mm/migrate.c~copy-huge-separate-from-copy-transhuge mm/migrate.c
--- linux.git/mm/migrate.c~copy-huge-separate-from-copy-transhuge	2013-11-15 14:44:55.256970259 -0800
+++ linux.git-davehans/mm/migrate.c	2013-11-15 14:45:17.457963844 -0800
@@ -442,6 +442,54 @@ int migrate_huge_page_move_mapping(struc
 }
 
 /*
+ * Gigantic pages are so large that the we do not guarantee
+ * that page++ pointer arithmetic will work across the
+ * entire page.  We need something more specialized.
+ */
+static void __copy_gigantic_page(struct page *dst, struct page *src,
+				int nr_pages)
+{
+	int i;
+	struct page *dst_base = dst;
+	struct page *src_base = src;
+
+	for (i = 0; i < nr_pages; ) {
+		cond_resched();
+		copy_highpage(dst, src);
+
+		i++;
+		dst = mem_map_next(dst, dst_base, i);
+		src = mem_map_next(src, src_base, i);
+	}
+}
+
+static void copy_huge_page(struct page *dst, struct page *src)
+{
+	int i;
+	int nr_pages;
+
+	if (PageHuge(src)) {
+		/* hugetlbfs page */
+		struct hstate *h = page_hstate(src);
+		nr_pages = pages_per_huge_page(h);
+
+		if (unlikely(nr_pages > MAX_ORDER_NR_PAGES)) {
+			__copy_gigantic_page(dst, src, nr_pages);
+			return;
+		}
+	} else {
+		/* thp page */
+		BUG_ON(!PageTransHuge(src));
+		nr_pages = hpage_nr_pages(src);
+	}
+
+	for (i = 0; i < nr_pages; i++ ) {
+		cond_resched();
+		copy_highpage(dst + i, src + i);
+	}
+}
+
+/*
  * Copy the page to its new location
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
diff -puN mm/hugetlb.c~copy-huge-separate-from-copy-transhuge mm/hugetlb.c
--- linux.git/mm/hugetlb.c~copy-huge-separate-from-copy-transhuge	2013-11-15 14:44:55.261970484 -0800
+++ linux.git-davehans/mm/hugetlb.c	2013-11-15 14:44:55.389976227 -0800
@@ -476,40 +476,6 @@ static int vma_has_reserves(struct vm_ar
 	return 0;
 }
 
-static void copy_gigantic_page(struct page *dst, struct page *src)
-{
-	int i;
-	struct hstate *h = page_hstate(src);
-	struct page *dst_base = dst;
-	struct page *src_base = src;
-
-	for (i = 0; i < pages_per_huge_page(h); ) {
-		cond_resched();
-		copy_highpage(dst, src);
-
-		i++;
-		dst = mem_map_next(dst, dst_base, i);
-		src = mem_map_next(src, src_base, i);
-	}
-}
-
-void copy_huge_page(struct page *dst, struct page *src)
-{
-	int i;
-	struct hstate *h = page_hstate(src);
-
-	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
-		copy_gigantic_page(dst, src);
-		return;
-	}
-
-	might_sleep();
-	for (i = 0; i < pages_per_huge_page(h); i++) {
-		cond_resched();
-		copy_highpage(dst + i, src + i);
-	}
-}
-
 static void enqueue_huge_page(struct hstate *h, struct page *page)
 {
 	int nid = page_to_nid(page);
diff -puN include/linux/hugetlb.h~copy-huge-separate-from-copy-transhuge include/linux/hugetlb.h
--- linux.git/include/linux/hugetlb.h~copy-huge-separate-from-copy-transhuge	2013-11-15 14:44:55.263970574 -0800
+++ linux.git-davehans/include/linux/hugetlb.h	2013-11-15 14:44:55.325973356 -0800
@@ -69,7 +69,6 @@ int dequeue_hwpoisoned_huge_page(struct
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
 bool is_hugepage_active(struct page *page);
-void copy_huge_page(struct page *dst, struct page *src);
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
@@ -140,9 +139,6 @@ static inline int dequeue_hwpoisoned_hug
 #define isolate_huge_page(p, l) false
 #define putback_active_hugepage(p)	do {} while (0)
 #define is_hugepage_active(x)	false
-static inline void copy_huge_page(struct page *dst, struct page *src)
-{
-}
 
 static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
