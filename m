Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5125C6B0390
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 13:00:33 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l203so50852001oig.3
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:00:33 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id d81si2836153oia.310.2017.03.31.10.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 10:00:31 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id 21so76621768pgg.1
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:00:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170331153009.11397-1-aryabinin@virtuozzo.com>
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 31 Mar 2017 10:00:30 -0700
Message-ID: <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in zswap_frontswap_store()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>

On Fri, Mar 31, 2017 at 8:30 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> zswap_frontswap_store() is called during memory reclaim from
> __frontswap_store() from swap_writepage() from shrink_page_list().
> This may happen in NOFS context, thus zswap shouldn't use __GFP_FS,
> otherwise we may renter into fs code and deadlock.
> zswap_frontswap_store() also shouldn't use __GFP_IO to avoid recursion
> into itself.
>

Is it possible to enter fs code (or IO) from zswap_frontswap_store()
other than recursive memory reclaim? However recursive memory reclaim
is protected through PF_MEMALLOC task flag. The change seems fine but
IMHO reasoning needs an update. Adding Michal for expert opinion.

> zswap_frontswap_store() call zpool_malloc() with __GFP_NORETRY |
> __GFP_NOWARN | __GFP_KSWAPD_RECLAIM, so let's use the same flags for
> zswap_entry_cache_alloc() as well, instead of GFP_KERNEL.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  mm/zswap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index eedc278..12ad7e9 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -966,6 +966,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         struct zswap_tree *tree = zswap_trees[type];
>         struct zswap_entry *entry, *dupentry;
>         struct crypto_comp *tfm;
> +       gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
>         int ret;
>         unsigned int dlen = PAGE_SIZE, len;
>         unsigned long handle;
> @@ -989,7 +990,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         }
>
>         /* allocate entry */
> -       entry = zswap_entry_cache_alloc(GFP_KERNEL);
> +       entry = zswap_entry_cache_alloc(gfp);
>         if (!entry) {
>                 zswap_reject_kmemcache_fail++;
>                 ret = -ENOMEM;
> @@ -1017,9 +1018,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>
>         /* store */
>         len = dlen + sizeof(struct zswap_header);
> -       ret = zpool_malloc(entry->pool->zpool, len,
> -                          __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
> -                          &handle);
> +       ret = zpool_malloc(entry->pool->zpool, len, gfp, &handle);
>         if (ret == -ENOSPC) {
>                 zswap_reject_compress_poor++;
>                 goto put_dstmem;
> --
> 2.10.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
