Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC676B0035
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 18:16:32 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so7506278pad.37
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 15:16:32 -0700 (PDT)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id ws5si14133214pab.93.2013.10.28.15.16.31
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 15:16:31 -0700 (PDT)
Subject: [PATCH 2/2] mm: thp: give transparent hugepage code a separate copy_page
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Oct 2013 15:16:20 -0700
References: <20131028221618.4078637F@viggo.jf.intel.com>
In-Reply-To: <20131028221618.4078637F@viggo.jf.intel.com>
Message-Id: <20131028221620.042323B3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, dhillf@gmail.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Right now, the migration code in migrate_page_copy() uses 
copy_huge_page() for hugetlbfs and thp pages:

       if (PageHuge(page) || PageTransHuge(page))
                copy_huge_page(newpage, page);

So, yay for code reuse.  But:

void copy_huge_page(struct page *dst, struct page *src)
{
        struct hstate *h = page_hstate(src);

and a non-hugetlbfs page has no page_hstate().  This
works 99% of the time because page_hstate() determines
the hstate from the page order alone.  Since the page
order of a THP page matches the default hugetlbfs page
order, it works.

But, if you change the default huge page size on the
boot command-line (say default_hugepagesz=1G), then
we might not even *have* a 2MB hstate so page_hstate()
returns null and copy_huge_page() oopses pretty fast
since copy_huge_page() dereferences the hstate:

void copy_huge_page(struct page *dst, struct page *src)
{
        struct hstate *h = page_hstate(src);
        if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
...

This patch creates a copy_high_order_page() which can
be used on THP pages.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/huge_mm.h |   16 ++++++++++++++++
 linux.git-davehans/mm/huge_memory.c        |   13 +++++++++++++
 linux.git-davehans/mm/migrate.c            |    4 +++-
 3 files changed, 32 insertions(+), 1 deletion(-)

diff -puN include/linux/huge_mm.h~copy-huge-separate-from-copy-transhuge include/linux/huge_mm.h
--- linux.git/include/linux/huge_mm.h~copy-huge-separate-from-copy-transhuge	2013-10-28 15:10:28.294220490 -0700
+++ linux.git-davehans/include/linux/huge_mm.h	2013-10-28 15:10:28.301220803 -0700
@@ -177,6 +177,10 @@ static inline struct page *compound_tran
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
+extern void copy_high_order_page(struct page *newpage,
+				 struct page *oldpage,
+				 int order);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -227,6 +231,18 @@ static inline int do_huge_pmd_numa_page(
 	return 0;
 }
 
+/*
+ * The non-stub version of this code is probably usable
+ * generically but its only user is thp at the moment,
+ * so enforce that with a BUG()
+ */
+static inline  void copy_high_order_page(struct page *newpage,
+					 struct page *oldpage,
+					 int order)
+{
+	BUG();
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff -puN mm/huge_memory.c~copy-huge-separate-from-copy-transhuge mm/huge_memory.c
--- linux.git/mm/huge_memory.c~copy-huge-separate-from-copy-transhuge	2013-10-28 15:10:28.296220580 -0700
+++ linux.git-davehans/mm/huge_memory.c	2013-10-28 15:10:28.302220848 -0700
@@ -2789,3 +2789,16 @@ void __vma_adjust_trans_huge(struct vm_a
 			split_huge_page_address(next->vm_mm, nstart);
 	}
 }
+
+void copy_high_order_page(struct page *newpage,
+			  struct page *oldpage,
+			  int order)
+{
+	int i;
+
+	might_sleep();
+	for (i = 0; i < (1<<order); i++) {
+		cond_resched();
+		copy_highpage(newpage + i, oldpage + i);
+	}
+}
diff -puN mm/migrate.c~copy-huge-separate-from-copy-transhuge mm/migrate.c
--- linux.git/mm/migrate.c~copy-huge-separate-from-copy-transhuge	2013-10-28 15:10:28.298220669 -0700
+++ linux.git-davehans/mm/migrate.c	2013-10-28 15:10:28.303220893 -0700
@@ -443,8 +443,10 @@ int migrate_huge_page_move_mapping(struc
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	if (PageHuge(page) || PageTransHuge(page))
+	if (PageHuge(page))
 		copy_huge_page(newpage, page);
+	else if(PageTransHuge(page))
+		copy_high_order_page(newpage, page, HPAGE_PMD_ORDER);
 	else
 		copy_highpage(newpage, page);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
