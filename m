Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7B286B026C
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:55:02 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x10so16493624pgx.12
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:55:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c1si28090983pfd.416.2017.12.28.23.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:55:01 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/17] mm: split altmap memory map allocation from normal case
Date: Fri, 29 Dec 2017 08:53:58 +0100
Message-Id: <20171229075406.1936-10-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

No functional changes, just untangling the call chain and document
why the altmap is passed around the hotplug code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/mm/init_64.c |  5 ++++-
 arch/x86/mm/init_64.c     |  5 ++++-
 include/linux/mm.h        |  9 ++-------
 mm/sparse-vmemmap.c       | 15 +++------------
 4 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index db7d4e092157..7a2251d99ed3 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -200,7 +200,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		if (vmemmap_populated(start, page_size))
 			continue;
 
-		p =  __vmemmap_alloc_block_buf(page_size, node, altmap);
+		if (altmap)
+			p = altmap_alloc_block_buf(page_size, altmap);
+		else
+			p = vmemmap_alloc_block_buf(page_size, node);
 		if (!p)
 			return -ENOMEM;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 0cab4b5b59ba..1ab42c852069 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1385,7 +1385,10 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 		if (pmd_none(*pmd)) {
 			void *p;
 
-			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
+			if (altmap)
+				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
+			else
+				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (p) {
 				pte_t entry;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fd01135324b6..09637c353de0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2547,13 +2547,8 @@ pmd_t *vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node);
 pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
 struct vmem_altmap;
-void *__vmemmap_alloc_block_buf(unsigned long size, int node,
-		struct vmem_altmap *altmap);
-static inline void *vmemmap_alloc_block_buf(unsigned long size, int node)
-{
-	return __vmemmap_alloc_block_buf(size, node, NULL);
-}
-
+void *vmemmap_alloc_block_buf(unsigned long size, int node);
+void *altmap_alloc_block_buf(unsigned long size, struct vmem_altmap *altmap);
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
 int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 			       int node);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 376dcf05a39c..d012c9e2811b 100644
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
+void * __meminit altmap_alloc_block_buf(unsigned long size,
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
