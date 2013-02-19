Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E0FFA6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:26:48 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 19 Feb 2013 13:26:47 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E65B16E93CF
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 12:54:25 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1JHsQ6r331970
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 12:54:27 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1JHsLYR004870
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 12:54:23 -0500
Message-ID: <5123BC4D.1010404@linux.vnet.ibm.com>
Date: Tue, 19 Feb 2013 11:54:21 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 1/8] zsmalloc: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-2-git-send-email-sjenning@linux.vnet.ibm.com> <20130219091804.GA13989@lge.com>
In-Reply-To: <20130219091804.GA13989@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/19/2013 03:18 AM, Joonsoo Kim wrote:
> Hello, Seth.
> I'm not sure that this is right time to review, because I already have
> seen many effort of various people to promote zxxx series. I don't want to
> be a stopper to promote these. :)

Any time is good review time :)  Thanks for your review!

> 
> But, I read the code, now, and then some comments below.
> 
> On Wed, Feb 13, 2013 at 12:38:44PM -0600, Seth Jennings wrote:
>> =========
>> DO NOT MERGE, FOR REVIEW ONLY
>> This patch introduces zsmalloc as new code, however, it already
>> exists in drivers/staging.  In order to build successfully, you
>> must select EITHER to driver/staging version OR this version.
>> Once zsmalloc is reviewed in this format (and hopefully accepted),
>> I will create a new patchset that properly promotes zsmalloc from
>> staging.
>> =========
>>
>> This patchset introduces a new slab-based memory allocator,
>> zsmalloc, for storing compressed pages.  It is designed for
>> low fragmentation and high allocation success rate on
>> large object, but <= PAGE_SIZE allocations.
>>
>> zsmalloc differs from the kernel slab allocator in two primary
>> ways to achieve these design goals.
>>
>> zsmalloc never requires high order page allocations to back
>> slabs, or "size classes" in zsmalloc terms. Instead it allows
>> multiple single-order pages to be stitched together into a
>> "zspage" which backs the slab.  This allows for higher allocation
>> success rate under memory pressure.
>>
>> Also, zsmalloc allows objects to span page boundaries within the
>> zspage.  This allows for lower fragmentation than could be had
>> with the kernel slab allocator for objects between PAGE_SIZE/2
>> and PAGE_SIZE.  With the kernel slab allocator, if a page compresses
>> to 60% of it original size, the memory savings gained through
>> compression is lost in fragmentation because another object of
>> the same size can't be stored in the leftover space.
>>
>> This ability to span pages results in zsmalloc allocations not being
>> directly addressable by the user.  The user is given an
>> non-dereferencable handle in response to an allocation request.
>> That handle must be mapped, using zs_map_object(), which returns
>> a pointer to the mapped region that can be used.  The mapping is
>> necessary since the object data may reside in two different
>> noncontigious pages.
>>
>> zsmalloc fulfills the allocation needs for zram and zswap.
>>
>> Acked-by: Nitin Gupta <ngupta@vflare.org>
>> Acked-by: Minchan Kim <minchan@kernel.org>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> ---
>>  include/linux/zsmalloc.h |   49 ++
>>  mm/Kconfig               |   24 +
>>  mm/Makefile              |    1 +
>>  mm/zsmalloc.c            | 1124 ++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 1198 insertions(+)
>>  create mode 100644 include/linux/zsmalloc.h
>>  create mode 100644 mm/zsmalloc.c
>>
>> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
>> new file mode 100644
>> index 0000000..eb6efb6
>> --- /dev/null
>> +++ b/include/linux/zsmalloc.h
>> @@ -0,0 +1,49 @@
>> +/*
>> + * zsmalloc memory allocator
>> + *
>> + * Copyright (C) 2011  Nitin Gupta
>> + *
>> + * This code is released using a dual license strategy: BSD/GPL
>> + * You can choose the license that better fits your requirements.
>> + *
>> + * Released under the terms of 3-clause BSD License
>> + * Released under the terms of GNU General Public License Version 2.0
>> + */
>> +
>> +#ifndef _ZS_MALLOC_H_
>> +#define _ZS_MALLOC_H_
>> +
>> +#include <linux/types.h>
>> +#include <linux/mm_types.h>
>> +
>> +/*
>> + * zsmalloc mapping modes
>> + *
>> + * NOTE: These only make a difference when a mapped object spans pages
>> +*/
>> +enum zs_mapmode {
>> +	ZS_MM_RW, /* normal read-write mapping */
>> +	ZS_MM_RO, /* read-only (no copy-out at unmap time) */
>> +	ZS_MM_WO /* write-only (no copy-in at map time) */
>> +};
> 
> 
> These makes no difference for PGTABLE_MAPPING.
> Please add some comment for this.

Yes. Will do.

> 
>> +struct zs_ops {
>> +	struct page * (*alloc)(gfp_t);
>> +	void (*free)(struct page *);
>> +};
>> +
>> +struct zs_pool;
>> +
>> +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops);
>> +void zs_destroy_pool(struct zs_pool *pool);
>> +
>> +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
>> +void zs_free(struct zs_pool *pool, unsigned long obj);
>> +
>> +void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>> +			enum zs_mapmode mm);
>> +void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
>> +
>> +u64 zs_get_total_size_bytes(struct zs_pool *pool);
>> +
>> +#endif
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 278e3ab..25b8f38 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -446,3 +446,27 @@ config FRONTSWAP
>>  	  and swap data is stored as normal on the matching swap device.
>>  
>>  	  If unsure, say Y to enable frontswap.
>> +
>> +config ZSMALLOC
>> +	tristate "Memory allocator for compressed pages"
>> +	default n
>> +	help
>> +	  zsmalloc is a slab-based memory allocator designed to store
>> +	  compressed RAM pages.  zsmalloc uses virtual memory mapping
>> +	  in order to reduce fragmentation.  However, this results in a
>> +	  non-standard allocator interface where a handle, not a pointer, is
>> +	  returned by an alloc().  This handle must be mapped in order to
>> +	  access the allocated space.
>> +
>> +config PGTABLE_MAPPING
>> +	bool "Use page table mapping to access object in zsmalloc"
>> +	depends on ZSMALLOC
>> +	help
>> +	  By default, zsmalloc uses a copy-based object mapping method to
>> +	  access allocations that span two pages. However, if a particular
>> +	  architecture (ex, ARM) performs VM mapping faster than copying,
>> +	  then you should select this. This causes zsmalloc to use page table
>> +	  mapping rather than copying for object mapping.
>> +
>> +	  You can check speed with zsmalloc benchmark[1].
>> +	  [1] https://github.com/spartacus06/zsmalloc
>> diff --git a/mm/Makefile b/mm/Makefile
>> index 3a46287..0f6ef0a 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
>>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>> +obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> new file mode 100644
>> index 0000000..34378ef
>> --- /dev/null
>> +++ b/mm/zsmalloc.c
>> @@ -0,0 +1,1124 @@
>> +/*
>> + * zsmalloc memory allocator
>> + *
>> + * Copyright (C) 2011  Nitin Gupta
>> + *
>> + * This code is released using a dual license strategy: BSD/GPL
>> + * You can choose the license that better fits your requirements.
>> + *
>> + * Released under the terms of 3-clause BSD License
>> + * Released under the terms of GNU General Public License Version 2.0
>> + */
>> +
>> +
>> +/*
>> + * This allocator is designed for use with zcache and zram. Thus, the
>> + * allocator is supposed to work well under low memory conditions. In
>> + * particular, it never attempts higher order page allocation which is
>> + * very likely to fail under memory pressure. On the other hand, if we
>> + * just use single (0-order) pages, it would suffer from very high
>> + * fragmentation -- any object of size PAGE_SIZE/2 or larger would occupy
>> + * an entire page. This was one of the major issues with its predecessor
>> + * (xvmalloc).
>> + *
>> + * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
>> + * and links them together using various 'struct page' fields. These linked
>> + * pages act as a single higher-order page i.e. an object can span 0-order
>> + * page boundaries. The code refers to these linked pages as a single entity
>> + * called zspage.
>> + *
>> + * For simplicity, zsmalloc can only allocate objects of size up to PAGE_SIZE
>> + * since this satisfies the requirements of all its current users (in the
>> + * worst case, page is incompressible and is thus stored "as-is" i.e. in
>> + * uncompressed form). For allocation requests larger than this size, failure
>> + * is returned (see zs_malloc).
>> + *
>> + * Additionally, zs_malloc() does not return a dereferenceable pointer.
>> + * Instead, it returns an opaque handle (unsigned long) which encodes actual
>> + * location of the allocated object. The reason for this indirection is that
>> + * zsmalloc does not keep zspages permanently mapped since that would cause
>> + * issues on 32-bit systems where the VA region for kernel space mappings
>> + * is very small. So, before using the allocating memory, the object has to
>> + * be mapped using zs_map_object() to get a usable pointer and subsequently
>> + * unmapped using zs_unmap_object().
>> + *
>> + * Following is how we use various fields and flags of underlying
>> + * struct page(s) to form a zspage.
>> + *
>> + * Usage of struct page fields:
>> + *	page->first_page: points to the first component (0-order) page
>> + *	page->index (union with page->freelist): offset of the first object
>> + *		starting in this page. For the first page, this is
>> + *		always 0, so we use this field (aka freelist) to point
>> + *		to the first free object in zspage.
>> + *	page->lru: links together all component pages (except the first page)
>> + *		of a zspage
>> + *
>> + *	For _first_ page only:
>> + *
>> + *	page->private (union with page->first_page): refers to the
>> + *		component page after the first page
>> + *	page->freelist: points to the first free object in zspage.
>> + *		Free objects are linked together using in-place
>> + *		metadata.
>> + *	page->objects: maximum number of objects we can store in this
>> + *		zspage (class->zspage_order * PAGE_SIZE / class->size)
> 
> How about just embedding maximum number of objects to size_class?
> For the SLUB, each slab can have difference number of objects.
> But, for the zsmalloc, it is not possible, so there is no reason
> to maintain it within metadata of zspage. Just to embed it to size_class
> is sufficient.

Yes, a little code massaging and this can go away.

However, there might be some value in having variable sized zspages in
the same size_class.  It could improve allocation success rate at the
expense of efficiency by not failing in alloc_zspage() if we can't
allocate the optimal number of pages.  As long as we can allocate the
first page, then we can proceed.

Nitin care to weigh in?

> 
> 
>> + *	page->lru: links together first pages of various zspages.
>> + *		Basically forming list of zspages in a fullness group.
>> + *	page->mapping: class index and fullness group of the zspage
>> + *
>> + * Usage of struct page flags:
>> + *	PG_private: identifies the first component page
>> + *	PG_private2: identifies the last component page
>> + *
>> + */
>> +
>> +#ifdef CONFIG_ZSMALLOC_DEBUG
>> +#define DEBUG
>> +#endif
> 
> Is this obsolete?

Yes, I'll remove it.

> 
>> +#include <linux/module.h>
>> +#include <linux/kernel.h>
>> +#include <linux/bitops.h>
>> +#include <linux/errno.h>
>> +#include <linux/highmem.h>
>> +#include <linux/init.h>
>> +#include <linux/string.h>
>> +#include <linux/slab.h>
>> +#include <asm/tlbflush.h>
>> +#include <asm/pgtable.h>
>> +#include <linux/cpumask.h>
>> +#include <linux/cpu.h>
>> +#include <linux/vmalloc.h>
>> +#include <linux/hardirq.h>
>> +#include <linux/spinlock.h>
>> +#include <linux/types.h>
>> +
>> +#include <linux/zsmalloc.h>
>> +
>> +/*
>> + * This must be power of 2 and greater than of equal to sizeof(link_free).
>> + * These two conditions ensure that any 'struct link_free' itself doesn't
>> + * span more than 1 page which avoids complex case of mapping 2 pages simply
>> + * to restore link_free pointer values.
>> + */
>> +#define ZS_ALIGN		8
>> +
>> +/*
>> + * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
>> + * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
>> + */
>> +#define ZS_MAX_ZSPAGE_ORDER 2
>> +#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
>> +
>> +/*
>> + * Object location (<PFN>, <obj_idx>) is encoded as
>> + * as single (unsigned long) handle value.
>> + *
>> + * Note that object index <obj_idx> is relative to system
>> + * page <PFN> it is stored in, so for each sub-page belonging
>> + * to a zspage, obj_idx starts with 0.
>> + *
>> + * This is made more complicated by various memory models and PAE.
>> + */
>> +
>> +#ifndef MAX_PHYSMEM_BITS
>> +#ifdef CONFIG_HIGHMEM64G
>> +#define MAX_PHYSMEM_BITS 36
>> +#else /* !CONFIG_HIGHMEM64G */
>> +/*
>> + * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
>> + * be PAGE_SHIFT
>> + */
>> +#define MAX_PHYSMEM_BITS BITS_PER_LONG
>> +#endif
>> +#endif
>> +#define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
>> +#define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS)
>> +#define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
>> +
>> +#define MAX(a, b) ((a) >= (b) ? (a) : (b))
>> +/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
>> +#define ZS_MIN_ALLOC_SIZE \
>> +	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
>> +#define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
>> +
>> +/*
>> + * On systems with 4K page size, this gives 254 size classes! There is a
>> + * trader-off here:
>> + *  - Large number of size classes is potentially wasteful as free page are
>> + *    spread across these classes
>> + *  - Small number of size classes causes large internal fragmentation
>> + *  - Probably its better to use specific size classes (empirically
>> + *    determined). NOTE: all those class sizes must be set as multiple of
>> + *    ZS_ALIGN to make sure link_free itself never has to span 2 pages.
>> + *
>> + *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
>> + *  (reason above)
>> + */
>> +#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
>> +#define ZS_SIZE_CLASSES		((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
>> +					ZS_SIZE_CLASS_DELTA + 1)
>> +
>> +/*
>> + * We do not maintain any list for completely empty or full pages
>> + */
>> +enum fullness_group {
>> +	ZS_ALMOST_FULL,
>> +	ZS_ALMOST_EMPTY,
>> +	_ZS_NR_FULLNESS_GROUPS,
>> +
>> +	ZS_EMPTY,
>> +	ZS_FULL
>> +};
>> +
>> +/*
>> + * We assign a page to ZS_ALMOST_EMPTY fullness group when:
>> + *	n <= N / f, where
>> + * n = number of allocated objects
>> + * N = total number of objects zspage can store
>> + * f = 1/fullness_threshold_frac
>> + *
>> + * Similarly, we assign zspage to:
>> + *	ZS_ALMOST_FULL	when n > N / f
>> + *	ZS_EMPTY	when n == 0
>> + *	ZS_FULL		when n == N
>> + *
>> + * (see: fix_fullness_group())
>> + */
>> +static const int fullness_threshold_frac = 4;
>> +
>> +struct size_class {
>> +	/*
>> +	 * Size of objects stored in this class. Must be multiple
>> +	 * of ZS_ALIGN.
>> +	 */
>> +	int size;
>> +	unsigned int index;
>> +
>> +	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
>> +	int pages_per_zspage;
>> +
>> +	spinlock_t lock;
>> +
>> +	/* stats */
>> +	u64 pages_allocated;
>> +
>> +	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
>> +};
> 
> Instead of simple pointer, how about using list_head?
> With this, fullness_list management is easily consolidated to
> set_zspage_mapping() and we can remove remove_zspage(), insert_zspage().

Makes sense to me.  Nitin what do you think?

> And how about maintaining FULL, EMPTY list?
> There is not much memory waste and it can be used for debugging and
> implementing other functionality.

The EMPTY list would always be empty.  There might be some merit to
maintaining a FULL list though just so zsmalloc always has a handle on
every zspage.

> 
>> +
>> +/*
>> + * Placed within free objects to form a singly linked list.
>> + * For every zspage, first_page->freelist gives head of this list.
>> + *
>> + * This must be power of 2 and less than or equal to ZS_ALIGN
>> + */
>> +struct link_free {
>> +	/* Handle of next free chunk (encodes <PFN, obj_idx>) */
>> +	void *next;
>> +};
>> +
>> +struct zs_pool {
>> +	struct size_class size_class[ZS_SIZE_CLASSES];
>> +
>> +	struct zs_ops *ops;
>> +};
>> +
>> +/*
>> + * A zspage's class index and fullness group
>> + * are encoded in its (first)page->mapping
>> + */
>> +#define CLASS_IDX_BITS	28
>> +#define FULLNESS_BITS	4
>> +#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
>> +#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
>> +
>> +struct mapping_area {
>> +#ifdef CONFIG_PGTABLE_MAPPING
>> +	struct vm_struct *vm; /* vm area for mapping object that span pages */
>> +#else
>> +	char *vm_buf; /* copy buffer for objects that span pages */
>> +#endif
>> +	char *vm_addr; /* address of kmap_atomic()'ed pages */
>> +	enum zs_mapmode vm_mm; /* mapping mode */
>> +};
>> +
>> +/* default page alloc/free ops */
>> +struct page *zs_alloc_page(gfp_t flags)
>> +{
>> +	return alloc_page(flags);
>> +}
>> +
>> +void zs_free_page(struct page *page)
>> +{
>> +	__free_page(page);
>> +}
>> +
>> +struct zs_ops zs_default_ops = {
>> +	.alloc = zs_alloc_page,
>> +	.free = zs_free_page
>> +};
>> +
>> +/* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
>> +static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
>> +
>> +static int is_first_page(struct page *page)
>> +{
>> +	return PagePrivate(page);
>> +}
>> +
>> +static int is_last_page(struct page *page)
>> +{
>> +	return PagePrivate2(page);
>> +}
>> +
>> +static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
>> +				enum fullness_group *fullness)
>> +{
>> +	unsigned long m;
>> +	BUG_ON(!is_first_page(page));
>> +
>> +	m = (unsigned long)page->mapping;
>> +	*fullness = m & FULLNESS_MASK;
>> +	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
>> +}
>> +
>> +static void set_zspage_mapping(struct page *page, unsigned int class_idx,
>> +				enum fullness_group fullness)
>> +{
>> +	unsigned long m;
>> +	BUG_ON(!is_first_page(page));
>> +
>> +	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
>> +			(fullness & FULLNESS_MASK);
>> +	page->mapping = (struct address_space *)m;
>> +}
>> +
>> +/*
>> + * zsmalloc divides the pool into various size classes where each
>> + * class maintains a list of zspages where each zspage is divided
>> + * into equal sized chunks. Each allocation falls into one of these
>> + * classes depending on its size. This function returns index of the
>> + * size class which has chunk size big enough to hold the give size.
>> + */
>> +static int get_size_class_index(int size)
>> +{
>> +	int idx = 0;
>> +
>> +	if (likely(size > ZS_MIN_ALLOC_SIZE))
>> +		idx = DIV_ROUND_UP(size - ZS_MIN_ALLOC_SIZE,
>> +				ZS_SIZE_CLASS_DELTA);
>> +
>> +	return idx;
>> +}
>> +
>> +/*
>> + * For each size class, zspages are divided into different groups
>> + * depending on how "full" they are. This was done so that we could
>> + * easily find empty or nearly empty zspages when we try to shrink
>> + * the pool (not yet implemented). This function returns fullness
>> + * status of the given page.
>> + */
>> +static enum fullness_group get_fullness_group(struct page *page)
>> +{
>> +	int inuse, max_objects;
>> +	enum fullness_group fg;
>> +	BUG_ON(!is_first_page(page));
>> +
>> +	inuse = page->inuse;
>> +	max_objects = page->objects;
>> +
>> +	if (inuse == 0)
>> +		fg = ZS_EMPTY;
>> +	else if (inuse == max_objects)
>> +		fg = ZS_FULL;
>> +	else if (inuse <= max_objects / fullness_threshold_frac)
>> +		fg = ZS_ALMOST_EMPTY;
>> +	else
>> +		fg = ZS_ALMOST_FULL;
>> +
>> +	return fg;
>> +}
>> +
>> +/*
>> + * Each size class maintains various freelists and zspages are assigned
>> + * to one of these freelists based on the number of live objects they
>> + * have. This functions inserts the given zspage into the freelist
>> + * identified by <class, fullness_group>.
>> + */
>> +static void insert_zspage(struct page *page, struct size_class *class,
>> +				enum fullness_group fullness)
>> +{
>> +	struct page **head;
>> +
>> +	BUG_ON(!is_first_page(page));
>> +
>> +	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
>> +		return;
>> +
>> +	head = &class->fullness_list[fullness];
>> +	if (*head)
>> +		list_add_tail(&page->lru, &(*head)->lru);
>> +
>> +	*head = page;
>> +}
>> +
>> +/*
>> + * This function removes the given zspage from the freelist identified
>> + * by <class, fullness_group>.
>> + */
>> +static void remove_zspage(struct page *page, struct size_class *class,
>> +				enum fullness_group fullness)
>> +{
>> +	struct page **head;
>> +
>> +	BUG_ON(!is_first_page(page));
>> +
>> +	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
>> +		return;
>> +
>> +	head = &class->fullness_list[fullness];
>> +	BUG_ON(!*head);
>> +	if (list_empty(&(*head)->lru))
>> +		*head = NULL;
>> +	else if (*head == page)
>> +		*head = (struct page *)list_entry((*head)->lru.next,
>> +					struct page, lru);
>> +
>> +	list_del_init(&page->lru);
>> +}
>> +
>> +/*
>> + * Each size class maintains zspages in different fullness groups depending
>> + * on the number of live objects they contain. When allocating or freeing
>> + * objects, the fullness status of the page can change, say, from ALMOST_FULL
>> + * to ALMOST_EMPTY when freeing an object. This function checks if such
>> + * a status change has occurred for the given page and accordingly moves the
>> + * page from the freelist of the old fullness group to that of the new
>> + * fullness group.
>> + */
>> +static enum fullness_group fix_fullness_group(struct zs_pool *pool,
>> +						struct page *page)
>> +{
>> +	int class_idx;
>> +	struct size_class *class;
>> +	enum fullness_group currfg, newfg;
>> +
>> +	BUG_ON(!is_first_page(page));
>> +
>> +	get_zspage_mapping(page, &class_idx, &currfg);
>> +	newfg = get_fullness_group(page);
>> +	if (newfg == currfg)
>> +		goto out;
>> +
>> +	class = &pool->size_class[class_idx];
>> +	remove_zspage(page, class, currfg);
>> +	insert_zspage(page, class, newfg);
>> +	set_zspage_mapping(page, class_idx, newfg);
>> +
>> +out:
>> +	return newfg;
>> +}
>> +
>> +/*
>> + * We have to decide on how many pages to link together
>> + * to form a zspage for each size class. This is important
>> + * to reduce wastage due to unusable space left at end of
>> + * each zspage which is given as:
>> + *	wastage = Zp - Zp % size_class
>> + * where Zp = zspage size = k * PAGE_SIZE where k = 1, 2, ...
>> + *
>> + * For example, for size class of 3/8 * PAGE_SIZE, we should
>> + * link together 3 PAGE_SIZE sized pages to form a zspage
>> + * since then we can perfectly fit in 8 such objects.
>> + */
>> +static int get_pages_per_zspage(int class_size)
>> +{
>> +	int i, max_usedpc = 0;
>> +	/* zspage order which gives maximum used size per KB */
>> +	int max_usedpc_order = 1;
>> +
>> +	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
>> +		int zspage_size;
>> +		int waste, usedpc;
>> +
>> +		zspage_size = i * PAGE_SIZE;
>> +		waste = zspage_size % class_size;
>> +		usedpc = (zspage_size - waste) * 100 / zspage_size;
>> +
>> +		if (usedpc > max_usedpc) {
>> +			max_usedpc = usedpc;
>> +			max_usedpc_order = i;
>> +		}
>> +	}
>> +
>> +	return max_usedpc_order;
>> +}
>> +
>> +/*
>> + * A single 'zspage' is composed of many system pages which are
>> + * linked together using fields in struct page. This function finds
>> + * the first/head page, given any component page of a zspage.
>> + */
>> +static struct page *get_first_page(struct page *page)
>> +{
>> +	if (is_first_page(page))
>> +		return page;
>> +	else
>> +		return page->first_page;
>> +}
>> +
>> +static struct page *get_next_page(struct page *page)
>> +{
>> +	struct page *next;
>> +
>> +	if (is_last_page(page))
>> +		next = NULL;
>> +	else if (is_first_page(page))
>> +		next = (struct page *)page->private;
>> +	else
>> +		next = list_entry(page->lru.next, struct page, lru);
>> +
>> +	return next;
>> +}
>> +
>> +/* Encode <page, obj_idx> as a single handle value */
>> +static void *obj_location_to_handle(struct page *page, unsigned long obj_idx)
>> +{
>> +	unsigned long handle;
>> +
>> +	if (!page) {
>> +		BUG_ON(obj_idx);
>> +		return NULL;
>> +	}
>> +
>> +	handle = page_to_pfn(page) << OBJ_INDEX_BITS;
>> +	handle |= (obj_idx & OBJ_INDEX_MASK);
>> +
>> +	return (void *)handle;
>> +}
>> +
>> +/* Decode <page, obj_idx> pair from the given object handle */
>> +static void obj_handle_to_location(unsigned long handle, struct page **page,
>> +				unsigned long *obj_idx)
>> +{
>> +	*page = pfn_to_page(handle >> OBJ_INDEX_BITS);
>> +	*obj_idx = handle & OBJ_INDEX_MASK;
>> +}
>> +
>> +static unsigned long obj_idx_to_offset(struct page *page,
>> +				unsigned long obj_idx, int class_size)
>> +{
>> +	unsigned long off = 0;
>> +
>> +	if (!is_first_page(page))
>> +		off = page->index;
>> +
>> +	return off + obj_idx * class_size;
>> +}
>> +
>> +static void reset_page(struct page *page)
>> +{
>> +	clear_bit(PG_private, &page->flags);
>> +	clear_bit(PG_private_2, &page->flags);
>> +	set_page_private(page, 0);
>> +	page->mapping = NULL;
>> +	page->freelist = NULL;
>> +	reset_page_mapcount(page);
>> +}
>> +
>> +static void free_zspage(struct zs_ops *ops, struct page *first_page)
>> +{
>> +	struct page *nextp, *tmp, *head_extra;
>> +
>> +	BUG_ON(!is_first_page(first_page));
>> +	BUG_ON(first_page->inuse);
>> +
>> +	head_extra = (struct page *)page_private(first_page);
>> +
>> +	reset_page(first_page);
>> +	ops->free(first_page);
>> +
>> +	/* zspage with only 1 system page */
>> +	if (!head_extra)
>> +		return;
>> +
>> +	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
>> +		list_del(&nextp->lru);
>> +		reset_page(nextp);
>> +		ops->free(nextp);
>> +	}
>> +	reset_page(head_extra);
>> +	ops->free(head_extra);
>> +}
>> +
>> +/* Initialize a newly allocated zspage */
>> +static void init_zspage(struct page *first_page, struct size_class *class)
>> +{
>> +	unsigned long off = 0;
>> +	struct page *page = first_page;
>> +
>> +	BUG_ON(!is_first_page(first_page));
>> +	while (page) {
>> +		struct page *next_page;
>> +		struct link_free *link;
>> +		unsigned int i, objs_on_page;
>> +
>> +		/*
>> +		 * page->index stores offset of first object starting
>> +		 * in the page. For the first page, this is always 0,
>> +		 * so we use first_page->index (aka ->freelist) to store
>> +		 * head of corresponding zspage's freelist.
>> +		 */
>> +		if (page != first_page)
>> +			page->index = off;
>> +
>> +		link = (struct link_free *)kmap_atomic(page) +
>> +						off / sizeof(*link);
>> +		objs_on_page = (PAGE_SIZE - off) / class->size;
>> +
>> +		for (i = 1; i <= objs_on_page; i++) {
>> +			off += class->size;
>> +			if (off < PAGE_SIZE) {
>> +				link->next = obj_location_to_handle(page, i);
>> +				link += class->size / sizeof(*link);
>> +			}
>> +		}
>> +
>> +		/*
>> +		 * We now come to the last (full or partial) object on this
>> +		 * page, which must point to the first object on the next
>> +		 * page (if present)
>> +		 */
>> +		next_page = get_next_page(page);
>> +		link->next = obj_location_to_handle(next_page, 0);
>> +		kunmap_atomic(link);
>> +		page = next_page;
>> +		off = (off + class->size) % PAGE_SIZE;
>> +	}
>> +}
>> +
>> +/*
>> + * Allocate a zspage for the given size class
>> + */
>> +static struct page *alloc_zspage(struct zs_ops *ops, struct size_class *class,
>> +				gfp_t flags)
>> +{
>> +	int i, error;
>> +	struct page *first_page = NULL, *uninitialized_var(prev_page);
>> +
>> +	/*
>> +	 * Allocate individual pages and link them together as:
>> +	 * 1. first page->private = first sub-page
>> +	 * 2. all sub-pages are linked together using page->lru
>> +	 * 3. each sub-page is linked to the first page using page->first_page
>> +	 *
>> +	 * For each size class, First/Head pages are linked together using
>> +	 * page->lru. Also, we set PG_private to identify the first page
>> +	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
>> +	 * identify the last page.
>> +	 */
>> +	error = -ENOMEM;
>> +	for (i = 0; i < class->pages_per_zspage; i++) {
>> +		struct page *page;
>> +
>> +		page = ops->alloc(flags);
>> +		if (!page)
>> +			goto cleanup;
>> +
>> +		INIT_LIST_HEAD(&page->lru);
>> +		if (i == 0) {	/* first page */
>> +			SetPagePrivate(page);
>> +			set_page_private(page, 0);
>> +			first_page = page;
>> +			first_page->inuse = 0;
>> +		}
>> +		if (i == 1)
>> +			first_page->private = (unsigned long)page;
>> +		if (i >= 1)
>> +			page->first_page = first_page;
>> +		if (i >= 2)
>> +			list_add(&page->lru, &prev_page->lru);
>> +		if (i == class->pages_per_zspage - 1)	/* last page */
>> +			SetPagePrivate2(page);
>> +		prev_page = page;
>> +	}
>> +
>> +	init_zspage(first_page, class);
>> +
>> +	first_page->freelist = obj_location_to_handle(first_page, 0);
>> +	/* Maximum number of objects we can store in this zspage */
>> +	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
>> +
>> +	error = 0; /* Success */
>> +
>> +cleanup:
>> +	if (unlikely(error) && first_page) {
>> +		free_zspage(ops, first_page);
>> +		first_page = NULL;
>> +	}
>> +
>> +	return first_page;
>> +}
>> +
>> +static struct page *find_get_zspage(struct size_class *class)
>> +{
>> +	int i;
>> +	struct page *page;
>> +
>> +	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
>> +		page = class->fullness_list[i];
>> +		if (page)
>> +			break;
>> +	}
>> +
>> +	return page;
>> +}
>> +
>> +#ifdef CONFIG_PGTABLE_MAPPING
>> +static inline int __zs_cpu_up(struct mapping_area *area)
>> +{
>> +	/*
>> +	 * Make sure we don't leak memory if a cpu UP notification
>> +	 * and zs_init() race and both call zs_cpu_up() on the same cpu
>> +	 */
>> +	if (area->vm)
>> +		return 0;
>> +	area->vm = alloc_vm_area(PAGE_SIZE * 2, NULL);
>> +	if (!area->vm)
>> +		return -ENOMEM;
>> +	return 0;
>> +}
>> +
>> +static inline void __zs_cpu_down(struct mapping_area *area)
>> +{
>> +	if (area->vm)
>> +		free_vm_area(area->vm);
>> +	area->vm = NULL;
>> +}
>> +
>> +static inline void *__zs_map_object(struct mapping_area *area,
>> +				struct page *pages[2], int off, int size)
>> +{
>> +	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));
>> +	area->vm_addr = area->vm->addr;
>> +	return area->vm_addr + off;
>> +}
>> +
>> +static inline void __zs_unmap_object(struct mapping_area *area,
>> +				struct page *pages[2], int off, int size)
>> +{
>> +	unsigned long addr = (unsigned long)area->vm_addr;
>> +	unsigned long end = addr + (PAGE_SIZE * 2);
>> +
>> +	flush_cache_vunmap(addr, end);
>> +	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
>> +	flush_tlb_kernel_range(addr, end);
>> +}
>> +
>> +#else /* CONFIG_PGTABLE_MAPPING*/
>> +
>> +static inline int __zs_cpu_up(struct mapping_area *area)
>> +{
>> +	/*
>> +	 * Make sure we don't leak memory if a cpu UP notification
>> +	 * and zs_init() race and both call zs_cpu_up() on the same cpu
>> +	 */
>> +	if (area->vm_buf)
>> +		return 0;
>> +	area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
>> +	if (!area->vm_buf)
>> +		return -ENOMEM;
>> +	return 0;
>> +}
>> +
>> +static inline void __zs_cpu_down(struct mapping_area *area)
>> +{
>> +	if (area->vm_buf)
>> +		free_page((unsigned long)area->vm_buf);
>> +	area->vm_buf = NULL;
>> +}
>> +
>> +static void *__zs_map_object(struct mapping_area *area,
>> +			struct page *pages[2], int off, int size)
>> +{
>> +	int sizes[2];
>> +	void *addr;
>> +	char *buf = area->vm_buf;
>> +
>> +	/* disable page faults to match kmap_atomic() return conditions */
>> +	pagefault_disable();
>> +
>> +	/* no read fastpath */
>> +	if (area->vm_mm == ZS_MM_WO)
>> +		goto out;
> 
> Current implementation of 'ZS_MM_WO' is not safe.
> For example, think about a situation like as mapping 512 bytes and writing
> only 8 bytes. When we unmap_object, remaining area will be filled with
> dummy bytes, but not original values.

I guess I should comment on the cavet with ZS_MM_WO.  The idea is that
the user is planning to initialize the entire allocation region.  So you
wouldn't use ZS_MM_WO to do a partial write to the region.  You'd have
to use ZS_MM_RW in that case so that the existing region is maintained.

Worthy of a comment. I'd add one.

> 
> If above comments are not important for now, feel free to ignore them. :)

Great comments!  The insight they contain demonstrate that you have a
great understanding of the code, which I find encouraging (i.e. that the
code is not too complex to be understood by reviewers).

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
