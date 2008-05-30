Message-Id: <20080530194738.169332815@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:25 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 05/14] bootmem: revisit bitmap size calculations
Content-Disposition: inline; filename=bootmem-revisit-bitmap-size-calculation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Reincarnate get_mapsize as bootmap_bytes and implement
bootmem_bootmap_pages on top of it.

Adjust users of these helpers and make free_all_bootmem_core use
bootmem_bootmap_pages instead of open-coding it.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

 mm/bootmem.c |   27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -50,17 +50,11 @@ early_param("bootmem_debug", bootmem_deb
 			__FUNCTION__, ## args);		\
 })
 
-/*
- * Given an initialised bdata, it returns the size of the boot bitmap
- */
-static unsigned long __init get_mapsize(bootmem_data_t *bdata)
+static unsigned long __init bootmap_bytes(unsigned long pages)
 {
-	unsigned long mapsize;
-	unsigned long start = PFN_DOWN(bdata->node_boot_start);
-	unsigned long end = bdata->node_low_pfn;
+	unsigned long bytes = (pages + 7) / 8;
 
-	mapsize = ((end - start) + 7) / 8;
-	return ALIGN(mapsize, sizeof(long));
+	return ALIGN(bytes, sizeof(long));
 }
 
 /**
@@ -69,13 +63,9 @@ static unsigned long __init get_mapsize(
  */
 unsigned long __init bootmem_bootmap_pages(unsigned long pages)
 {
-	unsigned long mapsize;
-
-	mapsize = (pages+7)/8;
-	mapsize = (mapsize + ~PAGE_MASK) & PAGE_MASK;
-	mapsize >>= PAGE_SHIFT;
+	unsigned long bytes = bootmap_bytes(pages);
 
-	return mapsize;
+	return PAGE_ALIGN(bytes) >> PAGE_SHIFT;
 }
 
 /*
@@ -117,7 +107,7 @@ static unsigned long __init init_bootmem
 	 * Initially all pages are reserved - setup_arch() has to
 	 * register free RAM areas explicitly.
 	 */
-	mapsize = get_mapsize(bdata);
+	mapsize = bootmap_bytes(end - start);
 	memset(bdata->node_bootmem_map, 0xff, mapsize);
 
 	bdebug("nid=%d start=%lx map=%lx end=%lx mapsize=%ld\n",
@@ -160,7 +150,7 @@ static unsigned long __init free_all_boo
 	struct page *page;
 	unsigned long pfn;
 	unsigned long i, count;
-	unsigned long idx;
+	unsigned long idx, pages;
 	unsigned long *map;
 	int gofast = 0;
 
@@ -211,7 +201,8 @@ static unsigned long __init free_all_boo
 	 * needed anymore:
 	 */
 	page = virt_to_page(bdata->node_bootmem_map);
-	idx = (get_mapsize(bdata) + PAGE_SIZE-1) >> PAGE_SHIFT;
+	pages = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
+	idx = bootmem_bootmap_pages(pages);
 	for (i = 0; i < idx; i++, page++)
 		__free_pages_bootmem(page, 0);
 	count += i;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
