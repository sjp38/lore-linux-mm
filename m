Date: Fri, 4 May 2007 18:41:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178322176.23795.219.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705041839550.28664@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
  <Pine.LNX.4.64.0705031937560.16542@schroedinger.engr.sgi.com>
 <1178298897.23795.195.camel@localhost.localdomain>
 <Pine.LNX.4.64.0705041118490.24283@schroedinger.engr.sgi.com>
 <1178318609.23795.214.camel@localhost.localdomain>
 <Pine.LNX.4.64.0705041658350.28260@schroedinger.engr.sgi.com>
 <1178322176.23795.219.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If you want to test some more: Here is a patch that removes the atomic ops 
from the allocation patch. But I only see minor improvements on my amd64 
box here.



Avoid the use of atomics in slab_alloc

This only increases netperf performance by 1%. Wonder why?

What we do is add the last free field in the page struct to setup
a separate per cpu freelist. From that one we can allocate without
taking the slab lock because we checkout the complete list of fre
objects when we first touch the slab.

This allows concurrent allocations and frees from the same slab using
two mutually exclusive freelists. If the allocator is running out of
its per cpu freelist then it will consult the per slab freelist and reload
if objects were freed in it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_types.h |    5 ++++-
 mm/slub.c                |   44 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 39 insertions(+), 10 deletions(-)

Index: slub/include/linux/mm_types.h
===================================================================
--- slub.orig/include/linux/mm_types.h	2007-05-04 17:39:33.000000000 -0700
+++ slub/include/linux/mm_types.h	2007-05-04 17:58:38.000000000 -0700
@@ -50,9 +50,12 @@ struct page {
 	    spinlock_t ptl;
 #endif
 	    struct {			/* SLUB uses */
-		struct page *first_page;	/* Compound pages */
+	    	void **active_freelist;		/* Allocation freelist */
 		struct kmem_cache *slab;	/* Pointer to slab */
 	    };
+	    struct {
+		struct page *first_page;	/* Compound pages */
+	    };
 	};
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-04 17:40:50.000000000 -0700
+++ slub/mm/slub.c	2007-05-04 18:14:23.000000000 -0700
@@ -845,6 +845,7 @@ static struct page *new_slab(struct kmem
 	page->offset = s->offset / sizeof(void *);
 	page->slab = s;
 	page->inuse = 0;
+	page->active_freelist = NULL;
 	start = page_address(page);
 	end = start + s->objects * s->size;
 
@@ -1137,6 +1138,19 @@ static void putback_slab(struct kmem_cac
  */
 static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
 {
+	/* Two freelists that are now to be consolidated */
+	while (unlikely(page->active_freelist)) {
+		void **object;
+
+		/* Retrieve object from active_freelist */
+		object = page->active_freelist;
+		page->active_freelist = page->active_freelist[page->offset];
+
+		/* And put onto the regular freelist */
+		object[page->offset] = page->freelist;
+		page->freelist = object;
+		page->inuse--;
+	}
 	s->cpu_slab[cpu] = NULL;
 	ClearPageActive(page);
 
@@ -1206,25 +1220,32 @@ static void *slab_alloc(struct kmem_cach
 	local_irq_save(flags);
 	cpu = smp_processor_id();
 	page = s->cpu_slab[cpu];
-	if (!page)
+	if (unlikely(!page))
 		goto new_slab;
 
+	if (likely(page->active_freelist)) {
+fast_object:
+		object = page->active_freelist;
+		page->active_freelist = object[page->offset];
+		local_irq_restore(flags);
+		return object;
+	}
+
 	slab_lock(page);
 	if (unlikely(node != -1 && page_to_nid(page) != node))
 		goto another_slab;
 redo:
-	object = page->freelist;
-	if (unlikely(!object))
+	if (unlikely(!page->freelist))
 		goto another_slab;
 	if (unlikely(PageError(page)))
 		goto debug;
 
-have_object:
-	page->inuse++;
-	page->freelist = object[page->offset];
+	/* Reload the active freelist */
+	page->active_freelist = page->freelist;
+	page->freelist = NULL;
+	page->inuse = s->objects;
 	slab_unlock(page);
-	local_irq_restore(flags);
-	return object;
+	goto fast_object;
 
 another_slab:
 	deactivate_slab(s, page, cpu);
@@ -1267,6 +1288,7 @@ have_slab:
 	local_irq_restore(flags);
 	return NULL;
 debug:
+	object = page->freelist;
 	if (!alloc_object_checks(s, page, object))
 		goto another_slab;
 	if (s->flags & SLAB_STORE_USER)
@@ -1278,7 +1300,11 @@ debug:
 		dump_stack();
 	}
 	init_object(s, object, 1);
-	goto have_object;
+	page->freelist = object[page->offset];
+	page->inuse++;
+	slab_unlock(page);
+	local_irq_restore(flags);
+	return object;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
