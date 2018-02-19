Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5BF76B002F
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:43:44 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f3so6663369plf.18
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:43:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n71si905532pfk.103.2018.02.19.11.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:43:43 -0800 (PST)
Subject: Re: [PATCH] mm: zsmalloc: Replace return type int with bool
References: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a13bc194-4fad-e8b2-1f75-9ab851ffcfc3@infradead.org>
Date: Mon, 19 Feb 2018 11:43:42 -0800
MIME-Version: 1.0
In-Reply-To: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: linux-mm@kvack.org

On 02/19/18 11:42, Souptick Joarder wrote:
> zs_register_migration() returns either 0 or 1.
> So the return type int should be replaced with bool.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> ---
>  mm/zsmalloc.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index c301350..e238354 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -295,7 +295,7 @@ struct mapping_area {
>  };
> 
>  #ifdef CONFIG_COMPACTION
> -static int zs_register_migration(struct zs_pool *pool);
> +static bool zs_register_migration(struct zs_pool *pool);
>  static void zs_unregister_migration(struct zs_pool *pool);
>  static void migrate_lock_init(struct zspage *zspage);
>  static void migrate_read_lock(struct zspage *zspage);
> @@ -306,7 +306,7 @@ struct mapping_area {
>  #else
>  static int zsmalloc_mount(void) { return 0; }
>  static void zsmalloc_unmount(void) {}
> -static int zs_register_migration(struct zs_pool *pool) { return 0; }
> +static bool zs_register_migration(struct zs_pool *pool) { return 0; }

                                                             return false;

>  static void zs_unregister_migration(struct zs_pool *pool) {}
>  static void migrate_lock_init(struct zspage *zspage) {}
>  static void migrate_read_lock(struct zspage *zspage) {}
> @@ -2101,17 +2101,17 @@ void zs_page_putback(struct page *page)
>  	.putback_page = zs_page_putback,
>  };
> 
> -static int zs_register_migration(struct zs_pool *pool)
> +static bool zs_register_migration(struct zs_pool *pool)
>  {
>  	pool->inode = alloc_anon_inode(zsmalloc_mnt->mnt_sb);
>  	if (IS_ERR(pool->inode)) {
>  		pool->inode = NULL;
> -		return 1;
> +		return true;
>  	}
> 
>  	pool->inode->i_mapping->private_data = pool;
>  	pool->inode->i_mapping->a_ops = &zsmalloc_aops;
> -	return 0;
> +	return false;
>  }
> 
>  static void zs_unregister_migration(struct zs_pool *pool)
> --

thanks,
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
