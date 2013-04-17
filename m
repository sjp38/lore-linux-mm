Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 8DA2C6B00B2
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 14:05:28 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 17 Apr 2013 14:05:27 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id CF3B038C805C
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 14:05:24 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3HI5Oet289888
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 14:05:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3HI5Eae016195
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 15:05:15 -0300
Date: Wed, 17 Apr 2013 11:05:12 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv9 1/8] zsmalloc: add to mm/
Message-ID: <20130417180512.GC29947@medulla>
References: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1365617940-21623-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130414004322.GB1330@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130414004322.GB1330@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Sun, Apr 14, 2013 at 01:43:22AM +0100, Mel Gorman wrote:
> I no longer remember any of the previous z* discussions, including my
> own review and I was not online as I wrote this. I may repeat myself,
> contradict myself or rehash topics that were visited already and have
> been concluded. If I do any of that then sorry.

Great!  That means you'll have the most fresh perspective :)

I very much appreciate you taking your valuable time to understand and review
the code!

> 
> On Wed, Apr 10, 2013 at 01:18:53PM -0500, Seth Jennings wrote:
> > <SNIP>
> >
> > Also, zsmalloc allows objects to span page boundaries within the
> > zspage.  This allows for lower fragmentation than could be had
> > with the kernel slab allocator for objects between PAGE_SIZE/2
> > and PAGE_SIZE. 
> 
> Be aware that this reduces *internal* fragmentation but not necessarily
> external fragmentation. If a page portion cannot be freed for some reason
> then the entire page cannot be freed. If it is possible for a page fragment
> to be pinned then it is potentially a serious problem because the zswap
> portion of memory does not necessarily shrink forever. This means that a
> large process exiting that had been pushed to swap may not free any
> physical memory due to fragmentation within zsmalloc which might be a
> big surprise to the OOM killer.

Yes.  This has been something Dan mentioned as well.  This design element of
zsmalloc was derived from 1) slab design and 2) need to efficiently store large
objects.  The kernel SLAB/SLUB allocators have that same issue for, say, a kmem
cache with objects 3k in size.  A high-order page allocation is needed to back
the slab and even if there is only one object in the slab none of the pages can
be freed.

But this does point out the desired behavior of both LRU and process locality
in the compressed pool pages so that when a process exits, the invalidating of
the unshared zpages frees entire underlying pages from the compressed pool.

> 
> Even assuming though that a page can be forcibly evicted then moving data
> from zswap to disk has two strange effects.
> 
> 1. Reclaiming a single page requires an unpredictable amount of
>    page frames to be uncompressed and written to swap. Swapout times may
>    vary considerably as a result.

Yes, this is less than ideal and stems from the fact that zswap has LRU
knowledge but does not have knowledge of how zpages are arranged in compressed
pool pages.  This is something Dan and I have been discussing: 1) should the
job of reclaim be done by the zsmalloc user or zsmalloc itself 2) what are the
API ramifications of each option.

> 
> 2. It make cause aging inversions. If an old page fragment and new page
>    fragment are co-located then a new page can be written to swap before
>    there was an opportunity to refault it.
> 
> Both yield unpredictable performance characteristics for zswap.
> zbud conceptually (I can't remember any of the code details) suffers from
> internal fragmentation wastage but it would have more predictable performance
> characterisics. The worst of the fragmentaiton problems may be mitigated
> if a zero-filled page was special cased (if it hasn't already). If the
> compressed page cannot fit into PAGE_SIZE/2 then too bad, dump it to swap.
> It still would suffer from an age inversion but at worst it only affects
> one other swap page so at least it's bound to a known value.
> 
> I think I said it before but I worry that testing has seen the ideal
> behaviour for zsmalloc because it is based on kernel compiles which has
> data that compresses easily and processes that are relatively short lived.
> 
> I recognise that a lot of work has gone into zsmalloc and that it exists
> for a reason. I'm not going to make it a blocker for merging because frankly
> I'm not familiar enough with zbud to know it actually can be used by zswap
> and my performance characterisic objections have not been proven. However,
> my gut feeling says that the allocators should have had compatible APIs
> or an operations struct with a default to zbud for predictable performance
> characterisics (assuming zbud is not completely broken of course).
> 
> Furthermore if any of this is accurate then the limitations of the
> allocator should be described in the changelog (copy and paste this if
> you wish). When/if this gets deployed and a vendor is handed a bug about
> unpredictable performance characteristics of zswap then there is a remote
> chance they learn why.
> 
> > With the kernel slab allocator, if a page compresses
> > to 60% of it original size, the memory savings gained through
> > compression is lost in fragmentation because another object of
> > the same size can't be stored in the leftover space.
> > 
> > This ability to span pages results in zsmalloc allocations not being
> > directly addressable by the user.  The user is given an
> > non-dereferencable handle in response to an allocation request.
> > That handle must be mapped, using zs_map_object(), which returns
> > a pointer to the mapped region that can be used.  The mapping is
> > necessary since the object data may reside in two different
> > noncontigious pages.
> > 
> > zsmalloc fulfills the allocation needs for zram and zswap.
> > 
> > Acked-by: Nitin Gupta <ngupta@vflare.org>
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > ---
> >  include/linux/zsmalloc.h |   56 +++
> >  mm/Kconfig               |   24 +
> >  mm/Makefile              |    1 +
> >  mm/zsmalloc.c            | 1117 ++++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 1198 insertions(+)
> >  create mode 100644 include/linux/zsmalloc.h
> >  create mode 100644 mm/zsmalloc.c
> > 
> > diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> > new file mode 100644
> > index 0000000..398dae3
> > --- /dev/null
> > +++ b/include/linux/zsmalloc.h
> > @@ -0,0 +1,56 @@
> > +/*
> > + * zsmalloc memory allocator
> > + *
> > + * Copyright (C) 2011  Nitin Gupta
> > + *
> 
> git blame indicates there are more people than Nitin involved although
> the bulk of the code does appear to be his.
> 
> > + * This code is released using a dual license strategy: BSD/GPL
> > + * You can choose the license that better fits your requirements.
> > + *
> > + * Released under the terms of 3-clause BSD License
> > + * Released under the terms of GNU General Public License Version 2.0
> > + */
> > +
> > +#ifndef _ZS_MALLOC_H_
> > +#define _ZS_MALLOC_H_
> > +
> > +#include <linux/types.h>
> > +#include <linux/mm_types.h>
> > +
> > +/*
> > + * zsmalloc mapping modes
> > + *
> > + * NOTE: These only make a difference when a mapped object spans pages.
> > + *       They also have no effect when PGTABLE_MAPPING is selected.
> > +*/
> > +enum zs_mapmode {
> > +	ZS_MM_RW, /* normal read-write mapping */
> > +	ZS_MM_RO, /* read-only (no copy-out at unmap time) */
> > +	ZS_MM_WO /* write-only (no copy-in at map time) */
> > +	/*
> > +	 * NOTE: ZS_MM_WO should only be used for initializing new
> > +	 * (uninitialized) allocations.  Partial writes to already
> > +	 * initialized allocations should use ZS_MM_RW to preserve the
> > +	 * existing data.
> > +	 */
> > +};
> > +
> > +struct zs_ops {
> > +	struct page * (*alloc)(gfp_t);
> > +	void (*free)(struct page *);
> > +};
> > +
> 
> 
> Hmm, zs_ops deserves a comment! It's quite curious because the zsmalloc
> implies it is an allocator but the user of zsmalloc is expected to allocate
> and free the physical memory. That looks like a layering inversion.

Yes, it might be.  It was added so that zswap can enforce the pool limit
accurately.  There might be a better way (i.e. a zsmalloc_pool_size()
function).

> 
> I suspect the motivation is because only the user of zsmalloc can sensibly
> decide what the pool size should be, particularly if it's dynamically
> sized. If this is the case then a more appropriate callback interface
> may be to inform it when the physical page pool shrinks (instead of free)
> and a request to increase the size of the pool by one page (instead of alloc.

That would work too :)

> 
> > +struct zs_pool;
> > +
> > +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops);
> > +void zs_destroy_pool(struct zs_pool *pool);
> > +
> > +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
> > +void zs_free(struct zs_pool *pool, unsigned long obj);
> > +
> > +void *zs_map_object(struct zs_pool *pool, unsigned long handle,
> > +			enum zs_mapmode mm);
> > +void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
> > +
> > +u64 zs_get_total_size_bytes(struct zs_pool *pool);
> > +
> > +#endif
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 3bea74f..aa054fc 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -471,3 +471,27 @@ config FRONTSWAP
> >  	  and swap data is stored as normal on the matching swap device.
> >  
> >  	  If unsure, say Y to enable frontswap.
> > +
> > +config ZSMALLOC
> > +	tristate "Memory allocator for compressed pages"
> > +	default n
> > +	help
> > +	  zsmalloc is a slab-based memory allocator designed to store
> > +	  compressed RAM pages.  zsmalloc uses virtual memory mapping
> > +	  in order to reduce fragmentation.  However, this results in a
> > +	  non-standard allocator interface where a handle, not a pointer, is
> > +	  returned by an alloc().  This handle must be mapped in order to
> > +	  access the allocated space.
> > +
> > +config PGTABLE_MAPPING
> > +	bool "Use page table mapping to access object in zsmalloc"
> > +	depends on ZSMALLOC
> > +	help
> > +	  By default, zsmalloc uses a copy-based object mapping method to
> > +	  access allocations that span two pages. However, if a particular
> > +	  architecture (ex, ARM) performs VM mapping faster than copying,
> > +	  then you should select this. This causes zsmalloc to use page table
> > +	  mapping rather than copying for object mapping.
> > +
> > +	  You can check speed with zsmalloc benchmark[1].
> > +	  [1] https://github.com/spartacus06/zsmalloc
> 
> Should PGTABLE_MAPPING be selected by the architecture instead of the
> user configuring the kernel?

This has seen some thrashing lately.  I'd perfer it be selected automatically by
arch, but I think that approach had some objections that I'm not recalling at
the time. Minchan might know.

> 
> > diff --git a/mm/Makefile b/mm/Makefile
> > index 3a46287..0f6ef0a 100644
> > --- a/mm/Makefile
> > +++ b/mm/Makefile
> > @@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
> >  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
> >  obj-$(CONFIG_CLEANCACHE) += cleancache.o
> >  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
> > +obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > new file mode 100644
> > index 0000000..adaeee5
> > --- /dev/null
> > +++ b/mm/zsmalloc.c
> > @@ -0,0 +1,1117 @@
> > +/*
> > + * zsmalloc memory allocator
> > + *
> > + * Copyright (C) 2011  Nitin Gupta
> > + *
> > + * This code is released using a dual license strategy: BSD/GPL
> > + * You can choose the license that better fits your requirements.
> > + *
> > + * Released under the terms of 3-clause BSD License
> > + * Released under the terms of GNU General Public License Version 2.0
> > + */
> > +
> > +
> > +/*
> > + * This allocator is designed for use with zcache and zram. Thus, the
> > + * allocator is supposed to work well under low memory conditions. In
> > + * particular, it never attempts higher order page allocation which is
> > + * very likely to fail under memory pressure. On the other hand, if we
> > + * just use single (0-order) pages, it would suffer from very high
> > + * fragmentation -- any object of size PAGE_SIZE/2 or larger would occupy
> > + * an entire page. This was one of the major issues with its predecessor
> > + * (xvmalloc).
> > + *
> > + * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
> > + * and links them together using various 'struct page' fields. These linked
> > + * pages act as a single higher-order page i.e. an object can span 0-order
> > + * page boundaries. The code refers to these linked pages as a single entity
> > + * called zspage.
> > + *
> > + * For simplicity, zsmalloc can only allocate objects of size up to PAGE_SIZE
> > + * since this satisfies the requirements of all its current users (in the
> > + * worst case, page is incompressible and is thus stored "as-is" i.e. in
> > + * uncompressed form). For allocation requests larger than this size, failure
> > + * is returned (see zs_malloc).
> > + *
> > + * Additionally, zs_malloc() does not return a dereferenceable pointer.
> > + * Instead, it returns an opaque handle (unsigned long) which encodes actual
> 
> There are places where it's assumed that an unsigned long is an address
> that can be used. It's a nit-pick but it might be worth explicitly declaring
> an opaque type that just happens to be unsigned long.

Ok.

> 
> > + * location of the allocated object. The reason for this indirection is that
> > + * zsmalloc does not keep zspages permanently mapped since that would cause
> > + * issues on 32-bit systems where the VA region for kernel space mappings
> > + * is very small. So, before using the allocating memory, the object has to
> > + * be mapped using zs_map_object() to get a usable pointer and subsequently
> > + * unmapped using zs_unmap_object().
> > + *
> > + * Following is how we use various fields and flags of underlying
> > + * struct page(s) to form a zspage.
> > + *
> > + * Usage of struct page fields:
> > + *	page->first_page: points to the first component (0-order) page
> > + *	page->index (union with page->freelist): offset of the first object
> > + *		starting in this page. For the first page, this is
> > + *		always 0, so we use this field (aka freelist) to point
> > + *		to the first free object in zspage.
> > + *	page->lru: links together all component pages (except the first page)
> > + *		of a zspage
> > + *
> > + *	For _first_ page only:
> > + *
> > + *	page->private (union with page->first_page): refers to the
> > + *		component page after the first page
> > + *	page->freelist: points to the first free object in zspage.
> > + *		Free objects are linked together using in-place
> > + *		metadata.
> > + *	page->lru: links together first pages of various zspages.
> > + *		Basically forming list of zspages in a fullness group.
> > + *	page->mapping: class index and fullness group of the zspage
> > + *
> 
> Heh, that's some packing.

Yes, yes it is.

> 
> > + * Usage of struct page flags:
> > + *	PG_private: identifies the first component page
> > + *	PG_private2: identifies the last component page
> > + *
> > + */
> > +
> > +#include <linux/module.h>
> > +#include <linux/kernel.h>
> > +#include <linux/bitops.h>
> > +#include <linux/errno.h>
> > +#include <linux/highmem.h>
> > +#include <linux/init.h>
> > +#include <linux/string.h>
> > +#include <linux/slab.h>
> > +#include <asm/tlbflush.h>
> > +#include <asm/pgtable.h>
> > +#include <linux/cpumask.h>
> > +#include <linux/cpu.h>
> > +#include <linux/vmalloc.h>
> > +#include <linux/hardirq.h>
> > +#include <linux/spinlock.h>
> > +#include <linux/types.h>
> > +
> > +#include <linux/zsmalloc.h>
> > +
> > +/*
> > + * This must be power of 2 and greater than of equal to sizeof(link_free).
> > + * These two conditions ensure that any 'struct link_free' itself doesn't
> > + * span more than 1 page which avoids complex case of mapping 2 pages simply
> > + * to restore link_free pointer values.
> > + */
> > +#define ZS_ALIGN		8
> > +
> > +/*
> > + * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
> > + * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
> > + */
> > +#define ZS_MAX_ZSPAGE_ORDER 2
> > +#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
> > +
> > +/*
> > + * Object location (<PFN>, <obj_idx>) is encoded as
> > + * as single (unsigned long) handle value.
> > + *
> > + * Note that object index <obj_idx> is relative to system
> > + * page <PFN> it is stored in, so for each sub-page belonging
> > + * to a zspage, obj_idx starts with 0.
> > + *
> > + * This is made more complicated by various memory models and PAE.
> > + */
> > +
> > +#ifndef MAX_PHYSMEM_BITS
> > +#ifdef CONFIG_HIGHMEM64G
> > +#define MAX_PHYSMEM_BITS 36
> > +#else /* !CONFIG_HIGHMEM64G */
> > +/*
> > + * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
> > + * be PAGE_SHIFT
> > + */
> > +#define MAX_PHYSMEM_BITS BITS_PER_LONG
> > +#endif
> > +#endif
> > +#define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
> > +#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
> > +#define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
> > +
> > +#define MAX(a, b) ((a) >= (b) ? (a) : (b))
> > +/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
> > +#define ZS_MIN_ALLOC_SIZE \
> > +	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
> > +#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
> > +
> > +/*
> > + * On systems with 4K page size, this gives 254 size classes! There is a
> > + * trader-off here:
> > + *  - Large number of size classes is potentially wasteful as free page are
> > + *    spread across these classes
> > + *  - Small number of size classes causes large internal fragmentation
> > + *  - Probably its better to use specific size classes (empirically
> > + *    determined). NOTE: all those class sizes must be set as multiple of
> > + *    ZS_ALIGN to make sure link_free itself never has to span 2 pages.
> > + *
> > + *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
> > + *  (reason above)
> > + */
> > +#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
> > +#define ZS_SIZE_CLASSES		((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
> > +					ZS_SIZE_CLASS_DELTA + 1)
> > +
> > +/*
> > + * We do not maintain any list for completely empty or full pages
> > + */
> > +enum fullness_group {
> > +	ZS_ALMOST_FULL,
> > +	ZS_ALMOST_EMPTY,
> > +	_ZS_NR_FULLNESS_GROUPS,
> > +
> > +	ZS_EMPTY,
> > +	ZS_FULL
> > +};
> 
> Ok, I see that you then use the fullness class to try and pack new
> allocations into "almost full" zspages. This could mean that a zspage
> spans an unpredictable number of physical pages but no idea if that's a
> problem or not.
> 
> > +
> > +/*
> > + * We assign a page to ZS_ALMOST_EMPTY fullness group when:
> > + *	n <= N / f, where
> > + * n = number of allocated objects
> > + * N = total number of objects zspage can store
> > + * f = 1/fullness_threshold_frac
> > + *
> > + * Similarly, we assign zspage to:
> > + *	ZS_ALMOST_FULL	when n > N / f
> > + *	ZS_EMPTY	when n == 0
> > + *	ZS_FULL		when n == N
> > + *
> > + * (see: fix_fullness_group())
> > + */
> > +static const int fullness_threshold_frac = 4;
> > +
> > +struct size_class {
> > +	/*
> > +	 * Size of objects stored in this class. Must be multiple
> > +	 * of ZS_ALIGN.
> > +	 */
> > +	int size;
> > +	unsigned int index;
> > +
> 
> You can drop index and use a lookup that calculates it as
> 
> index = size_class - zs_pool->size_class;

Clever :)

> 
> > +	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> > +	int pages_per_zspage;
> > +
> > +	spinlock_t lock;
> > +
> > +	/* stats */
> > +	u64 pages_allocated;
> > +
> > +	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> 
> The fact that you don't track full pages is curious. It may imply that
> it's not possible to forcibly reclaim a full zspage or maybe it's just
> not implemented.

Yes, that is the reason we don't track them.  If evict functionally were added
to zsmalloc, then we'd have to start tracking them.

> 
> I initially worrised that ZS_EMPTY pages leaked but it looks like such
> pages are always freed
> 
> > +};
> > +
> > +/*
> > + * Placed within free objects to form a singly linked list.
> > + * For every zspage, first_page->freelist gives head of this list.
> > + *
> > + * This must be power of 2 and less than or equal to ZS_ALIGN
> > + */
> > +struct link_free {
> > +	/* Handle of next free chunk (encodes <PFN, obj_idx>) */
> > +	void *next;
> > +};
> > +
> > +struct zs_pool {
> > +	struct size_class size_class[ZS_SIZE_CLASSES];
> > +
> > +	struct zs_ops *ops;
> > +};
> > +
> > +/*
> > + * A zspage's class index and fullness group
> > + * are encoded in its (first)page->mapping
> > + */
> > +#define CLASS_IDX_BITS	28
> > +#define FULLNESS_BITS	4
> > +#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
> > +#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
> > +
> > +struct mapping_area {
> > +#ifdef CONFIG_PGTABLE_MAPPING
> > +	struct vm_struct *vm; /* vm area for mapping object that span pages */
> > +#else
> > +	char *vm_buf; /* copy buffer for objects that span pages */
> > +#endif
> > +	char *vm_addr; /* address of kmap_atomic()'ed pages */
> > +	enum zs_mapmode vm_mm; /* mapping mode */
> > +};
> > +
> > +/* default page alloc/free ops */
> > +struct page *zs_alloc_page(gfp_t flags)
> > +{
> > +	return alloc_page(flags);
> > +}
> > +
> > +void zs_free_page(struct page *page)
> > +{
> > +	__free_page(page);
> > +}
> > +
> > +struct zs_ops zs_default_ops = {
> > +	.alloc = zs_alloc_page,
> > +	.free = zs_free_page
> > +};
> > +
> > +/* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
> > +static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
> > +
> > +static int is_first_page(struct page *page)
> > +{
> > +	return PagePrivate(page);
> > +}
> > +
> > +static int is_last_page(struct page *page)
> > +{
> > +	return PagePrivate2(page);
> > +}
> > +
> > +static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
> > +				enum fullness_group *fullness)
> > +{
> > +	unsigned long m;
> > +	BUG_ON(!is_first_page(page));
> > +
> > +	m = (unsigned long)page->mapping;
> > +	*fullness = m & FULLNESS_MASK;
> > +	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
> > +}
> > +
> > +static void set_zspage_mapping(struct page *page, unsigned int class_idx,
> > +				enum fullness_group fullness)
> > +{
> > +	unsigned long m;
> > +	BUG_ON(!is_first_page(page));
> > +
> > +	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
> > +			(fullness & FULLNESS_MASK);
> > +	page->mapping = (struct address_space *)m;
> > +}
> > +
> > +/*
> > + * zsmalloc divides the pool into various size classes where each
> > + * class maintains a list of zspages where each zspage is divided
> > + * into equal sized chunks. Each allocation falls into one of these
> > + * classes depending on its size. This function returns index of the
> > + * size class which has chunk size big enough to hold the give size.
> > + */
> > +static int get_size_class_index(int size)
> > +{
> > +	int idx = 0;
> > +
> > +	if (likely(size > ZS_MIN_ALLOC_SIZE))
> > +		idx = DIV_ROUND_UP(size - ZS_MIN_ALLOC_SIZE,
> > +				ZS_SIZE_CLASS_DELTA);
> > +
> > +	return idx;
> > +}
> > +
> > +/*
> > + * For each size class, zspages are divided into different groups
> > + * depending on how "full" they are. This was done so that we could
> > + * easily find empty or nearly empty zspages when we try to shrink
> > + * the pool (not yet implemented). This function returns fullness
> > + * status of the given page.
> > + */
> 
> We can't forcibly shrink this thing? I'll be curious to see what happens
> when zswap is full then.
> 
> > +static enum fullness_group get_fullness_group(struct page *page,
> > +					struct size_class *class)
> > +{
> > +	int inuse, max_objects;
> > +	enum fullness_group fg;
> > +	BUG_ON(!is_first_page(page));
> > +
> > +	inuse = page->inuse;
> > +	max_objects = class->pages_per_zspage * PAGE_SIZE / class->size;
> > +
> 
> As class->size must be a multiple of ZS_ALIGN which is a power-of-two
> then this calculation could be done as bit shifts if class->size was a
> shift instead of a size. Not that important.

Would be cleaner that way.

> 
> > +	if (inuse == 0)
> > +		fg = ZS_EMPTY;
> > +	else if (inuse == max_objects)
> > +		fg = ZS_FULL;
> > +	else if (inuse <= max_objects / fullness_threshold_frac)
> > +		fg = ZS_ALMOST_EMPTY;
> > +	else
> > +		fg = ZS_ALMOST_FULL;
> > +
> > +	return fg;
> > +}
> > +
> > +/*
> > + * Each size class maintains various freelists and zspages are assigned
> > + * to one of these freelists based on the number of live objects they
> > + * have. This functions inserts the given zspage into the freelist
> > + * identified by <class, fullness_group>.
> > + */
> > +static void insert_zspage(struct page *page, struct size_class *class,
> > +				enum fullness_group fullness)
> > +{
> > +	struct page **head;
> > +
> > +	BUG_ON(!is_first_page(page));
> > +
> > +	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
> > +		return;
> > +
> > +	head = &class->fullness_list[fullness];
> > +	if (*head)
> > +		list_add_tail(&page->lru, &(*head)->lru);
> > +
> > +	*head = page;
> > +}
> > +
> > +/*
> > + * This function removes the given zspage from the freelist identified
> > + * by <class, fullness_group>.
> > + */
> > +static void remove_zspage(struct page *page, struct size_class *class,
> > +				enum fullness_group fullness)
> > +{
> > +	struct page **head;
> > +
> > +	BUG_ON(!is_first_page(page));
> > +
> > +	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
> > +		return;
> > +
> > +	head = &class->fullness_list[fullness];
> > +	BUG_ON(!*head);
> > +	if (list_empty(&(*head)->lru))
> > +		*head = NULL;
> > +	else if (*head == page)
> > +		*head = (struct page *)list_entry((*head)->lru.next,
> > +					struct page, lru);
> > +
> > +	list_del_init(&page->lru);
> > +}
> > +
> > +/*
> > + * Each size class maintains zspages in different fullness groups depending
> > + * on the number of live objects they contain. When allocating or freeing
> > + * objects, the fullness status of the page can change, say, from ALMOST_FULL
> > + * to ALMOST_EMPTY when freeing an object. This function checks if such
> > + * a status change has occurred for the given page and accordingly moves the
> > + * page from the freelist of the old fullness group to that of the new
> > + * fullness group.
> > + */
> > +static enum fullness_group fix_fullness_group(struct zs_pool *pool,
> > +						struct page *page)
> > +{
> > +	int class_idx;
> > +	struct size_class *class;
> > +	enum fullness_group currfg, newfg;
> > +
> > +	BUG_ON(!is_first_page(page));
> > +
> > +	get_zspage_mapping(page, &class_idx, &currfg);
> > +	class = &pool->size_class[class_idx];
> > +	newfg = get_fullness_group(page, class);
> > +	if (newfg == currfg)
> > +		goto out;
> > +
> > +	remove_zspage(page, class, currfg);
> > +	insert_zspage(page, class, newfg);
> > +	set_zspage_mapping(page, class_idx, newfg);
> > +
> > +out:
> > +	return newfg;
> > +}
> > +
> > +/*
> > + * We have to decide on how many pages to link together
> > + * to form a zspage for each size class. This is important
> > + * to reduce wastage due to unusable space left at end of
> > + * each zspage which is given as:
> > + *	wastage = Zp - Zp % size_class
> > + * where Zp = zspage size = k * PAGE_SIZE where k = 1, 2, ...
> > + *
> > + * For example, for size class of 3/8 * PAGE_SIZE, we should
> > + * link together 3 PAGE_SIZE sized pages to form a zspage
> > + * since then we can perfectly fit in 8 such objects.
> > + */
> > +static int get_pages_per_zspage(int class_size)
> > +{
> > +	int i, max_usedpc = 0;
> > +	/* zspage order which gives maximum used size per KB */
> > +	int max_usedpc_order = 1;
> > +
> > +	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
> > +		int zspage_size;
> > +		int waste, usedpc;
> > +
> > +		zspage_size = i * PAGE_SIZE;
> > +		waste = zspage_size % class_size;
> > +		usedpc = (zspage_size - waste) * 100 / zspage_size;
> > +
> > +		if (usedpc > max_usedpc) {
> > +			max_usedpc = usedpc;
> > +			max_usedpc_order = i;
> > +		}
> > +	}
> > +
> > +	return max_usedpc_order;
> > +}
> > +
> > +/*
> > + * A single 'zspage' is composed of many system pages which are
> > + * linked together using fields in struct page. This function finds
> > + * the first/head page, given any component page of a zspage.
> > + */
> > +static struct page *get_first_page(struct page *page)
> > +{
> > +	if (is_first_page(page))
> > +		return page;
> > +	else
> > +		return page->first_page;
> > +}
> > +
> > +static struct page *get_next_page(struct page *page)
> > +{
> > +	struct page *next;
> > +
> > +	if (is_last_page(page))
> > +		next = NULL;
> > +	else if (is_first_page(page))
> > +		next = (struct page *)page->private;
> > +	else
> > +		next = list_entry(page->lru.next, struct page, lru);
> > +
> > +	return next;
> > +}
> > +
> > +/* Encode <page, obj_idx> as a single handle value */
> > +static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
> > +{
> > +	unsigned long handle;
> > +
> > +	if (!page) {
> > +		BUG_ON(obj_idx);
> > +		return NULL;
> > +	}
> > +
> > +	handle = page_to_pfn(page) << OBJ_INDEX_BITS;
> > +	handle |= (obj_idx & OBJ_INDEX_MASK);
> > +
> > +	return (void *)handle;
> > +}
> > +
> > +/* Decode <page, obj_idx> pair from the given object handle */
> > +static void obj_handle_to_location(unsigned long handle, struct page **page,
> > +				unsigned long *obj_idx)
> > +{
> > +	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
> > +	*obj_idx = handle & OBJ_INDEX_MASK;
> > +}
> > +
> > +static unsigned long obj_idx_to_offset(struct page *page,
> > +				unsigned long obj_idx, int class_size)
> > +{
> > +	unsigned long off = 0;
> > +
> > +	if (!is_first_page(page))
> > +		off = page->index;
> > +
> > +	return off + obj_idx * class_size;
> > +}
> > +
> > +static void reset_page(struct page *page)
> > +{
> > +	clear_bit(PG_private, &page->flags);
> > +	clear_bit(PG_private_2, &page->flags);
> > +	set_page_private(page, 0);
> > +	page->mapping = NULL;
> > +	page->freelist = NULL;
> > +	page_mapcount_reset(page);
> > +}
> > +
> > +static void free_zspage(struct zs_ops *ops, struct page *first_page)
> > +{
> > +	struct page *nextp, *tmp, *head_extra;
> > +
> > +	BUG_ON(!is_first_page(first_page));
> > +	BUG_ON(first_page->inuse);
> > +
> > +	head_extra = (struct page *)page_private(first_page);
> > +
> > +	reset_page(first_page);
> > +	ops->free(first_page);
> > +
> > +	/* zspage with only 1 system page */
> > +	if (!head_extra)
> > +		return;
> > +
> > +	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
> > +		list_del(&nextp->lru);
> > +		reset_page(nextp);
> > +		ops->free(nextp);
> > +	}
> > +	reset_page(head_extra);
> > +	ops->free(head_extra);
> > +}
> > +
> > +/* Initialize a newly allocated zspage */
> > +static void init_zspage(struct page *first_page, struct size_class *class)
> > +{
> > +	unsigned long off = 0;
> > +	struct page *page = first_page;
> > +
> > +	BUG_ON(!is_first_page(first_page));
> > +	while (page) {
> > +		struct page *next_page;
> > +		struct link_free *link;
> > +		unsigned int i, objs_on_page;
> > +
> > +		/*
> > +		 * page->index stores offset of first object starting
> > +		 * in the page. For the first page, this is always 0,
> > +		 * so we use first_page->index (aka ->freelist) to store
> > +		 * head of corresponding zspage's freelist.
> > +		 */
> > +		if (page != first_page)
> > +			page->index = off;
> > +
> > +		link = (struct link_free *)kmap_atomic(page) +
> > +						off / sizeof(*link);
> > +		objs_on_page = (PAGE_SIZE - off) / class->size;
> > +
> > +		for (i = 1; i <= objs_on_page; i++) {
> > +			off += class->size;
> > +			if (off < PAGE_SIZE) {
> > +				link->next = obj_location_to_handle(page, i);
> > +				link += class->size / sizeof(*link);
> > +			}
> > +		}
> > +
> > +		/*
> > +		 * We now come to the last (full or partial) object on this
> > +		 * page, which must point to the first object on the next
> > +		 * page (if present)
> > +		 */
> > +		next_page = get_next_page(page);
> > +		link->next = obj_location_to_handle(next_page, 0);
> > +		kunmap_atomic(link);
> > +		page = next_page;
> > +		off = (off + class->size) % PAGE_SIZE;
> > +	}
> > +}
> > +
> > +/*
> > + * Allocate a zspage for the given size class
> > + */
> > +static struct page *alloc_zspage(struct zs_ops *ops, struct size_class *class,
> > +				gfp_t flags)
> > +{
> > +	int i, error;
> > +	struct page *first_page = NULL, *uninitialized_var(prev_page);
> > +
> > +	/*
> > +	 * Allocate individual pages and link them together as:
> > +	 * 1. first page->private = first sub-page
> > +	 * 2. all sub-pages are linked together using page->lru
> > +	 * 3. each sub-page is linked to the first page using page->first_page
> > +	 *
> > +	 * For each size class, First/Head pages are linked together using
> > +	 * page->lru. Also, we set PG_private to identify the first page
> > +	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
> > +	 * identify the last page.
> > +	 */
> > +	error = -ENOMEM;
> > +	for (i = 0; i < class->pages_per_zspage; i++) {
> > +		struct page *page;
> > +
> > +		page = ops->alloc(flags);
> > +		if (!page)
> > +			goto cleanup;
> > +
> 
> After this point, error is guaranteed to be set to 0. It looks like the
> free_zspage code at cleanup: is necessary. If we goto cleanup from here,
> first_page is NULL and after here error is always 0.

I have to say, I'm not following here.  error is init'ed in -ENOMEM before the
for loop and is only set to 0 outside the look if each page allocation succeed.

I'm not clear on what optimization you are suggesting.

> 
> > +		INIT_LIST_HEAD(&page->lru);
> > +		if (i == 0) {	/* first page */
> > +			SetPagePrivate(page);
> > +			set_page_private(page, 0);
> > +			first_page = page;
> > +			first_page->inuse = 0;
> > +		}
> > +		if (i == 1)
> > +			first_page->private = (unsigned long)page;
> > +		if (i >= 1)
> > +			page->first_page = first_page;
> > +		if (i >= 2)
> > +			list_add(&page->lru, &prev_page->lru);
> > +		if (i == class->pages_per_zspage - 1)	/* last page */
> > +			SetPagePrivate2(page);
> > +		prev_page = page;
> > +	}
> > +
> > +	init_zspage(first_page, class);
> > +
> > +	first_page->freelist = obj_location_to_handle(first_page, 0);
> > +
> > +	error = 0; /* Success */
> > +
> > +cleanup:
> > +	if (unlikely(error) && first_page) {
> > +		free_zspage(ops, first_page);
> > +		first_page = NULL;
> > +	}
> > +
> > +	return first_page;
> > +}
> > +
> > +static struct page *find_get_zspage(struct size_class *class)
> > +{
> > +	int i;
> > +	struct page *page;
> > +
> > +	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
> > +		page = class->fullness_list[i];
> > +		if (page)
> > +			break;
> > +	}
> > +
> > +	return page;
> > +}
> > +
> 
> Just an observation but the locking around this is for the entire size
> class and not for a given zspage. However, I also doubt that this lock
> is a heavily contended one. I'd expect any contention to be negligible
> in comparison to the cost of compressing a page.

Yes, the locking is coarse, but in practice, contention at higher levels in the
swap subsystem make this a non-issue (for better or worse).

> 
> > +#ifdef CONFIG_PGTABLE_MAPPING
> > +static inline int __zs_cpu_up(struct mapping_area *area)
> > +{
> > +	/*
> > +	 * Make sure we don't leak memory if a cpu UP notification
> > +	 * and zs_init() race and both call zs_cpu_up() on the same cpu
> > +	 */
> > +	if (area->vm)
> > +		return 0;
> > +	area->vm = alloc_vm_area(PAGE_SIZE * 2, NULL);
> > +	if (!area->vm)
> > +		return -ENOMEM;
> > +	return 0;
> > +}
> > +
> > +static inline void __zs_cpu_down(struct mapping_area *area)
> > +{
> > +	if (area->vm)
> > +		free_vm_area(area->vm);
> > +	area->vm = NULL;
> > +}
> > +
> > +static inline void *__zs_map_object(struct mapping_area *area,
> > +				struct page *pages[2], int off, int size)
> > +{
> > +	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));
> > +	area->vm_addr = area->vm->addr;
> > +	return area->vm_addr + off;
> > +}
> > +
> > +static inline void __zs_unmap_object(struct mapping_area *area,
> > +				struct page *pages[2], int off, int size)
> > +{
> > +	unsigned long addr = (unsigned long)area->vm_addr;
> > +	unsigned long end = addr + (PAGE_SIZE * 2);
> > +
> > +	flush_cache_vunmap(addr, end);
> > +	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
> > +	flush_tlb_kernel_range(addr, end);
> > +}
> > +
> > +#else /* CONFIG_PGTABLE_MAPPING*/
> > +
> > +static inline int __zs_cpu_up(struct mapping_area *area)
> > +{
> > +	/*
> > +	 * Make sure we don't leak memory if a cpu UP notification
> > +	 * and zs_init() race and both call zs_cpu_up() on the same cpu
> > +	 */
> > +	if (area->vm_buf)
> > +		return 0;
> > +	area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
> > +	if (!area->vm_buf)
> > +		return -ENOMEM;
> > +	return 0;
> > +}
> > +
> > +static inline void __zs_cpu_down(struct mapping_area *area)
> > +{
> > +	if (area->vm_buf)
> > +		free_page((unsigned long)area->vm_buf);
> > +	area->vm_buf = NULL;
> > +}
> > +
> > +static void *__zs_map_object(struct mapping_area *area,
> > +			struct page *pages[2], int off, int size)
> > +{
> > +	int sizes[2];
> > +	void *addr;
> > +	char *buf = area->vm_buf;
> > +
> > +	/* disable page faults to match kmap_atomic() return conditions */
> > +	pagefault_disable();
> > +
> > +	/* no read fastpath */
> > +	if (area->vm_mm == ZS_MM_WO)
> > +		goto out;
> > +
> > +	sizes[0] = PAGE_SIZE - off;
> > +	sizes[1] = size - sizes[0];
> > +
> > +	/* copy object to per-cpu buffer */
> > +	addr = kmap_atomic(pages[0]);
> > +	memcpy(buf, addr + off, sizes[0]);
> > +	kunmap_atomic(addr);
> > +	addr = kmap_atomic(pages[1]);
> > +	memcpy(buf + sizes[0], addr, sizes[1]);
> > +	kunmap_atomic(addr);
> > +out:
> > +	return area->vm_buf;
> > +}
> > +
> > +static void __zs_unmap_object(struct mapping_area *area,
> > +			struct page *pages[2], int off, int size)
> > +{
> > +	int sizes[2];
> > +	void *addr;
> > +	char *buf = area->vm_buf;
> > +
> > +	/* no write fastpath */
> > +	if (area->vm_mm == ZS_MM_RO)
> > +		goto out;
> > +
> > +	sizes[0] = PAGE_SIZE - off;
> > +	sizes[1] = size - sizes[0];
> > +
> > +	/* copy per-cpu buffer to object */
> > +	addr = kmap_atomic(pages[0]);
> > +	memcpy(addr + off, buf, sizes[0]);
> > +	kunmap_atomic(addr);
> > +	addr = kmap_atomic(pages[1]);
> > +	memcpy(addr, buf + sizes[0], sizes[1]);
> > +	kunmap_atomic(addr);
> > +
> > +out:
> > +	/* enable page faults to match kunmap_atomic() return conditions */
> > +	pagefault_enable();
> > +}
> > +
> > +#endif /* CONFIG_PGTABLE_MAPPING */
> > +
> > +static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
> > +				void *pcpu)
> > +{
> > +	int ret, cpu = (long)pcpu;
> > +	struct mapping_area *area;
> > +
> > +	switch (action) {
> > +	case CPU_UP_PREPARE:
> > +		area = &per_cpu(zs_map_area, cpu);
> > +		ret = __zs_cpu_up(area);
> > +		if (ret)
> > +			return notifier_from_errno(ret);
> > +		break;
> > +	case CPU_DEAD:
> > +	case CPU_UP_CANCELED:
> > +		area = &per_cpu(zs_map_area, cpu);
> > +		__zs_cpu_down(area);
> > +		break;
> > +	}
> > +
> > +	return NOTIFY_OK;
> > +}
> > +
> > +static struct notifier_block zs_cpu_nb = {
> > +	.notifier_call = zs_cpu_notifier
> > +};
> > +
> > +static void zs_exit(void)
> > +{
> > +	int cpu;
> > +
> > +	for_each_online_cpu(cpu)
> > +		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
> > +	unregister_cpu_notifier(&zs_cpu_nb);
> > +}
> > +
> > +static int zs_init(void)
> > +{
> > +	int cpu, ret;
> > +
> > +	register_cpu_notifier(&zs_cpu_nb);
> > +	for_each_online_cpu(cpu) {
> > +		ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
> > +		if (notifier_to_errno(ret))
> > +			goto fail;
> > +	}
> > +	return 0;
> > +fail:
> > +	zs_exit();
> > +	return notifier_to_errno(ret);
> > +}
> > +
> > +/**
> > + * zs_create_pool - Creates an allocation pool to work from.
> > + * @flags: allocation flags used to allocate pool metadata
> > + * @ops: allocation/free callbacks for expanding the pool
> > + *
> > + * This function must be called before anything when using
> > + * the zsmalloc allocator.
> > + *
> > + * On success, a pointer to the newly created pool is returned,
> > + * otherwise NULL.
> > + */
> > +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops)
> > +{
> > +	int i, ovhd_size;
> > +	struct zs_pool *pool;
> > +
> > +	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
> > +	pool = kzalloc(ovhd_size, flags);
> > +	if (!pool)
> > +		return NULL;
> > +
> > +	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
> > +		int size;
> > +		struct size_class *class;
> > +
> > +		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
> > +		if (size > ZS_MAX_ALLOC_SIZE)
> > +			size = ZS_MAX_ALLOC_SIZE;
> > +
> > +		class = &pool->size_class[i];
> > +		class->size = size;
> > +		class->index = i;
> > +		spin_lock_init(&class->lock);
> > +		class->pages_per_zspage = get_pages_per_zspage(size);
> > +
> > +	}
> > +
> > +	if (ops)
> > +		pool->ops = ops;
> > +	else
> > +		pool->ops = &zs_default_ops;
> > +
> > +	return pool;
> > +}
> > +EXPORT_SYMBOL_GPL(zs_create_pool);
> > +
> > +void zs_destroy_pool(struct zs_pool *pool)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
> > +		int fg;
> > +		struct size_class *class = &pool->size_class[i];
> > +
> > +		for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
> > +			if (class->fullness_list[fg]) {
> > +				pr_info("Freeing non-empty class with size "
> > +					"%db, fullness group %d\n",
> > +					class->size, fg);
> > +			}
> > +		}
> > +	}
> > +	kfree(pool);
> > +}
> > +EXPORT_SYMBOL_GPL(zs_destroy_pool);
> > +
> > +/**
> > + * zs_malloc - Allocate block of given size from pool.
> > + * @pool: pool to allocate from
> > + * @size: size of block to allocate
> > + *
> > + * On success, handle to the allocated object is returned,
> > + * otherwise 0.
> > + * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
> > + */
> > +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags)
> > +{
> > +	unsigned long obj;
> > +	struct link_free *link;
> > +	int class_idx;
> > +	struct size_class *class;
> > +
> > +	struct page *first_page, *m_page;
> > +	unsigned long m_objidx, m_offset;
> > +
> > +	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
> > +		return 0;
> > +
> > +	class_idx = get_size_class_index(size);
> > +	class = &pool->size_class[class_idx];
> > +	BUG_ON(class_idx != class->index);
> > +
> > +	spin_lock(&class->lock);
> > +	first_page = find_get_zspage(class);
> > +
> > +	if (!first_page) {
> > +		spin_unlock(&class->lock);
> > +		first_page = alloc_zspage(pool->ops, class, flags);
> > +		if (unlikely(!first_page))
> > +			return 0;
> > +
> > +		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
> > +		spin_lock(&class->lock);
> > +		class->pages_allocated += class->pages_per_zspage;
> > +	}
> > +
> > +	obj = (unsigned long)first_page->freelist;
> > +	obj_handle_to_location(obj, &m_page, &m_objidx);
> > +	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
> > +
> > +	link = (struct link_free *)kmap_atomic(m_page) +
> > +					m_offset / sizeof(*link);
> > +	first_page->freelist = link->next;
> > +	memset(link, POISON_INUSE, sizeof(*link));
> > +	kunmap_atomic(link);
> > +
> 
> Pity about the kmap_atomic but I guess it doesn't matter as the lock is
> serialising the entire size class anyway.

Yes.  This is really only to support highmem pages.  We could #ifdef
CONFIG_64BIT and not disable preemption for 64-bit but that makes for
inconsistent (and confusing) state on return.

> 
> > +	first_page->inuse++;
> > +	/* Now move the zspage to another fullness group, if required */
> > +	fix_fullness_group(pool, first_page);
> > +	spin_unlock(&class->lock);
> > +
> > +	return obj;
> > +}
> > +EXPORT_SYMBOL_GPL(zs_malloc);
> > +
> > +void zs_free(struct zs_pool *pool, unsigned long obj)
> > +{
> > +	struct link_free *link;
> > +	struct page *first_page, *f_page;
> > +	unsigned long f_objidx, f_offset;
> > +
> > +	int class_idx;
> > +	struct size_class *class;
> > +	enum fullness_group fullness;
> > +
> > +	if (unlikely(!obj))
> > +		return;
> > +
> > +	obj_handle_to_location(obj, &f_page, &f_objidx);
> > +	first_page = get_first_page(f_page);
> > +
> > +	get_zspage_mapping(first_page, &class_idx, &fullness);
> > +	class = &pool->size_class[class_idx];
> > +	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
> > +
> > +	spin_lock(&class->lock);
> > +
> > +	/* Insert this object in containing zspage's freelist */
> > +	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
> > +							+ f_offset);
> > +	link->next = first_page->freelist;
> > +	kunmap_atomic(link);
> > +	first_page->freelist = (void *)obj;
> > +
> > +	first_page->inuse--;
> > +	fullness = fix_fullness_group(pool, first_page);
> > +
> > +	if (fullness == ZS_EMPTY)
> > +		class->pages_allocated -= class->pages_per_zspage;
> > +
> > +	spin_unlock(&class->lock);
> > +
> > +	if (fullness == ZS_EMPTY)
> > +		free_zspage(pool->ops, first_page);
> > +}
> > +EXPORT_SYMBOL_GPL(zs_free);
> > +
> > +/**
> > + * zs_map_object - get address of allocated object from handle.
> > + * @pool: pool from which the object was allocated
> > + * @handle: handle returned from zs_malloc
> > + *
> > + * Before using an object allocated from zs_malloc, it must be mapped using
> > + * this function. When done with the object, it must be unmapped using
> > + * zs_unmap_object.
> > + *
> > + * Only one object can be mapped per cpu at a time. There is no protection
> > + * against nested mappings.
> > + *
> > + * This function returns with preemption and page faults disabled.
> > +*/
> > +void *zs_map_object(struct zs_pool *pool, unsigned long handle,
> > +			enum zs_mapmode mm)
> > +{
> > +	struct page *page;
> > +	unsigned long obj_idx, off;
> > +
> > +	unsigned int class_idx;
> > +	enum fullness_group fg;
> > +	struct size_class *class;
> > +	struct mapping_area *area;
> > +	struct page *pages[2];
> > +
> > +	BUG_ON(!handle);
> > +
> > +	/*
> > +	 * Because we use per-cpu mapping areas shared among the
> > +	 * pools/users, we can't allow mapping in interrupt context
> > +	 * because it can corrupt another users mappings.
> > +	 */
> > +	BUG_ON(in_interrupt());
> > +
> > +	obj_handle_to_location(handle, &page, &obj_idx);
> > +	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
> > +	class = &pool->size_class[class_idx];
> > +	off = obj_idx_to_offset(page, obj_idx, class->size);
> > +
> > +	area = &get_cpu_var(zs_map_area);
> > +	area->vm_mm = mm;
> > +	if (off + class->size <= PAGE_SIZE) {
> > +		/* this object is contained entirely within a page */
> > +		area->vm_addr = kmap_atomic(page);
> > +		return area->vm_addr + off;
> > +	}
> > +
> > +	/* this object spans two pages */
> > +	pages[0] = page;
> > +	pages[1] = get_next_page(page);
> > +	BUG_ON(!pages[1]);
> > +
> > +	return __zs_map_object(area, pages, off, class->size);
> > +}
> > +EXPORT_SYMBOL_GPL(zs_map_object);
> > +
> > +void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
> > +{
> > +	struct page *page;
> > +	unsigned long obj_idx, off;
> > +
> > +	unsigned int class_idx;
> > +	enum fullness_group fg;
> > +	struct size_class *class;
> > +	struct mapping_area *area;
> > +
> > +	BUG_ON(!handle);
> > +
> > +	obj_handle_to_location(handle, &page, &obj_idx);
> > +	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
> > +	class = &pool->size_class[class_idx];
> > +	off = obj_idx_to_offset(page, obj_idx, class->size);
> > +
> > +	area = &__get_cpu_var(zs_map_area);
> > +	if (off + class->size <= PAGE_SIZE)
> > +		kunmap_atomic(area->vm_addr);
> > +	else {
> > +		struct page *pages[2];
> > +
> > +		pages[0] = page;
> > +		pages[1] = get_next_page(page);
> > +		BUG_ON(!pages[1]);
> > +
> > +		__zs_unmap_object(area, pages, off, class->size);
> > +	}
> > +	put_cpu_var(zs_map_area);
> > +}
> > +EXPORT_SYMBOL_GPL(zs_unmap_object);
> > +
> > +u64 zs_get_total_size_bytes(struct zs_pool *pool)
> > +{
> > +	int i;
> > +	u64 npages = 0;
> > +
> > +	for (i = 0; i < ZS_SIZE_CLASSES; i++)
> > +		npages += pool->size_class[i].pages_allocated;
> > +
> > +	return npages << PAGE_SHIFT;
> > +}
> > +EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
> > +
> > +module_init(zs_init);
> > +module_exit(zs_exit);
> > +
> > +MODULE_LICENSE("Dual BSD/GPL");
> > +MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
> > -- 
> > 1.8.2.1
> > 
> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
