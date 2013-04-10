Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id E31336B0037
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:09:37 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 3/3] hugetlbfs: add swap entry check in follow_hugetlb_page()
Date: Wed, 10 Apr 2013 12:09:17 -0400
Message-Id: <1365610157-15290-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365610157-15290-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1365610157-15290-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

# I suspended Reviewed and Acked given for the previous version, because
# it has a non-minor change. If you want to restore it, please let me know.
-----
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

The expected behavior is like this:

  absent   is_swap_pte   FOLL_DUMP   Expected behavior
  -------------------------------------------------------------------
   true     false         false       hugetlb_fault
   false    true          false       hugetlb_fault
   false    false         false       return page
   true     false         true        skip page (to avoid allocation)
   false    true          true        hugetlb_fault
   false    false         true        return page

With this patch, we can call hugetlb_fault() and take proper actions
(we wait for migration entries, fail with VM_FAULT_HWPOISON_LARGE for
hwpoisoned entries,) and as the result we can dump all hugepages except
for hwpoisoned ones.

ChangeLog v5:
 - improve comment and description.

ChangeLog v4:
 - move is_swap_page() to right place.

ChangeLog v3:
 - add comment about using is_swap_pte()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org
---
 mm/hugetlb.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
index 0d1705b..bf26ee8 100644
--- v3.9-rc3.orig/mm/hugetlb.c
+++ v3.9-rc3/mm/hugetlb.c
@@ -2983,7 +2983,17 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			break;
 		}
 
-		if (absent ||
+		/*
+		 * We need call hugetlb_fault for both hugepages under migration
+		 * (in which case hugetlb_fault waits for the migration,) and
+		 * hwpoisoned hugepages (in which case we need to prevent the
+		 * caller from accessing to them.) In order to do this, we use
+		 * here is_swap_pte instead of is_hugetlb_entry_migration and
+		 * is_hugetlb_entry_hwpoisoned. This is because it simply covers
+		 * both cases, and because we can't follow correct pages
+		 * directly from any kind of swap entries.
+		 */
+		if (absent || is_swap_pte(huge_ptep_get(pte)) ||
 		    ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
 			int ret;
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
