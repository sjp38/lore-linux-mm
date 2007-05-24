Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCBc4h008446
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCBavP559484
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCBaOJ023935
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:11:36 -0400
Date: Thu, 24 May 2007 08:11:35 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121135.13533.11053.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 001/012] Make iommu_map_sg deal with less-than-page-aligned data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Make iommu_map_sg deal with less-than-page-aligned data

The code actually assumes that the page_address() is page aligned (or
at least IOMMU_PAGE-aligned).

Using vaddr is more accurate, and saves a pointer dereference as well.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 arch/powerpc/kernel/iommu.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -Nurp linux000/arch/powerpc/kernel/iommu.c linux001/arch/powerpc/kernel/iommu.c
--- linux000/arch/powerpc/kernel/iommu.c	2007-05-21 15:14:49.000000000 -0500
+++ linux001/arch/powerpc/kernel/iommu.c	2007-05-23 22:53:11.000000000 -0500
@@ -325,7 +325,7 @@ int iommu_map_sg(struct iommu_table *tbl
 		/* Convert entry to a dma_addr_t */
 		entry += tbl->it_offset;
 		dma_addr = entry << IOMMU_PAGE_SHIFT;
-		dma_addr |= (s->offset & ~IOMMU_PAGE_MASK);
+		dma_addr |= (vaddr & ~IOMMU_PAGE_MASK);
 
 		DBG("  - %lu pages, entry: %lx, dma_addr: %lx\n",
 			    npages, entry, dma_addr);

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
