Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9881B6B00C2
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:18:55 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id wp18so11614298obc.2
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 14:18:55 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id z128si1794299oif.107.2014.11.04.14.18.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 14:18:54 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 6/8] x86, mm, pat: Refactor !pat_enabled handling
Date: Tue,  4 Nov 2014 15:04:36 -0700
Message-Id: <1415138678-22958-7-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
References: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch refactors the !pat_enabled handling code and integrates
this case into the PAT abstraction code. The PAT table is emulated
by corresponding to the two cache attribute bits, PWT (Write Through)
and PCD (Cache Disable). The emulated PAT table is also the same as
the BIOS default setup in case the system has PAT but "nopat" boot
option is specified.

As a result of this change, cache aliasing is checked for all cases
including !pat_enabled.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/mm/init.c     |    6 ++-
 arch/x86/mm/iomap_32.c |   12 +++---
 arch/x86/mm/ioremap.c  |   10 +----
 arch/x86/mm/pageattr.c |    3 --
 arch/x86/mm/pat.c      |   92 ++++++++++++++++++++----------------------------
 5 files changed, 50 insertions(+), 73 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 82b41d5..2e147c8 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -37,7 +37,7 @@
  */
 uint16_t __cachemode2pte_tbl[_PAGE_CACHE_MODE_NUM] = {
 	[_PAGE_CACHE_MODE_WB]		= 0,
-	[_PAGE_CACHE_MODE_WC]		= _PAGE_PWT,
+	[_PAGE_CACHE_MODE_WC]		= _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC_MINUS]	= _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC]		= _PAGE_PCD | _PAGE_PWT,
 	[_PAGE_CACHE_MODE_WT]		= _PAGE_PCD,
@@ -46,11 +46,11 @@ uint16_t __cachemode2pte_tbl[_PAGE_CACHE_MODE_NUM] = {
 EXPORT_SYMBOL_GPL(__cachemode2pte_tbl);
 uint8_t __pte2cachemode_tbl[8] = {
 	[__pte2cm_idx(0)] = _PAGE_CACHE_MODE_WB,
-	[__pte2cm_idx(_PAGE_PWT)] = _PAGE_CACHE_MODE_WC,
+	[__pte2cm_idx(_PAGE_PWT)] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PCD)] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PWT | _PAGE_PCD)] = _PAGE_CACHE_MODE_UC,
 	[__pte2cm_idx(_PAGE_PAT)] = _PAGE_CACHE_MODE_WB,
-	[__pte2cm_idx(_PAGE_PWT | _PAGE_PAT)] = _PAGE_CACHE_MODE_WC,
+	[__pte2cm_idx(_PAGE_PWT | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PCD | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PWT | _PAGE_PCD | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC,
 };
diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
index 9ca35fc..2c51a2b 100644
--- a/arch/x86/mm/iomap_32.c
+++ b/arch/x86/mm/iomap_32.c
@@ -77,13 +77,13 @@ void __iomem *
 iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
 	/*
-	 * For non-PAT systems, promote PAGE_KERNEL_WC to PAGE_KERNEL_UC_MINUS.
-	 * PAGE_KERNEL_WC maps to PWT, which translates to uncached if the
-	 * MTRR is UC or WC.  UC_MINUS gets the real intention, of the
-	 * user, which is "WC if the MTRR is WC, UC if you can't do that."
+	 * For non-PAT systems, translate non-WB request to UC- just in
+	 * case the caller set the PWT bit to prot directly without using
+	 * pgprot_writecombine(). UC- translates to uncached if the MTRR
+	 * is UC or WC. UC- gets the real intention, of the user, which is
+	 * "WC if the MTRR is WC, UC if you can't do that."
 	 */
-	if (!pat_enabled && pgprot_val(prot) ==
-	    (__PAGE_KERNEL | cachemode2protval(_PAGE_CACHE_MODE_WC)))
+	if (!pat_enabled && pgprot2cachemode(prot) != _PAGE_CACHE_MODE_WB)
 		prot = __pgprot(__PAGE_KERNEL |
 				cachemode2protval(_PAGE_CACHE_MODE_UC_MINUS));
 
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index ee6e55a..24c8ded 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -257,11 +257,8 @@ EXPORT_SYMBOL(ioremap_nocache);
  */
 void __iomem *ioremap_wc(resource_size_t phys_addr, unsigned long size)
 {
-	if (pat_enabled)
-		return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WC,
+	return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WC,
 					__builtin_return_address(0));
-	else
-		return ioremap_nocache(phys_addr, size);
 }
 EXPORT_SYMBOL(ioremap_wc);
 
@@ -277,11 +274,8 @@ EXPORT_SYMBOL(ioremap_wc);
  */
 void __iomem *ioremap_wt(resource_size_t phys_addr, unsigned long size)
 {
-	if (pat_enabled)
-		return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WT,
+	return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WT,
 					__builtin_return_address(0));
-	else
-		return ioremap_nocache(phys_addr, size);
 }
 EXPORT_SYMBOL(ioremap_wt);
 
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a3a5d46..114d0b3 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1553,9 +1553,6 @@ int set_memory_wc(unsigned long addr, int numpages)
 {
 	int ret;
 
-	if (!pat_enabled)
-		return set_memory_uc(addr, numpages);
-
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 		_PAGE_CACHE_MODE_WC, NULL);
 	if (ret)
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index da7a93b..5f5b950 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -131,28 +131,48 @@ void pat_init(void)
 	bool boot_cpu = !boot_pat_state;
 	struct cpuinfo_x86 *c = &boot_cpu_data;
 
-	if (!pat_enabled)
-		return;
-
 	if (!cpu_has_pat) {
 		if (!boot_pat_state) {
 			pat_disable("PAT not supported by CPU.");
-			return;
-		} else {
+		} else if (pat_enabled) {
 			/*
 			 * If this happens we are on a secondary CPU, but
 			 * switched to PAT on the boot CPU. We have no way to
 			 * undo PAT.
 			 */
-			printk(KERN_ERR "PAT enabled, "
+			pr_err("PAT enabled, "
 			       "but not supported by secondary CPU\n");
 			BUG();
 		}
 	}
 
-	if ((c->x86_vendor == X86_VENDOR_INTEL) &&
-	    (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
-	     ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {
+	if (!pat_enabled) {
+		/*
+		 * No PAT. Emulate the PAT table by corresponding to the two
+		 * cache bits, PWT (Write Through) and PCD (Cache Disable).
+		 * This is also the same as the BIOS default setup in case
+		 * the system has PAT but "nopat" boot option is specified.
+		 *
+		 *  PTE encoding used in Linux:
+		 *       PCD
+		 *       |PWT  PAT
+		 *       ||    slot
+		 *       00    0    WB : _PAGE_CACHE_MODE_WB
+		 *       01    1    WT : _PAGE_CACHE_MODE_WT
+		 *       10    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
+		 *       11    3    UC : _PAGE_CACHE_MODE_UC
+		 *
+		 * NOTE: When WC or WP is used, it is redirected to UC- per
+		 * the default setup in __cachemode2pte_tbl[].
+		 */
+		pat = PAT(0, WB) | PAT(1, WT) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WT) | PAT(6, UC_MINUS) | PAT(7, UC);
+		if (!boot_pat_state)
+			boot_pat_state = pat;
+
+	} else if ((c->x86_vendor == X86_VENDOR_INTEL) &&
+		   (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
+		    ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {
 		/*
 		 * PAT support with the lower four entries. Intel Pentium 2,
 		 * 3, M, and 4 are affected by PAT errata, which makes the
@@ -206,11 +226,13 @@ void pat_init(void)
 		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
 	}
 
-	/* Boot CPU check */
-	if (!boot_pat_state)
-		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
+	if (pat_enabled) {
+		/* Boot CPU check */
+		if (!boot_pat_state)
+			rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
 
-	wrmsrl(MSR_IA32_CR_PAT, pat);
+		wrmsrl(MSR_IA32_CR_PAT, pat);
+	}
 
 	if (boot_cpu)
 		pat_init_cache_modes();
@@ -435,17 +457,6 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
 
 	BUG_ON(start >= end); /* end is exclusive */
 
-	if (!pat_enabled) {
-		/* WB and UC- are the only types supported without PAT */
-		if (new_type) {
-			if (req_type == _PAGE_CACHE_MODE_WB)
-				*new_type = _PAGE_CACHE_MODE_WB;
-			else
-				*new_type = _PAGE_CACHE_MODE_UC_MINUS;
-		}
-		return 0;
-	}
-
 	/* Low ISA region is always mapped WB in page table. No need to track */
 	if (x86_platform.is_untracked_pat_range(start, end)) {
 		if (new_type)
@@ -510,9 +521,6 @@ int free_memtype(u64 start, u64 end)
 	int is_range_ram;
 	struct memtype *entry;
 
-	if (!pat_enabled)
-		return 0;
-
 	/* Low ISA region is always mapped WB. No need to track */
 	if (x86_platform.is_untracked_pat_range(start, end))
 		return 0;
@@ -549,8 +557,6 @@ int free_memtype(u64 start, u64 end)
  * lookup_memtype - Looksup the memory type for a physical address
  * @paddr: physical address of which memory type needs to be looked up
  *
- * Only to be called when PAT is enabled
- *
  * Returns _PAGE_CACHE_MODE_WB, _PAGE_CACHE_MODE_WC, _PAGE_CACHE_MODE_UC_MINUS
  * or _PAGE_CACHE_MODE_UC
  */
@@ -651,16 +657,13 @@ static inline int range_is_allowed(unsigned long pfn, unsigned long size)
 	return 1;
 }
 #else
-/* This check is needed to avoid cache aliasing when PAT is enabled */
+/* This check is needed to avoid cache aliasing */
 static inline int range_is_allowed(unsigned long pfn, unsigned long size)
 {
 	u64 from = ((u64)pfn) << PAGE_SHIFT;
 	u64 to = from + size;
 	u64 cursor = from;
 
-	if (!pat_enabled)
-		return 1;
-
 	while (cursor < to) {
 		if (!devmem_is_allowed(pfn)) {
 			printk(KERN_INFO "Program %s tried to access /dev/mem between [mem %#010Lx-%#010Lx]\n",
@@ -764,9 +767,6 @@ static int reserve_pfn_range(u64 paddr, unsigned long size, pgprot_t *vma_prot,
 	 * the type requested matches the type of first page in the range.
 	 */
 	if (is_ram) {
-		if (!pat_enabled)
-			return 0;
-
 		pcm = lookup_memtype(paddr);
 		if (want_pcm != pcm) {
 			printk(KERN_WARNING "%s:%d map pfn RAM range req %s for [mem %#010Lx-%#010Lx], got %s\n",
@@ -879,9 +879,6 @@ int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 		return ret;
 	}
 
-	if (!pat_enabled)
-		return 0;
-
 	/*
 	 * For anything smaller than the vma size we set prot based on the
 	 * lookup.
@@ -907,9 +904,6 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 {
 	enum page_cache_mode pcm;
 
-	if (!pat_enabled)
-		return 0;
-
 	/* Set prot based on lookup */
 	pcm = lookup_memtype((resource_size_t)pfn << PAGE_SHIFT);
 	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
@@ -948,21 +942,15 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 
 pgprot_t pgprot_writecombine(pgprot_t prot)
 {
-	if (pat_enabled)
-		return __pgprot(pgprot_val(prot) |
+	return __pgprot(pgprot_val(prot) |
 				cachemode2protval(_PAGE_CACHE_MODE_WC));
-	else
-		return pgprot_noncached(prot);
 }
 EXPORT_SYMBOL_GPL(pgprot_writecombine);
 
 pgprot_t pgprot_writethrough(pgprot_t prot)
 {
-	if (pat_enabled)
-		return __pgprot(pgprot_val(prot) |
+	return __pgprot(pgprot_val(prot) |
 				cachemode2protval(_PAGE_CACHE_MODE_WT));
-	else
-		return pgprot_noncached(prot);
 }
 EXPORT_SYMBOL_GPL(pgprot_writethrough);
 
@@ -1041,10 +1029,8 @@ static const struct file_operations memtype_fops = {
 
 static int __init pat_memtype_list_init(void)
 {
-	if (pat_enabled) {
-		debugfs_create_file("pat_memtype_list", S_IRUSR,
+	debugfs_create_file("pat_memtype_list", S_IRUSR,
 				    arch_debugfs_dir, NULL, &memtype_fops);
-	}
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
