Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F32386B003D
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 02:48:20 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1234919143.2604.417.camel@ymzhang>
References: <20090123154653.GA14517@wotan.suse.de>
	 <200902041748.41801.nickpiggin@yahoo.com.au>
	 <20090204152709.GA4799@csn.ul.ie>
	 <200902051459.30064.nickpiggin@yahoo.com.au>
	 <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
	 <alpine.DEB.1.10.0902171120040.27813@qirst.com>
	 <1234890096.11511.6.camel@penberg-laptop>
	 <alpine.DEB.1.10.0902171204070.15929@qirst.com>
	 <1234919143.2604.417.camel@ymzhang>
Date: Wed, 18 Feb 2009 09:48:16 +0200
Message-Id: <1234943296.24030.2.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>
List-ID: <linux-mm.kvack.org>

Hi Yanmin,

On Wed, 2009-02-18 at 09:05 +0800, Zhang, Yanmin wrote:
> On Tue, 2009-02-17 at 12:05 -0500, Christoph Lameter wrote:
> > Well yes you missed two locations (kmalloc_caches array has to be
> > redimensioned) and I also was writing the same patch...
> > 
> > Here is mine:
> > 
> > Subject: SLUB: Do not pass 8k objects through to the page allocator
> > 
> > Increase the maximum object size in SLUB so that 8k objects are not
> > passed through to the page allocator anymore. The network stack uses 8k
> > objects for performance critical operations.
> Kernel 2.6.29-rc2 panic with the patch.
> 
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<ffffffff8028fae3>] kmem_cache_alloc+0x43/0x97
> PGD 0 
> Oops: 0000 [#1] SMP 
> last sysfs file: 
> CPU 0 
> Modules linked in:
> Pid: 1, comm: swapper Not tainted 2.6.29-rc2slubstat8k #1
> RIP: 0010:[<ffffffff8028fae3>]  [<ffffffff8028fae3>] kmem_cache_alloc+0x43/0x97
> RSP: 0018:ffff88022f865e20  EFLAGS: 00010046
> RAX: 0000000000000000 RBX: 0000000000000246 RCX: 0000000000000002
> RDX: 0000000000000000 RSI: 000000000000063f RDI: ffffffff808096c7
> RBP: 00000000000000d0 R08: 0000000000000004 R09: 000000000012e941
> R10: 0000000000000002 R11: 0000000000000020 R12: ffffffff80991c48
> R13: ffffffff809a9b43 R14: ffffffff809f8000 R15: 0000000000000000
> FS:  0000000000000000(0000) GS:ffffffff80a13080(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 0000000000201000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process swapper (pid: 1, threadinfo ffff88022f864000, task ffff88022f868000)
> Stack:
>  ffffffff809f43e0 0000000000000020 ffffffff809aa469 0000000000000086
>  ffffffff809f8000 ffffffff809a9b43 ffffffff80aaae80 ffffffff809f43e0
>  0000000000000020 ffffffff809aa469 0000000000000000 ffffffff809d86a0
> Call Trace:
>  [<ffffffff809aa469>] ? populate_rootfs+0x0/0xdf
>  [<ffffffff809a9b43>] ? unpack_to_rootfs+0x59/0x97f
>  [<ffffffff809aa469>] ? populate_rootfs+0x0/0xdf
>  [<ffffffff809aa481>] ? populate_rootfs+0x18/0xdf
>  [<ffffffff80209051>] ? _stext+0x51/0x120
>  [<ffffffff802d69b2>] ? create_proc_entry+0x73/0x8a
>  [<ffffffff802619c0>] ? register_irq_proc+0x92/0xaa
>  [<ffffffff809a4896>] ? kernel_init+0x12e/0x188
>  [<ffffffff8020ce3a>] ? child_rip+0xa/0x20
>  [<ffffffff809a4768>] ? kernel_init+0x0/0x188
>  [<ffffffff8020ce30>] ? child_rip+0x0/0x20
> Code: be 3f 06 00 00 48 c7 c7 c7 96 80 80 e8 b8 e2 f9 ff e8 c5 c2 45 00 9c 5b fa 65 8b 04 25 24 00 00 00 48 98 49 8b 94 c4 e8  
> RIP  [<ffffffff8028fae3>] kmem_cache_alloc+0x43/0x97
>  RSP <ffff88022f865e20>
> CR2: 0000000000000000
> ---[ end trace a7919e7f17c0a725 ]---
> swapper used greatest stack depth: 5376 bytes left
> Kernel panic - not syncing: Attempted to kill init!

Aah, we need to fix up some more PAGE_SHIFTs in the code.

			Pekka

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2f5c16b..e217a7a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -121,10 +121,23 @@ struct kmem_cache {
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
+#define SLUB_PAGE_SHIFT (PAGE_SHIFT + 2)
+
+/*
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
  */
-extern struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1];
+extern struct kmem_cache kmalloc_caches[SLUB_PAGE_SHIFT];
 
 /*
  * Sorry that the following has to be that ugly but some versions of GCC
@@ -212,7 +225,7 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
-		if (size > PAGE_SIZE)
+		if (size > SLUB_MAX_SIZE)
 			return kmalloc_large(size, flags);
 
 		if (!(flags & SLUB_DMA)) {
@@ -234,7 +247,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	if (__builtin_constant_p(size) &&
-		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
+		size <= SLUB_MAX_SIZE && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
 
 		if (!s)
diff --git a/mm/slub.c b/mm/slub.c
index 0280eee..43a0c53 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2475,7 +2475,7 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache kmalloc_caches[PAGE_SHIFT + 1] __cacheline_aligned;
+struct kmem_cache kmalloc_caches[SLUB_PAGE_SHIFT] __cacheline_aligned;
 EXPORT_SYMBOL(kmalloc_caches);
 
 static int __init setup_slub_min_order(char *str)
@@ -2537,7 +2537,7 @@ panic:
 }
 
 #ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_caches_dma[PAGE_SHIFT + 1];
+static struct kmem_cache *kmalloc_caches_dma[SLUB_PAGE_SHIFT];
 
 static void sysfs_add_func(struct work_struct *w)
 {
@@ -2658,7 +2658,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLUB_MAX_SIZE))
 		return kmalloc_large(size, flags);
 
 	s = get_slab(size, flags);
@@ -2686,7 +2686,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLUB_MAX_SIZE))
 		return kmalloc_large_node(size, flags, node);
 
 	s = get_slab(size, flags);
@@ -2986,7 +2986,7 @@ void __init kmem_cache_init(void)
 		caches++;
 	}
 
-	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++) {
+	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
 		create_kmalloc_cache(&kmalloc_caches[i],
 			"kmalloc", 1 << i, GFP_KERNEL);
 		caches++;
@@ -3023,7 +3023,7 @@ void __init kmem_cache_init(void)
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
-	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++)
+	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++)
 		kmalloc_caches[i]. name =
 			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
 
@@ -3223,7 +3223,7 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
 
-	if (unlikely(size > PAGE_SIZE))
+	if (unlikely(size > SLUB_MAX_SIZE))
 		return kmalloc_large(size, gfpflags);
 
 	s = get_slab(size, gfpflags);
@@ -3239,7 +3239,7 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
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
