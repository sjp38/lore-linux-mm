Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0D46B027F
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:15:54 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id l13so14881084qtc.9
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:15:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t81si5202117qka.87.2017.11.23.03.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 03:15:52 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANBFNUw047200
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:15:51 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2educ81ef6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:15:50 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 11:15:48 -0000
Date: Thu, 23 Nov 2017 11:15:42 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: [PATCH v2 5/5] mm: memory-hotplug: Add memory hot remove support for
 arm64
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cover.1511433386.git.ar@linux.vnet.ibm.com>
Message-Id: <a7507f1245c957aec8732855a3dfdbe73a1254de.1511433386.git.ar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

Implementation of pagetable cleanup routines for arm64 memory hot remove.

How to offline:
 1. Logical Hot remove (offline)
 - # echo offline > /sys/devices/system/memory/memoryXX/state
 2. Physical Hot remove (offline)
 - (if offline is successful)
 - # echo $section_phy_address > /sys/devices/system/memory/remove

Changes v1->v2:
- introduced check on offlining state before hot remove:
  in x86 (and possibly other architectures), offlining of pages and hot
  remove of physical memory happen in a single step, i.e., via an acpi
  event. In this patchset we are introducing a "remove" sysfs handle
  that triggers the physical hot-remove process after manual offlining.

- new memblock flag used to mark partially unused vmemmap pages, avoiding
  the nasty 0xFD hack used in the prev rev (and in x86 hot remove code):
  the hot remove process needs to take care of freeing vmemmap pages
  and mappings for the memory being removed. Sometimes, it might be not
  possible to free fully a vmemmap page (because it is being used for
  other mappings); in such a case we mark part of that page as unused and
  we free it only when it is fully unused. In the previous version, in
  symmetry to x86 hot remove code, we were doing this marking by filling
  the unused parts of the page with an aribitrary 0xFD constant. In this
  version, we are using a new memblock flag for the same purpose.

- proper cleaning sequence for p[um]ds,ptes and related TLB management:
  i) clear the page table, ii) flush tlb, iii) free the pagetable page

- Removed macros that changed hot remove behavior based on number
  of pgtable levels. Now this is hidden in the pgtable traversal macros.

- Check on the corner case where P[UM]Ds would have to be split during
  hot remove: now this is forbidden.
  Hot addition and removal is done at SECTION_SIZE_BITS granularity
  (currently 1GB).  The only case when we would have to split a P[UM]D
  is when SECTION_SIZE_BITS is smaller than a P[UM]D mapped area (never
  by default), AND when we are removing some P[UM]D-mapped memory that
  was never hot-added (there since boot).  If the above conditions hold,
  we avoid splitting the P[UM]Ds and, instead, we forbid hot removal.

- Minor fixes and refactoring.

Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
---
 arch/arm64/Kconfig           |   3 +
 arch/arm64/configs/defconfig |   1 +
 arch/arm64/include/asm/mmu.h |   4 +
 arch/arm64/mm/init.c         |  29 +++
 arch/arm64/mm/mmu.c          | 572 ++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 601 insertions(+), 8 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index c736bba..c362ddf 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -649,6 +649,9 @@ config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
     depends on !NUMA
 
+config ARCH_ENABLE_MEMORY_HOTREMOVE
+	def_bool y
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
diff --git a/arch/arm64/configs/defconfig b/arch/arm64/configs/defconfig
index 5fc5656..cdac3b8 100644
--- a/arch/arm64/configs/defconfig
+++ b/arch/arm64/configs/defconfig
@@ -81,6 +81,7 @@ CONFIG_SCHED_MC=y
 CONFIG_NUMA=y
 CONFIG_PREEMPT=y
 CONFIG_MEMORY_HOTPLUG=y
+CONFIG_MEMORY_HOTREMOVE=y
 CONFIG_KSM=y
 CONFIG_TRANSPARENT_HUGEPAGE=y
 CONFIG_CMA=y
diff --git a/arch/arm64/include/asm/mmu.h b/arch/arm64/include/asm/mmu.h
index 2b3fa4d..ca11567 100644
--- a/arch/arm64/include/asm/mmu.h
+++ b/arch/arm64/include/asm/mmu.h
@@ -42,6 +42,10 @@ extern void *fixmap_remap_fdt(phys_addr_t dt_phys);
 extern void mark_linear_text_alias_ro(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
 extern void hotplug_paging(phys_addr_t start, phys_addr_t size);
+#ifdef CONFIG_MEMORY_HOTREMOVE
+extern int remove_pagetable(unsigned long start,
+	unsigned long end, bool linear_map, bool check_split);
+#endif
 #endif
 
 #endif
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index e96e7d3..406b378 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -808,4 +808,33 @@ int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
 	return ret;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	unsigned long va_start = (unsigned long) __va(start);
+	unsigned long va_end = (unsigned long)__va(start + size);
+	struct page *page = pfn_to_page(start_pfn);
+	struct zone *zone;
+	int ret = 0;
+
+	/*
+	 * Check if mem can be removed without splitting
+	 * PUD/PMD mappings.
+	 */
+	ret = remove_pagetable(va_start, va_end, true, true);
+	if (!ret) {
+		zone = page_zone(page);
+		ret = __remove_pages(zone, start_pfn, nr_pages);
+		WARN_ON_ONCE(ret);
+
+		/* Actually remove the mapping */
+		remove_pagetable(va_start, va_end, true, false);
+	}
+
+	return ret;
+}
+
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index d93043d..e6f8c91 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -25,6 +25,7 @@
 #include <linux/ioport.h>
 #include <linux/kexec.h>
 #include <linux/libfdt.h>
+#include <linux/memremap.h>
 #include <linux/mman.h>
 #include <linux/nodemask.h>
 #include <linux/memblock.h>
@@ -652,12 +653,532 @@ inline void hotplug_paging(phys_addr_t start, phys_addr_t size)
 
 	stop_machine(__hotplug_paging, &section, NULL);
 }
-#endif /* CONFIG_MEMORY_HOTPLUG */
+#ifdef CONFIG_MEMORY_HOTREMOVE
+
+static void  free_pagetable(struct page *page, int order, bool linear_map)
+{
+	unsigned long magic;
+	unsigned int nr_pages = 1 << order;
+	struct vmem_altmap *altmap = to_vmem_altmap((unsigned long) page);
+
+	if (altmap) {
+		vmem_altmap_free(altmap, nr_pages);
+		return;
+	}
+
+	/* bootmem page has reserved flag */
+	if (PageReserved(page)) {
+		__ClearPageReserved(page);
+
+		magic = (unsigned long)page->lru.next;
+		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
+			while (nr_pages--)
+				put_page_bootmem(page++);
+		} else {
+			while (nr_pages--)
+				free_reserved_page(page++);
+		}
+	} else {
+		/*
+		 * Only linear_map pagetable allocation (those allocated via
+		 * hotplug) call the pgtable_page_ctor; vmemmap pgtable
+		 * allocations don't.
+		 */
+		if (linear_map)
+			pgtable_page_dtor(page);
+
+		free_pages((unsigned long)page_address(page), order);
+	}
+}
+
+static void free_pte_table(unsigned long addr, pmd_t *pmd, bool linear_map)
+{
+	pte_t *pte;
+	struct page *page;
+	int i;
+
+	pte =  pte_offset_kernel(pmd, 0L);
+	/* Check if there is no valid entry in the PMD */
+	for (i = 0; i < PTRS_PER_PTE; i++, pte++) {
+		if (!pte_none(*pte))
+			return;
+	}
+
+	page = pmd_page(*pmd);
+	/*
+	 * This spin lock could be only taken in _pte_aloc_kernel
+	 * in mm/memory.c and nowhere else (for arm64). Not sure if
+	 * the function above can be called concurrently. In doubt,
+	 * I am living it here for now, but it probably can be removed
+	 */
+	spin_lock(&init_mm.page_table_lock);
+	pmd_clear(pmd);
+	spin_unlock(&init_mm.page_table_lock);
+
+	/* Make sure addr is aligned with first address of the PMD*/
+	addr &= PMD_MASK;
+	/*
+	 * Invalidate TLB walk caches to PTE
+	 * Not sure what is the index of the TLB walk caches.
+	 * i.e., if it is indexed just by addr & PMD_MASK or it can be
+	 * indexed by any address. Flushing everything to stay on the safe
+	 * side.
+	 */
+	flush_tlb_kernel_range(addr, addr + PMD_SIZE);
+
+	free_pagetable(page, 0, linear_map);
+}
+
+static void free_pmd_table(unsigned long addr, pud_t *pud, bool linear_map)
+{
+	pmd_t *pmd;
+	struct page *page;
+	int i;
+
+	pmd = pmd_offset(pud, 0L);
+	/*
+	 * If PMD is folded onto PUD, cleanup was already performed
+	 * up in the call stack. No more work needs to be done.
+	 */
+	if ((pud_t *) pmd == pud)
+		return;
+
+	/* Check if there is no valid entry in the PMD */
+	for (i = 0; i < PTRS_PER_PMD; i++, pmd++) {
+		if (!pmd_none(*pmd))
+			return;
+	}
+
+	page = pud_page(*pud);
+	/*
+	 * This spin lock could be only taken in _pte_aloc_kernel
+	 * in mm/memory.c and nowhere else (for arm64). Not sure if
+	 * the function above can be called concurrently. In doubt,
+	 * I am living it here for now, but it probably can be removed
+	 */
+	spin_lock(&init_mm.page_table_lock);
+	pud_clear(pud);
+	spin_unlock(&init_mm.page_table_lock);
+
+	/* Make sure addr is aligned with first address of the PMD*/
+	addr &= PUD_MASK;
+	/*
+	 * Invalidate TLB walk caches to PMD
+	 * Not sure what is the index of the TLB walk caches.
+	 * i.e., if it is indexed just by addr & PUD_MASK or it can be
+	 * indexed by any address. Flushing everything to stay on the safe
+	 * side.
+	 */
+	flush_tlb_kernel_range(addr, addr + PUD_SIZE);
+
+	free_pagetable(page, 0, linear_map);
+}
+
+static void free_pud_table(unsigned long addr, pgd_t *pgd, bool linear_map)
+{
+	pud_t *pud;
+	struct page *page;
+	int i;
+
+	pud = pud_offset(pgd, 0L);
+	/*
+	 * If PUD is folded onto PGD, cleanup was already performed
+	 * up in the call stack. No more work needs to be done.
+	 */
+	if ((pgd_t *)pud == pgd)
+		return;
+
+	/* Check if there is no valid entry in the PUD */
+	for (i = 0; i < PTRS_PER_PUD; i++, pud++) {
+		if (!pud_none(*pud))
+			return;
+	}
+
+	page = pgd_page(*pgd);
+
+	/*
+	 * This spin lock could be only
+	 * taken in _pte_aloc_kernel in
+	 * mm/memory.c and nowhere else
+	 * (for arm64). Not sure if the
+	 * function above can be called
+	 * concurrently. In doubt,
+	 * I am living it here for now,
+	 * but it probably can be removed.
+	 */
+	spin_lock(&init_mm.page_table_lock);
+	pgd_clear(pgd);
+	spin_unlock(&init_mm.page_table_lock);
+
+	/* Make sure addr is aligned with first address of the PUD*/
+	addr &= PGDIR_MASK;
+	/*
+	 * Invalidate TLB walk caches to PUD
+	 *
+	 * Not sure what is the index of the TLB walk caches.
+	 * i.e., if it is indexed just by addr & PGDIR_MASK or it can be
+	 * indexed by any address. Flushing everything to stay on the safe
+	 * side
+	 */
+	flush_tlb_kernel_range(addr, addr + PGD_SIZE);
+
+	free_pagetable(page, 0, linear_map);
+}
+
+static void mark_n_free_pte_vmemmap(pte_t *pte,
+		unsigned long addr, unsigned long size)
+{
+	unsigned long page_offset =  (addr & (~PAGE_MASK));
+	phys_addr_t page_start = pte_val(*pte) & PHYS_MASK & (s32)PAGE_MASK;
+	phys_addr_t pa_start = page_start + page_offset;
+
+	memblock_mark_unused_vmemmap(pa_start, size);
+
+	if (memblock_is_vmemmap_unused_range(&memblock.memory,
+				page_start, page_start + PAGE_SIZE)) {
+
+		free_pagetable(pte_page(*pte), 0, false);
+		memblock_clear_unused_vmemmap(page_start, PAGE_SIZE);
+
+		/*
+		 * This spin lock could be only
+		 * taken in _pte_aloc_kernel in
+		 * mm/memory.c and nowhere else
+		 * (for arm64). Not sure if the
+		 * function above can be called
+		 * concurrently. In doubt,
+		 * I am living it here for now,
+		 * but it probably can be removed.
+		 */
+		spin_lock(&init_mm.page_table_lock);
+		pte_clear(&init_mm, addr, pte);
+		spin_unlock(&init_mm.page_table_lock);
+
+		flush_tlb_kernel_range(addr & PAGE_MASK,
+				(addr + PAGE_SIZE) & PAGE_MASK);
+	}
+}
+
+static void mark_n_free_pmd_vmemmap(pmd_t *pmd,
+		unsigned long addr, unsigned long size)
+{
+	unsigned long sec_offset =  (addr & (~PMD_MASK));
+	phys_addr_t page_start = pmd_page_paddr(*pmd);
+	phys_addr_t pa_start = page_start + sec_offset;
+
+	memblock_mark_unused_vmemmap(pa_start, size);
+
+	if (memblock_is_vmemmap_unused_range(&memblock.memory,
+				page_start, page_start + PMD_SIZE)) {
+
+		free_pagetable(pmd_page(*pmd),
+				get_order(PMD_SIZE), false);
+
+		memblock_clear_unused_vmemmap(page_start, PMD_SIZE);
+		/*
+		 * This spin lock could be only
+		 * taken in _pte_aloc_kernel in
+		 * mm/memory.c and nowhere else
+		 * (for arm64). Not sure if the
+		 * function above can be called
+		 * concurrently. In doubt,
+		 * I am living it here for now,
+		 * but it probably can be removed.
+		 */
+		spin_lock(&init_mm.page_table_lock);
+		pmd_clear(pmd);
+		spin_unlock(&init_mm.page_table_lock);
+
+		flush_tlb_kernel_range(addr & PMD_MASK,
+				(addr + PMD_SIZE) & PMD_MASK);
+	}
+}
+
+static void rm_pte_mapping(pte_t *pte, unsigned long addr,
+		unsigned long next, bool linear_map)
+{
+	/*
+	 * Linear map pages were already freed when offlining.
+	 * We aonly need to free vmemmap pages.
+	 */
+	if (!linear_map)
+		free_pagetable(pte_page(*pte), 0, false);
+
+	/*
+	 * This spin lock could be only
+	 * taken in _pte_aloc_kernel in
+	 * mm/memory.c and nowhere else
+	 * (for arm64). Not sure if the
+	 * function above can be called
+	 * concurrently. In doubt,
+	 * I am living it here for now,
+	 * but it probably can be removed.
+	 */
+	spin_lock(&init_mm.page_table_lock);
+	pte_clear(&init_mm, addr, pte);
+	spin_unlock(&init_mm.page_table_lock);
+
+	flush_tlb_kernel_range(addr, next);
+}
+
+static void rm_pmd_mapping(pmd_t *pmd, unsigned long addr,
+		unsigned long next, bool linear_map)
+{
+	/* Freeing vmemmap pages */
+	if (!linear_map)
+		free_pagetable(pmd_page(*pmd),
+				get_order(PMD_SIZE), false);
+	/*
+	 * This spin lock could be only
+	 * taken in _pte_aloc_kernel in
+	 * mm/memory.c and nowhere else
+	 * (for arm64). Not sure if the
+	 * function above can be called
+	 * concurrently. In doubt,
+	 * I am living it here for now,
+	 * but it probably can be removed.
+	 */
+	spin_lock(&init_mm.page_table_lock);
+	pmd_clear(pmd);
+	spin_unlock(&init_mm.page_table_lock);
+
+	flush_tlb_kernel_range(addr, next);
+}
+
+static void rm_pud_mapping(pud_t *pud, unsigned long addr,
+		unsigned long next, bool linear_map)
+{
+	/** We never map vmemmap space on PUDs */
+	BUG_ON(!linear_map);
+	/*
+	 * This spin lock could be only
+	 * taken in _pte_aloc_kernel in
+	 * mm/memory.c and nowhere else
+	 * (for arm64). Not sure if the
+	 * function above can be called
+	 * concurrently. In doubt,
+	 * I am living it here for now,
+	 * but it probably can be removed.
+	 */
+	spin_lock(&init_mm.page_table_lock);
+	pud_clear(pud);
+	spin_unlock(&init_mm.page_table_lock);
+
+	flush_tlb_kernel_range(addr, next);
+}
 
 /*
- * Check whether a kernel address is valid (derived from arch/x86/).
+ * Used in hot-remove, cleans up PTE entries from addr to end from the pointed
+ * pte table. If linear_map is true, this is used called to remove the tables
+ * for the memory being hot-removed. If false, this is called to clean-up the
+ * tables (and the memory) that were used for the vmemmap of memory being
+ * hot-removed.
  */
-int kern_addr_valid(unsigned long addr)
+static void remove_pte_table(pte_t *pte, unsigned long addr,
+	unsigned long end, bool linear_map)
+{
+	unsigned long next;
+
+
+	for (; addr < end; addr = next, pte++) {
+		next = (addr + PAGE_SIZE) & PAGE_MASK;
+		if (next > end)
+			next = end;
+
+		if (!pte_present(*pte))
+			continue;
+
+		if (PAGE_ALIGNED(addr) && PAGE_ALIGNED(next)) {
+			rm_pte_mapping(pte, addr, next, linear_map);
+		} else {
+			unsigned long sz = next - addr;
+			/*
+			 * If we are here, we are freeing vmemmap pages since
+			 * linear_map mapped memory ranges to be freed
+			 * are aligned.
+			 *
+			 * If we are not removing the whole page, it means
+			 * other page structs in this page are being used and
+			 * we canot remove them. We use memblock to mark these
+			 * unused pieces and we only removed when they are fully
+			 * unuesed.
+			 */
+			mark_n_free_pte_vmemmap(pte, addr, sz);
+		}
+	}
+}
+
+/**
+ * Used in hot-remove, cleans up PMD entries from addr to end from the pointed
+ * pmd table.
+ *
+ * If linear_map is true, this is used called to remove the tables for the
+ * memory being hot-removed. If false, this is called to clean-up the tables
+ * (and the memory) that were used for the vmemmap of memory being hot-removed.
+ *
+ * If check_split is true, no change is done on the table: the call only
+ * checks whether removing the entries would cause a section mapped PMD
+ * to be split. In such a case, -EBUSY is returned by the method.
+ */
+static int remove_pmd_table(pmd_t *pmd, unsigned long addr,
+	unsigned long end, bool linear_map, bool check_split)
+{
+	int err = 0;
+	unsigned long next;
+	pte_t *pte;
+
+	for (; !err && addr < end; addr = next, pmd++) {
+		next = pmd_addr_end(addr, end);
+
+		if (!pmd_present(*pmd))
+			continue;
+
+		if (pmd_sect(*pmd)) {
+			if (IS_ALIGNED(addr, PMD_SIZE) &&
+					IS_ALIGNED(next, PMD_SIZE)) {
+
+				if (!check_split)
+					rm_pmd_mapping(pmd, addr, next,
+							linear_map);
+
+			} else { /* not aligned to PMD size */
+
+				/*
+				 * This should only occur for vmemap.
+				 * If it does happen for linear map,
+				 * we do not support splitting PMDs,
+				 * so we return error
+				 */
+				if (linear_map) {
+					pr_warn("Hot-remove failed. Cannot split PMD mapping\n");
+					err = -EBUSY;
+				} else if (!check_split) {
+					unsigned long sz = next - addr;
+					/* Freeing vmemmap pages.*/
+					mark_n_free_pmd_vmemmap(pmd, addr, sz);
+				}
+			}
+		} else { /* ! pmd_sect() */
+
+			BUG_ON(!pmd_table(*pmd));
+			if (!check_split) {
+				pte = pte_offset_map(pmd, addr);
+				remove_pte_table(pte, addr, next, linear_map);
+				free_pte_table(addr, pmd, linear_map);
+			}
+		}
+	}
+
+	return err;
+}
+
+/**
+ * Used in hot-remove, cleans up PUD entries from addr to end from the pointed
+ * pmd table.
+ *
+ * If linear_map is true, this is used called to remove the tables for the
+ * memory being hot-removed. If false, this is called to clean-up the tables
+ * (and the memory) that were used for the vmemmap of memory being hot-removed.
+ *
+ * If check_split is true, no change is done on the table: the call only
+ * checks whether removing the entries would cause a section mapped PUD
+ * to be split. In such a case, -EBUSY is returned by the method.
+ */
+static int remove_pud_table(pud_t *pud, unsigned long addr,
+	unsigned long end, bool linear_map, bool check_split)
+{
+	int err = 0;
+	unsigned long next;
+	pmd_t *pmd;
+
+	for (; !err && addr < end; addr = next, pud++) {
+		next = pud_addr_end(addr, end);
+		if (!pud_present(*pud))
+			continue;
+
+		/*
+		 * If we are using 4K granules, check if we are using
+		 * 1GB section mapping.
+		 */
+		if (pud_sect(*pud)) {
+			if (IS_ALIGNED(addr, PUD_SIZE) &&
+					IS_ALIGNED(next, PUD_SIZE)) {
+
+				if (!check_split)
+					rm_pud_mapping(pud, addr, next,
+							linear_map);
+
+			} else { /* not aligned to PUD size */
+				/*
+				 * As above, we never map vmemmap
+				 * space on PUDs
+				 */
+				BUG_ON(!linear_map);
+				pr_warn("Hot-remove failed. Cannot split PUD mapping\n");
+				err = -EBUSY;
+			}
+		} else { /* !pud_sect() */
+			BUG_ON(!pud_table(*pud));
+
+			pmd = pmd_offset(pud, addr);
+			err = remove_pmd_table(pmd, addr, next,
+					linear_map, check_split);
+			if (!check_split)
+				free_pmd_table(addr, pud, linear_map);
+		}
+	}
+
+	return err;
+}
+
+/**
+ * Used in hot-remove, cleans up kernel page tables from addr to end.
+ *
+ * If linear_map is true, this is used called to remove the tables for the
+ * memory being hot-removed. If false, this is called to clean-up the tables
+ * (and the memory) that were used for the vmemmap of memory being hot-removed.
+ *
+ * If check_split is true, no change is done on the table: the call only
+ * checks whether removing the entries would cause a section mapped PUD
+ * to be split. In such a case, -EBUSY is returned by the method.
+ */
+int remove_pagetable(unsigned long start, unsigned long end,
+		bool linear_map, bool check_split)
+{
+	int err;
+	unsigned long next;
+	unsigned long addr;
+	pgd_t *pgd;
+	pud_t *pud;
+
+	for (addr = start; addr < end; addr = next) {
+		next = pgd_addr_end(addr, end);
+
+		pgd = pgd_offset_k(addr);
+		if (pgd_none(*pgd))
+			continue;
+
+		pud = pud_offset(pgd, addr);
+		err = remove_pud_table(pud, addr, next,
+				linear_map, check_split);
+		if (err)
+			break;
+
+		if (!check_split)
+			free_pud_table(addr, pgd, linear_map);
+	}
+
+	if (!check_split)
+		flush_tlb_all();
+
+	return err;
+}
+
+
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
+static unsigned long walk_kern_pgtable(unsigned long addr)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -676,26 +1197,51 @@ int kern_addr_valid(unsigned long addr)
 		return 0;
 
 	if (pud_sect(*pud))
-		return pfn_valid(pud_pfn(*pud));
+		return pud_pfn(*pud);
 
 	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		return 0;
 
 	if (pmd_sect(*pmd))
-		return pfn_valid(pmd_pfn(*pmd));
+		return pmd_pfn(*pmd);
 
 	pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte))
 		return 0;
 
-	return pfn_valid(pte_pfn(*pte));
+	return pte_pfn(*pte);
+}
+
+/*
+ * Check whether a kernel address is valid (derived from arch/x86/).
+ */
+int kern_addr_valid(unsigned long addr)
+{
+	return pfn_valid(walk_kern_pgtable(addr));
 }
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #if !ARM64_SWAPPER_USES_SECTION_MAPS
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	return vmemmap_populate_basepages(start, end, node);
+	int err;
+
+	err = vmemmap_populate_basepages(start, end, node);
+#ifdef CONFIG_MEMORY_HOTREMOVE
+    /*
+     * A bit inefficient (restarting from PGD every time) but saves
+     * from lots of duplicated code. Also, this is only called
+     * at hot-add time, which should not be a frequent operation
+     */
+	for (; start < end; start += PAGE_SIZE) {
+		unsigned long pfn = walk_kern_pgtable(start);
+		phys_addr_t pa_start = ((phys_addr_t)pfn) << PAGE_SHIFT;
+
+		memblock_clear_unused_vmemmap(pa_start, PAGE_SIZE);
+	}
+#endif
+	return err;
 }
 #else	/* !ARM64_SWAPPER_USES_SECTION_MAPS */
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
@@ -726,8 +1272,15 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 				return -ENOMEM;
 
 			set_pmd(pmd, __pmd(__pa(p) | PROT_SECT_NORMAL));
-		} else
+		} else {
+			unsigned long sec_offset =  (addr & (~PMD_MASK));
+			phys_addr_t pa_start =
+				pmd_page_paddr(*pmd) + sec_offset;
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
+#ifdef CONFIG_MEMORY_HOTREMOVE
+			memblock_clear_unused_vmemmap(pa_start, next - addr);
+#endif
+		}
 	} while (addr = next, addr != end);
 
 	return 0;
@@ -735,6 +1288,9 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 #endif	/* CONFIG_ARM64_64K_PAGES */
 void vmemmap_free(unsigned long start, unsigned long end)
 {
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	remove_pagetable(start, end, false, false);
+#endif
 }
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
