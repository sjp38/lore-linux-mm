Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 27CE96B0035
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:56:01 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id x10so4066183pdj.18
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:56:00 -0800 (PST)
Received: from psmtp.com ([74.125.245.108])
        by mx.google.com with SMTP id pl10si3165038pbc.328.2013.11.15.14.55.53
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 14:55:54 -0800 (PST)
Subject: [v3][PATCH 1/2] mm: hugetlbfs: Add VM_BUG_ON()s to catch non-hugetlbfs pages
From: Dave Hansen <dave@sr71.net>
Date: Fri, 15 Nov 2013 14:55:52 -0800
References: <20131115225550.737E5C33@viggo.jf.intel.com>
In-Reply-To: <20131115225550.737E5C33@viggo.jf.intel.com>
Message-Id: <20131115225552.6DCE2E1B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Changes from v2:
 * Removed the VM_BUG_ON() from copy_huge_page() since the
   next patch makes it able to handle non-hugetlbfs pages

--

Dave Jiang reported that he was seeing oopses when running
NUMA systems and default_hugepagesz=1G.  I traced the issue down
to migrate_page_copy() trying to use the same code for hugetlb
pages and transparent hugepages.  It should not have been trying
to pass thp pages in there.

So, add a VM_BUG_ON()s for the next hapless developer that
tries to use page_hstate() on a non-hugetlbfs page.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Mel Gorman <mgorman@suse.de>

---

 linux.git-davehans/include/linux/hugetlb.h |    1 +
 1 file changed, 1 insertion(+)

diff -puN include/linux/hugetlb.h~bug-not-hugetlbfs-in-copy_huge_page include/linux/hugetlb.h
--- linux.git/include/linux/hugetlb.h~bug-not-hugetlbfs-in-copy_huge_page	2013-11-15 14:44:41.550357120 -0800
+++ linux.git-davehans/include/linux/hugetlb.h	2013-11-15 14:44:41.553357255 -0800
@@ -355,6 +355,7 @@ static inline pte_t arch_make_huge_pte(p
 
 static inline struct hstate *page_hstate(struct page *page)
 {
+	VM_BUG_ON(!PageHuge(page));
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
