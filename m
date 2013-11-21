Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 903786B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 20:59:22 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id n7so6528690qcx.27
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 17:59:22 -0800 (PST)
Received: from mail-qe0-x230.google.com (mail-qe0-x230.google.com [2607:f8b0:400d:c02::230])
        by mx.google.com with ESMTPS id 8si18108497qev.20.2013.11.20.17.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 17:59:21 -0800 (PST)
Received: by mail-qe0-f48.google.com with SMTP id gc15so2577983qeb.7
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 17:59:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1384976909-32671-1-git-send-email-ddstreet@ieee.org>
References: <1384976909-32671-1-git-send-email-ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 09:59:20 +0800
Message-ID: <CAL1ERfPcAbNyt9hTYKMj9OGK2=ynLrTVm9udEn=hF+bFptC16Q@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: don't allow entry eviction if in use by load
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Hello Dan

On Thu, Nov 21, 2013 at 3:48 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> The changes in commit 0ab0abcf511545d1fddbe72a36b3ca73388ac937
> introduce a bug in writeback, if an entry is in use by load
> it will be evicted anyway, which isn't correct (technically,
> the code currently in zbud doesn't actually care much what the
> zswap evict function returns, but that could change).

Thanks for your work. Howerver it is not a bug.

I have thought about this situation, and it will never happen.
If entry is being loaded, its corresponding page must be in swapcache
so zswap_get_swap_cache_page() will return ZSWAP_SWAPCACHE_EXIST

If I miss something, please let me know.

Thanks!

> This changes the check in the writeback function to prevent eviction
> if the entry is still in use (with a nonzero refcount).  The
> refcount is used instead of searching the rb tree beacuse we're
> holding the tree lock (which is required for any changes to refcount)
> and it's faster than a tree search.
>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  mm/zswap.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index e55bab9..e154f1e 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -600,14 +600,18 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>         zswap_entry_put(tree, entry);
>
>         /*
> -       * There are two possible situations for entry here:
> +       * There are three possible situations for entry here:
>         * (1) refcount is 1(normal case),  entry is valid and on the tree
>         * (2) refcount is 0, entry is freed and not on the tree
>         *     because invalidate happened during writeback
> -       *  search the tree and free the entry if find entry
> +       * (3) refcount is 2, entry is in use by load, prevent eviction
>         */
> -       if (entry == zswap_rb_search(&tree->rbroot, offset))
> +       if (likely(entry->refcount > 0))
>                 zswap_entry_put(tree, entry);
> +       if (unlikely(entry->refcount > 0)) {
> +               spin_unlock(&tree->lock);
> +               return -EAGAIN;
> +       }
>         spin_unlock(&tree->lock);
>
>         goto end;
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
