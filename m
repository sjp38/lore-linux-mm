Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1B258830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:30 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id wb13so146213664obb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:30 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id dp7si15254339obb.40.2016.02.08.01.21.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:25 -0800 (PST)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:25 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B092CC40005
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:33 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LN4o31784960
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:23 -0700
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LNDv032303
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:23 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 14/29] powerpc/mm: Move hash page table related functions to pgtable-hash64.c
Date: Mon,  8 Feb 2016 14:50:26 +0530
Message-Id: <1454923241-6681-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash.h    |   1 +
 arch/powerpc/include/asm/nohash/64/pgtable.h |   2 +
 arch/powerpc/mm/Makefile                     |   3 +-
 arch/powerpc/mm/init_64.c                    | 114 +------------
 arch/powerpc/mm/mem.c                        |  29 +---
 arch/powerpc/mm/mmu_decl.h                   |   4 -
 arch/powerpc/mm/pgtable-book3e.c             | 163 ++++++++++++++++++
 arch/powerpc/mm/pgtable-hash64.c             | 247 +++++++++++++++++++++++++++
 arch/powerpc/mm/pgtable.c                    |   9 +
 arch/powerpc/mm/pgtable_64.c                 |  88 ----------
 arch/powerpc/mm/ppc_mmu_32.c                 |  30 ++++
 11 files changed, 462 insertions(+), 228 deletions(-)
 create mode 100644 arch/powerpc/mm/pgtable-book3e.c
 create mode 100644 arch/powerpc/mm/pgtable-hash64.c

diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index e88573440bbe..05a048bc4a64 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -603,6 +603,7 @@ static inline void hpte_do_hugepage_flush(struct mm_struct *mm,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+extern int map_kernel_page(unsigned long ea, unsigned long pa, int flags);
 #endif /* !__ASSEMBLY__ */
 #endif /* __KERNEL__ */
 #endif /* _ASM_POWERPC_BOOK3S_64_HASH_H */
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
index b9f734dd5b81..a68e809d7739 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
@@ -359,6 +359,8 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
 void pgtable_cache_init(void);
+extern int map_kernel_page(unsigned long ea, unsigned long pa, int flags);
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_POWERPC_NOHASH_64_PGTABLE_H */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 1ffeda85c086..6b5cc805c7ba 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -13,7 +13,8 @@ obj-$(CONFIG_PPC_MMU_NOHASH)	+= mmu_context_nohash.o tlb_nohash.o \
 				   tlb_nohash_low.o
 obj-$(CONFIG_PPC_BOOK3E)	+= tlb_low_$(CONFIG_WORD_SIZE)e.o
 hash64-$(CONFIG_PPC_NATIVE)	:= hash_native_64.o
-obj-$(CONFIG_PPC_STD_MMU_64)	+= hash_utils_64.o slb_low.o slb.o $(hash64-y)
+obj-$(CONFIG_PPC_BOOK3E_64)   += pgtable-book3e.o
+obj-$(CONFIG_PPC_STD_MMU_64)	+= pgtable-hash64.o hash_utils_64.o slb_low.o slb.o $(hash64-y)
 obj-$(CONFIG_PPC_STD_MMU_32)	+= ppc_mmu_32.o hash_low_32.o
 obj-$(CONFIG_PPC_STD_MMU)	+= tlb_hash$(CONFIG_WORD_SIZE).o \
 				   mmu_context_hash$(CONFIG_WORD_SIZE).o
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 8ce1ec24d573..05b025a0efe6 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -65,38 +65,10 @@
 
 #include "mmu_decl.h"
 
-#ifdef CONFIG_PPC_STD_MMU_64
-#if PGTABLE_RANGE > USER_VSID_RANGE
-#warning Limited user VSID range means pagetable space is wasted
-#endif
-
-#if (TASK_SIZE_USER64 < PGTABLE_RANGE) && (TASK_SIZE_USER64 < USER_VSID_RANGE)
-#warning TASK_SIZE is smaller than it needs to be.
-#endif
-#endif /* CONFIG_PPC_STD_MMU_64 */
-
 phys_addr_t memstart_addr = ~0;
 EXPORT_SYMBOL_GPL(memstart_addr);
 phys_addr_t kernstart_addr;
 EXPORT_SYMBOL_GPL(kernstart_addr);
-
-static void pgd_ctor(void *addr)
-{
-	memset(addr, 0, PGD_TABLE_SIZE);
-}
-
-static void pud_ctor(void *addr)
-{
-	memset(addr, 0, PUD_TABLE_SIZE);
-}
-
-static void pmd_ctor(void *addr)
-{
-	memset(addr, 0, PMD_TABLE_SIZE);
-}
-
-struct kmem_cache *pgtable_cache[MAX_PGTABLE_INDEX_SIZE];
-
 /*
  * Create a kmem_cache() for pagetables.  This is not used for PTE
  * pages - they're linked to struct page, come from the normal free
@@ -104,6 +76,7 @@ struct kmem_cache *pgtable_cache[MAX_PGTABLE_INDEX_SIZE];
  * everything else.  Caches created by this function are used for all
  * the higher level pagetables, and for hugepage pagetables.
  */
+struct kmem_cache *pgtable_cache[MAX_PGTABLE_INDEX_SIZE];
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
 {
 	char *name;
@@ -138,25 +111,6 @@ void pgtable_cache_add(unsigned shift, void (*ctor)(void *))
 	pr_debug("Allocated pgtable cache for order %d\n", shift);
 }
 
-
-void pgtable_cache_init(void)
-{
-	pgtable_cache_add(PGD_INDEX_SIZE, pgd_ctor);
-	pgtable_cache_add(PMD_CACHE_INDEX, pmd_ctor);
-	/*
-	 * In all current configs, when the PUD index exists it's the
-	 * same size as either the pgd or pmd index except with THP enabled
-	 * on book3s 64
-	 */
-	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
-		pgtable_cache_add(PUD_INDEX_SIZE, pud_ctor);
-
-	if (!PGT_CACHE(PGD_INDEX_SIZE) || !PGT_CACHE(PMD_CACHE_INDEX))
-		panic("Couldn't allocate pgtable caches");
-	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
-		panic("Couldn't allocate pud pgtable caches");
-}
-
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Given an address within the vmemmap, determine the pfn of the page that
@@ -189,67 +143,6 @@ static int __meminit vmemmap_populated(unsigned long start, int page_size)
 	return 0;
 }
 
-/* On hash-based CPUs, the vmemmap is bolted in the hash table.
- *
- * On Book3E CPUs, the vmemmap is currently mapped in the top half of
- * the vmalloc space using normal page tables, though the size of
- * pages encoded in the PTEs can be different
- */
-
-#ifdef CONFIG_PPC_BOOK3E
-static void __meminit vmemmap_create_mapping(unsigned long start,
-					     unsigned long page_size,
-					     unsigned long phys)
-{
-	/* Create a PTE encoding without page size */
-	unsigned long i, flags = _PAGE_PRESENT | _PAGE_ACCESSED |
-		_PAGE_KERNEL_RW;
-
-	/* PTEs only contain page size encodings up to 32M */
-	BUG_ON(mmu_psize_defs[mmu_vmemmap_psize].enc > 0xf);
-
-	/* Encode the size in the PTE */
-	flags |= mmu_psize_defs[mmu_vmemmap_psize].enc << 8;
-
-	/* For each PTE for that area, map things. Note that we don't
-	 * increment phys because all PTEs are of the large size and
-	 * thus must have the low bits clear
-	 */
-	for (i = 0; i < page_size; i += PAGE_SIZE)
-		BUG_ON(map_kernel_page(start + i, phys, flags));
-}
-
-#ifdef CONFIG_MEMORY_HOTPLUG
-static void vmemmap_remove_mapping(unsigned long start,
-				   unsigned long page_size)
-{
-}
-#endif
-#else /* CONFIG_PPC_BOOK3E */
-static void __meminit vmemmap_create_mapping(unsigned long start,
-					     unsigned long page_size,
-					     unsigned long phys)
-{
-	int  mapped = htab_bolt_mapping(start, start + page_size, phys,
-					pgprot_val(PAGE_KERNEL),
-					mmu_vmemmap_psize,
-					mmu_kernel_ssize);
-	BUG_ON(mapped < 0);
-}
-
-#ifdef CONFIG_MEMORY_HOTPLUG
-static void vmemmap_remove_mapping(unsigned long start,
-				   unsigned long page_size)
-{
-	int mapped = htab_remove_mapping(start, start + page_size,
-					 mmu_vmemmap_psize,
-					 mmu_kernel_ssize);
-	BUG_ON(mapped < 0);
-}
-#endif
-
-#endif /* CONFIG_PPC_BOOK3E */
-
 struct vmemmap_backing *vmemmap_list;
 static struct vmemmap_backing *next;
 static int num_left;
@@ -301,6 +194,9 @@ static __meminit void vmemmap_list_populate(unsigned long phys,
 	vmemmap_list = vmem_back;
 }
 
+extern void __meminit vmemmap_create_mapping(unsigned long start,
+					     unsigned long page_size,
+					     unsigned long phys);
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
 	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
@@ -332,6 +228,8 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+extern void vmemmap_remove_mapping(unsigned long start,
+				   unsigned long page_size);
 static unsigned long vmemmap_list_free(unsigned long start)
 {
 	struct vmemmap_backing *vmem_back, *vmem_back_prev;
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index d0f0a514b04e..6b4c2ecd1d1e 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -476,6 +476,7 @@ void flush_icache_user_range(struct vm_area_struct *vma, struct page *page,
 }
 EXPORT_SYMBOL(flush_icache_user_range);
 
+#ifndef CONFIG_PPC_STD_MMU
 /*
  * This is called at the end of handling a user page fault, when the
  * fault has been handled by updating a PTE in the linux page tables.
@@ -487,39 +488,13 @@ EXPORT_SYMBOL(flush_icache_user_range);
 void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
 		      pte_t *ptep)
 {
-#ifdef CONFIG_PPC_STD_MMU
-	/*
-	 * We don't need to worry about _PAGE_PRESENT here because we are
-	 * called with either mm->page_table_lock held or ptl lock held
-	 */
-	unsigned long access = 0, trap;
-
-	/* We only want HPTEs for linux PTEs that have _PAGE_ACCESSED set */
-	if (!pte_young(*ptep) || address >= TASK_SIZE)
-		return;
-
-	/* We try to figure out if we are coming from an instruction
-	 * access fault and pass that down to __hash_page so we avoid
-	 * double-faulting on execution of fresh text. We have to test
-	 * for regs NULL since init will get here first thing at boot
-	 *
-	 * We also avoid filling the hash if not coming from a fault
-	 */
-	if (current->thread.regs == NULL)
-		return;
-	trap = TRAP(current->thread.regs);
-	if (trap == 0x400)
-		access |= _PAGE_EXEC;
-	else if (trap != 0x300)
-		return;
-	hash_preload(vma->vm_mm, address, access, trap);
-#endif /* CONFIG_PPC_STD_MMU */
 #if (defined(CONFIG_PPC_BOOK3E_64) || defined(CONFIG_PPC_FSL_BOOK3E)) \
 	&& defined(CONFIG_HUGETLB_PAGE)
 	if (is_vm_hugetlb_page(vma))
 		book3e_hugetlb_preload(vma, address, *ptep);
 #endif
 }
+#endif /* !CONFIG_PPC_STD_MMU */
 
 /*
  * System memory should not be in /proc/iomem but various tools expect it
diff --git a/arch/powerpc/mm/mmu_decl.h b/arch/powerpc/mm/mmu_decl.h
index 9f58ff44a075..6360f54ef2d0 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -109,10 +109,6 @@ extern unsigned long Hash_size, Hash_mask;
 
 #endif /* CONFIG_PPC32 */
 
-#ifdef CONFIG_PPC64
-extern int map_kernel_page(unsigned long ea, unsigned long pa, int flags);
-#endif /* CONFIG_PPC64 */
-
 extern unsigned long ioremap_bot;
 extern unsigned long __max_low_memory;
 extern phys_addr_t __initial_memory_limit_addr;
diff --git a/arch/powerpc/mm/pgtable-book3e.c b/arch/powerpc/mm/pgtable-book3e.c
new file mode 100644
index 000000000000..2c5574142bbe
--- /dev/null
+++ b/arch/powerpc/mm/pgtable-book3e.c
@@ -0,0 +1,163 @@
+
+/*
+ * Copyright IBM Corporation, 2015
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+/*
+ * PPC64 THP Support for hash based MMUs
+ */
+#include <linux/sched.h>
+#include <linux/memblock.h>
+#include <asm/pgalloc.h>
+#include <asm/tlb.h>
+#include <asm/dma.h>
+
+#include "mmu_decl.h"
+
+#if (TASK_SIZE_USER64 > PGTABLE_RANGE)
+#warning TASK_SIZE is larger than page table range
+#endif
+
+static void pgd_ctor(void *addr)
+{
+	memset(addr, 0, PGD_TABLE_SIZE);
+}
+
+static void pud_ctor(void *addr)
+{
+	memset(addr, 0, PUD_TABLE_SIZE);
+}
+
+static void pmd_ctor(void *addr)
+{
+	memset(addr, 0, PMD_TABLE_SIZE);
+}
+
+void pgtable_cache_init(void)
+{
+	pgtable_cache_add(PGD_INDEX_SIZE, pgd_ctor);
+	pgtable_cache_add(PMD_CACHE_INDEX, pmd_ctor);
+	/*
+	 * In all current configs, when the PUD index exists it's the
+	 * same size as either the pgd or pmd index except with THP enabled
+	 * on book3s 64
+	 */
+	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
+		pgtable_cache_add(PUD_INDEX_SIZE, pud_ctor);
+
+	if (!PGT_CACHE(PGD_INDEX_SIZE) || !PGT_CACHE(PMD_CACHE_INDEX))
+		panic("Couldn't allocate pgtable caches");
+	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
+		panic("Couldn't allocate pud pgtable caches");
+}
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+/*
+ * On Book3E CPUs, the vmemmap is currently mapped in the top half of
+ * the vmalloc space using normal page tables, though the size of
+ * pages encoded in the PTEs can be different
+ */
+void __meminit vmemmap_create_mapping(unsigned long start,
+				      unsigned long page_size,
+				      unsigned long phys)
+{
+	/* Create a PTE encoding without page size */
+	unsigned long i, flags = _PAGE_PRESENT | _PAGE_ACCESSED |
+		_PAGE_KERNEL_RW;
+
+	/* PTEs only contain page size encodings up to 32M */
+	BUG_ON(mmu_psize_defs[mmu_vmemmap_psize].enc > 0xf);
+
+	/* Encode the size in the PTE */
+	flags |= mmu_psize_defs[mmu_vmemmap_psize].enc << 8;
+
+	/* For each PTE for that area, map things. Note that we don't
+	 * increment phys because all PTEs are of the large size and
+	 * thus must have the low bits clear
+	 */
+	for (i = 0; i < page_size; i += PAGE_SIZE)
+		BUG_ON(map_kernel_page(start + i, phys, flags));
+}
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+void vmemmap_remove_mapping(unsigned long start,
+			    unsigned long page_size)
+{
+}
+#endif
+#endif /* CONFIG_SPARSEMEM_VMEMMAP */
+
+static __ref void *early_alloc_pgtable(unsigned long size)
+{
+	void *pt;
+
+	pt = __va(memblock_alloc_base(size, size, __pa(MAX_DMA_ADDRESS)));
+	memset(pt, 0, size);
+
+	return pt;
+}
+
+/*
+ * map_kernel_page currently only called by __ioremap
+ * map_kernel_page adds an entry to the ioremap page table
+ * and adds an entry to the HPT, possibly bolting it
+ */
+int map_kernel_page(unsigned long ea, unsigned long pa, int flags)
+{
+	pgd_t *pgdp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+
+	if (slab_is_available()) {
+		pgdp = pgd_offset_k(ea);
+		pudp = pud_alloc(&init_mm, pgdp, ea);
+		if (!pudp)
+			return -ENOMEM;
+		pmdp = pmd_alloc(&init_mm, pudp, ea);
+		if (!pmdp)
+			return -ENOMEM;
+		ptep = pte_alloc_kernel(pmdp, ea);
+		if (!ptep)
+			return -ENOMEM;
+		set_pte_at(&init_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT,
+							  __pgprot(flags)));
+	} else {
+		pgdp = pgd_offset_k(ea);
+#ifndef __PAGETABLE_PUD_FOLDED
+		if (pgd_none(*pgdp)) {
+			pudp = early_alloc_pgtable(PUD_TABLE_SIZE);
+			BUG_ON(pudp == NULL);
+			pgd_populate(&init_mm, pgdp, pudp);
+		}
+#endif /* !__PAGETABLE_PUD_FOLDED */
+		pudp = pud_offset(pgdp, ea);
+		if (pud_none(*pudp)) {
+			pmdp = early_alloc_pgtable(PMD_TABLE_SIZE);
+			BUG_ON(pmdp == NULL);
+			pud_populate(&init_mm, pudp, pmdp);
+		}
+		pmdp = pmd_offset(pudp, ea);
+		if (!pmd_present(*pmdp)) {
+			ptep = early_alloc_pgtable(PAGE_SIZE);
+			BUG_ON(ptep == NULL);
+			pmd_populate_kernel(&init_mm, pmdp, ptep);
+		}
+		ptep = pte_offset_kernel(pmdp, ea);
+		set_pte_at(&init_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT,
+							  __pgprot(flags)));
+	}
+
+	smp_wmb();
+	return 0;
+}
diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
new file mode 100644
index 000000000000..e4b01ee7703c
--- /dev/null
+++ b/arch/powerpc/mm/pgtable-hash64.c
@@ -0,0 +1,247 @@
+/*
+ * Copyright IBM Corporation, 2015
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+/*
+ * PPC64 THP Support for hash based MMUs
+ */
+#include <linux/sched.h>
+#include <asm/pgalloc.h>
+#include <asm/tlb.h>
+
+#include "mmu_decl.h"
+
+#if PGTABLE_RANGE > USER_VSID_RANGE
+#warning Limited user VSID range means pagetable space is wasted
+#endif
+
+#if (TASK_SIZE_USER64 < PGTABLE_RANGE) && (TASK_SIZE_USER64 < USER_VSID_RANGE)
+#warning TASK_SIZE is smaller than it needs to be.
+#endif
+
+#if (TASK_SIZE_USER64 > PGTABLE_RANGE)
+#warning TASK_SIZE is larger than page table range
+#endif
+
+static void pgd_ctor(void *addr)
+{
+	memset(addr, 0, PGD_TABLE_SIZE);
+}
+
+static void pud_ctor(void *addr)
+{
+	memset(addr, 0, PUD_TABLE_SIZE);
+}
+
+static void pmd_ctor(void *addr)
+{
+	memset(addr, 0, PMD_TABLE_SIZE);
+}
+
+
+void pgtable_cache_init(void)
+{
+	pgtable_cache_add(PGD_INDEX_SIZE, pgd_ctor);
+	pgtable_cache_add(PMD_CACHE_INDEX, pmd_ctor);
+	/*
+	 * In all current configs, when the PUD index exists it's the
+	 * same size as either the pgd or pmd index except with THP enabled
+	 * on book3s 64
+	 */
+	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
+		pgtable_cache_add(PUD_INDEX_SIZE, pud_ctor);
+
+	if (!PGT_CACHE(PGD_INDEX_SIZE) || !PGT_CACHE(PMD_CACHE_INDEX))
+		panic("Couldn't allocate pgtable caches");
+	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
+		panic("Couldn't allocate pud pgtable caches");
+}
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+/*
+ * On hash-based CPUs, the vmemmap is bolted in the hash table.
+ *
+ */
+void __meminit vmemmap_create_mapping(unsigned long start,
+				      unsigned long page_size,
+				      unsigned long phys)
+{
+	int  mapped = htab_bolt_mapping(start, start + page_size, phys,
+					pgprot_val(PAGE_KERNEL),
+					mmu_vmemmap_psize,
+					mmu_kernel_ssize);
+	BUG_ON(mapped < 0);
+}
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+void vmemmap_remove_mapping(unsigned long start,
+			    unsigned long page_size)
+{
+	int mapped = htab_remove_mapping(start, start + page_size,
+					 mmu_vmemmap_psize,
+					 mmu_kernel_ssize);
+	BUG_ON(mapped < 0);
+}
+#endif
+#endif /* CONFIG_SPARSEMEM_VMEMMAP */
+
+void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
+		      pte_t *ptep)
+{
+	/*
+	 * We don't need to worry about _PAGE_PRESENT here because we are
+	 * called with either mm->page_table_lock held or ptl lock held
+	 */
+	unsigned long access = 0, trap;
+
+	/* We only want HPTEs for linux PTEs that have _PAGE_ACCESSED set */
+	if (!pte_young(*ptep) || address >= TASK_SIZE)
+		return;
+
+	/* We try to figure out if we are coming from an instruction
+	 * access fault and pass that down to __hash_page so we avoid
+	 * double-faulting on execution of fresh text. We have to test
+	 * for regs NULL since init will get here first thing at boot
+	 *
+	 * We also avoid filling the hash if not coming from a fault
+	 */
+	if (current->thread.regs == NULL)
+		return;
+	trap = TRAP(current->thread.regs);
+	if (trap == 0x400)
+		access |= _PAGE_EXEC;
+	else if (trap != 0x300)
+		return;
+	hash_preload(vma->vm_mm, address, access, trap);
+}
+
+/*
+ * map_kernel_page currently only called by __ioremap
+ * map_kernel_page adds an entry to the ioremap page table
+ * and adds an entry to the HPT, possibly bolting it
+ */
+int map_kernel_page(unsigned long ea, unsigned long pa, int flags)
+{
+	pgd_t *pgdp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+
+	if (slab_is_available()) {
+		pgdp = pgd_offset_k(ea);
+		pudp = pud_alloc(&init_mm, pgdp, ea);
+		if (!pudp)
+			return -ENOMEM;
+		pmdp = pmd_alloc(&init_mm, pudp, ea);
+		if (!pmdp)
+			return -ENOMEM;
+		ptep = pte_alloc_kernel(pmdp, ea);
+		if (!ptep)
+			return -ENOMEM;
+		set_pte_at(&init_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT,
+							  __pgprot(flags)));
+	} else {
+		/*
+		 * If the mm subsystem is not fully up, we cannot create a
+		 * linux page table entry for this mapping.  Simply bolt an
+		 * entry in the hardware page table.
+		 *
+		 */
+		if (htab_bolt_mapping(ea, ea + PAGE_SIZE, pa, flags,
+				      mmu_io_psize, mmu_kernel_ssize)) {
+			printk(KERN_ERR "Failed to do bolted mapping IO "
+			       "memory at %016lx !\n", pa);
+			return -ENOMEM;
+		}
+	}
+
+	smp_wmb();
+	return 0;
+}
+
+/*
+ * We only try to do i/d cache coherency on stuff that looks like
+ * reasonably "normal" PTEs. We currently require a PTE to be present
+ * and we avoid _PAGE_SPECIAL and _PAGE_NO_CACHE. We also only do that
+ * on userspace PTEs
+ */
+static inline int pte_looks_normal(pte_t pte)
+{
+	return (pte_val(pte) &
+	    (_PAGE_PRESENT | _PAGE_SPECIAL | _PAGE_NO_CACHE | _PAGE_USER)) ==
+	    (_PAGE_PRESENT | _PAGE_USER);
+}
+
+static struct page *maybe_pte_to_page(pte_t pte)
+{
+	unsigned long pfn = pte_pfn(pte);
+	struct page *page;
+
+	if (unlikely(!pfn_valid(pfn)))
+		return NULL;
+	page = pfn_to_page(pfn);
+	if (PageReserved(page))
+		return NULL;
+	return page;
+}
+
+/* Server-style MMU handles coherency when hashing if HW exec permission
+ * is supposed per page (currently 64-bit only). If not, then, we always
+ * flush the cache for valid PTEs in set_pte. Embedded CPU without HW exec
+ * support falls into the same category.
+ */
+static pte_t set_pte_filter(pte_t pte)
+{
+	pte = __pte(pte_val(pte) & ~_PAGE_HPTEFLAGS);
+	if (pte_looks_normal(pte) && !(cpu_has_feature(CPU_FTR_COHERENT_ICACHE) ||
+				       cpu_has_feature(CPU_FTR_NOEXECUTE))) {
+		struct page *pg = maybe_pte_to_page(pte);
+
+		if (!pg)
+			return pte;
+		if (!test_bit(PG_arch_1, &pg->flags)) {
+			flush_dcache_icache_page(pg);
+			set_bit(PG_arch_1, &pg->flags);
+		}
+	}
+	return pte;
+}
+
+/*
+ * set_pte stores a linux PTE into the linux page table.
+ */
+void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
+		pte_t pte)
+{
+	/*
+	 * When handling numa faults, we already have the pte marked
+	 * _PAGE_PRESENT, but we can be sure that it is not in hpte.
+	 * Hence we can use set_pte_at for them.
+	 */
+	VM_WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
+		(_PAGE_PRESENT | _PAGE_USER));
+
+	/*
+	 * Add the pte bit when tryint set a pte
+	 */
+	pte = __pte(pte_val(pte) | _PAGE_PTE);
+
+	/* Note: mm->context.id might not yet have been assigned as
+	 * this context might not have been activated yet when this
+	 * is called.
+	 */
+	pte = set_pte_filter(pte);
+
+	/* Perform the setting of the PTE */
+	__set_pte_at(mm, addr, ptep, pte, 0);
+}
diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index 83dfd7925c72..5659432e576c 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -31,6 +31,8 @@
 #include <asm/tlbflush.h>
 #include <asm/tlb.h>
 
+#ifndef CONFIG_PPC_BOOK3S_64
+/* We have alternate definition for the below in pgtable-hash64.c */
 static inline int is_exec_fault(void)
 {
 	return current->thread.regs && TRAP(current->thread.regs) == 0x400;
@@ -193,6 +195,13 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 	/* Perform the setting of the PTE */
 	__set_pte_at(mm, addr, ptep, pte, 0);
 }
+#else
+static pte_t set_access_flags_filter(pte_t pte, struct vm_area_struct *vma,
+				     int dirty)
+{
+	return pte;
+}
+#endif /* !CONFIG_PPC_BOOK3S_64 */
 
 /*
  * This is called when relaxing access to a PTE. It's also called in the page
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 8840d31a5586..5cf3b75fb847 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -58,11 +58,6 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/thp.h>
 
-/* Some sanity checking */
-#if TASK_SIZE_USER64 > PGTABLE_RANGE
-#error TASK_SIZE_USER64 exceeds pagetable range
-#endif
-
 #ifdef CONFIG_PPC_STD_MMU_64
 #if TASK_SIZE_USER64 > (1UL << (ESID_BITS + SID_SHIFT))
 #error TASK_SIZE_USER64 exceeds user VSID range
@@ -71,89 +66,6 @@
 
 unsigned long ioremap_bot = IOREMAP_BASE;
 
-#ifdef CONFIG_PPC_MMU_NOHASH
-static __ref void *early_alloc_pgtable(unsigned long size)
-{
-	void *pt;
-
-	pt = __va(memblock_alloc_base(size, size, __pa(MAX_DMA_ADDRESS)));
-	memset(pt, 0, size);
-
-	return pt;
-}
-#endif /* CONFIG_PPC_MMU_NOHASH */
-
-/*
- * map_kernel_page currently only called by __ioremap
- * map_kernel_page adds an entry to the ioremap page table
- * and adds an entry to the HPT, possibly bolting it
- */
-int map_kernel_page(unsigned long ea, unsigned long pa, int flags)
-{
-	pgd_t *pgdp;
-	pud_t *pudp;
-	pmd_t *pmdp;
-	pte_t *ptep;
-
-	if (slab_is_available()) {
-		pgdp = pgd_offset_k(ea);
-		pudp = pud_alloc(&init_mm, pgdp, ea);
-		if (!pudp)
-			return -ENOMEM;
-		pmdp = pmd_alloc(&init_mm, pudp, ea);
-		if (!pmdp)
-			return -ENOMEM;
-		ptep = pte_alloc_kernel(pmdp, ea);
-		if (!ptep)
-			return -ENOMEM;
-		set_pte_at(&init_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT,
-							  __pgprot(flags)));
-	} else {
-#ifdef CONFIG_PPC_MMU_NOHASH
-		pgdp = pgd_offset_k(ea);
-#ifdef PUD_TABLE_SIZE
-		if (pgd_none(*pgdp)) {
-			pudp = early_alloc_pgtable(PUD_TABLE_SIZE);
-			BUG_ON(pudp == NULL);
-			pgd_populate(&init_mm, pgdp, pudp);
-		}
-#endif /* PUD_TABLE_SIZE */
-		pudp = pud_offset(pgdp, ea);
-		if (pud_none(*pudp)) {
-			pmdp = early_alloc_pgtable(PMD_TABLE_SIZE);
-			BUG_ON(pmdp == NULL);
-			pud_populate(&init_mm, pudp, pmdp);
-		}
-		pmdp = pmd_offset(pudp, ea);
-		if (!pmd_present(*pmdp)) {
-			ptep = early_alloc_pgtable(PAGE_SIZE);
-			BUG_ON(ptep == NULL);
-			pmd_populate_kernel(&init_mm, pmdp, ptep);
-		}
-		ptep = pte_offset_kernel(pmdp, ea);
-		set_pte_at(&init_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT,
-							  __pgprot(flags)));
-#else /* CONFIG_PPC_MMU_NOHASH */
-		/*
-		 * If the mm subsystem is not fully up, we cannot create a
-		 * linux page table entry for this mapping.  Simply bolt an
-		 * entry in the hardware page table.
-		 *
-		 */
-		if (htab_bolt_mapping(ea, ea + PAGE_SIZE, pa, flags,
-				      mmu_io_psize, mmu_kernel_ssize)) {
-			printk(KERN_ERR "Failed to do bolted mapping IO "
-			       "memory at %016lx !\n", pa);
-			return -ENOMEM;
-		}
-#endif /* !CONFIG_PPC_MMU_NOHASH */
-	}
-
-	smp_wmb();
-	return 0;
-}
-
-
 /**
  * __ioremap_at - Low level function to establish the page tables
  *                for an IO mapping
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index 6b2f3e457171..d051086f7a19 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -174,6 +174,36 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
 		add_hash_page(mm->context.id, ea, pmd_val(*pmd));
 }
 
+void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
+		      pte_t *ptep)
+{
+	/*
+	 * We don't need to worry about _PAGE_PRESENT here because we are
+	 * called with either mm->page_table_lock held or ptl lock held
+	 */
+	unsigned long access = 0, trap;
+
+	/* We only want HPTEs for linux PTEs that have _PAGE_ACCESSED set */
+	if (!pte_young(*ptep) || address >= TASK_SIZE)
+		return;
+
+	/* We try to figure out if we are coming from an instruction
+	 * access fault and pass that down to __hash_page so we avoid
+	 * double-faulting on execution of fresh text. We have to test
+	 * for regs NULL since init will get here first thing at boot
+	 *
+	 * We also avoid filling the hash if not coming from a fault
+	 */
+	if (current->thread.regs == NULL)
+		return;
+	trap = TRAP(current->thread.regs);
+	if (trap == 0x400)
+		access |= _PAGE_EXEC;
+	else if (trap != 0x300)
+		return;
+	hash_preload(vma->vm_mm, address, access, trap);
+}
+
 /*
  * Initialize the hash table and patch the instructions in hashtable.S.
  */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
