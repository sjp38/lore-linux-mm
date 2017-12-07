Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 906346B0266
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:08:52 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so5893696pff.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:08:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i74si3773766pgc.832.2017.12.07.07.08.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 07:08:51 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/14] mm: split dev_pagemap memory map allocation from normal case
Date: Thu,  7 Dec 2017 07:08:33 -0800
Message-Id: <20171207150840.28409-8-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org

No functional changes, just untangling the call chain.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/mm/init_64.c |  6 ++++--
 arch/x86/mm/init_64.c     |  5 ++++-
 include/linux/mm.h        |  8 ++------
 mm/sparse-vmemmap.c       | 15 +++------------
 4 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index d6a040198edf..3a39a644e96c 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -202,8 +202,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 
 		/* altmap lookups only work at section boundaries */
 		altmap = to_vmem_altmap(SECTION_ALIGN_DOWN(start));
-
-		p =  __vmemmap_alloc_block_buf(page_size, node, altmap);
+		if (altmap)
+			p = dev_pagemap_alloc_block_buf(page_size, altmap);
+		else
+			p = vmemmap_alloc_block_buf(page_size, node);
 		if (!p)
 			return -ENOMEM;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 4f79ee1ef501..9e1b489aa826 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1371,7 +1371,10 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (pmd_none(*pmd)) {
 			void *p;
 
-			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
+			if (altmap)
+				p = dev_pagemap_alloc_block_buf(PMD_SIZE, altmap);
+			else
+				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (p) {
 				pte_t entry;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..856869e2c119 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2546,13 +2546,9 @@ pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
 struct vmem_altmap;
-void *__vmemmap_alloc_block_buf(unsigned long size, int node,
+void *vmemmap_alloc_block_buf(unsigned long size, int node);
+void *dev_pagemap_alloc_block_buf(unsigned long size,
 		struct vmem_altmap *altmap);
-static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
-{
-	return __vmemmap_alloc_block_buf(size, node, NULL);
-}
-
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 17acf01791fa..268b6c7dfdf4 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -74,7 +74,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 }
 
 /* need to make sure size is all the same during early stage */
-static void * __meminit alloc_block_buf(unsigned long size, int node)
+void * __meminit vmemmap_alloc_block_buf(unsigned long size, int node)
 {
 	void *ptr;
 
@@ -129,7 +129,7 @@ static unsigned long __meminit vmem_altmap_alloc(struct vmem_altmap *altmap,
 	return pfn + nr_align;
 }
 
-static void * __meminit altmap_alloc_block_buf(unsigned long size,
+void * __meminit dev_pagemap_alloc_block_buf(unsigned long size,
 		struct vmem_altmap *altmap)
 {
 	unsigned long pfn, nr_pfns;
@@ -153,15 +153,6 @@ static void * __meminit altmap_alloc_block_buf(unsigned long size,
 	return ptr;
 }
 
-/* need to make sure size is all the same during early stage */
-void * __meminit __vmemmap_alloc_block_buf(unsigned long size, int node,
-		struct vmem_altmap *altmap)
-{
-	if (altmap)
-		return altmap_alloc_block_buf(size, altmap);
-	return alloc_block_buf(size, node);
-}
-
 void __meminit vmemmap_verify(pte_t *pte, int node,
 				unsigned long start, unsigned long end)
 {
@@ -178,7 +169,7 @@ pte_t * __meminit vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node)
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte)) {
 		pte_t entry;
-		void *p = alloc_block_buf(PAGE_SIZE, node);
+		void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
 		entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
