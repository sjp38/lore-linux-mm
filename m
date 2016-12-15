Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98B8E6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 21:16:14 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id 192so46299414vkh.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 18:16:14 -0800 (PST)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id 38si16633820uaf.86.2016.12.14.18.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 18:16:13 -0800 (PST)
Received: by mail-vk0-x241.google.com with SMTP id l126so6351835vkh.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 18:16:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161208122429.79cdf310867c8b4283b9c7d1@gmail.com>
References: <20161208122429.79cdf310867c8b4283b9c7d1@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 14 Dec 2016 21:15:32 -0500
Message-ID: <CALZtONAYHjz449nhbrSTWQ8Jq_rin-2rD8KD0j4RamS5FgpG0A@mail.gmail.com>
Subject: Re: [PATCH/RFC] z3fold: add kref refcounting
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Dec 8, 2016 at 6:24 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>
> Even with already present locking optimizations (and with the

so...is your patch series for z3fold that's in mmotm getting resent?
Wouldn't that be better than re-patching mistakes from the previous
patches?  None of it's gone upstream to Linus.  Having a consolidated
patch series, with the known problems removed, will be better for the
git log, in the long run...

at least, that's my opinion.


> page compaction to come), using kref for reference counting
> z3fold objects seems to be the right thing to do. Moreover,
> it makes buddied list no longer necessary, and allows for
> simpler handling of headless pages.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 108 ++++++++++++++++++++++++++++++++----------------------------
>  1 file changed, 57 insertions(+), 51 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 729a2da..8dcf35e 100644
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
> @@ -152,6 +151,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
>         clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>
>         raw_spin_lock_init(&zhdr->page_lock);
> +       kref_init(&zhdr->refcount);
>         zhdr->first_chunks = 0;
>         zhdr->middle_chunks = 0;
>         zhdr->last_chunks = 0;
> @@ -162,9 +162,19 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
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
> +       if (!list_empty(&page->lru))
> +               list_del(&page->lru);
> +       free_z3fold_page(page);
>  }
>
>  /* Lock a z3fold page */
> @@ -258,7 +268,6 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>         spin_lock_init(&pool->lock);
>         for_each_unbuddied_list(i, 0)
>                 INIT_LIST_HEAD(&pool->unbuddied[i]);
> -       INIT_LIST_HEAD(&pool->buddied);
>         INIT_LIST_HEAD(&pool->lru);
>         atomic64_set(&pool->pages_nr, 0);
>         pool->ops = ops;
> @@ -388,6 +397,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                                 continue;
>                         }
>                         list_del_init(&zhdr->buddy);
> +                       kref_get(&zhdr->refcount);
>                         spin_unlock(&pool->lock);
>
>                         page = virt_to_page(zhdr);
> @@ -403,10 +413,8 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                         else if (zhdr->middle_chunks == 0)
>                                 bud = MIDDLE;
>                         else {
> -                               spin_lock(&pool->lock);
> -                               list_add(&zhdr->buddy, &pool->buddied);
> -                               spin_unlock(&pool->lock);
>                                 z3fold_page_unlock(zhdr);
> +                               kref_put(&zhdr->refcount, release_z3fold_page);
>                                 pr_err("No free chunks in unbuddied\n");
>                                 WARN_ON(1);
>                                 continue;
> @@ -447,9 +455,6 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                 /* Add to unbuddied list */
>                 freechunks = num_free_chunks(zhdr);
>                 list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> -       } else {
> -               /* Add to buddied list */
> -               list_add(&zhdr->buddy, &pool->buddied);
>         }
>
>  headless:
> @@ -515,8 +520,10 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>
>         if (test_bit(UNDER_RECLAIM, &page->private)) {
>                 /* z3fold page is under reclaim, reclaim will free */
> -               if (bud != HEADLESS)
> +               if (bud != HEADLESS) {
>                         z3fold_page_unlock(zhdr);
> +                       kref_put(&zhdr->refcount, release_z3fold_page);
> +               }
>                 return;
>         }
>
> @@ -530,35 +537,37 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                  * to the relevant list.
>                  */
>                 if (!list_empty(&zhdr->buddy)) {
> -                       list_del(&zhdr->buddy);
> +                       list_del_init(&zhdr->buddy);
>                 } else {
>                         spin_unlock(&pool->lock);
>                         z3fold_page_unlock(zhdr);
> +                       kref_put(&zhdr->refcount, release_z3fold_page);

so, the point i was making before about adding kref counting was, we
shouldn't have to do this 'if it's removed from the list, someone else
will take care of freeing it' stuff.  The freeing should entirely be
handled by the kref handler function.  Each of the 3 possible buddies
in a page keeps a reference; when all the buddy's references are gone,
free it.  Nothing else should keep a (persistent) reference.


>                         return;
>                 }
>                 spin_unlock(&pool->lock);
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
> @@ -623,7 +632,9 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                 set_bit(UNDER_RECLAIM, &page->private);
>                 zhdr = page_address(page);
>                 if (!test_bit(PAGE_HEADLESS, &page->private)) {
> -                       list_del(&zhdr->buddy);
> +                       if (!list_empty(&zhdr->buddy))
> +                               list_del_init(&zhdr->buddy);
> +                       kref_get(&zhdr->refcount);
>                         spin_unlock(&pool->lock);
>                         z3fold_page_lock(zhdr);
>                         /*
> @@ -664,30 +675,26 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
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
> @@ -696,10 +703,9 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                                          &pool->unbuddied[freechunks]);
>                                 spin_unlock(&pool->lock);
>                         }
> -               }
> -
> -               if (!test_bit(PAGE_HEADLESS, &page->private))
>                         z3fold_page_unlock(zhdr);
> +                       kref_put(&zhdr->refcount, release_z3fold_page);
> +               }
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
