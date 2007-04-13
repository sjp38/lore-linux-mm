From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070413013650.17093.62480.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
References: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 4/5] Resiliency fixups
Date: Thu, 12 Apr 2007 18:36:50 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Do more fixups if we detect problems in order to potentially heal
problems so that the system can continue. This will also avoid
multiple reports about the same corruption.

Add messages what slub does to fix up things. These all begin with @@@.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-12 16:47:18.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-12 18:17:23.000000000 -0700
@@ -190,8 +190,6 @@ static void print_section(char *text, u8
 	int newline = 1;
 	char ascii[17];
 
-	if (length > 128)
-		length = 128;
 	ascii[16] = 0;
 
 	for (i = 0; i < length; i++) {
@@ -331,13 +329,13 @@ static void object_err(struct kmem_cache
 {
 	u8 *addr = page_address(page);
 
-	printk(KERN_ERR "*** SLUB: %s in %s@0x%p Slab 0x%p\n",
+	printk(KERN_ERR "*** SLUB: %s in %s@0x%p slab 0x%p\n",
 			reason, s->name, object, page);
 	printk(KERN_ERR "    offset=%tu flags=0x%04lx inuse=%u freelist=0x%p\n",
 		object - addr, page->flags, page->inuse, page->freelist);
 	if (object > addr + 16)
 		print_section("Bytes b4", object - 16, 16);
-	print_section("Object", object, s->objsize);
+	print_section("Object", object, min(s->objsize, 128));
 	print_trailer(s, object);
 	dump_stack();
 }
@@ -416,6 +414,14 @@ static int check_valid_pointer(struct km
  * may be used with merged slabcaches.
  */
 
+static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
+						void *from, void *to)
+{
+	printk(KERN_ERR "@@@ SLUB: %s Restoring %s (0x%x) from 0x%p-0x%p\n",
+		s->name, message, data, from, to - 1);
+	memset(from, data, to - from);
+}
+
 static int check_pad_bytes(struct kmem_cache *s, struct page *page, u8 *p)
 {
 	unsigned long off = s->inuse;	/* The end of info */
@@ -435,6 +441,11 @@ static int check_pad_bytes(struct kmem_c
 		return 1;
 
 	object_err(s, page, p, "Object padding check fails");
+
+	/*
+	 * Restore padding
+	 */
+	restore_bytes(s, "object padding", POISON_INUSE, p + off, p + s->size);
 	return 0;
 }
 
@@ -455,7 +466,9 @@ static int slab_pad_check(struct kmem_ca
 	if (!check_bytes(p + length, POISON_INUSE, remainder)) {
 		printk(KERN_ERR "SLUB: %s slab 0x%p: Padding fails check\n",
 			s->name, p);
-		print_section("Slab Pad", p + length, remainder);
+		dump_stack();
+		restore_bytes(s, "slab padding", POISON_INUSE, p + length,
+			p + length + remainder);
 		return 0;
 	}
 	return 1;
@@ -468,28 +481,48 @@ static int check_object(struct kmem_cach
 	u8 *endobject = object + s->objsize;
 
 	if (s->flags & SLAB_RED_ZONE) {
-		if (!check_bytes(endobject,
-			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE,
-			s->inuse - s->objsize)) {
-				object_err(s, page, object,
-				active ? "Redzone Active check fails" :
-					"Redzone Inactive check fails");
-				return 0;
+		unsigned int red =
+			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE;
+
+		if (!check_bytes(endobject, red, s->inuse - s->objsize)) {
+			object_err(s, page, object,
+			active ? "Redzone Active" : "Redzone Inactive");
+			restore_bytes(s, "redzone", red,
+				endobject, object + s->inuse);
+			return 0;
 		}
-	} else if ((s->flags & SLAB_POISON) && s->objsize < s->inuse &&
+	} else {
+		if ((s->flags & SLAB_POISON) && s->objsize < s->inuse &&
 			!check_bytes(endobject, POISON_INUSE,
-					s->inuse - s->objsize))
+					s->inuse - s->objsize)) {
 		object_err(s, page, p, "Alignment padding check fails");
+		/*
+		 * Fix it so that there will not be another report.
+		 *
+		 * Hmmm... We may be corrupting an object that now expects
+		 * to be longer than allowed.
+		 */
+		restore_bytes(s, "alignment padding", POISON_INUSE,
+			endobject, object + s->inuse);
+		}
+	}
 
 	if (s->flags & SLAB_POISON) {
 		if (!active && (s->flags & __OBJECT_POISON) &&
 			(!check_bytes(p, POISON_FREE, s->objsize - 1) ||
 				p[s->objsize - 1] != POISON_END)) {
+
 			object_err(s, page, p, "Poison check failed");
+			restore_bytes(s, "Poison", POISON_FREE,
+						p, p + s->objsize -1);
+			restore_bytes(s, "Poison", POISON_END,
+					p + s->objsize - 1, p + s->objsize);
 			return 0;
 		}
-		if (!check_pad_bytes(s, page, p))
-			return 0;
+		/*
+		 * check_pad_bytes cleans up on its own.
+		 */
+		check_pad_bytes(s, page, p);
 	}
 
 	if (!s->offset && active)
@@ -503,9 +536,10 @@ static int check_object(struct kmem_cach
 	if (!check_valid_pointer(s, page, get_freepointer(s, p))) {
 		object_err(s, page, p, "Freepointer corrupt");
 		/*
-		 * No choice but to zap it. This may cause
-		 * another error because the object count
-		 * is now wrong.
+		 * No choice but to zap it and thus loose the remainder
+		 * of the free objects in this slab. May cause
+		 * another error because the object count maybe
+		 * wrong now.
 		 */
 		set_freepointer(s, p, NULL);
 		return 0;
@@ -532,7 +566,8 @@ static int check_slab(struct kmem_cache 
 			page,
 			page->flags,
 			page->mapping,
-			page_count(page));
+			page_count(page));\
+		dump_stack();
 		return 0;
 	}
 	if (page->inuse > s->objects) {
@@ -540,9 +575,12 @@ static int check_slab(struct kmem_cache 
 			"page @0x%p flags=%lx mapping=0x%p count=%d\n",
 			s->name, page->inuse, s->objects, page, page->flags,
 			page->mapping, page_count(page));
+		dump_stack();
 		return 0;
 	}
-	return slab_pad_check(s, page);
+	/* Slab_pad_check fixes things up after itself */
+	slab_pad_check(s, page);
+	return 1;
 }
 
 /*
@@ -652,9 +690,19 @@ static int alloc_object_checks(struct km
 
 	return 1;
 bad:
-	/* Mark slab full */
-	page->inuse = s->objects;
-	page->freelist = NULL;
+	if (PageSlab(page)) {
+		/*
+		 * If this is a slab page then lets do the best we can
+		 * to avoid issues in the future. Marking all objects
+		 * as used avoids touching the remainder.
+		 */
+		printk(KERN_ERR "@@@ SLUB: %s slab 0x%p. Marking all objects used.\n",
+			s->name, page);
+		page->inuse = s->objects;
+		page->freelist = NULL;
+		/* Fix up fields that may be corrupted */
+		page->offset = s->offset / sizeof(void *);
+	}
 	return 0;
 }
 
@@ -700,6 +748,8 @@ static int free_object_checks(struct kme
 	return 1;
 fail:
 	dump_stack();
+	printk(KERN_ERR "@@@ SLUB: %s slab 0x%p object at 0x%p not freed.\n",
+		s->name, page, object);
 	return 0;
 }
 
@@ -1574,9 +1624,9 @@ static int calculate_sizes(struct kmem_c
 	 */
 	if ((flags & SLAB_POISON) && !(flags & SLAB_DESTROY_BY_RCU) &&
 			!s->ctor && !s->dtor)
-		flags |= __OBJECT_POISON;
+		s->flags |= __OBJECT_POISON;
 	else
-		flags &= ~__OBJECT_POISON;
+		s->flags &= ~__OBJECT_POISON;
 
 	/*
 	 * Round up object size to the next word boundary. We can only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
