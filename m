Date: Thu, 2 Sep 2004 16:40:01 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20040902234001.28782.13994.78039@tomahawk.engr.sgi.com>
In-Reply-To: <20040902233953.28782.83663.95879@tomahawk.engr.sgi.com>
References: <20040902233953.28782.83663.95879@tomahawk.engr.sgi.com>
Subject: [RFC 2.6.9-rc1-mm2 2/2] kmempolicy: memory policy for page cache allocation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <piggin@cyberone.com.au>, "Martin J. Bligh" <mbligh@aracnet.com>, Andi Kleen <ak@suse.de>, Brent Casavant <bcasavant@sgi.com>, Ray Bryant <raybry@sgi.com>, Andrew Morton <akpm@osdl.org>, Dan Higgins <djh@sgi.com>, Dave Hansen <haveblue@us.ibm.com>, Jesse Barnes <jbarnes@sgi.com>
List-ID: <linux-mm.kvack.org>

Here's the second part of the memory policy for page cache pages
allocation patch/RFC.  This is where the page cache policy is actually
declared and implemented.

Once again, hardly a final patch, but lets keep the lawyers happy:

Signed-off-by: Ray Bryant <raybry@sgi.com>

===================================================================
Index: linux-2.6.9-rc1-mm2-kdb-pagecache/mm/mempolicy.c
===================================================================
--- linux-2.6.9-rc1-mm2-kdb-pagecache.orig/mm/mempolicy.c	2004-09-02 13:17:45.000000000 -0700
+++ linux-2.6.9-rc1-mm2-kdb-pagecache/mm/mempolicy.c	2004-09-02 13:19:53.000000000 -0700
@@ -99,6 +99,12 @@
 	.policy = MPOL_DEFAULT,
 };
 
+struct mempolicy default_pagecache_mempolicy = {
+	.refcnt  = ATOMIC_INIT(1), /* never free it */
+	.policy  = MPOL_ROUNDROBIN,
+	.v.nodes = {0x000000000000000F, 7*0},
+};
+
 /* Check if all specified nodes are online */
 static int nodes_online(unsigned long *nodes)
 {
@@ -750,7 +756,7 @@
 }
 
 /**
- * 	alloc_pages_current - Allocate pages.
+ * 	alloc_pages_by_policy - Allocate pages using a given mempolicy
  *
  *	@gfp:
  *		%GFP_USER   user allocation,
@@ -759,15 +765,15 @@
  *      	%GFP_FS     don't call back into a file system.
  *      	%GFP_ATOMIC don't sleep.
  *	@order: Power of two of allocation size in pages. 0 is a single page.
+ *	@pol:   Pointer to the mempolicy struct to use for this allocation
  *
  *	Allocate a page from the kernel page pool.  When not in
  *	interrupt context and apply the current process NUMA policy.
  *	Returns NULL when no page can be allocated.
  */
-struct page *alloc_pages_current(unsigned gfp, unsigned order)
+struct page *
+__alloc_pages_by_policy(unsigned gfp, unsigned order, struct mempolicy *pol)
 {
-	struct mempolicy *pol = current->mempolicy;
-
 	if (!in_interrupt())
 		cpuset_update_current_mems_allowed();
 	if (!pol || in_interrupt())
@@ -779,6 +785,27 @@
 	}
 	return __alloc_pages(gfp, order, zonelist_policy(gfp, pol));
 }
+
+/**
+ * 	alloc_pages_current - Allocate pages.
+ *
+ *	@gfp:
+ *		%GFP_USER   user allocation,
+ *      	%GFP_KERNEL kernel allocation,
+ *      	%GFP_HIGHMEM highmem allocation,
+ *      	%GFP_FS     don't call back into a file system.
+ *      	%GFP_ATOMIC don't sleep.
+ *	@order: Power of two of allocation size in pages. 0 is a single page.
+ *
+ *	Allocate a page from the kernel page pool.  When not in
+ *	interrupt context and apply the current process NUMA policy.
+ *	Returns NULL when no page can be allocated.
+ */
+// FIXME -- make inline
+struct page *alloc_pages_current(unsigned gfp, unsigned order)
+{
+	return __alloc_pages_by_policy(gfp, order, current->mempolicy);
+}
 EXPORT_SYMBOL(alloc_pages_current);
 
 /* Slow path of a mempolicy copy */
===================================================================
Index: linux-2.6.9-rc1-mm2-kdb-pagecache/include/linux/sched.h
===================================================================
--- linux-2.6.9-rc1-mm2-kdb-pagecache.orig/include/linux/sched.h	2004-09-02 13:17:45.000000000 -0700
+++ linux-2.6.9-rc1-mm2-kdb-pagecache/include/linux/sched.h	2004-09-02 13:19:53.000000000 -0700
@@ -595,6 +595,7 @@
 	wait_queue_t *io_wait;
 #ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
+	struct mempolicy *kernel_mempolicy;
   	short il_next;		/* could be shared with used_math */
 	short rr_next;
 #endif
===================================================================
Index: linux-2.6.9-rc1-mm2-kdb-pagecache/include/linux/pagemap.h
===================================================================
--- linux-2.6.9-rc1-mm2-kdb-pagecache.orig/include/linux/pagemap.h	2004-08-31 13:32:09.000000000 -0700
+++ linux-2.6.9-rc1-mm2-kdb-pagecache/include/linux/pagemap.h	2004-09-02 13:19:53.000000000 -0700
@@ -50,6 +50,7 @@
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
+#ifndef CONFIG_NUMA
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
 	return alloc_pages(mapping_gfp_mask(x), 0);
@@ -59,6 +60,37 @@
 {
 	return alloc_pages(mapping_gfp_mask(x)|__GFP_COLD, 0);
 }
+#define page_cache_alloc_local((x)) page_cache_alloc((x))
+#else /* CONFIG_NUMA */
+extern struct mempolicy default_pagecache_mempolicy;
+extern struct page *
+__alloc_pages_by_policy(unsigned gfp, unsigned order, struct mempolicy *pol);
+
+static inline struct page *page_cache_alloc_local(struct address_space *x)
+{
+	return alloc_pages(mapping_gfp_mask(x), 0);
+}
+
+static inline struct page *page_cache_alloc(struct address_space *x)
+{
+	struct mempolicy *pol = current->kernel_mempolicy;
+
+	if (!pol)
+		pol = &default_pagecache_mempolicy;
+		
+	return __alloc_pages_by_policy(mapping_gfp_mask(x), 0, pol);
+}
+
+static inline struct page *page_cache_alloc_cold(struct address_space *x)
+{
+	struct mempolicy *pol = current->kernel_mempolicy;
+
+	if (!pol)
+		pol = &default_pagecache_mempolicy;
+		
+	return __alloc_pages_by_policy(mapping_gfp_mask(x)|__GFP_COLD, 0, pol);
+}
+#endif
 
 typedef int filler_t(void *, struct page *);
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
