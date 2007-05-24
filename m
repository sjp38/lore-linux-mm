Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCD5uj016882
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:13:05 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCC3kQ523042
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:03 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCC3jp028720
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:12:03 -0400
Date: Thu, 24 May 2007 08:12:03 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070524121203.13533.30015.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 006/012] Modify lowmem_page_address() & page_to_phys() to special case tail page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Modify lowmem_page_address() & page_to_phys() to special case tail page

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/asm-powerpc/io.h |    8 +++++++-
 include/linux/mm.h       |    2 ++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff -Nurp linux005/include/asm-powerpc/io.h linux006/include/asm-powerpc/io.h
--- linux005/include/asm-powerpc/io.h	2007-05-21 15:15:41.000000000 -0500
+++ linux006/include/asm-powerpc/io.h	2007-05-23 22:53:11.000000000 -0500
@@ -19,6 +19,7 @@ extern int check_legacy_ioport(unsigned 
 #define PNPBIOS_BASE	0xf000
 
 #include <linux/compiler.h>
+#include <linux/mm.h>
 #include <asm/page.h>
 #include <asm/byteorder.h>
 #include <asm/synch.h>
@@ -702,7 +703,12 @@ static inline void * phys_to_virt(unsign
 /*
  * Change "struct page" to physical address.
  */
-#define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
+static inline unsigned long page_to_phys(struct page *page)
+{
+	if (unlikely(PageFileTail(page)))
+		return __pa(page->mapping->tail);
+	return page_to_pfn(page) << PAGE_SHIFT;
+}
 
 /* We do NOT want virtual merging, it would put too much pressure on
  * our iommu allocator. Instead, we want drivers to be smart enough
diff -Nurp linux005/include/linux/mm.h linux006/include/linux/mm.h
--- linux005/include/linux/mm.h	2007-05-21 15:15:44.000000000 -0500
+++ linux006/include/linux/mm.h	2007-05-23 22:53:11.000000000 -0500
@@ -557,6 +557,8 @@ static inline void set_page_links(struct
 
 static __always_inline void *lowmem_page_address(struct page *page)
 {
+	if (unlikely(PageFileTail(page)))
+	       return page->mapping->tail;
 	return __va(page_to_pfn(page) << PAGE_SHIFT);
 }
 

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
