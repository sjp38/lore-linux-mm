From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 07/10] SLUB: Avoid referencing kmem_cache structure in __slab_alloc
Date: Sat, 27 Oct 2007 20:32:03 -0700
Message-ID: <20071028033259.992768446@sgi.com>
References: <20071028033156.022983073@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756793AbXJ1Dfr@vger.kernel.org>
Content-Disposition: inline; filename=slub_objects_in_per_cpu
Sender: linux-kernel-owner@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

There is the need to use the objects per slab in the first part of
__slab_alloc() which is still pretty hot. Copy the number of objects
per slab into the kmem_cache_cpu structure. That way we can get the
value from a cache line that we already need to touch. This brings
the kmem_cache_cpu structure up to 4 even words.

There is no increase in the size of kmem_cache_cpu since the size of object
is rounded to the next word.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2007-10-26 19:09:16.000000000 -0700
+++ linux-2.6/include/linux/slub_def.h	2007-10-27 07:55:12.000000000 -0700
@@ -17,6 +17,7 @@ struct kmem_cache_cpu {
 	int node;
 	unsigned int offset;
 	unsigned int objsize;
+	unsigned int objects;
 };
 
 struct kmem_cache_node {
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-27 07:52:12.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-27 07:55:12.000000000 -0700
@@ -1512,7 +1512,7 @@ load_freelist:
 
 	object = c->page->freelist;
 	c->freelist = object[c->offset];
-	c->page->inuse = s->objects;
+	c->page->inuse = c->objects;
 	c->page->freelist = c->page->end;
 	c->node = page_to_nid(c->page);
 unlock_out:
@@ -1896,6 +1896,7 @@ static void init_kmem_cache_cpu(struct k
 	c->node = 0;
 	c->offset = s->offset / sizeof(void *);
 	c->objsize = s->objsize;
+	c->objects = s->objects;
 }
 
 static void init_kmem_cache_node(struct kmem_cache_node *n)

-- 
