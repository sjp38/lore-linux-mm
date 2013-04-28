Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 9D73B6B003A
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:37:50 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:02:40 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 80A39E002D
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:09:53 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJbe9Q9634204
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:40 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJbhYk002988
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:37:44 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 02/18] mm/THP: Add pmd args to pgtable deposit and withdraw APIs
Date: Mon, 29 Apr 2013 01:07:23 +0530
Message-Id: <1367177859-7893-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This will be later used by powerpc THP support. In powerpc we want to use
pgtable for storing the hash index values. So instead of adding them to
mm_context list, we would like to store them in the second half of pmd

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: David Gibson <david@gibson.dropbear.id.au>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/s390/include/asm/pgtable.h     |  5 +++--
 arch/s390/mm/pgtable.c              |  5 +++--
 arch/sparc/include/asm/pgtable_64.h |  5 +++--
 arch/sparc/mm/tlb.c                 |  5 +++--
 include/asm-generic/pgtable.h       |  5 +++--
 mm/huge_memory.c                    | 18 +++++++++---------
 mm/pgtable-generic.c                |  5 +++--
 7 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 3cb47cf..83da660 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1283,10 +1283,11 @@ static inline void __pmd_idte(unsigned long address, pmd_t *pmdp)
 #define SEGMENT_RW	__pgprot(_HPAGE_TYPE_RW)
 
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
-extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable);
+extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				       pgtable_t pgtable);
 
 #define __HAVE_ARCH_PGTABLE_WITHDRAW
-extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm);
+extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 
 static inline int pmd_trans_splitting(pmd_t pmd)
 {
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index ae44d2a..9ab3224 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -920,7 +920,8 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 	}
 }
 
-void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable)
+void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pgtable)
 {
 	struct list_head *lh = (struct list_head *) pgtable;
 
@@ -934,7 +935,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable)
 	mm->pmd_huge_pte = pgtable;
 }
 
-pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm)
+pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
 	struct list_head *lh;
 	pgtable_t pgtable;
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 08fcce9..4c86de2 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -853,10 +853,11 @@ extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 				 pmd_t *pmd);
 
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
-extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable);
+extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				       pgtable_t pgtable);
 
 #define __HAVE_ARCH_PGTABLE_WITHDRAW
-extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm);
+extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 #endif
 
 /* Encode and de-code a swap entry */
diff --git a/arch/sparc/mm/tlb.c b/arch/sparc/mm/tlb.c
index ba6ae7f..0a8ac2a 100644
--- a/arch/sparc/mm/tlb.c
+++ b/arch/sparc/mm/tlb.c
@@ -157,7 +157,8 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 	}
 }
 
-void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable)
+void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pgtable)
 {
 	struct list_head *lh = (struct list_head *) pgtable;
 
@@ -171,7 +172,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable)
 	mm->pmd_huge_pte = pgtable;
 }
 
-pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm)
+pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
 	struct list_head *lh;
 	pgtable_t pgtable;
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index bfd8768..7250645 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -163,11 +163,12 @@ extern void pmdp_splitting_flush(struct vm_area_struct *vma,
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
-extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable);
+extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				       pgtable_t pgtable);
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_WITHDRAW
-extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm);
+extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_INVALIDATE
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 78bd84f..84f3180 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -735,7 +735,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		 */
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
-		pgtable_trans_huge_deposit(mm, pgtable);
+		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		mm->nr_ptes++;
 		spin_unlock(&mm->page_table_lock);
@@ -777,7 +777,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	entry = pmd_wrprotect(entry);
 	entry = pmd_mkhuge(entry);
 	set_pmd_at(mm, haddr, pmd, entry);
-	pgtable_trans_huge_deposit(mm, pgtable);
+	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	mm->nr_ptes++;
 	return true;
 }
@@ -922,7 +922,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
-	pgtable_trans_huge_deposit(dst_mm, pgtable);
+	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 	dst_mm->nr_ptes++;
 
 	ret = 0;
@@ -992,7 +992,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	pmdp_clear_flush(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
-	pgtable = pgtable_trans_huge_withdraw(mm);
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
@@ -1087,10 +1087,10 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		goto out_free_pages;
 	VM_BUG_ON(!PageHead(page));
 
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmdp_clear_flush(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
-	pgtable = pgtable_trans_huge_withdraw(mm);
 	pmd_populate(mm, &_pmd, pgtable);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
@@ -1363,7 +1363,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
-		pgtable = pgtable_trans_huge_withdraw(tlb->mm);
+		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		if (is_huge_zero_pmd(orig_pmd)) {
@@ -1695,7 +1695,7 @@ static int __split_huge_page_map(struct page *page,
 	pmd = page_check_address_pmd(page, mm, address,
 				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
 	if (pmd) {
-		pgtable = pgtable_trans_huge_withdraw(mm);
+		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 		pmd_populate(mm, &_pmd, pgtable);
 
 		haddr = address;
@@ -2352,7 +2352,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	page_add_new_anon_rmap(new_page, vma, address);
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
-	pgtable_trans_huge_deposit(mm, pgtable);
+	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	spin_unlock(&mm->page_table_lock);
 
 	*hpage = NULL;
@@ -2658,7 +2658,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	pmdp_clear_flush(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
-	pgtable = pgtable_trans_huge_withdraw(mm);
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 0c8323f..e1a6e4f 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -124,7 +124,8 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable)
+void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pgtable)
 {
 	assert_spin_locked(&mm->page_table_lock);
 
@@ -141,7 +142,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pgtable_t pgtable)
 #ifndef __HAVE_ARCH_PGTABLE_WITHDRAW
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* no "address" argument so destroys page coloring of some arch */
-pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm)
+pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
 	pgtable_t pgtable;
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
