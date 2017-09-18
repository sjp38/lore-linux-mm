Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 510956B027E
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 06:56:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so145207pga.6
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:56:50 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p4si4406566pgc.28.2017.09.18.03.56.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 03:56:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 19/19] x86/mm: Offset boot-time paging mode switching cost
Date: Mon, 18 Sep 2017 13:55:53 +0300
Message-Id: <20170918105553.27914-20-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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

!cpu_feature_enabled(X86_FEATURE_LA57) instead of pgtable_l5_enabled in
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

  vmlinux.before .text size:	9798404
  vmlinux.after .text size:	9802566

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
index 766a5211f827..5604f08aa405 100644
--- a/arch/x86/boot/compressed/misc.h
+++ b/arch/x86/boot/compressed/misc.h
@@ -11,6 +11,11 @@
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
index eec0ca064c67..49f1e5e48b7c 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -269,15 +269,8 @@ return_from_SYSCALL_64:
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
index fa9f8b6592fa..0efb46fa1052 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -20,7 +20,10 @@ typedef unsigned long	pgprotval_t;
 typedef struct { pteval_t pte; } pte_t;
 
 #ifdef CONFIG_X86_5LEVEL
-extern unsigned int pgtable_l5_enabled;
+extern unsigned int __pgtable_l5_enabled;
+#ifndef pgtable_l5_enabled
+#define pgtable_l5_enabled (cpu_feature_enabled(X86_FEATURE_LA57))
+#endif
 #else
 #define pgtable_l5_enabled 0
 #endif
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 617b42c9bdbb..6dcdbdf90030 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -31,6 +31,11 @@
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
@@ -39,8 +44,8 @@ static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgtable_l5_enabled __read_mostly;
-EXPORT_SYMBOL(pgtable_l5_enabled);
+unsigned int __pgtable_l5_enabled __read_mostly;
+EXPORT_SYMBOL(__pgtable_l5_enabled);
 unsigned int pgdir_shift __read_mostly = 39;
 EXPORT_SYMBOL(pgdir_shift);
 unsigned int ptrs_per_p4d __read_mostly = 1;
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index e137f2665fc2..8a1fe9b63c03 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -121,7 +121,7 @@ ENTRY(secondary_startup_64)
 	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 #ifdef CONFIG_X86_5LEVEL
-	testl	$1, pgtable_l5_enabled(%rip)
+	testl	$1, __pgtable_l5_enabled(%rip)
 	jz	1f
 	orl	$X86_CR4_LA57, %ecx
 1:
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 9173ce1feba0..230e4ea1d3ae 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -1,5 +1,11 @@
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
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
