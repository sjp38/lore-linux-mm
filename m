Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9E42B6B009E
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:13:02 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 24FF782C4E9
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:16:57 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id x-xJ+WxB6NLo for <linux-mm@kvack.org>;
	Tue, 17 Feb 2009 12:16:52 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0B8CC82C50F
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:16:47 -0500 (EST)
Date: Tue, 17 Feb 2009 12:05:07 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <1234890096.11511.6.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0902171204070.15929@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de>  <200902041748.41801.nickpiggin@yahoo.com.au>  <20090204152709.GA4799@csn.ul.ie>  <200902051459.30064.nickpiggin@yahoo.com.au>  <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
 <alpine.DEB.1.10.0902171120040.27813@qirst.com> <1234890096.11511.6.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Well yes you missed two locations (kmalloc_caches array has to be
redimensioned) and I also was writing the same patch...

Here is mine:

Subject: SLUB: Do not pass 8k objects through to the page allocator

Increase the maximum object size in SLUB so that 8k objects are not
passed through to the page allocator anymore. The network stack uses 8k
objects for performance critical operations.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2009-02-17 10:45:51.000000000 -0600
+++ linux-2.6/include/linux/slub_def.h	2009-02-17 11:06:53.000000000 -0600
@@ -121,10 +121,21 @@
 #define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)

 /*
+ * Maximum kmalloc object size handled by SLUB. Larger object allocations
+ * are passed through to the page allocator. The page allocator "fastpath"
+ * is relatively slow so we need this value sufficiently high so that
+ * performance critical objects are allocated through the SLUB fastpath.
+ *
+ * This should be dropped to PAGE_SIZE / 2 once the page allocator
+ * "fastpath" becomes competitive with the slab allocator fastpaths.
+ */
+#define SLUB_MAX_SIZE (2 * PAGE_SIZE)
+
+/*
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
  */
-extern struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1];
+extern struct kmem_cache kmalloc_caches[PAGE_SHIFT + 2];

 /*
  * Sorry that the following has to be that ugly but some versions of GCC
@@ -212,7 +223,7 @@
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
-		if (size > PAGE_SIZE)
+		if (size > SLUB_MAX_SIZE)
 			return kmalloc_large(size, flags);

 		if (!(flags & SLUB_DMA)) {
@@ -234,7 +245,7 @@
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	if (__builtin_constant_p(size) &&
-		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
+		size <= SLUB_MAX_SIZE && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);

 		if (!s)
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2009-02-17 10:49:47.000000000 -0600
+++ linux-2.6/mm/slub.c	2009-02-17 10:58:14.000000000 -0600
@@ -2475,7 +2475,7 @@
  *		Kmalloc subsystem
  *******************************************************************/

-struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1] __cacheline_aligned;
+struct kmem_cache kmalloc_caches[PAGE_SHIFT + 2] __cacheline_aligned;
 EXPORT_SYMBOL(kmalloc_caches);

 static int __init setup_slub_min_order(char *str)
@@ -2658,7 +2658,7 @@
 {
 	struct kmem_cache *s;

-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLUB_MAX_SIZE))
 		return kmalloc_large(size, flags);

 	s = get_slab(size, flags);
@@ -2686,7 +2686,7 @@
 {
 	struct kmem_cache *s;

-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLUB_MAX_SIZE))
 		return kmalloc_large_node(size, flags, node);

 	s = get_slab(size, flags);
@@ -3223,7 +3223,7 @@
 {
 	struct kmem_cache *s;

-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLUB_MAX_SIZE))
 		return kmalloc_large(size, gfpflags);

 	s = get_slab(size, gfpflags);
@@ -3239,7 +3239,7 @@
 {
 	struct kmem_cache *s;

-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLUB_MAX_SIZE))
 		return kmalloc_large_node(size, gfpflags, node);

 	s = get_slab(size, gfpflags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
