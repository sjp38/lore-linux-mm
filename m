Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 675F36B0080
	for <linux-mm@kvack.org>; Wed, 13 May 2015 17:25:43 -0400 (EDT)
Received: by oiko83 with SMTP id o83so41833526oik.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 14:25:43 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id l125si11359808oia.16.2015.05.13.14.25.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 14:25:42 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v9 9/10] x86, mm, pat: Refactor !pat_enabled handling
Date: Wed, 13 May 2015 15:05:50 -0600
Message-Id: <1431551151-19124-10-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

This patch refactors the !pat_enabled code paths and integrates
them into the PAT abstraction code.  The PAT table is emulated by
corresponding to the two cache attribute bits, PWT (Write Through)
and PCD (Cache Disable).  The emulated PAT table is the same as the
BIOS default setup when the system has PAT but the "nopat" boot
option is specified.  The emulated PAT table is also used when
MSR_IA32_CR_PAT returns 0 (9d34cfdf4).

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/mm/init.c     |    6 ++-
 arch/x86/mm/iomap_32.c |   12 +++----
 arch/x86/mm/ioremap.c  |   10 +-----
 arch/x86/mm/pageattr.c |    6 ---
 arch/x86/mm/pat.c      |   85 ++++++++++++++++++++++++++++--------------------
 5 files changed, 61 insertions(+), 58 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 1d55318..8533b46 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -40,7 +40,7 @@
  */
 uint16_t __cachemode2pte_tbl[_PAGE_CACHE_MODE_NUM] = {
 	[_PAGE_CACHE_MODE_WB      ]	= 0         | 0        ,
-	[_PAGE_CACHE_MODE_WC      ]	= _PAGE_PWT | 0        ,
+	[_PAGE_CACHE_MODE_WC      ]	= 0         | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC_MINUS]	= 0         | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC      ]	= _PAGE_PWT | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_WT      ]	= 0         | _PAGE_PCD,
@@ -50,11 +50,11 @@ EXPORT_SYMBOL(__cachemode2pte_tbl);
 
 uint8_t __pte2cachemode_tbl[8] = {
 	[__pte2cm_idx( 0        | 0         | 0        )] = _PAGE_CACHE_MODE_WB,
-	[__pte2cm_idx(_PAGE_PWT | 0         | 0        )] = _PAGE_CACHE_MODE_WC,
+	[__pte2cm_idx(_PAGE_PWT | 0         | 0        )] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx( 0        | _PAGE_PCD | 0        )] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PWT | _PAGE_PCD | 0        )] = _PAGE_CACHE_MODE_UC,
 	[__pte2cm_idx( 0        | 0         | _PAGE_PAT)] = _PAGE_CACHE_MODE_WB,
-	[__pte2cm_idx(_PAGE_PWT | 0         | _PAGE_PAT)] = _PAGE_CACHE_MODE_WC,
+	[__pte2cm_idx(_PAGE_PWT | 0         | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(0         | _PAGE_PCD | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC_MINUS,
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
index ae8c284..a86a199 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -262,11 +262,8 @@ EXPORT_SYMBOL(ioremap_nocache);
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
 
@@ -282,11 +279,8 @@ EXPORT_SYMBOL(ioremap_wc);
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
index a4d39cc..e6918fb 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1578,9 +1578,6 @@ int set_memory_wc(unsigned long addr, int numpages)
 {
 	int ret;
 
-	if (!pat_enabled)
-		return set_memory_uc(addr, numpages);
-
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 		_PAGE_CACHE_MODE_WC, NULL);
 	if (ret)
@@ -1609,9 +1606,6 @@ int set_memory_wt(unsigned long addr, int numpages)
 {
 	int ret;
 
-	if (!pat_enabled)
-		return set_memory_uc(addr, numpages);
-
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 			      _PAGE_CACHE_MODE_WT, NULL);
 	if (ret)
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index ed191e0..7694073 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -182,7 +182,11 @@ void pat_init_cache_modes(void)
 	char pat_msg[33];
 	u64 pat;
 
-	rdmsrl(MSR_IA32_CR_PAT, pat);
+	if (pat_enabled)
+		rdmsrl(MSR_IA32_CR_PAT, pat);
+	else
+		pat = boot_pat_state;
+
 	pat_msg[32] = 0;
 	for (i = 7; i >= 0; i--) {
 		cache = pat_get_cache_mode((pat >> (i * 8)) & 7,
@@ -200,28 +204,58 @@ void pat_init(void)
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
+	/* Boot CPU check */
+	if (pat_enabled && !boot_pat_state) {
+		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
+		if (!boot_pat_state)
+			pat_disable("PAT read returns always zero, disabled.");
+
+	}
+
+	if (!pat_enabled) {
+		/*
+		 * No PAT. Emulate the PAT table that corresponds to the two
+		 * cache bits, PWT (Write Through) and PCD (Cache Disable).
+		 * This setup is the same as the BIOS default setup when the
+		 * system has PAT but the "nopat" boot option is specified.
+		 * This emulated PAT table is also used when MSR_IA32_CR_PAT
+		 * returns 0.
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
@@ -275,16 +309,8 @@ void pat_init(void)
 		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
 	}
 
-	/* Boot CPU check */
-	if (!boot_pat_state) {
-		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
-		if (!boot_pat_state) {
-			pat_disable("PAT read returns always zero, disabled.");
-			return;
-		}
-	}
-
-	wrmsrl(MSR_IA32_CR_PAT, pat);
+	if (pat_enabled)
+		wrmsrl(MSR_IA32_CR_PAT, pat);
 
 	if (boot_cpu)
 		pat_init_cache_modes();
@@ -453,13 +479,8 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
 	BUG_ON(start >= end); /* end is exclusive */
 
 	if (!pat_enabled) {
-		/* WB and UC- are the only types supported without PAT */
-		if (new_type) {
-			if (req_type == _PAGE_CACHE_MODE_WB)
-				*new_type = _PAGE_CACHE_MODE_WB;
-			else
-				*new_type = _PAGE_CACHE_MODE_UC_MINUS;
-		}
+		if (new_type)
+			*new_type = req_type;
 		return 0;
 	}
 
@@ -958,21 +979,15 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
