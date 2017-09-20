Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC7156B026F
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:18:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b195so3775771wmb.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:18:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g3si42106edh.321.2017.09.20.13.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 13:18:11 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v9 12/12] mm: stop zeroing memory during allocation in vmemmap
Date: Wed, 20 Sep 2017 16:17:14 -0400
Message-Id: <20170920201714.19817-13-pasha.tatashin@oracle.com>
In-Reply-To: <20170920201714.19817-1-pasha.tatashin@oracle.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

vmemmap_alloc_block() will no longer zero the block, so zero memory
at its call sites for everything except struct pages.  Struct page memory
is zero'd by struct page initialization.

Replace allocators in sprase-vmemmap to use the non-zeroing version. So,
we will get the performance improvement by zeroing the memory in parallel
when struct pages are zeroed.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 include/linux/mm.h  | 11 +++++++++++
 mm/sparse-vmemmap.c | 15 +++++++--------
 mm/sparse.c         |  6 +++---
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a7bba4ce79ba..25848764570f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2501,6 +2501,17 @@ static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
 	return __vmemmap_alloc_block_buf(size, node, NULL);
 }
 
+static inline void *vmemmap_alloc_block_zero(unsigned long size, int node)
+{
+	void *p = vmemmap_alloc_block(size, node);
+
+	if (!p)
+		return NULL;
+	memset(p, 0, size);
+
+	return p;
+}
+
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index d1a39b8051e0..c2f5654e7c9d 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -41,7 +41,7 @@ static void * __ref __earlyonly_bootmem_alloc(int node,
 				unsigned long align,
 				unsigned long goal)
 {
-	return memblock_virt_alloc_try_nid(size, align, goal,
+	return memblock_virt_alloc_try_nid_raw(size, align, goal,
 					    BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
@@ -54,9 +54,8 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 	if (slab_is_available()) {
 		struct page *page;
 
-		page = alloc_pages_node(node,
-			GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
-			get_order(size));
+		page = alloc_pages_node(node, GFP_KERNEL | __GFP_RETRY_MAYFAIL,
+					get_order(size));
 		if (page)
 			return page_address(page);
 		return NULL;
@@ -183,7 +182,7 @@ pmd_t * __meminit vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node)
 {
 	pmd_t *pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block_zero(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		pmd_populate_kernel(&init_mm, pmd, p);
@@ -195,7 +194,7 @@ pud_t * __meminit vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node)
 {
 	pud_t *pud = pud_offset(p4d, addr);
 	if (pud_none(*pud)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block_zero(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		pud_populate(&init_mm, pud, p);
@@ -207,7 +206,7 @@ p4d_t * __meminit vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node)
 {
 	p4d_t *p4d = p4d_offset(pgd, addr);
 	if (p4d_none(*p4d)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block_zero(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		p4d_populate(&init_mm, p4d, p);
@@ -219,7 +218,7 @@ pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
 {
 	pgd_t *pgd = pgd_offset_k(addr);
 	if (pgd_none(*pgd)) {
-		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block_zero(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		pgd_populate(&init_mm, pgd, p);
diff --git a/mm/sparse.c b/mm/sparse.c
index 83b3bf6461af..d22f51bb7c79 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -437,9 +437,9 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	}
 
 	size = PAGE_ALIGN(size);
-	map = memblock_virt_alloc_try_nid(size * map_count,
-					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
-					  BOOTMEM_ALLOC_ACCESSIBLE, nodeid);
+	map = memblock_virt_alloc_try_nid_raw(size * map_count,
+					      PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
+					      BOOTMEM_ALLOC_ACCESSIBLE, nodeid);
 	if (map) {
 		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 			if (!present_section_nr(pnum))
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
