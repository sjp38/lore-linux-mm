Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id A01E26B0044
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 13:02:28 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so15890803pbb.22
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 10:02:28 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zq7si46507597pac.275.2014.01.03.10.02.26
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 10:02:26 -0800 (PST)
Subject: [PATCH 3/9] mm: page->pfmemalloc only used by slab/skb
From: Dave Hansen <dave@sr71.net>
Date: Fri, 03 Jan 2014 10:01:52 -0800
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
In-Reply-To: <20140103180147.6566F7C1@viggo.jf.intel.com>
Message-Id: <20140103180152.8DFF2A3C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

page->pfmemalloc does not deserve a spot in 'struct page'.  It is
only used transiently _just_ after a page leaves the buddy
allocator.

Instead of declaring a union, we move its functionality behind a
few quick accessor functions.  This way we could also much more
easily audit that it is being used correctly in debugging
scenarios.  For instance, we could store a magic number in there
which could never get reused as a page->index and check that the
magic number exists in page_pfmemalloc().

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/mm.h       |   17 +++++++++++++++++
 linux.git-davehans/include/linux/mm_types.h |    9 ---------
 linux.git-davehans/include/linux/skbuff.h   |   10 +++++-----
 linux.git-davehans/mm/page_alloc.c          |    2 +-
 linux.git-davehans/mm/slab.c                |    4 ++--
 linux.git-davehans/mm/slub.c                |    2 +-
 6 files changed, 26 insertions(+), 18 deletions(-)

diff -puN include/linux/mm.h~page_pfmemalloc-only-used-by-slab include/linux/mm.h
--- linux.git/include/linux/mm.h~page_pfmemalloc-only-used-by-slab	2014-01-02 13:40:29.673283120 -0800
+++ linux.git-davehans/include/linux/mm.h	2014-01-02 13:40:29.687283750 -0800
@@ -2011,5 +2011,22 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+/*
+ * If set by the page allocator, ALLOC_NO_WATERMARKS was set and the
+ * low watermark was not met implying that the system is under some
+ * pressure. The caller should try ensure this page is only used to
+ * free other pages.  Currently only used by sl[au]b.  Note that
+ * this is only valid for a short time after the page returns
+ * from the allocator.
+ */
+static inline int page_pfmemalloc(struct page *page)
+{
+	return !!page->index;
+}
+static inline void set_page_pfmemalloc(struct page *page, int pfmemalloc)
+{
+	page->index = pfmemalloc;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff -puN include/linux/mm_types.h~page_pfmemalloc-only-used-by-slab include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~page_pfmemalloc-only-used-by-slab	2014-01-02 13:40:29.675283210 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2014-01-02 13:40:29.688283795 -0800
@@ -61,15 +61,6 @@ struct page {
 		union {
 			pgoff_t index;		/* Our offset within mapping. */
 			void *freelist;		/* sl[aou]b first free object */
-			bool pfmemalloc;	/* If set by the page allocator,
-						 * ALLOC_NO_WATERMARKS was set
-						 * and the low watermark was not
-						 * met implying that the system
-						 * is under some pressure. The
-						 * caller should try ensure
-						 * this page is only used to
-						 * free other pages.
-						 */
 		};
 
 		union {
diff -puN include/linux/skbuff.h~page_pfmemalloc-only-used-by-slab include/linux/skbuff.h
--- linux.git/include/linux/skbuff.h~page_pfmemalloc-only-used-by-slab	2014-01-02 13:40:29.677283300 -0800
+++ linux.git-davehans/include/linux/skbuff.h	2014-01-02 13:40:29.690283885 -0800
@@ -1322,11 +1322,11 @@ static inline void __skb_fill_page_desc(
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 	/*
-	 * Propagate page->pfmemalloc to the skb if we can. The problem is
+	 * Propagate page_pfmemalloc() to the skb if we can. The problem is
 	 * that not all callers have unique ownership of the page. If
 	 * pfmemalloc is set, we check the mapping as a mapping implies
 	 * page->index is set (index and pfmemalloc share space).
-	 * If it's a valid mapping, we cannot use page->pfmemalloc but we
+	 * If it's a valid mapping, we cannot use page_pfmemalloc() but we
 	 * do not lose pfmemalloc information as the pages would not be
 	 * allocated using __GFP_MEMALLOC.
 	 */
@@ -1335,7 +1335,7 @@ static inline void __skb_fill_page_desc(
 	skb_frag_size_set(frag, size);
 
 	page = compound_head(page);
-	if (page->pfmemalloc && !page->mapping)
+	if (page_pfmemalloc(page) && !page->mapping)
 		skb->pfmemalloc	= true;
 }
 
@@ -1922,7 +1922,7 @@ static inline struct page *__skb_alloc_p
 		gfp_mask |= __GFP_MEMALLOC;
 
 	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
-	if (skb && page && page->pfmemalloc)
+	if (skb && page && page_pfmemalloc(page))
 		skb->pfmemalloc = true;
 
 	return page;
@@ -1951,7 +1951,7 @@ static inline struct page *__skb_alloc_p
 static inline void skb_propagate_pfmemalloc(struct page *page,
 					     struct sk_buff *skb)
 {
-	if (page && page->pfmemalloc)
+	if (page && page_pfmemalloc(page))
 		skb->pfmemalloc = true;
 }
 
diff -puN mm/page_alloc.c~page_pfmemalloc-only-used-by-slab mm/page_alloc.c
--- linux.git/mm/page_alloc.c~page_pfmemalloc-only-used-by-slab	2014-01-02 13:40:29.679283390 -0800
+++ linux.git-davehans/mm/page_alloc.c	2014-01-02 13:40:29.692283974 -0800
@@ -2040,7 +2040,7 @@ this_zone_full:
 		 * memory. The caller should avoid the page being used
 		 * for !PFMEMALLOC purposes.
 		 */
-		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+		set_page_pfmemalloc(page, alloc_flags & ALLOC_NO_WATERMARKS);
 
 	return page;
 }
diff -puN mm/slab.c~page_pfmemalloc-only-used-by-slab mm/slab.c
--- linux.git/mm/slab.c~page_pfmemalloc-only-used-by-slab	2014-01-02 13:40:29.681283480 -0800
+++ linux.git-davehans/mm/slab.c	2014-01-02 13:40:29.694284064 -0800
@@ -1672,7 +1672,7 @@ static struct page *kmem_getpages(struct
 	}
 
 	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
-	if (unlikely(page->pfmemalloc))
+	if (unlikely(page_pfmemalloc(page)))
 		pfmemalloc_active = true;
 
 	nr_pages = (1 << cachep->gfporder);
@@ -1683,7 +1683,7 @@ static struct page *kmem_getpages(struct
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
 	__SetPageSlab(page);
-	if (page->pfmemalloc)
+	if (page_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 	memcg_bind_pages(cachep, cachep->gfporder);
 
diff -puN mm/slub.c~page_pfmemalloc-only-used-by-slab mm/slub.c
--- linux.git/mm/slub.c~page_pfmemalloc-only-used-by-slab	2014-01-02 13:40:29.683283570 -0800
+++ linux.git-davehans/mm/slub.c	2014-01-02 13:40:29.696284154 -0800
@@ -1403,7 +1403,7 @@ static struct page *new_slab(struct kmem
 	memcg_bind_pages(s, order);
 	page->slab_cache = s;
 	__SetPageSlab(page);
-	if (page->pfmemalloc)
+	if (page_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
 	start = page_address(page);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
