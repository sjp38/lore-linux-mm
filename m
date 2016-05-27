Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B22E6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 14:38:02 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id m81so281614342vka.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 11:38:02 -0700 (PDT)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id u145si15543845vkb.50.2016.05.27.11.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 11:38:01 -0700 (PDT)
Received: by mail-vk0-x241.google.com with SMTP id e126so8493185vkb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 11:38:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5748706F.9020208@gmail.com>
References: <5748706F.9020208@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 27 May 2016 14:37:21 -0400
Message-ID: <CALZtONDNTvaz4mDNuR7MQvdqMvisuD-COhfpyuztDTF=F9u8Uw@mail.gmail.com>
Subject: Re: [PATCH] z3fold: avoid modifying HEADLESS page and minor cleanup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, May 27, 2016 at 12:06 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> This patch fixes erroneous z3fold header access in a HEADLESS page
> in reclaim function, and changes one remaining direct
> handle-to-buddy conversion to use the appropriate helper.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

Reviewed-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/z3fold.c | 24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 34917d5..8f9e89c 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -412,7 +412,7 @@ static void z3fold_free(struct z3fold_pool *pool,
> unsigned long handle)
>                 /* HEADLESS page stored */
>                 bud = HEADLESS;
>         } else {
> -               bud = (handle - zhdr->first_num) & BUDDY_MASK;
> +               bud = handle_to_buddy(handle);
>                 switch (bud) {
>                 case FIRST:
> @@ -572,15 +572,19 @@ next:
>                         pool->pages_nr--;
>                         spin_unlock(&pool->lock);
>                         return 0;
> -               } else if (zhdr->first_chunks != 0 &&
> -                          zhdr->last_chunks != 0 && zhdr->middle_chunks !=
> 0) {
> -                       /* Full, add to buddied list */
> -                       list_add(&zhdr->buddy, &pool->buddied);
> -               } else if (!test_bit(PAGE_HEADLESS, &page->private)) {
> -                       z3fold_compact_page(zhdr);
> -                       /* add to unbuddied list */
> -                       freechunks = num_free_chunks(zhdr);
> -                       list_add(&zhdr->buddy,
> &pool->unbuddied[freechunks]);
> +               }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
> +                       if (zhdr->first_chunks != 0 &&
> +                           zhdr->last_chunks != 0 &&
> +                           zhdr->middle_chunks != 0) {
> +                               /* Full, add to buddied list */
> +                               list_add(&zhdr->buddy, &pool->buddied);
> +                       } else {
> +                               z3fold_compact_page(zhdr);
> +                               /* add to unbuddied list */
> +                               freechunks = num_free_chunks(zhdr);
> +                               list_add(&zhdr->buddy,
> +                                        &pool->unbuddied[freechunks]);
> +                       }
>                 }
>                 /* add to beginning of LRU */
> --
> 2.5.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
