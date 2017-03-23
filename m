Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 364D76B0352
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 18:55:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t87so287021561pfk.4
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 15:55:26 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d2si183736pfk.113.2017.03.23.15.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 15:55:22 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v1 3/5] mm: add "zero" argument to vmemmap allocators
Date: Thu, 23 Mar 2017 19:01:51 -0400
Message-Id: <1490310113-824438-4-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.or

Allow clients to request non-zeroed memory from vmemmap allocator.
The following two public function have a new boolean argument called zero:

__vmemmap_alloc_block_buf()
vmemmap_alloc_block()

When zero is true, memory that is allocated by memblock allocator is zeroed
(the current behavior), when argument is false, the memory is not zeroed.

This change allows for optimizations where client knows when it is better
to zero memory: may be later when other CPUs are started, or may be client
is going to set every byte in the allocated memory, so no need to zero
memory beforehand.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 arch/powerpc/mm/init_64.c |    4 +-
 arch/s390/mm/vmem.c       |    5 ++-
 arch/sparc/mm/init_64.c   |    3 +-
 arch/x86/mm/init_64.c     |    3 +-
 include/linux/mm.h        |    6 ++--
 mm/sparse-vmemmap.c       |   48 +++++++++++++++++++++++++++++---------------
 6 files changed, 43 insertions(+), 26 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 9be9920..eb4c270 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -133,7 +133,7 @@ static int __meminit vmemmap_populated(unsigned long start, int page_size)
 
 	/* allocate a page when required and hand out chunks */
 	if (!num_left) {
-		next = vmemmap_alloc_block(PAGE_SIZE, node);
+		next = vmemmap_alloc_block(PAGE_SIZE, node, true);
 		if (unlikely(!next)) {
 			WARN_ON(1);
 			return NULL;
@@ -181,7 +181,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		if (vmemmap_populated(start, page_size))
 			continue;
 
-		p = vmemmap_alloc_block(page_size, node);
+		p = vmemmap_alloc_block(page_size, node, true);
 		if (!p)
 			return -ENOMEM;
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 60d3899..9c75214 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -251,7 +251,8 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 			if (MACHINE_HAS_EDAT1) {
 				void *new_page;
 
-				new_page = vmemmap_alloc_block(PMD_SIZE, node);
+				new_page = vmemmap_alloc_block(PMD_SIZE, node,
+							       true);
 				if (!new_page)
 					goto out;
 				pmd_val(*pm_dir) = __pa(new_page) | sgt_prot;
@@ -271,7 +272,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		if (pte_none(*pt_dir)) {
 			void *new_page;
 
-			new_page = vmemmap_alloc_block(PAGE_SIZE, node);
+			new_page = vmemmap_alloc_block(PAGE_SIZE, node, true);
 			if (!new_page)
 				goto out;
 			pte_val(*pt_dir) = __pa(new_page) | pgt_prot;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 01eccab..d91e462 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2541,7 +2541,8 @@ int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
 		pmd = pmd_offset(pud, vstart);
 		pte = pmd_val(*pmd);
 		if (!(pte & _PAGE_VALID)) {
-			void *block = vmemmap_alloc_block(PMD_SIZE, node);
+			void *block = vmemmap_alloc_block(PMD_SIZE, node,
+							  true);
 
 			if (!block)
 				return -ENOMEM;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 15173d3..46101b6 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1176,7 +1176,8 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (pmd_none(*pmd)) {
 			void *p;
 
-			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
+			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap,
+						      true);
 			if (p) {
 				pte_t entry;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5f01c88..54df194 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2410,13 +2410,13 @@ void sparse_mem_maps_populate_node(struct page **map_map,
 pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
 pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
-void *vmemmap_alloc_block(unsigned long size, int node);
+void *vmemmap_alloc_block(unsigned long size, int node, bool zero);
 struct vmem_altmap;
 void *__vmemmap_alloc_block_buf(unsigned long size, int node,
-		struct vmem_altmap *altmap);
+		struct vmem_altmap *altmap, bool zero);
 static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
 {
-	return __vmemmap_alloc_block_buf(size, node, NULL);
+	return __vmemmap_alloc_block_buf(size, node, NULL, true);
 }
 
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index a56c398..1e9508b 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -39,16 +39,27 @@
 static void * __ref __earlyonly_bootmem_alloc(int node,
 				unsigned long size,
 				unsigned long align,
-				unsigned long goal)
+				unsigned long goal,
+				bool zero)
 {
-	return memblock_virt_alloc_try_nid(size, align, goal,
-					    BOOTMEM_ALLOC_ACCESSIBLE, node);
+	void *mem = memblock_virt_alloc_try_nid_raw(size, align, goal,
+						    BOOTMEM_ALLOC_ACCESSIBLE,
+						    node);
+	if (!mem) {
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=0x%lx\n",
+		      __func__, size, align, node, goal);
+		return NULL;
+	}
+
+	if (zero)
+		memset(mem, 0, size);
+	return mem;
 }
 
 static void *vmemmap_buf;
 static void *vmemmap_buf_end;
 
-void * __meminit vmemmap_alloc_block(unsigned long size, int node)
+void * __meminit vmemmap_alloc_block(unsigned long size, int node, bool zero)
 {
 	/* If the main allocator is up use that, fallback to bootmem. */
 	if (slab_is_available()) {
@@ -67,24 +78,27 @@
 		return NULL;
 	} else
 		return __earlyonly_bootmem_alloc(node, size, size,
-				__pa(MAX_DMA_ADDRESS));
+				__pa(MAX_DMA_ADDRESS), zero);
 }
 
 /* need to make sure size is all the same during early stage */
-static void * __meminit alloc_block_buf(unsigned long size, int node)
+static void * __meminit alloc_block_buf(unsigned long size, int node, bool zero)
 {
 	void *ptr;
 
 	if (!vmemmap_buf)
-		return vmemmap_alloc_block(size, node);
+		return vmemmap_alloc_block(size, node, zero);
 
 	/* take the from buf */
 	ptr = (void *)ALIGN((unsigned long)vmemmap_buf, size);
 	if (ptr + size > vmemmap_buf_end)
-		return vmemmap_alloc_block(size, node);
+		return vmemmap_alloc_block(size, node, zero);
 
 	vmemmap_buf = ptr + size;
 
+	if (zero)
+		memset(ptr, 0, size);
+
 	return ptr;
 }
 
@@ -152,11 +166,11 @@ static unsigned long __meminit vmem_altmap_alloc(struct vmem_altmap *altmap,
 
 /* need to make sure size is all the same during early stage */
 void * __meminit __vmemmap_alloc_block_buf(unsigned long size, int node,
-		struct vmem_altmap *altmap)
+		struct vmem_altmap *altmap, bool zero)
 {
 	if (altmap)
 		return altmap_alloc_block_buf(size, altmap);
-	return alloc_block_buf(size, node);
+	return alloc_block_buf(size, node, zero);
 }
 
 void __meminit vmemmap_verify(pte_t *pte, int node,
@@ -175,7 +189,7 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte)) {
 		pte_t entry;
-		void *p = alloc_block_buf(PAGE_SIZE, node);
+		void *p = alloc_block_buf(PAGE_SIZE, node, true);
 		if (!p)
 			return NULL;
 		entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
@@ -188,7 +202,7 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 {
 	pmd_t *pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block(PAGE_SIZE, node, true);
 		if (!p)
 			return NULL;
 		pmd_populate_kernel(&init_mm, pmd, p);
@@ -200,7 +214,7 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 {
 	pud_t *pud = pud_offset(p4d, addr);
 	if (pud_none(*pud)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block(PAGE_SIZE, node, true);
 		if (!p)
 			return NULL;
 		pud_populate(&init_mm, pud, p);
@@ -212,7 +226,7 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 {
 	p4d_t *p4d = p4d_offset(pgd, addr);
 	if (p4d_none(*p4d)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block(PAGE_SIZE, node, true);
 		if (!p)
 			return NULL;
 		p4d_populate(&init_mm, p4d, p);
@@ -224,7 +238,7 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 {
 	pgd_t *pgd = pgd_offset_k(addr);
 	if (pgd_none(*pgd)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block(PAGE_SIZE, node, true);
 		if (!p)
 			return NULL;
 		pgd_populate(&init_mm, pgd, p);
@@ -290,8 +304,8 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	void *vmemmap_buf_start;
 
 	size = ALIGN(size, PMD_SIZE);
-	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size * map_count,
-			 PMD_SIZE, __pa(MAX_DMA_ADDRESS));
+	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size
+			* map_count, PMD_SIZE, __pa(MAX_DMA_ADDRESS), false);
 
 	if (vmemmap_buf_start) {
 		vmemmap_buf = vmemmap_buf_start;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
