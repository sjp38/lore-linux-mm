Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 63EF06B0083
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 16:10:21 -0400 (EDT)
Received: by fxm20 with SMTP id 20so2445683fxm.38
        for <linux-mm@kvack.org>; Mon, 14 Sep 2009 13:10:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200909100249.26284.ngupta@vflare.org>
References: <200909100215.36350.ngupta@vflare.org>
	 <200909100249.26284.ngupta@vflare.org>
Date: Mon, 14 Sep 2009 23:10:22 +0300
Message-ID: <84144f020909141310y164b2d1ak44dd6945d35e6ec@mail.gmail.com>
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi Nitin,

I am not a block driver expert but here are some comments on the code
that probably need to be addressed before merging.

                        Pekka

On Thu, Sep 10, 2009 at 12:19 AM, Nitin Gupta <ngupta@vflare.org> wrote:
> @@ -0,0 +1,1529 @@
> +/*
> + * Compressed RAM based swap device
> + *
> + * Copyright (C) 2008, 2009 =A0Nitin Gupta
> + *
> + * This code is released using a dual license strategy: BSD/GPL
> + * You can choose the licence that better fits your requirements.
> + *
> + * Released under the terms of 3-clause BSD License
> + * Released under the terms of GNU General Public License Version 2.0
> + *
> + * Project home: http://compcache.googlecode.com
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/bitops.h>
> +#include <linux/blkdev.h>
> +#include <linux/buffer_head.h>
> +#include <linux/device.h>
> +#include <linux/genhd.h>
> +#include <linux/highmem.h>
> +#include <linux/lzo.h>
> +#include <linux/marker.h>
> +#include <linux/mutex.h>
> +#include <linux/string.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +#include <linux/vmalloc.h>
> +#include <linux/version.h>
> +
> +#include "ramzswap_drv.h"
> +
> +/* Globals */
> +static int RAMZSWAP_MAJOR;
> +static struct ramzswap *DEVICES;
> +
> +/*
> + * Pages that compress to larger than this size are
> + * forwarded to backing swap, if present or stored
> + * uncompressed in memory otherwise.
> + */
> +static unsigned int MAX_CPAGE_SIZE;
> +
> +/* Module params (documentation at end) */
> +static unsigned long NUM_DEVICES;

These variable names should be in lower case.

> +
> +/* Function declarations */
> +static int __init ramzswap_init(void);
> +static int ramzswap_ioctl(struct block_device *, fmode_t,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned, unsigned long);
> +static int setup_swap_header(struct ramzswap *, union swap_header *);
> +static void ramzswap_set_memlimit(struct ramzswap *, size_t);
> +static void ramzswap_set_disksize(struct ramzswap *, size_t);
> +static void reset_device(struct ramzswap *rzs);

It's preferable not to use forward declarations in new kernel code.

> +static int test_flag(struct ramzswap *rzs, u32 index, enum rzs_pageflags=
 flag)
> +{
> + =A0 =A0 =A0 return rzs->table[index].flags & BIT(flag);
> +}
> +
> +static void set_flag(struct ramzswap *rzs, u32 index, enum rzs_pageflags=
 flag)
> +{
> + =A0 =A0 =A0 rzs->table[index].flags |=3D BIT(flag);
> +}
> +
> +static void clear_flag(struct ramzswap *rzs, u32 index,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 enum rzs_pageflags flag)
> +{
> + =A0 =A0 =A0 rzs->table[index].flags &=3D ~BIT(flag);
> +}

These function names could use a ramzswap specific prefix.

> +
> +static int page_zero_filled(void *ptr)
> +{
> + =A0 =A0 =A0 u32 pos;
> + =A0 =A0 =A0 u64 *page;
> +
> + =A0 =A0 =A0 page =3D (u64 *)ptr;
> +
> + =A0 =A0 =A0 for (pos =3D 0; pos !=3D PAGE_SIZE / sizeof(*page); pos++) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page[pos])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 1;
> +}

This looks like something that could be in lib/string.c.

/me looks

There's strspn so maybe you could introduce a memspn equivalent.

> +
> +/*
> + * Given <pagenum, offset> pair, provide a dereferencable pointer.
> + */
> +static void *get_ptr_atomic(struct page *page, u16 offset, enum km_type =
type)
> +{
> + =A0 =A0 =A0 unsigned char *base;
> +
> + =A0 =A0 =A0 base =3D kmap_atomic(page, type);
> + =A0 =A0 =A0 return base + offset;
> +}
> +
> +static void put_ptr_atomic(void *ptr, enum km_type type)
> +{
> + =A0 =A0 =A0 kunmap_atomic(ptr, type);
> +}

These two functions also appear in xmalloc. It's probably best to just
kill the wrappers and use kmap/kunmap directly.

> +
> +static void ramzswap_flush_dcache_page(struct page *page)
> +{
> +#ifdef CONFIG_ARM
> + =A0 =A0 =A0 int flag =3D 0;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Ugly hack to get flush_dcache_page() work on ARM.
> + =A0 =A0 =A0 =A0* page_mapping(page) =3D=3D NULL after clearing this swa=
p cache flag.
> + =A0 =A0 =A0 =A0* Without clearing this flag, flush_dcache_page() will s=
imply set
> + =A0 =A0 =A0 =A0* "PG_dcache_dirty" bit and return.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (PageSwapCache(page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flag =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageSwapCache(page);
> + =A0 =A0 =A0 }
> +#endif
> + =A0 =A0 =A0 flush_dcache_page(page);
> +#ifdef CONFIG_ARM
> + =A0 =A0 =A0 if (flag)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageSwapCache(page);
> +#endif
> +}

The above CONFIG_ARM magic really has no place in drivers/block.

> +static int add_backing_swap_extent(struct ramzswap *rzs,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoff_t phy=
_pagenum,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoff_t num=
_pages)
> +{
> + =A0 =A0 =A0 unsigned int idx;
> + =A0 =A0 =A0 struct list_head *head;
> + =A0 =A0 =A0 struct page *curr_page, *new_page;
> + =A0 =A0 =A0 unsigned int extents_per_page =3D PAGE_SIZE /
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(stru=
ct ramzswap_backing_extent);
> +
> + =A0 =A0 =A0 idx =3D rzs->num_extents % extents_per_page;
> + =A0 =A0 =A0 if (!idx) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_page =3D alloc_page(__GFP_ZERO);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!new_page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rzs->num_extents) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 curr_page =3D virt_to_page(=
rzs->curr_extent);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D &curr_page->lru;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D &rzs->backing_swap=
_extent_list;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&new_page->lru, head);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rzs->curr_extent =3D page_address(new_page)=
;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 rzs->curr_extent->phy_pagenum =3D phy_pagenum;
> + =A0 =A0 =A0 rzs->curr_extent->num_pages =3D num_pages;
> +
> + =A0 =A0 =A0 pr_debug(C "extent: [%lu, %lu] %lu\n", phy_pagenum,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_pagenum + num_pages - 1, num_pages);

What's this "C" thing everywhere? A subsystem prefix? Shouldn't you
override pr_fmt() instead?

> +static int ramzswap_write(struct ramzswap *rzs, struct bio *bio)
> +{
> + =A0 =A0 =A0 int ret, fwd_write_request =3D 0;
> + =A0 =A0 =A0 u32 offset;
> + =A0 =A0 =A0 size_t clen;
> + =A0 =A0 =A0 pgoff_t index;
> + =A0 =A0 =A0 struct zobj_header *zheader;
> + =A0 =A0 =A0 struct page *page, *page_store;
> + =A0 =A0 =A0 unsigned char *user_mem, *cmem, *src;
> +
> + =A0 =A0 =A0 stat_inc(rzs->stats.num_writes);
> +
> + =A0 =A0 =A0 page =3D bio->bi_io_vec[0].bv_page;
> + =A0 =A0 =A0 index =3D bio->bi_sector >> SECTORS_PER_PAGE_SHIFT;
> +
> + =A0 =A0 =A0 src =3D rzs->compress_buffer;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* System swaps to same sector again when the stored page
> + =A0 =A0 =A0 =A0* is no longer referenced by any process. So, its now sa=
fe
> + =A0 =A0 =A0 =A0* to free the memory that was allocated for this page.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (rzs->table[index].page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ramzswap_free_page(rzs, index);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* No memory ia allocated for zero filled pages.
> + =A0 =A0 =A0 =A0* Simply clear zero page flag.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (test_flag(rzs, index, RZS_ZERO)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_dec(rzs->stats.pages_zero);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_flag(rzs, index, RZS_ZERO);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 trace_mark(ramzswap_lock_wait, "ramzswap_lock_wait");
> + =A0 =A0 =A0 mutex_lock(&rzs->lock);
> + =A0 =A0 =A0 trace_mark(ramzswap_lock_acquired, "ramzswap_lock_acquired"=
);

Hmm? What's this? I don't think you should be doing ad hoc
trace_mark() in driver code.

> +
> + =A0 =A0 =A0 user_mem =3D get_ptr_atomic(page, 0, KM_USER0);
> + =A0 =A0 =A0 if (page_zero_filled(user_mem)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_ptr_atomic(user_mem, KM_USER0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&rzs->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_inc(rzs->stats.pages_zero);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_flag(rzs, index, RZS_ZERO);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(BIO_UPTODATE, &bio->bi_flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bio_endio(bio, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (rzs->backing_swap &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (rzs->stats.compr_size > rzs->memlimit - PA=
GE_SIZE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_ptr_atomic(user_mem, KM_USER0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&rzs->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fwd_write_request =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ret =3D lzo1x_1_compress(user_mem, PAGE_SIZE, src, &clen,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rzs->compre=
ss_workmem);
> +
> + =A0 =A0 =A0 put_ptr_atomic(user_mem, KM_USER0);
> +
> + =A0 =A0 =A0 if (unlikely(ret !=3D LZO_E_OK)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&rzs->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(C "Compression failed! err=3D%d\n", =
ret);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_inc(rzs->stats.failed_writes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Page is incompressible. Forward it to backing swap
> + =A0 =A0 =A0 =A0* if present. Otherwise, store it as-is (uncompressed)
> + =A0 =A0 =A0 =A0* since we do not want to return too many swap write
> + =A0 =A0 =A0 =A0* errors which has side effect of hanging the system.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (unlikely(clen > MAX_CPAGE_SIZE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rzs->backing_swap) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&rzs->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fwd_write_request =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clen =3D PAGE_SIZE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_store =3D alloc_page(GFP_NOIO | __GFP_=
HIGHMEM);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!page_store)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&rzs->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info(C "Error allocating=
 memory for incompressible "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "page: %lu\=
n", index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_inc(rzs->stats.failed_=
writes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_flag(rzs, index, RZS_UNCOMPRESSED);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_inc(rzs->stats.pages_expand);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rzs->table[index].page =3D page_store;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 src =3D get_ptr_atomic(page, 0, KM_USER0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto memstore;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (xv_malloc(rzs->mem_pool, clen + sizeof(*zheader),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &rzs->table[index].page, &o=
ffset,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_NOIO | __GFP_HIGHMEM)) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&rzs->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info(C "Error allocating memory for comp=
ressed "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "page: %lu, size=3D%zu\n", =
index, clen);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_inc(rzs->stats.failed_writes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rzs->backing_swap)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fwd_write_request =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> +memstore:
> + =A0 =A0 =A0 rzs->table[index].offset =3D offset;
> +
> + =A0 =A0 =A0 cmem =3D get_ptr_atomic(rzs->table[index].page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rzs->table[index].offset, K=
M_USER1);
> +
> +#if 0
> + =A0 =A0 =A0 /* Back-reference needed for memory defragmentation */
> + =A0 =A0 =A0 if (!test_flag(rzs, index, RZS_UNCOMPRESSED)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zheader =3D (struct zobj_header *)cmem;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zheader->table_idx =3D index;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmem +=3D sizeof(*zheader);
> + =A0 =A0 =A0 }
> +#endif

Drop the above dead code?

> +
> + =A0 =A0 =A0 memcpy(cmem, src, clen);
> +
> + =A0 =A0 =A0 put_ptr_atomic(cmem, KM_USER1);
> + =A0 =A0 =A0 if (unlikely(test_flag(rzs, index, RZS_UNCOMPRESSED)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_ptr_atomic(src, KM_USER0);
> +
> + =A0 =A0 =A0 /* Update stats */
> + =A0 =A0 =A0 rzs->stats.compr_size +=3D clen;
> + =A0 =A0 =A0 stat_inc(rzs->stats.pages_stored);
> + =A0 =A0 =A0 stat_inc_if_less(rzs->stats.good_compress, clen, PAGE_SIZE =
/ 2 + 1);
> +
> + =A0 =A0 =A0 mutex_unlock(&rzs->lock);
> +
> + =A0 =A0 =A0 set_bit(BIO_UPTODATE, &bio->bi_flags);
> + =A0 =A0 =A0 bio_endio(bio, 0);
> + =A0 =A0 =A0 return 0;
> +
> +out:
> + =A0 =A0 =A0 if (fwd_write_request) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat_inc(rzs->stats.bdev_num_writes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bio->bi_bdev =3D rzs->backing_swap;
> +#if 0
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: We currently have linear mapping=
 of ramzswap and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* backing swap sectors. This is not desi=
red since we want
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to optimize writes to backing swap to =
minimize disk seeks
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* or have effective wear leveling (for S=
SDs). Also, a
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* non-linear mapping is required to impl=
ement compressed
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* on-disk swapping.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bio->bi_sector =3D get_backing_swap_page=
()
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 << SECTORS_PER_PAGE_SHIFT;
> +#endif

This too?

> +static int ramzswap_ioctl_init_device(struct ramzswap *rzs)
> +{
> + =A0 =A0 =A0 int ret;
> + =A0 =A0 =A0 size_t num_pages, totalram_bytes;
> + =A0 =A0 =A0 struct sysinfo i;
> + =A0 =A0 =A0 struct page *page;
> + =A0 =A0 =A0 union swap_header *swap_header;
> +
> + =A0 =A0 =A0 if (rzs->init_done) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info(C "Device already initialized!\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ret =3D setup_backing_swap(rzs);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
> +
> + =A0 =A0 =A0 si_meminfo(&i);
> + =A0 =A0 =A0 /* Here is a trivia: guess unit used for i.totalram !! */
> + =A0 =A0 =A0 totalram_bytes =3D i.totalram << PAGE_SHIFT;

You can use totalram_pages here. OTOH, I'm not sure why the driver
needs this information. Hmm?

> +
> + =A0 =A0 =A0 if (rzs->backing_swap)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ramzswap_set_memlimit(rzs, totalram_bytes);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ramzswap_set_disksize(rzs, totalram_bytes);
> +
> + =A0 =A0 =A0 rzs->compress_workmem =3D kzalloc(LZO1X_MEM_COMPRESS, GFP_K=
ERNEL);
> + =A0 =A0 =A0 if (rzs->compress_workmem =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(C "Error allocating compressor worki=
ng memory!\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 rzs->compress_buffer =3D kzalloc(2 * PAGE_SIZE, GFP_KERNEL)=
;

Use alloc_pages(__GFP_ZERO) here?

> diff --git a/drivers/block/ramzswap/ramzswap_drv.h b/drivers/block/ramzsw=
ap/ramzswap_drv.h
> new file mode 100644
> index 0000000..7f77edc
> --- /dev/null
> +++ b/drivers/block/ramzswap/ramzswap_drv.h

> +
> +#define SECTOR_SHIFT =A0 =A0 =A0 =A0 =A0 9
> +#define SECTOR_SIZE =A0 =A0 =A0 =A0 =A0 =A0(1 << SECTOR_SHIFT)
> +#define SECTORS_PER_PAGE_SHIFT (PAGE_SHIFT - SECTOR_SHIFT)
> +#define SECTORS_PER_PAGE =A0 =A0 =A0 (1 << SECTORS_PER_PAGE_SHIFT)

Don't we have these defines somewhere in include/linux?

> +
> +/* Message prefix */
> +#define C "ramzswap: "

Use pr_fmt() instead.

> +
> +/* Debugging and Stats */
> +#define NOP =A0 =A0do { } while (0)

Huh? Drop this.

> +
> +#if defined(CONFIG_BLK_DEV_RAMZSWAP_STATS)
> +#define STATS
> +#endif

Why can't you rename that to CONFIG_RAMZSWAP_STATS and use that
instead of the very generic STATS?

> +
> +#if defined(STATS)
> +#define stat_inc(stat) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat)++)
> +#define stat_dec(stat) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat)--)
> +#define stat_inc_if_less(stat, val1, val2) \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat) +=
=3D ((val1) < (val2) ? 1 : 0))
> +#define stat_dec_if_less(stat, val1, val2) \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((stat) -=
=3D ((val1) < (val2) ? 1 : 0))
> +#else =A0/* STATS */
> +#define stat_inc(x) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NOP
> +#define stat_dec(x) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NOP
> +#define stat_inc_if_less(x, v1, v2) =A0 =A0NOP
> +#define stat_dec_if_less(x, v1, v2) =A0 =A0NOP
> +#endif /* STATS */

Why do you need inc_if_less() and dec_if_less()? And why are these not
static inlines?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
