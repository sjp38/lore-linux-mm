Message-Id: <20070427202900.850200197@sgi.com>
References: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:43 -0700
From: clameter@sgi.com
Subject: [patch 6/8] SLUB printk cleanup: Diagnostic functions
Content-Disposition: inline; filename=slub_printk_diag
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make printk output of the diagnostic functions consistent and use the new
slab_err function as much as possible to consolidate code.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   73 +++++++++++++++++++++++++-------------------------------------
 1 file changed, 30 insertions(+), 43 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-27 10:34:12.000000000 -0700
+++ slub/mm/slub.c	2007-04-27 10:36:34.000000000 -0700
@@ -457,7 +457,7 @@ static int check_valid_pointer(struct km
 static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
 						void *from, void *to)
 {
-	printk(KERN_ERR "@@@ SLUB: %s Restoring %s (0x%x) from 0x%p-0x%p\n",
+	printk(KERN_ERR "@@@ SLUB %s: Restoring %s (0x%x) from 0x%p-0x%p\n",
 		s->name, message, data, from, to - 1);
 	memset(from, data, to - from);
 }
@@ -504,9 +504,7 @@ static int slab_pad_check(struct kmem_ca
 		return 1;
 
 	if (!check_bytes(p + length, POISON_INUSE, remainder)) {
-		printk(KERN_ERR "SLUB: %s slab 0x%p: Padding fails check\n",
-			s->name, p);
-		dump_stack();
+		slab_err(s, page, "Padding check failed");
 		restore_bytes(s, "slab padding", POISON_INUSE, p + length,
 			p + length + remainder);
 		return 0;
@@ -592,30 +590,25 @@ static int check_slab(struct kmem_cache 
 	VM_BUG_ON(!irqs_disabled());
 
 	if (!PageSlab(page)) {
-		printk(KERN_ERR "SLUB: %s Not a valid slab page @0x%p "
-			"flags=%lx mapping=0x%p count=%d \n",
-			s->name, page, page->flags, page->mapping,
+		slab_err(s, page, "Not a valid slab page flags=%lx "
+			"mapping=0x%p count=%d", page->flags, page->mapping,
 			page_count(page));
 		return 0;
 	}
 	if (page->offset * sizeof(void *) != s->offset) {
-		printk(KERN_ERR "SLUB: %s Corrupted offset %lu in slab @0x%p"
-			" flags=0x%lx mapping=0x%p count=%d\n",
-			s->name,
+		slab_err(s, page, "Corrupted offset %lu flags=0x%lx "
+			"mapping=0x%p count=%d",
 			(unsigned long)(page->offset * sizeof(void *)),
-			page,
 			page->flags,
 			page->mapping,
 			page_count(page));
-		dump_stack();
 		return 0;
 	}
 	if (page->inuse > s->objects) {
-		printk(KERN_ERR "SLUB: %s inuse %u > max %u in slab "
-			"page @0x%p flags=%lx mapping=0x%p count=%d\n",
-			s->name, page->inuse, s->objects, page, page->flags,
+		slab_err(s, page, "inuse %u > max %u @0x%p flags=%lx "
+			"mapping=0x%p count=%d",
+			s->name, page->inuse, s->objects, page->flags,
 			page->mapping, page_count(page));
-		dump_stack();
 		return 0;
 	}
 	/* Slab_pad_check fixes things up after itself */
@@ -644,12 +637,13 @@ static int on_freelist(struct kmem_cache
 				set_freepointer(s, object, NULL);
 				break;
 			} else {
-				printk(KERN_ERR "SLUB: %s slab 0x%p "
-					"freepointer 0x%p corrupted.\n",
-					s->name, page, fp);
-				dump_stack();
+				slab_err(s, page, "Freepointer 0x%p corrupt",
+									fp);
 				page->freelist = NULL;
 				page->inuse = s->objects;
+				printk(KERN_ERR "@@@ SLUB %s: Freelist "
+					"cleared. Slab 0x%p\n",
+					s->name, page);
 				return 0;
 			}
 			break;
@@ -660,11 +654,12 @@ static int on_freelist(struct kmem_cache
 	}
 
 	if (page->inuse != s->objects - nr) {
-		printk(KERN_ERR "slab %s: page 0x%p wrong object count."
-			" counter is %d but counted were %d\n",
-			s->name, page, page->inuse,
-			s->objects - nr);
+		slab_err(s, page, "Wrong object count. Counter is %d but "
+			"counted were %d", s, page, page->inuse,
+							s->objects - nr);
 		page->inuse = s->objects - nr;
+		printk(KERN_ERR "@@@ SLUB %s: Object count adjusted. "
+			"Slab @0x%p\n", s->name, page);
 	}
 	return search == NULL;
 }
@@ -700,10 +695,7 @@ static int alloc_object_checks(struct km
 		goto bad;
 
 	if (object && !on_freelist(s, page, object)) {
-		printk(KERN_ERR "SLUB: %s Object 0x%p@0x%p "
-			"already allocated.\n",
-			s->name, object, page);
-		dump_stack();
+		slab_err(s, page, "Object 0x%p already allocated", object);
 		goto bad;
 	}
 
@@ -743,15 +735,12 @@ static int free_object_checks(struct kme
 		goto fail;
 
 	if (!check_valid_pointer(s, page, object)) {
-		printk(KERN_ERR "SLUB: %s slab 0x%p invalid "
-			"object pointer 0x%p\n",
-			s->name, page, object);
+		slab_err(s, page, "Invalid object pointer 0x%p", object);
 		goto fail;
 	}
 
 	if (on_freelist(s, page, object)) {
-		printk(KERN_ERR "SLUB: %s slab 0x%p object "
-			"0x%p already free.\n", s->name, page, object);
+		slab_err(s, page, "Object 0x%p already free", object);
 		goto fail;
 	}
 
@@ -760,24 +749,22 @@ static int free_object_checks(struct kme
 
 	if (unlikely(s != page->slab)) {
 		if (!PageSlab(page))
-			printk(KERN_ERR "slab_free %s size %d: attempt to"
-				"free object(0x%p) outside of slab.\n",
-				s->name, s->size, object);
+			slab_err(s, page, "Attempt to free object(0x%p) "
+				"outside of slab", object);
 		else
-		if (!page->slab)
+		if (!page->slab) {
 			printk(KERN_ERR
-				"slab_free : no slab(NULL) for object 0x%p.\n",
+				"SLUB <none>: no slab for object 0x%p.\n",
 						object);
+			dump_stack();
+		}
 		else
-			printk(KERN_ERR "slab_free %s(%d): object at 0x%p"
-				" belongs to slab %s(%d)\n",
-				s->name, s->size, object,
-				page->slab->name, page->slab->size);
+			slab_err(s, page, "object at 0x%p belongs "
+				"to slab %s", object, page->slab->name);
 		goto fail;
 	}
 	return 1;
 fail:
-	dump_stack();
 	printk(KERN_ERR "@@@ SLUB: %s slab 0x%p object at 0x%p not freed.\n",
 		s->name, page, object);
 	return 0;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
