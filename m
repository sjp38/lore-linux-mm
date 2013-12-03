Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 769E46B0038
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:06 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so1258574eek.32
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id w6si38042926eeg.216.2013.12.03.00.52.05
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:05 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/15] mm: thp: give transparent hugepage code a separate copy_page
Date: Tue,  3 Dec 2013 08:51:50 +0000
Message-Id: <1386060721-3794-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Dave Hansen <dave.hansen@linux.intel.com>

commit 30b0a105d9f7141e4cbf72ae5511832457d89788 upstream.

Right now, the migration code in migrate_page_copy() uses copy_huge_page()
for hugetlbfs and thp pages:

       if (PageHuge(page) || PageTransHuge(page))
                copy_huge_page(newpage, page);

So, yay for code reuse.  But:

  void copy_huge_page(struct page *dst, struct page *src)
  {
        struct hstate *h = page_hstate(src);

and a non-hugetlbfs page has no page_hstate().  This works 99% of the
time because page_hstate() determines the hstate from the page order
alone.  Since the page order of a THP page matches the default hugetlbfs
page order, it works.

But, if you change the default huge page size on the boot command-line
(say default_hugepagesz=1G), then we might not even *have* a 2MB hstate
so page_hstate() returns null and copy_huge_page() oopses pretty fast
since copy_huge_page() dereferences the hstate:

  void copy_huge_page(struct page *dst, struct page *src)
  {
        struct hstate *h = page_hstate(src);
        if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
  ...

Mel noticed that the migration code is really the only user of these
functions.  This moves all the copy code over to migrate.c and makes
copy_huge_page() work for THP by checking for it explicitly.

I believe the bug was introduced in commit b32967ff101a ("mm: numa: Add
THP migration for the NUMA working set scanning fault case")

[akpm@linux-foundation.org: fix coding-style and comment text, per Naoya Horiguchi]
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <dhillf@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Tested-by: Dave Jiang <dave.jiang@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/hugetlb.h |  4 ----
 mm/hugetlb.c            | 34 ----------------------------------
 mm/migrate.c            | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 48 insertions(+), 38 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6125579..4694afc 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -70,7 +70,6 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
 bool is_hugepage_active(struct page *page);
-void copy_huge_page(struct page *dst, struct page *src);
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
@@ -146,9 +145,6 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
 #define isolate_huge_page(p, l) false
 #define putback_active_hugepage(p)	do {} while (0)
 #define is_hugepage_active(x)	false
-static inline void copy_huge_page(struct page *dst, struct page *src)
-{
-}
 
 static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f0a4ca4..0defeb6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -476,40 +476,6 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
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
diff --git a/mm/migrate.c b/mm/migrate.c
index c046927..fbcac8b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -441,6 +441,54 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 }
 
 /*
+ * Gigantic pages are so large that we do not guarantee that page++ pointer
+ * arithmetic will work across the entire page.  We need something more
+ * specialized.
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
+	for (i = 0; i < nr_pages; i++) {
+		cond_resched();
+		copy_highpage(dst + i, src + i);
+	}
+}
+
+/*
  * Copy the page to its new location
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
