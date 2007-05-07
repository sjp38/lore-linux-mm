Message-Id: <20070507212408.951409595@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:47 -0700
From: clameter@sgi.com
Subject: [patch 07/17] SLUB: Clean up krealloc
Content-Disposition: inline; filename=better_krealloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We really do not need all this gaga there.

ksize gives us all the information we need to figure out
if the object can cope with the new size.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:52:47.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:52:51.000000000 -0700
@@ -2206,9 +2206,8 @@ EXPORT_SYMBOL(kmem_cache_shrink);
  */
 void *krealloc(const void *p, size_t new_size, gfp_t flags)
 {
-	struct kmem_cache *new_cache;
 	void *ret;
-	struct page *page;
+	unsigned long ks;
 
 	if (unlikely(!p))
 		return kmalloc(new_size, flags);
@@ -2218,19 +2217,13 @@ void *krealloc(const void *p, size_t new
 		return NULL;
 	}
 
-	page = virt_to_head_page(p);
-
-	new_cache = get_slab(new_size, flags);
-
-	/*
- 	 * If new size fits in the current cache, bail out.
- 	 */
-	if (likely(page->slab == new_cache))
+	ks = ksize(p);
+	if (ks >= new_size)
 		return (void *)p;
 
 	ret = kmalloc(new_size, flags);
 	if (ret) {
-		memcpy(ret, p, min(new_size, ksize(p)));
+		memcpy(ret, p, min(new_size, ks));
 		kfree(p);
 	}
 	return ret;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
