Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01E676B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:16:16 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g49so72703674qtc.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 13:16:15 -0700 (PDT)
Received: from mail-vk0-x242.google.com (mail-vk0-x242.google.com. [2607:f8b0:400c:c05::242])
        by mx.google.com with ESMTPS id 128si28396764qkk.19.2016.10.20.13.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 13:16:14 -0700 (PDT)
Received: by mail-vk0-x242.google.com with SMTP id 2so3677213vkb.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 13:16:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161019183557.5371f48b064079807c65c92a@gmail.com>
References: <20161019183340.9e3738b403ddda1a04c8f906@gmail.com> <20161019183557.5371f48b064079807c65c92a@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 20 Oct 2016 16:15:33 -0400
Message-ID: <CALZtONBYifCupwSWx7mcnrQDxF5FLV0KToDyz57u7ZgKrVqUrw@mail.gmail.com>
Subject: Re: [PATCH 2/3] z3fold: remove redundant locking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 19, 2016 at 12:35 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> The per-pool z3fold spinlock should generally be taken only when
> a non-atomic pool variable is modified. There's no need to take it
> to map/unmap an object. This patch introduces per-page lock that
> will be used instead to protect per-page variables in map/unmap
> functions.

I think the per-page lock must be held around almost all access to any
page zhdr data; previously that was protected by the pool lock.

>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 65 ++++++++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 38 insertions(+), 27 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 5ac325a..329bc26 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -104,6 +104,7 @@ enum buddy {
>   * @middle_chunks:     the size of the middle buddy in chunks, 0 if free
>   * @last_chunks:       the size of the last buddy in chunks, 0 if free
>   * @first_num:         the starting number (for the first handle)
> + * @page_lock:         per-page lock
>   */
>  struct z3fold_header {
>         struct list_head buddy;
> @@ -112,6 +113,7 @@ struct z3fold_header {
>         unsigned short last_chunks;
>         unsigned short start_middle;
>         unsigned short first_num:NCHUNKS_ORDER;
> +       raw_spinlock_t page_lock;
>  };
>
>  /*
> @@ -152,6 +154,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page)
>         zhdr->first_num = 0;
>         zhdr->start_middle = 0;
>         INIT_LIST_HEAD(&zhdr->buddy);
> +       raw_spin_lock_init(&zhdr->page_lock);
>         return zhdr;
>  }
>
> @@ -163,15 +166,17 @@ static void free_z3fold_page(struct z3fold_header *zhdr)
>
>  /*
>   * Encodes the handle of a particular buddy within a z3fold page
> - * Pool lock should be held as this function accesses first_num
>   */
>  static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
>  {
>         unsigned long handle;
>
>         handle = (unsigned long)zhdr;
> -       if (bud != HEADLESS)
> +       if (bud != HEADLESS) {
> +               raw_spin_lock(&zhdr->page_lock);
>                 handle += (bud + zhdr->first_num) & BUDDY_MASK;
> +               raw_spin_unlock(&zhdr->page_lock);
> +       }
>         return handle;
>  }
>
> @@ -181,7 +186,10 @@ static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
>         return (struct z3fold_header *)(handle & PAGE_MASK);
>  }
>
> -/* Returns buddy number */
> +/*
> + * Returns buddy number.
> + * NB: can't be used with HEADLESS pages.

either indicate this needs to be called with zhdr->page_lock held, or
ensure it never is and take lock internally, like the encode_handle
function above.

> + */
>  static enum buddy handle_to_buddy(unsigned long handle)
>  {
>         struct z3fold_header *zhdr = handle_to_z3fold_header(handle);
> @@ -253,7 +261,6 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
>         kfree(pool);
>  }
>
> -/* Has to be called with lock held */
>  static int z3fold_compact_page(struct z3fold_header *zhdr)
>  {
>         struct page *page = virt_to_page(zhdr);
> @@ -263,6 +270,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
>         if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
>             zhdr->middle_chunks != 0 &&
>             zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +               raw_spin_lock(&zhdr->page_lock);

mapping and chunk checks above need to be protected by the per-page lock.

>                 memmove(beg + ZHDR_SIZE_ALIGNED,
>                         beg + (zhdr->start_middle << CHUNK_SHIFT),
>                         zhdr->middle_chunks << CHUNK_SHIFT);
> @@ -270,6 +278,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
>                 zhdr->middle_chunks = 0;
>                 zhdr->start_middle = 0;
>                 zhdr->first_num++;
> +               raw_spin_unlock(&zhdr->page_lock);
>                 return 1;
>         }
>         return 0;
> @@ -385,9 +394,9 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,

all the zhdr->*_chunks field checks in this function need to be
protected by the page_lock.

>                 list_del(&page->lru);
>
>         list_add(&page->lru, &pool->lru);
> +       spin_unlock(&pool->lock);
>
>         *handle = encode_handle(zhdr, bud);
> -       spin_unlock(&pool->lock);
>
>         return 0;
>  }
> @@ -409,15 +418,18 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>         struct page *page;
>         enum buddy bud;
>
> -       spin_lock(&pool->lock);
>         zhdr = handle_to_z3fold_header(handle);
>         page = virt_to_page(zhdr);
>
>         if (test_bit(PAGE_HEADLESS, &page->private)) {
>                 /* HEADLESS page stored */
>                 bud = HEADLESS;
> +               spin_lock(&pool->lock);
>         } else {
> -               bool is_unbuddied = zhdr->first_chunks == 0 ||
> +               bool is_unbuddied;
> +
> +               raw_spin_lock(&zhdr->page_lock);
> +               is_unbuddied = zhdr->first_chunks == 0 ||
>                                 zhdr->middle_chunks == 0 ||
>                                 zhdr->last_chunks == 0;
>
> @@ -436,12 +448,17 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                         break;
>                 default:
>                         pr_err("%s: unknown bud %d\n", __func__, bud);
> +                       raw_spin_unlock(&zhdr->page_lock);
>                         WARN_ON(1);
> -                       spin_unlock(&pool->lock);
>                         return;
>                 }
> +               raw_spin_unlock(&zhdr->page_lock);
>                 if (is_unbuddied)
>                         atomic64_dec(&pool->unbuddied_nr);
> +
> +               spin_lock(&pool->lock);
> +               /* Remove from existing buddy list */
> +               list_del(&zhdr->buddy);

I think this needs to be left in place below, after the UNDER_RECLAIM
check; if it is being reclaimed, it's already been taken off of its
buddy list.

>         }
>
>         if (test_bit(UNDER_RECLAIM, &page->private)) {
> @@ -450,11 +467,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 return;
>         }
>
> -       if (bud != HEADLESS) {
> -               /* Remove from existing buddy list */
> -               list_del(&zhdr->buddy);
> -       }
> -
> +       /* We've got the page and it is not under reclaim */

kind of.  another free for a different bud in this page could come in
at the same time, so we have no guarantee that we have exclusive
access to it.  must be careful going between the pool and page locks,
to avoid deadlock; and to avoid removing the page from its buddy list,
if it's already been removed.

>         if (bud == HEADLESS ||
>             (zhdr->first_chunks == 0 && zhdr->middle_chunks == 0 &&
>                         zhdr->last_chunks == 0)) {
> @@ -462,16 +475,16 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 list_del(&page->lru);
>                 clear_bit(PAGE_HEADLESS, &page->private);
>                 free_z3fold_page(zhdr);
> +               spin_unlock(&pool->lock);
>                 atomic64_dec(&pool->pages_nr);
>         } else {
>                 z3fold_compact_page(zhdr);
>                 /* Add to the unbuddied list */
>                 freechunks = num_free_chunks(zhdr);
>                 list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               spin_unlock(&pool->lock);
>                 atomic64_inc(&pool->unbuddied_nr);
>         }
> -
> -       spin_unlock(&pool->lock);
>  }
>
>  /**
> @@ -580,6 +593,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                 if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
>                     (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
>                      zhdr->middle_chunks == 0)) {
> +                       spin_unlock(&pool->lock);

as in compact, lock needs to protect all zhdr field access

>                         /*
>                          * All buddies are now free, free the z3fold page and
>                          * return success.
> @@ -587,7 +601,6 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                         clear_bit(PAGE_HEADLESS, &page->private);
>                         free_z3fold_page(zhdr);
>                         atomic64_dec(&pool->pages_nr);
> -                       spin_unlock(&pool->lock);
>                         return 0;
>                 }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
>                         if (zhdr->first_chunks != 0 &&
> @@ -629,7 +642,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>         void *addr;
>         enum buddy buddy;
>
> -       spin_lock(&pool->lock);
>         zhdr = handle_to_z3fold_header(handle);
>         addr = zhdr;
>         page = virt_to_page(zhdr);
> @@ -637,7 +649,9 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>         if (test_bit(PAGE_HEADLESS, &page->private))
>                 goto out;
>
> +       raw_spin_lock(&zhdr->page_lock);
>         buddy = handle_to_buddy(handle);
> +
>         switch (buddy) {
>         case FIRST:
>                 addr += ZHDR_SIZE_ALIGNED;
> @@ -655,8 +669,8 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
>                 addr = NULL;
>                 break;
>         }
> +       raw_spin_unlock(&zhdr->page_lock);
>  out:
> -       spin_unlock(&pool->lock);
>         return addr;
>  }
>
> @@ -671,19 +685,16 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
>         struct page *page;
>         enum buddy buddy;
>
> -       spin_lock(&pool->lock);
>         zhdr = handle_to_z3fold_header(handle);
>         page = virt_to_page(zhdr);
>
> -       if (test_bit(PAGE_HEADLESS, &page->private)) {
> -               spin_unlock(&pool->lock);
> -               return;
> +       if (!test_bit(PAGE_HEADLESS, &page->private)) {
> +               raw_spin_lock(&zhdr->page_lock);
> +               buddy = handle_to_buddy(handle);
> +               if (buddy == MIDDLE)
> +                       clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
> +               raw_spin_unlock(&zhdr->page_lock);
>         }
> -
> -       buddy = handle_to_buddy(handle);
> -       if (buddy == MIDDLE)
> -               clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
> -       spin_unlock(&pool->lock);
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
