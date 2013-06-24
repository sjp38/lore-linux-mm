Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 4DC636B0039
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 04:25:45 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 24 Jun 2013 13:48:16 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 4399B3940058
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 13:55:39 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5O8PZ7x28442642
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 13:55:35 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5O8Pci2021583
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 18:25:38 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/3] powerpc: Contiguous memory allocator based hash page allocation
Date: Mon, 24 Jun 2013 13:55:26 +0530
Message-Id: <1372062327-7028-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1372062327-7028-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1372062327-7028-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Use CMA for allocation of guest hash page.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/kvm_book3s_64.h |   1 -
 arch/powerpc/include/asm/kvm_host.h      |   2 +-
 arch/powerpc/include/asm/kvm_ppc.h       |   8 +-
 arch/powerpc/kernel/setup_64.c           |   2 +
 arch/powerpc/kvm/Kconfig                 |   1 +
 arch/powerpc/kvm/Makefile                |   3 +
 arch/powerpc/kvm/book3s_64_mmu_hv.c      |  36 +++--
 arch/powerpc/kvm/book3s_hv_builtin.c     |  79 +++++++----
 arch/powerpc/kvm/book3s_hv_cma.c         | 220 +++++++++++++++++++++++++++++++
 arch/powerpc/kvm/book3s_hv_cma.h         |  21 +++
 10 files changed, 322 insertions(+), 51 deletions(-)
 create mode 100644 arch/powerpc/kvm/book3s_hv_cma.c
 create mode 100644 arch/powerpc/kvm/book3s_hv_cma.h

diff --git a/arch/powerpc/include/asm/kvm_book3s_64.h b/arch/powerpc/include/asm/kvm_book3s_64.h
index 9c1ff33..f8355a9 100644
--- a/arch/powerpc/include/asm/kvm_book3s_64.h
+++ b/arch/powerpc/include/asm/kvm_book3s_64.h
@@ -37,7 +37,6 @@ static inline void svcpu_put(struct kvmppc_book3s_shadow_vcpu *svcpu)
 
 #ifdef CONFIG_KVM_BOOK3S_64_HV
 #define KVM_DEFAULT_HPT_ORDER	24	/* 16MB HPT by default */
-extern int kvm_hpt_order;		/* order of preallocated HPTs */
 #endif
 
 #define VRMA_VSID	0x1ffffffUL	/* 1TB VSID reserved for VRMA */
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index af326cd..0097dab 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -259,7 +259,7 @@ struct kvm_arch {
 	spinlock_t slot_phys_lock;
 	cpumask_t need_tlb_flush;
 	struct kvmppc_vcore *vcores[KVM_MAX_VCORES];
-	struct kvmppc_linear_info *hpt_li;
+	int hpt_cma_alloc;
 #endif /* CONFIG_KVM_BOOK3S_64_HV */
 #ifdef CONFIG_PPC_BOOK3S_64
 	struct list_head spapr_tce_tables;
diff --git a/arch/powerpc/include/asm/kvm_ppc.h b/arch/powerpc/include/asm/kvm_ppc.h
index a5287fe..058ac93 100644
--- a/arch/powerpc/include/asm/kvm_ppc.h
+++ b/arch/powerpc/include/asm/kvm_ppc.h
@@ -139,8 +139,8 @@ extern long kvm_vm_ioctl_allocate_rma(struct kvm *kvm,
 				struct kvm_allocate_rma *rma);
 extern struct kvmppc_linear_info *kvm_alloc_rma(void);
 extern void kvm_release_rma(struct kvmppc_linear_info *ri);
-extern struct kvmppc_linear_info *kvm_alloc_hpt(void);
-extern void kvm_release_hpt(struct kvmppc_linear_info *li);
+extern struct page *kvm_alloc_hpt(int nr_pages);
+extern void kvm_release_hpt(struct page *page, int nr_pages);
 extern int kvmppc_core_init_vm(struct kvm *kvm);
 extern void kvmppc_core_destroy_vm(struct kvm *kvm);
 extern void kvmppc_core_free_memslot(struct kvm_memory_slot *free,
@@ -261,6 +261,7 @@ void kvmppc_set_pid(struct kvm_vcpu *vcpu, u32 pid);
 struct openpic;
 
 #ifdef CONFIG_KVM_BOOK3S_64_HV
+extern void kvm_cma_reserve(void) __init;
 static inline void kvmppc_set_xics_phys(int cpu, unsigned long addr)
 {
 	paca[cpu].kvm_hstate.xics_phys = addr;
@@ -284,6 +285,9 @@ extern void kvmppc_fast_vcpu_kick(struct kvm_vcpu *vcpu);
 extern void kvm_linear_init(void);
 
 #else
+static inline void __init kvm_cma_reserve(void)
+{}
+
 static inline void kvmppc_set_xics_phys(int cpu, unsigned long addr)
 {}
 
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index e379d3f..ee28d1f 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -229,6 +229,8 @@ void __init early_setup(unsigned long dt_ptr)
 	/* Initialize the hash table or TLB handling */
 	early_init_mmu();
 
+	kvm_cma_reserve();
+
 	/*
 	 * Reserve any gigantic pages requested on the command line.
 	 * memblock needs to have been initialized by the time this is
diff --git a/arch/powerpc/kvm/Kconfig b/arch/powerpc/kvm/Kconfig
index eb643f8..ffaef2c 100644
--- a/arch/powerpc/kvm/Kconfig
+++ b/arch/powerpc/kvm/Kconfig
@@ -72,6 +72,7 @@ config KVM_BOOK3S_64_HV
 	bool "KVM support for POWER7 and PPC970 using hypervisor mode in host"
 	depends on KVM_BOOK3S_64
 	select MMU_NOTIFIER
+	select CMA
 	---help---
 	  Support running unmodified book3s_64 guest kernels in
 	  virtual machines on POWER7 and PPC970 processors that have
diff --git a/arch/powerpc/kvm/Makefile b/arch/powerpc/kvm/Makefile
index 422de3f..dc155de 100644
--- a/arch/powerpc/kvm/Makefile
+++ b/arch/powerpc/kvm/Makefile
@@ -74,12 +74,15 @@ kvm-book3s_64-objs-$(CONFIG_KVM_BOOK3S_64_HV) := \
 	book3s_64_mmu_hv.o
 kvm-book3s_64-builtin-xics-objs-$(CONFIG_KVM_XICS) := \
 	book3s_hv_rm_xics.o
+kvm-book3s_64-builtin-cma-objs-$(CONFIG_CMA) := \
+	book3s_hv_cma.o
 kvm-book3s_64-builtin-objs-$(CONFIG_KVM_BOOK3S_64_HV) := \
 	book3s_hv_rmhandlers.o \
 	book3s_hv_rm_mmu.o \
 	book3s_64_vio_hv.o \
 	book3s_hv_ras.o \
 	book3s_hv_builtin.o \
+	$(kvm-book3s_64-builtin-cma-objs-y) \
 	$(kvm-book3s_64-builtin-xics-objs-y)
 
 kvm-book3s_64-objs-$(CONFIG_KVM_XICS) += \
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 5880dfb..e96470d 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -52,8 +52,8 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
 {
 	unsigned long hpt;
 	struct revmap_entry *rev;
-	struct kvmppc_linear_info *li;
-	long order = kvm_hpt_order;
+	struct page *page = NULL;
+	long order = KVM_DEFAULT_HPT_ORDER;
 
 	if (htab_orderp) {
 		order = *htab_orderp;
@@ -62,25 +62,20 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
 	}
 
 	/*
-	 * If the user wants a different size from default,
 	 * try first to allocate it from the kernel page allocator.
+	 * We keep the CMA reserved for failed allocation.
 	 */
-	hpt = 0;
-	if (order != kvm_hpt_order) {
-		hpt = __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT|
-				       __GFP_NOWARN, order - PAGE_SHIFT);
-		if (!hpt)
-			--order;
-	}
+	hpt = __get_free_pages(GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT |
+			       __GFP_NOWARN, order - PAGE_SHIFT);
 
 	/* Next try to allocate from the preallocated pool */
 	if (!hpt) {
-		li = kvm_alloc_hpt();
-		if (li) {
-			hpt = (ulong)li->base_virt;
-			kvm->arch.hpt_li = li;
-			order = kvm_hpt_order;
-		}
+		page = kvm_alloc_hpt(1 << (order - PAGE_SHIFT));
+		if (page) {
+			hpt = (unsigned long)pfn_to_kaddr(page_to_pfn(page));
+			kvm->arch.hpt_cma_alloc = 1;
+		} else
+			--order;
 	}
 
 	/* Lastly try successively smaller sizes from the page allocator */
@@ -118,8 +113,8 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
 	return 0;
 
  out_freehpt:
-	if (kvm->arch.hpt_li)
-		kvm_release_hpt(kvm->arch.hpt_li);
+	if (kvm->arch.hpt_cma_alloc)
+		kvm_release_hpt(page, 1 << (order - PAGE_SHIFT));
 	else
 		free_pages(hpt, order - PAGE_SHIFT);
 	return -ENOMEM;
@@ -165,8 +160,9 @@ void kvmppc_free_hpt(struct kvm *kvm)
 {
 	kvmppc_free_lpid(kvm->arch.lpid);
 	vfree(kvm->arch.revmap);
-	if (kvm->arch.hpt_li)
-		kvm_release_hpt(kvm->arch.hpt_li);
+	if (kvm->arch.hpt_cma_alloc)
+		kvm_release_hpt(virt_to_page(kvm->arch.hpt_virt),
+				1 << (kvm->arch.hpt_order - PAGE_SHIFT));
 	else
 		free_pages(kvm->arch.hpt_virt,
 			   kvm->arch.hpt_order - PAGE_SHIFT);
diff --git a/arch/powerpc/kvm/book3s_hv_builtin.c b/arch/powerpc/kvm/book3s_hv_builtin.c
index ec0a9e5..cf8e25a 100644
--- a/arch/powerpc/kvm/book3s_hv_builtin.c
+++ b/arch/powerpc/kvm/book3s_hv_builtin.c
@@ -13,20 +13,29 @@
 #include <linux/spinlock.h>
 #include <linux/bootmem.h>
 #include <linux/init.h>
+#include <linux/memblock.h>
+#include <linux/sizes.h>
 
 #include <asm/cputable.h>
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
 
+#include "book3s_hv_cma.h"
+
 #define KVM_LINEAR_RMA		0
 #define KVM_LINEAR_HPT		1
 
 static void __init kvm_linear_init_one(ulong size, int count, int type);
 static struct kvmppc_linear_info *kvm_alloc_linear(int type);
 static void kvm_release_linear(struct kvmppc_linear_info *ri);
-
-int kvm_hpt_order = KVM_DEFAULT_HPT_ORDER;
-EXPORT_SYMBOL_GPL(kvm_hpt_order);
+/*
+ * should be power of 2
+ */
+static unsigned long hpt_align_pages = (1 << 18) >> PAGE_SHIFT; /* 256k */
+/*
+ * By default we reserve 5% of memory for hash pagetable allocation.
+ */
+static unsigned long kvm_cma_resv_ratio = 5;
 
 /*************** RMA *************/
 
@@ -101,36 +110,25 @@ void kvm_release_rma(struct kvmppc_linear_info *ri)
 }
 EXPORT_SYMBOL_GPL(kvm_release_rma);
 
-/*************** HPT *************/
-
-/*
- * This maintains a list of big linear HPT tables that contain the GVA->HPA
- * memory mappings. If we don't reserve those early on, we might not be able
- * to get a big (usually 16MB) linear memory region from the kernel anymore.
- */
-
-static unsigned long kvm_hpt_count;
-
-static int __init early_parse_hpt_count(char *p)
+static int __init early_parse_kvm_cma_resv(char *p)
 {
+	pr_debug("%s(%s)\n", __func__, p);
 	if (!p)
-		return 1;
-
-	kvm_hpt_count = simple_strtoul(p, NULL, 0);
-
-	return 0;
+		return -EINVAL;
+	return kstrtoul(p, 0, &kvm_cma_resv_ratio);
 }
-early_param("kvm_hpt_count", early_parse_hpt_count);
+early_param("kvm_cma_resv_ratio", early_parse_kvm_cma_resv);
 
-struct kvmppc_linear_info *kvm_alloc_hpt(void)
+struct page *kvm_alloc_hpt(int nr_pages)
 {
-	return kvm_alloc_linear(KVM_LINEAR_HPT);
+	return kvm_alloc_cma(nr_pages,
+			     get_order(hpt_align_pages << PAGE_SHIFT));
 }
 EXPORT_SYMBOL_GPL(kvm_alloc_hpt);
 
-void kvm_release_hpt(struct kvmppc_linear_info *li)
+void kvm_release_hpt(struct page *page, int nr_pages)
 {
-	kvm_release_linear(li);
+	kvm_release_cma(page, nr_pages);
 }
 EXPORT_SYMBOL_GPL(kvm_release_hpt);
 
@@ -211,9 +209,6 @@ static void kvm_release_linear(struct kvmppc_linear_info *ri)
  */
 void __init kvm_linear_init(void)
 {
-	/* HPT */
-	kvm_linear_init_one(1 << kvm_hpt_order, kvm_hpt_count, KVM_LINEAR_HPT);
-
 	/* RMA */
 	/* Only do this on PPC970 in HV mode */
 	if (!cpu_has_feature(CPU_FTR_HVMODE) ||
@@ -231,3 +226,33 @@ void __init kvm_linear_init(void)
 
 	kvm_linear_init_one(kvm_rma_size, kvm_rma_count, KVM_LINEAR_RMA);
 }
+
+/**
+ * kvm_cma_reserve() - reserve area for kvm hash pagetable
+ *
+ * This function reserves memory from early allocator. It should be
+ * called by arch specific code once the early allocator (memblock or bootmem)
+ * has been activated and all other subsystems have already allocated/reserved
+ * memory.
+ */
+void __init kvm_cma_reserve(void)
+{
+	int align_size;
+	struct memblock_region *reg;
+	phys_addr_t selected_size = 0;
+	/*
+	 * We cannot use memblock_phys_mem_size() here, because
+	 * memblock_analyze() has not been called yet.
+	 */
+	for_each_memblock(memory, reg)
+		selected_size += memblock_region_memory_end_pfn(reg) -
+				 memblock_region_memory_base_pfn(reg);
+
+	selected_size = (selected_size * kvm_cma_resv_ratio / 100) << PAGE_SHIFT;
+	if (selected_size) {
+		pr_debug("%s: reserving %ld MiB for global area\n", __func__,
+			 (unsigned long)selected_size / SZ_1M);
+		align_size = hpt_align_pages << PAGE_SHIFT;
+		kvm_cma_declare_contiguous(selected_size, align_size);
+	}
+}
diff --git a/arch/powerpc/kvm/book3s_hv_cma.c b/arch/powerpc/kvm/book3s_hv_cma.c
new file mode 100644
index 0000000..8bd68bc
--- /dev/null
+++ b/arch/powerpc/kvm/book3s_hv_cma.c
@@ -0,0 +1,220 @@
+/*
+ * Contiguous Memory Allocator for ppc KVM hash pagetable  based on CMA
+ * for DMA mapping framework
+ *
+ * Copyright IBM Corporation, 2013
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ *
+ */
+#define pr_fmt(fmt) "kvm_cma: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#ifndef DEBUG
+#  define DEBUG
+#endif
+#endif
+
+#include <linux/memblock.h>
+#include <linux/mutex.h>
+#include <linux/sizes.h>
+#include <linux/slab.h>
+
+struct kvm_cma {
+	unsigned long	base_pfn;
+	unsigned long	count;
+	unsigned long	*bitmap;
+};
+
+static DEFINE_MUTEX(kvm_cma_mutex);
+static struct kvm_cma kvm_cma_area;
+
+/**
+ * kvm_cma_declare_contiguous() - reserve area for contiguous memory handling
+ *			          for kvm hash pagetable
+ * @size:  Size of the reserved memory.
+ * @alignment:  Alignment for the contiguous memory area
+ *
+ * This function reserves memory for kvm cma area. It should be
+ * called by arch code when early allocator (memblock or bootmem)
+ * is still activate.
+ */
+long __init kvm_cma_declare_contiguous(phys_addr_t size, phys_addr_t alignment)
+{
+	long base_pfn;
+	phys_addr_t addr;
+	struct kvm_cma *cma = &kvm_cma_area;
+
+	pr_debug("%s(size %lx)\n", __func__, (unsigned long)size);
+
+	if (!size)
+		return -EINVAL;
+	/*
+	 * Sanitise input arguments.
+	 * We should be pageblock aligned for CMA.
+	 */
+	alignment = max(alignment, (phys_addr_t)(PAGE_SIZE << pageblock_order));
+	size = ALIGN(size, alignment);
+	/*
+	 * Reserve memory
+	 * Use __memblock_alloc_base() since
+	 * memblock_alloc_base() panic()s.
+	 */
+	addr = __memblock_alloc_base(size, alignment, 0);
+	if (!addr) {
+		base_pfn = -ENOMEM;
+		goto err;
+	} else
+		base_pfn = PFN_DOWN(addr);
+
+	/*
+	 * Each reserved area must be initialised later, when more kernel
+	 * subsystems (like slab allocator) are available.
+	 */
+	cma->base_pfn = base_pfn;
+	cma->count    = size >> PAGE_SHIFT;
+	pr_info("CMA: reserved %ld MiB\n", (unsigned long)size / SZ_1M);
+	return 0;
+err:
+	pr_err("CMA: failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
+	return base_pfn;
+}
+
+/**
+ * kvm_alloc_cma() - allocate pages from contiguous area
+ * @nr_pages: Requested number of pages.
+ * @align_order: Requested alignment of pages in PAGE_SIZE order
+ *
+ * This function allocates memory buffer for hash pagetable.
+ */
+struct page *kvm_alloc_cma(int nr_pages, unsigned long align_order)
+{
+	int ret;
+	struct page *page = NULL;
+	struct kvm_cma *cma = &kvm_cma_area;
+	unsigned long mask, pfn, pageno, start = 0;
+
+
+	if (!cma || !cma->count)
+		return NULL;
+
+	pr_debug("%s(cma %p, count %d, align order %lu)\n", __func__,
+		 (void *)cma, nr_pages, align_order);
+
+	if (!nr_pages)
+		return NULL;
+
+	mask = (1 << align_order) - 1;
+
+	mutex_lock(&kvm_cma_mutex);
+	for (;;) {
+		pageno = bitmap_find_next_zero_area(cma->bitmap, cma->count,
+						    start, nr_pages, mask);
+		if (pageno >= cma->count)
+			break;
+
+		pfn = cma->base_pfn + pageno;
+		ret = alloc_contig_range(pfn, pfn + nr_pages, MIGRATE_CMA);
+		if (ret == 0) {
+			bitmap_set(cma->bitmap, pageno, nr_pages);
+			page = pfn_to_page(pfn);
+			memset(pfn_to_kaddr(pfn), 0, nr_pages << PAGE_SHIFT);
+			break;
+		} else if (ret != -EBUSY) {
+			break;
+		}
+		pr_debug("%s(): memory range at %p is busy, retrying\n",
+			 __func__, pfn_to_page(pfn));
+		/* try again with a bit different memory target */
+		start = pageno + mask + 1;
+	}
+	mutex_unlock(&kvm_cma_mutex);
+	pr_debug("%s(): returned %p\n", __func__, page);
+	return page;
+}
+
+/**
+ * kvm_release_cma() - release allocated pages for hash pagetable
+ * @pages: Allocated pages.
+ * @nr_pages: Number of allocated pages.
+ *
+ * This function releases memory allocated by kvm_alloc_cma().
+ * It returns false when provided pages do not belong to contiguous area and
+ * true otherwise.
+ */
+bool kvm_release_cma(struct page *pages, int nr_pages)
+{
+	unsigned long pfn;
+	struct kvm_cma *cma = &kvm_cma_area;
+
+
+	if (!cma || !pages)
+		return false;
+
+	pr_debug("%s(page %p count %d)\n", __func__, (void *)pages, nr_pages);
+
+	pfn = page_to_pfn(pages);
+
+	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
+		return false;
+
+	VM_BUG_ON(pfn + nr_pages > cma->base_pfn + cma->count);
+
+	mutex_lock(&kvm_cma_mutex);
+	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, nr_pages);
+	free_contig_range(pfn, nr_pages);
+	mutex_unlock(&kvm_cma_mutex);
+
+	return true;
+}
+
+static int __init kvm_cma_activate_area(unsigned long base_pfn,
+					unsigned long count)
+{
+	unsigned long pfn = base_pfn;
+	unsigned i = count >> pageblock_order;
+	struct zone *zone;
+
+	WARN_ON_ONCE(!pfn_valid(pfn));
+	zone = page_zone(pfn_to_page(pfn));
+	do {
+		unsigned j;
+		base_pfn = pfn;
+		for (j = pageblock_nr_pages; j; --j, pfn++) {
+			WARN_ON_ONCE(!pfn_valid(pfn));
+			if (page_zone(pfn_to_page(pfn)) != zone)
+				return -EINVAL;
+		}
+		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
+	} while (--i);
+	return 0;
+}
+
+static int __init kvm_cma_init_reserved_areas(void)
+{
+	int bitmap_size, ret;
+	struct kvm_cma *cma = &kvm_cma_area;
+
+	pr_debug("%s()\n", __func__);
+	if (!cma->count)
+		return 0;
+
+	bitmap_size = BITS_TO_LONGS(cma->count) * sizeof(long);
+	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	if (!cma->bitmap)
+		return -ENOMEM;
+
+	ret = kvm_cma_activate_area(cma->base_pfn, cma->count);
+	if (ret)
+		goto error;
+	return 0;
+
+error:
+	kfree(cma->bitmap);
+	return ret;
+}
+core_initcall(kvm_cma_init_reserved_areas);
diff --git a/arch/powerpc/kvm/book3s_hv_cma.h b/arch/powerpc/kvm/book3s_hv_cma.h
new file mode 100644
index 0000000..6c5c75d
--- /dev/null
+++ b/arch/powerpc/kvm/book3s_hv_cma.h
@@ -0,0 +1,21 @@
+/*
+ * Contiguous Memory Allocator for ppc KVM hash pagetable  based on CMA
+ * for DMA mapping framework
+ *
+ * Copyright IBM Corporation, 2013
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ *
+ */
+
+#ifndef __POWERPC_KVM_CMA_ALLOC_H__
+#define __POWERPC_KVM_CMA_ALLOC_H__
+extern struct page *kvm_alloc_cma(int nr_pages, unsigned long align_order);
+extern bool kvm_release_cma(struct page *pages, int nr_pages);
+extern long kvm_cma_declare_contiguous(phys_addr_t size,
+				       phys_addr_t alignment) __init;
+#endif
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
