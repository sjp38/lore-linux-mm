Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A79A6B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:16:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b83so5049176pfl.6
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:16:39 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f13si4641667pgr.65.2017.08.07.07.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 07:16:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 12/13] x86/xen: Allow XEN_PV and XEN_PVH to be enabled with X86_5LEVEL
Date: Mon,  7 Aug 2017 17:14:50 +0300
Message-Id: <20170807141451.80934-13-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
References: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Juergen Gross <jgross@suse.com>

With boot-time switching between paging modes, XEN_PV and XEN_PVH can be
boot into 4-level paging mode.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Juergen Gross <jgross@suse.com>
---
 arch/x86/kernel/head_64.S | 12 ++++++------
 arch/x86/xen/Kconfig      |  5 -----
 arch/x86/xen/mmu_pv.c     | 21 +++++++++++++++++++++
 3 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index ebdcb08a91cb..9de244aa72fd 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -37,12 +37,12 @@
  *
  */
 
+#define l4_index(x)	(((x) >> 39) & 511)
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
-#if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
-PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE48)
-PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
-#endif
+L4_PAGE_OFFSET = l4_index(__PAGE_OFFSET_BASE48)
+L4_START_KERNEL = l4_index(__START_KERNEL_map)
+
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
 
 	.text
@@ -363,9 +363,9 @@ NEXT_PAGE(early_dynamic_pgts)
 #if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
 NEXT_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
-	.org    init_top_pgt + PGD_PAGE_OFFSET*8, 0
+	.org    init_top_pgt + L4_PAGE_OFFSET*8, 0
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
-	.org    init_top_pgt + PGD_START_KERNEL*8, 0
+	.org    init_top_pgt + L4_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
 	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 
diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index 1ecd419811a2..027987638e98 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -17,9 +17,6 @@ config XEN_PV
 	bool "Xen PV guest support"
 	default y
 	depends on XEN
-	# XEN_PV is not ready to work with 5-level paging.
-	# Changes to hypervisor are also required.
-	depends on !X86_5LEVEL
 	select XEN_HAVE_PVMMU
 	select XEN_HAVE_VPMU
 	help
@@ -78,6 +75,4 @@ config XEN_DEBUG_FS
 config XEN_PVH
 	bool "Support for running as a PVH guest"
 	depends on XEN && XEN_PVHVM && ACPI
-	# Pre-built page tables are not ready to handle 5-level paging.
-	depends on !X86_5LEVEL
 	def_bool n
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index bc5fddd64217..55b529c36f16 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -558,6 +558,22 @@ static void xen_set_p4d(p4d_t *ptr, p4d_t val)
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
 }
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+__visible p4dval_t xen_p4d_val(p4d_t p4d)
+{
+	return pte_mfn_to_pfn(p4d.p4d);
+}
+PV_CALLEE_SAVE_REGS_THUNK(xen_p4d_val);
+
+__visible p4d_t xen_make_p4d(p4dval_t p4d)
+{
+	p4d = pte_pfn_to_mfn(p4d);
+
+	return native_make_p4d(p4d);
+}
+PV_CALLEE_SAVE_REGS_THUNK(xen_make_p4d);
+#endif  /* CONFIG_PGTABLE_LEVELS >= 5 */
 #endif	/* CONFIG_X86_64 */
 
 static int xen_pmd_walk(struct mm_struct *mm, pmd_t *pmd,
@@ -2430,6 +2446,11 @@ static const struct pv_mmu_ops xen_mmu_ops __initconst = {
 
 	.alloc_pud = xen_alloc_pmd_init,
 	.release_pud = xen_release_pmd_init,
+
+#if CONFIG_PGTABLE_LEVELS >= 5
+	.p4d_val = PV_CALLEE_SAVE(xen_p4d_val),
+	.make_p4d = PV_CALLEE_SAVE(xen_make_p4d),
+#endif
 #endif	/* CONFIG_X86_64 */
 
 	.activate_mm = xen_activate_mm,
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
