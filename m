Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA8186B02C5
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 02:48:53 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id b25-v6so1559061ljj.8
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 23:48:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor1639517lfc.14.2018.11.05.23.48.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 23:48:52 -0800 (PST)
MIME-Version: 1.0
References: <1530853846-30215-1-git-send-email-ks77sj@gmail.com>
In-Reply-To: <1530853846-30215-1-git-send-email-ks77sj@gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 6 Nov 2018 08:48:39 +0100
Message-ID: <CAMJBoFPGZ_pYFQTXb06U4QxM1ibUhmdxr6efwZigXdUo=4S=Vw@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix wrong handling of headless pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?6rmA7KKF7ISd?= <ks77sj@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Jongseok,

Den fre 6 juli 2018 kl 07:11 skrev Jongseok Kim <ks77sj@gmail.com>:
>
> During the processing of headless pages in z3fold_reclaim_page(),
> there was a problem that the zhdr pointed to another page
> or a page was already released in z3fold_free(). So, the wrong page
> is encoded in headless, or test_bit does not work properly
> in z3fold_reclaim_page(). This patch fixed these problems.

thank you for your work, we've now got a more comprehensive solution:
https://lkml.org/lkml/2018/11/5/726

Would you please confirm that it works for you? Also, would you be
okay with dropping your patch in favor of the new one?

~Vitaly

> Signed-off-by: Jongseok Kim <ks77sj@gmail.com>
> ---
>  mm/z3fold.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 4b366d1..201a8ac 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -746,6 +746,9 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>         }
>
>         if (bud == HEADLESS) {
> +               if (test_bit(UNDER_RECLAIM, &page->private))
> +                       return;
> +
>                 spin_lock(&pool->lock);
>                 list_del(&page->lru);
>                 spin_unlock(&pool->lock);
> @@ -836,20 +839,20 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                 }
>                 list_for_each_prev(pos, &pool->lru) {
>                         page = list_entry(pos, struct page, lru);
> +                       zhdr = page_address(page);
>                         if (test_bit(PAGE_HEADLESS, &page->private))
>                                 /* candidate found */
>                                 break;
>
> -                       zhdr = page_address(page);
>                         if (!z3fold_page_trylock(zhdr))
>                                 continue; /* can't evict at this point */
>                         kref_get(&zhdr->refcount);
>                         list_del_init(&zhdr->buddy);
>                         zhdr->cpu = -1;
> -                       set_bit(UNDER_RECLAIM, &page->private);
>                         break;
>                 }
>
> +               set_bit(UNDER_RECLAIM, &page->private);
>                 list_del_init(&page->lru);
>                 spin_unlock(&pool->lock);
>
> @@ -898,6 +901,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>                 if (test_bit(PAGE_HEADLESS, &page->private)) {
>                         if (ret == 0) {
>                                 free_z3fold_page(page);
> +                               atomic64_dec(&pool->pages_nr);
>                                 return 0;
>                         }
>                         spin_lock(&pool->lock);
> --
> 2.7.4
>
