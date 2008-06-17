Date: Tue, 17 Jun 2008 20:39:04 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch](memory hotplug) Tiny fixes of bootmem free patch for memory hotremove
In-Reply-To: <20080616204200.9E9F.E1E9C6FF@jp.fujitsu.com>
References: <20080616102131.GD17016@shadowen.org> <20080616204200.9E9F.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080617203343.C208.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

Here is tiny fixes of bootmem free patch for memory hotremove.

  - Change some naming
      * Magic -> types
      * MIX_INFO -> MIX_SECTION_INFO
      * Change definition of bootmem type from direct hex value
  - __free_pages_bootmem() becomes __meminit.

This is for 2.6.26-rc5-mm3.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


---
 include/linux/memory_hotplug.h |    8 ++++----
 mm/memory_hotplug.c            |   12 ++++++------
 mm/page_alloc.c                |    2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

Index: current/include/linux/memory_hotplug.h
===================================================================
--- current.orig/include/linux/memory_hotplug.h	2008-06-10 20:23:30.000000000 +0900
+++ current/include/linux/memory_hotplug.h	2008-06-17 20:30:14.000000000 +0900
@@ -13,12 +13,12 @@
 #ifdef CONFIG_MEMORY_HOTPLUG
 
 /*
- * Magic number for free bootmem.
+ * Types for free bootmem.
  * The normal smallest mapcount is -1. Here is smaller value than it.
  */
-#define SECTION_INFO		0xfffffffe
-#define MIX_INFO		0xfffffffd
-#define NODE_INFO		0xfffffffc
+#define SECTION_INFO		(-1 - 1)
+#define MIX_SECTION_INFO	(-1 - 2)
+#define NODE_INFO		(-1 - 3)
 
 /*
  * pgdat resizing functions
Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c	2008-06-17 15:34:29.000000000 +0900
+++ current/mm/memory_hotplug.c	2008-06-17 20:31:59.000000000 +0900
@@ -62,9 +62,9 @@
 
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
-static void get_page_bootmem(unsigned long info,  struct page *page, int magic)
+static void get_page_bootmem(unsigned long info,  struct page *page, int type)
 {
-	atomic_set(&page->_mapcount, magic);
+	atomic_set(&page->_mapcount, type);
 	SetPagePrivate(page);
 	set_page_private(page, info);
 	atomic_inc(&page->_count);
@@ -72,10 +72,10 @@
 
 void put_page_bootmem(struct page *page)
 {
-	int magic;
+	int type;
 
-	magic = atomic_read(&page->_mapcount);
-	BUG_ON(magic >= -1);
+	type = atomic_read(&page->_mapcount);
+	BUG_ON(type >= -1);
 
 	if (atomic_dec_return(&page->_count) == 1) {
 		ClearPagePrivate(page);
@@ -119,7 +119,7 @@
 	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
 
 	for (i = 0; i < mapsize; i++, page++)
-		get_page_bootmem(section_nr, page, MIX_INFO);
+		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
 
 }
 
Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c	2008-06-17 15:34:29.000000000 +0900
+++ current/mm/page_alloc.c	2008-06-17 20:08:47.000000000 +0900
@@ -583,7 +583,7 @@
 /*
  * permit the bootmem allocator to evade page validation on high-order frees
  */
-void __free_pages_bootmem(struct page *page, unsigned int order)
+void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 {
 	if (order == 0) {
 		__ClearPageReserved(page);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
