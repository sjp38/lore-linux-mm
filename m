Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 397116B0005
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 06:49:56 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f3so2050554plf.18
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 03:49:56 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m187si4907286pfb.291.2018.02.16.03.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 03:49:54 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/3] x86/mm: Offset boot-time paging mode switching cost
Date: Fri, 16 Feb 2018 14:49:48 +0300
Message-Id: <20180216114948.68868-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180216114948.68868-1-kirill.shutemov@linux.intel.com>
References: <20180216114948.68868-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
cpu_feature_enabled(X86_FEATURE_LA57) instead of pgtable_l5_enabled in
all hot code paths. These will statically patch the target code for
additional performance.

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

Unfortunately, this approach doesn't help with text size:

  vmlinux.before .text size:	8190319
  vmlinux.after .text size:	8200623

The .text section is increased by about 4k. Not sure if we can do anything
about this.

Signed-off-by: Kirill A. Shuemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/misc.h         |  5 +++++
 arch/x86/entry/entry_64.S               | 11 ++---------
 arch/x86/include/asm/pgtable_64_types.h |  5 ++++-
 arch/x86/kernel/head64.c                |  9 +++++++--
 arch/x86/kernel/head_64.S               |  2 +-
 arch/x86/mm/kasan_init_64.c             |  6 ++++++
 6 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/arch/x86/boot/compressed/misc.h b/arch/x86/boot/compressed/misc.h
index 9d323dc6b159..4d369c308ed7 100644
--- a/arch/x86/boot/compressed/misc.h
+++ b/arch/x86/boot/compressed/misc.h
@@ -12,6 +12,11 @@
 #undef CONFIG_PARAVIRT_SPINLOCKS
 #undef CONFIG_KASAN
 
+#ifdef CONFIG_X86_5LEVEL
+/* cpu_feature_enabled() cannot be used that early */
+#define pgtable_l5_enabled __pgtable_l5_enabled
+#endif
+
 #include <linux/linkage.h>
 #include <linux/screen_info.h>
 #include <linux/elf.h>
diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index 165301c0903a..c9e55b89f03a 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -261,15 +261,8 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
 	 * depending on paging mode) in the address.
 	 */
 #ifdef CONFIG_X86_5LEVEL
-	testl	$1, pgtable_l5_enabled(%rip)
-	jz	1f
-	shl	$(64 - 57), %rcx
-	sar	$(64 - 57), %rcx
-	jmp	2f
-1:
-	shl	$(64 - 48), %rcx
-	sar	$(64 - 48), %rcx
-2:
+	ALTERNATIVE "shl $(64 - 48), %rcx; sar $(64 - 48), %rcx", \
+		"shl $(64 - 57), %rcx; sar $(64 - 57), %rcx", X86_FEATURE_LA57
 #else
 	shl	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 	sar	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 68909a68e5b9..d5c21a382475 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -21,7 +21,10 @@ typedef unsigned long	pgprotval_t;
 typedef struct { pteval_t pte; } pte_t;
 
 #ifdef CONFIG_X86_5LEVEL
-extern unsigned int pgtable_l5_enabled;
+extern unsigned int __pgtable_l5_enabled;
+#ifndef pgtable_l5_enabled
+#define pgtable_l5_enabled cpu_feature_enabled(X86_FEATURE_LA57)
+#endif
 #else
 #define pgtable_l5_enabled 0
 #endif
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 8161e719a20f..0c855deee165 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -32,6 +32,11 @@
 #include <asm/microcode.h>
 #include <asm/kasan.h>
 
+#ifdef CONFIG_X86_5LEVEL
+#undef pgtable_l5_enabled
+#define pgtable_l5_enabled __pgtable_l5_enabled
+#endif
+
 /*
  * Manage page tables very early on.
  */
@@ -40,8 +45,8 @@ static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgtable_l5_enabled __ro_after_init;
-EXPORT_SYMBOL(pgtable_l5_enabled);
+unsigned int __pgtable_l5_enabled __ro_after_init;
+EXPORT_SYMBOL(__pgtable_l5_enabled);
 unsigned int pgdir_shift __ro_after_init = 39;
 EXPORT_SYMBOL(pgdir_shift);
 unsigned int ptrs_per_p4d __ro_after_init = 1;
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 3e9de0fc97de..326c63129417 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -124,7 +124,7 @@ ENTRY(secondary_startup_64)
 	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 #ifdef CONFIG_X86_5LEVEL
-	testl	$1, pgtable_l5_enabled(%rip)
+	testl	$1, __pgtable_l5_enabled(%rip)
 	jz	1f
 	orl	$X86_CR4_LA57, %ecx
 1:
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 0df0dd13a71d..d8ff013ea9d0 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -1,6 +1,12 @@
 // SPDX-License-Identifier: GPL-2.0
 #define DISABLE_BRANCH_PROFILING
 #define pr_fmt(fmt) "kasan: " fmt
+
+#ifdef CONFIG_X86_5LEVEL
+/* Too early to use cpu_feature_enabled() */
+#define pgtable_l5_enabled __pgtable_l5_enabled
+#endif
+
 #include <linux/bootmem.h>
 #include <linux/kasan.h>
 #include <linux/kdebug.h>
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
