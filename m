Date: Fri, 20 Apr 2007 23:06:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slab allocators: Remove SLAB_CTOR_ATOMIC
Message-ID: <Pine.LNX.4.64.0704202305270.6313@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

SLAB_CTOR atomic is never used which is no surprise since I cannot imagine
that one would want to do something serious in a constructor or destructor.
In particular given that the slab allocators run with interrupts disabled.
Actions in constructors and destructors are by their nature very limited
and usually do not go beyond initializing variables and list operations.

(The i386 pgd ctor and dtors do take a spinlock in constructor and
destructor..... I think that is the furthest we go at this point.)

There is no flag passed to the destructor so removing SLAB_CTOR_ATOMIC
also establishes a certain symmetry.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/include/linux/slab.h
===================================================================
--- linux-2.6.21-rc6.orig/include/linux/slab.h	2007-04-20 22:33:04.000000000 -0700
+++ linux-2.6.21-rc6/include/linux/slab.h	2007-04-20 22:33:09.000000000 -0700
@@ -34,7 +34,6 @@ typedef struct kmem_cache kmem_cache_t _
 
 /* Flags passed to a constructor functions */
 #define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */
-#define SLAB_CTOR_ATOMIC	0x002UL		/* Tell constructor it can't sleep */
 
 /*
  * struct kmem_cache related prototypes
Index: linux-2.6.21-rc6/mm/slab.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slab.c	2007-04-20 22:34:08.000000000 -0700
+++ linux-2.6.21-rc6/mm/slab.c	2007-04-20 22:35:07.000000000 -0700
@@ -2749,13 +2749,6 @@ static int cache_grow(struct kmem_cache 
 
 	ctor_flags = SLAB_CTOR_CONSTRUCTOR;
 	local_flags = (flags & GFP_LEVEL_MASK);
-	if (!(local_flags & __GFP_WAIT))
-		/*
-		 * Not allowed to sleep.  Need to tell a constructor about
-		 * this - it might need to know...
-		 */
-		ctor_flags |= SLAB_CTOR_ATOMIC;
-
 	/* Take the l3 list lock to change the colour_next on this node */
 	check_irq_off();
 	l3 = cachep->nodelists[nodeid];
@@ -3089,14 +3082,8 @@ static void *cache_alloc_debugcheck_afte
 	}
 #endif
 	objp += obj_offset(cachep);
-	if (cachep->ctor && cachep->flags & SLAB_POISON) {
-		unsigned long ctor_flags = SLAB_CTOR_CONSTRUCTOR;
-
-		if (!(flags & __GFP_WAIT))
-			ctor_flags |= SLAB_CTOR_ATOMIC;
-
-		cachep->ctor(objp, cachep, ctor_flags);
-	}
+	if (cachep->ctor && cachep->flags & SLAB_POISON)
+		cachep->ctor(objp, cachep, SLAB_CTOR_CONSTRUCTOR);
 #if ARCH_SLAB_MINALIGN
 	if ((u32)objp & (ARCH_SLAB_MINALIGN-1)) {
 		printk(KERN_ERR "0x%p: not aligned to ARCH_SLAB_MINALIGN=%d\n",
Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-20 22:33:13.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-20 22:33:43.000000000 -0700
@@ -784,14 +784,8 @@ static void setup_object(struct kmem_cac
 		init_tracking(s, object);
 	}
 
-	if (unlikely(s->ctor)) {
-		int mode = SLAB_CTOR_CONSTRUCTOR;
-
-		if (!(s->flags & __GFP_WAIT))
-			mode |= SLAB_CTOR_ATOMIC;
-
-		s->ctor(object, s, mode);
-	}
+	if (unlikely(s->ctor))
+		s->ctor(object, s, SLAB_CTOR_CONSTRUCTOR);
 }
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
