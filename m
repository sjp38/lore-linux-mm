Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64E666B02FD
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 13:10:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r187so12783568pfr.8
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 10:10:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u4si4440086pfj.154.2017.08.10.10.10.53
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 10:10:54 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v6 4/9] arm64: hugetlb: Add break-before-make logic for contiguous entries
Date: Thu, 10 Aug 2017 18:09:01 +0100
Message-Id: <20170810170906.30772-5-punit.agrawal@arm.com>
In-Reply-To: <20170810170906.30772-1-punit.agrawal@arm.com>
References: <20170810170906.30772-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, David Woods <dwoods@mellanox.com>, Punit Agrawal <punit.agrawal@arm.com>

From: Steve Capper <steve.capper@arm.com>


It has become apparent that one has to take special care when modifying
attributes of memory mappings that employ the contiguous bit.

Both the requirement and the architecturally correct "Break-Before-Make"
technique of updating contiguous entries can be found described in:
ARM DDI 0487A.k_iss10775, "Misprogramming of the Contiguous bit",
page D4-1762.

The huge pte accessors currently replace the attributes of contiguous
pte entries in place thus can, on certain platforms, lead to TLB
conflict aborts or even erroneous results returned from TLB lookups.

This patch adds two helper functions -

* get_clear_flush(.) - clears a contiguous entry and returns the head
  pte (whilst taking care to retain dirty bit information that could
  have been modified by DBM).

* clear_flush(.) that clears a contiguous entry

A tlb invalidate is performed to then ensure that there is no
possibility of multiple tlb entries being present for the same region.

Cc: David Woods <dwoods@mellanox.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
(Added helper clear_flush(), updated commit log, and comments cleanup)
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
Hi Mark,

I've dropped your reviewed-by tag due to the patch update. I'd
appreciate if you could take a look at the new version.

Thanks!
---
 arch/arm64/mm/hugetlbpage.c | 107 +++++++++++++++++++++++++++++++++++---------
 1 file changed, 86 insertions(+), 21 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 08deed7c71f0..d3a6713048a2 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -68,6 +68,62 @@ static int find_num_contig(struct mm_struct *mm, unsigned long addr,
 	return CONT_PTES;
 }
 
+/*
+ * Changing some bits of contiguous entries requires us to follow a
+ * Break-Before-Make approach, breaking the whole contiguous set
+ * before we can change any entries. See ARM DDI 0487A.k_iss10775,
+ * "Misprogramming of the Contiguous bit", page D4-1762.
+ *
+ * This helper performs the break step.
+ */
+static pte_t get_clear_flush(struct mm_struct *mm,
+			     unsigned long addr,
+			     pte_t *ptep,
+			     unsigned long pgsize,
+			     unsigned long ncontig)
+{
+	unsigned long i, saddr = addr;
+	struct vm_area_struct vma = { .vm_mm = mm };
+	pte_t orig_pte = huge_ptep_get(ptep);
+
+	/*
+	 * If we already have a faulting entry then we don't need
+	 * to break before make (there won't be a tlb entry cached).
+	 */
+	if (!pte_present(orig_pte))
+		return orig_pte;
+
+	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
+		pte_t pte = ptep_get_and_clear(mm, addr, ptep);
+
+		/*
+		 * If HW_AFDBM is enabled, then the HW could turn on
+		 * the dirty bit for any page in the set, so check
+		 * them all.  All hugetlb entries are already young.
+		 */
+		if (IS_ENABLED(CONFIG_ARM64_HW_AFDBM) && pte_dirty(pte))
+			orig_pte = pte_mkdirty(orig_pte);
+	}
+
+	flush_tlb_range(&vma, saddr, addr);
+	return orig_pte;
+}
+
+static void clear_flush(struct mm_struct *mm,
+			     unsigned long addr,
+			     pte_t *ptep,
+			     unsigned long pgsize,
+			     unsigned long ncontig)
+{
+	unsigned long i, saddr = addr;
+	struct vm_area_struct vma = { .vm_mm = mm };
+
+	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++)
+		pte_clear(mm, addr, ptep);
+
+	flush_tlb_range(&vma, saddr, addr);
+}
+
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 			    pte_t *ptep, pte_t pte)
 {
@@ -93,6 +149,8 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	dpfn = pgsize >> PAGE_SHIFT;
 	hugeprot = pte_pgprot(pte);
 
+	clear_flush(mm, addr, ptep, pgsize, ncontig);
+
 	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
 		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
 			 pte_val(pfn_pte(pfn, hugeprot)));
@@ -194,7 +252,7 @@ pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 			      unsigned long addr, pte_t *ptep)
 {
-	int ncontig, i;
+	int ncontig;
 	size_t pgsize;
 	pte_t orig_pte = huge_ptep_get(ptep);
 
@@ -202,17 +260,8 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 		return ptep_get_and_clear(mm, addr, ptep);
 
 	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
-	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
-		/*
-		 * If HW_AFDBM is enabled, then the HW could
-		 * turn on the dirty bit for any of the page
-		 * in the set, so check them all.
-		 */
-		if (pte_dirty(ptep_get_and_clear(mm, addr, ptep)))
-			orig_pte = pte_mkdirty(orig_pte);
-	}
 
-	return orig_pte;
+	return get_clear_flush(mm, addr, ptep, pgsize, ncontig);
 }
 
 int huge_ptep_set_access_flags(struct vm_area_struct *vma,
@@ -222,6 +271,7 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 	int ncontig, i, changed = 0;
 	size_t pgsize = 0;
 	unsigned long pfn = pte_pfn(pte), dpfn;
+	pte_t orig_pte;
 	pgprot_t hugeprot;
 
 	if (!pte_cont(pte))
@@ -229,12 +279,18 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 
 	ncontig = find_num_contig(vma->vm_mm, addr, ptep, &pgsize);
 	dpfn = pgsize >> PAGE_SHIFT;
-	hugeprot = pte_pgprot(pte);
 
-	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn) {
-		changed |= ptep_set_access_flags(vma, addr, ptep,
-				pfn_pte(pfn, hugeprot), dirty);
-	}
+	orig_pte = get_clear_flush(vma->vm_mm, addr, ptep, pgsize, ncontig);
+	if (!pte_same(orig_pte, pte))
+		changed = 1;
+
+	/* Make sure we don't lose the dirty state */
+	if (pte_dirty(orig_pte))
+		pte = pte_mkdirty(pte);
+
+	hugeprot = pte_pgprot(pte);
+	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
+		set_pte_at(vma->vm_mm, addr, ptep, pfn_pte(pfn, hugeprot));
 
 	return changed;
 }
@@ -244,6 +300,9 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
 {
 	int ncontig, i;
 	size_t pgsize;
+	pte_t pte = pte_wrprotect(huge_ptep_get(ptep)), orig_pte;
+	unsigned long pfn = pte_pfn(pte), dpfn;
+	pgprot_t hugeprot;
 
 	if (!pte_cont(*ptep)) {
 		ptep_set_wrprotect(mm, addr, ptep);
@@ -251,14 +310,21 @@ void huge_ptep_set_wrprotect(struct mm_struct *mm,
 	}
 
 	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
-	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize)
-		ptep_set_wrprotect(mm, addr, ptep);
+	dpfn = pgsize >> PAGE_SHIFT;
+
+	orig_pte = get_clear_flush(mm, addr, ptep, pgsize, ncontig);
+	if (pte_dirty(orig_pte))
+		pte = pte_mkdirty(pte);
+
+	hugeprot = pte_pgprot(pte);
+	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize, pfn += dpfn)
+		set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
 }
 
 void huge_ptep_clear_flush(struct vm_area_struct *vma,
 			   unsigned long addr, pte_t *ptep)
 {
-	int ncontig, i;
+	int ncontig;
 	size_t pgsize;
 
 	if (!pte_cont(*ptep)) {
@@ -267,8 +333,7 @@ void huge_ptep_clear_flush(struct vm_area_struct *vma,
 	}
 
 	ncontig = find_num_contig(vma->vm_mm, addr, ptep, &pgsize);
-	for (i = 0; i < ncontig; i++, ptep++, addr += pgsize)
-		ptep_clear_flush(vma, addr, ptep);
+	clear_flush(vma->vm_mm, addr, ptep, pgsize, ncontig);
 }
 
 static __init int setup_hugepagesz(char *opt)
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
