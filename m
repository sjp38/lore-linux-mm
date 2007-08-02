From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/4] vmemmap: simplify initialisation code and reduce duplication
References: <exportbomb.1186045945@pinky>
Message-Id: <E1IGWvi-0002Xg-Pn@hellhawk.shadowen.org>
Date: Thu, 02 Aug 2007 10:25:14 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

The vmemmap and non-vmemmap implementations of
sparse_early_mem_map_alloc() share a fair amount of code.
Refactor this into a common wrapper, pulling the differences out
to sparse_early_mem_map_populate().  This reduces depandancies
between SPARSMEM and SPARSEMEM_VMEMMAP simplifying separation.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/sparse.c |   41 +++++++++++++++++++++--------------------
 1 files changed, 21 insertions(+), 20 deletions(-)
diff --git a/mm/sparse.c b/mm/sparse.c
index 76316d4..1905759 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -421,33 +421,23 @@ int __meminit vmemmap_populate(struct page *start_page,
 }
 #endif /* !CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP */
 
-static struct page * __init sparse_early_mem_map_alloc(unsigned long pnum)
+static struct page __init *sparse_early_mem_map_populate(unsigned long pnum,
+									int nid)
 {
-	struct page *map;
-	struct mem_section *ms = __nr_to_section(pnum);
-	int nid = sparse_early_nid(ms);
-	int error;
-
-	map = pfn_to_page(pnum * PAGES_PER_SECTION);
-	error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
-	if (error) {
-		printk(KERN_ERR "%s: allocation failed. Error=%d\n",
-							__FUNCTION__, error);
-		printk(KERN_ERR "%s: virtual memory map backing failed "
-			"some memory will not be available.\n", __FUNCTION__);
-		ms->section_mem_map = 0;
+	struct page *map = pfn_to_page(pnum * PAGES_PER_SECTION);
+	int error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
+	if (error)
 		return NULL;
-	}
+
 	return map;
 }
 
 #else /* CONFIG_SPARSEMEM_VMEMMAP */
 
-static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
+static struct page __init *sparse_early_mem_map_populate(unsigned long pnum,
+									int nid)
 {
 	struct page *map;
-	struct mem_section *ms = __nr_to_section(pnum);
-	int nid = sparse_early_nid(ms);
 
 	map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
 	if (map)
@@ -460,14 +450,25 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 
 	map = alloc_bootmem_node(NODE_DATA(nid),
 			sizeof(struct page) * PAGES_PER_SECTION);
+	return map;
+}
+#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
+
+struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
+{
+	struct page *map;
+	struct mem_section *ms = __nr_to_section(pnum);
+	int nid = sparse_early_nid(ms);
+
+	map = sparse_early_mem_map_populate(pnum, nid);
 	if (map)
 		return map;
 
-	printk(KERN_WARNING "%s: allocation failed\n", __FUNCTION__);
+	printk(KERN_ERR "%s: sparsemem memory map backing failed "
+			"some memory will not be available.\n", __FUNCTION__);
 	ms->section_mem_map = 0;
 	return NULL;
 }
-#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 /*
  * Allocate the accumulated non-linear sections, allocate a mem_map

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
