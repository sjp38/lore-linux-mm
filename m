Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAHLwQMW363992
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 16:58:26 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAHLwQOd284286
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 16:58:26 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAHLwQmX014294
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 16:58:26 -0500
Subject: [patch] make sure ioremap only tests valid addresses
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 17 Nov 2004 13:58:23 -0800
Message-Id: <E1CUXom-0008K5-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>


When CONFIG_HIGHMEM=y, but ZONE_NORMAL isn't quite full, there is, of course,
no actual memory at *high_memory.  This isn't a problem with normal
virt<->phys translations because it's never dereferenced, but CONFIG_NONLINEAR
is a bit more finicky.  So, don't do virt_to_phys() to non-existent addresses.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/ioremap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -puN arch/i386/mm/ioremap.c~A2-ioremap-valid-pfns arch/i386/mm/ioremap.c
--- memhotplug/arch/i386/mm/ioremap.c~A2-ioremap-valid-pfns	2004-11-17 13:23:28.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/ioremap.c	2004-11-17 13:23:37.000000000 -0800
@@ -130,7 +130,7 @@ void __iomem * __ioremap(unsigned long p
 	/*
 	 * Don't allow anybody to remap normal RAM that we're using..
 	 */
-	if (phys_addr < virt_to_phys(high_memory)) {
+	if (phys_addr <= virt_to_phys(high_memory-1)) {
 		char *t_addr, *t_end;
 		struct page *page;
 
@@ -197,7 +197,7 @@ void __iomem *ioremap_nocache (unsigned 
 	/* Guaranteed to be > phys_addr, as per __ioremap() */
 	last_addr = phys_addr + size - 1;
 
-	if (last_addr < virt_to_phys(high_memory)) { 
+	if (last_addr <= virt_to_phys(high_memory-1)) {
 		struct page *ppage = virt_to_page(__va(phys_addr));		
 		unsigned long npages;
 
@@ -232,7 +232,7 @@ void iounmap(volatile void __iomem *addr
 		return;
 	} 
 
-	if (p->flags && p->phys_addr < virt_to_phys(high_memory)) { 
+	if (p->flags && p->phys_addr <= virt_to_phys(high_memory-1)) {
 		change_page_attr(virt_to_page(__va(p->phys_addr)),
 				 p->size >> PAGE_SHIFT,
 				 PAGE_KERNEL); 				 
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
