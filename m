Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id ECA0B6B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 21:52:56 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id u18so6523264qcx.28
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 18:52:56 -0800 (PST)
Received: from mail-qe0-x22f.google.com (mail-qe0-x22f.google.com [2607:f8b0:400d:c02::22f])
        by mx.google.com with ESMTPS id t9si989890qat.53.2013.11.20.18.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 18:52:56 -0800 (PST)
Received: by mail-qe0-f47.google.com with SMTP id t7so2140297qeb.20
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 18:52:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1384976824-32624-1-git-send-email-ddstreet@ieee.org>
References: <1384976824-32624-1-git-send-email-ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 10:52:55 +0800
Message-ID: <CAL1ERfNNAZCS58K9mT85wxQfH8B3AyR4aLE8r745me1dJRmPfg@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: remove unneeded zswap_rb_erase calls
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Hello Dan

On Thu, Nov 21, 2013 at 3:47 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> Since zswap_rb_erase was added to the final (when refcount == 0)
> zswap_put_entry, there is no need to call zswap_rb_erase before
> calling zswap_put_entry.
>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  mm/zswap.c | 5 -----
>  1 file changed, 5 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index e154f1e..f4fbbd5 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -711,8 +711,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>                 ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
>                 if (ret == -EEXIST) {
>                         zswap_duplicate_entry++;
> -                       /* remove from rbtree */
> -                       zswap_rb_erase(&tree->rbroot, dupentry);
>                         zswap_entry_put(tree, dupentry);
>                 }
>         } while (ret == -EEXIST);

If remove zswap_rb_erase, it would loop until free this dupentry. This
would cause 2 proplems:
1.  zswap_duplicate_entry counter is not correct
2. trigger BUG_ON in zswap_entry_put when this dupentry is being writeback,
   because zswap_writeback_entry will call zswap_entry_put either.

So, I don't think it is a good idea to remove zswap_rb_erase call.

> @@ -787,9 +785,6 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
>                 return;
>         }
>
> -       /* remove from rbtree */
> -       zswap_rb_erase(&tree->rbroot, entry);
> -
>         /* drop the initial reference from entry creation */
>         zswap_entry_put(tree, entry);

I think it is better not to remove the zswap_rb_erase call.

>From frontswap interface view, if invalidate is called, the page(and
entry) should never visible to upper.
If remove the zswap_rb_erase call, it is not fit this semantic.

Consider the following scenario:
1. thread 0: entry A is being writeback
2. thread 1: invalidate entry A, as refcount != 0, it will still exist
on rbtree.
3. thread 1: reuse  entry A 's swp_entry_t, do a frontswap_store
   it will conflict with the  entry A on the rbtree, it is not a
normal duplicate store.

If we place the zswap_rb_erase call in zswap_frontswap_invalidate_page,
we can avoid the above scenario.

So, I don't think it is a good idea to remove zswap_rb_erase call.

Regards,

> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
