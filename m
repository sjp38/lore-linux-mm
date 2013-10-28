Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 475BB6B0031
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 18:16:31 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so7761302pde.29
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 15:16:30 -0700 (PDT)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id jp3si13178172pbc.126.2013.10.28.15.16.29
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 15:16:30 -0700 (PDT)
Subject: [PATCH 1/2] mm: hugetlbfs: Add some VM_BUG_ON()s to catch non-hugetlbfs pages
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Oct 2013 15:16:18 -0700
Message-Id: <20131028221618.4078637F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, dhillf@gmail.com, Dave Hansen <dave@sr71.net>


Dave Jiang reported that he was seeing oopses when running
NUMA systems and default_hugepagesz=1G.  I traced the issue down
to migrate_page_copy() trying to use the same code for hugetlb
pages and transparent hugepages.  It should not have been trying
to pass thp pages in there.

So, add some VM_BUG_ON()s for the next hapless VM developer that
tries the same thing.

---

 linux.git-davehans/include/linux/hugetlb.h |    1 +
 linux.git-davehans/mm/hugetlb.c            |    1 +
 2 files changed, 2 insertions(+)

diff -puN include/linux/hugetlb.h~bug-not-hugetlbfs-in-copy_huge_page include/linux/hugetlb.h
--- linux.git/include/linux/hugetlb.h~bug-not-hugetlbfs-in-copy_huge_page	2013-10-28 15:06:12.888828815 -0700
+++ linux.git-davehans/include/linux/hugetlb.h	2013-10-28 15:06:12.893829038 -0700
@@ -355,6 +355,7 @@ static inline pte_t arch_make_huge_pte(p
 
 static inline struct hstate *page_hstate(struct page *page)
 {
+	VM_BUG_ON(!PageHuge(page));
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
diff -puN mm/hugetlb.c~bug-not-hugetlbfs-in-copy_huge_page mm/hugetlb.c
--- linux.git/mm/hugetlb.c~bug-not-hugetlbfs-in-copy_huge_page	2013-10-28 15:06:12.890828904 -0700
+++ linux.git-davehans/mm/hugetlb.c	2013-10-28 15:06:12.894829082 -0700
@@ -498,6 +498,7 @@ void copy_huge_page(struct page *dst, st
 	int i;
 	struct hstate *h = page_hstate(src);
 
+	VM_BUG_ON(!h);
 	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
 		copy_gigantic_page(dst, src);
 		return;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
