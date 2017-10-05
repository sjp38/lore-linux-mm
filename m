Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAD46B026A
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 17:12:19 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 6so12005428qtw.5
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 14:12:19 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a18si4453682qtk.187.2017.10.05.14.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 14:12:18 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v10 09/10] mm: stop zeroing memory during allocation in vmemmap
Date: Thu,  5 Oct 2017 17:11:23 -0400
Message-Id: <20171005211124.26524-10-pasha.tatashin@oracle.com>
In-Reply-To: <20171005211124.26524-1-pasha.tatashin@oracle.com>
References: <20171005211124.26524-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

vmemmap_alloc_block() will no longer zero the block, so zero memory
at its call sites for everything except struct pages.  Struct page memory
is zero'd by struct page initialization.

Replace allocators in sprase-vmemmap to use the non-zeroing version. So,
we will get the performance improvement by zeroing the memory in parallel
when struct pages are zeroed.

Add struct page zeroing as a part of initialization of other fields in
__init_single_page().

This single thread performance collected on: Intel(R) Xeon(R) CPU E7-8895
v3 @ 2.60GHz with 1T of memory (268400646 pages in 8 nodes):

                         BASE            FIX
sparse_init     11.244671836s   0.007199623s
zone_sizes_init  4.879775891s   8.355182299s
                  --------------------------
Total           16.124447727s   8.362381922s

sparse_init is where memory for struct pages is zeroed, and the zeroing
part is moved later in this patch into __init_single_page(), which is
called from zone_sizes_init().

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h  | 11 +++++++++++
 mm/page_alloc.c     |  1 +
 mm/sparse-vmemmap.c | 15 +++++++--------
 mm/sparse.c         |  6 +++---
 4 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 04c8b2e5aff4..fd045a3b243a 100644
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5f0013bbbe9d..85e038e1e941 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1170,6 +1170,7 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
+	mm_zero_struct_page(page);
 	set_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
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
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
