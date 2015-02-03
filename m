Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3E9900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:43:40 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so98866771pab.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:43:39 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ht1si3308698pac.134.2015.02.03.09.43.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:35 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ700MWSIR9TF50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:33 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 04/19] x86_64: add KASan support
Date: Tue, 03 Feb 2015 20:42:57 +0300
Message-id: <1422985392-28652-5-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andy Lutomirski <luto@amacapital.net>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>

This patch adds arch specific code for kernel address sanitizer.

16TB of virtual addressed used for shadow memory.
It's located in range [ffffec0000000000 - fffffc0000000000]
between vmemmap and %esp fixup stacks.

At early stage we map whole shadow region with zero page.
Latter, after pages mapped to direct mapping address range
we unmap zero pages from corresponding shadow (see kasan_map_shadow())
and allocate and map a real shadow memory reusing vmemmap_populate()
function.

Also replace __pa with __pa_nodebug before shadow initialized.
__pa with CONFIG_DEBUG_VIRTUAL=y make external function call (__phys_addr)
__phys_addr is instrumented, so __asan_load could be called before
shadow area initialized.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 Documentation/x86/x86_64/mm.txt   |   2 +
 arch/x86/Kconfig                  |   1 +
 arch/x86/boot/Makefile            |   2 +
 arch/x86/boot/compressed/Makefile |   2 +
 arch/x86/include/asm/kasan.h      |  31 ++++++
 arch/x86/kernel/Makefile          |   2 +
 arch/x86/kernel/dumpstack.c       |   5 +-
 arch/x86/kernel/head64.c          |   9 +-
 arch/x86/kernel/head_64.S         |  30 ++++++
 arch/x86/kernel/setup.c           |   3 +
 arch/x86/mm/Makefile              |   3 +
 arch/x86/mm/kasan_init_64.c       | 199 ++++++++++++++++++++++++++++++++++++++
 arch/x86/realmode/Makefile        |   2 +-
 arch/x86/realmode/rm/Makefile     |   1 +
 arch/x86/vdso/Makefile            |   1 +
 lib/Kconfig.kasan                 |   1 +
 16 files changed, 290 insertions(+), 4 deletions(-)
 create mode 100644 arch/x86/include/asm/kasan.h
 create mode 100644 arch/x86/mm/kasan_init_64.c

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 052ee64..05712ac 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -12,6 +12,8 @@ ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
 ffffe90000000000 - ffffe9ffffffffff (=40 bits) hole
 ffffea0000000000 - ffffeaffffffffff (=40 bits) virtual memory map (1TB)
 ... unused hole ...
+ffffec0000000000 - fffffc0000000000 (=44 bits) kasan shadow memory (16TB)
+... unused hole ...
 ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
 ... unused hole ...
 ffffffff80000000 - ffffffffa0000000 (=512 MB)  kernel text mapping, from phys 0
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index d34ef08..e5c87b2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -85,6 +85,7 @@ config X86
 	select HAVE_CMPXCHG_LOCAL
 	select HAVE_CMPXCHG_DOUBLE
 	select HAVE_ARCH_KMEMCHECK
+	select HAVE_ARCH_KASAN if X86_64
 	select HAVE_USER_RETURN_NOTIFIER
 	select ARCH_BINFMT_ELF_RANDOMIZE_PIE
 	select HAVE_ARCH_JUMP_LABEL
diff --git a/arch/x86/boot/Makefile b/arch/x86/boot/Makefile
index 3db07f3..57bbf2f 100644
--- a/arch/x86/boot/Makefile
+++ b/arch/x86/boot/Makefile
@@ -14,6 +14,8 @@
 # Set it to -DSVGA_MODE=NORMAL_VGA if you just want the EGA/VGA mode.
 # The number is the same as you would ordinarily press at bootup.
 
+KASAN_SANITIZE := n
+
 SVGA_MODE	:= -DSVGA_MODE=NORMAL_VGA
 
 targets		:= vmlinux.bin setup.bin setup.elf bzImage
diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index ad754b4..843feb3 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -16,6 +16,8 @@
 #	(see scripts/Makefile.lib size_append)
 #	compressed vmlinux.bin.all + u32 size of vmlinux.bin.all
 
+KASAN_SANITIZE := n
+
 targets := vmlinux vmlinux.bin vmlinux.bin.gz vmlinux.bin.bz2 vmlinux.bin.lzma \
 	vmlinux.bin.xz vmlinux.bin.lzo vmlinux.bin.lz4
 
diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
new file mode 100644
index 0000000..8b22422
--- /dev/null
+++ b/arch/x86/include/asm/kasan.h
@@ -0,0 +1,31 @@
+#ifndef _ASM_X86_KASAN_H
+#define _ASM_X86_KASAN_H
+
+/*
+ * Compiler uses shadow offset assuming that addresses start
+ * from 0. Kernel addresses don't start from 0, so shadow
+ * for kernel really starts from compiler's shadow offset +
+ * 'kernel address space start' >> KASAN_SHADOW_SCALE_SHIFT
+ */
+#define KASAN_SHADOW_START      (KASAN_SHADOW_OFFSET + \
+					(0xffff800000000000ULL >> 3))
+/* 47 bits for kernel address -> (47 - 3) bits for shadow */
+#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (47 - 3)))
+
+#ifndef __ASSEMBLY__
+
+extern pte_t kasan_zero_pte[];
+extern pte_t kasan_zero_pmd[];
+extern pte_t kasan_zero_pud[];
+
+#ifdef CONFIG_KASAN
+void __init kasan_map_early_shadow(pgd_t *pgd);
+void __init kasan_init(void);
+#else
+static inline void kasan_map_early_shadow(pgd_t *pgd) { }
+static inline void kasan_init(void) { }
+#endif
+
+#endif
+
+#endif
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 316b34e..4fc8ca7 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -16,6 +16,8 @@ CFLAGS_REMOVE_ftrace.o = -pg
 CFLAGS_REMOVE_early_printk.o = -pg
 endif
 
+KASAN_SANITIZE_head$(BITS).o := n
+
 CFLAGS_irq.o := -I$(src)/../include/asm/trace
 
 obj-y			:= process_$(BITS).o signal.o entry_$(BITS).o
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index b74ebc7..cf3df1d 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -265,7 +265,10 @@ int __die(const char *str, struct pt_regs *regs, long err)
 	printk("SMP ");
 #endif
 #ifdef CONFIG_DEBUG_PAGEALLOC
-	printk("DEBUG_PAGEALLOC");
+	printk("DEBUG_PAGEALLOC ");
+#endif
+#ifdef CONFIG_KASAN
+	printk("KASAN");
 #endif
 	printk("\n");
 	if (notify_die(DIE_OOPS, str, regs, err,
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index eda1a86..efcddfa 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -27,6 +27,7 @@
 #include <asm/bios_ebda.h>
 #include <asm/bootparam_utils.h>
 #include <asm/microcode.h>
+#include <asm/kasan.h>
 
 /*
  * Manage page tables very early on.
@@ -46,7 +47,7 @@ static void __init reset_early_page_tables(void)
 
 	next_early_pgt = 0;
 
-	write_cr3(__pa(early_level4_pgt));
+	write_cr3(__pa_nodebug(early_level4_pgt));
 }
 
 /* Create a new PMD entry */
@@ -59,7 +60,7 @@ int __init early_make_pgtable(unsigned long address)
 	pmdval_t pmd, *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa(early_level4_pgt))
+	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
 		return -1;
 
 again:
@@ -158,6 +159,8 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	/* Kill off the identity-map trampoline */
 	reset_early_page_tables();
 
+	kasan_map_early_shadow(early_level4_pgt);
+
 	/* clear bss before set_intr_gate with early_idt_handler */
 	clear_bss();
 
@@ -179,6 +182,8 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	/* set init_level4_pgt kernel high mapping*/
 	init_level4_pgt[511] = early_level4_pgt[511];
 
+	kasan_map_early_shadow(init_level4_pgt);
+
 	x86_64_start_reservations(real_mode_data);
 }
 
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index a468c0a..6fd514d9 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -514,8 +514,38 @@ ENTRY(phys_base)
 	/* This must match the first entry in level2_kernel_pgt */
 	.quad   0x0000000000000000
 
+#ifdef CONFIG_KASAN
+#define FILL(VAL, COUNT)				\
+	.rept (COUNT) ;					\
+	.quad	(VAL) ;					\
+	.endr
+
+NEXT_PAGE(kasan_zero_pte)
+	FILL(kasan_zero_page - __START_KERNEL_map + _KERNPG_TABLE, 512)
+NEXT_PAGE(kasan_zero_pmd)
+	FILL(kasan_zero_pte - __START_KERNEL_map + _KERNPG_TABLE, 512)
+NEXT_PAGE(kasan_zero_pud)
+	FILL(kasan_zero_pmd - __START_KERNEL_map + _KERNPG_TABLE, 512)
+
+#undef FILL
+#endif
+
+
 #include "../../x86/xen/xen-head.S"
 	
 	__PAGE_ALIGNED_BSS
 NEXT_PAGE(empty_zero_page)
 	.skip PAGE_SIZE
+
+#ifdef CONFIG_KASAN
+/*
+ * This page used as early shadow. We don't use empty_zero_page
+ * at early stages, stack instrumentation could write some garbage
+ * to this page.
+ * Latter we reuse it as zero shadow for large ranges of memory
+ * that allowed to access, but not instrumented by kasan
+ * (vmalloc/vmemmap ...).
+ */
+NEXT_PAGE(kasan_zero_page)
+	.skip PAGE_SIZE
+#endif
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index c4648ada..27d2009 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -89,6 +89,7 @@
 #include <asm/cacheflush.h>
 #include <asm/processor.h>
 #include <asm/bugs.h>
+#include <asm/kasan.h>
 
 #include <asm/vsyscall.h>
 #include <asm/cpu.h>
@@ -1174,6 +1175,8 @@ void __init setup_arch(char **cmdline_p)
 
 	x86_init.paging.pagetable_init();
 
+	kasan_init();
+
 	if (boot_cpu_data.cpuid_level >= 0) {
 		/* A CPU has %cr4 if and only if it has CPUID */
 		mmu_cr4_features = read_cr4();
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index ecfdc46..c4cc740 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -20,6 +20,9 @@ obj-$(CONFIG_HIGHMEM)		+= highmem_32.o
 
 obj-$(CONFIG_KMEMCHECK)		+= kmemcheck/
 
+KASAN_SANITIZE_kasan_init_$(BITS).o := n
+obj-$(CONFIG_KASAN)		+= kasan_init_$(BITS).o
+
 obj-$(CONFIG_MMIOTRACE)		+= mmiotrace.o
 mmiotrace-y			:= kmmio.o pf_in.o mmio-mod.o
 obj-$(CONFIG_MMIOTRACE_TEST)	+= testmmiotrace.o
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
new file mode 100644
index 0000000..3e4d9a1
--- /dev/null
+++ b/arch/x86/mm/kasan_init_64.c
@@ -0,0 +1,199 @@
+#include <linux/bootmem.h>
+#include <linux/kasan.h>
+#include <linux/kdebug.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/vmalloc.h>
+
+#include <asm/tlbflush.h>
+#include <asm/sections.h>
+
+extern pgd_t early_level4_pgt[PTRS_PER_PGD];
+extern struct range pfn_mapped[E820_X_MAX];
+
+extern unsigned char kasan_zero_page[PAGE_SIZE];
+
+static int __init map_range(struct range *range)
+{
+	unsigned long start;
+	unsigned long end;
+
+	start = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->start));
+	end = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->end));
+
+	/*
+	 * end + 1 here is intentional. We check several shadow bytes in advance
+	 * to slightly speed up fastpath. In some rare cases we could cross
+	 * boundary of mapped shadow, so we just map some more here.
+	 */
+	return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
+}
+
+static void __init clear_pgds(unsigned long start,
+			unsigned long end)
+{
+	for (; start < end; start += PGDIR_SIZE)
+		pgd_clear(pgd_offset_k(start));
+}
+
+void __init kasan_map_early_shadow(pgd_t *pgd)
+{
+	int i;
+	unsigned long start = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+
+	for (i = pgd_index(start); start < end; i++) {
+		pgd[i] = __pgd(__pa_nodebug(kasan_zero_pud)
+				| _KERNPG_TABLE);
+		start += PGDIR_SIZE;
+	}
+}
+
+static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
+				unsigned long end)
+{
+	pte_t *pte = pte_offset_kernel(pmd, addr);
+
+	while (addr + PAGE_SIZE <= end) {
+		WARN_ON(!pte_none(*pte));
+		set_pte(pte, __pte(__pa_nodebug(kasan_zero_page)
+					| __PAGE_KERNEL_RO));
+		addr += PAGE_SIZE;
+		pte = pte_offset_kernel(pmd, addr);
+	}
+	return 0;
+}
+
+static int __init zero_pmd_populate(pud_t *pud, unsigned long addr,
+				unsigned long end)
+{
+	int ret = 0;
+	pmd_t *pmd = pmd_offset(pud, addr);
+
+	while (IS_ALIGNED(addr, PMD_SIZE) && addr + PMD_SIZE <= end) {
+		WARN_ON(!pmd_none(*pmd));
+		set_pmd(pmd, __pmd(__pa_nodebug(kasan_zero_pte)
+					| __PAGE_KERNEL_RO));
+		addr += PMD_SIZE;
+		pmd = pmd_offset(pud, addr);
+	}
+	if (addr < end) {
+		if (pmd_none(*pmd)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			set_pmd(pmd, __pmd(__pa_nodebug(p) | _KERNPG_TABLE));
+		}
+		ret = zero_pte_populate(pmd, addr, end);
+	}
+	return ret;
+}
+
+
+static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
+				unsigned long end)
+{
+	int ret = 0;
+	pud_t *pud = pud_offset(pgd, addr);
+
+	while (IS_ALIGNED(addr, PUD_SIZE) && addr + PUD_SIZE <= end) {
+		WARN_ON(!pud_none(*pud));
+		set_pud(pud, __pud(__pa_nodebug(kasan_zero_pmd)
+					| __PAGE_KERNEL_RO));
+		addr += PUD_SIZE;
+		pud = pud_offset(pgd, addr);
+	}
+
+	if (addr < end) {
+		if (pud_none(*pud)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			set_pud(pud, __pud(__pa_nodebug(p) | _KERNPG_TABLE));
+		}
+		ret = zero_pmd_populate(pud, addr, end);
+	}
+	return ret;
+}
+
+static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
+{
+	int ret = 0;
+	pgd_t *pgd = pgd_offset_k(addr);
+
+	while (IS_ALIGNED(addr, PGDIR_SIZE) && addr + PGDIR_SIZE <= end) {
+		WARN_ON(!pgd_none(*pgd));
+		set_pgd(pgd, __pgd(__pa_nodebug(kasan_zero_pud)
+					| __PAGE_KERNEL_RO));
+		addr += PGDIR_SIZE;
+		pgd = pgd_offset_k(addr);
+	}
+
+	if (addr < end) {
+		if (pgd_none(*pgd)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			set_pgd(pgd, __pgd(__pa_nodebug(p) | _KERNPG_TABLE));
+		}
+		ret = zero_pud_populate(pgd, addr, end);
+	}
+	return ret;
+}
+
+
+static void __init populate_zero_shadow(const void *start, const void *end)
+{
+	if (zero_pgd_populate((unsigned long)start, (unsigned long)end))
+		panic("kasan: unable to map zero shadow!");
+}
+
+
+#ifdef CONFIG_KASAN_INLINE
+static int kasan_die_handler(struct notifier_block *self,
+			     unsigned long val,
+			     void *data)
+{
+	if (val == DIE_GPF) {
+		pr_emerg("CONFIG_KASAN_INLINE enabled");
+		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access");
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block kasan_die_notifier = {
+	.notifier_call = kasan_die_handler,
+};
+#endif
+
+void __init kasan_init(void)
+{
+	int i;
+
+#ifdef CONFIG_KASAN_INLINE
+	register_die_notifier(&kasan_die_notifier);
+#endif
+
+	memcpy(early_level4_pgt, init_level4_pgt, sizeof(early_level4_pgt));
+	load_cr3(early_level4_pgt);
+
+	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
+
+	populate_zero_shadow((void *)KASAN_SHADOW_START,
+			kasan_mem_to_shadow((void *)PAGE_OFFSET));
+
+	for (i = 0; i < E820_X_MAX; i++) {
+		if (pfn_mapped[i].end == 0)
+			break;
+
+		if (map_range(&pfn_mapped[i]))
+			panic("kasan: unable to allocate shadow!");
+	}
+
+	populate_zero_shadow(kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
+				(void *)KASAN_SHADOW_END);
+
+	memset(kasan_zero_page, 0, PAGE_SIZE);
+
+	load_cr3(init_level4_pgt);
+}
diff --git a/arch/x86/realmode/Makefile b/arch/x86/realmode/Makefile
index 94f7fbe..e02c2c6 100644
--- a/arch/x86/realmode/Makefile
+++ b/arch/x86/realmode/Makefile
@@ -6,7 +6,7 @@
 # for more details.
 #
 #
-
+KASAN_SANITIZE := n
 subdir- := rm
 
 obj-y += init.o
diff --git a/arch/x86/realmode/rm/Makefile b/arch/x86/realmode/rm/Makefile
index 7c0d7be..2730d77 100644
--- a/arch/x86/realmode/rm/Makefile
+++ b/arch/x86/realmode/rm/Makefile
@@ -6,6 +6,7 @@
 # for more details.
 #
 #
+KASAN_SANITIZE := n
 
 always := realmode.bin realmode.relocs
 
diff --git a/arch/x86/vdso/Makefile b/arch/x86/vdso/Makefile
index 5a4affe..2aacd7c 100644
--- a/arch/x86/vdso/Makefile
+++ b/arch/x86/vdso/Makefile
@@ -3,6 +3,7 @@
 #
 
 KBUILD_CFLAGS += $(DISABLE_LTO)
+KASAN_SANITIZE := n
 
 VDSO64-$(CONFIG_X86_64)		:= y
 VDSOX32-$(CONFIG_X86_X32_ABI)	:= y
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index e5b3fbe..0052b1b 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -15,6 +15,7 @@ config KASAN
 
 config KASAN_SHADOW_OFFSET
 	hex
+	default 0xdffffc0000000000 if X86_64
 
 choice
 	prompt "Instrumentation type"
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
