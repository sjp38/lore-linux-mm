Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 681B16B0260
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 10:06:17 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id x1so159373140lff.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 07:06:17 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id q142si12420381lfe.107.2017.02.01.07.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 07:06:15 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id x1so36767529lff.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 07:06:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170131214334.c4f3eac9a477af0fa9a22c46@gmail.com>
References: <20170131213829.3d86c07ffd1358019354c937@gmail.com> <20170131214334.c4f3eac9a477af0fa9a22c46@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 1 Feb 2017 10:05:35 -0500
Message-ID: <CALZtONB31xEZwN9iD6KypB8Nmt1B9wEeAfYw+HKTUoNUosWgsg@mail.gmail.com>
Subject: Re: [PATCH/RESEND v3 3/5] z3fold: extend compaction function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jan 31, 2017 at 3:43 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> z3fold_compact_page() currently only handles the situation when
> there's a single middle chunk within the z3fold page. However it
> may be worth it to move middle chunk closer to either first or
> last chunk, whichever is there, if the gap between them is big
> enough.
>
> This patch adds the relevant code, using BIG_CHUNK_GAP define as
> a threshold for middle chunk to be worth moving.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

Reviewed-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/z3fold.c | 26 +++++++++++++++++++++++++-
>  1 file changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 98ab01f..be8b56e 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -268,6 +268,7 @@ static inline void *mchunk_memmove(struct z3fold_header *zhdr,
>                        zhdr->middle_chunks << CHUNK_SHIFT);
>  }
>
> +#define BIG_CHUNK_GAP  3
>  /* Has to be called with lock held */
>  static int z3fold_compact_page(struct z3fold_header *zhdr)
>  {
> @@ -286,8 +287,31 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
>                 zhdr->middle_chunks = 0;
>                 zhdr->start_middle = 0;
>                 zhdr->first_num++;
> +               return 1;
>         }
> -       return 1;
> +
> +       /*
> +        * moving data is expensive, so let's only do that if
> +        * there's substantial gain (at least BIG_CHUNK_GAP chunks)
> +        */
> +       if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
> +           zhdr->start_middle - (zhdr->first_chunks + ZHDR_CHUNKS) >=
> +                       BIG_CHUNK_GAP) {
> +               mchunk_memmove(zhdr, zhdr->first_chunks + ZHDR_CHUNKS);
> +               zhdr->start_middle = zhdr->first_chunks + ZHDR_CHUNKS;
> +               return 1;
> +       } else if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
> +                  TOTAL_CHUNKS - (zhdr->last_chunks + zhdr->start_middle
> +                                       + zhdr->middle_chunks) >=
> +                       BIG_CHUNK_GAP) {
> +               unsigned short new_start = TOTAL_CHUNKS - zhdr->last_chunks -
> +                       zhdr->middle_chunks;
> +               mchunk_memmove(zhdr, new_start);
> +               zhdr->start_middle = new_start;
> +               return 1;
> +       }
> +
> +       return 0;
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
