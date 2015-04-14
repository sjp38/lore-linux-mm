Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f43.google.com (mail-vn0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC1106B007D
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:57:05 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so8119044vnb.13
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:57:05 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g50si1185714yhd.85.2015.04.14.13.56.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 13:56:47 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 11/11] mm: debug: use VM_BUG() to help with debug output
Date: Tue, 14 Apr 2015 16:56:33 -0400
Message-Id: <1429044993-1677-12-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

This shows how we can use VM_BUG() to improve output in various
common places.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 arch/arm/mm/mmap.c               |    2 +-
 arch/frv/mm/elf-fdpic.c          |    4 ++--
 arch/mips/mm/gup.c               |    4 ++--
 arch/parisc/kernel/sys_parisc.c  |    2 +-
 arch/powerpc/mm/hugetlbpage.c    |    2 +-
 arch/powerpc/mm/pgtable_64.c     |    4 ++--
 arch/s390/mm/gup.c               |    2 +-
 arch/s390/mm/mmap.c              |    2 +-
 arch/s390/mm/pgtable.c           |    6 +++---
 arch/sh/mm/mmap.c                |    2 +-
 arch/sparc/kernel/sys_sparc_64.c |    4 ++--
 arch/sparc/mm/gup.c              |    2 +-
 arch/sparc/mm/hugetlbpage.c      |    4 ++--
 arch/tile/mm/hugetlbpage.c       |    2 +-
 arch/x86/kernel/sys_x86_64.c     |    2 +-
 arch/x86/mm/hugetlbpage.c        |    2 +-
 arch/x86/mm/pgtable.c            |    6 +++---
 mm/huge_memory.c                 |    4 ++--
 mm/mmap.c                        |    2 +-
 mm/pgtable-generic.c             |    8 ++++----
 20 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 407dc78..6767df7 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -159,7 +159,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = mm->mmap_base;
 		info.high_limit = TASK_SIZE;
diff --git a/arch/frv/mm/elf-fdpic.c b/arch/frv/mm/elf-fdpic.c
index 836f147..6ae5497 100644
--- a/arch/frv/mm/elf-fdpic.c
+++ b/arch/frv/mm/elf-fdpic.c
@@ -88,7 +88,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
 		goto success;
-	VM_BUG_ON(addr != -ENOMEM);
+	VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 
 	/* search from just above the WorkRAM area to the top of memory */
 	info.low_limit = PAGE_ALIGN(0x80000000);
@@ -96,7 +96,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
 		goto success;
-	VM_BUG_ON(addr != -ENOMEM);
+	VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 
 #if 0
 	printk("[area] l=%lx (ENOMEM) f='%s'\n",
diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 349995d..364e27b 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -85,7 +85,7 @@ static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long end,
 	head = pte_page(pte);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON(compound_head(page) != head);
+		VM_BUG(compound_head(page) != head, "%pZp\n%pZp", page, head);
 		pages[*nr] = page;
 		if (PageTail(page))
 			get_huge_page_tail(page);
@@ -151,7 +151,7 @@ static int gup_huge_pud(pud_t pud, unsigned long addr, unsigned long end,
 	head = pte_page(pte);
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON(compound_head(page) != head);
+		VM_BUG(compound_head(page) != head, "%pZp\n%pZp", page, head);
 		pages[*nr] = page;
 		if (PageTail(page))
 			get_huge_page_tail(page);
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index e1ffea2..845823c 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -187,7 +187,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
 		goto found_addr;
-	VM_BUG_ON(addr != -ENOMEM);
+	VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 
 	/*
 	 * A failed mmap() very likely causes application failure,
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index fa9d5c2..8e8834c 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -1062,7 +1062,7 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
 	tail = page;
 	do {
-		VM_BUG_ON(compound_head(page) != head);
+		VM_BUG(compound_head(page) != head, "%pZp\n%pZp", page, head);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 59daa5e..b33bc22 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -559,7 +559,7 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 {
 	pmd_t pmd;
 
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 	if (pmd_trans_huge(*pmdp)) {
 		pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
 	} else {
@@ -627,7 +627,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma,
 {
 	unsigned long old, tmp;
 
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 
 #ifdef CONFIG_DEBUG_VM
 	WARN_ON(!pmd_trans_huge(*pmdp));
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 1eb41bb..2ad6ba0 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -66,7 +66,7 @@ static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	tail = page;
 	do {
-		VM_BUG_ON(compound_head(page) != head);
+		VM_BUG(compound_head(page) != head, "%pZp\n%pZp", page, head);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index 6e552af..178eb32 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -167,7 +167,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 33f5894..e16bf2c 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -1389,7 +1389,7 @@ EXPORT_SYMBOL_GPL(gmap_test_and_clear_dirty);
 int pmdp_clear_flush_young(struct vm_area_struct *vma, unsigned long address,
 			   pmd_t *pmdp)
 {
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 	/* No need to flush TLB
 	 * On s390 reference bits are in storage key and never in TLB */
 	return pmdp_test_and_clear_young(vma, address, pmdp);
@@ -1399,7 +1399,7 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 			  unsigned long address, pmd_t *pmdp,
 			  pmd_t entry, int dirty)
 {
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 
 	entry = pmd_mkyoung(entry);
 	if (dirty)
@@ -1419,7 +1419,7 @@ static void pmdp_splitting_flush_sync(void *arg)
 void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 			  pmd_t *pmdp)
 {
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 	if (!test_and_set_bit(_SEGMENT_ENTRY_SPLIT_BIT,
 			      (unsigned long *) pmdp)) {
 		/* need to serialize against gup-fast (IRQ disabled) */
diff --git a/arch/sh/mm/mmap.c b/arch/sh/mm/mmap.c
index 6777177..f30fd96 100644
--- a/arch/sh/mm/mmap.c
+++ b/arch/sh/mm/mmap.c
@@ -132,7 +132,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 30e7ddb..a77210d 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -131,7 +131,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	addr = vm_unmapped_area(&info);
 
 	if ((addr & ~PAGE_MASK) && task_size > VA_EXCLUDE_END) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.low_limit = VA_EXCLUDE_END;
 		info.high_limit = task_size;
 		addr = vm_unmapped_area(&info);
@@ -200,7 +200,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = STACK_TOP32;
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 2e5c4fc..9d92335 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -84,7 +84,7 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	tail = page;
 	do {
-		VM_BUG_ON(compound_head(page) != head);
+		VM_BUG(compound_head(page) != head, "%pZp\n%pZp", page, head);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 4242eab..463214e 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -42,7 +42,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *filp,
 	addr = vm_unmapped_area(&info);
 
 	if ((addr & ~PAGE_MASK) && task_size > VA_EXCLUDE_END) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.low_limit = VA_EXCLUDE_END;
 		info.high_limit = task_size;
 		addr = vm_unmapped_area(&info);
@@ -79,7 +79,7 @@ hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = STACK_TOP32;
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 8416240..e46dab5 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -205,7 +205,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 10e0272..9737762 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -203,7 +203,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
 		return addr;
-	VM_BUG_ON(addr != -ENOMEM);
+	VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 
 bottomup:
 	/*
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 42982b2..ae468ee 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -111,7 +111,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 3d6edea..7ec9841 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -427,7 +427,7 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 {
 	int changed = !pmd_same(*pmdp, entry);
 
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 
 	if (changed && dirty) {
 		*pmdp = entry;
@@ -501,7 +501,7 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 {
 	int young;
 
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 
 	young = pmdp_test_and_clear_young(vma, address, pmdp);
 	if (young)
@@ -514,7 +514,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma,
 			  unsigned long address, pmd_t *pmdp)
 {
 	int set;
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 	set = !test_and_set_bit(_PAGE_BIT_SPLITTING,
 				(unsigned long *)pmdp);
 	if (set) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cda190f..ccc8186 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2488,7 +2488,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t gfp;
 
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 
 	/* Only allocate from the target node */
 	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
@@ -2620,7 +2620,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	int node = NUMA_NO_NODE;
 	bool writable = false, referenced = false;
 
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd)
diff --git a/mm/mmap.c b/mm/mmap.c
index 311a795..5439e8e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1977,7 +1977,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * allocations.
 	 */
 	if (addr & ~PAGE_MASK) {
-		VM_BUG_ON(addr != -ENOMEM);
+		VM_BUG(addr != -ENOMEM, "addr = %lu\n", addr);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index c25f94b..97327c3 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -64,7 +64,7 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	int changed = !pmd_same(*pmdp, entry);
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 	if (changed) {
 		set_pmd_at(vma->vm_mm, address, pmdp, entry);
 		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
@@ -95,7 +95,7 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 {
 	int young;
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 #else
 	BUG();
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -125,7 +125,7 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 		       pmd_t *pmdp)
 {
 	pmd_t pmd;
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
@@ -139,7 +139,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 			  pmd_t *pmdp)
 {
 	pmd_t pmd = pmd_mksplitting(*pmdp);
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG(address & ~HPAGE_PMD_MASK, "address = %lu\n", address);
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
 	/* tlb flush only to serialize against gup-fast */
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
