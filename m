Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 965949000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 17:03:02 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 10/10] mm: memcg: remove unused node/section info from pc->flags
Date: Thu, 29 Sep 2011 23:01:04 +0200
Message-Id: <1317330064-28893-11-git-send-email-jweiner@redhat.com>
In-Reply-To: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To find the page corresponding to a certain page_cgroup, the pc->flags
encoded the node or section ID with the base array to compare the pc
pointer to.

Now that the per-memory cgroup LRU lists link page descriptors
directly, there is no longer any code that knows the struct
page_cgroup of a PFN but not the struct page.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/page_cgroup.h |   33 ------------------------
 mm/page_cgroup.c            |   58 ++++++-------------------------------------
 2 files changed, 8 insertions(+), 83 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 5bae753..aaa60da 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -121,39 +121,6 @@ static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
 	local_irq_restore(*flags);
 }
 
-#ifdef CONFIG_SPARSEMEM
-#define PCG_ARRAYID_WIDTH	SECTIONS_SHIFT
-#else
-#define PCG_ARRAYID_WIDTH	NODES_SHIFT
-#endif
-
-#if (PCG_ARRAYID_WIDTH > BITS_PER_LONG - NR_PCG_FLAGS)
-#error Not enough space left in pc->flags to store page_cgroup array IDs
-#endif
-
-/* pc->flags: ARRAY-ID | FLAGS */
-
-#define PCG_ARRAYID_MASK	((1UL << PCG_ARRAYID_WIDTH) - 1)
-
-#define PCG_ARRAYID_OFFSET	(BITS_PER_LONG - PCG_ARRAYID_WIDTH)
-/*
- * Zero the shift count for non-existent fields, to prevent compiler
- * warnings and ensure references are optimized away.
- */
-#define PCG_ARRAYID_SHIFT	(PCG_ARRAYID_OFFSET * (PCG_ARRAYID_WIDTH != 0))
-
-static inline void set_page_cgroup_array_id(struct page_cgroup *pc,
-					    unsigned long id)
-{
-	pc->flags &= ~(PCG_ARRAYID_MASK << PCG_ARRAYID_SHIFT);
-	pc->flags |= (id & PCG_ARRAYID_MASK) << PCG_ARRAYID_SHIFT;
-}
-
-static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)
-{
-	return (pc->flags >> PCG_ARRAYID_SHIFT) & PCG_ARRAYID_MASK;
-}
-
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 256dee8..2601a65 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -11,12 +11,6 @@
 #include <linux/swapops.h>
 #include <linux/kmemleak.h>
 
-static void __meminit init_page_cgroup(struct page_cgroup *pc, unsigned long id)
-{
-	pc->flags = 0;
-	set_page_cgroup_array_id(pc, id);
-	pc->mem_cgroup = NULL;
-}
 static unsigned long total_usage;
 
 #if !defined(CONFIG_SPARSEMEM)
@@ -41,24 +35,11 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return base + offset;
 }
 
-struct page *lookup_cgroup_page(struct page_cgroup *pc)
-{
-	unsigned long pfn;
-	struct page *page;
-	pg_data_t *pgdat;
-
-	pgdat = NODE_DATA(page_cgroup_array_id(pc));
-	pfn = pc - pgdat->node_page_cgroup + pgdat->node_start_pfn;
-	page = pfn_to_page(pfn);
-	VM_BUG_ON(pc != lookup_page_cgroup(page));
-	return page;
-}
-
 static int __init alloc_node_page_cgroup(int nid)
 {
-	struct page_cgroup *base, *pc;
+	struct page_cgroup *base;
 	unsigned long table_size;
-	unsigned long start_pfn, nr_pages, index;
+	unsigned long nr_pages;
 
 	start_pfn = NODE_DATA(nid)->node_start_pfn;
 	nr_pages = NODE_DATA(nid)->node_spanned_pages;
@@ -72,10 +53,6 @@ static int __init alloc_node_page_cgroup(int nid)
 			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 	if (!base)
 		return -ENOMEM;
-	for (index = 0; index < nr_pages; index++) {
-		pc = base + index;
-		init_page_cgroup(pc, nid);
-	}
 	NODE_DATA(nid)->node_page_cgroup = base;
 	total_usage += table_size;
 	return 0;
@@ -116,31 +93,19 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return section->page_cgroup + pfn;
 }
 
-struct page *lookup_cgroup_page(struct page_cgroup *pc)
-{
-	struct mem_section *section;
-	struct page *page;
-	unsigned long nr;
-
-	nr = page_cgroup_array_id(pc);
-	section = __nr_to_section(nr);
-	page = pfn_to_page(pc - section->page_cgroup);
-	VM_BUG_ON(pc != lookup_page_cgroup(page));
-	return page;
-}
-
 static void *__meminit alloc_page_cgroup(size_t size, int nid)
 {
 	void *addr = NULL;
 
-	addr = alloc_pages_exact_nid(nid, size, GFP_KERNEL | __GFP_NOWARN);
+	addr = alloc_pages_exact_nid(nid, size,
+				     GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN);
 	if (addr)
 		return addr;
 
 	if (node_state(nid, N_HIGH_MEMORY))
-		addr = vmalloc_node(size, nid);
+		addr = vzalloc_node(size, nid);
 	else
-		addr = vmalloc(size);
+		addr = vzalloc(size);
 
 	return addr;
 }
@@ -163,14 +128,11 @@ static void free_page_cgroup(void *addr)
 
 static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 {
-	struct page_cgroup *base, *pc;
 	struct mem_section *section;
+	struct page_cgroup *base;
 	unsigned long table_size;
-	unsigned long nr;
-	int index;
 
-	nr = pfn_to_section_nr(pfn);
-	section = __nr_to_section(nr);
+	section = __pfn_to_section(pfn);
 
 	if (section->page_cgroup)
 		return 0;
@@ -190,10 +152,6 @@ static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 		return -ENOMEM;
 	}
 
-	for (index = 0; index < PAGES_PER_SECTION; index++) {
-		pc = base + index;
-		init_page_cgroup(pc, nr);
-	}
 	/*
 	 * The passed "pfn" may not be aligned to SECTION.  For the calculation
 	 * we need to apply a mask.
-- 
1.7.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
