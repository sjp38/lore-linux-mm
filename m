Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 41CFA6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 18:10:54 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so720714pab.22
        for <linux-mm@kvack.org>; Tue, 20 May 2014 15:10:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gh5si3570918pbc.245.2014.05.20.15.10.53
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 15:10:53 -0700 (PDT)
Date: Tue, 20 May 2014 15:10:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] zram: remove global tb_lock with fine grain lock
Message-Id: <20140520151051.72912b8a7ecc5d460c871a58@linux-foundation.org>
In-Reply-To: <000101cf7013$f646ac30$e2d40490$%yang@samsung.com>
References: <000101cf7013$f646ac30$e2d40490$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Heesub Shin' <heesub.shin@samsung.com>, 'Davidlohr Bueso' <davidlohr@hp.com>, 'Joonsoo Kim' <js1304@gmail.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Thu, 15 May 2014 16:00:47 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

> Currently, we use a rwlock tb_lock to protect concurrent access to
> the whole zram meta table. However, according to the actual access model,
> there is only a small chance for upper user to access the same table[index],
> so the current lock granularity is too big.
> 
> The idea of optimization is to change the lock granularity from whole
> meta table to per table entry (table -> table[index]), so that we can
> protect concurrent access to the same table[index], meanwhile allow
> the maximum concurrency.
> With this in mind, several kinds of locks which could be used as a
> per-entry lock were tested and compared:
> 
> ...
>
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -179,23 +179,32 @@ static ssize_t comp_algorithm_store(struct device *dev,
>  	return len;
>  }
>  
> -/* flag operations needs meta->tb_lock */
> -static int zram_test_flag(struct zram_meta *meta, u32 index,
> -			enum zram_pageflags flag)
> +static int zram_test_zero(struct zram_meta *meta, u32 index)
>  {
> -	return meta->table[index].flags & BIT(flag);
> +	return meta->table[index].value & BIT(ZRAM_ZERO);
>  }
>  
> -static void zram_set_flag(struct zram_meta *meta, u32 index,
> -			enum zram_pageflags flag)
> +static void zram_set_zero(struct zram_meta *meta, u32 index)
>  {
> -	meta->table[index].flags |= BIT(flag);
> +	meta->table[index].value |= BIT(ZRAM_ZERO);
>  }
>  
> -static void zram_clear_flag(struct zram_meta *meta, u32 index,
> -			enum zram_pageflags flag)
> +static void zram_clear_zero(struct zram_meta *meta, u32 index)
>  {
> -	meta->table[index].flags &= ~BIT(flag);
> +	meta->table[index].value &= ~BIT(ZRAM_ZERO);
> +}
> +
> +static int zram_get_obj_size(struct zram_meta *meta, u32 index)
> +{
> +	return meta->table[index].value & (BIT(ZRAM_FLAG_SHIFT) - 1);
> +}
> +
> +static void zram_set_obj_size(struct zram_meta *meta,
> +					u32 index, int size)
> +{
> +	meta->table[index].value = (unsigned long)size |
> +		((meta->table[index].value >> ZRAM_FLAG_SHIFT)
> +		<< ZRAM_FLAG_SHIFT );
>  }

Let's sort out the types here?  It makes no sense for `size' to be
signed.  And I don't think we need *any* 64-bit quantities here
(discussed below).

So I think we can make `size' a u32 and remove that typecast.

Also, please use checkpatch ;)

>  static inline int is_partial_io(struct bio_vec *bvec)
> @@ -255,7 +264,6 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
>  		goto free_table;
>  	}
>  
> -	rwlock_init(&meta->tb_lock);
>  	return meta;
>  
>  free_table:
> @@ -304,19 +312,19 @@ static void handle_zero_page(struct bio_vec *bvec)
>  	flush_dcache_page(page);
>  }
>  
> -/* NOTE: caller should hold meta->tb_lock with write-side */

Can we please update this important comment rather than simply deleting
it?

>  static void zram_free_page(struct zram *zram, size_t index)
>  {
>  	struct zram_meta *meta = zram->meta;
>  	unsigned long handle = meta->table[index].handle;
> +	int size;
>  
>  	if (unlikely(!handle)) {
>  		/*
>  		 * No memory is allocated for zero filled pages.
>  		 * Simply clear zero page flag.
>  		 */
> -		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
> -			zram_clear_flag(meta, index, ZRAM_ZERO);
> +		if (zram_test_zero(meta, index)) {
> +			zram_clear_zero(meta, index);
>  			atomic64_dec(&zram->stats.zero_pages);
>  		}
>  		return;
>
> ...
>
> @@ -64,9 +76,8 @@ enum zram_pageflags {
>  /* Allocated for each disk page */
>  struct table {
>  	unsigned long handle;
> -	u16 size;	/* object size (excluding header) */
> -	u8 flags;
> -} __aligned(4);
> +	unsigned long value;
> +};

Does `value' need to be 64 bit on 64-bit machines?  I think u32 will be
sufficient?  The struct will still be 16 bytes but if we then play
around adding __packed to this structure we should be able to shrink it
to 12 bytes, save large amounts of memory?

And does `handle' need to be 64-bit on 64-bit?


Problem is, if we make optimisations such as this we will smash head-on
into the bit_spin_lock() requirement that it operate on a ulong*. 
Which is due to the bitops requiring a ulong*.  How irritating.


um, something like

union table {		/* Should be called table_entry */
	unsigned long ul;
	struct {
		u32 size_and_flags;
		u32 handle;
	} s;
};

That's a 64-bit structure containing 32-bit handle and 8-bit flags and
24-bit size.

I'm tempted to use bitfields here but that could get messy as we handle
endianness.

static void zram_table_lock(union table *table)
{
#ifdef __LITTLE_ENDIAN
	bit_spin_lock(ZRAM_ACCESS, &t->ul);
#else
#ifdef CONFIG_64BIT
	bit_spin_lock(ZRAM_ACCESS ^ (3 << 3), &t->ul);
#else
	bit_spin_lock(ZRAM_ACCESS ^ (7 << 3), &t->ul);
#endif
#endif
}

Or something like that ;)  And I don't know if it's correct to use
32-bit handle on 64-bit.

But you get the idea.  It's worth spending time over this because the
space savings will be quite large.

>  struct zram_stats {
>  	atomic64_t compr_data_size;	/* compressed size of pages stored */
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
