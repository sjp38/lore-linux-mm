Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13E988E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:12 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id j65-v6so3537997otc.5
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:13:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u3-v6si1450291otj.449.2018.09.14.05.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:13:10 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC4XCM096265
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:10 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgay24x87-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:09 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:13:07 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 20/30] memblock: replace __alloc_bootmem with memblock_alloc_from
Date: Fri, 14 Sep 2018 15:10:35 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-21-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

The functions are equivalent, just the later does not require nobootmem
translation layer.

The conversion is done using the following semantic patch:

@@
expression size, align, goal;
@@
- __alloc_bootmem(size, align, goal)
+ memblock_alloc_from(size, align, goal)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/kernel/core_cia.c  |  2 +-
 arch/alpha/kernel/pci_iommu.c |  4 ++--
 arch/alpha/kernel/setup.c     |  2 +-
 arch/ia64/kernel/mca.c        |  4 ++--
 arch/ia64/mm/contig.c         |  5 +++--
 arch/mips/kernel/traps.c      |  2 +-
 arch/sparc/kernel/prom_32.c   |  2 +-
 arch/sparc/kernel/smp_64.c    | 10 +++++-----
 arch/sparc/mm/init_32.c       |  2 +-
 arch/sparc/mm/init_64.c       |  9 ++++++---
 arch/sparc/mm/srmmu.c         | 10 +++++-----
 include/linux/bootmem.h       |  8 ++++++++
 12 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/arch/alpha/kernel/core_cia.c b/arch/alpha/kernel/core_cia.c
index 4b38386..026ee95 100644
--- a/arch/alpha/kernel/core_cia.c
+++ b/arch/alpha/kernel/core_cia.c
@@ -331,7 +331,7 @@ cia_prepare_tbia_workaround(int window)
 	long i;
 
 	/* Use minimal 1K map. */
-	ppte = __alloc_bootmem(CIA_BROKEN_TBIA_SIZE, 32768, 0);
+	ppte = memblock_alloc_from(CIA_BROKEN_TBIA_SIZE, 32768, 0);
 	pte = (virt_to_phys(ppte) >> (PAGE_SHIFT - 1)) | 1;
 
 	for (i = 0; i < CIA_BROKEN_TBIA_SIZE / sizeof(unsigned long); ++i)
diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index b52d76f..0c05493 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -87,13 +87,13 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 		printk("%s: couldn't allocate arena ptes from node %d\n"
 		       "    falling back to system-wide allocation\n",
 		       __func__, nid);
-		arena->ptes = __alloc_bootmem(mem_size, align, 0);
+		arena->ptes = memblock_alloc_from(mem_size, align, 0);
 	}
 
 #else /* CONFIG_DISCONTIGMEM */
 
 	arena = alloc_bootmem(sizeof(*arena));
-	arena->ptes = __alloc_bootmem(mem_size, align, 0);
+	arena->ptes = memblock_alloc_from(mem_size, align, 0);
 
 #endif /* CONFIG_DISCONTIGMEM */
 
diff --git a/arch/alpha/kernel/setup.c b/arch/alpha/kernel/setup.c
index 4f0d944..64c06a0 100644
--- a/arch/alpha/kernel/setup.c
+++ b/arch/alpha/kernel/setup.c
@@ -294,7 +294,7 @@ move_initrd(unsigned long mem_limit)
 	unsigned long size;
 
 	size = initrd_end - initrd_start;
-	start = __alloc_bootmem(PAGE_ALIGN(size), PAGE_SIZE, 0);
+	start = memblock_alloc_from(PAGE_ALIGN(size), PAGE_SIZE, 0);
 	if (!start || __pa(start) + size > mem_limit) {
 		initrd_start = initrd_end = 0;
 		return NULL;
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6115464..5586926 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1835,8 +1835,8 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 /* Caller prevents this from being called after init */
 static void * __ref mca_bootmem(void)
 {
-	return __alloc_bootmem(sizeof(struct ia64_mca_cpu),
-	                    KERNEL_STACK_SIZE, 0);
+	return memblock_alloc_from(sizeof(struct ia64_mca_cpu),
+				   KERNEL_STACK_SIZE, 0);
 }
 
 /* Do per-CPU MCA-related initialization.  */
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index e2e40bb..9e5c23a 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -85,8 +85,9 @@ void *per_cpu_init(void)
 static inline void
 alloc_per_cpu_data(void)
 {
-	cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * num_possible_cpus(),
-				   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	cpu_data = memblock_alloc_from(PERCPU_PAGE_SIZE * num_possible_cpus(),
+				       PERCPU_PAGE_SIZE,
+				       __pa(MAX_DMA_ADDRESS));
 }
 
 /**
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 5feef28..623dc18 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -2263,7 +2263,7 @@ void __init trap_init(void)
 
 		memblock_set_bottom_up(true);
 		ebase = (unsigned long)
-			__alloc_bootmem(size, 1 << fls(size), 0);
+			memblock_alloc_from(size, 1 << fls(size), 0);
 		memblock_set_bottom_up(false);
 
 		/*
diff --git a/arch/sparc/kernel/prom_32.c b/arch/sparc/kernel/prom_32.c
index b51cbb9..4389944 100644
--- a/arch/sparc/kernel/prom_32.c
+++ b/arch/sparc/kernel/prom_32.c
@@ -32,7 +32,7 @@ void * __init prom_early_alloc(unsigned long size)
 {
 	void *ret;
 
-	ret = __alloc_bootmem(size, SMP_CACHE_BYTES, 0UL);
+	ret = memblock_alloc_from(size, SMP_CACHE_BYTES, 0UL);
 	if (ret != NULL)
 		memset(ret, 0, size);
 
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index 83ff88d..337febd 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -1588,7 +1588,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, size_t size,
 	void *ptr;
 
 	if (!node_online(node) || !NODE_DATA(node)) {
-		ptr = __alloc_bootmem(size, align, goal);
+		ptr = memblock_alloc_from(size, align, goal);
 		pr_info("cpu %d has no node %d or node-local memory\n",
 			cpu, node);
 		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
@@ -1601,7 +1601,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, size_t size,
 	}
 	return ptr;
 #else
-	return __alloc_bootmem(size, align, goal);
+	return memblock_alloc_from(size, align, goal);
 #endif
 }
 
@@ -1627,7 +1627,7 @@ static void __init pcpu_populate_pte(unsigned long addr)
 	if (pgd_none(*pgd)) {
 		pud_t *new;
 
-		new = __alloc_bootmem(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
+		new = memblock_alloc_from(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
 		pgd_populate(&init_mm, pgd, new);
 	}
 
@@ -1635,7 +1635,7 @@ static void __init pcpu_populate_pte(unsigned long addr)
 	if (pud_none(*pud)) {
 		pmd_t *new;
 
-		new = __alloc_bootmem(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
+		new = memblock_alloc_from(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
 		pud_populate(&init_mm, pud, new);
 	}
 
@@ -1643,7 +1643,7 @@ static void __init pcpu_populate_pte(unsigned long addr)
 	if (!pmd_present(*pmd)) {
 		pte_t *new;
 
-		new = __alloc_bootmem(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
+		new = memblock_alloc_from(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
 		pmd_populate_kernel(&init_mm, pmd, new);
 	}
 }
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 92634d4..885dd38 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -265,7 +265,7 @@ void __init mem_init(void)
 	i = last_valid_pfn >> ((20 - PAGE_SHIFT) + 5);
 	i += 1;
 	sparc_valid_addr_bitmap = (unsigned long *)
-		__alloc_bootmem(i << 2, SMP_CACHE_BYTES, 0UL);
+		memblock_alloc_from(i << 2, SMP_CACHE_BYTES, 0UL);
 
 	if (sparc_valid_addr_bitmap == NULL) {
 		prom_printf("mem_init: Cannot alloc valid_addr_bitmap.\n");
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 578ec3d..51cd583 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -1810,7 +1810,8 @@ static unsigned long __ref kernel_map_range(unsigned long pstart,
 		if (pgd_none(*pgd)) {
 			pud_t *new;
 
-			new = __alloc_bootmem(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
+			new = memblock_alloc_from(PAGE_SIZE, PAGE_SIZE,
+						  PAGE_SIZE);
 			alloc_bytes += PAGE_SIZE;
 			pgd_populate(&init_mm, pgd, new);
 		}
@@ -1822,7 +1823,8 @@ static unsigned long __ref kernel_map_range(unsigned long pstart,
 				vstart = kernel_map_hugepud(vstart, vend, pud);
 				continue;
 			}
-			new = __alloc_bootmem(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
+			new = memblock_alloc_from(PAGE_SIZE, PAGE_SIZE,
+						  PAGE_SIZE);
 			alloc_bytes += PAGE_SIZE;
 			pud_populate(&init_mm, pud, new);
 		}
@@ -1835,7 +1837,8 @@ static unsigned long __ref kernel_map_range(unsigned long pstart,
 				vstart = kernel_map_hugepmd(vstart, vend, pmd);
 				continue;
 			}
-			new = __alloc_bootmem(PAGE_SIZE, PAGE_SIZE, PAGE_SIZE);
+			new = memblock_alloc_from(PAGE_SIZE, PAGE_SIZE,
+						  PAGE_SIZE);
 			alloc_bytes += PAGE_SIZE;
 			pmd_populate_kernel(&init_mm, pmd, new);
 		}
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index be9cb00..b48fea5 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -303,13 +303,13 @@ static void __init srmmu_nocache_init(void)
 
 	bitmap_bits = srmmu_nocache_size >> SRMMU_NOCACHE_BITMAP_SHIFT;
 
-	srmmu_nocache_pool = __alloc_bootmem(srmmu_nocache_size,
-		SRMMU_NOCACHE_ALIGN_MAX, 0UL);
+	srmmu_nocache_pool = memblock_alloc_from(srmmu_nocache_size,
+						 SRMMU_NOCACHE_ALIGN_MAX, 0UL);
 	memset(srmmu_nocache_pool, 0, srmmu_nocache_size);
 
 	srmmu_nocache_bitmap =
-		__alloc_bootmem(BITS_TO_LONGS(bitmap_bits) * sizeof(long),
-				SMP_CACHE_BYTES, 0UL);
+		memblock_alloc_from(BITS_TO_LONGS(bitmap_bits) * sizeof(long),
+				    SMP_CACHE_BYTES, 0UL);
 	bit_map_init(&srmmu_nocache_map, srmmu_nocache_bitmap, bitmap_bits);
 
 	srmmu_swapper_pg_dir = __srmmu_get_nocache(SRMMU_PGD_TABLE_SIZE, SRMMU_PGD_TABLE_SIZE);
@@ -467,7 +467,7 @@ static void __init sparc_context_init(int numctx)
 	unsigned long size;
 
 	size = numctx * sizeof(struct ctx_list);
-	ctx_list_pool = __alloc_bootmem(size, SMP_CACHE_BYTES, 0UL);
+	ctx_list_pool = memblock_alloc_from(size, SMP_CACHE_BYTES, 0UL);
 
 	for (ctx = 0; ctx < numctx; ctx++) {
 		struct ctx_list *clist;
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 3896af2..c97c105 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -122,6 +122,14 @@ static inline void * __init memblock_alloc_raw(
 					    NUMA_NO_NODE);
 }
 
+static inline void * __init memblock_alloc_from(
+		phys_addr_t size, phys_addr_t align, phys_addr_t min_addr)
+{
+	return memblock_alloc_try_nid(size, align, min_addr,
+				      BOOTMEM_ALLOC_ACCESSIBLE,
+				      NUMA_NO_NODE);
+}
+
 static inline void * __init memblock_alloc_nopanic(
 					phys_addr_t size, phys_addr_t align)
 {
-- 
2.7.4
