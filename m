Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 614536B006C
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 17:31:55 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so1526395qgf.28
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 14:31:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e92si5014971qgf.34.2014.09.26.14.31.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 14:31:54 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [mmotm][PATCH 2/2] mm/hugetlb: cleanup and rename is_hugetlb_entry_(migration|hwpoisoned)()
Date: Fri, 26 Sep 2014 16:44:11 -0400
Message-Id: <1411764251-31910-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1411764251-31910-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1411764251-31910-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

non_swap_entry() returns true if a given swp_entry_t is a migration
entry or hwpoisoned entry. So non_swap_entry() && is_migration_entry() is
identical with just is_migration_entry(). By removing non_swap_entry(),
we can write is_hugetlb_entry_(migration|hwpoisoned)() more simply.

And the name is_hugetlb_entry_(migration|hwpoisoned) is lengthy and
it's not predictable from naming convention around pte_* family.
Just pte_migration() looks better, but these function contains hugetlb
specific (so architecture dependent) huge_pte_none() check, so let's
rename them as huge_pte_(migration|hwpoisoned).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 36 ++++++++++++------------------------
 1 file changed, 12 insertions(+), 24 deletions(-)

diff --git mmotm-2014-09-25-16-28.orig/mm/hugetlb.c mmotm-2014-09-25-16-28/mm/hugetlb.c
index e6543359be4d..e70da7ae36ed 100644
--- mmotm-2014-09-25-16-28.orig/mm/hugetlb.c
+++ mmotm-2014-09-25-16-28/mm/hugetlb.c
@@ -2516,30 +2516,18 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
 		update_mmu_cache(vma, address, ptep);
 }
 
-static int is_hugetlb_entry_migration(pte_t pte)
+static inline int huge_pte_migration(pte_t pte)
 {
-	swp_entry_t swp;
-
 	if (huge_pte_none(pte) || pte_present(pte))
 		return 0;
-	swp = pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_migration_entry(swp))
-		return 1;
-	else
-		return 0;
+	return is_migration_entry(pte_to_swp_entry(pte));
 }
 
-static int is_hugetlb_entry_hwpoisoned(pte_t pte)
+static inline int huge_pte_hwpoisoned(pte_t pte)
 {
-	swp_entry_t swp;
-
 	if (huge_pte_none(pte) || pte_present(pte))
 		return 0;
-	swp = pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
-		return 1;
-	else
-		return 0;
+	return is_hwpoison_entry(pte_to_swp_entry(pte));
 }
 
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
@@ -2583,8 +2571,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		entry = huge_ptep_get(src_pte);
 		if (huge_pte_none(entry)) { /* skip none entry */
 			;
-		} else if (unlikely(is_hugetlb_entry_migration(entry) ||
-				    is_hugetlb_entry_hwpoisoned(entry))) {
+		} else if (unlikely(huge_pte_migration(entry) ||
+				    huge_pte_hwpoisoned(entry))) {
 			swp_entry_t swp_entry = pte_to_swp_entry(entry);
 
 			if (is_write_migration_entry(swp_entry) && cow) {
@@ -3162,9 +3150,9 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * a active hugepage in pagecache.
 	 */
 	if (!pte_present(entry)) {
-		if (is_hugetlb_entry_migration(entry))
+		if (huge_pte_migration(entry))
 			need_wait_migration = 1;
-		else if (is_hugetlb_entry_hwpoisoned(entry))
+		else if (huge_pte_hwpoisoned(entry))
 			ret = VM_FAULT_HWPOISON_LARGE |
 				VM_FAULT_SET_HINDEX(hstate_index(h));
 		goto out_mutex;
@@ -3291,8 +3279,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * (in which case hugetlb_fault waits for the migration,) and
 		 * hwpoisoned hugepages (in which case we need to prevent the
 		 * caller from accessing to them.) In order to do this, we use
-		 * here is_swap_pte instead of is_hugetlb_entry_migration and
-		 * is_hugetlb_entry_hwpoisoned. This is because it simply covers
+		 * here is_swap_pte instead of huge_pte_migration and
+		 * huge_pte_hwpoisoned. This is because it simply covers
 		 * both cases, and because we can't follow correct pages
 		 * directly from any kind of swap entries.
 		 */
@@ -3370,11 +3358,11 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			continue;
 		}
 		pte = huge_ptep_get(ptep);
-		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
+		if (unlikely(huge_pte_hwpoisoned(pte))) {
 			spin_unlock(ptl);
 			continue;
 		}
-		if (unlikely(is_hugetlb_entry_migration(pte))) {
+		if (unlikely(huge_pte_migration(pte))) {
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
 			if (is_write_migration_entry(entry)) {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
