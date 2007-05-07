Message-Id: <20070507212410.385755131@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:53 -0700
From: clameter@sgi.com
Subject: [patch 13/17] SLUB: Consolidate trace code
Content-Disposition: inline; filename=slub_trace
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Trace in both slab_alloc and slab_free has a lot of common code. Use
a single function for both.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:56:25.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:57:04.000000000 -0700
@@ -807,6 +807,22 @@ fail:
 	return 0;
 }
 
+static void trace(struct kmem_cache *s, struct page *page, void *object, int alloc)
+{
+	if (s->flags & SLAB_TRACE) {
+		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
+			s->name,
+			alloc ? "alloc" : "free",
+			object, page->inuse,
+			page->freelist);
+
+		if (!alloc)
+			print_section("Object", (void *)object, s->objsize);
+
+		dump_stack();
+	}
+}
+
 /*
  * Slab allocation and freeing
  */
@@ -1291,12 +1307,7 @@ debug:
 		goto another_slab;
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_ALLOC, addr);
-	if (s->flags & SLAB_TRACE) {
-		printk(KERN_INFO "TRACE %s alloc 0x%p inuse=%d fp=0x%p\n",
-			s->name, object, page->inuse,
-			page->freelist);
-		dump_stack();
-	}
+	trace(s, page, object, 1);
 	init_object(s, object, 1);
 	goto have_object;
 }
@@ -1381,13 +1392,7 @@ debug:
 		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, x, TRACK_FREE, addr);
-	if (s->flags & SLAB_TRACE) {
-		printk(KERN_INFO "TRACE %s free 0x%p inuse=%d fp=0x%p\n",
-			s->name, object, page->inuse,
-			page->freelist);
-		print_section("Object", (void *)object, s->objsize);
-		dump_stack();
-	}
+	trace(s, page, object, 0);
 	init_object(s, object, 0);
 	goto checks_ok;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
