Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15DCC6B026C
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:55:11 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n6so29909439pfg.19
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:55:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a3si16029680pgv.684.2017.12.28.23.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:55:09 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/17] mm: merge vmem_altmap_alloc into altmap_alloc_block_buf
Date: Fri, 29 Dec 2017 08:53:59 +0100
Message-Id: <20171229075406.1936-11-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is no clear separation between the two, so merge them.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/sparse-vmemmap.c | 45 ++++++++++++++++-----------------------------
 1 file changed, 16 insertions(+), 29 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index d012c9e2811b..bd0276d5f66b 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -107,33 +107,16 @@ static unsigned long __meminit vmem_altmap_nr_free(struct vmem_altmap *altmap)
 }
 
 /**
- * vmem_altmap_alloc - allocate pages from the vmem_altmap reservation
- * @altmap - reserved page pool for the allocation
- * @nr_pfns - size (in pages) of the allocation
+ * altmap_alloc_block_buf - allocate pages from the device page map
+ * @altmap:	device page map
+ * @size:	size (in bytes) of the allocation
  *
- * Allocations are aligned to the size of the request
+ * Allocations are aligned to the size of the request.
  */
-static unsigned long __meminit vmem_altmap_alloc(struct vmem_altmap *altmap,
-		unsigned long nr_pfns)
-{
-	unsigned long pfn = vmem_altmap_next_pfn(altmap);
-	unsigned long nr_align;
-
-	nr_align = 1UL << find_first_bit(&nr_pfns, BITS_PER_LONG);
-	nr_align = ALIGN(pfn, nr_align) - pfn;
-
-	if (nr_pfns + nr_align > vmem_altmap_nr_free(altmap))
-		return ULONG_MAX;
-	altmap->alloc += nr_pfns;
-	altmap->align += nr_align;
-	return pfn + nr_align;
-}
-
 void * __meminit altmap_alloc_block_buf(unsigned long size,
 		struct vmem_altmap *altmap)
 {
-	unsigned long pfn, nr_pfns;
-	void *ptr;
+	unsigned long pfn, nr_pfns, nr_align;
 
 	if (size & ~PAGE_MASK) {
 		pr_warn_once("%s: allocations must be multiple of PAGE_SIZE (%ld)\n",
@@ -141,16 +124,20 @@ void * __meminit altmap_alloc_block_buf(unsigned long size,
 		return NULL;
 	}
 
+	pfn = vmem_altmap_next_pfn(altmap);
 	nr_pfns = size >> PAGE_SHIFT;
-	pfn = vmem_altmap_alloc(altmap, nr_pfns);
-	if (pfn < ULONG_MAX)
-		ptr = __va(__pfn_to_phys(pfn));
-	else
-		ptr = NULL;
+	nr_align = 1UL << find_first_bit(&nr_pfns, BITS_PER_LONG);
+	nr_align = ALIGN(pfn, nr_align) - pfn;
+	if (nr_pfns + nr_align > vmem_altmap_nr_free(altmap))
+		return NULL;
+
+	altmap->alloc += nr_pfns;
+	altmap->align += nr_align;
+	pfn += nr_align;
+
 	pr_debug("%s: pfn: %#lx alloc: %ld align: %ld nr: %#lx\n",
 			__func__, pfn, altmap->alloc, altmap->align, nr_pfns);
-
-	return ptr;
+	return __va(__pfn_to_phys(pfn));
 }
 
 void __meminit vmemmap_verify(pte_t *pte, int node,
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
