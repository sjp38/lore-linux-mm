Date: Fri, 1 Jun 2007 13:25:15 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] sparsemem: Shut up unused symbol compiler warnings.
Message-ID: <20070601042515.GA8628@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

__kmalloc_section_memmap()/__kfree_section_memmap() and friends are only
used by the memory hotplug code. Move these in to the existing
CONFIG_MEMORY_HOTPLUG block.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/sparse.c |   42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 1302f83..35f739a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -229,6 +229,7 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 	return NULL;
 }
 
+#ifdef CONFIG_MEMORY_HOTPLUG
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
 	struct page *page, *ret;
@@ -269,27 +270,6 @@ static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 }
 
 /*
- * Allocate the accumulated non-linear sections, allocate a mem_map
- * for each and record the physical to section mapping.
- */
-void __init sparse_init(void)
-{
-	unsigned long pnum;
-	struct page *map;
-
-	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-		if (!valid_section_nr(pnum))
-			continue;
-
-		map = sparse_early_mem_map_alloc(pnum);
-		if (!map)
-			continue;
-		sparse_init_one_section(__nr_to_section(pnum), pnum, map);
-	}
-}
-
-#ifdef CONFIG_MEMORY_HOTPLUG
-/*
  * returns the number of sections whose mem_maps were properly
  * set.  If this is <=0, then that means that the passed-in
  * map was not consumed and must be freed.
@@ -329,3 +309,23 @@ out:
 	return ret;
 }
 #endif
+
+/*
+ * Allocate the accumulated non-linear sections, allocate a mem_map
+ * for each and record the physical to section mapping.
+ */
+void __init sparse_init(void)
+{
+	unsigned long pnum;
+	struct page *map;
+
+	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
+		if (!valid_section_nr(pnum))
+			continue;
+
+		map = sparse_early_mem_map_alloc(pnum);
+		if (!map)
+			continue;
+		sparse_init_one_section(__nr_to_section(pnum), pnum, map);
+	}
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
