From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070413013645.17093.60546.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
References: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 3/5] Remove object activities out of checking functions
Date: Thu, 12 Apr 2007 18:36:45 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Make sure that the check function really only check things and do not
perform activities. Extract the tracing and object seeding out
of the two check functions and place them into slab_alloc and slab_free

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-12 12:29:22.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-12 13:09:01.000000000 -0700
@@ -536,7 +536,7 @@ static int check_slab(struct kmem_cache 
 		return 0;
 	}
 	if (page->inuse > s->objects) {
-		printk(KERN_ERR "SLUB: %s Inuse %u > max %u in slab "
+		printk(KERN_ERR "SLUB: %s inuse %u > max %u in slab "
 			"page @0x%p flags=%lx mapping=0x%p count=%d\n",
 			s->name, page->inuse, s->objects, page, page->flags,
 			page->mapping, page_count(page));
@@ -635,12 +635,13 @@ static int alloc_object_checks(struct km
 		printk(KERN_ERR "SLUB: %s Object 0x%p@0x%p "
 			"already allocated.\n",
 			s->name, object, page);
-		goto dump;
+		dump_stack();
+		goto bad;
 	}
 
 	if (!check_valid_pointer(s, page, object)) {
 		object_err(s, page, object, "Freelist Pointer check fails");
-		goto dump;
+		goto bad;
 	}
 
 	if (!object)
@@ -648,17 +649,8 @@ static int alloc_object_checks(struct km
 
 	if (!check_object(s, page, object, 0))
 		goto bad;
-	init_object(s, object, 1);
 
-	if (s->flags & SLAB_TRACE) {
-		printk(KERN_INFO "TRACE %s alloc 0x%p inuse=%d fp=0x%p\n",
-			s->name, object, page->inuse,
-			page->freelist);
-		dump_stack();
-	}
 	return 1;
-dump:
-	dump_stack();
 bad:
 	/* Mark slab full */
 	page->inuse = s->objects;
@@ -699,20 +691,12 @@ static int free_object_checks(struct kme
 				"slab_free : no slab(NULL) for object 0x%p.\n",
 						object);
 		else
-		printk(KERN_ERR "slab_free %s(%d): object at 0x%p"
+			printk(KERN_ERR "slab_free %s(%d): object at 0x%p"
 				" belongs to slab %s(%d)\n",
 				s->name, s->size, object,
 				page->slab->name, page->slab->size);
 		goto fail;
 	}
-	if (s->flags & SLAB_TRACE) {
-		printk(KERN_INFO "TRACE %s free 0x%p inuse=%d fp=0x%p\n",
-			s->name, object, page->inuse,
-			page->freelist);
-		print_section("Object", object, s->objsize);
-		dump_stack();
-	}
-	init_object(s, object, 0);
 	return 1;
 fail:
 	dump_stack();
@@ -1241,6 +1225,13 @@ debug:
 		goto another_slab;
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_ALLOC, addr);
+	if (s->flags & SLAB_TRACE) {
+		printk(KERN_INFO "TRACE %s alloc 0x%p inuse=%d fp=0x%p\n",
+			s->name, object, page->inuse,
+			page->freelist);
+		dump_stack();
+	}
+	init_object(s, object, 1);
 	goto have_object;
 }
 
@@ -1323,6 +1314,14 @@ debug:
 		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, x, TRACK_FREE, addr);
+	if (s->flags & SLAB_TRACE) {
+		printk(KERN_INFO "TRACE %s free 0x%p inuse=%d fp=0x%p\n",
+			s->name, object, page->inuse,
+			page->freelist);
+		print_section("Object", (void *)object, s->objsize);
+		dump_stack();
+	}
+	init_object(s, object, 0);
 	goto checks_ok;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
