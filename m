Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 93CC96B0039
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 14:35:56 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 3/3] hugetlbfs: add swap entry check in follow_hugetlb_page()
Date: Wed,  3 Apr 2013 14:35:38 -0400
Message-Id: <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

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

ChangeLog v3:
 - add comment about using is_swap_pte()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: stable@vger.kernel.org
---
 mm/hugetlb.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
index 0d1705b..3bc20bd 100644
--- v3.9-rc3.orig/mm/hugetlb.c
+++ v3.9-rc3/mm/hugetlb.c
@@ -2966,9 +2966,15 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * Some archs (sparc64, sh*) have multiple pte_ts to
 		 * each hugepage.  We have to make sure we get the
 		 * first, for the page indexing below to work.
+		 *
+		 * is_swap_pte test covers both is_hugetlb_entry_hwpoisoned
+		 * and hugepages under migration in which case
+		 * hugetlb_fault waits for the migration and bails out
+		 * properly for HWPosined pages.
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
