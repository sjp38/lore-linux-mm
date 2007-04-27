Message-Id: <20070427042907.998009077@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:26:58 -0700
From: clameter@sgi.com
Subject: [patch 03/10] SLUB: debug printk cleanup
Content-Disposition: inline; filename=slub_at_cleanup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Set up a new function slab_err in order to report errors consistently.

Consistently report corrective actions taken by SLUB by a printk starting
with @@@.

Fix locations where there is no 0x in front of %p.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm2/mm/slub.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-26 20:58:08.000000000 -0700
+++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-26 20:58:23.000000000 -0700
@@ -324,8 +324,8 @@ static void object_err(struct kmem_cache
 {
 	u8 *addr = page_address(page);
 
-	printk(KERN_ERR "*** SLUB: %s in %s@0x%p slab 0x%p\n",
-			reason, s->name, object, page);
+	printk(KERN_ERR "*** SLUB %s: %s@0x%p slab 0x%p\n",
+			s->name, reason, object, page);
 	printk(KERN_ERR "    offset=%tu flags=0x%04lx inuse=%u freelist=0x%p\n",
 		object - addr, page->flags, page->inuse, page->freelist);
 	if (object > addr + 16)
@@ -335,6 +335,19 @@ static void object_err(struct kmem_cache
 	dump_stack();
 }
 
+static void slab_err(struct kmem_cache *s, struct page *page, char *reason, ...)
+{
+	va_list args;
+	char buf[100];
+
+	va_start(args, reason);
+	vsnprintf(buf, sizeof(buf), reason, args);
+	va_end(args);
+	printk(KERN_ERR "*** SLUB %s: %s in slab @0x%p\n", s->name, buf,
+		page);
+	dump_stack();
+}
+
 static void init_object(struct kmem_cache *s, void *object, int active)
 {
 	u8 *p = object;
@@ -412,7 +425,7 @@ static int check_valid_pointer(struct km
 static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
 						void *from, void *to)
 {
-	printk(KERN_ERR "@@@ SLUB: %s Restoring %s (0x%x) from 0x%p-0x%p\n",
+	printk(KERN_ERR "@@@ SLUB %s: Restoring %s (0x%x) from 0x%p-0x%p\n",
 		s->name, message, data, from, to - 1);
 	memset(from, data, to - from);
 }
@@ -459,9 +472,7 @@ static int slab_pad_check(struct kmem_ca
 		return 1;
 
 	if (!check_bytes(p + length, POISON_INUSE, remainder)) {
-		printk(KERN_ERR "SLUB: %s slab 0x%p: Padding fails check\n",
-			s->name, p);
-		dump_stack();
+		slab_err(s, page, "Padding check failed");
 		restore_bytes(s, "slab padding", POISON_INUSE, p + length,
 			p + length + remainder);
 		return 0;
@@ -547,30 +558,25 @@ static int check_slab(struct kmem_cache 
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
@@ -599,12 +605,13 @@ static int on_freelist(struct kmem_cache
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
@@ -615,11 +622,12 @@ static int on_freelist(struct kmem_cache
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
@@ -663,10 +671,7 @@ static int alloc_object_checks(struct km
 		goto bad;
 
 	if (object && !on_freelist(s, page, object)) {
-		printk(KERN_ERR "SLUB: %s Object 0x%p@0x%p "
-			"already allocated.\n",
-			s->name, object, page);
-		dump_stack();
+		slab_err(s, page, "Object 0x%p already allocated", object);
 		goto bad;
 	}
 
@@ -706,15 +711,12 @@ static int free_object_checks(struct kme
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
 
@@ -723,24 +725,22 @@ static int free_object_checks(struct kme
 
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
@@ -2479,6 +2479,8 @@ __initcall(cpucache_init);
 #endif
 
 #ifdef SLUB_RESILIENCY_TEST
+static unsigned long validate_slab_cache(struct kmem_cache *s);
+
 static void resiliency_test(void)
 {
 	u8 *p;
@@ -2490,7 +2492,7 @@ static void resiliency_test(void)
 	p = kzalloc(16, GFP_KERNEL);
 	p[16] = 0x12;
 	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
-			" 0x12->%p\n\n", p + 16);
+			" 0x12->0x%p\n\n", p + 16);
 
 	validate_slab_cache(kmalloc_caches + 4);
 
@@ -2498,14 +2500,14 @@ static void resiliency_test(void)
 	p = kzalloc(32, GFP_KERNEL);
 	p[32 + sizeof(void *)] = 0x34;
 	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
-		 	" 0x34 -> %p\n", p);
+		 	" 0x34 -> -0x%p\n", p);
 	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
 
 	validate_slab_cache(kmalloc_caches + 5);
 	p = kzalloc(64, GFP_KERNEL);
 	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p = 0x56;
-	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->%p\n",
+	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
 									p);
 	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
 	validate_slab_cache(kmalloc_caches + 6);
@@ -2514,19 +2516,19 @@ static void resiliency_test(void)
 	p = kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p = 0x78;
-	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->%p\n\n", p);
+	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 7);
 
 	p = kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] = 0x9a;
-	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->%p\n\n", p);
+	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 8);
 
 	p = kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] = 0xab;
-	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->%p\n\n", p);
+	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 9);
 }
 #else
@@ -2593,17 +2595,17 @@ static void validate_slab_slab(struct km
 		validate_slab(s, page);
 		slab_unlock(page);
 	} else
-		printk(KERN_INFO "SLUB: %s Skipped busy slab %p\n",
+		printk(KERN_INFO "SLUB %s: Skipped busy slab 0x%p\n",
 			s->name, page);
 
 	if (s->flags & DEBUG_DEFAULT_FLAGS) {
 		if (!PageError(page))
-			printk(KERN_ERR "SLUB: %s PageError not set "
-				"on slab %p\n", s->name, page);
+			printk(KERN_ERR "SLUB %s: PageError not set "
+				"on slab 0x%p\n", s->name, page);
 	} else {
 		if (PageError(page))
-			printk(KERN_ERR "SLUB: %s PageError set on "
-				"slab %p\n", s->name, page);
+			printk(KERN_ERR "SLUB %s: PageError set on "
+				"slab 0x%p\n", s->name, page);
 	}
 }
 
@@ -2620,8 +2622,8 @@ static int validate_slab_node(struct kme
 		count++;
 	}
 	if (count != n->nr_partial)
-		printk("SLUB: %s %ld partial slabs counted but counter=%ld\n",
-			s->name, count, n->nr_partial);
+		printk(KERN_ERR "SLUB %s: %ld partial slabs counted but "
+			"counter=%ld\n", s->name, count, n->nr_partial);
 
 	if (!(s->flags & SLAB_STORE_USER))
 		goto out;
@@ -2631,8 +2633,9 @@ static int validate_slab_node(struct kme
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
-		printk("SLUB: %s %ld slabs counted but counter=%ld\n",
-		s->name, count, atomic_long_read(&n->nr_slabs));
+		printk(KERN_ERR "SLUB: %s %ld slabs counted but "
+			"counter=%ld\n", s->name, count,
+			atomic_long_read(&n->nr_slabs));
 
 out:
 	spin_unlock_irqrestore(&n->list_lock, flags);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
