Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD086B02FD
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 10:15:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y62so21571915pfa.3
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 07:15:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 6si1955303plc.392.2017.07.18.07.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 07:15:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 10/10] x86/mm: Offset boot-time paging mode switching cost
Date: Tue, 18 Jul 2017 17:15:17 +0300
Message-Id: <20170718141517.52202-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

By this point we have functioning boot-time switching between 4- and
5-level paging mode. But naive approach comes with cost.

Numbers below are for kernel build, allmodconfig, 5 times.

CONFIG_X86_5LEVEL=n:

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

   17308719.892691      task-clock:u (msec)       #   26.772 CPUs utilized            ( +-  0.11% )
                 0      context-switches:u        #    0.000 K/sec
                 0      cpu-migrations:u          #    0.000 K/sec
       331,993,164      page-faults:u             #    0.019 M/sec                    ( +-  0.01% )
43,614,978,867,455      cycles:u                  #    2.520 GHz                      ( +-  0.01% )
39,371,534,575,126      stalled-cycles-frontend:u #   90.27% frontend cycles idle     ( +-  0.09% )
28,363,350,152,428      instructions:u            #    0.65  insn per cycle
                                                  #    1.39  stalled cycles per insn  ( +-  0.00% )
 6,316,784,066,413      branches:u                #  364.948 M/sec                    ( +-  0.00% )
   250,808,144,781      branch-misses:u           #    3.97% of all branches          ( +-  0.01% )

     646.531974142 seconds time elapsed                                          ( +-  1.15% )

CONFIG_X86_5LEVEL=y:

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

   17411536.780625      task-clock:u (msec)       #   26.426 CPUs utilized            ( +-  0.10% )
                 0      context-switches:u        #    0.000 K/sec
                 0      cpu-migrations:u          #    0.000 K/sec
       331,868,663      page-faults:u             #    0.019 M/sec                    ( +-  0.01% )
43,865,909,056,301      cycles:u                  #    2.519 GHz                      ( +-  0.01% )
39,740,130,365,581      stalled-cycles-frontend:u #   90.59% frontend cycles idle     ( +-  0.05% )
28,363,358,997,959      instructions:u            #    0.65  insn per cycle
                                                  #    1.40  stalled cycles per insn  ( +-  0.00% )
 6,316,784,937,460      branches:u                #  362.793 M/sec                    ( +-  0.00% )
   251,531,919,485      branch-misses:u           #    3.98% of all branches          ( +-  0.00% )

     658.886307752 seconds time elapsed                                          ( +-  0.92% )
The patch tries to fix the performance regression by using

!cpu_feature_enabled(X86_FEATURE_LA57) instead of p4d_folded in most
code paths. These will statically patch the target code for additional
performance.

Notable exception, where cpu_feature_enabled() wasn't used is
return_from_SYSCALL_64(). It's written in assembly and there's no easy
way to use the same approach. We can come back to this later, if
required.

Also, I had to re-write number of static inline helpers as macros.
It was needed to break header dependency loop between cpufeature.h and
pgtable_types.h.

CONFIG_X86_5LEVEL=y + the patch:

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

   17381990.268506      task-clock:u (msec)       #   26.907 CPUs utilized            ( +-  0.19% )
                 0      context-switches:u        #    0.000 K/sec
                 0      cpu-migrations:u          #    0.000 K/sec
       331,862,625      page-faults:u             #    0.019 M/sec                    ( +-  0.01% )
43,697,726,320,051      cycles:u                  #    2.514 GHz                      ( +-  0.03% )
39,480,408,690,401      stalled-cycles-frontend:u #   90.35% frontend cycles idle     ( +-  0.05% )
28,363,394,221,388      instructions:u            #    0.65  insn per cycle
                                                  #    1.39  stalled cycles per insn  ( +-  0.00% )
 6,316,794,985,573      branches:u                #  363.410 M/sec                    ( +-  0.00% )
   251,013,232,547      branch-misses:u           #    3.97% of all branches          ( +-  0.01% )

     645.991174661 seconds time elapsed                                          ( +-  1.19% )

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/misc.h         |  5 +++
 arch/x86/entry/entry_64.S               |  2 +-
 arch/x86/include/asm/paravirt.h         |  9 ++---
 arch/x86/include/asm/pgtable_64_types.h |  5 ++-
 arch/x86/include/asm/pgtable_types.h    | 67 ++++++++-------------------------
 arch/x86/kernel/head64.c                |  5 +++
 arch/x86/kernel/head_64.S               |  6 +--
 arch/x86/mm/kasan_init_64.c             |  6 +++
 8 files changed, 44 insertions(+), 61 deletions(-)

diff --git a/arch/x86/boot/compressed/misc.h b/arch/x86/boot/compressed/misc.h
index 766a5211f827..28ac72acaa31 100644
--- a/arch/x86/boot/compressed/misc.h
+++ b/arch/x86/boot/compressed/misc.h
@@ -11,6 +11,11 @@
 #undef CONFIG_PARAVIRT_SPINLOCKS
 #undef CONFIG_KASAN
 
+#ifdef CONFIG_X86_5LEVEL
+/* cpu_feature_enabled() cannot be used that early */
+#define p4d_folded __p4d_folded
+#endif
+
 #include <linux/linkage.h>
 #include <linux/screen_info.h>
 #include <linux/elf.h>
diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index 66d7a4685e1f..696ddab6d1af 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -269,7 +269,7 @@ return_from_SYSCALL_64:
 	 * depending on paging mode) in the address.
 	 */
 #ifdef CONFIG_X86_5LEVEL
-	testl	$1, p4d_folded(%rip)
+	testl	$1, __p4d_folded(%rip)
 	jnz	1f
 	shl	$(64 - 57), %rcx
 	sar	$(64 - 57), %rcx
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 511f300abd42..8febaa318aa2 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -611,11 +611,10 @@ static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
 	PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, val);
 }
 
-static inline void pgd_clear(pgd_t *pgdp)
-{
-	if (!p4d_folded)
-		set_pgd(pgdp, __pgd(0));
-}
+#define pgd_clear(pgdp) do {				\
+                if (!p4d_folded)			\
+                        set_pgd(pgdp, __pgd(0));	\
+        } while (0)
 
 #endif  /* CONFIG_PGTABLE_LEVELS == 5 */
 
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 57718303805e..b283cb29f7a3 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -20,7 +20,10 @@ typedef unsigned long	pgprotval_t;
 typedef struct { pteval_t pte; } pte_t;
 
 #ifdef CONFIG_X86_5LEVEL
-extern unsigned int p4d_folded;
+extern unsigned int __p4d_folded;
+#ifndef p4d_folded
+#define p4d_folded (!cpu_feature_enabled(X86_FEATURE_LA57))
+#endif
 #else
 #define p4d_folded 1
 #endif
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index bf9638e1ee42..d783b26e32fc 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -267,10 +267,7 @@ static inline pgdval_t native_pgd_val(pgd_t pgd)
 	return pgd.pgd;
 }
 
-static inline pgdval_t pgd_flags(pgd_t pgd)
-{
-	return native_pgd_val(pgd) & PTE_FLAGS_MASK;
-}
+#define pgd_flags(pgd) (native_pgd_val(pgd) & PTE_FLAGS_MASK)
 
 #if CONFIG_PGTABLE_LEVELS > 4
 typedef struct { p4dval_t p4d; } p4d_t;
@@ -335,57 +332,28 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 }
 #endif
 
-static inline p4dval_t p4d_pfn_mask(p4d_t p4d)
-{
-	/* No 512 GiB huge pages yet */
-	return PTE_PFN_MASK;
-}
+/* No 512 GiB huge pages yet */
+#define p4d_pfn_mask(p4d) PTE_PFN_MASK
 
-static inline p4dval_t p4d_flags_mask(p4d_t p4d)
-{
-	return ~p4d_pfn_mask(p4d);
-}
+#define p4d_flags_mask(p4d) (~p4d_pfn_mask(p4d))
 
-static inline p4dval_t p4d_flags(p4d_t p4d)
-{
-	return native_p4d_val(p4d) & p4d_flags_mask(p4d);
-}
+#define p4d_flags(p4d) (native_p4d_val(p4d) & p4d_flags_mask(p4d))
 
-static inline pudval_t pud_pfn_mask(pud_t pud)
-{
-	if (native_pud_val(pud) & _PAGE_PSE)
-		return PHYSICAL_PUD_PAGE_MASK;
-	else
-		return PTE_PFN_MASK;
-}
+#define pud_pfn_mask(pud) \
+	(native_pud_val(pud) & _PAGE_PSE ? \
+	 PHYSICAL_PUD_PAGE_MASK : PTE_PFN_MASK)
 
-static inline pudval_t pud_flags_mask(pud_t pud)
-{
-	return ~pud_pfn_mask(pud);
-}
+#define pud_flags_mask(pud) (~pud_pfn_mask(pud))
 
-static inline pudval_t pud_flags(pud_t pud)
-{
-	return native_pud_val(pud) & pud_flags_mask(pud);
-}
+#define pud_flags(pud) (native_pud_val(pud) & pud_flags_mask(pud))
 
-static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
-{
-	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return PHYSICAL_PMD_PAGE_MASK;
-	else
-		return PTE_PFN_MASK;
-}
+#define pmd_pfn_mask(pmd) \
+	(native_pmd_val(pmd) & _PAGE_PSE ? \
+	 PHYSICAL_PMD_PAGE_MASK : PTE_PFN_MASK)
 
-static inline pmdval_t pmd_flags_mask(pmd_t pmd)
-{
-	return ~pmd_pfn_mask(pmd);
-}
+#define pmd_flags_mask(pmd) (~pmd_pfn_mask(pmd))
 
-static inline pmdval_t pmd_flags(pmd_t pmd)
-{
-	return native_pmd_val(pmd) & pmd_flags_mask(pmd);
-}
+#define pmd_flags(pmd) (native_pmd_val(pmd) & pmd_flags_mask(pmd))
 
 static inline pte_t native_make_pte(pteval_t val)
 {
@@ -397,10 +365,7 @@ static inline pteval_t native_pte_val(pte_t pte)
 	return pte.pte;
 }
 
-static inline pteval_t pte_flags(pte_t pte)
-{
-	return native_pte_val(pte) & PTE_FLAGS_MASK;
-}
+#define pte_flags(pte) (native_pte_val(pte) & PTE_FLAGS_MASK)
 
 #define pgprot_val(x)	((x).pgprot)
 #define __pgprot(x)	((pgprot_t) { (x) } )
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 4d06df5f317f..be8847042840 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -30,6 +30,11 @@
 #include <asm/microcode.h>
 #include <asm/kasan.h>
 
+#ifdef CONFIG_X86_5LEVEL
+#undef p4d_folded
+#define p4d_folded __p4d_folded
+#endif
+
 /*
  * Manage page tables very early on.
  */
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 5e046a0225d9..7ebb56e99389 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -105,7 +105,7 @@ ENTRY(secondary_startup_64)
 	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 #ifdef CONFIG_X86_5LEVEL
-	testl	$1, p4d_folded(%rip)
+	testl	$1, __p4d_folded(%rip)
 	jnz	1f
 	orl	$X86_CR4_LA57, %ecx
 1:
@@ -417,9 +417,9 @@ ENTRY(phys_base)
 EXPORT_SYMBOL(phys_base)
 
 #ifdef CONFIG_X86_5LEVEL
-ENTRY(p4d_folded)
+ENTRY(__p4d_folded)
 	.word	1
-EXPORT_SYMBOL(p4d_folded)
+EXPORT_SYMBOL(__p4d_folded)
 #endif
 
 #include "../../x86/xen/xen-head.S"
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index ee12861e0609..f62bed1c2a9d 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -1,5 +1,11 @@
 #define DISABLE_BRANCH_PROFILING
 #define pr_fmt(fmt) "kasan: " fmt
+
+#ifdef CONFIG_X86_5LEVEL
+/* Too early to use cpu_feature_enabled() */
+#define p4d_folded __p4d_folded
+#endif
+
 #include <linux/bootmem.h>
 #include <linux/kasan.h>
 #include <linux/kdebug.h>
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
