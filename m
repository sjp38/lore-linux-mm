Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B39318E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 16:41:59 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id x5-v6so4258173ioa.6
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:41:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x204-v6sor78603itf.56.2018.09.27.13.41.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 13:41:58 -0700 (PDT)
MIME-Version: 1.0
References: <1538079759.qxp8zh3nwh.astroid@alex-archsus.none>
In-Reply-To: <1538079759.qxp8zh3nwh.astroid@alex-archsus.none>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 27 Sep 2018 16:41:21 -0400
Message-ID: <CALZtONA9r6=gnK-5a++tjaReqEnRzrBb3hzYMTFNXZ13z+UOWQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix z3fold warnings on CONFIG_SMP=n
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alex_y_xu@yahoo.ca
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Sep 27, 2018 at 4:27 PM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wrote:
>
> Spinlocks are always lockable on UP systems, even if they were just
> locked.

i think it would be much better to just use either
assert_spin_locked() or just spin_is_locked(), instead of an #ifdef.

>
> Cc: Dan Streetman <ddstreet@ieee.org>
> Signed-off-by: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
> ---
>  mm/z3fold.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 4b366d181..4e6ad2de4 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -202,6 +202,13 @@ static inline void z3fold_page_lock(struct z3fold_header *zhdr)
>         spin_lock(&zhdr->page_lock);
>  }
>
> +static inline void z3fold_page_ensure_locked(struct z3fold_header *zhdr)
> +{
> +#ifdef CONFIG_SMP
> +       WARN_ON(z3fold_page_trylock(zhdr));
> +#endif
> +}
> +
>  /* Try to lock a z3fold page */
>  static inline int z3fold_page_trylock(struct z3fold_header *zhdr)
>  {
> @@ -277,7 +284,7 @@ static void release_z3fold_page_locked(struct kref *ref)
>  {
>         struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
>                                                 refcount);
> -       WARN_ON(z3fold_page_trylock(zhdr));
> +       z3fold_page_ensure_locked(zhdr);
>         __release_z3fold_page(zhdr, true);
>  }
>
> @@ -289,7 +296,7 @@ static void release_z3fold_page_locked_list(struct kref *ref)
>         list_del_init(&zhdr->buddy);
>         spin_unlock(&zhdr->pool->lock);
>
> -       WARN_ON(z3fold_page_trylock(zhdr));
> +       z3fold_page_ensure_locked(zhdr);
>         __release_z3fold_page(zhdr, true);
>  }
>
> @@ -403,7 +410,7 @@ static void do_compact_page(struct z3fold_header *zhdr, bool locked)
>
>         page = virt_to_page(zhdr);
>         if (locked)
> -               WARN_ON(z3fold_page_trylock(zhdr));
> +               z3fold_page_ensure_locked(zhdr);
>         else
>                 z3fold_page_lock(zhdr);
>         if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING, &page->private))) {
> --
> 2.19.0
>
