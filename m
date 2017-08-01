Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 116A36B0541
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:41:39 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g35so14850036ioi.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:39 -0700 (PDT)
Received: from mail-io0-f195.google.com (mail-io0-f195.google.com. [209.85.223.195])
        by mx.google.com with ESMTPS id m71si1586677ith.196.2017.08.01.05.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:41:38 -0700 (PDT)
Received: by mail-io0-f195.google.com with SMTP id o9so1441225iod.5
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:38 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/6] mm, arch: unify vmemmap_populate altmap handling
Date: Tue,  1 Aug 2017 14:41:07 +0200
Message-Id: <20170801124111.28881-3-mhocko@kernel.org>
In-Reply-To: <20170801124111.28881-1-mhocko@kernel.org>
References: <20170801124111.28881-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>

From: Michal Hocko <mhocko@suse.com>

vmem_altmap allows vmemmap_populate to allocate memmap (struct page
array) from an alternative allocator rather than bootmem resp.
kmalloc. Only x86 currently supports altmap handling, most likely
because only nvdim code uses this mechanism currently and the code
depends on ZONE_DEVICE which is present only for x86_64. This will
change in follow up changes so we would like other architectures
to support it as well.

Provide vmemmap_populate generic implementation which simply resolves
altmap and then call into arch specific __vmemmap_populate.
Architectures then only need to use __vmemmap_alloc_block_buf to
allocate the memmap. vmemmap_free then needs to call vmem_altmap_free
if there is any altmap associated with the address.

This patch shouldn't introduce any functional changes because
to_vmem_altmap always returns NULL on !x86_x64.

Changes since v1
- s390: use altmap even for ptes in case the HW doesn't support large
  pages as per Gerald Schaefer

c: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-ia64@vger.kernel.org
Cc: x86@kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/arm64/mm/mmu.c       |  9 ++++++---
 arch/ia64/mm/discontig.c  |  4 +++-
 arch/powerpc/mm/init_64.c | 29 ++++++++++++++++++++---------
 arch/s390/mm/vmem.c       |  9 +++++----
 arch/sparc/mm/init_64.c   |  6 +++---
 arch/x86/mm/init_64.c     |  4 ++--
 include/linux/memremap.h  | 13 ++-----------
 include/linux/mm.h        | 19 ++++++++++++++++++-
 mm/sparse-vmemmap.c       |  2 +-
 9 files changed, 60 insertions(+), 35 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 0c429ec6fde8..5de1161e7a1b 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -649,12 +649,15 @@ int kern_addr_valid(unsigned long addr)
 }
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #if !ARM64_SWAPPER_USES_SECTION_MAPS
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
+	WARN(altmap, "altmap unsupported\n");
 	return vmemmap_populate_basepages(start, end, node);
 }
 #else	/* !ARM64_SWAPPER_USES_SECTION_MAPS */
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	unsigned long addr = start;
 	unsigned long next;
@@ -677,7 +680,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		if (pmd_none(*pmd)) {
 			void *p = NULL;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
 			if (!p)
 				return -ENOMEM;
 
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 878626805369..2a939e877ced 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -753,8 +753,10 @@ void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
+	WARN(altmap, "altmap unsupported\n");
 	return vmemmap_populate_basepages(start, end, node);
 }
 
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index ec84b31c6c86..5ea5e870a589 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -44,6 +44,7 @@
 #include <linux/slab.h>
 #include <linux/of_fdt.h>
 #include <linux/libfdt.h>
+#include <linux/memremap.h>
 
 #include <asm/pgalloc.h>
 #include <asm/page.h>
@@ -115,7 +116,8 @@ static struct vmemmap_backing *next;
 static int num_left;
 static int num_freed;
 
-static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node)
+static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node,
+		struct vmem_altmap *altmap)
 {
 	struct vmemmap_backing *vmem_back;
 	/* get from freed entries first */
@@ -129,7 +131,7 @@ static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node)
 
 	/* allocate a page when required and hand out chunks */
 	if (!num_left) {
-		next = vmemmap_alloc_block(PAGE_SIZE, node);
+		next = __vmemmap_alloc_block_buf(PAGE_SIZE, node, altmap);
 		if (unlikely(!next)) {
 			WARN_ON(1);
 			return NULL;
@@ -144,11 +146,12 @@ static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node)
 
 static __meminit void vmemmap_list_populate(unsigned long phys,
 					    unsigned long start,
-					    int node)
+					    int node,
+					    struct vmem_altmap *altmap)
 {
 	struct vmemmap_backing *vmem_back;
 
-	vmem_back = vmemmap_list_alloc(node);
+	vmem_back = vmemmap_list_alloc(node, altmap);
 	if (unlikely(!vmem_back)) {
 		WARN_ON(1);
 		return;
@@ -161,14 +164,15 @@ static __meminit void vmemmap_list_populate(unsigned long phys,
 	vmemmap_list = vmem_back;
 }
 
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
 
 	/* Align to the page size of the linear mapping. */
 	start = _ALIGN_DOWN(start, page_size);
 
-	pr_debug("vmemmap_populate %lx..%lx, node %d\n", start, end, node);
+	pr_debug("__vmemmap_populate %lx..%lx, node %d\n", start, end, node);
 
 	for (; start < end; start += page_size) {
 		void *p;
@@ -177,11 +181,11 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		if (vmemmap_populated(start, page_size))
 			continue;
 
-		p = vmemmap_alloc_block(page_size, node);
+		p = __vmemmap_alloc_block_buf(page_size, node, altmap);
 		if (!p)
 			return -ENOMEM;
 
-		vmemmap_list_populate(__pa(p), start, node);
+		vmemmap_list_populate(__pa(p), start, node, altmap);
 
 		pr_debug("      * %016lx..%016lx allocated at %p\n",
 			 start, start + page_size, p);
@@ -189,7 +193,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		rc = vmemmap_create_mapping(start, page_size, __pa(p));
 		if (rc < 0) {
 			pr_warning(
-				"vmemmap_populate: Unable to create vmemmap mapping: %d\n",
+				"__vmemmap_populate: Unable to create vmemmap mapping: %d\n",
 				rc);
 			return -EFAULT;
 		}
@@ -253,6 +257,12 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 		addr = vmemmap_list_free(start);
 		if (addr) {
 			struct page *page = pfn_to_page(addr >> PAGE_SHIFT);
+			struct vmem_altmap *altmap = to_vmem_altmap((unsigned long) page);
+
+			if (altmap) {
+				vmem_altmap_free(altmap, page_size >> PAGE_SHIFT);
+				goto unmap;
+			}
 
 			if (PageReserved(page)) {
 				/* allocated from bootmem */
@@ -272,6 +282,7 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 				free_pages((unsigned long)(__va(addr)),
 							get_order(page_size));
 
+unmap:
 			vmemmap_remove_mapping(start, page_size);
 		}
 	}
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index c33c94b4be60..764b6393e66c 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -208,7 +208,8 @@ static void vmem_remove_range(unsigned long start, unsigned long size)
 /*
  * Add a backed mem_map array to the virtual mem_map array.
  */
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
 	unsigned long pgt_prot, sgt_prot;
 	unsigned long address = start;
@@ -247,12 +248,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 			 * use large frames even if they are only partially
 			 * used.
 			 * Otherwise we would have also page tables since
-			 * vmemmap_populate gets called for each section
+			 * __vmemmap_populate gets called for each section
 			 * separately. */
 			if (MACHINE_HAS_EDAT1) {
 				void *new_page;
 
-				new_page = vmemmap_alloc_block(PMD_SIZE, node);
+				new_page = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
 				if (!new_page)
 					goto out;
 				pmd_val(*pm_dir) = __pa(new_page) | sgt_prot;
@@ -272,7 +273,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		if (pte_none(*pt_dir)) {
 			void *new_page;
 
-			new_page = vmemmap_alloc_block(PAGE_SIZE, node);
+			new_page = __vmemmap_alloc_block_buf(PAGE_SIZE, node, altmap);
 			if (!new_page)
 				goto out;
 			pte_val(*pt_dir) = __pa(new_page) | pgt_prot;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 3c40ebd50f92..4a77dfa85468 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2544,8 +2544,8 @@ unsigned long _PAGE_CACHE __read_mostly;
 EXPORT_SYMBOL(_PAGE_CACHE);
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
-			       int node)
+int __meminit __vmemmap_populate(unsigned long vstart, unsigned long vend,
+			       int node, struct vmem_altmap *altmap)
 {
 	unsigned long pte_base;
 
@@ -2587,7 +2587,7 @@ int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
 
 		pte = pmd_val(*pmd);
 		if (!(pte & _PAGE_VALID)) {
-			void *block = vmemmap_alloc_block(PMD_SIZE, node);
+			void *block = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
 
 			if (!block)
 				return -ENOMEM;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 136422d7d539..cfe01150f24f 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1398,9 +1398,9 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 	return 0;
 }
 
-int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
+int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap)
 {
-	struct vmem_altmap *altmap = to_vmem_altmap(start);
 	int err;
 
 	if (boot_cpu_has(X86_FEATURE_PSE))
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 93416196ba64..6f8f65d8ebdd 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -8,12 +8,12 @@ struct resource;
 struct device;
 
 /**
- * struct vmem_altmap - pre-allocated storage for vmemmap_populate
+ * struct vmem_altmap - pre-allocated storage for __vmemmap_populate
  * @base_pfn: base of the entire dev_pagemap mapping
  * @reserve: pages mapped, but reserved for driver use (relative to @base)
  * @free: free pages set aside in the mapping for memmap storage
  * @align: pages reserved to meet allocation alignments
- * @alloc: track pages consumed, private to vmemmap_populate()
+ * @alloc: track pages consumed, private to __vmemmap_populate()
  */
 struct vmem_altmap {
 	const unsigned long base_pfn;
@@ -26,15 +26,6 @@ struct vmem_altmap {
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
 
-#ifdef CONFIG_ZONE_DEVICE
-struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
-#else
-static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
-{
-	return NULL;
-}
-#endif
-
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6f543a47fc92..957d4658977d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2441,10 +2441,27 @@ static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
 	return __vmemmap_alloc_block_buf(size, node, NULL);
 }
 
+#ifdef CONFIG_ZONE_DEVICE
+struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
+#else
+static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
+{
+	return NULL;
+}
+#endif
+
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
-int vmemmap_populate(unsigned long start, unsigned long end, int node);
+int __vmemmap_populate(unsigned long start, unsigned long end, int node,
+		struct vmem_altmap *altmap);
+static inline int vmemmap_populate(unsigned long start, unsigned long end,
+		int node)
+{
+	struct vmem_altmap *altmap = to_vmem_altmap(start);
+	return __vmemmap_populate(start, end, node, altmap);
+}
+
 void vmemmap_populate_print_last(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
 void vmemmap_free(unsigned long start, unsigned long end);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index d1a39b8051e0..48c44eda3254 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -14,7 +14,7 @@
  * case the overhead consists of a few additional pages that are
  * allocated to create a view of memory for vmemmap.
  *
- * The architecture is expected to provide a vmemmap_populate() function
+ * The architecture is expected to provide a __vmemmap_populate() function
  * to instantiate the mapping.
  */
 #include <linux/mm.h>
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
