Date: Wed, 28 Feb 2007 17:06:19 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] SLUB The unqueued slab allocator V3
In-Reply-To: <20070228.140022.74750199.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0702281656450.1488@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702281120110.27828@schroedinger.engr.sgi.com>
 <20070228.140022.74750199.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Feb 2007, David Miller wrote:

> Maybe if you managed your individual changes in GIT or similar
> this could be debugged very quickly. :-)

I think once things calm down and the changes become smaller its going 
to be easier. Likely the case with after V4.

> Meanwhile I noticed that your alignment algorithm is different
> than SLAB's.  And I think this is important for the page table
> SLABs that some platforms use.

Ok.
 
> No matter what flags are specified, SLAB gives at least the
> passed in alignment specified in kmem_cache_create().  That
> logic in slab is here:
> 
> 	/* 3) caller mandated alignment */
> 	if (ralign < align) {
> 		ralign = align;
> 	}

Hmmm... Right.
 
> Whereas SLUB uses the CPU cacheline size when the MUSTALIGN
> flag is set.  Architectures do things like:
> 
> 	pgtable_cache = kmem_cache_create("pgtable_cache",
> 					  PAGE_SIZE, PAGE_SIZE,
> 					  SLAB_HWCACHE_ALIGN |
> 					  SLAB_MUST_HWCACHE_ALIGN,
> 					  zero_ctor,
> 					  NULL);
> 
> to get a PAGE_SIZE aligned slab, SLUB doesn't give the same
> behavior SLAB does in this case.

SLUB only supports this by passing through allocations to the page 
allocator since it does not maintain queues. So the above will cause the 
pgtable_cache to use the caches of the page allocator. The queueing effect 
that you get from SLAB is not present in SLUB since it does not provide 
them. If SLUB is to be used this way then we need to have higher order 
page sizes and allocate chunks from the higher order page for the 
pgtable_cache.

There are other ways of doing it. IA64 f.e. uses a linked list to 
accomplish the same avoiding SLAB overhead.

> Arguably SLAB_HWCACHE_ALIGN and SLAB_MUST_HWCACHE_ALIGN should
> not be set here, but SLUBs change in semantics in this area
> could cause similar grief in other areas, an audit is probably
> in order.
> 
> The above example was from sparc64, but x86 does the same thing
> as probably do other platforms which use SLAB for pagetables.

Maybe this will address these concerns?

Index: linux-2.6.21-rc2/mm/slub.c
===================================================================
--- linux-2.6.21-rc2.orig/mm/slub.c	2007-02-28 16:54:23.000000000 -0800
+++ linux-2.6.21-rc2/mm/slub.c	2007-02-28 17:03:54.000000000 -0800
@@ -1229,8 +1229,10 @@ static int calculate_order(int size)
 static unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align)
 {
-	if (flags & (SLAB_MUST_HWCACHE_ALIGN|SLAB_HWCACHE_ALIGN))
+	if (flags & SLAB_HWCACHE_ALIGN)
 		return L1_CACHE_BYTES;
+	if (flags & SLAB_MUST_HWCACHE_ALIGN)
+		return max(align, (unsigned long)L1_CACHE_BYTES);
 
 	if (align < ARCH_SLAB_MINALIGN)
 		return ARCH_SLAB_MINALIGN;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
