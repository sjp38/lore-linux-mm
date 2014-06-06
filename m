Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 75AA16B00A1
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 15:48:11 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j5so4716406qaq.1
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 12:48:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fs1si14228041qcb.32.2014.06.06.12.48.09
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 12:48:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] hugetlb: fix copy_hugetlb_page_range() to handle migration/hwpoisoned entry
Date: Fri,  6 Jun 2014 15:07:00 -0400
Message-Id: <1402081620-1247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There's a race between fork() and hugepage migration, as a result we try to
"dereference" a swap entry as a normal pte, causing kernel panic.
The cause of the problem is that copy_hugetlb_page_range() can't handle "swap
entry" family (migration entry and hwpoisoned entry,) so let's fix it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # v2.6.36+
---
 include/linux/mm.h |  6 +++++
 mm/hugetlb.c       | 72 ++++++++++++++++++++++++++++++++----------------------
 mm/memory.c        |  5 ----
 3 files changed, 49 insertions(+), 34 deletions(-)

diff --git v3.15-rc8.orig/include/linux/mm.h v3.15-rc8/include/linux/mm.h
index d6777060449f..6b4fe9ec79ba 100644
--- v3.15-rc8.orig/include/linux/mm.h
+++ v3.15-rc8/include/linux/mm.h
@@ -1924,6 +1924,12 @@ static inline struct vm_area_struct *find_exact_vma(struct mm_struct *mm,
 	return vma;
 }
 
+static inline bool is_cow_mapping(vm_flags_t flags)
+{
+	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
+}
+
+
 #ifdef CONFIG_MMU
 pgprot_t vm_get_page_prot(unsigned long vm_flags);
 #else
diff --git v3.15-rc8.orig/mm/hugetlb.c v3.15-rc8/mm/hugetlb.c
index c82290b9c1fc..47ae7db288f7 100644
--- v3.15-rc8.orig/mm/hugetlb.c
+++ v3.15-rc8/mm/hugetlb.c
@@ -2377,6 +2377,31 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
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
@@ -2391,7 +2416,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	int ret = 0;
 
-	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
+	cow = is_cow_mapping(vma->vm_flags);
 
 	mmun_start = vma->vm_start;
 	mmun_end = vma->vm_end;
@@ -2416,10 +2441,25 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
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
+				set_pte_at(src, addr, src_pte, entry);
+			}
+			set_huge_pte_at(dst, addr, dst_pte, entry);
+		} else {
 			if (cow)
 				huge_ptep_set_wrprotect(src, addr, src_pte);
-			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
 			get_page(ptepage);
 			page_dup_rmap(ptepage);
@@ -2435,32 +2475,6 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
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
diff --git v3.15-rc8.orig/mm/memory.c v3.15-rc8/mm/memory.c
index 037b812a9531..efc66b128976 100644
--- v3.15-rc8.orig/mm/memory.c
+++ v3.15-rc8/mm/memory.c
@@ -698,11 +698,6 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
 }
 
-static inline bool is_cow_mapping(vm_flags_t flags)
-{
-	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
-}
-
 /*
  * vm_normal_page -- This function gets the "struct page" associated with a pte.
  *
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
