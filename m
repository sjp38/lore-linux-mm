Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 505B96B01F8
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:34:12 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hn9so6159439wib.16
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 05:34:10 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id i7si1226147wjz.160.2014.03.20.05.34.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 05:34:09 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 20 Mar 2014 12:34:08 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id CAB582190069
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:34:00 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2KCXsoX57671914
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:33:54 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2KCY5ei015248
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:34:05 -0400
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 3/3] s390/mm: Convert bootmem to memblock
Date: Thu, 20 Mar 2014 13:33:50 +0100
Message-Id: <1395318830-7435-4-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1395318830-7435-1-git-send-email-schwidefsky@de.ibm.com>
References: <1395318830-7435-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tangchen@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, grygorii.strashko@ti.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>

The original bootmem allocator is getting replaced by memblock. To
cover the needs of the s390 kdump implementation the physical memory
list is used.
With this patch the bootmem allocator and its bitmaps are completely
removed from s390.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/Kconfig             |    3 +-
 arch/s390/include/asm/setup.h |   16 +-
 arch/s390/kernel/crash_dump.c |   83 ++++----
 arch/s390/kernel/early.c      |    6 +
 arch/s390/kernel/head31.S     |    1 -
 arch/s390/kernel/setup.c      |  451 +++++++++++++++--------------------------
 arch/s390/kernel/topology.c   |    4 +-
 arch/s390/mm/mem_detect.c     |  138 ++++---------
 arch/s390/mm/vmem.c           |   30 ++-
 drivers/s390/char/zcore.c     |   44 ++--
 10 files changed, 274 insertions(+), 502 deletions(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 65a0775..167e040 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -60,7 +60,6 @@ config PCI_QUIRKS
 
 config S390
 	def_bool y
-	select ARCH_DISCARD_MEMBLOCK
 	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
 	select ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
@@ -128,6 +127,7 @@ config S390
 	select HAVE_KVM if 64BIT
 	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
+	select HAVE_MEMBLOCK_PHYS_MAP
 	select HAVE_MOD_ARCH_SPECIFIC
 	select HAVE_OPROFILE
 	select HAVE_PERF_EVENTS
@@ -137,6 +137,7 @@ config S390
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select KTIME_SCALAR if 32BIT
 	select MODULES_USE_ELF_RELA
+	select NO_BOOTMEM
 	select OLD_SIGACTION
 	select OLD_SIGSUSPEND3
 	select SYSCTL_EXCEPTION_TRACE
diff --git a/arch/s390/include/asm/setup.h b/arch/s390/include/asm/setup.h
index 94cfbe4..5c84ece 100644
--- a/arch/s390/include/asm/setup.h
+++ b/arch/s390/include/asm/setup.h
@@ -9,7 +9,6 @@
 
 
 #define PARMAREA		0x10400
-#define MEMORY_CHUNKS		256
 
 #ifndef __ASSEMBLY__
 
@@ -31,22 +30,11 @@
 #endif /* CONFIG_64BIT */
 #define COMMAND_LINE      ((char *)            (0x10480))
 
-#define CHUNK_READ_WRITE 0
-#define CHUNK_READ_ONLY  1
-
-struct mem_chunk {
-	unsigned long addr;
-	unsigned long size;
-	int type;
-};
-
-extern struct mem_chunk memory_chunk[];
 extern int memory_end_set;
 extern unsigned long memory_end;
+extern unsigned long max_physmem_end;
 
-void detect_memory_layout(struct mem_chunk chunk[], unsigned long maxsize);
-void create_mem_hole(struct mem_chunk mem_chunk[], unsigned long addr,
-		     unsigned long size);
+extern void detect_memory_memblock(void);
 
 /*
  * Machine features detected in head.S
diff --git a/arch/s390/kernel/crash_dump.c b/arch/s390/kernel/crash_dump.c
index d7658c4..a3b9150 100644
--- a/arch/s390/kernel/crash_dump.c
+++ b/arch/s390/kernel/crash_dump.c
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/bootmem.h>
 #include <linux/elf.h>
+#include <linux/memblock.h>
 #include <asm/os_info.h>
 #include <asm/elf.h>
 #include <asm/ipl.h>
@@ -22,6 +23,24 @@
 #define PTR_SUB(x, y) (((char *) (x)) - ((unsigned long) (y)))
 #define PTR_DIFF(x, y) ((unsigned long)(((char *) (x)) - ((unsigned long) (y))))
 
+static struct memblock_region oldmem_region;
+
+static struct memblock_type oldmem_type = {
+	.cnt = 1,
+	.max = 1,
+	.total_size = 0,
+	.regions = &oldmem_region,
+};
+
+#define for_each_dump_mem_range(i, nid, p_start, p_end, p_nid)		\
+	for (i = 0, __next_mem_range(&i, nid, &memblock.physmem,	\
+				     &oldmem_type, p_start,		\
+				     p_end, p_nid);			\
+	     i != (u64)ULLONG_MAX;					\
+	     __next_mem_range(&i, nid, &memblock.physmem,		\
+			      &oldmem_type,				\
+			      p_start, p_end, p_nid))
+
 struct dump_save_areas dump_save_areas;
 
 /*
@@ -264,19 +283,6 @@ static void *kzalloc_panic(int len)
 }
 
 /*
- * Get memory layout and create hole for oldmem
- */
-static struct mem_chunk *get_memory_layout(void)
-{
-	struct mem_chunk *chunk_array;
-
-	chunk_array = kzalloc_panic(MEMORY_CHUNKS * sizeof(struct mem_chunk));
-	detect_memory_layout(chunk_array, 0);
-	create_mem_hole(chunk_array, OLDMEM_BASE, OLDMEM_SIZE);
-	return chunk_array;
-}
-
-/*
  * Initialize ELF note
  */
 static void *nt_init(void *buf, Elf64_Word type, void *desc, int d_len,
@@ -490,52 +496,33 @@ static int get_cpu_cnt(void)
  */
 static int get_mem_chunk_cnt(void)
 {
-	struct mem_chunk *chunk_array, *mem_chunk;
-	int i, cnt = 0;
+	int cnt = 0;
+	u64 idx;
 
-	chunk_array = get_memory_layout();
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		mem_chunk = &chunk_array[i];
-		if (chunk_array[i].type != CHUNK_READ_WRITE &&
-		    chunk_array[i].type != CHUNK_READ_ONLY)
-			continue;
-		if (mem_chunk->size == 0)
-			continue;
+	for_each_dump_mem_range(idx, NUMA_NO_NODE, NULL, NULL, NULL)
 		cnt++;
-	}
-	kfree(chunk_array);
 	return cnt;
 }
 
 /*
  * Initialize ELF loads (new kernel)
  */
-static int loads_init(Elf64_Phdr *phdr, u64 loads_offset)
+static void loads_init(Elf64_Phdr *phdr, u64 loads_offset)
 {
-	struct mem_chunk *chunk_array, *mem_chunk;
-	int i;
+	phys_addr_t start, end;
+	u64 idx;
 
-	chunk_array = get_memory_layout();
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		mem_chunk = &chunk_array[i];
-		if (mem_chunk->size == 0)
-			continue;
-		if (chunk_array[i].type != CHUNK_READ_WRITE &&
-		    chunk_array[i].type != CHUNK_READ_ONLY)
-			continue;
-		else
-			phdr->p_filesz = mem_chunk->size;
+	for_each_dump_mem_range(idx, NUMA_NO_NODE, &start, &end, NULL) {
+		phdr->p_filesz = end - start;
 		phdr->p_type = PT_LOAD;
-		phdr->p_offset = mem_chunk->addr;
-		phdr->p_vaddr = mem_chunk->addr;
-		phdr->p_paddr = mem_chunk->addr;
-		phdr->p_memsz = mem_chunk->size;
+		phdr->p_offset = start;
+		phdr->p_vaddr = start;
+		phdr->p_paddr = start;
+		phdr->p_memsz = end - start;
 		phdr->p_flags = PF_R | PF_W | PF_X;
 		phdr->p_align = PAGE_SIZE;
 		phdr++;
 	}
-	kfree(chunk_array);
-	return i;
 }
 
 /*
@@ -584,6 +571,14 @@ int elfcorehdr_alloc(unsigned long long *addr, unsigned long long *size)
 	/* If we cannot get HSA size for zfcpdump return error */
 	if (ipl_info.type == IPL_TYPE_FCP_DUMP && !sclp_get_hsa_size())
 		return -ENODEV;
+
+	/* For kdump, exclude previous crashkernel memory */
+	if (OLDMEM_BASE) {
+		oldmem_region.base = OLDMEM_BASE;
+		oldmem_region.size = OLDMEM_SIZE;
+		oldmem_type.total_size = OLDMEM_SIZE;
+	}
+
 	mem_chunk_cnt = get_mem_chunk_cnt();
 
 	alloc_size = 0x1000 + get_cpu_cnt() * 0x300 +
diff --git a/arch/s390/kernel/early.c b/arch/s390/kernel/early.c
index fca20b5..1dfabb0 100644
--- a/arch/s390/kernel/early.c
+++ b/arch/s390/kernel/early.c
@@ -258,13 +258,19 @@ static __init void setup_topology(void)
 static void early_pgm_check_handler(void)
 {
 	const struct exception_table_entry *fixup;
+	unsigned long cr0, cr0_new;
 	unsigned long addr;
 
 	addr = S390_lowcore.program_old_psw.addr;
 	fixup = search_exception_tables(addr & PSW_ADDR_INSN);
 	if (!fixup)
 		disabled_wait(0);
+	/* Disable low address protection before storing into lowcore. */
+	__ctl_store(cr0, 0, 0);
+	cr0_new = cr0 & ~(1UL << 28);
+	__ctl_load(cr0_new, 0, 0);
 	S390_lowcore.program_old_psw.addr = extable_fixup(fixup)|PSW_ADDR_AMODE;
+	__ctl_load(cr0, 0, 0);
 }
 
 static noinline __init void setup_lowcore_early(void)
diff --git a/arch/s390/kernel/head31.S b/arch/s390/kernel/head31.S
index 9a99856..6dbe809 100644
--- a/arch/s390/kernel/head31.S
+++ b/arch/s390/kernel/head31.S
@@ -59,7 +59,6 @@ ENTRY(startup_continue)
 	.long	0			# cr13: home space segment table
 	.long	0xc0000000		# cr14: machine check handling off
 	.long	0			# cr15: linkage stack operations
-.Lmchunk:.long	memory_chunk
 .Lbss_bgn:  .long __bss_start
 .Lbss_end:  .long _end
 .Lparmaddr: .long PARMAREA
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index 09e2f46..55d89d2 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -85,10 +85,9 @@ EXPORT_SYMBOL(console_irq);
 unsigned long elf_hwcap = 0;
 char elf_platform[ELF_PLATFORM_SIZE];
 
-struct mem_chunk __initdata memory_chunk[MEMORY_CHUNKS];
-
 int __initdata memory_end_set;
 unsigned long __initdata memory_end;
+unsigned long __initdata max_physmem_end;
 
 unsigned long VMALLOC_START;
 EXPORT_SYMBOL(VMALLOC_START);
@@ -280,6 +279,7 @@ EXPORT_SYMBOL_GPL(pm_power_off);
 static int __init early_parse_mem(char *p)
 {
 	memory_end = memparse(p, &p);
+	memory_end &= PAGE_MASK;
 	memory_end_set = 1;
 	return 0;
 }
@@ -416,7 +416,8 @@ static struct resource __initdata *standard_resources[] = {
 static void __init setup_resources(void)
 {
 	struct resource *res, *std_res, *sub_res;
-	int i, j;
+	struct memblock_region *reg;
+	int j;
 
 	code_resource.start = (unsigned long) &_text;
 	code_resource.end = (unsigned long) &_etext - 1;
@@ -425,24 +426,13 @@ static void __init setup_resources(void)
 	bss_resource.start = (unsigned long) &__bss_start;
 	bss_resource.end = (unsigned long) &__bss_stop - 1;
 
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		if (!memory_chunk[i].size)
-			continue;
+	for_each_memblock(memory, reg) {
 		res = alloc_bootmem_low(sizeof(*res));
 		res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
-		switch (memory_chunk[i].type) {
-		case CHUNK_READ_WRITE:
-			res->name = "System RAM";
-			break;
-		case CHUNK_READ_ONLY:
-			res->name = "System ROM";
-			res->flags |= IORESOURCE_READONLY;
-			break;
-		default:
-			res->name = "reserved";
-		}
-		res->start = memory_chunk[i].addr;
-		res->end = res->start + memory_chunk[i].size - 1;
+
+		res->name = "System RAM";
+		res->start = reg->base;
+		res->end = reg->base + reg->size - 1;
 		request_resource(&iomem_resource, res);
 
 		for (j = 0; j < ARRAY_SIZE(standard_resources); j++) {
@@ -466,48 +456,11 @@ static void __init setup_resources(void)
 static void __init setup_memory_end(void)
 {
 	unsigned long vmax, vmalloc_size, tmp;
-	unsigned long real_memory_size = 0;
-	int i;
-
-
-#ifdef CONFIG_ZFCPDUMP
-	if (ipl_info.type == IPL_TYPE_FCP_DUMP &&
-	    !OLDMEM_BASE && sclp_get_hsa_size()) {
-		memory_end = sclp_get_hsa_size();
-		memory_end_set = 1;
-	}
-#endif
-	memory_end &= PAGE_MASK;
-
-	/*
-	 * Make sure all chunks are MAX_ORDER aligned so we don't need the
-	 * extra checks that HOLES_IN_ZONE would require.
-	 */
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		unsigned long start, end;
-		struct mem_chunk *chunk;
-		unsigned long align;
-
-		chunk = &memory_chunk[i];
-		if (!chunk->size)
-			continue;
-		align = 1UL << (MAX_ORDER + PAGE_SHIFT - 1);
-		start = (chunk->addr + align - 1) & ~(align - 1);
-		end = (chunk->addr + chunk->size) & ~(align - 1);
-		if (start >= end)
-			memset(chunk, 0, sizeof(*chunk));
-		else {
-			chunk->addr = start;
-			chunk->size = end - start;
-		}
-		real_memory_size = max(real_memory_size,
-				       chunk->addr + chunk->size);
-	}
 
 	/* Choose kernel address space layout: 2, 3, or 4 levels. */
 #ifdef CONFIG_64BIT
 	vmalloc_size = VMALLOC_END ?: (128UL << 30) - MODULES_LEN;
-	tmp = (memory_end ?: real_memory_size) / PAGE_SIZE;
+	tmp = (memory_end ?: max_physmem_end) / PAGE_SIZE;
 	tmp = tmp * (sizeof(struct page) + PAGE_SIZE) + vmalloc_size;
 	if (tmp <= (1UL << 42))
 		vmax = 1UL << 42;	/* 3-level kernel page table */
@@ -535,21 +488,11 @@ static void __init setup_memory_end(void)
 	vmemmap = (struct page *) tmp;
 
 	/* Take care that memory_end is set and <= vmemmap */
-	memory_end = min(memory_end ?: real_memory_size, tmp);
-
-	/* Fixup memory chunk array to fit into 0..memory_end */
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		struct mem_chunk *chunk = &memory_chunk[i];
+	memory_end = min(memory_end ?: max_physmem_end, tmp);
+	max_pfn = max_low_pfn = PFN_DOWN(memory_end);
+	memblock_remove(memory_end, ULONG_MAX);
 
-		if (!chunk->size)
-			continue;
-		if (chunk->addr >= memory_end) {
-			memset(chunk, 0, sizeof(*chunk));
-			continue;
-		}
-		if (chunk->addr + chunk->size > memory_end)
-			chunk->size = memory_end - chunk->addr;
-	}
+	pr_notice("Max memory size: %luMB\n", memory_end >> 20);
 }
 
 static void __init setup_vmcoreinfo(void)
@@ -560,89 +503,6 @@ static void __init setup_vmcoreinfo(void)
 #ifdef CONFIG_CRASH_DUMP
 
 /*
- * Find suitable location for crashkernel memory
- */
-static unsigned long __init find_crash_base(unsigned long crash_size,
-					    char **msg)
-{
-	unsigned long crash_base;
-	struct mem_chunk *chunk;
-	int i;
-
-	if (memory_chunk[0].size < crash_size) {
-		*msg = "first memory chunk must be at least crashkernel size";
-		return 0;
-	}
-	if (OLDMEM_BASE && crash_size == OLDMEM_SIZE)
-		return OLDMEM_BASE;
-
-	for (i = MEMORY_CHUNKS - 1; i >= 0; i--) {
-		chunk = &memory_chunk[i];
-		if (chunk->size == 0)
-			continue;
-		if (chunk->type != CHUNK_READ_WRITE)
-			continue;
-		if (chunk->size < crash_size)
-			continue;
-		crash_base = (chunk->addr + chunk->size) - crash_size;
-		if (crash_base < crash_size)
-			continue;
-		if (crash_base < sclp_get_hsa_size())
-			continue;
-		if (crash_base < (unsigned long) INITRD_START + INITRD_SIZE)
-			continue;
-		return crash_base;
-	}
-	*msg = "no suitable area found";
-	return 0;
-}
-
-/*
- * Check if crash_base and crash_size is valid
- */
-static int __init verify_crash_base(unsigned long crash_base,
-				    unsigned long crash_size,
-				    char **msg)
-{
-	struct mem_chunk *chunk;
-	int i;
-
-	/*
-	 * Because we do the swap to zero, we must have at least 'crash_size'
-	 * bytes free space before crash_base
-	 */
-	if (crash_size > crash_base) {
-		*msg = "crashkernel offset must be greater than size";
-		return -EINVAL;
-	}
-
-	/* First memory chunk must be at least crash_size */
-	if (memory_chunk[0].size < crash_size) {
-		*msg = "first memory chunk must be at least crashkernel size";
-		return -EINVAL;
-	}
-	/* Check if we fit into the respective memory chunk */
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		chunk = &memory_chunk[i];
-		if (chunk->size == 0)
-			continue;
-		if (crash_base < chunk->addr)
-			continue;
-		if (crash_base >= chunk->addr + chunk->size)
-			continue;
-		/* we have found the memory chunk */
-		if (crash_base + crash_size > chunk->addr + chunk->size) {
-			*msg = "selected memory chunk is too small for "
-				"crashkernel memory";
-			return -EINVAL;
-		}
-		return 0;
-	}
-	*msg = "invalid memory range specified";
-	return -EINVAL;
-}
-
-/*
  * When kdump is enabled, we have to ensure that no memory from
  * the area [0 - crashkernel memory size] and
  * [crashk_res.start - crashk_res.end] is set offline.
@@ -668,23 +528,44 @@ static struct notifier_block kdump_mem_nb = {
 #endif
 
 /*
+ * Make sure that the area behind memory_end is protected
+ */
+static void reserve_memory_end(void)
+{
+#ifdef CONFIG_ZFCPDUMP
+	if (ipl_info.type == IPL_TYPE_FCP_DUMP &&
+	    !OLDMEM_BASE && sclp_get_hsa_size()) {
+		memory_end = sclp_get_hsa_size();
+		memory_end &= PAGE_MASK;
+		memory_end_set = 1;
+	}
+#endif
+	if (!memory_end_set)
+		return;
+	memblock_reserve(memory_end, ULONG_MAX);
+}
+
+/*
  * Make sure that oldmem, where the dump is stored, is protected
  */
 static void reserve_oldmem(void)
 {
 #ifdef CONFIG_CRASH_DUMP
-	unsigned long real_size = 0;
-	int i;
-
-	if (!OLDMEM_BASE)
-		return;
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		struct mem_chunk *chunk = &memory_chunk[i];
+	if (OLDMEM_BASE)
+		/* Forget all memory above the running kdump system */
+		memblock_reserve(OLDMEM_SIZE, (phys_addr_t)ULONG_MAX);
+#endif
+}
 
-		real_size = max(real_size, chunk->addr + chunk->size);
-	}
-	create_mem_hole(memory_chunk, OLDMEM_BASE, OLDMEM_SIZE);
-	create_mem_hole(memory_chunk, OLDMEM_SIZE, real_size - OLDMEM_SIZE);
+/*
+ * Make sure that oldmem, where the dump is stored, is protected
+ */
+static void remove_oldmem(void)
+{
+#ifdef CONFIG_CRASH_DUMP
+	if (OLDMEM_BASE)
+		/* Forget all memory above the running kdump system */
+		memblock_remove(OLDMEM_SIZE, (phys_addr_t)ULONG_MAX);
 #endif
 }
 
@@ -695,167 +576,132 @@ static void __init reserve_crashkernel(void)
 {
 #ifdef CONFIG_CRASH_DUMP
 	unsigned long long crash_base, crash_size;
-	char *msg = NULL;
+	phys_addr_t low, high;
 	int rc;
 
 	rc = parse_crashkernel(boot_command_line, memory_end, &crash_size,
 			       &crash_base);
-	if (rc || crash_size == 0)
-		return;
+
 	crash_base = ALIGN(crash_base, KEXEC_CRASH_MEM_ALIGN);
 	crash_size = ALIGN(crash_size, KEXEC_CRASH_MEM_ALIGN);
-	if (register_memory_notifier(&kdump_mem_nb))
+	if (rc || crash_size == 0)
 		return;
-	if (!crash_base)
-		crash_base = find_crash_base(crash_size, &msg);
-	if (!crash_base) {
-		pr_info("crashkernel reservation failed: %s\n", msg);
-		unregister_memory_notifier(&kdump_mem_nb);
+
+	if (memblock.memory.regions[0].size < crash_size) {
+		pr_info("crashkernel reservation failed: %s\n",
+			"first memory chunk must be at least crashkernel size");
 		return;
 	}
-	if (verify_crash_base(crash_base, crash_size, &msg)) {
-		pr_info("crashkernel reservation failed: %s\n", msg);
-		unregister_memory_notifier(&kdump_mem_nb);
+
+	low = crash_base ?: OLDMEM_BASE;
+	high = low + crash_size;
+	if (low >= OLDMEM_BASE && high <= OLDMEM_BASE + OLDMEM_SIZE) {
+		/* The crashkernel fits into OLDMEM, reuse OLDMEM */
+		crash_base = low;
+	} else {
+		/* Find suitable area in free memory */
+		low = max_t(unsigned long, crash_size, sclp_get_hsa_size());
+		high = crash_base ? crash_base + crash_size : ULONG_MAX;
+
+		if (crash_base && crash_base < low) {
+			pr_info("crashkernel reservation failed: %s\n",
+				"crash_base too low");
+			return;
+		}
+		low = crash_base ?: low;
+		crash_base = memblock_find_in_range(low, high, crash_size,
+						    KEXEC_CRASH_MEM_ALIGN);
+	}
+
+	if (!crash_base) {
+		pr_info("crashkernel reservation failed: %s\n",
+			"no suitable area found");
 		return;
 	}
+
+	if (register_memory_notifier(&kdump_mem_nb))
+		return;
+
 	if (!OLDMEM_BASE && MACHINE_IS_VM)
 		diag10_range(PFN_DOWN(crash_base), PFN_DOWN(crash_size));
 	crashk_res.start = crash_base;
 	crashk_res.end = crash_base + crash_size - 1;
 	insert_resource(&iomem_resource, &crashk_res);
-	create_mem_hole(memory_chunk, crash_base, crash_size);
+	memblock_remove(crash_base, crash_size);
 	pr_info("Reserving %lluMB of memory at %lluMB "
 		"for crashkernel (System RAM: %luMB)\n",
-		crash_size >> 20, crash_base >> 20, memory_end >> 20);
+		crash_size >> 20, crash_base >> 20,
+		(unsigned long)memblock.memory.total_size >> 20);
 	os_info_crashkernel_add(crash_base, crash_size);
 #endif
 }
 
-static void __init setup_memory(void)
+/*
+ * Reserve the initrd from being used by memblock
+ */
+static void __init reserve_initrd(void)
 {
-        unsigned long bootmap_size;
-	unsigned long start_pfn, end_pfn;
-	int i;
+#ifdef CONFIG_BLK_DEV_INITRD
+	initrd_start = INITRD_START;
+	initrd_end = initrd_start + INITRD_SIZE;
+	memblock_reserve(INITRD_START, INITRD_SIZE);
+#endif
+}
 
-	/*
-	 * partially used pages are not usable - thus
-	 * we are rounding upwards:
-	 */
+/*
+ * Check for initrd being in usable memory
+ */
+static void __init check_initrd(void)
+{
+#ifdef CONFIG_BLK_DEV_INITRD
+	if (INITRD_START && INITRD_SIZE &&
+	    !memblock_is_region_memory(INITRD_START, INITRD_SIZE)) {
+		pr_err("initrd does not fit memory.\n");
+		memblock_free(INITRD_START, INITRD_SIZE);
+		initrd_start = initrd_end = 0;
+	}
+#endif
+}
+
+/*
+ * Reserve all kernel text
+ */
+static void __init reserve_kernel(void)
+{
+	unsigned long start_pfn;
 	start_pfn = PFN_UP(__pa(&_end));
-	end_pfn = max_pfn = PFN_DOWN(memory_end);
 
-#ifdef CONFIG_BLK_DEV_INITRD
 	/*
-	 * Move the initrd in case the bitmap of the bootmem allocater
-	 * would overwrite it.
+	 * Reserve memory used for lowcore/command line/kernel image.
 	 */
+	memblock_reserve(0, (unsigned long)_ehead);
+	memblock_reserve((unsigned long)_stext, PFN_PHYS(start_pfn)
+			 - (unsigned long)_stext);
+}
 
-	if (INITRD_START && INITRD_SIZE) {
-		unsigned long bmap_size;
-		unsigned long start;
-
-		bmap_size = bootmem_bootmap_pages(end_pfn - start_pfn + 1);
-		bmap_size = PFN_PHYS(bmap_size);
-
-		if (PFN_PHYS(start_pfn) + bmap_size > INITRD_START) {
-			start = PFN_PHYS(start_pfn) + bmap_size + PAGE_SIZE;
-
+static void __init reserve_elfcorehdr(void)
+{
 #ifdef CONFIG_CRASH_DUMP
-			if (OLDMEM_BASE) {
-				/* Move initrd behind kdump oldmem */
-				if (start + INITRD_SIZE > OLDMEM_BASE &&
-				    start < OLDMEM_BASE + OLDMEM_SIZE)
-					start = OLDMEM_BASE + OLDMEM_SIZE;
-			}
-#endif
-			if (start + INITRD_SIZE > memory_end) {
-				pr_err("initrd extends beyond end of "
-				       "memory (0x%08lx > 0x%08lx) "
-				       "disabling initrd\n",
-				       start + INITRD_SIZE, memory_end);
-				INITRD_START = INITRD_SIZE = 0;
-			} else {
-				pr_info("Moving initrd (0x%08lx -> "
-					"0x%08lx, size: %ld)\n",
-					INITRD_START, start, INITRD_SIZE);
-				memmove((void *) start, (void *) INITRD_START,
-					INITRD_SIZE);
-				INITRD_START = start;
-			}
-		}
-	}
+	if (is_kdump_kernel())
+		memblock_reserve(elfcorehdr_addr - OLDMEM_BASE,
+				 PAGE_ALIGN(elfcorehdr_size));
 #endif
+}
 
-	/*
-	 * Initialize the boot-time allocator
-	 */
-	bootmap_size = init_bootmem(start_pfn, end_pfn);
+static void __init setup_memory(void)
+{
+	struct memblock_region *reg;
 
 	/*
-	 * Register RAM areas with the bootmem allocator.
+	 * Init storage key for present memory
 	 */
-
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		unsigned long start_chunk, end_chunk, pfn;
-
-		if (!memory_chunk[i].size)
-			continue;
-		start_chunk = PFN_DOWN(memory_chunk[i].addr);
-		end_chunk = start_chunk + PFN_DOWN(memory_chunk[i].size);
-		end_chunk = min(end_chunk, end_pfn);
-		if (start_chunk >= end_chunk)
-			continue;
-		memblock_add_node(PFN_PHYS(start_chunk),
-				  PFN_PHYS(end_chunk - start_chunk), 0);
-		pfn = max(start_chunk, start_pfn);
-		storage_key_init_range(PFN_PHYS(pfn), PFN_PHYS(end_chunk));
+	for_each_memblock(memory, reg) {
+		storage_key_init_range(reg->base, reg->base + reg->size);
 	}
-
 	psw_set_key(PAGE_DEFAULT_KEY);
 
-	free_bootmem_with_active_regions(0, max_pfn);
-
-	/*
-	 * Reserve memory used for lowcore/command line/kernel image.
-	 */
-	reserve_bootmem(0, (unsigned long)_ehead, BOOTMEM_DEFAULT);
-	reserve_bootmem((unsigned long)_stext,
-			PFN_PHYS(start_pfn) - (unsigned long)_stext,
-			BOOTMEM_DEFAULT);
-	/*
-	 * Reserve the bootmem bitmap itself as well. We do this in two
-	 * steps (first step was init_bootmem()) because this catches
-	 * the (very unlikely) case of us accidentally initializing the
-	 * bootmem allocator with an invalid RAM area.
-	 */
-	reserve_bootmem(start_pfn << PAGE_SHIFT, bootmap_size,
-			BOOTMEM_DEFAULT);
-
-#ifdef CONFIG_CRASH_DUMP
-	if (crashk_res.start)
-		reserve_bootmem(crashk_res.start,
-				crashk_res.end - crashk_res.start + 1,
-				BOOTMEM_DEFAULT);
-	if (is_kdump_kernel())
-		reserve_bootmem(elfcorehdr_addr - OLDMEM_BASE,
-				PAGE_ALIGN(elfcorehdr_size), BOOTMEM_DEFAULT);
-#endif
-#ifdef CONFIG_BLK_DEV_INITRD
-	if (INITRD_START && INITRD_SIZE) {
-		if (INITRD_START + INITRD_SIZE <= memory_end) {
-			reserve_bootmem(INITRD_START, INITRD_SIZE,
-					BOOTMEM_DEFAULT);
-			initrd_start = INITRD_START;
-			initrd_end = initrd_start + INITRD_SIZE;
-		} else {
-			pr_err("initrd extends beyond end of "
-			       "memory (0x%08lx > 0x%08lx) "
-			       "disabling initrd\n",
-			       initrd_start + INITRD_SIZE, memory_end);
-			initrd_start = initrd_end = 0;
-		}
-	}
-#endif
+	/* Only cosmetics */
+	memblock_enforce_memory_limit(memblock_end_of_DRAM());
 }
 
 /*
@@ -1004,6 +850,7 @@ void __init setup_arch(char **cmdline_p)
 
         ROOT_DEV = Root_RAM0;
 
+	/* Is init_mm really needed? */
 	init_mm.start_code = PAGE_OFFSET;
 	init_mm.end_code = (unsigned long) &_etext;
 	init_mm.end_data = (unsigned long) &_edata;
@@ -1012,17 +859,39 @@ void __init setup_arch(char **cmdline_p)
 	uaccess = MACHINE_HAS_MVCOS ? uaccess_mvcos : uaccess_pt;
 
 	parse_early_param();
-	detect_memory_layout(memory_chunk, memory_end);
 	os_info_init();
 	setup_ipl();
+
+	/* Do some memory reservations *before* memory is added to memblock */
+	reserve_memory_end();
 	reserve_oldmem();
+	reserve_kernel();
+	reserve_initrd();
+	reserve_elfcorehdr();
+	memblock_allow_resize();
+
+	/* Get information about *all* installed memory */
+	detect_memory_memblock();
+
+	remove_oldmem();
+
+	/*
+	 * Make sure all chunks are MAX_ORDER aligned so we don't need the
+	 * extra checks that HOLES_IN_ZONE would require.
+	 *
+	 * Is this still required?
+	 */
+	memblock_trim_memory(1UL << (MAX_ORDER - 1 + PAGE_SHIFT));
+
 	setup_memory_end();
-	reserve_crashkernel();
 	setup_memory();
+
+	check_initrd();
+	reserve_crashkernel();
+
 	setup_resources();
 	setup_vmcoreinfo();
 	setup_lowcore();
-
 	smp_fill_possible_mask();
         cpu_init();
 	s390_init_cpu_topology();
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index 4b2e3e3..805c70c 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -333,7 +333,9 @@ static void __init alloc_masks(struct sysinfo_15_1_x *info,
 		nr_masks *= info->mag[TOPOLOGY_NR_MAG - offset - 1 - i];
 	nr_masks = max(nr_masks, 1);
 	for (i = 0; i < nr_masks; i++) {
-		mask->next = alloc_bootmem(sizeof(struct mask_info));
+		mask->next = alloc_bootmem_align(
+			roundup_pow_of_two(sizeof(struct mask_info)),
+			roundup_pow_of_two(sizeof(struct mask_info)));
 		mask = mask->next;
 	}
 }
diff --git a/arch/s390/mm/mem_detect.c b/arch/s390/mm/mem_detect.c
index cca3882..7a4ba18 100644
--- a/arch/s390/mm/mem_detect.c
+++ b/arch/s390/mm/mem_detect.c
@@ -6,130 +6,60 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/memblock.h>
+#include <linux/init.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <asm/ipl.h>
 #include <asm/sclp.h>
 #include <asm/setup.h>
 
-#define ADDR2G (1ULL << 31)
+#define ADDR2G (1UL << 31)
 
-static void find_memory_chunks(struct mem_chunk chunk[], unsigned long maxsize)
+#define CHUNK_READ_WRITE 0
+#define CHUNK_READ_ONLY  1
+
+static inline void memblock_physmem_add(phys_addr_t start, phys_addr_t size)
+{
+	memblock_add_range(&memblock.memory, start, size, 0, 0);
+	memblock_add_range(&memblock.physmem, start, size, 0, 0);
+}
+
+void __init detect_memory_memblock(void)
 {
-	unsigned long long memsize, rnmax, rzm;
-	unsigned long addr = 0, size;
-	int i = 0, type;
+	unsigned long long rnmax, rzm;
+	unsigned long addr, size;
+	int type;
 
 	rzm = sclp_get_rzm();
 	rnmax = sclp_get_rnmax();
-	memsize = rzm * rnmax;
+	max_physmem_end = rzm * rnmax;
 	if (!rzm)
 		rzm = 1ULL << 17;
-	if (sizeof(long) == 4) {
-		rzm = min(ADDR2G, rzm);
-		memsize = memsize ? min(ADDR2G, memsize) : ADDR2G;
+	if (IS_ENABLED(CONFIG_32BIT)) {
+		rzm = min_t(unsigned long, ADDR2G, rzm);
+		if (!max_physmem_end || max_physmem_end > ADDR2G)
+			max_physmem_end = min(ADDR2G, max_physmem_end);
 	}
-	if (maxsize)
-		memsize = memsize ? min((unsigned long)memsize, maxsize) : maxsize;
+	addr = 0;
+	/* keep memblock lists close to the kernel */
+	memblock_set_bottom_up(true);
 	do {
 		size = 0;
 		type = tprot(addr);
 		do {
 			size += rzm;
-			if (memsize && addr + size >= memsize)
+			if (max_physmem_end && addr + size >= max_physmem_end)
 				break;
 		} while (type == tprot(addr + size));
 		if (type == CHUNK_READ_WRITE || type == CHUNK_READ_ONLY) {
-			if (memsize && (addr + size > memsize))
-				size = memsize - addr;
-			chunk[i].addr = addr;
-			chunk[i].size = size;
-			chunk[i].type = type;
-			i++;
+			if (max_physmem_end && (addr + size > max_physmem_end))
+				size = max_physmem_end - addr;
+			memblock_physmem_add(addr, size);
 		}
 		addr += size;
-	} while (addr < memsize && i < MEMORY_CHUNKS);
-}
-
-/**
- * detect_memory_layout - fill mem_chunk array with memory layout data
- * @chunk: mem_chunk array to be filled
- * @maxsize: maximum address where memory detection should stop
- *
- * Fills the passed in memory chunk array with the memory layout of the
- * machine. The array must have a size of at least MEMORY_CHUNKS and will
- * be fully initialized afterwards.
- * If the maxsize paramater has a value > 0 memory detection will stop at
- * that address. It is guaranteed that all chunks have an ending address
- * that is smaller than maxsize.
- * If maxsize is 0 all memory will be detected.
- */
-void detect_memory_layout(struct mem_chunk chunk[], unsigned long maxsize)
-{
-	unsigned long flags, flags_dat, cr0;
-
-	memset(chunk, 0, MEMORY_CHUNKS * sizeof(struct mem_chunk));
-	/*
-	 * Disable IRQs, DAT and low address protection so tprot does the
-	 * right thing and we don't get scheduled away with low address
-	 * protection disabled.
-	 */
-	local_irq_save(flags);
-	flags_dat = __arch_local_irq_stnsm(0xfb);
-	/*
-	 * In case DAT was enabled, make sure chunk doesn't reside in vmalloc
-	 * space. We have disabled DAT and any access to vmalloc area will
-	 * cause an exception.
-	 * If DAT was disabled we are called from early ipl code.
-	 */
-	if (test_bit(5, &flags_dat)) {
-		if (WARN_ON_ONCE(is_vmalloc_or_module_addr(chunk)))
-			goto out;
-	}
-	__ctl_store(cr0, 0, 0);
-	__ctl_clear_bit(0, 28);
-	find_memory_chunks(chunk, maxsize);
-	__ctl_load(cr0, 0, 0);
-out:
-	__arch_local_irq_ssm(flags_dat);
-	local_irq_restore(flags);
-}
-EXPORT_SYMBOL(detect_memory_layout);
-
-/*
- * Create memory hole with given address and size.
- */
-void create_mem_hole(struct mem_chunk mem_chunk[], unsigned long addr,
-		     unsigned long size)
-{
-	int i;
-
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		struct mem_chunk *chunk = &mem_chunk[i];
-
-		if (chunk->size == 0)
-			continue;
-		if (addr > chunk->addr + chunk->size)
-			continue;
-		if (addr + size <= chunk->addr)
-			continue;
-		/* Split */
-		if ((addr > chunk->addr) &&
-		    (addr + size < chunk->addr + chunk->size)) {
-			struct mem_chunk *new = chunk + 1;
-
-			memmove(new, chunk, (MEMORY_CHUNKS-i-1) * sizeof(*new));
-			new->addr = addr + size;
-			new->size = chunk->addr + chunk->size - new->addr;
-			chunk->size = addr - chunk->addr;
-			continue;
-		} else if ((addr <= chunk->addr) &&
-			   (addr + size >= chunk->addr + chunk->size)) {
-			memmove(chunk, chunk + 1, (MEMORY_CHUNKS-i-1) * sizeof(*chunk));
-			memset(&mem_chunk[MEMORY_CHUNKS-1], 0, sizeof(*chunk));
-		} else if (addr + size < chunk->addr + chunk->size) {
-			chunk->size =  chunk->addr + chunk->size - addr - size;
-			chunk->addr = addr + size;
-		} else if (addr > chunk->addr) {
-			chunk->size = addr - chunk->addr;
-		}
-	}
+	} while (addr < max_physmem_end);
+	memblock_set_bottom_up(false);
+	if (!max_physmem_end)
+		max_physmem_end = memblock_end_of_DRAM();
 }
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index bcfb70b..1aece42 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -10,6 +10,7 @@
 #include <linux/list.h>
 #include <linux/hugetlb.h>
 #include <linux/slab.h>
+#include <linux/memblock.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
 #include <asm/setup.h>
@@ -66,7 +67,8 @@ static pte_t __ref *vmem_pte_alloc(unsigned long address)
 	if (slab_is_available())
 		pte = (pte_t *) page_table_alloc(&init_mm, address);
 	else
-		pte = alloc_bootmem(PTRS_PER_PTE * sizeof(pte_t));
+		pte = alloc_bootmem_align(PTRS_PER_PTE * sizeof(pte_t),
+					  PTRS_PER_PTE * sizeof(pte_t));
 	if (!pte)
 		return NULL;
 	clear_table((unsigned long *) pte, _PAGE_INVALID,
@@ -373,16 +375,14 @@ out:
 void __init vmem_map_init(void)
 {
 	unsigned long ro_start, ro_end;
-	unsigned long start, end;
-	int i;
+	struct memblock_region *reg;
+	phys_addr_t start, end;
 
 	ro_start = PFN_ALIGN((unsigned long)&_stext);
 	ro_end = (unsigned long)&_eshared & PAGE_MASK;
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		if (!memory_chunk[i].size)
-			continue;
-		start = memory_chunk[i].addr;
-		end = memory_chunk[i].addr + memory_chunk[i].size;
+	for_each_memblock(memory, reg) {
+		start = reg->base;
+		end = reg->base + reg->size - 1;
 		if (start >= ro_end || end <= ro_start)
 			vmem_add_mem(start, end - start, 0);
 		else if (start >= ro_start && end <= ro_end)
@@ -402,23 +402,21 @@ void __init vmem_map_init(void)
 }
 
 /*
- * Convert memory chunk array to a memory segment list so there is a single
- * list that contains both r/w memory and shared memory segments.
+ * Convert memblock.memory  to a memory segment list so there is a single
+ * list that contains all memory segments.
  */
 static int __init vmem_convert_memory_chunk(void)
 {
+	struct memblock_region *reg;
 	struct memory_segment *seg;
-	int i;
 
 	mutex_lock(&vmem_mutex);
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		if (!memory_chunk[i].size)
-			continue;
+	for_each_memblock(memory, reg) {
 		seg = kzalloc(sizeof(*seg), GFP_KERNEL);
 		if (!seg)
 			panic("Out of memory...\n");
-		seg->start = memory_chunk[i].addr;
-		seg->size = memory_chunk[i].size;
+		seg->start = reg->base;
+		seg->size = reg->size;
 		insert_memory_segment(seg);
 	}
 	mutex_unlock(&vmem_mutex);
diff --git a/drivers/s390/char/zcore.c b/drivers/s390/char/zcore.c
index 3d8e4d6..1884653 100644
--- a/drivers/s390/char/zcore.c
+++ b/drivers/s390/char/zcore.c
@@ -17,6 +17,8 @@
 #include <linux/miscdevice.h>
 #include <linux/debugfs.h>
 #include <linux/module.h>
+#include <linux/memblock.h>
+
 #include <asm/asm-offsets.h>
 #include <asm/ipl.h>
 #include <asm/sclp.h>
@@ -411,33 +413,24 @@ static ssize_t zcore_memmap_read(struct file *filp, char __user *buf,
 				 size_t count, loff_t *ppos)
 {
 	return simple_read_from_buffer(buf, count, ppos, filp->private_data,
-				       MEMORY_CHUNKS * CHUNK_INFO_SIZE);
+				       memblock.memory.cnt * CHUNK_INFO_SIZE);
 }
 
 static int zcore_memmap_open(struct inode *inode, struct file *filp)
 {
-	int i;
+	struct memblock_region *reg;
 	char *buf;
-	struct mem_chunk *chunk_array;
+	int i = 0;
 
-	chunk_array = kzalloc(MEMORY_CHUNKS * sizeof(struct mem_chunk),
-			      GFP_KERNEL);
-	if (!chunk_array)
-		return -ENOMEM;
-	detect_memory_layout(chunk_array, 0);
-	buf = kzalloc(MEMORY_CHUNKS * CHUNK_INFO_SIZE, GFP_KERNEL);
+	buf = kzalloc(memblock.memory.cnt * CHUNK_INFO_SIZE, GFP_KERNEL);
 	if (!buf) {
-		kfree(chunk_array);
 		return -ENOMEM;
 	}
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		sprintf(buf + (i * CHUNK_INFO_SIZE), "%016llx %016llx ",
-			(unsigned long long) chunk_array[i].addr,
-			(unsigned long long) chunk_array[i].size);
-		if (chunk_array[i].size == 0)
-			break;
+	for_each_memblock(memory, reg) {
+		sprintf(buf + (i++ * CHUNK_INFO_SIZE), "%016llx %016llx ",
+			(unsigned long long) reg->base,
+			(unsigned long long) reg->size);
 	}
-	kfree(chunk_array);
 	filp->private_data = buf;
 	return nonseekable_open(inode, filp);
 }
@@ -593,21 +586,12 @@ static int __init check_sdias(void)
 
 static int __init get_mem_info(unsigned long *mem, unsigned long *end)
 {
-	int i;
-	struct mem_chunk *chunk_array;
+	struct memblock_region *reg;
 
-	chunk_array = kzalloc(MEMORY_CHUNKS * sizeof(struct mem_chunk),
-			      GFP_KERNEL);
-	if (!chunk_array)
-		return -ENOMEM;
-	detect_memory_layout(chunk_array, 0);
-	for (i = 0; i < MEMORY_CHUNKS; i++) {
-		if (chunk_array[i].size == 0)
-			break;
-		*mem += chunk_array[i].size;
-		*end = max(*end, chunk_array[i].addr + chunk_array[i].size);
+	for_each_memblock(memory, reg) {
+		*mem += reg->size;
+		*end = max_t(unsigned long, *end, reg->base + reg->size);
 	}
-	kfree(chunk_array);
 	return 0;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
