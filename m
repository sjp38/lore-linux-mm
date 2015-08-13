Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 775056B0253
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 05:00:35 -0400 (EDT)
Received: by wijp15 with SMTP id p15so249658335wij.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:00:34 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id q8si2815407wiz.6.2015.08.13.02.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 02:00:33 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so250272245wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:00:33 -0700 (PDT)
From: mhocko@kernel.org
Subject: [PATCH] mm: make page pfmemalloc check more robust
Date: Thu, 13 Aug 2015 10:58:54 +0200
Message-Id: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

The patch c48a11c7ad26 ("netvm: propagate page->pfmemalloc to skb")
added the checks for page->pfmemalloc to __skb_fill_page_desc():

        if (page->pfmemalloc && !page->mapping)
                skb->pfmemalloc = true;

It assumes page->mapping == NULL implies that page->pfmemalloc can be
trusted.  However, __delete_from_page_cache() can set set page->mapping
to NULL and leave page->index value alone. Due to being in union, a
non-zero page->index will be interpreted as true page->pfmemalloc.

So the assumption is invalid if the networking code can see such a
page. And it seems it can. We have encountered this with a NFS over
loopback setup when such a page is attached to a new skbuf. There is no
copying going on in this case so the page confuses __skb_fill_page_desc
which interprets the index as pfmemalloc flag and the network stack
drops packets that have been allocated using the reserves unless they
are to be queued on sockets handling the swapping which is the case here
and that leads to hangs when the nfs client waits for a response from
the server which has been dropped and thus never arrive.

The struct page is already heavily packed so rather than finding
another hole to put it in, let's do a trick instead. We can reuse the
index again but define it to an impossible value (-1UL). This is the
page index so it should never see the value that large. Replace all
direct users of page->pfmemalloc by page_is_pfmemalloc which will
hide this nastiness from unspoiled eyes.

The information will get lost if somebody wants to use page->index
obviously but that was the case before and the original code expected
that the information should be persisted somewhere else if that is
really needed (e.g. what SLAB and SLUB do).

Fixes: c48a11c7ad26 ("netvm: propagate page->pfmemalloc to skb")
Cc: stable # 3.6+
Debugged-by: Vlastimil Babka <vbabka@suse.com>
Debugged-by: Jiri Bohac <jbohac@suse.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 include/linux/mm.h                                | 28 +++++++++++++++++++++++
 include/linux/mm_types.h                          |  9 --------
 include/linux/skbuff.h                            | 14 ++++--------
 mm/page_alloc.c                                   |  9 +++++---
 mm/slab.c                                         |  4 ++--
 mm/slub.c                                         |  2 +-
 net/core/skbuff.c                                 |  2 +-
 11 files changed, 47 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 982fdcdc795b..b5b2925103ec 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -216,7 +216,7 @@ static void fm10k_reuse_rx_page(struct fm10k_ring *rx_ring,
 
 static inline bool fm10k_page_is_reserved(struct page *page)
 {
-	return (page_to_nid(page) != numa_mem_id()) || page->pfmemalloc;
+	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
 }
 
 static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2f70a9b152bd..830466c49987 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6566,7 +6566,7 @@ static void igb_reuse_rx_page(struct igb_ring *rx_ring,
 
 static inline bool igb_page_is_reserved(struct page *page)
 {
-	return (page_to_nid(page) != numa_mem_id()) || page->pfmemalloc;
+	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
 }
 
 static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9aa6104e34ea..ae21e0b06c3a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1832,7 +1832,7 @@ static void ixgbe_reuse_rx_page(struct ixgbe_ring *rx_ring,
 
 static inline bool ixgbe_page_is_reserved(struct page *page)
 {
-	return (page_to_nid(page) != numa_mem_id()) || page->pfmemalloc;
+	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index e71cdde9cb01..1d7b00b038a2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -765,7 +765,7 @@ static void ixgbevf_reuse_rx_page(struct ixgbevf_ring *rx_ring,
 
 static inline bool ixgbevf_page_is_reserved(struct page *page)
 {
-	return (page_to_nid(page) != numa_mem_id()) || page->pfmemalloc;
+	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
 }
 
 /**
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f92dbac..bf6f117fcf4d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1003,6 +1003,34 @@ static inline int page_mapped(struct page *page)
 }
 
 /*
+ * Return true only if the page has been allocated with
+ * ALLOC_NO_WATERMARKS and the low watermark was not
+ * met implying that the system is under some pressure.
+ */
+static inline bool page_is_pfmemalloc(struct page *page)
+{
+	/*
+	 * Page index cannot be this large so this must be
+	 * a pfmemalloc page.
+	 */
+	return page->index == -1UL;
+}
+
+/*
+ * Only to be called by the page allocator on a freshly allocated
+ * page.
+ */
+static inline void set_page_pfmemalloc(struct page *page)
+{
+	page->index = -1UL;
+}
+
+static inline void clear_page_pfmemalloc(struct page *page)
+{
+	page->index = 0;
+}
+
+/*
  * Different kinds of faults, as returned by handle_mm_fault().
  * Used to decide whether a process gets delivered SIGBUS or
  * just gets major/minor fault counters bumped up.
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0038ac7466fd..15549578d559 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -63,15 +63,6 @@ struct page {
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
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d6cdd6e87d53..6dcee34a476f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1602,20 +1602,16 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 	/*
-	 * Propagate page->pfmemalloc to the skb if we can. The problem is
-	 * that not all callers have unique ownership of the page. If
-	 * pfmemalloc is set, we check the mapping as a mapping implies
-	 * page->index is set (index and pfmemalloc share space).
-	 * If it's a valid mapping, we cannot use page->pfmemalloc but we
-	 * do not lose pfmemalloc information as the pages would not be
-	 * allocated using __GFP_MEMALLOC.
+	 * Propagate page pfmemalloc to the skb if we can. The problem is
+	 * that not all callers have unique ownership of the page but rely
+	 * on page_is_pfmemalloc doing the right thing(tm).
 	 */
 	frag->page.p		  = page;
 	frag->page_offset	  = off;
 	skb_frag_size_set(frag, size);
 
 	page = compound_head(page);
-	if (page->pfmemalloc && !page->mapping)
+	if (page_is_pfmemalloc(page))
 		skb->pfmemalloc	= true;
 }
 
@@ -2263,7 +2259,7 @@ static inline struct page *dev_alloc_page(void)
 static inline void skb_propagate_pfmemalloc(struct page *page,
 					     struct sk_buff *skb)
 {
-	if (page && page->pfmemalloc)
+	if (page_is_pfmemalloc(page))
 		skb->pfmemalloc = true;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index beda41710802..a0e65dc89784 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1343,12 +1343,15 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 	set_page_owner(page, order, gfp_flags);
 
 	/*
-	 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was necessary to
+	 * page is set pfmemalloc when ALLOC_NO_WATERMARKS was necessary to
 	 * allocate the page. The expectation is that the caller is taking
 	 * steps that will free more memory. The caller should avoid the page
 	 * being used for !PFMEMALLOC purposes.
 	 */
-	page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+	if (alloc_flags & ALLOC_NO_WATERMARKS)
+		set_page_pfmemalloc(page);
+	else
+		clear_page_pfmemalloc(page);
 
 	return 0;
 }
@@ -3345,7 +3348,7 @@ void *__alloc_page_frag(struct page_frag_cache *nc,
 		atomic_add(size - 1, &page->_count);
 
 		/* reset page count bias and offset to start of new frag */
-		nc->pfmemalloc = page->pfmemalloc;
+		nc->pfmemalloc = page_is_pfmemalloc(page);
 		nc->pagecnt_bias = size;
 		nc->offset = size;
 	}
diff --git a/mm/slab.c b/mm/slab.c
index 200e22412a16..bbd0b47dc6a9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1603,7 +1603,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	}
 
 	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
-	if (unlikely(page->pfmemalloc))
+	if (page_is_pfmemalloc(page))
 		pfmemalloc_active = true;
 
 	nr_pages = (1 << cachep->gfporder);
@@ -1614,7 +1614,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
 	__SetPageSlab(page);
-	if (page->pfmemalloc)
+	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
 	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
diff --git a/mm/slub.c b/mm/slub.c
index 816df0016555..0eacabff35ab 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1427,7 +1427,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab_cache = s;
 	__SetPageSlab(page);
-	if (page->pfmemalloc)
+	if (page_is_pfmemalloc)
 		SetPageSlabPfmemalloc(page);
 
 	start = page_address(page);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b6a19ca0f99e..6bb3d82c9bbe 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -340,7 +340,7 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 
 	if (skb && frag_size) {
 		skb->head_frag = 1;
-		if (virt_to_head_page(data)->pfmemalloc)
+		if (page_is_pfmemalloc(virt_to_head_page(data)))
 			skb->pfmemalloc = 1;
 	}
 	return skb;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
