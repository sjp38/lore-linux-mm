Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 811688E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:31:56 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id y73-v6so2225115ita.2
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:31:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q188-v6sor1182672iof.30.2018.09.28.04.31.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 04:31:55 -0700 (PDT)
MIME-Version: 1.0
References: <1538079759.qxp8zh3nwh.astroid@alex-archsus.none>
 <CALZtONA9r6=gnK-5a++tjaReqEnRzrBb3hzYMTFNXZ13z+UOWQ@mail.gmail.com>
 <153808275043.724.15980761008814866300@pink.alxu.ca> <1538082779.246sm0vb2p.astroid@alex-archsus.none>
In-Reply-To: <1538082779.246sm0vb2p.astroid@alex-archsus.none>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 28 Sep 2018 07:31:18 -0400
Message-ID: <CALZtONBUR2X8hLG59=JitZqAr0aOO+TWkf6Reke9DHkVu-9_wQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: fix z3fold warnings on CONFIG_SMP=n
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alex_y_xu@yahoo.ca, Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Sep 27, 2018 at 5:15 PM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wrote:
>
> Spinlocks are always lockable on UP systems, even if they were just
> locked.
>
> Cc: Dan Streetman <ddstreet@ieee.org>

I cc'ed Vitaly also, as this code is from him, but the change
certainly looks correct to me.

Acked-by: Dan Streetman <ddstreet@ieee.org>

> Signed-off-by: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
> ---
>  mm/z3fold.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 4b366d181..2e8d268ac 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -277,7 +277,7 @@ static void release_z3fold_page_locked(struct kref *ref)
>  {
>         struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
>                                                 refcount);
> -       WARN_ON(z3fold_page_trylock(zhdr));
> +       WARN_ON_SMP(z3fold_page_trylock(zhdr));
>         __release_z3fold_page(zhdr, true);
>  }
>
> @@ -289,7 +289,7 @@ static void release_z3fold_page_locked_list(struct kref *ref)
>         list_del_init(&zhdr->buddy);
>         spin_unlock(&zhdr->pool->lock);
>
> -       WARN_ON(z3fold_page_trylock(zhdr));
> +       WARN_ON_SMP(z3fold_page_trylock(zhdr));
>         __release_z3fold_page(zhdr, true);
>  }
>
> @@ -403,7 +403,7 @@ static void do_compact_page(struct z3fold_header *zhdr, bool locked)
>
>         page = virt_to_page(zhdr);
>         if (locked)
> -               WARN_ON(z3fold_page_trylock(zhdr));
> +               WARN_ON_SMP(z3fold_page_trylock(zhdr));
>         else
>                 z3fold_page_lock(zhdr);
>         if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING, &page->private))) {
> --
> 2.19.0
>
