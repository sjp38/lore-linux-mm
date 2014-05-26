Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8942E6B0035
	for <linux-mm@kvack.org>; Mon, 26 May 2014 03:55:28 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so7375603iec.37
        for <linux-mm@kvack.org>; Mon, 26 May 2014 00:55:28 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id ad4si16550330igd.13.2014.05.26.00.55.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 00:55:27 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id tp5so7344750ieb.39
        for <linux-mm@kvack.org>; Mon, 26 May 2014 00:55:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140521075130.GB3983@bbox>
References: <000101cf7013$f646ac30$e2d40490$%yang@samsung.com>
	<20140520151051.72912b8a7ecc5d460c871a58@linux-foundation.org>
	<20140521075130.GB3983@bbox>
Date: Mon, 26 May 2014 15:55:27 +0800
Message-ID: <CAL1ERfO5TXHD50gAYJmGZo-=mS2MPoMgQ_YTE3uWJo4sj1K3zg@mail.gmail.com>
Subject: Re: [PATCH v2] zram: remove global tb_lock with fine grain lock
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Bob Liu <bob.liu@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Heesub Shin <heesub.shin@samsung.com>, Davidlohr Bueso <davidlohr@hp.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hello,

Sorry for my late reply, because of a biz trip.

On Wed, May 21, 2014 at 3:51 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hello Andrew,
>
> On Tue, May 20, 2014 at 03:10:51PM -0700, Andrew Morton wrote:
>> On Thu, 15 May 2014 16:00:47 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:
>>
>> > Currently, we use a rwlock tb_lock to protect concurrent access to
>> > the whole zram meta table. However, according to the actual access model,
>> > there is only a small chance for upper user to access the same table[index],
>> > so the current lock granularity is too big.
>> >
>> > The idea of optimization is to change the lock granularity from whole
>> > meta table to per table entry (table -> table[index]), so that we can
>> > protect concurrent access to the same table[index], meanwhile allow
>> > the maximum concurrency.
>> > With this in mind, several kinds of locks which could be used as a
>> > per-entry lock were tested and compared:
>> >
>> > ...
>> >
>> > --- a/drivers/block/zram/zram_drv.c
>> > +++ b/drivers/block/zram/zram_drv.c
>> > @@ -179,23 +179,32 @@ static ssize_t comp_algorithm_store(struct device *dev,
>> >     return len;
>> >  }
>> >
>> > -/* flag operations needs meta->tb_lock */
>> > -static int zram_test_flag(struct zram_meta *meta, u32 index,
>> > -                   enum zram_pageflags flag)
>> > +static int zram_test_zero(struct zram_meta *meta, u32 index)
>> >  {
>> > -   return meta->table[index].flags & BIT(flag);
>> > +   return meta->table[index].value & BIT(ZRAM_ZERO);
>> >  }
>> >
>> > -static void zram_set_flag(struct zram_meta *meta, u32 index,
>> > -                   enum zram_pageflags flag)
>> > +static void zram_set_zero(struct zram_meta *meta, u32 index)
>> >  {
>> > -   meta->table[index].flags |= BIT(flag);
>> > +   meta->table[index].value |= BIT(ZRAM_ZERO);
>> >  }
>> >
>> > -static void zram_clear_flag(struct zram_meta *meta, u32 index,
>> > -                   enum zram_pageflags flag)
>> > +static void zram_clear_zero(struct zram_meta *meta, u32 index)
>> >  {
>> > -   meta->table[index].flags &= ~BIT(flag);
>> > +   meta->table[index].value &= ~BIT(ZRAM_ZERO);
>> > +}
>> > +
>> > +static int zram_get_obj_size(struct zram_meta *meta, u32 index)
>> > +{
>> > +   return meta->table[index].value & (BIT(ZRAM_FLAG_SHIFT) - 1);
>> > +}
>> > +
>> > +static void zram_set_obj_size(struct zram_meta *meta,
>> > +                                   u32 index, int size)
>> > +{
>> > +   meta->table[index].value = (unsigned long)size |
>> > +           ((meta->table[index].value >> ZRAM_FLAG_SHIFT)
>> > +           << ZRAM_FLAG_SHIFT );
>> >  }
>>
>> Let's sort out the types here?  It makes no sense for `size' to be
>> signed.  And I don't think we need *any* 64-bit quantities here
>> (discussed below).
>>
>> So I think we can make `size' a u32 and remove that typecast.
>>
>> Also, please use checkpatch ;)
>>

I will remove the typecast and do checkpatch in the next patch version.

>> >  static inline int is_partial_io(struct bio_vec *bvec)
>> > @@ -255,7 +264,6 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
>> >             goto free_table;
>> >     }
>> >
>> > -   rwlock_init(&meta->tb_lock);
>> >     return meta;
>> >
>> >  free_table:
>> > @@ -304,19 +312,19 @@ static void handle_zero_page(struct bio_vec *bvec)
>> >     flush_dcache_page(page);
>> >  }
>> >
>> > -/* NOTE: caller should hold meta->tb_lock with write-side */
>>
>> Can we please update this important comment rather than simply deleting
>> it?
>>

Of couse, I will update it.

>> >  static void zram_free_page(struct zram *zram, size_t index)
>> >  {
>> >     struct zram_meta *meta = zram->meta;
>> >     unsigned long handle = meta->table[index].handle;
>> > +   int size;
>> >
>> >     if (unlikely(!handle)) {
>> >             /*
>> >              * No memory is allocated for zero filled pages.
>> >              * Simply clear zero page flag.
>> >              */
>> > -           if (zram_test_flag(meta, index, ZRAM_ZERO)) {
>> > -                   zram_clear_flag(meta, index, ZRAM_ZERO);
>> > +           if (zram_test_zero(meta, index)) {
>> > +                   zram_clear_zero(meta, index);
>> >                     atomic64_dec(&zram->stats.zero_pages);
>> >             }
>> >             return;
>> >
>> > ...
>> >
>> > @@ -64,9 +76,8 @@ enum zram_pageflags {
>> >  /* Allocated for each disk page */
>> >  struct table {
>> >     unsigned long handle;
>> > -   u16 size;       /* object size (excluding header) */
>> > -   u8 flags;
>> > -} __aligned(4);
>> > +   unsigned long value;
>> > +};
>>
>> Does `value' need to be 64 bit on 64-bit machines?  I think u32 will be
>> sufficient?  The struct will still be 16 bytes but if we then play
>> around adding __packed to this structure we should be able to shrink it
>> to 12 bytes, save large amounts of memory?
>>

I agree that u32 is sufficient to value(size and flags), the reason I choice
unsigned long is as you said bit_spin_lock() requires a ulong *.

>> And does `handle' need to be 64-bit on 64-bit?
>
> To me, it's a buggy. We should not have used (unsigned long) as zsmalloc's
> handle from the beginning. Sometime it might be bigger than sizeof(unsigned long)
> because zsmalloc's handle consists of (pfn, obj idx) so pfn itself is already
> unsigned long but more practically, if we consider MAX_PHYSMEM_BITS of arch
> and zsmalloc's min size class we have some room for obj_idx which is offset
> from each pages(I think that's why it isn't a problem for CONFIG_X86_32 PAE)
> but MAX_PHYSMEM_BITS is really arch dependent thing and zsmalloc's class size
> could be changed in future so we can't make sure in (exisiting/upcoming)
> all architecture, (MAX_PHYSMEM_BITS + bit for obj_idx) is less than
> unsigned long. So we should use zs_handle rather than unsigned log and
> zs_handle's size shouldn't expose to user. :(
>
> So, I'm fine with Weijie's patch other than naming Andrew pointed out.
> I like size_and_flags. :)
>

Andrew proposed a pack idea to save more memory, when I go through it,
I think I am not convinced to use it, because:
1. it doesn't help on 32-bit system, while most embedded system are 32-bit.
2. it make code messy and unreadable.
3. it will help on 64-bit system only if "handle" can be 32-bit, but I
am not sure it.

Minchan said it's better to hide "handle" size to user, if it becomes
true, it will
be more messy for the upper pack code.

So, I like to insist this v2 patch design on the table entry.

>>
>>
>> Problem is, if we make optimisations such as this we will smash head-on
>> into the bit_spin_lock() requirement that it operate on a ulong*.
>> Which is due to the bitops requiring a ulong*.  How irritating.
>>
>>
>> um, something like
>>
>> union table {         /* Should be called table_entry */
>>       unsigned long ul;
>>       struct {
>>               u32 size_and_flags;
>>               u32 handle;
>>       } s;
>> };
>>
>> That's a 64-bit structure containing 32-bit handle and 8-bit flags and
>> 24-bit size.
>>
>> I'm tempted to use bitfields here but that could get messy as we handle
>> endianness.
>>
>> static void zram_table_lock(union table *table)
>> {
>> #ifdef __LITTLE_ENDIAN
>>       bit_spin_lock(ZRAM_ACCESS, &t->ul);
>> #else
>> #ifdef CONFIG_64BIT
>>       bit_spin_lock(ZRAM_ACCESS ^ (3 << 3), &t->ul);
>> #else
>>       bit_spin_lock(ZRAM_ACCESS ^ (7 << 3), &t->ul);
>> #endif
>> #endif
>> }
>>
>> Or something like that ;)  And I don't know if it's correct to use
>> 32-bit handle on 64-bit.
>>
>> But you get the idea.  It's worth spending time over this because the
>> space savings will be quite large.
>>
>> >  struct zram_stats {
>> >     atomic64_t compr_data_size;     /* compressed size of pages stored */
>> >
>> > ...
>> >
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
