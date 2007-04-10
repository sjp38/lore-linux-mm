Date: Tue, 10 Apr 2007 14:14:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101413470.9522@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> Please check that all printks have suitable facility levels (KERN_FOO).

SLUB: printk facility level cleanup

Consistently use KERN_ERR instead of KERN_CRIT. Fixup one location
where we did not use a facility level.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 14:07:02.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 14:09:01.000000000 -0700
@@ -496,14 +496,14 @@ static int check_object(struct kmem_cach
 static int check_slab(struct kmem_cache *s, struct page *page)
 {
 	if (!PageSlab(page)) {
-		printk(KERN_CRIT "SLUB: %s Not a valid slab page @0x%p "
+		printk(KERN_ERR "SLUB: %s Not a valid slab page @0x%p "
 			"flags=%lx mapping=0x%p count=%d \n",
 			s->name, page, page->flags, page->mapping,
 			page_count(page));
 		return 0;
 	}
 	if (page->offset * sizeof(void *) != s->offset) {
-		printk(KERN_CRIT "SLUB: %s Corrupted offset %lu in slab @0x%p"
+		printk(KERN_ERR "SLUB: %s Corrupted offset %lu in slab @0x%p"
 			" flags=0x%lx mapping=0x%p count=%d\n",
 			s->name,
 			(unsigned long)(page->offset * sizeof(void *)),
@@ -514,7 +514,7 @@ static int check_slab(struct kmem_cache 
 		return 0;
 	}
 	if (page->inuse > s->objects) {
-		printk(KERN_CRIT "SLUB: %s Inuse %u > max %u in slab "
+		printk(KERN_ERR "SLUB: %s Inuse %u > max %u in slab "
 			"page @0x%p flags=%lx mapping=0x%p count=%d\n",
 			s->name, page->inuse, s->objects, page, page->flags,
 			page->mapping, page_count(page));
@@ -560,7 +560,7 @@ static int on_freelist(struct kmem_cache
 	}
 
 	if (page->inuse != s->objects - nr) {
-		printk(KERN_CRIT "slab %s: page 0x%p wrong object count."
+		printk(KERN_ERR "slab %s: page 0x%p wrong object count."
 			" counter is %d but counted were %d\n",
 			s->name, page, page->inuse,
 			s->objects - nr);
@@ -625,7 +625,7 @@ static int alloc_object_checks(struct km
 	init_object(s, object, 1);
 
 	if (s->flags & SLAB_TRACE) {
-		printk("TRACE %s alloc 0x%p inuse=%d fp=0x%p\n",
+		printk(KERN_INFO "TRACE %s alloc 0x%p inuse=%d fp=0x%p\n",
 			s->name, object, page->inuse,
 			page->freelist);
 		dump_stack();
@@ -654,7 +654,7 @@ static int free_object_checks(struct kme
 	}
 
 	if (on_freelist(s, page, object)) {
-		printk(KERN_CRIT "SLUB: %s slab 0x%p object "
+		printk(KERN_ERR "SLUB: %s slab 0x%p object "
 			"0x%p already free.\n", s->name, page, object);
 		goto fail;
 	}
@@ -664,23 +664,23 @@ static int free_object_checks(struct kme
 
 	if (unlikely(s != page->slab)) {
 		if (!PageSlab(page))
-			printk(KERN_CRIT "slab_free %s size %d: attempt to"
+			printk(KERN_ERR "slab_free %s size %d: attempt to"
 				"free object(0x%p) outside of slab.\n",
 				s->name, s->size, object);
 		else
 		if (!page->slab)
-			printk(KERN_CRIT
+			printk(KERN_ERR
 				"slab_free : no slab(NULL) for object 0x%p.\n",
 						object);
 		else
-		printk(KERN_CRIT "slab_free %s(%d): object at 0x%p"
+		printk(KERN_ERR "slab_free %s(%d): object at 0x%p"
 				" belongs to slab %s(%d)\n",
 				s->name, s->size, object,
 				page->slab->name, page->slab->size);
 		goto fail;
 	}
 	if (s->flags & SLAB_TRACE) {
-		printk("TRACE %s free 0x%p inuse=%d fp=0x%p\n",
+		printk(KERN_INFO "TRACE %s free 0x%p inuse=%d fp=0x%p\n",
 			s->name, object, page->inuse,
 			page->freelist);
 		print_section("Object", object, s->objsize);
@@ -1794,7 +1794,7 @@ static int __init setup_slub_debug(char 
 				slub_debug |= SLAB_TRACE;
 				break;
 			default:
-				printk(KERN_CRIT "slub_debug option '%c' "
+				printk(KERN_ERR "slub_debug option '%c' "
 					"unknown. skipped\n",*str);
 			}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
