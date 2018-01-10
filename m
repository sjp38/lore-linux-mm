Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 398C36B026B
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:00:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id j6so872257pgp.21
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 15:00:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor5492896pla.70.2018.01.10.15.00.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 15:00:34 -0800 (PST)
Date: Wed, 10 Jan 2018 15:00:30 -0800
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v2] zswap: only save zswap header when necessary
Message-ID: <20180110230030.GA110374@google.com>
References: <20180108225101.15790-1-yuzhao@google.com>
 <20180110224741.83751-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110224741.83751-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 10, 2018 at 02:47:41PM -0800, Yu Zhao wrote:
> We waste sizeof(swp_entry_t) for zswap header when using zsmalloc
> as zpool driver because zsmalloc doesn't support eviction.
> 
> Add zpool_evictable() to detect if zpool is potentially evictable,
> and use it in zswap to avoid waste memory for zswap header.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  include/linux/zpool.h |  2 ++
>  mm/zpool.c            | 26 ++++++++++++++++++++++++--
>  mm/zsmalloc.c         |  7 -------
>  mm/zswap.c            | 20 ++++++++++----------
>  4 files changed, 36 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/zpool.h b/include/linux/zpool.h
> index 004ba807df96..7238865e75b0 100644
> --- a/include/linux/zpool.h
> +++ b/include/linux/zpool.h
> @@ -108,4 +108,6 @@ void zpool_register_driver(struct zpool_driver *driver);
>  
>  int zpool_unregister_driver(struct zpool_driver *driver);
>  
> +bool zpool_evictable(struct zpool *pool);
> +
>  #endif
> diff --git a/mm/zpool.c b/mm/zpool.c
> index fd3ff719c32c..ec63ef32d73d 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -21,6 +21,7 @@ struct zpool {
>  	struct zpool_driver *driver;
>  	void *pool;
>  	const struct zpool_ops *ops;
> +	bool evictable;
>  
>  	struct list_head list;
>  };
> @@ -142,7 +143,7 @@ EXPORT_SYMBOL(zpool_has_pool);
>   *
>   * This creates a new zpool of the specified type.  The gfp flags will be
>   * used when allocating memory, if the implementation supports it.  If the
> - * ops param is NULL, then the created zpool will not be shrinkable.
> + * ops param is NULL, then the created zpool will not be evictable.
>   *
>   * Implementations must guarantee this to be thread-safe.
>   *
> @@ -180,6 +181,8 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
>  	zpool->driver = driver;
>  	zpool->pool = driver->create(name, gfp, ops, zpool);
>  	zpool->ops = ops;
> +	zpool->evictable = zpool->driver->shrink &&
> +			   zpool->ops && zpool->ops->evict;

The zpool->" prefix is a result out copy & paste. Fixed in the next
version. Sorry for the spam.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
