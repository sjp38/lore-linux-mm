Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 54BC76B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 10:38:58 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so7112798wgh.6
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 07:38:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e8si12885110wib.22.2014.06.17.07.38.55
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 07:38:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] hugetlb: fix copy_hugetlb_page_range() to handle migration/hwpoisoned entry
Date: Tue, 17 Jun 2014 09:49:55 -0400
Message-Id: <1403012995-538-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <alpine.LSU.2.11.1406161750520.1190@eggly.anvils>
References: <alpine.LSU.2.11.1406161750520.1190@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There's a race between fork() and hugepage migration, as a result we try to
"dereference" a swap entry as a normal pte, causing kernel panic.
The cause of the problem is that copy_hugetlb_page_range() can't handle "swap
entry" family (migration entry and hwpoisoned entry,) so let's fix it.

ChangeLog v2:
- stop applying is_cow_mapping() in copy_hugetlb_page_range()
- use set_huge_pte_at() in hugepage code
- fix stable version

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # v2.6.37+
---
 mm/hugetlb.c | 70 ++++++++++++++++++++++++++++++++++++------------------------
 1 file changed, 42 insertions(+), 28 deletions(-)

diff --git v3.16-rc1.orig/mm/hugetlb.c v3.16-rc1/mm/hugetlb.c
index 226910cb7c9b..a3f6349ab5b5 100644
--- v3.16-rc1.orig/mm/hugetlb.c
+++ v3.16-rc1/mm/hugetlb.c
@@ -2520,6 +2520,31 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
 		update_mmu_cache(vma, address, ptep);
 }
 
+static int is_hugetlb_entry_migration(pte_t pte)
+{
+	swp_entry_t swp;
+
+	if (huge_pte_none(pte) || pte_present(pte))
+		return 0;
+	swp = pte_to_swp_entry(pte);
+	if (non_swap_entry(swp) && is_migration_entry(swp))
+		return 1;
+	else
+		return 0;
+}
+
+static int is_hugetlb_entry_hwpoisoned(pte_t pte)
+{
+	swp_entry_t swp;
+
+	if (huge_pte_none(pte) || pte_present(pte))
+		return 0;
+	swp = pte_to_swp_entry(pte);
+	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
+		return 1;
+	else
+		return 0;
+}
 
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			    struct vm_area_struct *vma)
@@ -2559,10 +2584,25 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		dst_ptl = huge_pte_lock(h, dst, dst_pte);
 		src_ptl = huge_pte_lockptr(h, src, src_pte);
 		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
-		if (!huge_pte_none(huge_ptep_get(src_pte))) {
+		entry = huge_ptep_get(src_pte);
+		if (huge_pte_none(entry)) { /* skip none entry */
+			;
+		} else if (unlikely(is_hugetlb_entry_migration(entry) ||
+				    is_hugetlb_entry_hwpoisoned(entry))) {
+			swp_entry_t swp_entry = pte_to_swp_entry(entry);
+			if (is_write_migration_entry(swp_entry) && cow) {
+				/*
+				 * COW mappings require pages in both
+				 * parent and child to be set to read.
+				 */
+				make_migration_entry_read(&swp_entry);
+				entry = swp_entry_to_pte(swp_entry);
+				set_huge_pte_at(src, addr, src_pte, entry);
+			}
+			set_huge_pte_at(dst, addr, dst_pte, entry);
+		} else {
 			if (cow)
 				huge_ptep_set_wrprotect(src, addr, src_pte);
-			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
 			get_page(ptepage);
 			page_dup_rmap(ptepage);
@@ -2578,32 +2618,6 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	return ret;
 }
 
-static int is_hugetlb_entry_migration(pte_t pte)
-{
-	swp_entry_t swp;
-
-	if (huge_pte_none(pte) || pte_present(pte))
-		return 0;
-	swp = pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_migration_entry(swp))
-		return 1;
-	else
-		return 0;
-}
-
-static int is_hugetlb_entry_hwpoisoned(pte_t pte)
-{
-	swp_entry_t swp;
-
-	if (huge_pte_none(pte) || pte_present(pte))
-		return 0;
-	swp = pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
-		return 1;
-	else
-		return 0;
-}
-
 void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			    unsigned long start, unsigned long end,
 			    struct page *ref_page)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
