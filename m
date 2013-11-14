Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8506B0039
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 18:34:03 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2730415pbb.13
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 15:34:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.186])
        by mx.google.com with SMTP id yd9si101251pab.234.2013.11.14.15.34.00
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 15:34:02 -0800 (PST)
Subject: [PATCH 1/2] mm: hugetlbfs: Add some VM_BUG_ON()s to catch non-hugetlbfs pages
From: Dave Hansen <dave@sr71.net>
Date: Thu, 14 Nov 2013 15:33:58 -0800
References: <20131114233357.90EE35C1@viggo.jf.intel.com>
In-Reply-To: <20131114233357.90EE35C1@viggo.jf.intel.com>
Message-Id: <20131114233358.2B10EA33@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Dave Jiang reported that he was seeing oopses when running
NUMA systems and default_hugepagesz=1G.  I traced the issue down
to migrate_page_copy() trying to use the same code for hugetlb
pages and transparent hugepages.  It should not have been trying
to pass thp pages in there.

So, add some VM_BUG_ON()s for the next hapless VM developer that
tries the same thing.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

---

 linux.git-davehans/include/linux/hugetlb.h |    1 +
 linux.git-davehans/mm/hugetlb.c            |    1 +
 2 files changed, 2 insertions(+)

diff -puN include/linux/hugetlb.h~bug-not-hugetlbfs-in-copy_huge_page include/linux/hugetlb.h
--- linux.git/include/linux/hugetlb.h~bug-not-hugetlbfs-in-copy_huge_page	2013-11-14 15:09:38.707180957 -0800
+++ linux.git-davehans/include/linux/hugetlb.h	2013-11-14 15:09:38.710181090 -0800
@@ -355,6 +355,7 @@ static inline pte_t arch_make_huge_pte(p
 
 static inline struct hstate *page_hstate(struct page *page)
 {
+	VM_BUG_ON(!PageHuge(page));
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
diff -puN mm/hugetlb.c~bug-not-hugetlbfs-in-copy_huge_page mm/hugetlb.c
--- linux.git/mm/hugetlb.c~bug-not-hugetlbfs-in-copy_huge_page	2013-11-14 15:09:38.708181001 -0800
+++ linux.git-davehans/mm/hugetlb.c	2013-11-14 15:09:38.711181135 -0800
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
