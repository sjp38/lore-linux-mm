Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3746B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 13:42:55 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id c47so211306940qtc.4
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 10:42:55 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id e23si45758908qtc.215.2017.01.04.10.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 10:42:54 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id w39so1692818qtw.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 10:42:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161226014059.d1aa11c9ed4ac3380bd35870@gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com> <20161226014059.d1aa11c9ed4ac3380bd35870@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 4 Jan 2017 13:42:13 -0500
Message-ID: <CALZtONAs9Gj6DR-ksoxEe9N31EMYZ_SFRinezbFjqpf9jp4sVA@mail.gmail.com>
Subject: Re: [PATCH/RESEND 5/5] z3fold: add kref refcounting
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Dec 25, 2016 at 7:40 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> With both coming and already present locking optimizations,
> introducing kref to reference-count z3fold objects is the right
> thing to do. Moreover, it makes buddied list no longer necessary,
> and allows for a simpler handling of headless pages.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 137 ++++++++++++++++++++++++++++++------------------------------
>  1 file changed, 68 insertions(+), 69 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 729a2da..4593493 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -52,6 +52,7 @@ enum buddy {
>   *                     z3fold page, except for HEADLESS pages
>   * @buddy:     links the z3fold page into the relevant list in the pool
>   * @page_lock:         per-page lock
> + * @refcount:          reference cound for the z3fold page
>   * @first_chunks:      the size of the first buddy in chunks, 0 if free
>   * @middle_chunks:     the size of the middle buddy in chunks, 0 if free
>   * @last_chunks:       the size of the last buddy in chunks, 0 if free
> @@ -60,6 +61,7 @@ enum buddy {
>  struct z3fold_header {
>         struct list_head buddy;
>         raw_spinlock_t page_lock;
> +       struct kref refcount;
>         unsigned short first_chunks;
>         unsigned short middle_chunks;
>         unsigned short last_chunks;
> @@ -95,8 +97,6 @@ struct z3fold_header {
>   * @unbuddied: array of lists tracking z3fold pages that contain 2- buddies;
>   *             the lists each z3fold page is added to depends on the size of
>   *             its free region.
> - * @buddied:   list tracking the z3fold pages that contain 3 buddies;
> - *             these z3fold pages are full
>   * @lru:       list tracking the z3fold pages in LRU order by most recently
>   *             added buddy.
>   * @pages_nr:  number of z3fold pages in the pool.
> @@ -109,7 +109,6 @@ struct z3fold_header {
>  struct z3fold_pool {
>         spinlock_t lock;
>         struct list_head unbuddied[NCHUNKS];
> -       struct list_head buddied;
>         struct list_head lru;
>         atomic64_t pages_nr;
>         const struct z3fold_ops *ops;
> @@ -162,9 +161,21 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
>  }
>
>  /* Resets the struct page fields and frees the page */
> -static void free_z3fold_page(struct z3fold_header *zhdr)
> +static void free_z3fold_page(struct page *page)
>  {
> -       __free_page(virt_to_page(zhdr));
> +       __free_page(page);
> +}
> +
> +static void release_z3fold_page(struct kref *ref)
> +{
> +       struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
> +                                               refcount);
> +       struct page *page = virt_to_page(zhdr);
> +       if (!list_empty(&zhdr->buddy))
> +               list_del(&zhdr->buddy);
> +       if (!list_empty(&page->lru))
> +               list_del(&page->lru);

wait, a page shouldn't ever be on a buddy or lru list if it's free,
should it?  these checks are bugs if they're true aren't they?
Relying on the release function to remove a page from its buddy and/or
lru list (and hoping no other code already took it off and it using
it) seems very error-prone.

> +       free_z3fold_page(page);
>  }
>
>  /* Lock a z3fold page */
> @@ -256,9 +267,9 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>         if (!pool)
>                 return NULL;
>         spin_lock_init(&pool->lock);
> +       kref_init(&zhdr->refcount);
>         for_each_unbuddied_list(i, 0)
>                 INIT_LIST_HEAD(&pool->unbuddied[i]);
> -       INIT_LIST_HEAD(&pool->buddied);
>         INIT_LIST_HEAD(&pool->lru);
>         atomic64_set(&pool->pages_nr, 0);
>         pool->ops = ops;
> @@ -383,7 +394,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                         spin_lock(&pool->lock);
>                         zhdr = list_first_entry_or_null(&pool->unbuddied[i],
>                                                 struct z3fold_header, buddy);
> -                       if (!zhdr) {
> +                       if (!zhdr || !kref_get_unless_zero(&zhdr->refcount)) {

if we can't rely on the kref to be safe under the pool lock, the kref
isn't very useful is it?  seems like it just makes things more
complicated.

the kref should be assumed to be safe while holding the pool lock, or
whatever lock protects the list(s) the object is on, otherwise it
seems likely that use-after-free problems will result...but this goes
back to my concern about relying on the freeing function to remove
objects from their lists.

>                                 spin_unlock(&pool->lock);
>                                 continue;
>                         }
> @@ -403,10 +414,12 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                         else if (zhdr->middle_chunks == 0)
>                                 bud = MIDDLE;
>                         else {
> +                               z3fold_page_unlock(zhdr);
>                                 spin_lock(&pool->lock);
> -                               list_add(&zhdr->buddy, &pool->buddied);
> +                               if (kref_put(&zhdr->refcount,
> +                                            release_z3fold_page))
> +                                       atomic64_dec(&pool->pages_nr);
>                                 spin_unlock(&pool->lock);
> -                               z3fold_page_unlock(zhdr);
>                                 pr_err("No free chunks in unbuddied\n");
>                                 WARN_ON(1);
>                                 continue;
> @@ -447,9 +460,6 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                 /* Add to unbuddied list */
>                 freechunks = num_free_chunks(zhdr);
>                 list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> -       } else {
> -               /* Add to buddied list */
> -               list_add(&zhdr->buddy, &pool->buddied);
>         }
>
>  headless:
> @@ -515,50 +525,39 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>
>         if (test_bit(UNDER_RECLAIM, &page->private)) {
>                 /* z3fold page is under reclaim, reclaim will free */
> -               if (bud != HEADLESS)
> +               if (bud != HEADLESS) {
>                         z3fold_page_unlock(zhdr);
> -               return;
> -       }
> -
> -       /* Remove from existing buddy list */
> -       if (bud != HEADLESS) {
> -               spin_lock(&pool->lock);
> -               /*
> -                * this object may have been removed from its list by
> -                * z3fold_alloc(). In that case we just do nothing,
> -                * z3fold_alloc() will allocate an object and add the page
> -                * to the relevant list.
> -                */
> -               if (!list_empty(&zhdr->buddy)) {
> -                       list_del(&zhdr->buddy);
> -               } else {
> +                       spin_lock(&pool->lock);
> +                       if (kref_put(&zhdr->refcount, release_z3fold_page))
> +                               atomic64_dec(&pool->pages_nr);
>                         spin_unlock(&pool->lock);
> -                       z3fold_page_unlock(zhdr);
> -                       return;
>                 }
> -               spin_unlock(&pool->lock);
> +               return;
>         }
>
> -       if (bud == HEADLESS ||
> -           (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
> -                       zhdr->last_chunks == 0)) {
> -               /* z3fold page is empty, free */
> +       if (bud == HEADLESS) {
>                 spin_lock(&pool->lock);
>                 list_del(&page->lru);
>                 spin_unlock(&pool->lock);
> -               clear_bit(PAGE_HEADLESS, &page->private);
> -               if (bud != HEADLESS)
> -                       z3fold_page_unlock(zhdr);
> -               free_z3fold_page(zhdr);
> +               free_z3fold_page(page);
>                 atomic64_dec(&pool->pages_nr);
>         } else {
> -               z3fold_compact_page(zhdr);
> -               /* Add to the unbuddied list */
> +               if (zhdr->first_chunks != 0 || zhdr->middle_chunks != 0 ||
> +                   zhdr->last_chunks != 0) {
> +                       z3fold_compact_page(zhdr);
> +                       /* Add to the unbuddied list */
> +                       spin_lock(&pool->lock);
> +                       if (!list_empty(&zhdr->buddy))
> +                               list_del(&zhdr->buddy);
> +                       freechunks = num_free_chunks(zhdr);
> +                       list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +                       spin_unlock(&pool->lock);
> +               }
> +               z3fold_page_unlock(zhdr);
>                 spin_lock(&pool->lock);
> -               freechunks = num_free_chunks(zhdr);
> -               list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               if (kref_put(&zhdr->refcount, release_z3fold_page))
> +                       atomic64_dec(&pool->pages_nr);
>                 spin_unlock(&pool->lock);
> -               z3fold_page_unlock(zhdr);
>         }
>
>  }
> @@ -617,13 +616,15 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                         return -EINVAL;
>                 }
>                 page = list_last_entry(&pool->lru, struct page, lru);
> -               list_del(&page->lru);
> +               list_del_init(&page->lru);
>
>                 /* Protect z3fold page against free */
>                 set_bit(UNDER_RECLAIM, &page->private);

UNDER_RECLAIM shouldn't be needed anymore when kref counting is used,
and with the separate pool and page locks, z3fold_free and
z3fold_reclaim can race to set/check this bit anyway (it's set under
the pool lock, but checked under the page lock).

>                 zhdr = page_address(page);
>                 if (!test_bit(PAGE_HEADLESS, &page->private)) {
> -                       list_del(&zhdr->buddy);
> +                       if (!list_empty(&zhdr->buddy))
> +                               list_del_init(&zhdr->buddy);
> +                       kref_get(&zhdr->refcount);
>                         spin_unlock(&pool->lock);
>                         z3fold_page_lock(zhdr);
>                         /*
> @@ -664,30 +665,26 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                                 goto next;
>                 }
>  next:
> -               if (!test_bit(PAGE_HEADLESS, &page->private))
> -                       z3fold_page_lock(zhdr);
>                 clear_bit(UNDER_RECLAIM, &page->private);
> -               if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
> -                   (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
> -                    zhdr->middle_chunks == 0)) {
> -                       /*
> -                        * All buddies are now free, free the z3fold page and
> -                        * return success.
> -                        */
> -                       if (!test_and_clear_bit(PAGE_HEADLESS, &page->private))
> +               if (test_bit(PAGE_HEADLESS, &page->private)) {
> +                       if (ret == 0) {
> +                               free_z3fold_page(page);
> +                               return 0;
> +                       }
> +               } else {
> +                       z3fold_page_lock(zhdr);
> +                       if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
> +                           zhdr->middle_chunks == 0) {
>                                 z3fold_page_unlock(zhdr);
> -                       free_z3fold_page(zhdr);
> -                       atomic64_dec(&pool->pages_nr);
> -                       return 0;
> -               }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
> -                       if (zhdr->first_chunks != 0 &&
> -                           zhdr->last_chunks != 0 &&
> -                           zhdr->middle_chunks != 0) {
> -                               /* Full, add to buddied list */
>                                 spin_lock(&pool->lock);
> -                               list_add(&zhdr->buddy, &pool->buddied);
> +                               if (kref_put(&zhdr->refcount,
> +                                            release_z3fold_page))
> +                                       atomic64_dec(&pool->pages_nr);
>                                 spin_unlock(&pool->lock);
> -                       } else {
> +                               return 0;
> +                       } else if (zhdr->first_chunks == 0 ||
> +                                  zhdr->last_chunks == 0 ||
> +                                  zhdr->middle_chunks == 0) {
>                                 z3fold_compact_page(zhdr);
>                                 /* add to unbuddied list */
>                                 spin_lock(&pool->lock);
> @@ -696,10 +693,12 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                                          &pool->unbuddied[freechunks]);
>                                 spin_unlock(&pool->lock);
>                         }
> -               }
> -
> -               if (!test_bit(PAGE_HEADLESS, &page->private))
>                         z3fold_page_unlock(zhdr);
> +                       spin_lock(&pool->lock);
> +                       if (kref_put(&zhdr->refcount, release_z3fold_page))
> +                               atomic64_dec(&pool->pages_nr);
> +                       spin_unlock(&pool->lock);
> +               }

you can't put the zhdr above, and then go on to add the page to the
lru list; you don't have the kref anymore to allow you to do that.

>
>                 spin_lock(&pool->lock);
>                 /* add to beginning of LRU */
> --
> 2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
