Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 09E0F6B009C
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:01:39 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.1.10.0902171120040.27813@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de>
	 <200902041748.41801.nickpiggin@yahoo.com.au>
	 <20090204152709.GA4799@csn.ul.ie>
	 <200902051459.30064.nickpiggin@yahoo.com.au>
	 <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
	 <alpine.DEB.1.10.0902171120040.27813@qirst.com>
Date: Tue, 17 Feb 2009 19:01:36 +0200
Message-Id: <1234890096.11511.6.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Mon, 16 Feb 2009, Pekka Enberg wrote:
> > Btw, Yanmin, do you have access to the tests Mel is running (especially the
> > ones where slub-rvrt seems to do worse)? Can you see this kind of regression?
> > The results make we wonder whether we should avoid reverting all of the page
> > allocator pass-through and just add a kmalloc cache for 8K allocations. Or not
> > address the netperf regression at all. Double-hmm.

On Tue, 2009-02-17 at 11:20 -0500, Christoph Lameter wrote:
> Going to 8k for the limit beyond we pass through to the page allocator may
> be the simplest and best solution. Someone please work on the page
> allocator...

Yeah. Something like this totally untested patch, perhaps?

			Pekka

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2f5c16b..e93cb3d 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -201,6 +201,13 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 #define SLUB_DMA (__force gfp_t)0
 #endif
 
+/*
+ * The maximum allocation size that will be satisfied by the slab allocator for
+ * kmalloc(). Requests that exceed this limit are passed directly to the page
+ * allocator.
+ */
+#define SLAB_LIMIT (8 * 1024)
+
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
@@ -212,7 +219,7 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
-		if (size > PAGE_SIZE)
+		if (size > SLAB_LIMIT)
 			return kmalloc_large(size, flags);
 
 		if (!(flags & SLUB_DMA)) {
@@ -234,7 +241,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	if (__builtin_constant_p(size) &&
-		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
+		size <= SLAB_LIMIT && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
 
 		if (!s)
diff --git a/mm/slub.c b/mm/slub.c
index 0280eee..a324188 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2658,7 +2658,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLAB_LIMIT))
 		return kmalloc_large(size, flags);
 
 	s = get_slab(size, flags);
@@ -2686,7 +2686,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLAB_LIMIT))
 		return kmalloc_large_node(size, flags, node);
 
 	s = get_slab(size, flags);
@@ -3223,7 +3223,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLAB_LIMIT))
 		return kmalloc_large(size, gfpflags);
 
 	s = get_slab(size, gfpflags);
@@ -3239,7 +3239,7 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLAB_LIMIT))
 		return kmalloc_large_node(size, gfpflags, node);
 
 	s = get_slab(size, gfpflags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
