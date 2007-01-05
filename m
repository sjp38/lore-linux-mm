Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l05Et43l130640
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 14:55:04 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l05Et4S13014784
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 15:55:04 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l05Et4VT009647
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 15:55:04 +0100
Date: Fri, 5 Jan 2007 15:55:01 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [patch] fix memmap accounting
Message-ID: <20070105145501.GA9602@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Using some rather large holes in memory gives me an error.
Present memory areas are 0-1GB and 1023GB-1023.5GB (1.5GB in total)

Kernel output on s390 with vmemmap is this:

Entering add_active_range(0, 0, 262143) 0 entries of 256 used
Entering add_active_range(0, 268173312, 268304383) 1 entries of 256 used
Detected 4 CPU's
Boot cpu address  0
Zone PFN ranges:
  DMA             0 ->   524288
  Normal     524288 -> 268304384
early_node_map[2] active PFN ranges
    0:        0 ->   262143
    0: 268173312 -> 268304383
On node 0 totalpages: 393214
  DMA zone: 9216 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 252927 pages, LIFO batch:31

  Normal zone: 4707071 pages exceeds realsize 131071  <------

  Normal zone: 131071 pages, LIFO batch:31
Built 1 zonelists.  Total pages: 383998  

So the calculation of the number of pages needed for the memmap is wrong.
It just doesn't work with virtual memmaps since it expects that all pages
of a memmap are actually backed with physical pages which is not the case
here.

This patch fixes it, but I guess something similar is also needed for
SPARSEMEM and ia64 (with vmemmap).

Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/Kconfig |    3 +++
 mm/page_alloc.c   |    4 ++++
 2 files changed, 7 insertions(+)

Index: linux-2.6/arch/s390/Kconfig
===================================================================
--- linux-2.6.orig/arch/s390/Kconfig
+++ linux-2.6/arch/s390/Kconfig
@@ -30,6 +30,9 @@ config ARCH_HAS_ILOG2_U64
 	bool
 	default n
 
+config ARCH_HAS_VMEMMAP
+	def_bool y
+
 config GENERIC_HWEIGHT
 	bool
 	default y
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -2629,7 +2629,11 @@ static void __meminit free_area_init_cor
 		 * is used by this zone for memmap. This affects the watermark
 		 * and per-cpu initialisations
 		 */
+#ifdef CONFIG_ARCH_HAS_VMEMMAP
+		memmap_pages = (realsize * sizeof(struct page)) >> PAGE_SHIFT;
+#else
 		memmap_pages = (size * sizeof(struct page)) >> PAGE_SHIFT;
+#endif
 		if (realsize >= memmap_pages) {
 			realsize -= memmap_pages;
 			printk(KERN_DEBUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
