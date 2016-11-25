Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9DF46B0253
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 11:29:04 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o20so27719428lfg.2
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:29:04 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id z81si20922343lfa.220.2016.11.25.08.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 08:29:03 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id p100so3729874lfg.2
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:29:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161115170014.db7859b144d44985e3805ea3@gmail.com>
References: <20161115165538.878698352bd45e212751b57a@gmail.com> <20161115170014.db7859b144d44985e3805ea3@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 25 Nov 2016 11:28:21 -0500
Message-ID: <CALZtONArJ6LVpjMELrR5FigS_6WbOE6EX_S_6Nq+xP1Gp1Bkbw@mail.gmail.com>
Subject: Re: [PATCH 1/3] z3fold: use per-page spinlock
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Nov 15, 2016 at 11:00 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> Most of z3fold operations are in-page, such as modifying z3fold
> page header or moving z3fold objects within a page. Taking
> per-pool spinlock to protect per-page objects is therefore
> suboptimal, and the idea of having a per-page spinlock (or rwlock)
> has been around for some time.
>
> This patch implements raw spinlock-based per-page locking mechanism
> which is lightweight enough to normally fit ok into the z3fold
> header.
>
> Changes from v1 [1]:
> - custom locking mechanism changed to spinlocks
> - no read/write locks, just per-page spinlock
>
> Changes from v2 [2]:
> - if a page is taken off its list by z3fold_alloc(), bail out from
>   z3fold_free() early
>
> Changes from v3 [3]:
> - spinlock changed to raw spinlock to avoid BUILD_BUG_ON trigger
>
> [1] https://lkml.org/lkml/2016/11/5/59
> [2] https://lkml.org/lkml/2016/11/8/400
> [3] https://lkml.org/lkml/2016/11/9/146
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 136 +++++++++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 97 insertions(+), 39 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index d2e8aec..7ad70fa 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -98,6 +98,7 @@ enum buddy {
>   * struct z3fold_header - z3fold page metadata occupying the first chunk of each
>   *                     z3fold page, except for HEADLESS pages
>   * @buddy:     links the z3fold page into the relevant list in the pool
> + * @page_lock:         per-page lock
>   * @first_chunks:      the size of the first buddy in chunks, 0 if free
>   * @middle_chunks:     the size of the middle buddy in chunks, 0 if free
>   * @last_chunks:       the size of the last buddy in chunks, 0 if free
> @@ -105,6 +106,7 @@ enum buddy {
>   */
>  struct z3fold_header {
>         struct list_head buddy;
> +       raw_spinlock_t page_lock;
>         unsigned short first_chunks;
>         unsigned short middle_chunks;
>         unsigned short last_chunks;
> @@ -144,6 +146,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
>         clear_bit(PAGE_HEADLESS, &page->private);
>         clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>
> +       raw_spin_lock_init(&zhdr->page_lock);
>         zhdr->first_chunks = 0;
>         zhdr->middle_chunks = 0;
>         zhdr->last_chunks = 0;
> @@ -159,6 +162,19 @@ static void free_z3fold_page(struct z3fold_header *zhdr)
>         __free_page(virt_to_page(zhdr));
>  }
>
> +/* Lock a z3fold page */
> +static inline void z3fold_page_lock(struct z3fold_header *zhdr)
> +{
> +       raw_spin_lock(&zhdr->page_lock);
> +}
> +
> +/* Unlock a z3fold page */
> +static inline void z3fold_page_unlock(struct z3fold_header *zhdr)
> +{
> +       raw_spin_unlock(&zhdr->page_lock);
> +}
> +
> +
>  /*
>   * Encodes the handle of a particular buddy within a z3fold page
>   * Pool lock should be held as this function accesses first_num
> @@ -347,50 +363,60 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                 bud = HEADLESS;
>         else {
>                 chunks = size_to_chunks(size);
> -               spin_lock(&pool->lock);
>
>                 /* First, try to find an unbuddied z3fold page. */
>                 zhdr = NULL;
>                 for_each_unbuddied_list(i, chunks) {
> -                       if (!list_empty(&pool->unbuddied[i])) {
> -                               zhdr = list_first_entry(&pool->unbuddied[i],
> +                       spin_lock(&pool->lock);
> +                       zhdr = list_first_entry_or_null(&pool->unbuddied[i],
>                                                 struct z3fold_header, buddy);
> -                               page = virt_to_page(zhdr);
> -                               if (zhdr->first_chunks == 0) {
> -                                       if (zhdr->middle_chunks != 0 &&
> -                                           chunks >= zhdr->start_middle)
> -                                               bud = LAST;
> -                                       else
> -                                               bud = FIRST;
> -                               } else if (zhdr->last_chunks == 0)
> +                       if (!zhdr) {
> +                               spin_unlock(&pool->lock);
> +                               continue;
> +                       }
> +                       list_del_init(&zhdr->buddy);
> +                       spin_unlock(&pool->lock);
> +
> +                       page = virt_to_page(zhdr);
> +                       z3fold_page_lock(zhdr);
> +                       if (zhdr->first_chunks == 0) {
> +                               if (zhdr->middle_chunks != 0 &&
> +                                   chunks >= zhdr->start_middle)
>                                         bud = LAST;
> -                               else if (zhdr->middle_chunks == 0)
> -                                       bud = MIDDLE;
> -                               else {
> -                                       pr_err("No free chunks in unbuddied\n");
> -                                       WARN_ON(1);
> -                                       continue;
> -                               }
> -                               list_del(&zhdr->buddy);
> -                               goto found;
> +                               else
> +                                       bud = FIRST;
> +                       } else if (zhdr->last_chunks == 0)
> +                               bud = LAST;
> +                       else if (zhdr->middle_chunks == 0)
> +                               bud = MIDDLE;
> +                       else {
> +                               spin_lock(&pool->lock);
> +                               list_add(&zhdr->buddy, &pool->buddied);
> +                               spin_unlock(&pool->lock);
> +                               z3fold_page_unlock(zhdr);
> +                               pr_err("No free chunks in unbuddied\n");
> +                               WARN_ON(1);
> +                               continue;
>                         }
> +                       goto found;
>                 }
>                 bud = FIRST;
> -               spin_unlock(&pool->lock);
>         }
>
>         /* Couldn't find unbuddied z3fold page, create new one */
>         page = alloc_page(gfp);
>         if (!page)
>                 return -ENOMEM;
> -       spin_lock(&pool->lock);
> +
>         atomic64_inc(&pool->pages_nr);
>         zhdr = init_z3fold_page(page);
>
>         if (bud == HEADLESS) {
>                 set_bit(PAGE_HEADLESS, &page->private);
> +               spin_lock(&pool->lock);
>                 goto headless;
>         }
> +       z3fold_page_lock(zhdr);
>
>  found:
>         if (bud == FIRST)
> @@ -402,6 +428,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                 zhdr->start_middle = zhdr->first_chunks + 1;
>         }
>
> +       spin_lock(&pool->lock);
>         if (zhdr->first_chunks == 0 || zhdr->last_chunks == 0 ||
>                         zhdr->middle_chunks == 0) {
>                 /* Add to unbuddied list */
> @@ -421,6 +448,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>
>         *handle = encode_handle(zhdr, bud);
>         spin_unlock(&pool->lock);
> +       if (bud != HEADLESS)
> +               z3fold_page_unlock(zhdr);
>
>         return 0;
>  }
> @@ -442,7 +471,6 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>         struct page *page;
>         enum buddy bud;
>
> -       spin_lock(&pool->lock);
>         zhdr = handle_to_z3fold_header(handle);
>         page = virt_to_page(zhdr);
>
> @@ -450,6 +478,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 /* HEADLESS page stored */
>                 bud = HEADLESS;
>         } else {
> +               z3fold_page_lock(zhdr);
>                 bud = handle_to_buddy(handle);
>
>                 switch (bud) {
> @@ -466,37 +495,59 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 default:
>                         pr_err("%s: unknown bud %d\n", __func__, bud);
>                         WARN_ON(1);
> -                       spin_unlock(&pool->lock);
> +                       z3fold_page_unlock(zhdr);
>                         return;
>                 }
>         }
>
>         if (test_bit(UNDER_RECLAIM, &page->private)) {
>                 /* z3fold page is under reclaim, reclaim will free */
> -               spin_unlock(&pool->lock);
> +               if (bud != HEADLESS)
> +                       z3fold_page_unlock(zhdr);
>                 return;
>         }
>
>         /* Remove from existing buddy list */
> -       if (bud != HEADLESS)
> -               list_del(&zhdr->buddy);
> +       if (bud != HEADLESS) {
> +               spin_lock(&pool->lock);
> +               /*
> +                * this object may have been removed from its list by
> +                * z3fold_alloc(). In that case we just do nothing,
> +                * z3fold_alloc() will allocate an object and add the page
> +                * to the relevant list.
> +                */

this is getting complicated enough that it may be better to switch to
kref counting to handle freeing of each page.  That's going to be more
reliable as well as simpler code.

However, this code does seem correct as it is now, since
z3fold_alloc() is the *only* code that removes a page from its buddy
list without holding the page lock (right??).

> +               if (!list_empty(&zhdr->buddy)) {
> +                       list_del(&zhdr->buddy);
> +               } else {
> +                       spin_unlock(&pool->lock);
> +                       z3fold_page_unlock(zhdr);
> +                       return;
> +               }
> +               spin_unlock(&pool->lock);
> +       }
>
>         if (bud == HEADLESS ||
>             (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
>                         zhdr->last_chunks == 0)) {
>                 /* z3fold page is empty, free */
> +               spin_lock(&pool->lock);
>                 list_del(&page->lru);
> +               spin_unlock(&pool->lock);
>                 clear_bit(PAGE_HEADLESS, &page->private);
> +               if (bud != HEADLESS)
> +                       z3fold_page_unlock(zhdr);
>                 free_z3fold_page(zhdr);
>                 atomic64_dec(&pool->pages_nr);
>         } else {
>                 z3fold_compact_page(zhdr);
>                 /* Add to the unbuddied list */
> +               spin_lock(&pool->lock);
>                 freechunks = num_free_chunks(zhdr);
>                 list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               spin_unlock(&pool->lock);
> +               z3fold_page_unlock(zhdr);
>         }
>
> -       spin_unlock(&pool->lock);
>  }
>
>  /**
> @@ -557,6 +608,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)

while you're making these changes, can you fix another existing bug -
the main reclaim_page for loop assumes the lru list always has an
entry, but that's not guaranteed, can you change it to check
list_empty() before getting the last lru entry?

>                 zhdr = page_address(page);
>                 if (!test_bit(PAGE_HEADLESS, &page->private)) {
>                         list_del(&zhdr->buddy);
> +                       spin_unlock(&pool->lock);
> +                       z3fold_page_lock(zhdr);
>                         /*
>                          * We need encode the handles before unlocking, since
>                          * we can race with free that will set
> @@ -571,13 +624,13 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                                 middle_handle = encode_handle(zhdr, MIDDLE);
>                         if (zhdr->last_chunks)
>                                 last_handle = encode_handle(zhdr, LAST);
> +                       z3fold_page_unlock(zhdr);
>                 } else {
>                         first_handle = encode_handle(zhdr, HEADLESS);
>                         last_handle = middle_handle = 0;
> +                       spin_unlock(&pool->lock);
>                 }
>
> -               spin_unlock(&pool->lock);
> -
>                 /* Issue the eviction callback(s) */
>                 if (middle_handle) {
>                         ret = pool->ops->evict(pool, middle_handle);
> @@ -595,7 +648,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                                 goto next;
>                 }
>  next:
> -               spin_lock(&pool->lock);
> +               if (!test_bit(PAGE_HEADLESS, &page->private))
> +                       z3fold_page_lock(zhdr);
>                 clear_bit(UNDER_RECLAIM, &page->private);
>                 if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
>                     (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
> @@ -605,19 +659,22 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                          * return success.
>                          */
>                         clear_bit(PAGE_HEADLESS, &page->private);
> +                       if (!test_bit(PAGE_HEADLESS, &page->private))
> +                               z3fold_page_unlock(zhdr);

heh, well this definitely isn't correct :-)

probably should move that test_bit to before clearing the bit.

>                         free_z3fold_page(zhdr);
>                         atomic64_dec(&pool->pages_nr);
> -                       spin_unlock(&pool->lock);
>                         return 0;
>                 }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {

in this if-else, the case of HEADLESS && ret != 0 falls through
without taking the pool lock, which it's assumed to have held in the
next for loop and/or after exiting the for loop.

>                         if (zhdr->first_chunks != 0 &&
>                             zhdr->last_chunks != 0 &&
>                             zhdr->middle_chunks != 0) {
>                                 /* Full, add to buddied list */
> +                               spin_lock(&pool->lock);
>                                 list_add(&zhdr->buddy, &pool->buddied);
>                         } else {
>                                 z3fold_compact_page(zhdr);
>                                 /* add to unbuddied list */
> +                               spin_lock(&pool->lock);
>                                 freechunks = num_free_chunks(zhdr);
>                                 list_add(&zhdr->buddy,
>                                          &pool->unbuddied[freechunks]);
> @@ -628,6 +685,8 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                 list_add(&page->lru, &pool->lru);
>         }
>         spin_unlock(&pool->lock);
> +       if (!test_bit(PAGE_HEADLESS, &page->private))
> +               z3fold_page_unlock(zhdr);

this needs to be inside the for loop, otherwise you leave all the
failed-to-reclaim pages locked except the last after retries are done.

>         return -EAGAIN;
>  }
>
> @@ -648,7 +707,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>         void *addr;
>         enum buddy buddy;
>
> -       spin_lock(&pool->lock);
>         zhdr = handle_to_z3fold_header(handle);
>         addr = zhdr;
>         page = virt_to_page(zhdr);
> @@ -656,6 +714,7 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>         if (test_bit(PAGE_HEADLESS, &page->private))
>                 goto out;
>
> +       z3fold_page_lock(zhdr);
>         buddy = handle_to_buddy(handle);
>         switch (buddy) {
>         case FIRST:
> @@ -674,8 +733,9 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>                 addr = NULL;
>                 break;
>         }
> +
> +       z3fold_page_unlock(zhdr);
>  out:
> -       spin_unlock(&pool->lock);
>         return addr;
>  }
>
> @@ -690,19 +750,17 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
>         struct page *page;
>         enum buddy buddy;
>
> -       spin_lock(&pool->lock);
>         zhdr = handle_to_z3fold_header(handle);
>         page = virt_to_page(zhdr);
>
> -       if (test_bit(PAGE_HEADLESS, &page->private)) {
> -               spin_unlock(&pool->lock);
> +       if (test_bit(PAGE_HEADLESS, &page->private))
>                 return;
> -       }
>
> +       z3fold_page_lock(zhdr);
>         buddy = handle_to_buddy(handle);
>         if (buddy == MIDDLE)
>                 clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
> -       spin_unlock(&pool->lock);
> +       z3fold_page_unlock(zhdr);
>  }
>
>  /**
> --
> 2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
