Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I48Wth032261
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:08:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I48V6k305524
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I48VFY020891
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:31 -0600
Date: Mon, 17 Jul 2006 22:08:30 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040828.11926.51545.sendpatchset@kleikamp.austin.ibm.com>
In-Reply-To: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
References: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 003/008] Handle tail pages in kmap & kmap_atomic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Handle tail pages in kmap & kmap_atomic

TODO: possibly move to mm.h: lowmem_page_address()

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
---
diff -Nurp linux002/include/asm-powerpc/io.h linux003/include/asm-powerpc/io.h
--- linux002/include/asm-powerpc/io.h	2006-06-17 20:49:35.000000000 -0500
+++ linux003/include/asm-powerpc/io.h	2006-07-17 23:04:38.000000000 -0500
@@ -250,7 +250,9 @@ static inline void * phys_to_virt(unsign
 /*
  * Change "struct page" to physical address.
  */
-#define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
+#define page_to_phys(page)	(PageTail(page) ?			\
+				__pa((page)->mapping->tail) :		\
+				page_to_pfn(page) << PAGE_SHIFT)
 
 /* We do NOT want virtual merging, it would put too much pressure on
  * our iommu allocator. Instead, we want drivers to be smart enough
diff -Nurp linux002/include/linux/highmem.h linux003/include/linux/highmem.h
--- linux002/include/linux/highmem.h	2006-06-17 20:49:35.000000000 -0500
+++ linux003/include/linux/highmem.h	2006-07-17 23:04:38.000000000 -0500
@@ -33,12 +33,21 @@ static inline unsigned int nr_free_highp
 static inline void *kmap(struct page *page)
 {
 	might_sleep();
+#ifdef CONFIG_FILE_TAILS
+	return PageTail(page) ? page->mapping->tail : page_address(page);
+#else
 	return page_address(page);
+#endif
 }
 
 #define kunmap(page) do { (void) (page); } while (0)
 
+#ifdef CONFIG_FILE_TAILS
+#define kmap_atomic(page, idx) \
+       	(PageTail(page) ? (page)->mapping->tail : page_address(page))
+#else
 #define kmap_atomic(page, idx)		page_address(page)
+#endif
 #define kunmap_atomic(addr, idx)	do { } while (0)
 #define kmap_atomic_pfn(pfn, idx)	page_address(pfn_to_page(pfn))
 #define kmap_atomic_to_page(ptr)	virt_to_page(ptr)

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
