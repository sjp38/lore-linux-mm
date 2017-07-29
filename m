Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9AD6B0591
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 10:10:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v77so70530145pgb.15
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 07:10:26 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g4si11167157pgr.934.2017.07.29.07.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 07:10:24 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id r63so1802948pfb.3
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 07:10:24 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RFC PATCH v1] powerpc/radix/kasan: KASAN support for Radix
Date: Sun, 30 Jul 2017 00:09:01 +1000
Message-Id: <20170729140901.5887-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, mpe@ellerman.id.au
Cc: kasan-dev@googlegroups.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, glider@google.com, dvyukov@google.com, Balbir Singh <bsingharora@gmail.com>

This is the first attempt to implement KASAN for radix
on powerpc64. Aneesh Kumar implemented KASAN for hash 64
in limited mode (support only for kernel linear mapping)
(https://lwn.net/Articles/655642/)

This patch does the following:
1. Defines its own zero_page,pte,pmd and pud because
the generic PTRS_PER_PTE, etc are variables on ppc64
book3s. Since the implementation is for radix, we use
the radix constants. This patch uses ARCH_DEFINES_KASAN_ZERO_PTE
for that purpose
2. There is a new function check_return_arch_not_ready()
which is defined for ppc64/book3s/radix and overrides the
checks in check_memory_region_inline() until the arch has
done kasan setup is done for the architecture. This is needed
for powerpc. A lot of functions are called in real mode prior
to MMU paging init, we could fix some of this by using
the kasan_early_init() bits, but that just maps the zero
page and does not do useful reporting. For this RFC we
just delay the checks in mem* functions till kasan_init()
3. This patch renames memcpy/memset/memmove to their
equivalent __memcpy/__memset/__memmove and for files
that skip KASAN via KASAN_SANITIZE, we use the __
variants. This is largely based on Aneesh's patchset
mentioned above
4. In paca.c, some explicit memcpy inserted by the
compiler/linker is replaced via explicit memcpy
for structure content copying
5. prom_init and a few other files have KASAN_SANITIZE
set to n, I think with the delayed checks (#2 above)
we might be able to work around many of them
6. Resizing of virtual address space is done a little
aggressively the size is reduced to 1/4 and totally
to 1/2. For the RFC it was considered OK, since this
is just a debug tool for developers. This can be revisited
in the final implementation

Tests:

I ran test_kasan.ko and it reported errors for all test
cases except for

kasan test: memcg_accounted_kmem_cache allocate memcg accounted object
kasan test: kasan_stack_oob out-of-bounds on stack
kasan test: kasan_global_oob out-of-bounds global variable
kasan test: use_after_scope_test use-after-scope on int
kasan test: use_after_scope_test use-after-scope on array

Based on my understanding of the test, which is an expected
kasan bug report after each test starting with a "===" line.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 arch/powerpc/Kconfig                             |   1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h     |   1 +
 arch/powerpc/include/asm/book3s/64/radix-kasan.h |  56 +++++++++++
 arch/powerpc/include/asm/book3s/64/radix.h       |   9 ++
 arch/powerpc/include/asm/kasan.h                 |  24 +++++
 arch/powerpc/include/asm/string.h                |  24 +++++
 arch/powerpc/kernel/Makefile                     |   5 +
 arch/powerpc/kernel/cputable.c                   |   6 +-
 arch/powerpc/kernel/paca.c                       |   2 +-
 arch/powerpc/kernel/prom_init_check.sh           |   3 +-
 arch/powerpc/kernel/setup-common.c               |   3 +
 arch/powerpc/kernel/setup_64.c                   |   1 -
 arch/powerpc/lib/mem_64.S                        |  20 +++-
 arch/powerpc/lib/memcpy_64.S                     |  10 +-
 arch/powerpc/mm/Makefile                         |   3 +
 arch/powerpc/mm/radix_kasan_init.c               | 120 +++++++++++++++++++++++
 include/linux/kasan.h                            |   7 ++
 mm/kasan/kasan.c                                 |   2 +
 mm/kasan/kasan_init.c                            |   2 +
 19 files changed, 290 insertions(+), 9 deletions(-)
 create mode 100644 arch/powerpc/include/asm/book3s/64/radix-kasan.h
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/mm/radix_kasan_init.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 36f858c37ca7..83b882e00fcf 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -160,6 +160,7 @@ config PPC
 	select GENERIC_TIME_VSYSCALL
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN if (PPC_BOOK3S && PPC64 && SPARSEMEM_VMEMMAP)
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if COMPAT
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index d1da415e283c..7b8afe97bb8e 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -299,6 +299,7 @@ extern unsigned long pci_io_base;
  * IOREMAP_BASE = ISA_IO_BASE + 2G to VMALLOC_START + PGTABLE_RANGE
  */
 #define KERN_IO_START	(KERN_VIRT_START + (KERN_VIRT_SIZE >> 1))
+
 #define FULL_IO_SIZE	0x80000000ul
 #define  ISA_IO_BASE	(KERN_IO_START)
 #define  ISA_IO_END	(KERN_IO_START + 0x10000ul)
diff --git a/arch/powerpc/include/asm/book3s/64/radix-kasan.h b/arch/powerpc/include/asm/book3s/64/radix-kasan.h
new file mode 100644
index 000000000000..67022dde6548
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/64/radix-kasan.h
@@ -0,0 +1,56 @@
+/*
+ * Copyright 2017 Balbir Singh, IBM Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ * Author: Balbir Singh <bsingharora@gmail.com>
+ */
+#ifndef __ASM_BOOK3S_64_RADIX_KASAN_H
+#define __ASM_BOOK3S_64_RADIX_KASAN_H
+
+#ifndef __ASSEMBLY__
+
+#define ARCH_DEFINES_KASAN_ZERO_PTE
+
+#define RADIX_PTRS_PER_PTE	(1 << RADIX_PTE_INDEX_SIZE)
+#define RADIX_PTRS_PER_PMD	(1 << RADIX_PMD_INDEX_SIZE)
+#define RADIX_PTRS_PER_PUD	(1 << RADIX_PUD_INDEX_SIZE)
+extern pte_t kasan_zero_pte[RADIX_PTRS_PER_PTE];
+extern pmd_t kasan_zero_pmd[RADIX_PTRS_PER_PMD];
+extern pud_t kasan_zero_pud[RADIX_PTRS_PER_PUD];
+
+#include <asm/book3s/64/radix.h>
+
+/*
+ * KASAN_SHADOW_START: beginning at the end of IO region
+ * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/8 of kernel virtual addresses.
+ */
+#define KASAN_SHADOW_START      (IOREMAP_END)
+#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (KERN_VIRT_SIZE << 1))
+
+/*
+ * This value is used to map an address to the corresponding shadow
+ * address by the following formula:
+ *     shadow_addr = (address >> 3) + KASAN_SHADOW_OFFSET;
+ *
+ */
+#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_START - (PAGE_OFFSET / 8))
+
+#ifdef CONFIG_KASAN
+void kasan_init(void);
+
+extern struct static_key_false powerpc_kasan_enabled_key;
+#define check_return_arch_not_ready() \
+	do {								\
+		if (!static_branch_likely(&powerpc_kasan_enabled_key))	\
+			return;						\
+	} while (0)
+
+
+#else
+static inline void kasan_init(void) { }
+#endif
+
+#endif
+#endif /* __ASM_BOOK3S_64_RADIX_KASAN_H */
diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
index 544440b5aff3..48d267630625 100644
--- a/arch/powerpc/include/asm/book3s/64/radix.h
+++ b/arch/powerpc/include/asm/book3s/64/radix.h
@@ -93,8 +93,17 @@
  * +------------------------------+  Kernel linear (0xc.....)
  */
 
+#ifndef CONFIG_KASAN
 #define RADIX_KERN_VIRT_START ASM_CONST(0xc008000000000000)
+#else
+#define RADIX_KERN_VIRT_START ASM_CONST(0xc002000000000000)
+#endif
+
+#ifndef CONFIG_KASAN
 #define RADIX_KERN_VIRT_SIZE  ASM_CONST(0x0008000000000000)
+#else
+#define RADIX_KERN_VIRT_SIZE  ASM_CONST(0x0002000000000000)
+#endif
 
 /*
  * The vmalloc space starts at the beginning of that region, and
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
new file mode 100644
index 000000000000..181e39d9f934
--- /dev/null
+++ b/arch/powerpc/include/asm/kasan.h
@@ -0,0 +1,24 @@
+/*
+ * Copyright 2017 Balbir Singh, IBM Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __ASM_KASAN_H
+#define __ASM_KASAN_H
+
+#ifndef __ASSEMBLY__
+
+#include <asm/pgtable.h>
+
+#if defined(CONFIG_KASAN) && defined(CONFIG_PPC_RADIX_MMU)
+extern void kasan_init(void);
+#include <asm/book3s/64/radix-kasan.h>
+
+#else
+static inline void kasan_init(void) {}
+#endif
+
+#endif
+#endif
diff --git a/arch/powerpc/include/asm/string.h b/arch/powerpc/include/asm/string.h
index da3cdffca440..c8b4489266a4 100644
--- a/arch/powerpc/include/asm/string.h
+++ b/arch/powerpc/include/asm/string.h
@@ -17,9 +17,33 @@ extern __kernel_size_t strlen(const char *);
 extern int strcmp(const char *,const char *);
 extern int strncmp(const char *, const char *, __kernel_size_t);
 extern char * strcat(char *, const char *);
+
+extern void * __memset(void *,int,__kernel_size_t);
+extern void * __memcpy(void *,const void *,__kernel_size_t);
+extern void * __memmove(void *,const void *,__kernel_size_t);
+
 extern void * memset(void *,int,__kernel_size_t);
 extern void * memcpy(void *,const void *,__kernel_size_t);
 extern void * memmove(void *,const void *,__kernel_size_t);
+
+#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
+
+/*
+ * For files that are not instrumented (e.g. mm/slub.c) we
+ * should use not instrumented version of mem* functions.
+ */
+
+#define memcpy(dst, src, len) __memcpy(dst, src, len)
+#define memmove(dst, src, len) __memmove(dst, src, len)
+#define memset(s, c, n) __memset(s, c, n)
+
+#ifndef __NO_FORTIFY
+#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
+#endif
+
+#endif
+
+
 extern int memcmp(const void *,const void *,__kernel_size_t);
 extern void * memchr(const void *,int,__kernel_size_t);
 
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 4aa7c147e447..6a1c41c2c82d 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -27,6 +27,11 @@ CFLAGS_REMOVE_btext.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_prom.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
 endif
 
+KASAN_SANITIZE_prom_init.o := n
+KASAN_SANITIZE_align.o := n
+KASAN_SANITIZE_dbell.o := n
+KASAN_SANITIZE_setup_64.o := n
+
 obj-y				:= cputable.o ptrace.o syscalls.o \
 				   irq.o align.o signal_32.o pmc.o vdso.o \
 				   process.o systbl.o idle.o \
diff --git a/arch/powerpc/kernel/cputable.c b/arch/powerpc/kernel/cputable.c
index 6f849832a669..537a3a9a8d08 100644
--- a/arch/powerpc/kernel/cputable.c
+++ b/arch/powerpc/kernel/cputable.c
@@ -2187,7 +2187,7 @@ void __init set_cur_cpu_spec(struct cpu_spec *s)
 	struct cpu_spec *t = &the_cpu_spec;
 
 	t = PTRRELOC(t);
-	*t = *s;
+	memcpy(t, s, sizeof(*s));
 
 	*PTRRELOC(&cur_cpu_spec) = &the_cpu_spec;
 }
@@ -2199,10 +2199,10 @@ static struct cpu_spec * __init setup_cpu_spec(unsigned long offset,
 	struct cpu_spec old;
 
 	t = PTRRELOC(t);
-	old = *t;
+	memcpy(&old, t, sizeof(*t));
 
 	/* Copy everything, then do fixups */
-	*t = *s;
+	memcpy(t, s, sizeof(*s));
 
 	/*
 	 * If we are overriding a previous value derived from the real
diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
index 8d63627e067f..3e7b50fccf6d 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -62,7 +62,7 @@ static struct lppaca * __init new_lppaca(int cpu)
 		return &lppaca[cpu];
 
 	lp = extra_lppacas + (cpu - NR_LPPACAS);
-	*lp = lppaca[0];
+	memcpy(lp, &lppaca[0], sizeof(struct lppaca));
 
 	return lp;
 }
diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
index 12640f7e726b..372ff6dcc385 100644
--- a/arch/powerpc/kernel/prom_init_check.sh
+++ b/arch/powerpc/kernel/prom_init_check.sh
@@ -21,7 +21,8 @@ _end enter_prom memcpy memset reloc_offset __secondary_hold
 __secondary_hold_acknowledge __secondary_hold_spinloop __start
 strcmp strcpy strlcpy strlen strncmp strstr logo_linux_clut224
 reloc_got2 kernstart_addr memstart_addr linux_banner _stext
-__prom_init_toc_start __prom_init_toc_end btext_setup_display TOC."
+__prom_init_toc_start __prom_init_toc_end btext_setup_display TOC.
+__memcpy __memset"
 
 NM="$1"
 OBJ="$2"
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index 94a948207cd2..318a67801fd9 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -20,6 +20,7 @@
 #include <linux/reboot.h>
 #include <linux/delay.h>
 #include <linux/initrd.h>
+#include <linux/kasan.h>
 #include <linux/platform_device.h>
 #include <linux/seq_file.h>
 #include <linux/ioport.h>
@@ -38,6 +39,7 @@
 #include <asm/debugfs.h>
 #include <asm/io.h>
 #include <asm/paca.h>
+#include <asm/kasan.h>
 #include <asm/prom.h>
 #include <asm/processor.h>
 #include <asm/vdso_datapage.h>
@@ -957,6 +959,7 @@ void __init setup_arch(char **cmdline_p)
 		ppc_md.setup_arch();
 
 	paging_init();
+	kasan_init();
 
 	/* Initialize the MMU context management stuff. */
 	mmu_context_init();
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index af23d4b576ec..aea8ba320727 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -322,7 +322,6 @@ void __init early_setup(unsigned long dt_ptr)
 	 * have IR and DR set and enable AIL if it exists
 	 */
 	cpu_ready_for_interrupts();
-
 	DBG(" <- early_setup()\n");
 
 #ifdef CONFIG_PPC_EARLY_DEBUG_BOOTX
diff --git a/arch/powerpc/lib/mem_64.S b/arch/powerpc/lib/mem_64.S
index 85fa9869aec5..8b962e8f62ec 100644
--- a/arch/powerpc/lib/mem_64.S
+++ b/arch/powerpc/lib/mem_64.S
@@ -13,7 +13,21 @@
 #include <asm/ppc_asm.h>
 #include <asm/export.h>
 
-_GLOBAL(memset)
+.weak memset
+.set  memset, __memset
+#ifndef PPC64_ELF_ABI_v2
+.weak DOTSYM(memset)
+.set DOTSYM(memset), DOTSYM(__memset)
+#endif
+
+.weak memmove
+.set  memmove, __memmove
+#ifndef PPC64_ELF_ABI_v2
+.weak DOTSYM(memmove)
+.set DOTSYM(memmove), DOTSYM(__memmove)
+#endif
+
+_GLOBAL_TOC(__memset)
 	neg	r0,r3
 	rlwimi	r4,r4,8,16,23
 	andi.	r0,r0,7			/* # bytes to be 8-byte aligned */
@@ -79,8 +93,9 @@ _GLOBAL(memset)
 	stb	r4,0(r6)
 	blr
 EXPORT_SYMBOL(memset)
+EXPORT_SYMBOL(__memset)
 
-_GLOBAL_TOC(memmove)
+_GLOBAL_TOC(__memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
 	b	memcpy
@@ -122,3 +137,4 @@ _GLOBAL(backwards_memcpy)
 	mtctr	r7
 	b	1b
 EXPORT_SYMBOL(memmove)
+EXPORT_SYMBOL(__memmove)
diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
index f4d6088e2d53..6b911ea7cb35 100644
--- a/arch/powerpc/lib/memcpy_64.S
+++ b/arch/powerpc/lib/memcpy_64.S
@@ -10,8 +10,15 @@
 #include <asm/ppc_asm.h>
 #include <asm/export.h>
 
+.weak memcpy
+.set  memcpy, __memcpy
+#ifndef PPC64_ELF_ABI_v2
+.weak DOTSYM(memcpy)
+.set DOTSYM(memcpy), DOTSYM(__memcpy)
+#endif
+
 	.align	7
-_GLOBAL_TOC(memcpy)
+_GLOBAL_TOC(__memcpy)
 BEGIN_FTR_SECTION
 #ifdef __LITTLE_ENDIAN__
 	cmpdi	cr7,r5,0
@@ -221,3 +228,4 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
 	blr
 #endif
 EXPORT_SYMBOL(memcpy)
+EXPORT_SYMBOL(__memcpy)
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 7414034df1c3..c14ff4406d95 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -45,3 +45,6 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= dump_linuxpagetables.o
 obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
+obj-$(CONFIG_PPC_RADIX_MMU)	+= radix_kasan_init.o
+
+KASAN_SANITIZE := n
diff --git a/arch/powerpc/mm/radix_kasan_init.c b/arch/powerpc/mm/radix_kasan_init.c
new file mode 100644
index 000000000000..a05bf4d3d8d1
--- /dev/null
+++ b/arch/powerpc/mm/radix_kasan_init.c
@@ -0,0 +1,120 @@
+/*
+ * This file contains kasan initialization code for PowerPC
+ *
+ * Copyright 2017 Balbir Singh, IBM Corporation.
+ *
+ * Derived from arm64 version
+ * Copyright (c) 2015 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifdef CONFIG_KASAN
+
+#define pr_fmt(fmt) "kasan: " fmt
+#include <linux/kasan.h>
+#include <linux/kernel.h>
+#include <linux/sched/task.h>
+#include <linux/memblock.h>
+#include <linux/start_kernel.h>
+#include <linux/mm.h>
+#include <linux/pfn_t.h>
+
+#include <asm/mmu_context.h>
+#include <asm/page.h>
+#include <asm/io.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+#include <asm/sections.h>
+#include <asm/tlbflush.h>
+
+DEFINE_STATIC_KEY_FALSE(powerpc_kasan_enabled_key);
+EXPORT_SYMBOL(powerpc_kasan_enabled_key);
+
+unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
+#if CONFIG_PGTABLE_LEVELS > 3
+pud_t kasan_zero_pud[RADIX_PTRS_PER_PUD] __page_aligned_bss;
+#endif
+#if CONFIG_PGTABLE_LEVELS > 2
+pmd_t kasan_zero_pmd[RADIX_PTRS_PER_PMD] __page_aligned_bss;
+#endif
+pte_t kasan_zero_pte[RADIX_PTRS_PER_PTE] __page_aligned_bss;
+
+static void set_pte(pte_t *ptep, pte_t pte)
+{
+	*ptep = pte;
+	/* No flush */
+}
+
+void __init kasan_init(void)
+{
+	unsigned long kimg_shadow_start, kimg_shadow_end;
+	struct memblock_region *reg;
+	int i;
+
+	unsigned long pte_val = __pa(kasan_zero_page) | pgprot_val(PAGE_KERNEL)
+						      | _PAGE_PTE;
+	unsigned long pmd_val = __pa(kasan_zero_pte) | pgprot_val(PAGE_KERNEL)
+						     | _PAGE_PTE;
+	unsigned long pud_val = __pa(kasan_zero_pmd) | pgprot_val(PAGE_KERNEL);
+
+
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		kasan_zero_pte[i] = __pte(pte_val);
+
+	for (i = 0; i < PTRS_PER_PMD; i++)
+		kasan_zero_pmd[i] = __pmd(pmd_val);
+
+	for (i = 0; i < PTRS_PER_PUD; i++)
+		kasan_zero_pud[i] = __pud(pud_val);
+
+
+	kimg_shadow_start = (unsigned long)kasan_mem_to_shadow(_text);
+	kimg_shadow_end = (unsigned long)kasan_mem_to_shadow(_end);
+
+
+	vmemmap_populate(kimg_shadow_start, kimg_shadow_end,
+			 pfn_to_nid(virt_to_pfn(lm_alias(_text))));
+
+	for_each_memblock(memory, reg) {
+		void *start = (void *)phys_to_virt(reg->base);
+		void *end = (void *)phys_to_virt(reg->base + reg->size);
+
+		if (start >= end)
+			break;
+
+		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
+				(unsigned long)kasan_mem_to_shadow(end),
+				pfn_to_nid(virt_to_pfn(start)));
+	}
+
+	kimg_shadow_start = (unsigned long)
+			kasan_mem_to_shadow((void *)(RADIX_KERN_VIRT_START));
+	kimg_shadow_end = (unsigned long)
+			kasan_mem_to_shadow((void *)(RADIX_KERN_VIRT_START +
+							RADIX_KERN_VIRT_SIZE));
+
+	kasan_populate_zero_shadow((void *)kimg_shadow_start,
+					(void *)kimg_shadow_end);
+
+	/*
+	 * Kasan may reuse the contents of kasan_zero_pte directly, so we
+	 * should make sure that it maps the zero page read-only.
+	 */
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		set_pte(&kasan_zero_pte[i],
+			pfn_pte(virt_to_pfn(kasan_zero_page),
+			__pgprot(_PAGE_PTE | _PAGE_KERNEL_RO | _PAGE_BASE)));
+
+	memset(kasan_zero_page, 0, PAGE_SIZE);
+
+	/* At this point kasan is fully initialized. Enable error messages */
+	init_task.kasan_depth = 0;
+	pr_info("KernelAddressSanitizer initialized\n");
+	static_branch_inc(&powerpc_kasan_enabled_key);
+}
+
+#endif /* CONFIG_KASAN */
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index a5c7046f26b4..d2190df2bdff 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -15,11 +15,18 @@ struct task_struct;
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
+#ifndef check_return_arch_not_ready
+#define check_return_arch_not_ready()	do { } while (0)
+#endif
+
 extern unsigned char kasan_zero_page[PAGE_SIZE];
+
+#ifndef ARCH_DEFINES_KASAN_ZERO_PTE
 extern pte_t kasan_zero_pte[PTRS_PER_PTE];
 extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
 extern pud_t kasan_zero_pud[PTRS_PER_PUD];
 extern p4d_t kasan_zero_p4d[PTRS_PER_P4D];
+#endif
 
 void kasan_populate_zero_shadow(const void *shadow_start,
 				const void *shadow_end);
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index ca11bc4ce205..7204512f0bdb 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -248,6 +248,8 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 	if (unlikely(size == 0))
 		return;
 
+	check_return_arch_not_ready();
+
 	if (unlikely((void *)addr <
 		kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
 		kasan_report(addr, size, write, ret_ip);
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 554e4c0f23a2..8b7086f52ae2 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -28,6 +28,7 @@
  *   - Latter it reused it as zero shadow to cover large ranges of memory
  *     that allowed to access, but not handled by kasan (vmalloc/vmemmap ...).
  */
+#ifndef ARCH_DEFINES_KASAN_ZERO_PTE
 unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 
 #if CONFIG_PGTABLE_LEVELS > 4
@@ -40,6 +41,7 @@ pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
 pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
 #endif
 pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
+#endif
 
 static __init void *early_alloc(size_t size, int node)
 {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
