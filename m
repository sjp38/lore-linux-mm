Date: Thu, 3 May 2007 18:45:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0705031839480.16296@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmmmm.. One potential issues are the complicated way the slab is 
handled. Could you try this patch and see what impact it has?

If it has any then remove the cachline alignment and see how that 
influences things.


Remove constructor from buffer_head

Buffer head management uses a constructor which increases overhead
for object handling. Remove the constructor. That way SLUB can place
the freepointer in an optimal location instead of after the object
in potentially another cache line.

Also having no constructor makes allocation and disposal of slabs
from the page allocator much easier since no pass over the objects
allocated to call construtors is necessary. SLUB can directly begin by
serving the first object.

Plus it simplifies the code and removes a difficult to understand
element for buffer handling.

Align the buffer heads on cacheline boundaries for best performance.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/buffer.c                 |   22 ++++------------------
 include/linux/buffer_head.h |    2 +-
 2 files changed, 5 insertions(+), 19 deletions(-)

Index: slub/fs/buffer.c
===================================================================
--- slub.orig/fs/buffer.c	2007-04-30 22:03:21.000000000 -0700
+++ slub/fs/buffer.c	2007-05-03 18:37:47.000000000 -0700
@@ -2907,9 +2907,10 @@ static void recalc_bh_state(void)
 	
 struct buffer_head *alloc_buffer_head(gfp_t gfp_flags)
 {
-	struct buffer_head *ret = kmem_cache_alloc(bh_cachep,
+	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep,
 				set_migrateflags(gfp_flags, __GFP_RECLAIMABLE));
 	if (ret) {
+		INIT_LIST_HEAD(&ret->b_assoc_buffers);
 		get_cpu_var(bh_accounting).nr++;
 		recalc_bh_state();
 		put_cpu_var(bh_accounting);
@@ -2928,17 +2929,6 @@ void free_buffer_head(struct buffer_head
 }
 EXPORT_SYMBOL(free_buffer_head);
 
-static void
-init_buffer_head(void *data, struct kmem_cache *cachep, unsigned long flags)
-{
-	if (flags & SLAB_CTOR_CONSTRUCTOR) {
-		struct buffer_head * bh = (struct buffer_head *)data;
-
-		memset(bh, 0, sizeof(*bh));
-		INIT_LIST_HEAD(&bh->b_assoc_buffers);
-	}
-}
-
 static void buffer_exit_cpu(int cpu)
 {
 	int i;
@@ -2965,12 +2955,8 @@ void __init buffer_init(void)
 {
 	int nrpages;
 
-	bh_cachep = kmem_cache_create("buffer_head",
-					sizeof(struct buffer_head), 0,
-					(SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
-					SLAB_MEM_SPREAD),
-					init_buffer_head,
-					NULL);
+	bh_cachep = KMEM_CACHE(buffer_head,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
 
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL
Index: slub/include/linux/buffer_head.h
===================================================================
--- slub.orig/include/linux/buffer_head.h	2007-05-03 18:40:51.000000000 -0700
+++ slub/include/linux/buffer_head.h	2007-05-03 18:41:07.000000000 -0700
@@ -73,7 +73,7 @@ struct buffer_head {
 	struct address_space *b_assoc_map;	/* mapping this buffer is
 						   associated with */
 	atomic_t b_count;		/* users using this buffer_head */
-};
+} ____cacheline_aligned_in_smp;
 
 /*
  * macro tricks to expand the set_buffer_foo(), clear_buffer_foo()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
