Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C98E66B0351
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:58:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q126so434228138pga.0
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 05:58:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y11si5570186pgo.307.2017.03.23.05.58.51
        for <linux-mm@kvack.org>;
        Thu, 23 Mar 2017 05:58:51 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [RFC PATCH 1/2] mm/hugetlb.c: add hstate parameter to huge_pte_offset()
Date: Thu, 23 Mar 2017 12:58:22 +0000
Message-Id: <20170323125823.429-2-punit.agrawal@arm.com>
In-Reply-To: <20170323125823.429-1-punit.agrawal@arm.com>
References: <20170323125823.429-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tyler Baicar <tbaicar@codeaurora.org>

A poisoned or migrated hugepage is stored as a swap entry in the page
tables. On architectures that support hugepages consisting of contiguous
page table entries (such as on arm64) this leads to ambiguity in
determining the right page table entry to return in huge_pte_offset()
when a poisoned entry is encountered.

Let's remove the ambiguity by adding a hstate parameter to convey
additional information about the requested address. Also fixup the
definition/usage of huge_pte_offset() throughout the tree.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/mm/hugetlbpage.c   |  2 +-
 arch/ia64/mm/hugetlbpage.c    |  4 ++--
 arch/metag/mm/hugetlbpage.c   |  2 +-
 arch/mips/mm/hugetlbpage.c    |  2 +-
 arch/parisc/mm/hugetlbpage.c  |  2 +-
 arch/powerpc/mm/hugetlbpage.c |  2 +-
 arch/s390/mm/hugetlbpage.c    |  2 +-
 arch/sh/mm/hugetlbpage.c      |  2 +-
 arch/sparc/mm/hugetlbpage.c   |  2 +-
 arch/tile/mm/hugetlbpage.c    |  2 +-
 arch/x86/mm/hugetlbpage.c     |  2 +-
 fs/userfaultfd.c              |  7 +++++--
 include/linux/hugetlb.h       |  2 +-
 mm/hugetlb.c                  | 18 +++++++++---------
 mm/page_vma_mapped.c          |  2 +-
 mm/pagewalk.c                 |  2 +-
 16 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index e2106932daa0..75d8cc3e138b 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -189,7 +189,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 85de86d36fdf..09c865be3cfe 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -44,7 +44,7 @@ huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
 }
 
 pte_t *
-huge_pte_offset (struct mm_struct *mm, unsigned long addr)
+huge_pte_offset (struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	unsigned long taddr = htlbpage_to_page(addr);
 	pgd_t *pgd;
@@ -92,7 +92,7 @@ struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr, int writ
 	if (REGION_NUMBER(addr) != RGN_HPAGE)
 		return ERR_PTR(-EINVAL);
 
-	ptep = huge_pte_offset(mm, addr);
+	ptep = huge_pte_offset(mm, addr, size_to_hstate(HPAGE_SIZE));
 	if (!ptep || pte_none(*ptep))
 		return NULL;
 	page = pte_page(*ptep);
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index db1b7da91e4f..2c3b34189d29 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -74,7 +74,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
index 74aa6f62468f..e66f47074ea4 100644
--- a/arch/mips/mm/hugetlbpage.c
+++ b/arch/mips/mm/hugetlbpage.c
@@ -36,7 +36,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/parisc/mm/hugetlbpage.c b/arch/parisc/mm/hugetlbpage.c
index aa50ac090e9b..c146ee7d80c7 100644
--- a/arch/parisc/mm/hugetlbpage.c
+++ b/arch/parisc/mm/hugetlbpage.c
@@ -69,7 +69,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 8c3389cbcd12..9fddb22c60d9 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -55,7 +55,7 @@ static unsigned nr_gpages;
 
 #define hugepd_none(hpd)	(hpd_val(hpd) == 0)
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	/* Only called for hugetlbfs pages, hence can ignore THP */
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 9b4050caa4e9..63061fcb0560 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -176,7 +176,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return (pte_t *) pmdp;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgdp;
 	pud_t *pudp;
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
index cc948db74878..94a2625b2ead 100644
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -42,7 +42,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 323bc6b6e3ad..76834a44a767 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -270,7 +270,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index cb10153b5c9f..dc434a64175d 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -102,7 +102,7 @@ static pte_t *get_pte(pte_t *base, int index, int level)
 	return ptep;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index c5066a260803..49d469fd4f07 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -31,7 +31,7 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 	if (!vma || !is_vm_hugetlb_page(vma))
 		return ERR_PTR(-EINVAL);
 
-	pte = huge_pte_offset(mm, address);
+	pte = huge_pte_offset(mm, address, hstate_vma(vma));
 
 	/* hugetlb should be locked, and hence, prefaulted */
 	WARN_ON(!pte || pte_none(*pte));
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1d227b0fcf49..dabbf6e408d1 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -214,6 +214,7 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
  * hugepmd ranges.
  */
 static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
+					 struct vm_area_struct *vma,
 					 unsigned long address,
 					 unsigned long flags,
 					 unsigned long reason)
@@ -224,7 +225,7 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
 
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
-	pte = huge_pte_offset(mm, address);
+	pte = huge_pte_offset(mm, address, hstate_vma(vma));
 	if (!pte)
 		goto out;
 
@@ -243,6 +244,7 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
 }
 #else
 static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
+					 struct vm_area_struct *vma,
 					 unsigned long address,
 					 unsigned long flags,
 					 unsigned long reason)
@@ -435,7 +437,8 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 		must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
 						  reason);
 	else
-		must_wait = userfaultfd_huge_must_wait(ctx, vmf->address,
+		must_wait = userfaultfd_huge_must_wait(ctx, vmf->vma,
+						       vmf->address,
 						       vmf->flags, reason);
 	up_read(&mm->mmap_sem);
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index b857fc8cc2ec..f374dd4eed5b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -113,7 +113,7 @@ extern struct list_head huge_boot_pages;
 
 pte_t *huge_pte_alloc(struct mm_struct *mm,
 			unsigned long addr, unsigned long sz);
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3d0aab9ee80d..5bd16c2ff67a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3233,7 +3233,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
-		src_pte = huge_pte_offset(src, addr);
+		src_pte = huge_pte_offset(src, addr, h);
 		if (!src_pte)
 			continue;
 		dst_pte = huge_pte_alloc(dst, addr, sz);
@@ -3317,7 +3317,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	address = start;
 	for (; address < end; address += sz) {
-		ptep = huge_pte_offset(mm, address);
+		ptep = huge_pte_offset(mm, address, h);
 		if (!ptep)
 			continue;
 
@@ -3535,7 +3535,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			unmap_ref_private(mm, vma, old_page, address);
 			BUG_ON(huge_pte_none(pte));
 			spin_lock(ptl);
-			ptep = huge_pte_offset(mm, address & huge_page_mask(h));
+			ptep = huge_pte_offset(mm, address & huge_page_mask(h), h);
 			if (likely(ptep &&
 				   pte_same(huge_ptep_get(ptep), pte)))
 				goto retry_avoidcopy;
@@ -3574,7 +3574,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * before the page tables are altered
 	 */
 	spin_lock(ptl);
-	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
+	ptep = huge_pte_offset(mm, address & huge_page_mask(h), h);
 	if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
 		ClearPagePrivate(new_page);
 
@@ -3861,7 +3861,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	address &= huge_page_mask(h);
 
-	ptep = huge_pte_offset(mm, address);
+	ptep = huge_pte_offset(mm, address, h);
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
@@ -4118,7 +4118,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 *
 		 * Note that page table lock is not held when pte is null.
 		 */
-		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
+		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h), h);
 		if (pte)
 			ptl = huge_pte_lock(h, mm, pte);
 		absent = !pte || huge_pte_none(huge_ptep_get(pte));
@@ -4252,7 +4252,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
-		ptep = huge_pte_offset(mm, address);
+		ptep = huge_pte_offset(mm, address, h);
 		if (!ptep)
 			continue;
 		ptl = huge_pte_lock(h, mm, ptep);
@@ -4514,7 +4514,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 
 		saddr = page_table_shareable(svma, vma, addr, idx);
 		if (saddr) {
-			spte = huge_pte_offset(svma->vm_mm, saddr);
+			spte = huge_pte_offset(svma->vm_mm, saddr, hstate_vma(svma));
 			if (spte) {
 				get_page(virt_to_page(spte));
 				break;
@@ -4610,7 +4610,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, struct hstate *h)
 {
 	pgd_t *pgd;
 	p4d_t *p4d;
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index c4c9def8ffea..566d474dbdc0 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -120,7 +120,7 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 
 	if (unlikely(PageHuge(pvmw->page))) {
 		/* when pud is not present, pte will be NULL */
-		pvmw->pte = huge_pte_offset(mm, pvmw->address);
+		pvmw->pte = huge_pte_offset(mm, pvmw->address, page_hstate(page));
 		if (!pvmw->pte)
 			return false;
 
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 60f7856e508f..8805b68d353c 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -185,7 +185,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 
 	do {
 		next = hugetlb_entry_end(h, addr, end);
-		pte = huge_pte_offset(walk->mm, addr & hmask);
+		pte = huge_pte_offset(walk->mm, addr & hmask, h);
 		if (pte && walk->hugetlb_entry)
 			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		if (err)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
