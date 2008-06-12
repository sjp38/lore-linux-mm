Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5CIsBtV029131
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:54:11 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5CIrtQ5104388
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 12:54:05 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5CIrr7s016520
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 12:53:55 -0600
Subject: [RFC PATCH 1/2] Merge options into CONFIG_HUGETLB
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1213296540.17108.8.camel@localhost.localdomain>
References: <1213296540.17108.8.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 12 Jun 2008 14:53:47 -0400
Message-Id: <1213296827.17108.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: agl@us.ibm.com, npiggin@suse.de, nacc@us.ibm.com, mel@csn.ul.ie, Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

Merge CONFIG_HUGETLB_PAGE and CONFIG_HUGETLBFS into one new config option:
CONFIG_HUGETLB.  CONFIG_HUGETLB_PAGE is aliased to the value of
CONFIG_HUGETLBFS, so one option can be removed without any effect.  This change
is pretty mechanical, but a little extra verification from arch maintainers
would be very helpful.  Thanks.

Signed-off-by: Adam Litke <agl@us.ibm.com>

--

 Documentation/vm/hugetlbpage.txt       |    6 ++----
 arch/arm/mm/consistent.c               |    2 +-
 arch/avr32/mm/dma-coherent.c           |    2 +-
 arch/ia64/Kconfig                      |    8 ++++----
 arch/ia64/kernel/ivt.S                 |    6 +++---
 arch/ia64/kernel/sys_ia64.c            |    2 +-
 arch/ia64/mm/Makefile                  |    2 +-
 arch/ia64/mm/init.c                    |    2 +-
 arch/powerpc/Kconfig                   |    2 +-
 arch/powerpc/mm/Makefile               |    2 +-
 arch/powerpc/mm/hash_utils_64.c        |   10 +++++-----
 arch/powerpc/mm/init_64.c              |    2 +-
 arch/powerpc/mm/tlb_64.c               |    2 +-
 arch/powerpc/platforms/Kconfig.cputype |    2 +-
 arch/s390/mm/Makefile                  |    2 +-
 arch/sh/mm/Kconfig                     |    2 +-
 arch/sh/mm/Makefile_32                 |    2 +-
 arch/sh/mm/Makefile_64                 |    2 +-
 arch/sparc64/Kconfig                   |    2 +-
 arch/sparc64/kernel/sun4v_tlb_miss.S   |    2 +-
 arch/sparc64/kernel/tsb.S              |    4 ++--
 arch/sparc64/mm/Makefile               |    2 +-
 arch/sparc64/mm/fault.c                |    4 ++--
 arch/sparc64/mm/init.c                 |    2 +-
 arch/sparc64/mm/tsb.c                  |   14 +++++++-------
 arch/x86/mm/Makefile                   |    2 +-
 fs/Kconfig                             |    5 +----
 fs/Makefile                            |    2 +-
 fs/hugetlbfs/Makefile                  |    2 +-
 include/asm-ia64/mmu_context.h         |    2 +-
 include/asm-ia64/page.h                |    6 +++---
 include/asm-ia64/pgtable.h             |    2 +-
 include/asm-mn10300/page.h             |    2 +-
 include/asm-parisc/page.h              |    2 +-
 include/asm-powerpc/mmu-hash64.h       |    4 ++--
 include/asm-powerpc/page_64.h          |    6 +++---
 include/asm-powerpc/pgtable-ppc64.h    |    2 +-
 include/asm-sh/page.h                  |    2 +-
 include/asm-sparc64/mmu.h              |    2 +-
 include/asm-sparc64/mmu_context.h      |    2 +-
 include/asm-sparc64/page.h             |    2 +-
 include/asm-sparc64/pgtable.h          |    2 +-
 include/asm-x86/page_32.h              |    2 +-
 include/linux/hugetlb.h                |   12 ++++++------
 include/linux/pageblock-flags.h        |    6 +++---
 include/linux/vmstat.h                 |    2 +-
 kernel/sysctl.c                        |    2 +-
 mm/Makefile                            |    2 +-
 mm/mempolicy.c                         |    4 ++--
 mm/vmstat.c                            |    2 +-
 50 files changed, 81 insertions(+), 86 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index 3102b81..53604e9 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -13,10 +13,8 @@ This optimization is more critical now as bigger and bigger physical memories
 Users can use the huge page support in Linux kernel by either using the mmap
 system call or standard SYSv shared memory system calls (shmget, shmat).
 
-First the Linux kernel needs to be built with the CONFIG_HUGETLBFS
-(present under "File systems") and CONFIG_HUGETLB_PAGE (selected
-automatically when CONFIG_HUGETLBFS is selected) configuration
-options.
+First the Linux kernel needs to be built with the CONFIG_HUGETLB
+(present under "File systems") configuration option.
 
 The kernel built with hugepage support should show the number of configured
 hugepages in the system by running the "cat /proc/meminfo" command.
diff --git a/arch/arm/mm/consistent.c b/arch/arm/mm/consistent.c
index 333a82a..5931192 100644
--- a/arch/arm/mm/consistent.c
+++ b/arch/arm/mm/consistent.c
@@ -140,7 +140,7 @@ static struct vm_region *vm_region_find(struct vm_region *head, unsigned long ad
 	return c;
 }
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #error ARM Coherent DMA allocator does not (yet) support huge TLB
 #endif
 
diff --git a/arch/avr32/mm/dma-coherent.c b/arch/avr32/mm/dma-coherent.c
index 6d8c794..0cf57c6 100644
--- a/arch/avr32/mm/dma-coherent.c
+++ b/arch/avr32/mm/dma-coherent.c
@@ -45,7 +45,7 @@ static struct page *__dma_alloc(struct device *dev, size_t size,
 	 * with __GFP_COMP being passed to split_page() which cannot
 	 * handle them.  The real problem is that this flag probably
 	 * should be 0 on AVR32 as it is not supported on this
-	 * platform--see CONFIG_HUGETLB_PAGE. */
+	 * platform--see CONFIG_HUGETLB. */
 	gfp &= ~(__GFP_COMP);
 
 	size = PAGE_ALIGN(size);
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 16be414..b9445b9 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -70,7 +70,7 @@ config ARCH_HAS_ILOG2_U64
 
 config HUGETLB_PAGE_SIZE_VARIABLE
 	bool
-	depends on HUGETLB_PAGE
+	depends on HUGETLB
 	default y
 
 config GENERIC_FIND_NEXT_BIT
@@ -285,9 +285,9 @@ config IOSAPIC
 	default y
 
 config FORCE_MAX_ZONEORDER
-	int "MAX_ORDER (11 - 17)"  if !HUGETLB_PAGE
-	range 11 17  if !HUGETLB_PAGE
-	default "17" if HUGETLB_PAGE
+	int "MAX_ORDER (11 - 17)"  if !HUGETLB
+	range 11 17  if !HUGETLB
+	default "17" if HUGETLB
 	default "11"
 
 config VIRT_CPU_ACCOUNTING
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 80b44ea..ddf7778 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -103,7 +103,7 @@ ENTRY(vhpt_miss)
 	 *	- the faulting virtual address has no valid page table mapping
 	 */
 	mov r16=cr.ifa				// get address that caused the TLB miss
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	movl r18=PAGE_SHIFT
 	mov r25=cr.itir
 #endif
@@ -115,7 +115,7 @@ ENTRY(vhpt_miss)
 	shr.u r17=r16,61			// get the region number into r17
 	;;
 	shr.u r22=r21,3
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	extr.u r26=r25,2,6
 	;;
 	cmp.ne p8,p0=r18,r26
@@ -181,7 +181,7 @@ ENTRY(vhpt_miss)
 (p6)	br.cond.spnt.many page_fault		// handle bad address/page not present (page fault)
 	mov cr.ifa=r22
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 (p8)	mov cr.itir=r25				// change to default page-size for VHPT
 #endif
 
diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index 1eda194..490c1ce 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -39,7 +39,7 @@ arch_get_unmapped_area (struct file *filp, unsigned long addr, unsigned long len
 		return addr;
 	}
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	if (REGION_NUMBER(addr) == RGN_HPAGE)
 		addr = 0;
 #endif
diff --git a/arch/ia64/mm/Makefile b/arch/ia64/mm/Makefile
index bb0a01a..03a7b0e 100644
--- a/arch/ia64/mm/Makefile
+++ b/arch/ia64/mm/Makefile
@@ -4,7 +4,7 @@
 
 obj-y := init.o fault.o tlb.o extable.o ioremap.o
 
-obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
+obj-$(CONFIG_HUGETLB)      += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
 obj-$(CONFIG_DISCONTIGMEM) += discontig.o
 obj-$(CONFIG_SPARSEMEM)	   += discontig.o
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 200100e..976d992 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -357,7 +357,7 @@ ia64_mmu_init (void *my_cpu_data)
 
 	ia64_tlb_init();
 
-#ifdef	CONFIG_HUGETLB_PAGE
+#ifdef	CONFIG_HUGETLB
 	ia64_set_rr(HPAGE_REGION_BASE, HPAGE_SHIFT << 2);
 	ia64_srlz_d();
 #endif
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 3934e26..3c0abd1 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -231,7 +231,7 @@ source "fs/Kconfig.binfmt"
 
 config HUGETLB_PAGE_SIZE_VARIABLE
 	bool
-	depends on HUGETLB_PAGE
+	depends on HUGETLB
 	default y
 
 config MATH_EMULATION
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 1c00e01..fc51157 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -21,5 +21,5 @@ obj-$(CONFIG_44x)		+= 44x_mmu.o
 obj-$(CONFIG_FSL_BOOKE)		+= fsl_booke_mmu.o
 obj-$(CONFIG_NEED_MULTIPLE_NODES) += numa.o
 obj-$(CONFIG_PPC_MM_SLICES)	+= slice.o
-obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
+obj-$(CONFIG_HUGETLB)		+= hugetlbpage.o
 obj-$(CONFIG_PPC_SUBPAGE_PROT)	+= subpage-prot.o
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 0f2d239..37d8296 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -101,7 +101,7 @@ int mmu_io_psize = MMU_PAGE_4K;
 int mmu_kernel_ssize = MMU_SEGSIZE_256M;
 int mmu_highuser_ssize = MMU_SEGSIZE_256M;
 u16 mmu_slb_size = 64;
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 int mmu_huge_psize = MMU_PAGE_16M;
 unsigned int HPAGE_SHIFT;
 #endif
@@ -417,7 +417,7 @@ static void __init htab_init_page_sizes(void)
 #endif
 	       );
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	/* Init large page size. Currently, we pick 16M or 1M depending
 	 * on what is available
 	 */
@@ -427,7 +427,7 @@ static void __init htab_init_page_sizes(void)
 	 * huge page size < PMD_SIZE */
 	else if (mmu_psize_defs[MMU_PAGE_1M].shift)
 		set_huge_psize(MMU_PAGE_1M);
-#endif /* CONFIG_HUGETLB_PAGE */
+#endif /* CONFIG_HUGETLB */
 }
 
 static int __init htab_dt_scan_pftsize(unsigned long node,
@@ -829,13 +829,13 @@ int hash_page(unsigned long ea, unsigned long access, unsigned long trap)
 	if (user_region && cpus_equal(mm->cpu_vm_mask, tmp))
 		local = 1;
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	/* Handle hugepage regions */
 	if (HPAGE_SHIFT && psize == mmu_huge_psize) {
 		DBG_LOW(" -> huge page !\n");
 		return hash_huge_page(mm, access, ea, vsid, local, trap);
 	}
-#endif /* CONFIG_HUGETLB_PAGE */
+#endif /* CONFIG_HUGETLB */
 
 #ifndef CONFIG_PPC_64K_PAGES
 	/* If we use 4K pages and our psize is not 4K, then we are hitting
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 6aa6537..03b9c1f 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -152,7 +152,7 @@ static const char *pgtable_cache_name[ARRAY_SIZE(pgtable_cache_size)] = {
 #endif /* CONFIG_PPC_64K_PAGES */
 };
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 /* Hugepages need one extra cache, initialized in hugetlbpage.c.  We
  * can't put into the tables above, because HPAGE_SHIFT is not compile
  * time constant. */
diff --git a/arch/powerpc/mm/tlb_64.c b/arch/powerpc/mm/tlb_64.c
index e2d867c..6494eb3 100644
--- a/arch/powerpc/mm/tlb_64.c
+++ b/arch/powerpc/mm/tlb_64.c
@@ -149,7 +149,7 @@ void hpte_need_flush(struct mm_struct *mm, unsigned long addr,
 	 * of this call
 	 */
 	if (huge) {
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 		psize = mmu_huge_psize;
 #else
 		BUG();
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index f7efaa9..7081354 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -182,7 +182,7 @@ config PPC_STD_MMU_32
 
 config PPC_MM_SLICES
 	bool
-	default y if HUGETLB_PAGE
+	default y if HUGETLB
 	default n
 
 config VIRT_CPU_ACCOUNTING
diff --git a/arch/s390/mm/Makefile b/arch/s390/mm/Makefile
index 2a74581..883aded 100644
--- a/arch/s390/mm/Makefile
+++ b/arch/s390/mm/Makefile
@@ -4,5 +4,5 @@
 
 obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o
 obj-$(CONFIG_CMM) += cmm.o
-obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
+obj-$(CONFIG_HUGETLB) += hugetlbpage.o
 obj-$(CONFIG_PAGE_STATES) += page-states.o
diff --git a/arch/sh/mm/Kconfig b/arch/sh/mm/Kconfig
index 5fd2184..3f49d45 100644
--- a/arch/sh/mm/Kconfig
+++ b/arch/sh/mm/Kconfig
@@ -166,7 +166,7 @@ endchoice
 
 choice
 	prompt "HugeTLB page size"
-	depends on HUGETLB_PAGE && (CPU_SH4 || CPU_SH5) && MMU
+	depends on HUGETLB && (CPU_SH4 || CPU_SH5) && MMU
 	default HUGETLB_PAGE_SIZE_64K
 
 config HUGETLB_PAGE_SIZE_64K
diff --git a/arch/sh/mm/Makefile_32 b/arch/sh/mm/Makefile_32
index e295db6..ff58abc 100644
--- a/arch/sh/mm/Makefile_32
+++ b/arch/sh/mm/Makefile_32
@@ -29,7 +29,7 @@ obj-$(CONFIG_SH7705_CACHE_32KB)	+= pg-sh7705.o
 endif
 endif
 
-obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
+obj-$(CONFIG_HUGETLB)		+= hugetlbpage.o
 obj-$(CONFIG_PMB)		+= pmb.o
 obj-$(CONFIG_NUMA)		+= numa.o
 
diff --git a/arch/sh/mm/Makefile_64 b/arch/sh/mm/Makefile_64
index 0d92a8a..06b7a6b 100644
--- a/arch/sh/mm/Makefile_64
+++ b/arch/sh/mm/Makefile_64
@@ -14,7 +14,7 @@ endif
 
 obj-y			+= $(mmu-y)
 
-obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
+obj-$(CONFIG_HUGETLB)		+= hugetlbpage.o
 obj-$(CONFIG_NUMA)		+= numa.o
 
 EXTRA_CFLAGS += -Werror
diff --git a/arch/sparc64/Kconfig b/arch/sparc64/Kconfig
index eb36f3b..a004e2c 100644
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -216,7 +216,7 @@ config GENERIC_CALIBRATE_DELAY
 
 choice
 	prompt "SPARC64 Huge TLB Page Size"
-	depends on HUGETLB_PAGE
+	depends on HUGETLB
 	default HUGETLB_PAGE_SIZE_4MB
 
 config HUGETLB_PAGE_SIZE_4MB
diff --git a/arch/sparc64/kernel/sun4v_tlb_miss.S b/arch/sparc64/kernel/sun4v_tlb_miss.S
index e1fbf8c..152bf74 100644
--- a/arch/sparc64/kernel/sun4v_tlb_miss.S
+++ b/arch/sparc64/kernel/sun4v_tlb_miss.S
@@ -176,7 +176,7 @@ sun4v_tsb_miss_common:
 
 	sub	%g2, TRAP_PER_CPU_FAULT_INFO, %g2
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	mov	SCRATCHPAD_UTSBREG2, %g5
 	ldxa	[%g5] ASI_SCRATCHPAD, %g5
 	cmp	%g5, -1
diff --git a/arch/sparc64/kernel/tsb.S b/arch/sparc64/kernel/tsb.S
index c499214..84ad9a6 100644
--- a/arch/sparc64/kernel/tsb.S
+++ b/arch/sparc64/kernel/tsb.S
@@ -49,7 +49,7 @@ tsb_miss_page_table_walk:
 	/* Before committing to a full page table walk,
 	 * check the huge page TSB.
 	 */
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 
 661:	ldx		[%g7 + TRAP_PER_CPU_TSB_HUGE], %g5
 	nop
@@ -115,7 +115,7 @@ tsb_miss_page_table_walk_sun4v_fastpath:
 	brgez,pn	%g5, tsb_do_fault
 	 nop
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 661:	sethi		%uhi(_PAGE_SZALL_4U), %g7
 	sllx		%g7, 32, %g7
 	.section	.sun4v_2insn_patch, "ax"
diff --git a/arch/sparc64/mm/Makefile b/arch/sparc64/mm/Makefile
index 68d04c0..2c7f7ce 100644
--- a/arch/sparc64/mm/Makefile
+++ b/arch/sparc64/mm/Makefile
@@ -6,4 +6,4 @@ EXTRA_CFLAGS := -Werror
 
 obj-y    := ultra.o tlb.o tsb.o fault.o init.o generic.o
 
-obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
+obj-$(CONFIG_HUGETLB) += hugetlbpage.o
diff --git a/arch/sparc64/mm/fault.c b/arch/sparc64/mm/fault.c
index 236f4d2..5b7b706 100644
--- a/arch/sparc64/mm/fault.c
+++ b/arch/sparc64/mm/fault.c
@@ -420,13 +420,13 @@ good_area:
 	up_read(&mm->mmap_sem);
 
 	mm_rss = get_mm_rss(mm);
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	mm_rss -= (mm->context.huge_pte_count * (HPAGE_SIZE / PAGE_SIZE));
 #endif
 	if (unlikely(mm_rss >
 		     mm->context.tsb_block[MM_TSB_BASE].tsb_rss_limit))
 		tsb_grow(mm, MM_TSB_BASE, mm_rss);
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	mm_rss = mm->context.huge_pte_count;
 	if (unlikely(mm_rss >
 		     mm->context.tsb_block[MM_TSB_HUGE].tsb_rss_limit))
diff --git a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
index 84898c4..a8c10a7 100644
--- a/arch/sparc64/mm/init.c
+++ b/arch/sparc64/mm/init.c
@@ -303,7 +303,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address, pte_t p
 
 	spin_lock_irqsave(&mm->context.lock, flags);
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	if (mm->context.tsb_block[MM_TSB_HUGE].tsb != NULL) {
 		if ((tlb_type == hypervisor &&
 		     (pte_val(pte) & _PAGE_SZALL_4V) == _PAGE_SZHUGE_4V) ||
diff --git a/arch/sparc64/mm/tsb.c b/arch/sparc64/mm/tsb.c
index fe70c8a..9b65f4a 100644
--- a/arch/sparc64/mm/tsb.c
+++ b/arch/sparc64/mm/tsb.c
@@ -78,7 +78,7 @@ void flush_tsb_user(struct mmu_gather *mp)
 		base = __pa(base);
 	__flush_tsb_one(mp, PAGE_SHIFT, base, nentries);
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	if (mm->context.tsb_block[MM_TSB_HUGE].tsb) {
 		base = (unsigned long) mm->context.tsb_block[MM_TSB_HUGE].tsb;
 		nentries = mm->context.tsb_block[MM_TSB_HUGE].tsb_nentries;
@@ -106,7 +106,7 @@ void flush_tsb_user(struct mmu_gather *mp)
 #error Broken base page size setting...
 #endif
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #if defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
 #define HV_PGSZ_IDX_HUGE	HV_PGSZ_IDX_64K
 #define HV_PGSZ_MASK_HUGE	HV_PGSZ_MASK_64K
@@ -213,7 +213,7 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 		case MM_TSB_BASE:
 			hp->pgsz_idx = HV_PGSZ_IDX_BASE;
 			break;
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 		case MM_TSB_HUGE:
 			hp->pgsz_idx = HV_PGSZ_IDX_HUGE;
 			break;
@@ -228,7 +228,7 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 		case MM_TSB_BASE:
 			hp->pgsz_mask = HV_PGSZ_MASK_BASE;
 			break;
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 		case MM_TSB_HUGE:
 			hp->pgsz_mask = HV_PGSZ_MASK_HUGE;
 			break;
@@ -430,7 +430,7 @@ retry_tsb_alloc:
 
 int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 {
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	unsigned long huge_pte_count;
 #endif
 	unsigned int i;
@@ -439,7 +439,7 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 
 	mm->context.sparc64_ctx_val = 0UL;
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	/* We reset it to zero because the fork() page copying
 	 * will re-increment the counters as the parent PTEs are
 	 * copied into the child address space.
@@ -460,7 +460,7 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	tsb_grow(mm, MM_TSB_BASE, get_mm_rss(mm));
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	if (unlikely(huge_pte_count))
 		tsb_grow(mm, MM_TSB_HUGE, huge_pte_count);
 #endif
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index b7b3e4c..e5ecc68 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -3,7 +3,7 @@ obj-y	:=  init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
 
 obj-$(CONFIG_X86_32)		+= pgtable_32.o
 
-obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
+obj-$(CONFIG_HUGETLB)		+= hugetlbpage.o
 obj-$(CONFIG_X86_PTDUMP)	+= dump_pagetables.o
 
 obj-$(CONFIG_HIGHMEM)		+= highmem_32.o
diff --git a/fs/Kconfig b/fs/Kconfig
index cf12c40..c8e9176 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1003,7 +1003,7 @@ config TMPFS_POSIX_ACL
 
 	  If you don't know what Access Control Lists are, say N.
 
-config HUGETLBFS
+config HUGETLB
 	bool "HugeTLB file system support"
 	depends on X86 || IA64 || PPC64 || SPARC64 || (SUPERH && MMU) || \
 		   (S390 && 64BIT) || BROKEN
@@ -1014,9 +1014,6 @@ config HUGETLBFS
 
 	  If unsure, say N.
 
-config HUGETLB_PAGE
-	def_bool HUGETLBFS
-
 config CONFIGFS_FS
 	tristate "Userspace-driven configuration filesystem"
 	depends on SYSFS
diff --git a/fs/Makefile b/fs/Makefile
index 1e7a11b..aa6708a 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -74,7 +74,7 @@ obj-$(CONFIG_JBD2)		+= jbd2/
 obj-$(CONFIG_EXT2_FS)		+= ext2/
 obj-$(CONFIG_CRAMFS)		+= cramfs/
 obj-y				+= ramfs/
-obj-$(CONFIG_HUGETLBFS)		+= hugetlbfs/
+obj-$(CONFIG_HUGETLB)		+= hugetlbfs/
 obj-$(CONFIG_CODA_FS)		+= coda/
 obj-$(CONFIG_MINIX_FS)		+= minix/
 obj-$(CONFIG_FAT_FS)		+= fat/
diff --git a/fs/hugetlbfs/Makefile b/fs/hugetlbfs/Makefile
index 6adf870..87f547c 100644
--- a/fs/hugetlbfs/Makefile
+++ b/fs/hugetlbfs/Makefile
@@ -2,6 +2,6 @@
 # Makefile for the linux ramfs routines.
 #
 
-obj-$(CONFIG_HUGETLBFS) += hugetlbfs.o
+obj-$(CONFIG_HUGETLB) += hugetlbfs.o
 
 hugetlbfs-objs := inode.o
diff --git a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
index cef2400..1fc64e1 100644
--- a/include/asm-ia64/mmu_context.h
+++ b/include/asm-ia64/mmu_context.h
@@ -144,7 +144,7 @@ reload_context (nv_mm_context_t context)
 	rr2 = rr0 + 2*rid_incr;
 	rr3 = rr0 + 3*rid_incr;
 	rr4 = rr0 + 4*rid_incr;
-#ifdef  CONFIG_HUGETLB_PAGE
+#ifdef  CONFIG_HUGETLB
 	rr4 = (rr4 & (~(0xfcUL))) | (old_rr4 & 0xfc);
 
 #  if RGN_HPAGE != 4
diff --git a/include/asm-ia64/page.h b/include/asm-ia64/page.h
index 36f3932..ab0d657 100644
--- a/include/asm-ia64/page.h
+++ b/include/asm-ia64/page.h
@@ -46,7 +46,7 @@
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
 
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 # define HPAGE_REGION_BASE	RGN_BASE(RGN_HPAGE)
 # define HPAGE_SHIFT		hpage_shift
 # define HPAGE_SHIFT_DEFAULT	28	/* check ia64 SDM for architecture supported size */
@@ -54,7 +54,7 @@
 # define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 
 # define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
-#endif /* CONFIG_HUGETLB_PAGE */
+#endif /* CONFIG_HUGETLB */
 
 #ifdef __ASSEMBLY__
 # define __pa(x)		((x) - PAGE_OFFSET)
@@ -146,7 +146,7 @@ typedef union ia64_va {
 #define REGION_NUMBER(x)	({ia64_va _v; _v.l = (long) (x); _v.f.reg;})
 #define REGION_OFFSET(x)	({ia64_va _v; _v.l = (long) (x); _v.f.off;})
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 # define htlbpage_to_page(x)	(((unsigned long) REGION_NUMBER(x) << 61)			\
 				 | (REGION_OFFSET(x) >> (HPAGE_SHIFT-PAGE_SHIFT)))
 # define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
diff --git a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
index 7a9bff4..53ccb4c 100644
--- a/include/asm-ia64/pgtable.h
+++ b/include/asm-ia64/pgtable.h
@@ -510,7 +510,7 @@ extern struct page *zero_page_memmap_ptr;
 /* We provide our own get_unmapped_area to cope with VA holes for userland */
 #define HAVE_ARCH_UNMAPPED_AREA
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #define HUGETLB_PGDIR_SHIFT	(HPAGE_SHIFT + 2*(PAGE_SHIFT-3))
 #define HUGETLB_PGDIR_SIZE	(__IA64_UL(1) << HUGETLB_PGDIR_SHIFT)
 #define HUGETLB_PGDIR_MASK	(~(HUGETLB_PGDIR_SIZE-1))
diff --git a/include/asm-mn10300/page.h b/include/asm-mn10300/page.h
index 124971b..5cb71cf 100644
--- a/include/asm-mn10300/page.h
+++ b/include/asm-mn10300/page.h
@@ -43,7 +43,7 @@ typedef struct page *pgtable_t;
 #define PTE_MASK	PAGE_MASK
 #define HPAGE_SHIFT	22
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #define HPAGE_SIZE		((1UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
diff --git a/include/asm-parisc/page.h b/include/asm-parisc/page.h
index 27d50b8..1f99754 100644
--- a/include/asm-parisc/page.h
+++ b/include/asm-parisc/page.h
@@ -156,7 +156,7 @@ extern int npmem_ranges;
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
 #endif /* CONFIG_DISCONTIGMEM */
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #define HPAGE_SHIFT		22	/* 4MB (is this fixed?) */
 #define HPAGE_SIZE      	((1UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
diff --git a/include/asm-powerpc/mmu-hash64.h b/include/asm-powerpc/mmu-hash64.h
index 39c5c5f..12bc742 100644
--- a/include/asm-powerpc/mmu-hash64.h
+++ b/include/asm-powerpc/mmu-hash64.h
@@ -191,13 +191,13 @@ extern u16 mmu_slb_size;
  */
 extern int mmu_ci_restrictions;
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 /*
  * The page size index of the huge pages for use by hugetlbfs
  */
 extern int mmu_huge_psize;
 
-#endif /* CONFIG_HUGETLB_PAGE */
+#endif /* CONFIG_HUGETLB */
 
 /*
  * This function sets the AVPN and L fields of the HPTE  appropriately
diff --git a/include/asm-powerpc/page_64.h b/include/asm-powerpc/page_64.h
index 25af4fc..f7aeae4 100644
--- a/include/asm-powerpc/page_64.h
+++ b/include/asm-powerpc/page_64.h
@@ -82,7 +82,7 @@ static inline void copy_page(void *to, void *from)
 extern u64 ppc64_pft_size;
 
 /* Large pages size */
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 extern unsigned int HPAGE_SHIFT;
 #else
 #define HPAGE_SHIFT PAGE_SHIFT
@@ -139,11 +139,11 @@ do {						\
 #define slice_mm_new_context(mm)	1
 #endif /* CONFIG_PPC_MM_SLICES */
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 
 #define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 
-#endif /* !CONFIG_HUGETLB_PAGE */
+#endif /* !CONFIG_HUGETLB */
 
 #ifdef MODULE
 #define __page_aligned __attribute__((__aligned__(PAGE_SIZE)))
diff --git a/include/asm-powerpc/pgtable-ppc64.h b/include/asm-powerpc/pgtable-ppc64.h
index cc6a43b..ac59e5b 100644
--- a/include/asm-powerpc/pgtable-ppc64.h
+++ b/include/asm-powerpc/pgtable-ppc64.h
@@ -147,7 +147,7 @@
 #define __S110	PAGE_SHARED_X
 #define __S111	PAGE_SHARED_X
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 
 #define HAVE_ARCH_UNMAPPED_AREA
 #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
diff --git a/include/asm-sh/page.h b/include/asm-sh/page.h
index 304c30b..72091b3 100644
--- a/include/asm-sh/page.h
+++ b/include/asm-sh/page.h
@@ -39,7 +39,7 @@
 #define HPAGE_SHIFT	29
 #endif
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #define HPAGE_SIZE		(1UL << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE-1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT-PAGE_SHIFT)
diff --git a/include/asm-sparc64/mmu.h b/include/asm-sparc64/mmu.h
index 8abc58f..e66eae1 100644
--- a/include/asm-sparc64/mmu.h
+++ b/include/asm-sparc64/mmu.h
@@ -100,7 +100,7 @@ struct tsb_config {
 
 #define MM_TSB_BASE	0
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #define MM_TSB_HUGE	1
 #define MM_NUM_TSBS	2
 #else
diff --git a/include/asm-sparc64/mmu_context.h b/include/asm-sparc64/mmu_context.h
index 5693ab4..5496962 100644
--- a/include/asm-sparc64/mmu_context.h
+++ b/include/asm-sparc64/mmu_context.h
@@ -37,7 +37,7 @@ static inline void tsb_context_switch(struct mm_struct *mm)
 {
 	__tsb_context_switch(__pa(mm->pgd),
 			     &mm->context.tsb_block[0],
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 			     (mm->context.tsb_block[1].tsb ?
 			      &mm->context.tsb_block[1] :
 			      NULL)
diff --git a/include/asm-sparc64/page.h b/include/asm-sparc64/page.h
index 93f0881..9ef06d1 100644
--- a/include/asm-sparc64/page.h
+++ b/include/asm-sparc64/page.h
@@ -33,7 +33,7 @@
 #define HPAGE_SHIFT		16
 #endif
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #define HPAGE_SIZE		(_AC(1,UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1UL))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
diff --git a/include/asm-sparc64/pgtable.h b/include/asm-sparc64/pgtable.h
index b870177..76dda6a 100644
--- a/include/asm-sparc64/pgtable.h
+++ b/include/asm-sparc64/pgtable.h
@@ -356,7 +356,7 @@ static inline pgprot_t pgprot_noncached(pgprot_t prot)
  */
 #define pgprot_noncached pgprot_noncached
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 static inline pte_t pte_mkhuge(pte_t pte)
 {
 	unsigned long mask;
diff --git a/include/asm-x86/page_32.h b/include/asm-x86/page_32.h
index 424e82f..e3f952d 100644
--- a/include/asm-x86/page_32.h
+++ b/include/asm-x86/page_32.h
@@ -59,7 +59,7 @@ typedef union {
 typedef struct page *pgtable_t;
 #endif
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 #define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 #endif
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index a79e80b..e378785 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -3,7 +3,7 @@
 
 #include <linux/fs.h>
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 
 #include <linux/mempolicy.h>
 #include <linux/shm.h>
@@ -52,7 +52,7 @@ int pmd_huge(pmd_t pmd);
 void hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
-#else /* !CONFIG_HUGETLB_PAGE */
+#else /* !CONFIG_HUGETLB */
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
@@ -84,9 +84,9 @@ static inline unsigned long hugetlb_total_pages(void)
 #define HPAGE_SIZE	PAGE_SIZE
 #endif
 
-#endif /* !CONFIG_HUGETLB_PAGE */
+#endif /* !CONFIG_HUGETLB */
 
-#ifdef CONFIG_HUGETLBFS
+#ifdef CONFIG_HUGETLB
 struct hugetlbfs_config {
 	uid_t   uid;
 	gid_t   gid;
@@ -141,13 +141,13 @@ static inline void set_file_hugepages(struct file *file)
 {
 	file->f_op = &hugetlbfs_file_operations;
 }
-#else /* !CONFIG_HUGETLBFS */
+#else /* !CONFIG_HUGETLB */
 
 #define is_file_hugepages(file)		0
 #define set_file_hugepages(file)	BUG()
 #define hugetlb_file_setup(name,size)	ERR_PTR(-ENOSYS)
 
-#endif /* !CONFIG_HUGETLBFS */
+#endif /* !CONFIG_HUGETLB */
 
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index e875905..362f3cd 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -35,7 +35,7 @@ enum pageblock_bits {
 	NR_PAGEBLOCK_BITS
 };
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 
@@ -49,12 +49,12 @@ extern int pageblock_order;
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
-#else /* CONFIG_HUGETLB_PAGE */
+#else /* CONFIG_HUGETLB */
 
 /* If huge pages are not used, group by MAX_ORDER_NR_PAGES */
 #define pageblock_order		(MAX_ORDER-1)
 
-#endif /* CONFIG_HUGETLB_PAGE */
+#endif /* CONFIG_HUGETLB */
 
 #define pageblock_nr_pages	(1UL << pageblock_order)
 
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index e83b693..d2f6892 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -38,7 +38,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
 		NR_VM_EVENT_ITEMS
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2911665..9d35488 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -924,7 +924,7 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	 {
 		.procname	= "nr_hugepages",
 		.data		= &max_huge_pages,
diff --git a/mm/Makefile b/mm/Makefile
index 18c143b..f34a484 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -17,7 +17,7 @@ obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
-obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
+obj-$(CONFIG_HUGETLB)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a37a503..1c10f51 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1452,7 +1452,7 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 		return interleave_nodes(pol);
 }
 
-#ifdef CONFIG_HUGETLBFS
+#ifdef CONFIG_HUGETLB
 /*
  * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
  * @vma = virtual memory area whose policy is sought
@@ -2209,7 +2209,7 @@ static void gather_stats(struct page *page, void *private, int pte_dirty)
 	md->node[page_to_nid(page)]++;
 }
 
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 static void check_huge_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end,
 		struct numa_maps *md)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index db9eabb..4705147 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -653,7 +653,7 @@ static const char * const vmstat_text[] = {
 	"allocstall",
 
 	"pgrotated",
-#ifdef CONFIG_HUGETLB_PAGE
+#ifdef CONFIG_HUGETLB
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
 #endif


-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
