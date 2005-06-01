Date: Wed, 1 Jun 2005 10:23:12 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH 3/4] VM: add __GFP_NORECLAIM
Message-ID: <20050601142312.GV14894@localhost>
References: <20050601141154.GN14894@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050601141154.GN14894@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Ray Bryant <raybry@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

When using the early zone reclaim, it was noticed that allocating new
pages that should be spread across the whole system caused eviction
of local pages.

This adds a new GFP flag to prevent early reclaim from happening during
certain allocation attempts.  The example that is implemented here is
for page cache pages.  We want page cache pages to be spread across the
whole system, and we don't want page cache pages to evict other pages
to get local memory.

Signed-off-by:  Martin Hicks <mort@sgi.com>

 include/linux/gfp.h     |    3 ++-
 include/linux/pagemap.h |    4 ++--
 mm/page_alloc.c         |    2 ++
 3 files changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6.12-rc5-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.12-rc5-mm1.orig/include/linux/gfp.h	2005-05-26 12:26:57.000000000 -0700
+++ linux-2.6.12-rc5-mm1/include/linux/gfp.h	2005-05-26 12:27:15.000000000 -0700
@@ -39,6 +39,7 @@ struct vm_area_struct;
 #define __GFP_COMP	0x4000u	/* Add compound page metadata */
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
+#define __GFP_NORECLAIM  0x20000u /* No realy zone reclaim during allocation */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
@@ -47,7 +48,7 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC)
+			__GFP_NOMEMALLOC|__GFP_NORECLAIM)
 
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
Index: linux-2.6.12-rc5-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.12-rc5-mm1.orig/include/linux/pagemap.h	2005-05-26 12:26:57.000000000 -0700
+++ linux-2.6.12-rc5-mm1/include/linux/pagemap.h	2005-05-26 12:27:15.000000000 -0700
@@ -52,12 +52,12 @@ void release_pages(struct page **pages, 
 
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
-	return alloc_pages(mapping_gfp_mask(x), 0);
+	return alloc_pages(mapping_gfp_mask(x)|__GFP_NORECLAIM, 0);
 }
 
 static inline struct page *page_cache_alloc_cold(struct address_space *x)
 {
-	return alloc_pages(mapping_gfp_mask(x)|__GFP_COLD, 0);
+	return alloc_pages(mapping_gfp_mask(x)|__GFP_COLD|__GFP_NORECLAIM, 0);
 }
 
 typedef int filler_t(void *, struct page *);
Index: linux-2.6.12-rc5-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc5-mm1.orig/mm/page_alloc.c	2005-05-26 12:27:11.000000000 -0700
+++ linux-2.6.12-rc5-mm1/mm/page_alloc.c	2005-05-26 12:27:15.000000000 -0700
@@ -729,6 +729,8 @@ check_zone_reclaim(struct zone *z, unsig
 {
 	if (!z->reclaim_pages)
 		return 0;
+	if (gfp_mask & __GFP_NORECLAIM)
+		return 0;
 	return 1;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
