Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86B626B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 10:43:54 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id x49so4529759qtc.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 07:43:54 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id h49si45445192qtc.162.2017.01.04.07.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 07:43:53 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id j29so3323336qtc.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 07:43:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161226013448.d02b73ea0fca7edf0537162b@gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com> <20161226013448.d02b73ea0fca7edf0537162b@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 4 Jan 2017 10:43:13 -0500
Message-ID: <CALZtONAOgKLfRQbXR+xxhRWW2QyQghoLA_ownxK7_RZ8D5wOYw@mail.gmail.com>
Subject: Re: [PATCH/RESEND 2/5] mm/z3fold.c: extend compaction function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Dec 25, 2016 at 7:34 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> z3fold_compact_page() currently only handles the situation where there's a
> single middle chunk within the z3fold page.  However it may be worth it to
> move middle chunk closer to either first or last chunk, whichever is
> there, if the gap between them is big enough.
>
> Basically compression ratio wise, it always makes sense to move middle
> chunk as close as possible to another in-page z3fold object, because then
> the third object can use all the remaining space.  However, moving big
> object just by one chunk will hurt performance without gaining much
> compression ratio wise.  So the gap between the middle object and the edge
> object should be big enough to justify the move.
>
> So this patch improves compression ratio because in-page compaction
> becomes more comprehensive; this patch (which came as a surprise) also
> increases performance in fio randrw tests (I am not 100% sure why, but
> probably due to less actual page allocations on hot path due to denser
> in-page allocation).
>
> This patch adds the relevant code, using BIG_CHUNK_GAP define as a
> threshold for middle chunk to be worth moving.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 47 insertions(+), 13 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 2273789..d2e8aec 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -254,26 +254,60 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
>         kfree(pool);
>  }
>
> +static inline void *mchunk_memmove(struct z3fold_header *zhdr,
> +                               unsigned short dst_chunk)
> +{
> +       void *beg = zhdr;
> +       return memmove(beg + (dst_chunk << CHUNK_SHIFT),
> +                      beg + (zhdr->start_middle << CHUNK_SHIFT),
> +                      zhdr->middle_chunks << CHUNK_SHIFT);
> +}
> +
> +#define BIG_CHUNK_GAP  3
>  /* Has to be called with lock held */
>  static int z3fold_compact_page(struct z3fold_header *zhdr)
>  {
>         struct page *page = virt_to_page(zhdr);
> -       void *beg = zhdr;
> +       int ret = 0;

I still don't understand why you're adding ret and using goto.  Just
use return for each failure case.

> +
> +       if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
> +               goto out;
>
> +       if (zhdr->middle_chunks != 0) {

you appear to have just re-sent all your patches without addressing
comments; in patch 4 you invert the check and return, which is what
you should have done here in the first place, as that change is
unrelated to that patch.

> +               if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> +                       mchunk_memmove(zhdr, 1); /* move to the beginning */
> +                       zhdr->first_chunks = zhdr->middle_chunks;
> +                       zhdr->middle_chunks = 0;
> +                       zhdr->start_middle = 0;
> +                       zhdr->first_num++;
> +                       ret = 1;
> +                       goto out;
> +               }
>
> -       if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
> -           zhdr->middle_chunks != 0 &&
> -           zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
> -               memmove(beg + ZHDR_SIZE_ALIGNED,
> -                       beg + (zhdr->start_middle << CHUNK_SHIFT),
> -                       zhdr->middle_chunks << CHUNK_SHIFT);
> -               zhdr->first_chunks = zhdr->middle_chunks;
> -               zhdr->middle_chunks = 0;
> -               zhdr->start_middle = 0;
> -               zhdr->first_num++;
> -               return 1;
> +               /*
> +                * moving data is expensive, so let's only do that if
> +                * there's substantial gain (at least BIG_CHUNK_GAP chunks)
> +                */
> +               if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
> +                   zhdr->start_middle > zhdr->first_chunks + BIG_CHUNK_GAP) {

you're not accouting for the 1-chunk zhdr in this > comparison

> +                       mchunk_memmove(zhdr, zhdr->first_chunks + 1);
> +                       zhdr->start_middle = zhdr->first_chunks + 1;
> +                       ret = 1;
> +                       goto out;
> +               }
> +               if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
> +                   zhdr->middle_chunks + zhdr->last_chunks <=
> +                   NCHUNKS - zhdr->start_middle - BIG_CHUNK_GAP) {
> +                       unsigned short new_start = NCHUNKS - zhdr->last_chunks -
> +                               zhdr->middle_chunks;

We already know this needs to use TOTAL_CHUNKS, not NCHUNKS; using
NCHUNKS places it at the wrong location.  Define TOTAL_CHUNKS either
in this patch or before this patch in the series so it can be used
here.

> +                       mchunk_memmove(zhdr, new_start);
> +                       zhdr->start_middle = new_start;
> +                       ret = 1;
> +                       goto out;
> +               }
>         }
> -       return 0;
> +out:
> +       return ret;
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
