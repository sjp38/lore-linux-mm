Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DEECB6B0397
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:37:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y62so6651199pfd.17
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:37:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 60si12888577plb.284.2017.04.05.06.37.54
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:37:55 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2 1/9] mm/hugetlb: add size parameter to huge_pte_offset()
Date: Wed,  5 Apr 2017 14:37:14 +0100
Message-Id: <20170405133722.6406-2-punit.agrawal@arm.com>
In-Reply-To: <20170405133722.6406-1-punit.agrawal@arm.com>
References: <20170405133722.6406-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, mark.rutland@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

A poisoned or migrated hugepage is stored as a swap entry in the page
tables. On architectures that support hugepages consisting of contiguous
page table entries (such as on arm64) this leads to ambiguity in
determining the page table entry to return in huge_pte_offset() when a
poisoned entry is encountered.

Let's remove the ambiguity by adding a size parameter to convey
additional information about the requested address. Also fixup the
definition/usage of huge_pte_offset() throughout the tree.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: James Hogan <james.hogan@imgtec.com> (odd fixer:METAG ARCHITECTURE)
Cc: Ralf Baechle <ralf@linux-mips.org> (supporter:MIPS)
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Steve Capper <steve.capper@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 arch/arm64/mm/hugetlbpage.c   |  3 ++-
 arch/ia64/mm/hugetlbpage.c    |  4 ++--
 arch/metag/mm/hugetlbpage.c   |  3 ++-
 arch/mips/mm/hugetlbpage.c    |  3 ++-
 arch/parisc/mm/hugetlbpage.c  |  3 ++-
 arch/powerpc/mm/hugetlbpage.c |  2 +-
 arch/s390/mm/hugetlbpage.c    |  3 ++-
 arch/sh/mm/hugetlbpage.c      |  3 ++-
 arch/sparc/mm/hugetlbpage.c   |  3 ++-
 arch/tile/mm/hugetlbpage.c    |  3 ++-
 arch/x86/mm/hugetlbpage.c     |  2 +-
 fs/userfaultfd.c              |  7 +++++--
 include/linux/hugetlb.h       |  5 +++--
 mm/hugetlb.c                  | 23 ++++++++++++++---------
 mm/page_vma_mapped.c          |  3 ++-
 mm/pagewalk.c                 |  3 ++-
 16 files changed, 46 insertions(+), 27 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index e2106932daa0..1bc08ae49e6a 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -189,7 +189,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 85de86d36fdf..ae35140332f7 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -44,7 +44,7 @@ huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
 }
 
 pte_t *
-huge_pte_offset (struct mm_struct *mm, unsigned long addr)
+huge_pte_offset (struct mm_struct *mm, unsigned long addr, unsigned long sz)
 {
 	unsigned long taddr = htlbpage_to_page(addr);
 	pgd_t *pgd;
@@ -92,7 +92,7 @@ struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr, int writ
 	if (REGION_NUMBER(addr) != RGN_HPAGE)
 		return ERR_PTR(-EINVAL);
 
-	ptep = huge_pte_offset(mm, addr);
+	ptep = huge_pte_offset(mm, addr, HPAGE_SIZE);
 	if (!ptep || pte_none(*ptep))
 		return NULL;
 	page = pte_page(*ptep);
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index db1b7da91e4f..67fd53e2935a 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -74,7 +74,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
index 74aa6f62468f..cef152234312 100644
--- a/arch/mips/mm/hugetlbpage.c
+++ b/arch/mips/mm/hugetlbpage.c
@@ -36,7 +36,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr,
+		       unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/parisc/mm/hugetlbpage.c b/arch/parisc/mm/hugetlbpage.c
index aa50ac090e9b..5eb8f633b282 100644
--- a/arch/parisc/mm/hugetlbpage.c
+++ b/arch/parisc/mm/hugetlbpage.c
@@ -69,7 +69,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 8c3389cbcd12..ef36ad6c8cfe 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -55,7 +55,7 @@ static unsigned nr_gpages;
 
 #define hugepd_none(hpd)	(hpd_val(hpd) == 0)
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, unsigned long sz)
 {
 	/* Only called for hugetlbfs pages, hence can ignore THP */
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 9b4050caa4e9..ae23afc18493 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -176,7 +176,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return (pte_t *) pmdp;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgdp;
 	pud_t *pudp;
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
index cc948db74878..d2412d2d6462 100644
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -42,7 +42,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 323bc6b6e3ad..dea90a98a869 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -270,7 +270,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index cb10153b5c9f..1f0993945521 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -102,7 +102,8 @@ static pte_t *get_pte(pte_t *base, int index, int level)
 	return ptep;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index c5066a260803..7ee3fa2157f9 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -31,7 +31,7 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 	if (!vma || !is_vm_hugetlb_page(vma))
 		return ERR_PTR(-EINVAL);
 
-	pte = huge_pte_offset(mm, address);
+	pte = huge_pte_offset(mm, address, vma_mmu_pagesize(vma));
 
 	/* hugetlb should be locked, and hence, prefaulted */
 	WARN_ON(!pte || pte_none(*pte));
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1d227b0fcf49..f2711ae085f7 100644
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
+	pte = huge_pte_offset(mm, address, vma_mmu_pagesize(vma));
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
index b857fc8cc2ec..23010a3b2047 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -113,7 +113,8 @@ extern struct list_head huge_boot_pages;
 
 pte_t *huge_pte_alloc(struct mm_struct *mm,
 			unsigned long addr, unsigned long sz);
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
@@ -157,7 +158,7 @@ static inline void hugetlb_show_meminfo(void)
 #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
 #define hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
 				src_addr, pagep)	({ BUG(); 0; })
-#define huge_pte_offset(mm, address)	0
+#define huge_pte_offset(mm, address, sz)	0
 static inline int dequeue_hwpoisoned_huge_page(struct page *page)
 {
 	return 0;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e5828875f7bb..0e4d1fb3122f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3233,7 +3233,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
-		src_pte = huge_pte_offset(src, addr);
+		src_pte = huge_pte_offset(src, addr, sz);
 		if (!src_pte)
 			continue;
 		dst_pte = huge_pte_alloc(dst, addr, sz);
@@ -3317,7 +3317,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	address = start;
 	for (; address < end; address += sz) {
-		ptep = huge_pte_offset(mm, address);
+		ptep = huge_pte_offset(mm, address, sz);
 		if (!ptep)
 			continue;
 
@@ -3535,7 +3535,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			unmap_ref_private(mm, vma, old_page, address);
 			BUG_ON(huge_pte_none(pte));
 			spin_lock(ptl);
-			ptep = huge_pte_offset(mm, address & huge_page_mask(h));
+			ptep = huge_pte_offset(mm, address & huge_page_mask(h),
+					       huge_page_size(h));
 			if (likely(ptep &&
 				   pte_same(huge_ptep_get(ptep), pte)))
 				goto retry_avoidcopy;
@@ -3574,7 +3575,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * before the page tables are altered
 	 */
 	spin_lock(ptl);
-	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
+	ptep = huge_pte_offset(mm, address & huge_page_mask(h),
+			       huge_page_size(h));
 	if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
 		ClearPagePrivate(new_page);
 
@@ -3861,7 +3863,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	address &= huge_page_mask(h);
 
-	ptep = huge_pte_offset(mm, address);
+	ptep = huge_pte_offset(mm, address, huge_page_size(h));
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
@@ -4118,7 +4120,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 *
 		 * Note that page table lock is not held when pte is null.
 		 */
-		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
+		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h),
+				      huge_page_size(h));
 		if (pte)
 			ptl = huge_pte_lock(h, mm, pte);
 		absent = !pte || huge_pte_none(huge_ptep_get(pte));
@@ -4252,7 +4255,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
-		ptep = huge_pte_offset(mm, address);
+		ptep = huge_pte_offset(mm, address, huge_page_size(h));
 		if (!ptep)
 			continue;
 		ptl = huge_pte_lock(h, mm, ptep);
@@ -4516,7 +4519,8 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 
 		saddr = page_table_shareable(svma, vma, addr, idx);
 		if (saddr) {
-			spte = huge_pte_offset(svma->vm_mm, saddr);
+			spte = huge_pte_offset(svma->vm_mm, saddr,
+					       vma_mmu_pagesize(svma));
 			if (spte) {
 				get_page(virt_to_page(spte));
 				break;
@@ -4612,7 +4616,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	return pte;
 }
 
-pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+pte_t *huge_pte_offset(struct mm_struct *mm,
+		       unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	p4d_t *p4d;
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index c4c9def8ffea..7d7b5949df3a 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -120,7 +120,8 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 
 	if (unlikely(PageHuge(pvmw->page))) {
 		/* when pud is not present, pte will be NULL */
-		pvmw->pte = huge_pte_offset(mm, pvmw->address);
+		pvmw->pte = huge_pte_offset(mm, pvmw->address,
+					    PAGE_SIZE << compound_order(page));
 		if (!pvmw->pte)
 			return false;
 
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 60f7856e508f..1a4197965415 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -180,12 +180,13 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 	struct hstate *h = hstate_vma(vma);
 	unsigned long next;
 	unsigned long hmask = huge_page_mask(h);
+	unsigned long sz = huge_page_size(h);
 	pte_t *pte;
 	int err = 0;
 
 	do {
 		next = hugetlb_entry_end(h, addr, end);
-		pte = huge_pte_offset(walk->mm, addr & hmask);
+		pte = huge_pte_offset(walk->mm, addr & hmask, sz);
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
