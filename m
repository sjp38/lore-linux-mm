Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id B28156B0036
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 11:43:11 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/2] hugetlbfs: add swap entry check in follow_hugetlb_page()
Date: Thu, 28 Mar 2013 11:42:38 -0400
Message-Id: <1364485358-8745-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With applying the previous patch "hugetlbfs: stop setting VM_DONTDUMP in
initializing vma(VM_HUGETLB)" to reenable hugepage coredump, if a memory
error happens on a hugepage and the affected processes try to access
the error hugepage, we hit VM_BUG_ON(atomic_read(&page->_count) <= 0)
in get_page().

The reason for this bug is that coredump-related code doesn't recognise
"hugepage hwpoison entry" with which a pmd entry is replaced when a memory
error occurs on a hugepage.
In other words, physical address information is stored in different bit layout
between hugepage hwpoison entry and pmd entry, so follow_hugetlb_page()
which is called in get_dump_page() returns a wrong page from a given address.

We need to filter out only hwpoison hugepages to have data on healthy
hugepages in coredump. So this patch makes follow_hugetlb_page() avoid
trying to get page when a pmd is in swap entry like format.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
index 0d1705b..8462e2c 100644
--- v3.9-rc3.orig/mm/hugetlb.c
+++ v3.9-rc3/mm/hugetlb.c
@@ -2968,7 +2968,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * first, for the page indexing below to work.
 		 */
 		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
-		absent = !pte || huge_pte_none(huge_ptep_get(pte));
+		absent = !pte || huge_pte_none(huge_ptep_get(pte)) ||
+			is_swap_pte(huge_ptep_get(pte));
 
 		/*
 		 * When coredumping, it suits get_dump_page if we just return
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
