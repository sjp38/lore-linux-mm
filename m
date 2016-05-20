Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEF746B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 22:33:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so60256811wme.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 19:33:16 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id va2si9516254wjb.113.2016.05.19.19.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 19:33:15 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n129so25637764wmn.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 19:33:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1463671123-5479-1-git-send-email-ddstreet@ieee.org>
References: <CADAEsF-kaCQnNN_9gySw3J0UT4mGh8KFp75tGSJtaDAuN1T10A@mail.gmail.com>
	<1463671123-5479-1-git-send-email-ddstreet@ieee.org>
Date: Fri, 20 May 2016 10:33:15 +0800
Message-ID: <CADAEsF_g_Zgw5VmnVJaLLmF+HJr-x+g8Ht==kBJqVF-Ns7nbQg@mail.gmail.com>
Subject: Re: [PATCHv2] mm/zsmalloc: don't fail if can't create debugfs info
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

2016-05-19 23:18 GMT+08:00 Dan Streetman <ddstreet@ieee.org>:
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
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Dan Streetman <dan.streetman@canonical.com>
> Cc: Minchan Kim <minchan@kernel.org>
>
> ---
> Changes since v1:
>  -add pr_warn to all stat failure cases
>  -do not prevent module loading on stat failure
>

Reviewed-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

>  mm/zsmalloc.c | 51 ++++++++++++++++++++++-----------------------------
>  1 file changed, 22 insertions(+), 29 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index aba39a2..b6d4f25 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -45,6 +45,8 @@
>   *
>   */
>
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/sched.h>
> @@ -483,16 +485,16 @@ static inline unsigned long zs_stat_get(struct size_class *class,
>
>  #ifdef CONFIG_ZSMALLOC_STAT
>
> -static int __init zs_stat_init(void)
> +static void __init zs_stat_init(void)
>  {
> -       if (!debugfs_initialized())
> -               return -ENODEV;
> +       if (!debugfs_initialized()) {
> +               pr_warn("debugfs not available, stat dir not created\n");
> +               return;
> +       }
>
>         zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
>         if (!zs_stat_root)
> -               return -ENOMEM;
> -
> -       return 0;
> +               pr_warn("debugfs 'zsmalloc' stat dir creation failed\n");
>  }
>
>  static void __exit zs_stat_exit(void)
> @@ -573,17 +575,19 @@ static const struct file_operations zs_stat_size_ops = {
>         .release        = single_release,
>  };
>
> -static int zs_pool_stat_create(struct zs_pool *pool, const char *name)
> +static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
>  {
>         struct dentry *entry;
>
> -       if (!zs_stat_root)
> -               return -ENODEV;
> +       if (!zs_stat_root) {
> +               pr_warn("no root stat dir, not creating <%s> stat dir\n", name);
> +               return;
> +       }
>
>         entry = debugfs_create_dir(name, zs_stat_root);
>         if (!entry) {
>                 pr_warn("debugfs dir <%s> creation failed\n", name);
> -               return -ENOMEM;
> +               return;
>         }
>         pool->stat_dentry = entry;
>
> @@ -592,10 +596,9 @@ static int zs_pool_stat_create(struct zs_pool *pool, const char *name)
>         if (!entry) {
>                 pr_warn("%s: debugfs file entry <%s> creation failed\n",
>                                 name, "classes");
> -               return -ENOMEM;
> +               debugfs_remove_recursive(pool->stat_dentry);
> +               pool->stat_dentry = NULL;
>         }
> -
> -       return 0;
>  }
>
>  static void zs_pool_stat_destroy(struct zs_pool *pool)
> @@ -604,18 +607,16 @@ static void zs_pool_stat_destroy(struct zs_pool *pool)
>  }
>
>  #else /* CONFIG_ZSMALLOC_STAT */
> -static int __init zs_stat_init(void)
> +static void __init zs_stat_init(void)
>  {
> -       return 0;
>  }
>
>  static void __exit zs_stat_exit(void)
>  {
>  }
>
> -static inline int zs_pool_stat_create(struct zs_pool *pool, const char *name)
> +static inline void zs_pool_stat_create(struct zs_pool *pool, const char *name)
>  {
> -       return 0;
>  }
>
>  static inline void zs_pool_stat_destroy(struct zs_pool *pool)
> @@ -623,7 +624,6 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
>  }
>  #endif
>
> -
>  /*
>   * For each size class, zspages are divided into different groups
>   * depending on how "full" they are. This was done so that we could
> @@ -1952,8 +1952,8 @@ struct zs_pool *zs_create_pool(const char *name)
>                 prev_class = class;
>         }
>
> -       if (zs_pool_stat_create(pool, name))
> -               goto err;
> +       /* debug only, don't abort if it fails */
> +       zs_pool_stat_create(pool, name);
>
>         /*
>          * Not critical, we still can use the pool
> @@ -2015,17 +2015,10 @@ static int __init zs_init(void)
>         zpool_register_driver(&zs_zpool_driver);
>  #endif
>
> -       ret = zs_stat_init();
> -       if (ret) {
> -               pr_err("zs stat initialization failed\n");
> -               goto stat_fail;
> -       }
> +       zs_stat_init();
> +
>         return 0;
>
> -stat_fail:
> -#ifdef CONFIG_ZPOOL
> -       zpool_unregister_driver(&zs_zpool_driver);
> -#endif
>  notifier_fail:
>         zs_unregister_cpu_notifier();
>
> --
> 2.7.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
