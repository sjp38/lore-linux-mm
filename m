Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 596746B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 04:24:01 -0500 (EST)
Date: Fri, 22 Feb 2013 18:24:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCHv5 1/8] zsmalloc: add to mm/
Message-ID: <20130222092420.GA8077@lge.com>
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1360780731-11708-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130219091804.GA13989@lge.com>
 <5123BC4D.1010404@linux.vnet.ibm.com>
 <20130219233733.GA16950@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130219233733.GA16950@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Feb 20, 2013 at 08:37:33AM +0900, Minchan Kim wrote:
> On Tue, Feb 19, 2013 at 11:54:21AM -0600, Seth Jennings wrote:
> > On 02/19/2013 03:18 AM, Joonsoo Kim wrote:
> > > Hello, Seth.
> > > I'm not sure that this is right time to review, because I already have
> > > seen many effort of various people to promote zxxx series. I don't want to
> > > be a stopper to promote these. :)
> > 
> > Any time is good review time :)  Thanks for your review!
> > 
> > > 
> > > But, I read the code, now, and then some comments below.
> > > 
> > > On Wed, Feb 13, 2013 at 12:38:44PM -0600, Seth Jennings wrote:
> > >> =========
> > >> DO NOT MERGE, FOR REVIEW ONLY
> > >> This patch introduces zsmalloc as new code, however, it already
> > >> exists in drivers/staging.  In order to build successfully, you
> > >> must select EITHER to driver/staging version OR this version.
> > >> Once zsmalloc is reviewed in this format (and hopefully accepted),
> > >> I will create a new patchset that properly promotes zsmalloc from
> > >> staging.
> > >> =========
> > >>
> > >> This patchset introduces a new slab-based memory allocator,
> > >> zsmalloc, for storing compressed pages.  It is designed for
> > >> low fragmentation and high allocation success rate on
> > >> large object, but <= PAGE_SIZE allocations.
> > >>
> > >> zsmalloc differs from the kernel slab allocator in two primary
> > >> ways to achieve these design goals.
> > >>
> > >> zsmalloc never requires high order page allocations to back
> > >> slabs, or "size classes" in zsmalloc terms. Instead it allows
> > >> multiple single-order pages to be stitched together into a
> > >> "zspage" which backs the slab.  This allows for higher allocation
> > >> success rate under memory pressure.
> > >>
> > >> Also, zsmalloc allows objects to span page boundaries within the
> > >> zspage.  This allows for lower fragmentation than could be had
> > >> with the kernel slab allocator for objects between PAGE_SIZE/2
> > >> and PAGE_SIZE.  With the kernel slab allocator, if a page compresses
> > >> to 60% of it original size, the memory savings gained through
> > >> compression is lost in fragmentation because another object of
> > >> the same size can't be stored in the leftover space.
> > >>
> > >> This ability to span pages results in zsmalloc allocations not being
> > >> directly addressable by the user.  The user is given an
> > >> non-dereferencable handle in response to an allocation request.
> > >> That handle must be mapped, using zs_map_object(), which returns
> > >> a pointer to the mapped region that can be used.  The mapping is
> > >> necessary since the object data may reside in two different
> > >> noncontigious pages.
> > >>
> > >> zsmalloc fulfills the allocation needs for zram and zswap.
> > >>
> > >> Acked-by: Nitin Gupta <ngupta@vflare.org>
> > >> Acked-by: Minchan Kim <minchan@kernel.org>
> > >> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > >> ---
> > >>  include/linux/zsmalloc.h |   49 ++
> > >>  mm/Kconfig               |   24 +
> > >>  mm/Makefile              |    1 +
> > >>  mm/zsmalloc.c            | 1124 ++++++++++++++++++++++++++++++++++++++++++++++
> > >>  4 files changed, 1198 insertions(+)
> > >>  create mode 100644 include/linux/zsmalloc.h
> > >>  create mode 100644 mm/zsmalloc.c
> > >>
> > >> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> > >> new file mode 100644
> > >> index 0000000..eb6efb6
> > >> --- /dev/null
> > >> +++ b/include/linux/zsmalloc.h
> > >> @@ -0,0 +1,49 @@
> > >> +/*
> > >> + * zsmalloc memory allocator
> > >> + *
> > >> + * Copyright (C) 2011  Nitin Gupta
> > >> + *
> > >> + * This code is released using a dual license strategy: BSD/GPL
> > >> + * You can choose the license that better fits your requirements.
> > >> + *
> > >> + * Released under the terms of 3-clause BSD License
> > >> + * Released under the terms of GNU General Public License Version 2.0
> > >> + */
> > >> +
> > >> +#ifndef _ZS_MALLOC_H_
> > >> +#define _ZS_MALLOC_H_
> > >> +
> > >> +#include <linux/types.h>
> > >> +#include <linux/mm_types.h>
> > >> +
> > >> +/*
> > >> + * zsmalloc mapping modes
> > >> + *
> > >> + * NOTE: These only make a difference when a mapped object spans pages
> > >> +*/
> > >> +enum zs_mapmode {
> > >> +	ZS_MM_RW, /* normal read-write mapping */
> > >> +	ZS_MM_RO, /* read-only (no copy-out at unmap time) */
> > >> +	ZS_MM_WO /* write-only (no copy-in at map time) */
> > >> +};
> > > 
> > > 
> > > These makes no difference for PGTABLE_MAPPING.
> > > Please add some comment for this.
> > 
> > Yes. Will do.
> > 
> > > 
> > >> +struct zs_ops {
> > >> +	struct page * (*alloc)(gfp_t);
> > >> +	void (*free)(struct page *);
> > >> +};
> > >> +
> > >> +struct zs_pool;
> > >> +
> > >> +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops);
> > >> +void zs_destroy_pool(struct zs_pool *pool);
> > >> +
> > >> +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
> > >> +void zs_free(struct zs_pool *pool, unsigned long obj);
> > >> +
> > >> +void *zs_map_object(struct zs_pool *pool, unsigned long handle,
> > >> +			enum zs_mapmode mm);
> > >> +void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
> > >> +
> > >> +u64 zs_get_total_size_bytes(struct zs_pool *pool);
> > >> +
> > >> +#endif
> > >> diff --git a/mm/Kconfig b/mm/Kconfig
> > >> index 278e3ab..25b8f38 100644
> > >> --- a/mm/Kconfig
> > >> +++ b/mm/Kconfig
> > >> @@ -446,3 +446,27 @@ config FRONTSWAP
> > >>  	  and swap data is stored as normal on the matching swap device.
> > >>  
> > >>  	  If unsure, say Y to enable frontswap.
> > >> +
> > >> +config ZSMALLOC
> > >> +	tristate "Memory allocator for compressed pages"
> > >> +	default n
> > >> +	help
> > >> +	  zsmalloc is a slab-based memory allocator designed to store
> > >> +	  compressed RAM pages.  zsmalloc uses virtual memory mapping
> > >> +	  in order to reduce fragmentation.  However, this results in a
> > >> +	  non-standard allocator interface where a handle, not a pointer, is
> > >> +	  returned by an alloc().  This handle must be mapped in order to
> > >> +	  access the allocated space.
> > >> +
> > >> +config PGTABLE_MAPPING
> > >> +	bool "Use page table mapping to access object in zsmalloc"
> > >> +	depends on ZSMALLOC
> > >> +	help
> > >> +	  By default, zsmalloc uses a copy-based object mapping method to
> > >> +	  access allocations that span two pages. However, if a particular
> > >> +	  architecture (ex, ARM) performs VM mapping faster than copying,
> > >> +	  then you should select this. This causes zsmalloc to use page table
> > >> +	  mapping rather than copying for object mapping.
> > >> +
> > >> +	  You can check speed with zsmalloc benchmark[1].
> > >> +	  [1] https://github.com/spartacus06/zsmalloc
> > >> diff --git a/mm/Makefile b/mm/Makefile
> > >> index 3a46287..0f6ef0a 100644
> > >> --- a/mm/Makefile
> > >> +++ b/mm/Makefile
> > >> @@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
> > >>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
> > >>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
> > >>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
> > >> +obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
> > >> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > >> new file mode 100644
> > >> index 0000000..34378ef
> > >> --- /dev/null
> > >> +++ b/mm/zsmalloc.c
> > >> @@ -0,0 +1,1124 @@
> > >> +/*
> > >> + * zsmalloc memory allocator
> > >> + *
> > >> + * Copyright (C) 2011  Nitin Gupta
> > >> + *
> > >> + * This code is released using a dual license strategy: BSD/GPL
> > >> + * You can choose the license that better fits your requirements.
> > >> + *
> > >> + * Released under the terms of 3-clause BSD License
> > >> + * Released under the terms of GNU General Public License Version 2.0
> > >> + */
> > >> +
> > >> +
> > >> +/*
> > >> + * This allocator is designed for use with zcache and zram. Thus, the
> > >> + * allocator is supposed to work well under low memory conditions. In
> > >> + * particular, it never attempts higher order page allocation which is
> > >> + * very likely to fail under memory pressure. On the other hand, if we
> > >> + * just use single (0-order) pages, it would suffer from very high
> > >> + * fragmentation -- any object of size PAGE_SIZE/2 or larger would occupy
> > >> + * an entire page. This was one of the major issues with its predecessor
> > >> + * (xvmalloc).
> > >> + *
> > >> + * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
> > >> + * and links them together using various 'struct page' fields. These linked
> > >> + * pages act as a single higher-order page i.e. an object can span 0-order
> > >> + * page boundaries. The code refers to these linked pages as a single entity
> > >> + * called zspage.
> > >> + *
> > >> + * For simplicity, zsmalloc can only allocate objects of size up to PAGE_SIZE
> > >> + * since this satisfies the requirements of all its current users (in the
> > >> + * worst case, page is incompressible and is thus stored "as-is" i.e. in
> > >> + * uncompressed form). For allocation requests larger than this size, failure
> > >> + * is returned (see zs_malloc).
> > >> + *
> > >> + * Additionally, zs_malloc() does not return a dereferenceable pointer.
> > >> + * Instead, it returns an opaque handle (unsigned long) which encodes actual
> > >> + * location of the allocated object. The reason for this indirection is that
> > >> + * zsmalloc does not keep zspages permanently mapped since that would cause
> > >> + * issues on 32-bit systems where the VA region for kernel space mappings
> > >> + * is very small. So, before using the allocating memory, the object has to
> > >> + * be mapped using zs_map_object() to get a usable pointer and subsequently
> > >> + * unmapped using zs_unmap_object().
> > >> + *
> > >> + * Following is how we use various fields and flags of underlying
> > >> + * struct page(s) to form a zspage.
> > >> + *
> > >> + * Usage of struct page fields:
> > >> + *	page->first_page: points to the first component (0-order) page
> > >> + *	page->index (union with page->freelist): offset of the first object
> > >> + *		starting in this page. For the first page, this is
> > >> + *		always 0, so we use this field (aka freelist) to point
> > >> + *		to the first free object in zspage.
> > >> + *	page->lru: links together all component pages (except the first page)
> > >> + *		of a zspage
> > >> + *
> > >> + *	For _first_ page only:
> > >> + *
> > >> + *	page->private (union with page->first_page): refers to the
> > >> + *		component page after the first page
> > >> + *	page->freelist: points to the first free object in zspage.
> > >> + *		Free objects are linked together using in-place
> > >> + *		metadata.
> > >> + *	page->objects: maximum number of objects we can store in this
> > >> + *		zspage (class->zspage_order * PAGE_SIZE / class->size)
> > > 
> > > How about just embedding maximum number of objects to size_class?
> > > For the SLUB, each slab can have difference number of objects.
> > > But, for the zsmalloc, it is not possible, so there is no reason
> > > to maintain it within metadata of zspage. Just to embed it to size_class
> > > is sufficient.
> > 
> > Yes, a little code massaging and this can go away.
> > 
> > However, there might be some value in having variable sized zspages in
> > the same size_class.  It could improve allocation success rate at the
> > expense of efficiency by not failing in alloc_zspage() if we can't
> > allocate the optimal number of pages.  As long as we can allocate the
> > first page, then we can proceed.
> > 
> > Nitin care to weigh in?
> 
> Sorry, I'm not Nitin.
> IMHO, Seth's idea is good but at the moment, it's just a idea.
> We can add it in future easily with some experiment result.
> So I vote Joonsoo's comment.
> 
> > 
> > > 
> > > 
> > >> + *	page->lru: links together first pages of various zspages.
> > >> + *		Basically forming list of zspages in a fullness group.
> > >> + *	page->mapping: class index and fullness group of the zspage
> > >> + *
> > >> + * Usage of struct page flags:
> > >> + *	PG_private: identifies the first component page
> > >> + *	PG_private2: identifies the last component page
> > >> + *
> > >> + */
> > >> +
> > >> +#ifdef CONFIG_ZSMALLOC_DEBUG
> > >> +#define DEBUG
> > >> +#endif
> > > 
> > > Is this obsolete?
> > 
> > Yes, I'll remove it.
> > 
> > > 
> > >> +#include <linux/module.h>
> > >> +#include <linux/kernel.h>
> > >> +#include <linux/bitops.h>
> > >> +#include <linux/errno.h>
> > >> +#include <linux/highmem.h>
> > >> +#include <linux/init.h>
> > >> +#include <linux/string.h>
> > >> +#include <linux/slab.h>
> > >> +#include <asm/tlbflush.h>
> > >> +#include <asm/pgtable.h>
> > >> +#include <linux/cpumask.h>
> > >> +#include <linux/cpu.h>
> > >> +#include <linux/vmalloc.h>
> > >> +#include <linux/hardirq.h>
> > >> +#include <linux/spinlock.h>
> > >> +#include <linux/types.h>
> > >> +
> > >> +#include <linux/zsmalloc.h>
> > >> +
> > >> +/*
> > >> + * This must be power of 2 and greater than of equal to sizeof(link_free).
> > >> + * These two conditions ensure that any 'struct link_free' itself doesn't
> > >> + * span more than 1 page which avoids complex case of mapping 2 pages simply
> > >> + * to restore link_free pointer values.
> > >> + */
> > >> +#define ZS_ALIGN		8
> > >> +
> > >> +/*
> > >> + * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
> > >> + * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
> > >> + */
> > >> +#define ZS_MAX_ZSPAGE_ORDER 2
> > >> +#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
> > >> +
> > >> +/*
> > >> + * Object location (<PFN>, <obj_idx>) is encoded as
> > >> + * as single (unsigned long) handle value.
> > >> + *
> > >> + * Note that object index <obj_idx> is relative to system
> > >> + * page <PFN> it is stored in, so for each sub-page belonging
> > >> + * to a zspage, obj_idx starts with 0.
> > >> + *
> > >> + * This is made more complicated by various memory models and PAE.
> > >> + */
> > >> +
> > >> +#ifndef MAX_PHYSMEM_BITS
> > >> +#ifdef CONFIG_HIGHMEM64G
> > >> +#define MAX_PHYSMEM_BITS 36
> > >> +#else /* !CONFIG_HIGHMEM64G */
> > >> +/*
> > >> + * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
> > >> + * be PAGE_SHIFT
> > >> + */
> > >> +#define MAX_PHYSMEM_BITS BITS_PER_LONG
> > >> +#endif
> > >> +#endif
> > >> +#define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
> > >> +#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
> > >> +#define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
> > >> +
> > >> +#define MAX(a, b) ((a) >= (b) ? (a) : (b))
> > >> +/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
> > >> +#define ZS_MIN_ALLOC_SIZE \
> > >> +	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
> > >> +#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
> > >> +
> > >> +/*
> > >> + * On systems with 4K page size, this gives 254 size classes! There is a
> > >> + * trader-off here:
> > >> + *  - Large number of size classes is potentially wasteful as free page are
> > >> + *    spread across these classes
> > >> + *  - Small number of size classes causes large internal fragmentation
> > >> + *  - Probably its better to use specific size classes (empirically
> > >> + *    determined). NOTE: all those class sizes must be set as multiple of
> > >> + *    ZS_ALIGN to make sure link_free itself never has to span 2 pages.
> > >> + *
> > >> + *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
> > >> + *  (reason above)
> > >> + */
> > >> +#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
> > >> +#define ZS_SIZE_CLASSES		((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
> > >> +					ZS_SIZE_CLASS_DELTA + 1)
> > >> +
> > >> +/*
> > >> + * We do not maintain any list for completely empty or full pages
> > >> + */
> > >> +enum fullness_group {
> > >> +	ZS_ALMOST_FULL,
> > >> +	ZS_ALMOST_EMPTY,
> > >> +	_ZS_NR_FULLNESS_GROUPS,
> > >> +
> > >> +	ZS_EMPTY,
> > >> +	ZS_FULL
> > >> +};
> > >> +
> > >> +/*
> > >> + * We assign a page to ZS_ALMOST_EMPTY fullness group when:
> > >> + *	n <= N / f, where
> > >> + * n = number of allocated objects
> > >> + * N = total number of objects zspage can store
> > >> + * f = 1/fullness_threshold_frac
> > >> + *
> > >> + * Similarly, we assign zspage to:
> > >> + *	ZS_ALMOST_FULL	when n > N / f
> > >> + *	ZS_EMPTY	when n == 0
> > >> + *	ZS_FULL		when n == N
> > >> + *
> > >> + * (see: fix_fullness_group())
> > >> + */
> > >> +static const int fullness_threshold_frac = 4;
> > >> +
> > >> +struct size_class {
> > >> +	/*
> > >> +	 * Size of objects stored in this class. Must be multiple
> > >> +	 * of ZS_ALIGN.
> > >> +	 */
> > >> +	int size;
> > >> +	unsigned int index;
> > >> +
> > >> +	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> > >> +	int pages_per_zspage;
> > >> +
> > >> +	spinlock_t lock;
> > >> +
> > >> +	/* stats */
> > >> +	u64 pages_allocated;
> > >> +
> > >> +	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> > >> +};
> > > 
> > > Instead of simple pointer, how about using list_head?
> > > With this, fullness_list management is easily consolidated to
> > > set_zspage_mapping() and we can remove remove_zspage(), insert_zspage().
> > 
> > Makes sense to me.  Nitin what do you think?
> 
> I like it although I'm not Nitin.
> 
> > 
> > > And how about maintaining FULL, EMPTY list?
> > > There is not much memory waste and it can be used for debugging and
> > > implementing other functionality.
> 
> Joonsoo, could you elaborate on ideas you have about debugging and
> other functions you mentioned?
> We need justification for change rather than saying
> "might be useful in future". Then, we can judge whether we should do
> it right now or are able to add it in future when we really need it.

It's my quick thought. So there is no concrete idea.
As Seth said, with a FULL list, zsmalloc always access all zspage.
So, if we want to know what pages are for zsmalloc, we can know it.
The EMPTY list can be used for pool of zsmalloc itself. With it, we don't
need to free zspage directly, we can keep zspages, so can reduce
alloc/free overhead. But, I'm not sure whether it is useful.

> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
