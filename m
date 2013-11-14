Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 272A86B003A
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 18:34:04 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ld10so2776414pab.20
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 15:34:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.135])
        by mx.google.com with SMTP id q7si124591pbi.105.2013.11.14.15.34.01
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 15:34:02 -0800 (PST)
Subject: [PATCH 2/2] mm: thp: give transparent hugepage code a separate copy_page
From: Dave Hansen <dave@sr71.net>
Date: Thu, 14 Nov 2013 15:34:00 -0800
References: <20131114233357.90EE35C1@viggo.jf.intel.com>
In-Reply-To: <20131114233357.90EE35C1@viggo.jf.intel.com>
Message-Id: <20131114233400.A729214D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave@sr71.net>


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

I believe the bug was introduced in b32967ff101:
Author: Mel Gorman <mgorman@suse.de>
Date:   Mon Nov 19 12:35:47 2012 +0000
mm: numa: Add THP migration for the NUMA working set scanning fault case.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/huge_mm.h |   16 ++++++++++++++++
 linux.git-davehans/mm/huge_memory.c        |   12 ++++++++++++
 linux.git-davehans/mm/migrate.c            |    6 ++++--
 3 files changed, 32 insertions(+), 2 deletions(-)

diff -puN include/linux/huge_mm.h~copy-huge-separate-from-copy-transhuge include/linux/huge_mm.h
--- linux.git/include/linux/huge_mm.h~copy-huge-separate-from-copy-transhuge	2013-11-14 15:09:38.869188202 -0800
+++ linux.git-davehans/include/linux/huge_mm.h	2013-11-14 15:09:38.873188379 -0800
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
--- linux.git/mm/huge_memory.c~copy-huge-separate-from-copy-transhuge	2013-11-14 15:09:38.870188245 -0800
+++ linux.git-davehans/mm/huge_memory.c	2013-11-14 15:09:38.874188424 -0800
@@ -2890,3 +2890,15 @@ void __vma_adjust_trans_huge(struct vm_a
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
+	for (i = 0; i < (1<<order); i++) {
+		cond_resched();
+		copy_highpage(newpage + i, oldpage + i);
+	}
+}
diff -puN mm/migrate.c~copy-huge-separate-from-copy-transhuge mm/migrate.c
--- linux.git/mm/migrate.c~copy-huge-separate-from-copy-transhuge	2013-11-14 15:09:38.871188288 -0800
+++ linux.git-davehans/mm/migrate.c	2013-11-14 15:09:38.874188424 -0800
@@ -447,8 +447,10 @@ void migrate_page_copy(struct page *newp
 {
 	int cpupid;
 
-	if (PageHuge(page) || PageTransHuge(page))
-		copy_huge_page(newpage, page);
+	if (PageHuge(page))
+ 		copy_huge_page(newpage, page);
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
