Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3496B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 22:18:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so6708723wme.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 19:18:03 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id n125si2558781wmd.65.2016.05.02.19.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 19:18:02 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id e201so1377617wme.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 19:18:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
References: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
Date: Tue, 3 May 2016 10:18:01 +0800
Message-ID: <CADAEsF-kaCQnNN_9gySw3J0UT4mGh8KFp75tGSJtaDAuN1T10A@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: don't fail if can't create debugfs info
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

Hello, Dan:

2016-04-28 23:36 GMT+08:00 Dan Streetman <ddstreet@ieee.org>:
> Change the return type of zs_pool_stat_create() to void, and
> remove the logic to abort pool creation if the stat debugfs
> dir/file could not be created.
>
> The debugfs stat file is for debugging/information only, and doesn't
> affect operation of zsmalloc; there is no reason to abort creating
> the pool if the stat file can't be created.  This was seen with
> zswap, which used the same name for all pool creations, which caused
> zsmalloc to fail to create a second pool for zswap if
> CONFIG_ZSMALLOC_STAT was enabled.
>
> Cc: Dan Streetman <dan.streetman@canonical.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  mm/zsmalloc.c | 17 +++++++----------
>  1 file changed, 7 insertions(+), 10 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index e72efb1..25a7db2 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -567,17 +567,17 @@ static const struct file_operations zs_stat_size_ops = {
>         .release        = single_release,
>  };
>
> -static int zs_pool_stat_create(const char *name, struct zs_pool *pool)
> +static void zs_pool_stat_create(const char *name, struct zs_pool *pool)
>  {
>         struct dentry *entry;
>
>         if (!zs_stat_root)
> -               return -ENODEV;
> +               return;

Since the error will not be propagated, Would it be better if you
add some pr_warn information here(also in zs_stat_init() if you
send your V2 patch as Minchan suggested)? It will be useful for
developers to know the reason of failed to create debugfs file/dir.

Thanks.

>
>         entry = debugfs_create_dir(name, zs_stat_root);
>         if (!entry) {
>                 pr_warn("debugfs dir <%s> creation failed\n", name);
> -               return -ENOMEM;
> +               return;
>         }
>         pool->stat_dentry = entry;
>
> @@ -586,10 +586,8 @@ static int zs_pool_stat_create(const char *name, struct zs_pool *pool)
>         if (!entry) {
>                 pr_warn("%s: debugfs file entry <%s> creation failed\n",
>                                 name, "classes");
> -               return -ENOMEM;
> +               return;
>         }
> -
> -       return 0;
>  }
>
>  static void zs_pool_stat_destroy(struct zs_pool *pool)
> @@ -607,9 +605,8 @@ static void __exit zs_stat_exit(void)
>  {
>  }
>
> -static inline int zs_pool_stat_create(const char *name, struct zs_pool *pool)
> +static inline void zs_pool_stat_create(const char *name, struct zs_pool *pool)
>  {
> -       return 0;
>  }
>
>  static inline void zs_pool_stat_destroy(struct zs_pool *pool)
> @@ -1956,8 +1953,8 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>
>         pool->flags = flags;
>
> -       if (zs_pool_stat_create(name, pool))
> -               goto err;
> +       /* debug only, don't abort if it fails */
> +       zs_pool_stat_create(name, pool);
>
>         /*
>          * Not critical, we still can use the pool
> --
> 2.7.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
