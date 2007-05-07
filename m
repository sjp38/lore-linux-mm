Message-Id: <20070507212408.708592453@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:46 -0700
From: clameter@sgi.com
Subject: [patch 06/17] SLUB: Use check_valid_pointer in kmem_ptr_validate
Content-Disposition: inline; filename=use_check_valid_pointer_in_kmem_ptr_validate
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We needlessly duplicate code. Also make check_valid_pointer inline.

Signed-off-by: Christoph LAemter <clameter@sgi.com>

---
 mm/slub.c |   13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:52:44.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:52:47.000000000 -0700
@@ -407,9 +407,8 @@ static int check_bytes(u8 *start, unsign
 	return 1;
 }
 
-
-static int check_valid_pointer(struct kmem_cache *s, struct page *page,
-					 void *object)
+static inline int check_valid_pointer(struct kmem_cache *s,
+				struct page *page, const void *object)
 {
 	void *base;
 
@@ -1803,13 +1802,7 @@ int kmem_ptr_validate(struct kmem_cache 
 		/* No slab or wrong slab */
 		return 0;
 
-	addr = page_address(page);
-	if (object < addr || object >= addr + s->objects * s->size)
-		/* Out of bounds */
-		return 0;
-
-	if ((object - addr) % s->size)
-		/* Improperly aligned */
+	if (!check_valid_pointer(s, page, object))
 		return 0;
 
 	/*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
