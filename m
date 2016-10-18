Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1DC6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 22:45:41 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x23so1162079lfi.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 19:45:41 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id u1si5403897lff.331.2016.10.17.19.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 19:45:39 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id x79so29960263lff.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 19:45:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONBWyX0OjJUcyyj23vqpJtbx-8fHakdDzrywvgZDZyVq6w@mail.gmail.com>
References: <20161015135632.541010b55bec496e2cae056e@gmail.com>
 <20161015140520.ee52a80c92c50214a6614977@gmail.com> <CALZtONBWyX0OjJUcyyj23vqpJtbx-8fHakdDzrywvgZDZyVq6w@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 18 Oct 2016 04:45:38 +0200
Message-ID: <CAMJBoFPORDkVnpX5tf6zoYPxQWXA1Aayvff5s8iRWw0mLSg7OQ@mail.gmail.com>
Subject: Re: [PATCH v5 3/3] z3fold: add shrinker
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>

Hi Dan,

On Tue, Oct 18, 2016 at 4:06 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Sat, Oct 15, 2016 at 8:05 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>> This patch implements shrinker for z3fold. This shrinker
>> implementation does not free up any pages directly but it allows
>> for a denser placement of compressed objects which results in
>> less actual pages consumed and higher compression ratio therefore.
>>
>> This update removes z3fold page compaction from the freeing path
>> since we can rely on shrinker to do the job. Also, a new flag
>> UNDER_COMPACTION is introduced to protect against two threads
>> trying to compact the same page.
>
> i'm completely unconvinced that this should be a shrinker.  The
> alloc/free paths are much, much better suited to compacting a page
> than a shrinker that must scan through all the unbuddied pages.  Why
> not just improve compaction for the alloc/free paths?

Basically the main reason is performance, I want to avoid compaction on hot
paths as much as possible. This patchset brings both performance and
compression ratio gain, I'm not sure how to achieve that with improving
compaction on alloc/free paths.

>
>>
>> This patch has been checked with the latest Linus's tree.
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>> ---
>>  mm/z3fold.c | 144 +++++++++++++++++++++++++++++++++++++++++++++++++-----------
>>  1 file changed, 119 insertions(+), 25 deletions(-)
>>
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> index 10513b5..8f84d3c 100644
>> --- a/mm/z3fold.c
>> +++ b/mm/z3fold.c
>> @@ -27,6 +27,7 @@
>>  #include <linux/mm.h>
>>  #include <linux/module.h>
>>  #include <linux/preempt.h>
>> +#include <linux/shrinker.h>
>>  #include <linux/slab.h>
>>  #include <linux/spinlock.h>
>>  #include <linux/zpool.h>
>> @@ -72,6 +73,7 @@ struct z3fold_ops {
>>   * @unbuddied_nr:      number of unbuddied z3fold pages in the pool.
>>   * @ops:       pointer to a structure of user defined operations specified at
>>   *             pool creation time.
>> + * @shrinker:  shrinker structure to optimize page layout in background
>>   *
>>   * This structure is allocated at pool creation time and maintains metadata
>>   * pertaining to a particular z3fold pool.
>> @@ -86,6 +88,7 @@ struct z3fold_pool {
>>         const struct z3fold_ops *ops;
>>         struct zpool *zpool;
>>         const struct zpool_ops *zpool_ops;
>> +       struct shrinker shrinker;
>>  };
>>
>>  enum buddy {
>> @@ -121,6 +124,7 @@ enum z3fold_page_flags {
>>         UNDER_RECLAIM = 0,
>>         PAGE_HEADLESS,
>>         MIDDLE_CHUNK_MAPPED,
>> +       UNDER_COMPACTION,
>>  };
>>
>>  /*****************
>> @@ -136,6 +140,9 @@ static int size_to_chunks(size_t size)
>>  #define for_each_unbuddied_list(_iter, _begin) \
>>         for ((_iter) = (_begin); (_iter) < NCHUNKS; (_iter)++)
>>
>> +#define for_each_unbuddied_list_down(_iter, _end) \
>> +       for ((_iter) = (_end); (_iter) > 0; (_iter)--)
>> +
>
> bikeshed: the conventional suffix is _reverse, not _down, i.e.
> for_each_unbuddied_list_reverse()

Ok :)

>>  /* Initializes the z3fold header of a newly allocated z3fold page */
>>  static struct z3fold_header *init_z3fold_page(struct page *page)
>>  {
>> @@ -145,6 +152,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
>>         clear_bit(UNDER_RECLAIM, &page->private);
>>         clear_bit(PAGE_HEADLESS, &page->private);
>>         clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>> +       clear_bit(UNDER_COMPACTION, &page->private);
>>
>>         zhdr->first_chunks = 0;
>>         zhdr->middle_chunks = 0;
>> @@ -211,6 +219,103 @@ static int num_free_chunks(struct z3fold_header *zhdr)
>>         return nfree;
>>  }
>>
>> +/* Has to be called with lock held */
>> +static int z3fold_compact_page(struct z3fold_header *zhdr, bool sync)
>> +{
>> +       struct page *page = virt_to_page(zhdr);
>> +       void *beg = zhdr;
>> +
>> +
>> +       if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
>> +           !test_bit(UNDER_RECLAIM, &page->private) &&
>> +           !test_bit(UNDER_COMPACTION, &page->private)) {
>> +               set_bit(UNDER_COMPACTION, &page->private);
>
> i assume the reclaim check, and new compaction bit check, is due to
> the removal of the spinlock, which was incorrect.  changing to a
> per-page spinlock may be the best way to handle this, but flags are
> absolutely not appropriate - they don't provide the needed locking.
> Even if the compaction bit was the only locking needed (which it
> isn't), it still isn't correct here - while extremely unlikely, it's
> still possible for multiple threads to race between checking the
> compaction bit, and setting it.  That's what test_and_set_bit() is
> for.

Yep, thanks, will fix that.

>
>> +               if (zhdr->middle_chunks != 0 &&
>
> only need to check if the middle bud is in use once; if it isn't,
> there's no compaction to do.
>
>> +                   zhdr->first_chunks == 0 &&
>> +                   zhdr->last_chunks == 0) {
>> +                       memmove(beg + ZHDR_SIZE_ALIGNED,
>> +                               beg + (zhdr->start_middle << CHUNK_SHIFT),
>> +                               zhdr->middle_chunks << CHUNK_SHIFT);
>> +                       zhdr->first_chunks = zhdr->middle_chunks;
>> +                       zhdr->middle_chunks = 0;
>> +                       zhdr->start_middle = 0;
>> +                       zhdr->first_num++;
>> +                       clear_bit(UNDER_COMPACTION, &page->private);
>> +                       return 1;
>> +               }
>> +               if (sync)
>> +                       goto out;
>
> i don't get it, why is that compaction synchronous while the others
> below aren't?

That is the "important" compaction which changes first_num and brings the
biggest benefit. Moving middle object closer to another existing one is not
so important ratio wise, so the idea was to leave that for the shrinker.

>
>> +
>> +               /* moving data is expensive, so let's only do that if
>> +                * there's substantial gain (2+ chunks)
>
> "at least 2 chunks" feels arbitrary...it should be a #define instead
> of a magic number...

...or the module parameter but that could be added later.

>> +                */
>> +               if (zhdr->middle_chunks != 0 && zhdr->first_chunks != 0 &&
>> +                   zhdr->last_chunks == 0 &&
>> +                   zhdr->start_middle > zhdr->first_chunks + 2) {
>> +                       unsigned short new_start = zhdr->first_chunks + 1;
>> +                       memmove(beg + (new_start << CHUNK_SHIFT),
>> +                               beg + (zhdr->start_middle << CHUNK_SHIFT),
>> +                               zhdr->middle_chunks << CHUNK_SHIFT);
>> +                       zhdr->start_middle = new_start;
>> +                       clear_bit(UNDER_COMPACTION, &page->private);
>> +                       return 1;
>> +               }
>> +               if (zhdr->middle_chunks != 0 && zhdr->last_chunks != 0 &&
>> +                   zhdr->first_chunks == 0 &&
>> +                   zhdr->middle_chunks + zhdr->last_chunks <=
>> +                   NCHUNKS - zhdr->start_middle - 2) {
>> +                       unsigned short new_start = NCHUNKS - zhdr->last_chunks -
>> +                               zhdr->middle_chunks;
>> +                       memmove(beg + (new_start << CHUNK_SHIFT),
>> +                               beg + (zhdr->start_middle << CHUNK_SHIFT),
>> +                               zhdr->middle_chunks << CHUNK_SHIFT);
>
> these if clauses, and the memmoves, aren't very readable, could it be
> made any better with a separate function?

Yep, look somewhat scary, I'll think what I can do about it.

>> +                       zhdr->start_middle = new_start;
>> +                       clear_bit(UNDER_COMPACTION, &page->private);
>> +                       return 1;
>> +               }
>> +       }
>> +out:
>> +       clear_bit(UNDER_COMPACTION, &page->private);
>> +       return 0;
>> +}
>> +
>> +static unsigned long z3fold_shrink_count(struct shrinker *shrink,
>> +                               struct shrink_control *sc)
>> +{
>> +       struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
>> +                                               shrinker);
>> +
>> +       return atomic64_read(&pool->unbuddied_nr);
>> +}
>> +
>> +static unsigned long z3fold_shrink_scan(struct shrinker *shrink,
>> +                               struct shrink_control *sc)
>> +{
>> +       struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
>> +                                               shrinker);
>> +       struct z3fold_header *zhdr;
>> +       int i, nr_to_scan = sc->nr_to_scan, nr_shrunk = 0;
>> +
>> +       spin_lock(&pool->lock);
>> +       for_each_unbuddied_list_down(i, NCHUNKS - 3) {
>> +               if (!list_empty(&pool->unbuddied[i])) {
>> +                       zhdr = list_first_entry(&pool->unbuddied[i],
>> +                                               struct z3fold_header, buddy);
>> +                       list_del(&zhdr->buddy);
>> +                       spin_unlock(&pool->lock);
>> +                       nr_shrunk += z3fold_compact_page(zhdr, false);
>> +                       spin_lock(&pool->lock);
>> +                       list_add(&zhdr->buddy,
>> +                               &pool->unbuddied[num_free_chunks(zhdr)]);
>
> use list_add_tail(), we just compacted it and putting it at the head
> of the new unbuddied list will cause it to be unnecessarily scanned
> first later.
>
>> +                       if (!--nr_to_scan)
>> +                               break;
>> +               }
>> +       }
>> +       spin_unlock(&pool->lock);
>> +       return nr_shrunk;
>> +}
>> +
>> +
>>  /*****************
>>   * API Functions
>>  *****************/
>> @@ -230,7 +335,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>>
>>         pool = kzalloc(sizeof(struct z3fold_pool), gfp);
>>         if (!pool)
>> -               return NULL;
>> +               goto out;
>>         spin_lock_init(&pool->lock);
>>         for_each_unbuddied_list(i, 0)
>>                 INIT_LIST_HEAD(&pool->unbuddied[i]);
>> @@ -238,8 +343,19 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>>         INIT_LIST_HEAD(&pool->lru);
>>         atomic64_set(&pool->pages_nr, 0);
>>         atomic64_set(&pool->unbuddied_nr, 0);
>> +       pool->shrinker.count_objects = z3fold_shrink_count;
>> +       pool->shrinker.scan_objects = z3fold_shrink_scan;
>> +       pool->shrinker.seeks = DEFAULT_SEEKS;
>> +       pool->shrinker.batch = NCHUNKS - 4;
>> +       if (register_shrinker(&pool->shrinker))
>> +               goto out_free;
>>         pool->ops = ops;
>>         return pool;
>> +
>> +out_free:
>> +       kfree(pool);
>> +out:
>> +       return NULL;
>>  }
>>
>>  /**
>> @@ -250,31 +366,10 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>>   */
>>  static void z3fold_destroy_pool(struct z3fold_pool *pool)
>>  {
>> +       unregister_shrinker(&pool->shrinker);
>>         kfree(pool);
>>  }
>>
>> -/* Has to be called with lock held */
>> -static int z3fold_compact_page(struct z3fold_header *zhdr)
>> -{
>> -       struct page *page = virt_to_page(zhdr);
>> -       void *beg = zhdr;
>> -
>> -
>> -       if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
>> -           zhdr->middle_chunks != 0 &&
>> -           zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>> -               memmove(beg + ZHDR_SIZE_ALIGNED,
>> -                       beg + (zhdr->start_middle << CHUNK_SHIFT),
>> -                       zhdr->middle_chunks << CHUNK_SHIFT);
>> -               zhdr->first_chunks = zhdr->middle_chunks;
>> -               zhdr->middle_chunks = 0;
>> -               zhdr->start_middle = 0;
>> -               zhdr->first_num++;
>> -               return 1;
>> -       }
>> -       return 0;
>> -}
>> -
>>  /**
>>   * z3fold_alloc() - allocates a region of a given size
>>   * @pool:      z3fold pool from which to allocate
>> @@ -464,7 +559,6 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>>                 free_z3fold_page(zhdr);
>>                 atomic64_dec(&pool->pages_nr);
>>         } else {
>> -               z3fold_compact_page(zhdr);
>
> why remove this?

As I've said above, that gives some performance improvement.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
