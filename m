Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7CD6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 13:03:48 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a16so100563304qkc.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:03:48 -0800 (PST)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id u26si4279998qta.241.2017.01.11.10.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 10:03:47 -0800 (PST)
Received: by mail-qk0-x242.google.com with SMTP id a20so29402468qkc.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:03:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMJBoFPC-ugq1W-UiADB2H-hHGgN2wrW8C-PpOojnQMoO5OwWg@mail.gmail.com>
References: <20170111155948.aa61c5b995b6523caf87d862@gmail.com>
 <20170111160632.5b0f9fcee5577796c9cd7add@gmail.com> <CALZtONBh808S459yH1Nwron-1Dnfcub3WJpeRf3VWEubsyhReg@mail.gmail.com>
 <CAMJBoFOKGvToTeJAmJ5Ufw8PFhGBb+j_U6+J-UOq4XcggnNqRw@mail.gmail.com>
 <CALZtOND7qpXYOJZ+KK+mKHF_+w5hWzkbbgLDNaTiPFqun=u5sg@mail.gmail.com> <CAMJBoFPC-ugq1W-UiADB2H-hHGgN2wrW8C-PpOojnQMoO5OwWg@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 11 Jan 2017 13:03:06 -0500
Message-ID: <CALZtONDFbsQTpFVmVEmfODVOVp03ndgfHKdJz0i=742KtWS3Jg@mail.gmail.com>
Subject: Re: [PATCH/RESEND v2 5/5] z3fold: add kref refcounting
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 11, 2017 at 12:51 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> On Wed, Jan 11, 2017 at 6:39 PM, Dan Streetman <ddstreet@ieee.org> wrote:
>> On Wed, Jan 11, 2017 at 12:27 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
>>> On Wed, Jan 11, 2017 at 6:08 PM, Dan Streetman <ddstreet@ieee.org> wrote:
>>>> On Wed, Jan 11, 2017 at 10:06 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>>>>> With both coming and already present locking optimizations,
>>>>> introducing kref to reference-count z3fold objects is the right
>>>>> thing to do. Moreover, it makes buddied list no longer necessary,
>>>>> and allows for a simpler handling of headless pages.
>>>>>
>>>>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>>>>> ---
>>>>>  mm/z3fold.c | 145 ++++++++++++++++++++++++++----------------------------------
>>>>>  1 file changed, 62 insertions(+), 83 deletions(-)
>>>>>
>>>>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>>>>> index 4325bde..59cb14f 100644
>>>>> --- a/mm/z3fold.c
>>>>> +++ b/mm/z3fold.c
>>>>> @@ -52,6 +52,7 @@ enum buddy {
>>>>>   *                     z3fold page, except for HEADLESS pages
>>>>>   * @buddy:     links the z3fold page into the relevant list in the pool
>>>>>   * @page_lock:         per-page lock
>>>>> + * @refcount:          reference cound for the z3fold page
>>>>>   * @first_chunks:      the size of the first buddy in chunks, 0 if free
>>>>>   * @middle_chunks:     the size of the middle buddy in chunks, 0 if free
>>>>>   * @last_chunks:       the size of the last buddy in chunks, 0 if free
>>>>> @@ -60,6 +61,7 @@ enum buddy {
>>>>>  struct z3fold_header {
>>>>>         struct list_head buddy;
>>>>>         spinlock_t page_lock;
>>>>> +       struct kref refcount;
>>>>>         unsigned short first_chunks;
>>>>>         unsigned short middle_chunks;
>>>>>         unsigned short last_chunks;
>>>>> @@ -95,8 +97,6 @@ struct z3fold_header {
>>>>>   * @unbuddied: array of lists tracking z3fold pages that contain 2- buddies;
>>>>>   *             the lists each z3fold page is added to depends on the size of
>>>>>   *             its free region.
>>>>> - * @buddied:   list tracking the z3fold pages that contain 3 buddies;
>>>>> - *             these z3fold pages are full
>>>>>   * @lru:       list tracking the z3fold pages in LRU order by most recently
>>>>>   *             added buddy.
>>>>>   * @pages_nr:  number of z3fold pages in the pool.
>>>>> @@ -109,7 +109,6 @@ struct z3fold_header {
>>>>>  struct z3fold_pool {
>>>>>         spinlock_t lock;
>>>>>         struct list_head unbuddied[NCHUNKS];
>>>>> -       struct list_head buddied;
>>>>>         struct list_head lru;
>>>>>         atomic64_t pages_nr;
>>>>>         const struct z3fold_ops *ops;
>>>>> @@ -121,8 +120,7 @@ struct z3fold_pool {
>>>>>   * Internal z3fold page flags
>>>>>   */
>>>>>  enum z3fold_page_flags {
>>>>> -       UNDER_RECLAIM = 0,
>>>>> -       PAGE_HEADLESS,
>>>>> +       PAGE_HEADLESS = 0,
>>>>>         MIDDLE_CHUNK_MAPPED,
>>>>>  };
>>>>>
>>>>> @@ -146,11 +144,11 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
>>>>>         struct z3fold_header *zhdr = page_address(page);
>>>>>
>>>>>         INIT_LIST_HEAD(&page->lru);
>>>>> -       clear_bit(UNDER_RECLAIM, &page->private);
>>>>>         clear_bit(PAGE_HEADLESS, &page->private);
>>>>>         clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>>>>>
>>>>>         spin_lock_init(&zhdr->page_lock);
>>>>> +       kref_init(&zhdr->refcount);
>>>>>         zhdr->first_chunks = 0;
>>>>>         zhdr->middle_chunks = 0;
>>>>>         zhdr->last_chunks = 0;
>>>>> @@ -161,9 +159,21 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
>>>>>  }
>>>>>
>>>>>  /* Resets the struct page fields and frees the page */
>>>>> -static void free_z3fold_page(struct z3fold_header *zhdr)
>>>>> +static void free_z3fold_page(struct page *page)
>>>>>  {
>>>>> -       __free_page(virt_to_page(zhdr));
>>>>> +       __free_page(page);
>>>>> +}
>>>>> +
>>>>> +static void release_z3fold_page(struct kref *ref)
>>>>> +{
>>>>> +       struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
>>>>> +                                               refcount);
>>>>> +       struct page *page = virt_to_page(zhdr);
>>>>> +       if (!list_empty(&zhdr->buddy))
>>>>> +               list_del(&zhdr->buddy);
>>>>> +       if (!list_empty(&page->lru))
>>>>> +               list_del(&page->lru);
>>>>> +       free_z3fold_page(page);
>>>>>  }
>>>>>
>>>>>  /* Lock a z3fold page */
>>>>> @@ -257,7 +267,6 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>>>>>         spin_lock_init(&pool->lock);
>>>>>         for_each_unbuddied_list(i, 0)
>>>>>                 INIT_LIST_HEAD(&pool->unbuddied[i]);
>>>>> -       INIT_LIST_HEAD(&pool->buddied);
>>>>>         INIT_LIST_HEAD(&pool->lru);
>>>>>         atomic64_set(&pool->pages_nr, 0);
>>>>>         pool->ops = ops;
>>>>> @@ -378,6 +387,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>>>>>                                 spin_unlock(&pool->lock);
>>>>>                                 continue;
>>>>>                         }
>>>>> +                       kref_get(&zhdr->refcount);
>>>>>                         list_del_init(&zhdr->buddy);
>>>>>                         spin_unlock(&pool->lock);
>>>>>
>>>>> @@ -394,10 +404,12 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>>>>>                         else if (zhdr->middle_chunks == 0)
>>>>>                                 bud = MIDDLE;
>>>>>                         else {
>>>>> +                               z3fold_page_unlock(zhdr);
>>>>>                                 spin_lock(&pool->lock);
>>>>> -                               list_add(&zhdr->buddy, &pool->buddied);
>>>>> +                               if (kref_put(&zhdr->refcount,
>>>>> +                                            release_z3fold_page))
>>>>> +                                       atomic64_dec(&pool->pages_nr);
>>>>>                                 spin_unlock(&pool->lock);
>>>>> -                               z3fold_page_unlock(zhdr);
>>>>>                                 pr_err("No free chunks in unbuddied\n");
>>>>>                                 WARN_ON(1);
>>>>>                                 continue;
>>>>> @@ -438,9 +450,6 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>>>>>                 /* Add to unbuddied list */
>>>>>                 freechunks = num_free_chunks(zhdr);
>>>>>                 list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>>>>> -       } else {
>>>>> -               /* Add to buddied list */
>>>>> -               list_add(&zhdr->buddy, &pool->buddied);
>>>>>         }
>>>>>
>>>>>  headless:
>>>>> @@ -504,52 +513,29 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>>>>>                 }
>>>>>         }
>>>>>
>>>>> -       if (test_bit(UNDER_RECLAIM, &page->private)) {
>>>>> -               /* z3fold page is under reclaim, reclaim will free */
>>>>> -               if (bud != HEADLESS)
>>>>> -                       z3fold_page_unlock(zhdr);
>>>>> -               return;
>>>>> -       }
>>>>> -
>>>>> -       /* Remove from existing buddy list */
>>>>> -       if (bud != HEADLESS) {
>>>>> -               spin_lock(&pool->lock);
>>>>> -               /*
>>>>> -                * this object may have been removed from its list by
>>>>> -                * z3fold_alloc(). In that case we just do nothing,
>>>>> -                * z3fold_alloc() will allocate an object and add the page
>>>>> -                * to the relevant list.
>>>>> -                */
>>>>> -               if (!list_empty(&zhdr->buddy)) {
>>>>> -                       list_del(&zhdr->buddy);
>>>>> -               } else {
>>>>> -                       spin_unlock(&pool->lock);
>>>>> -                       z3fold_page_unlock(zhdr);
>>>>> -                       return;
>>>>> -               }
>>>>> -               spin_unlock(&pool->lock);
>>>>> -       }
>>>>> -
>>>>> -       if (bud == HEADLESS ||
>>>>> -           (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
>>>>> -                       zhdr->last_chunks == 0)) {
>>>>> -               /* z3fold page is empty, free */
>>>>> +       if (bud == HEADLESS) {
>>>>>                 spin_lock(&pool->lock);
>>>>>                 list_del(&page->lru);
>>>>>                 spin_unlock(&pool->lock);
>>>>> -               clear_bit(PAGE_HEADLESS, &page->private);
>>>>> -               if (bud != HEADLESS)
>>>>> -                       z3fold_page_unlock(zhdr);
>>>>> -               free_z3fold_page(zhdr);
>>>>> +               free_z3fold_page(page);
>>>>>                 atomic64_dec(&pool->pages_nr);
>>>>>         } else {
>>>>> -               z3fold_compact_page(zhdr);
>>>>> -               /* Add to the unbuddied list */
>>>>> +               if (zhdr->first_chunks != 0 || zhdr->middle_chunks != 0 ||
>>>>> +                   zhdr->last_chunks != 0) {
>>>>> +                       z3fold_compact_page(zhdr);
>>>>> +                       /* Add to the unbuddied list */
>>>>> +                       spin_lock(&pool->lock);
>>>>> +                       if (!list_empty(&zhdr->buddy))
>>>>> +                               list_del(&zhdr->buddy);
>>>>> +                       freechunks = num_free_chunks(zhdr);
>>>>> +                       list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>>>>> +                       spin_unlock(&pool->lock);
>>>>> +               }
>>>>> +               z3fold_page_unlock(zhdr);
>>>>>                 spin_lock(&pool->lock);
>>>>> -               freechunks = num_free_chunks(zhdr);
>>>>> -               list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
>>>>> +               if (kref_put(&zhdr->refcount, release_z3fold_page))
>>>>> +                       atomic64_dec(&pool->pages_nr);
>>>>>                 spin_unlock(&pool->lock);
>>>>> -               z3fold_page_unlock(zhdr);
>>>>>         }
>>>>>
>>>>>  }
>>>>> @@ -608,13 +594,13 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>>>>>                         return -EINVAL;
>>>>>                 }
>>>>>                 page = list_last_entry(&pool->lru, struct page, lru);
>>>>> -               list_del(&page->lru);
>>>>> +               list_del_init(&page->lru);
>>>>>
>>>>> -               /* Protect z3fold page against free */
>>>>> -               set_bit(UNDER_RECLAIM, &page->private);
>>>>>                 zhdr = page_address(page);
>>>>>                 if (!test_bit(PAGE_HEADLESS, &page->private)) {
>>>>> -                       list_del(&zhdr->buddy);
>>>>> +                       if (!list_empty(&zhdr->buddy))
>>>>> +                               list_del_init(&zhdr->buddy);
>>>>> +                       kref_get(&zhdr->refcount);
>>>>>                         spin_unlock(&pool->lock);
>>>>>                         z3fold_page_lock(zhdr);
>>>>>                         /*
>>>>> @@ -655,30 +641,18 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>>>>>                                 goto next;
>>>>>                 }
>>>>>  next:
>>>>> -               if (!test_bit(PAGE_HEADLESS, &page->private))
>>>>> +               if (test_bit(PAGE_HEADLESS, &page->private)) {
>>>>> +                       if (ret == 0) {
>>>>> +                               free_z3fold_page(page);
>>>>> +                               return 0;
>>>>> +                       }
>>>>> +               } else {
>>>>> +                       int freed;
>>>>>                         z3fold_page_lock(zhdr);
>>>>> -               clear_bit(UNDER_RECLAIM, &page->private);
>>>>> -               if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
>>>>> -                   (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
>>>>> -                    zhdr->middle_chunks == 0)) {
>>>>> -                       /*
>>>>> -                        * All buddies are now free, free the z3fold page and
>>>>> -                        * return success.
>>>>> -                        */
>>>>> -                       if (!test_and_clear_bit(PAGE_HEADLESS, &page->private))
>>>>> -                               z3fold_page_unlock(zhdr);
>>>>> -                       free_z3fold_page(zhdr);
>>>>> -                       atomic64_dec(&pool->pages_nr);
>>>>> -                       return 0;
>>>>> -               }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
>>>>> -                       if (zhdr->first_chunks != 0 &&
>>>>> -                           zhdr->last_chunks != 0 &&
>>>>> -                           zhdr->middle_chunks != 0) {
>>>>> -                               /* Full, add to buddied list */
>>>>> -                               spin_lock(&pool->lock);
>>>>> -                               list_add(&zhdr->buddy, &pool->buddied);
>>>>> -                               spin_unlock(&pool->lock);
>>>>> -                       } else {
>>>>> +                       if ((zhdr->first_chunks || zhdr->last_chunks ||
>>>>> +                            zhdr->middle_chunks) &&
>>>>> +                           !(zhdr->first_chunks && zhdr->last_chunks &&
>>>>> +                             zhdr->middle_chunks)) {
>>>>>                                 z3fold_compact_page(zhdr);
>>>>>                                 /* add to unbuddied list */
>>>>>                                 spin_lock(&pool->lock);
>>>>> @@ -687,10 +661,15 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>>>>>                                          &pool->unbuddied[freechunks]);
>>>>>                                 spin_unlock(&pool->lock);
>>>>>                         }
>>>>> -               }
>>>>> -
>>>>> -               if (!test_bit(PAGE_HEADLESS, &page->private))
>>>>>                         z3fold_page_unlock(zhdr);
>>>>> +                       spin_lock(&pool->lock);
>>>>> +                       freed = kref_put(&zhdr->refcount, release_z3fold_page);
>>>>> +                       spin_unlock(&pool->lock);
>>>>> +                       if (freed) {
>>>>> +                               atomic64_dec(&pool->pages_nr);
>>>>> +                               return 0;
>>>>> +                       }
>>>>
>>>> you still can't do this - put the kref and then add it back to the lru
>>>> later.  freed here is only useful for knowing that it was freed - you
>>>> can't assume that !freed means it's still valid for you to use.
>>>
>>> Oh right, thanks. I can however do something like
>>> ...
>>>                         spin_lock(&pool->lock);
>>>                         if (kref_put(&zhdr->refcount, release_z3fold_page)) {
>>>                                 atomic64_dec(&pool->pages_nr);
>>>                                 spin_unlock(&pool->lock);
>>>                                 return 0;
>>>                         }
>>>                 }
>>>
>>>                 /* add to beginning of LRU */
>>>                 list_add(&page->lru, &pool->lru);
>>>         }
>>> ...
>>>
>>> provided that I take the lock for the headless case above. That will
>>> work won't it?
>>
>> in this specific case - since every single kref_put in the driver is
>> protected by the pool lock - yeah, you can do that, since you know
>> that specific kref_put didn't free the page and no other kref_put
>> could happen since you're holding the pool lock.
>>
>> but that specific requirement isn't made obvious by the code, and I
>> can see how a future patch could release the pool lock between the
>> kref_put and lru list add, without realizing that introduces a bug.
>> isn't it better to just add it to the lru list before you put the
>> kref?  just a suggestion.
>
> That would require to add it to the lru separately for headless pages
> above, I don't think it makes things better or less error prone.
> I would rather add a comment before list_add.
>
>> i'd also suggest the pages_nr dec go into the page release function,
>> instead of checking every kref_put return value; that's easier and
>> less prone to forgetting to check one of the kref_puts.
>
> That will mean z3fold_header should contain a pointer to its pool. I'm
> not sure it is worth it but I can do that :)

the header's already rounded up to chunk size, so if there's room then
it won't take any extra memory.  but it works either way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
