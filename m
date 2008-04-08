Date: Tue, 8 Apr 2008 22:07:49 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 03/18] SLUB: Add get() and kick() methods
In-Reply-To: <20080407231059.e8c173fa.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804082206001.9054@sbz-30.cs.Helsinki.FI>
References: <20080404230158.365359425@sgi.com> <20080404230226.340749825@sgi.com>
 <20080407231059.e8c173fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 04 Apr 2008 16:02:01 -0700 Christoph Lameter <clameter@sgi.com> wrote:
> > Add the two methods needed for defragmentation and add the display of the
> > methods via the proc interface.
> > 
> > Add documentation explaining the use of these methods.
> > 
> > +	void *(*get)(struct kmem_cache *, int nr, void **),
> > +	void (*kick)(struct kmem_cache *, int nr, void **, void *private)) {}
> > +	void *(*get)(struct kmem_cache *, int nr, void **),
> > +	void (*kick)(struct kmem_cache *, int nr, void **, void *private)) {}
> > +	void *(*get)(struct kmem_cache *, int nr, void **);
> > +	void (*kick)(struct kmem_cache *, int nr, void **, void *private);
> > +	void *(*get)(struct kmem_cache *, int nr, void **),
> > +	void (*kick)(struct kmem_cache *, int nr, void **, void *private));
> > +	void *(*get)(struct kmem_cache *, int nr, void **),
> > +	void (*kick)(struct kmem_cache *, int nr, void **, void *private))

On Mon, 7 Apr 2008, Andrew Morton wrote:
> This is one of the few instances where we do use typedefs.

Aye, aye, Cap'n!

			Pekka

From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH] slub: use typedefs for ->get and ->kick functions

As suggested by Andrew Morton, use typedefs for the SLUB defragmentation ->get
and ->kick callback functions.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slub_def.h |   12 +++++++-----
 mm/slub.c                |    5 ++---
 2 files changed, 9 insertions(+), 8 deletions(-)

Index: slab-2.6/include/linux/slub_def.h
===================================================================
--- slab-2.6.orig/include/linux/slub_def.h	2008-04-08 21:57:56.000000000 +0300
+++ slab-2.6/include/linux/slub_def.h	2008-04-08 22:00:29.000000000 +0300
@@ -38,6 +38,9 @@
 	SHRINK_OBJECT_RECLAIM_FAILED, /* Callbacks signaled busy objects */
 	NR_SLUB_STAT_ITEMS };
 
+typedef void *(*kmem_get_fn_t)(struct kmem_cache *, int, void **);
+typedef void (*kmem_kick_fn_t)(struct kmem_cache *, int, void **, void *);
+
 struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to first free per cpu object */
 	struct page *page;	/* The slab from which we are allocating */
@@ -109,7 +112,7 @@
 	 * The array passed to get() is also passed to kick(). The
 	 * function may remove objects by setting array elements to NULL.
 	 */
-	void *(*get)(struct kmem_cache *, int nr, void **);
+	kmem_get_fn_t get;
 
 	/*
 	 * Called with no locks held and interrupts enabled.
@@ -122,7 +125,7 @@
 	 * Success is checked by examining the number of remaining
 	 * objects in the slab.
 	 */
-	void (*kick)(struct kmem_cache *, int nr, void **, void *private);
+	kmem_kick_fn_t kick;
 
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
@@ -288,9 +291,8 @@
 }
 #endif
 
-void kmem_cache_setup_defrag(struct kmem_cache *s,
-	void *(*get)(struct kmem_cache *, int nr, void **),
-	void (*kick)(struct kmem_cache *, int nr, void **, void *private));
+void kmem_cache_setup_defrag(struct kmem_cache *s, kmem_get_fn_t get,
+			     kmem_kick_fn_t kick);
 int kmem_cache_defrag(int node);
 
 #endif /* _LINUX_SLUB_DEF_H */
Index: slab-2.6/mm/slub.c
===================================================================
--- slab-2.6.orig/mm/slub.c	2008-04-08 21:57:52.000000000 +0300
+++ slab-2.6/mm/slub.c	2008-04-08 22:01:22.000000000 +0300
@@ -2770,9 +2770,8 @@
 								GFP_KERNEL);
 }
 
-void kmem_cache_setup_defrag(struct kmem_cache *s,
-	void *(*get)(struct kmem_cache *, int nr, void **),
-	void (*kick)(struct kmem_cache *, int nr, void **, void *private))
+void kmem_cache_setup_defrag(struct kmem_cache *s, kmem_get_fn_t get,
+			     kmem_kick_fn_t kick)
 {
 	int max_objects = oo_objects(s->max);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
