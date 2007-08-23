From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 6/6] SLUB: Optimize cacheline use for zeroing
Date: Wed, 22 Aug 2007 23:46:59 -0700
Message-ID: <20070823064734.997050223@sgi.com>
References: <20070823064653.081843729@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760939AbXHWGtH@vger.kernel.org>
Content-Disposition: inline; filename=0010-SLUB-Optimize-cacheline-use-for-zeroing.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

We touch a cacheline in the kmem_cache structure for zeroing to get the
size. However, the hot paths in slab_alloc and slab_free do not reference
any other fields in kmem_cache, so we may have to just bring in the
cacheline for this one access.

Add a new field to kmem_cache_cpu that contains the object size. That
cacheline must already be used in the hotpaths. So we save one cacheline
on every slab_alloc if we zero.

We need to update the kmem_cache_cpu object size if an aliasing operation
changes the objsize of an non debug slab.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

Index: linux-2.6.23-rc3-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.23-rc3-mm1.orig/include/linux/slub_def.h	2007-08-22 17:23:47.000000000 -0700
+++ linux-2.6.23-rc3-mm1/include/linux/slub_def.h	2007-08-22 17:23:50.000000000 -0700
@@ -16,6 +16,7 @@ struct kmem_cache_cpu {
 	struct page *page;
 	int node;
 	unsigned int offset;
+	unsigned int objsize;
 };
 
 struct kmem_cache_node {
Index: linux-2.6.23-rc3-mm1/mm/slub.c
===================================================================
--- linux-2.6.23-rc3-mm1.orig/mm/slub.c	2007-08-22 17:23:47.000000000 -0700
+++ linux-2.6.23-rc3-mm1/mm/slub.c	2007-08-22 17:23:50.000000000 -0700
@@ -1556,7 +1556,7 @@ static void __always_inline *slab_alloc(
 	local_irq_restore(flags);
 
 	if (unlikely((gfpflags & __GFP_ZERO) && object))
-		memset(object, 0, s->objsize);
+		memset(object, 0, c->objsize);
 
 	return object;
 }
@@ -1843,8 +1843,9 @@ static void init_kmem_cache_cpu(struct k
 {
 	c->page = NULL;
 	c->freelist = NULL;
-	c->offset = s->offset / sizeof(void *);
 	c->node = 0;
+	c->offset = s->offset / sizeof(void *);
+	c->objsize = s->objsize;
 }
 
 static void init_kmem_cache_node(struct kmem_cache_node *n)
@@ -2842,12 +2843,21 @@ struct kmem_cache *kmem_cache_create(con
 	down_write(&slub_lock);
 	s = find_mergeable(size, align, flags, ctor);
 	if (s) {
+		int cpu;
+
 		s->refcount++;
 		/*
 		 * Adjust the object sizes so that we clear
 		 * the complete object on kzalloc.
 		 */
 		s->objsize = max(s->objsize, (int)size);
+
+		/*
+		 * And then we need to update the object size in the
+		 * per cpu structures
+		 */
+		for_each_online_cpu(cpu)
+			get_cpu_slab(s, cpu)->objsize = s->objsize;
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 		up_write(&slub_lock);
 		if (sysfs_slab_alias(s, name))

-- 
