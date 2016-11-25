Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 37FA86B0038
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 13:26:38 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id h201so29099168lfg.5
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 10:26:38 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id b138si21298478lfg.347.2016.11.25.10.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 10:26:36 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id o141so3978841lff.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 10:26:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161115170038.75e127739b66f850e50d7fc1@gmail.com>
References: <20161115165538.878698352bd45e212751b57a@gmail.com> <20161115170038.75e127739b66f850e50d7fc1@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 25 Nov 2016 13:25:55 -0500
Message-ID: <CALZtONChB1HA7rSAhJA9FuOznRa7sXJYqRach+=Y7Pu8RzpJfQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] z3fold: discourage use of pages that weren't compacted
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Nov 15, 2016 at 11:00 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> If a z3fold page couldn't be compacted, we don't want it to be
> used for next object allocation in the first place.

why?  !compacted can only mean 1) already compact or 2) middle chunks
is mapped.  #1 is as good compaction-wise as the page can get, so do
you mean that if a page couldn't be compacted because of #2, we
shouldn't use it for next allocation?  if so, that isn't quite what
this patch does.

> It makes more
> sense to add it to the end of the relevant unbuddied list. If that
> page gets compacted later, it will be added to the beginning of
> the list then.
>
> This simple idea gives 5-7% improvement in randrw fio tests and
> about 10% improvement in fio sequential read/write.

i don't understand why there is any improvement - the unbuddied lists
are grouped by the amount of free chunks, so all pages in a specific
unbuddied list should have exactly that number of free chunks
available, and it shouldn't matter if a page gets put into the front
or back...where is the performance improvement coming from?

>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 22 +++++++++++++++++-----
>  1 file changed, 17 insertions(+), 5 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index ffd9353..e282ba0 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -539,11 +539,19 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>                 free_z3fold_page(zhdr);
>                 atomic64_dec(&pool->pages_nr);
>         } else {
> -               z3fold_compact_page(zhdr);
> +               int compacted = z3fold_compact_page(zhdr);
>                 /* Add to the unbuddied list */
>                 spin_lock(&pool->lock);
>                 freechunks = num_free_chunks(zhdr);
> -               list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               /*
> +                * If the page has been compacted, we want to use it
> +                * in the first place.
> +                */
> +               if (compacted)
> +                       list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> +               else
> +                       list_add_tail(&zhdr->buddy,
> +                                     &pool->unbuddied[freechunks]);
>                 spin_unlock(&pool->lock);
>                 z3fold_page_unlock(zhdr);
>         }
> @@ -672,12 +680,16 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                                 spin_lock(&pool->lock);
>                                 list_add(&zhdr->buddy, &pool->buddied);
>                         } else {
> -                               z3fold_compact_page(zhdr);
> +                               int compacted = z3fold_compact_page(zhdr);
>                                 /* add to unbuddied list */
>                                 spin_lock(&pool->lock);
>                                 freechunks = num_free_chunks(zhdr);
> -                               list_add(&zhdr->buddy,
> -                                        &pool->unbuddied[freechunks]);
> +                               if (compacted)
> +                                       list_add(&zhdr->buddy,
> +                                               &pool->unbuddied[freechunks]);
> +                               else
> +                                       list_add_tail(&zhdr->buddy,
> +                                               &pool->unbuddied[freechunks]);
>                         }
>                 }
>
> --
> 2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
