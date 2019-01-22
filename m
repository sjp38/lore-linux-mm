Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 999CC8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:28:56 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f198so1532677wmd.4
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 06:28:56 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id q10si50261944wrd.104.2019.01.22.06.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 06:28:54 -0800 (PST)
Message-Id: <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1548166824.git.christophe.leroy@c-s.fr>
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v4 3/3] powerpc/32: Add KASAN support
Date: Tue, 22 Jan 2019 14:28:46 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org

This patch adds KASAN support for PPC32.

Note that on book3s it will only work on the 603 because the other
ones use hash table and can therefore not share a single PTE table
covering the entire early KASAN shadow area.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Kconfig                         |  1 +
 arch/powerpc/include/asm/book3s/32/pgtable.h |  2 +
 arch/powerpc/include/asm/kasan.h             | 24 ++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  2 +
 arch/powerpc/include/asm/ppc_asm.h           |  5 ++
 arch/powerpc/include/asm/setup.h             |  5 ++
 arch/powerpc/include/asm/string.h            | 14 +++++
 arch/powerpc/kernel/Makefile                 |  9 ++-
 arch/powerpc/kernel/early_32.c               |  1 +
 arch/powerpc/kernel/prom_init_check.sh       | 10 +++-
 arch/powerpc/kernel/setup-common.c           |  2 +
 arch/powerpc/kernel/setup_32.c               |  3 +
 arch/powerpc/lib/Makefile                    |  8 +++
 arch/powerpc/lib/copy_32.S                   |  9 ++-
 arch/powerpc/mm/Makefile                     |  3 +
 arch/powerpc/mm/dump_linuxpagetables.c       |  8 +++
 arch/powerpc/mm/kasan_init.c                 | 86 ++++++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |  4 ++
 18 files changed, 190 insertions(+), 6 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/mm/kasan_init.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2890d36eb531..11dcaa80d3ff 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -175,6 +175,7 @@ config PPC
 	select GENERIC_TIME_VSYSCALL
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN			if PPC32
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if COMPAT
diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index 49d76adb9bc5..4543016f80ca 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -141,6 +141,8 @@ static inline bool pte_user(pte_t pte)
  */
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
+#elif defined(CONFIG_KASAN)
+#define KVIRT_TOP	KASAN_SHADOW_START
 #else
 #define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
 #endif
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
new file mode 100644
index 000000000000..5d0088429b62
--- /dev/null
+++ b/arch/powerpc/include/asm/kasan.h
@@ -0,0 +1,24 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __ASM_KASAN_H
+#define __ASM_KASAN_H
+
+#ifndef __ASSEMBLY__
+
+#include <asm/page.h>
+#include <asm/pgtable-types.h>
+#include <asm/fixmap.h>
+
+#define KASAN_SHADOW_SCALE_SHIFT	3
+#define KASAN_SHADOW_SIZE	((~0UL - PAGE_OFFSET + 1) >> KASAN_SHADOW_SCALE_SHIFT)
+
+#define KASAN_SHADOW_START	(ALIGN_DOWN(FIXADDR_START - KASAN_SHADOW_SIZE, \
+					    PGDIR_SIZE))
+#define KASAN_SHADOW_END	(KASAN_SHADOW_START + KASAN_SHADOW_SIZE)
+#define KASAN_SHADOW_OFFSET	(KASAN_SHADOW_START - \
+				 (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT))
+
+void kasan_early_init(void);
+void kasan_init(void);
+
+#endif
+#endif
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index bed433358260..b3b52f02be1a 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -71,6 +71,8 @@ extern int icache_44x_need_flush;
  */
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
+#elif defined(CONFIG_KASAN)
+#define KVIRT_TOP	KASAN_SHADOW_START
 #else
 #define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
 #endif
diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
index e0637730a8e7..8d5291c721fa 100644
--- a/arch/powerpc/include/asm/ppc_asm.h
+++ b/arch/powerpc/include/asm/ppc_asm.h
@@ -251,6 +251,11 @@ GLUE(.,name):
 
 #define _GLOBAL_TOC(name) _GLOBAL(name)
 
+#define KASAN_OVERRIDE(x, y) \
+	.weak x;	     \
+	.set x, y
+
+
 #endif
 
 /*
diff --git a/arch/powerpc/include/asm/setup.h b/arch/powerpc/include/asm/setup.h
index 65676e2325b8..da7768aa996a 100644
--- a/arch/powerpc/include/asm/setup.h
+++ b/arch/powerpc/include/asm/setup.h
@@ -74,6 +74,11 @@ static inline void setup_spectre_v2(void) {};
 #endif
 void do_btb_flush_fixups(void);
 
+#ifndef CONFIG_KASAN
+static inline void kasan_early_init(void) { }
+static inline void kasan_init(void) { }
+#endif
+
 #endif /* !__ASSEMBLY__ */
 
 #endif	/* _ASM_POWERPC_SETUP_H */
diff --git a/arch/powerpc/include/asm/string.h b/arch/powerpc/include/asm/string.h
index 1647de15a31e..64d44d4836b4 100644
--- a/arch/powerpc/include/asm/string.h
+++ b/arch/powerpc/include/asm/string.h
@@ -27,6 +27,20 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
 extern void * memchr(const void *,int,__kernel_size_t);
 extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
 
+void *__memset(void *s, int c, __kernel_size_t count);
+void *__memcpy(void *to, const void *from, __kernel_size_t n);
+void *__memmove(void *to, const void *from, __kernel_size_t n);
+
+#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
+/*
+ * For files that are not instrumented (e.g. mm/slub.c) we
+ * should use not instrumented version of mem* functions.
+ */
+#define memcpy(dst, src, len) __memcpy(dst, src, len)
+#define memmove(dst, src, len) __memmove(dst, src, len)
+#define memset(s, c, n) __memset(s, c, n)
+#endif
+
 #ifdef CONFIG_PPC64
 #define __HAVE_ARCH_MEMSET32
 #define __HAVE_ARCH_MEMSET64
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 879b36602748..fc4c42262694 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -16,8 +16,9 @@ CFLAGS_prom_init.o      += -fPIC
 CFLAGS_btext.o		+= -fPIC
 endif
 
-CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
-CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
+CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
+CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
 CFLAGS_btext.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
 CFLAGS_prom.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
 
@@ -31,6 +32,10 @@ CFLAGS_REMOVE_btext.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_prom.o = $(CC_FLAGS_FTRACE)
 endif
 
+KASAN_SANITIZE_early_32.o := n
+KASAN_SANITIZE_cputable.o := n
+KASAN_SANITIZE_prom_init.o := n
+
 obj-y				:= cputable.o ptrace.o syscalls.o \
 				   irq.o align.o signal_32.o pmc.o vdso.o \
 				   process.o systbl.o idle.o \
diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
index b3e40d6d651c..3482118ffe76 100644
--- a/arch/powerpc/kernel/early_32.c
+++ b/arch/powerpc/kernel/early_32.c
@@ -8,6 +8,7 @@
 #include <linux/kernel.h>
 #include <asm/setup.h>
 #include <asm/sections.h>
+#include <asm/asm-prototypes.h>
 
 /*
  * We're called here very early in the boot.
diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
index 667df97d2595..da6bb16e0876 100644
--- a/arch/powerpc/kernel/prom_init_check.sh
+++ b/arch/powerpc/kernel/prom_init_check.sh
@@ -16,8 +16,16 @@
 # If you really need to reference something from prom_init.o add
 # it to the list below:
 
+grep CONFIG_KASAN=y .config >/dev/null
+if [ $? -eq 0 ]
+then
+	MEMFCT="__memcpy __memset"
+else
+	MEMFCT="memcpy memset"
+fi
+
 WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
-_end enter_prom memcpy memset reloc_offset __secondary_hold
+_end enter_prom $MEMFCT reloc_offset __secondary_hold
 __secondary_hold_acknowledge __secondary_hold_spinloop __start
 strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
 reloc_got2 kernstart_addr memstart_addr linux_banner _stext
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index ca00fbb97cf8..16ff1ea66805 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -978,6 +978,8 @@ void __init setup_arch(char **cmdline_p)
 
 	paging_init();
 
+	kasan_init();
+
 	/* Initialize the MMU context management stuff. */
 	mmu_context_init();
 
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index b46a9a33225b..fe6990dec6fc 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -17,6 +17,7 @@
 #include <linux/console.h>
 #include <linux/memblock.h>
 #include <linux/export.h>
+#include <linux/kasan.h>
 
 #include <asm/io.h>
 #include <asm/prom.h>
@@ -75,6 +76,8 @@ notrace void __init machine_init(u64 dt_ptr)
 	unsigned int *addr = (unsigned int *)patch_site_addr(&patch__memset_nocache);
 	unsigned long insn;
 
+	kasan_early_init();
+
 	/* Configure static keys first, now that we're relocated. */
 	setup_feature_keys();
 
diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
index 3bf9fc6fd36c..ce8d4a9f810a 100644
--- a/arch/powerpc/lib/Makefile
+++ b/arch/powerpc/lib/Makefile
@@ -8,6 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
 CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
 
+KASAN_SANITIZE_code-patching.o := n
+KASAN_SANITIZE_feature-fixups.o := n
+
+ifdef CONFIG_KASAN
+CFLAGS_code-patching.o += -DDISABLE_BRANCH_PROFILING
+CFLAGS_feature-fixups.o += -DDISABLE_BRANCH_PROFILING
+endif
+
 obj-y += string.o alloc.o code-patching.o feature-fixups.o
 
 obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o strlen_32.o
diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
index ba66846fe973..4d8a1c73b4cf 100644
--- a/arch/powerpc/lib/copy_32.S
+++ b/arch/powerpc/lib/copy_32.S
@@ -91,7 +91,8 @@ EXPORT_SYMBOL(memset16)
  * We therefore skip the optimised bloc that uses dcbz. This jump is
  * replaced by a nop once cache is active. This is done in machine_init()
  */
-_GLOBAL(memset)
+_GLOBAL(__memset)
+KASAN_OVERRIDE(memset, __memset)
 	cmplwi	0,r5,4
 	blt	7f
 
@@ -163,12 +164,14 @@ EXPORT_SYMBOL(memset)
  * We therefore jump to generic_memcpy which doesn't use dcbz. This jump is
  * replaced by a nop once cache is active. This is done in machine_init()
  */
-_GLOBAL(memmove)
+_GLOBAL(__memmove)
+KASAN_OVERRIDE(memmove, __memmove)
 	cmplw	0,r3,r4
 	bgt	backwards_memcpy
 	/* fall through */
 
-_GLOBAL(memcpy)
+_GLOBAL(__memcpy)
+KASAN_OVERRIDE(memcpy, __memcpy)
 1:	b	generic_memcpy
 	patch_site	1b, patch__memcpy_nocache
 
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index f965fc33a8b7..d6b76f25f6de 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -7,6 +7,8 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 
 CFLAGS_REMOVE_slb.o = $(CC_FLAGS_FTRACE)
 
+KASAN_SANITIZE_kasan_init.o := n
+
 obj-y				:= fault.o mem.o pgtable.o mmap.o \
 				   init_$(BITS).o pgtable_$(BITS).o \
 				   init-common.o mmu_context.o drmem.o
@@ -55,3 +57,4 @@ obj-$(CONFIG_PPC_BOOK3S_64)	+= dump_linuxpagetables-book3s64.o
 endif
 obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
 obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
+obj-$(CONFIG_KASAN)		+= kasan_init.o
diff --git a/arch/powerpc/mm/dump_linuxpagetables.c b/arch/powerpc/mm/dump_linuxpagetables.c
index 6aa41669ac1a..c862b48118f1 100644
--- a/arch/powerpc/mm/dump_linuxpagetables.c
+++ b/arch/powerpc/mm/dump_linuxpagetables.c
@@ -94,6 +94,10 @@ static struct addr_marker address_markers[] = {
 	{ 0,	"Consistent mem start" },
 	{ 0,	"Consistent mem end" },
 #endif
+#ifdef CONFIG_KASAN
+	{ 0,	"kasan shadow mem start" },
+	{ 0,	"kasan shadow mem end" },
+#endif
 #ifdef CONFIG_HIGHMEM
 	{ 0,	"Highmem PTEs start" },
 	{ 0,	"Highmem PTEs end" },
@@ -310,6 +314,10 @@ static void populate_markers(void)
 	address_markers[i++].start_address = IOREMAP_TOP +
 					     CONFIG_CONSISTENT_SIZE;
 #endif
+#ifdef CONFIG_KASAN
+	address_markers[i++].start_address = KASAN_SHADOW_START;
+	address_markers[i++].start_address = KASAN_SHADOW_END;
+#endif
 #ifdef CONFIG_HIGHMEM
 	address_markers[i++].start_address = PKMAP_BASE;
 	address_markers[i++].start_address = PKMAP_ADDR(LAST_PKMAP);
diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
new file mode 100644
index 000000000000..69e17428c2e9
--- /dev/null
+++ b/arch/powerpc/mm/kasan_init.c
@@ -0,0 +1,86 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#define DISABLE_BRANCH_PROFILING
+
+#include <linux/kasan.h>
+#include <linux/printk.h>
+#include <linux/memblock.h>
+#include <linux/sched/task.h>
+#include <asm/pgalloc.h>
+
+void __init kasan_early_init(void)
+{
+	unsigned long addr = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+	unsigned long next;
+	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
+	int i;
+	phys_addr_t pa = __pa(kasan_early_shadow_page);
+
+	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
+
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		panic("KASAN not supported with Hash MMU\n");
+
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		__set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
+			     kasan_early_shadow_pte + i,
+			     pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static void __init kasan_init_region(struct memblock_region *reg)
+{
+	void *start = __va(reg->base);
+	void *end = __va(reg->base + reg->size);
+	unsigned long k_start, k_end, k_cur, k_next;
+	pmd_t *pmd;
+
+	if (start >= end)
+		return;
+
+	k_start = (unsigned long)kasan_mem_to_shadow(start);
+	k_end = (unsigned long)kasan_mem_to_shadow(end);
+	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
+
+	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
+		k_next = pgd_addr_end(k_cur, k_end);
+		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte) {
+			pte_t *new = pte_alloc_one_kernel(&init_mm);
+
+			if (!new)
+				panic("kasan: pte_alloc_one_kernel() failed");
+			memcpy(new, kasan_early_shadow_pte, PTE_TABLE_SIZE);
+			pmd_populate_kernel(&init_mm, pmd, new);
+		}
+	};
+
+	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
+		void *va = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
+
+		if (!va)
+			panic("kasan: memblock_alloc() failed");
+		pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
+		pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(pte));
+	}
+	flush_tlb_kernel_range(k_start, k_end);
+}
+
+void __init kasan_init(void)
+{
+	struct memblock_region *reg;
+
+	for_each_memblock(memory, reg)
+		kasan_init_region(reg);
+
+	kasan_init_tags();
+
+	/* At this point kasan is fully initialized. Enable error messages */
+	init_task.kasan_depth = 0;
+	pr_info("KASAN init done\n");
+}
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 33cc6f676fa6..ae7db88b72d6 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -369,6 +369,10 @@ void __init mem_init(void)
 	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
 		PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
 #endif /* CONFIG_HIGHMEM */
+#ifdef CONFIG_KASAN
+	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
+		KASAN_SHADOW_START, KASAN_SHADOW_END);
+#endif
 #ifdef CONFIG_NOT_COHERENT_CACHE
 	pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
 		IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
-- 
2.13.3
