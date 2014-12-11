Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B91676B0032
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 18:39:14 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so6045711pad.29
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 15:39:14 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id b1si3567154pat.116.2014.12.11.15.39.11
        for <linux-mm@kvack.org>;
        Thu, 11 Dec 2014 15:39:12 -0800 (PST)
Date: Fri, 12 Dec 2014 08:40:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: disclose statistics to debugfs
Message-ID: <20141211234005.GA13405@bbox>
References: <1418218820-4153-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1418218820-4153-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Ganesh,

On Wed, Dec 10, 2014 at 09:40:20PM +0800, Ganesh Mahendran wrote:
> As we now talk more and more about the fragmentation of zsmalloc. But
> we still need to manually add some debug code to see the fragmentation.
> So, I think we may add the statistics of memory fragmention in zsmalloc
> and disclose them to debugfs. Then we can easily get and analysis
> them when adding or developing new feature for zsmalloc.
> 
> Below entries will be created when a zsmalloc pool is created:
>     /sys/kernel/debug/zsmalloc/pool-n/obj_allocated
>     /sys/kernel/debug/zsmalloc/pool-n/obj_used
> 
> Then the status of objects usage will be:
>     objects_usage = obj_used / obj_allocated
> 

I didn't look at the code in detail but It would be handy for developer
but not sure we should deliver it to admin so need configurable?

How about making it per-sizeclass information, not per-pool?
So we can rely on the class->lock for the locking rule.

> Also we can collect other information and add corresponding entries
> in debugfs when needed.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c |  108 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 104 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 4d0a063..f682ef9 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -168,6 +168,8 @@ enum fullness_group {
>  	ZS_FULL
>  };
>  
> +static int zs_pool_num;
> +
>  /*
>   * number of size_classes
>   */
> @@ -216,11 +218,19 @@ struct link_free {
>  	void *next;
>  };
>  
> +struct zs_stats {
> +	atomic_long_t pages_allocated;
> +	u64 obj_allocated;
> +	u64 obj_used;
> +};
> +
>  struct zs_pool {
>  	struct size_class **size_class;
>  
>  	gfp_t flags;	/* allocation flags used when growing pool */
> -	atomic_long_t pages_allocated;
> +
> +	struct zs_stats stats;
> +	struct dentry *debugfs_dentry;
>  };
>  
>  /*
> @@ -925,12 +935,84 @@ static void init_zs_size_classes(void)
>  	zs_size_classes = nr;
>  }
>  
> +
> +#ifdef CONFIG_DEBUG_FS
> +#include <linux/debugfs.h>
> +
> +static struct dentry *zs_debugfs_root;
> +
> +static int __init zs_debugfs_init(void)
> +{
> +	if (!debugfs_initialized())
> +		return -ENODEV;
> +
> +	zs_debugfs_root = debugfs_create_dir("zsmalloc", NULL);
> +	if (!zs_debugfs_root)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +static void __exit zs_debugfs_exit(void)
> +{
> +	debugfs_remove_recursive(zs_debugfs_root);
> +}
> +
> +static int zs_pool_debugfs_create(struct zs_pool *pool, int index)
> +{
> +	char name[10];
> +	int ret = 0;
> +
> +	if (!zs_debugfs_root) {
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +
> +	snprintf(name, sizeof(name), "pool-%d", index);
> +	pool->debugfs_dentry = debugfs_create_dir(name, zs_debugfs_root);
> +	if (!pool->debugfs_dentry) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	debugfs_create_u64("obj_allocated", S_IRUGO, pool->debugfs_dentry,
> +			&pool->stats.obj_allocated);
> +	debugfs_create_u64("obj_used", S_IRUGO, pool->debugfs_dentry,
> +			&pool->stats.obj_used);
> +
> +out:
> +	return ret;
> +}
> +
> +static void zs_pool_debugfs_destroy(struct zs_pool *pool)
> +{
> +	debugfs_remove_recursive(pool->debugfs_dentry);
> +}
> +
> +#else
> +static int __init zs_debugfs_init(void)
> +{
> +	return 0;
> +}
> +
> +static void __exit zs_debugfs_exit(void) { }
> +
> +static int zs_pool_debugfs_create(struct zs_pool *pool, int index)
> +{
> +	return 0;
> +}
> +
> +static void zs_pool_debugfs_destroy(struct zs_pool *pool) {}
> +#endif
> +
>  static void __exit zs_exit(void)
>  {
>  #ifdef CONFIG_ZPOOL
>  	zpool_unregister_driver(&zs_zpool_driver);
>  #endif
>  	zs_unregister_cpu_notifier();
> +
> +	zs_debugfs_exit();
>  }
>  
>  static int __init zs_init(void)
> @@ -947,6 +1029,10 @@ static int __init zs_init(void)
>  #ifdef CONFIG_ZPOOL
>  	zpool_register_driver(&zs_zpool_driver);
>  #endif
> +
> +	if (zs_debugfs_init())
> +		pr_warn("debugfs initialization failed\n");
> +
>  	return 0;
>  }
>  
> @@ -1039,6 +1125,11 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>  
>  	pool->flags = flags;
>  
> +	zs_pool_num++;
> +
> +	if (zs_pool_debugfs_create(pool, zs_pool_num))
> +		pr_warn("zs pool debugfs initialization failed\n");
> +
>  	return pool;
>  
>  err:
> @@ -1071,6 +1162,9 @@ void zs_destroy_pool(struct zs_pool *pool)
>  	}
>  
>  	kfree(pool->size_class);
> +	zs_pool_debugfs_destroy(pool);
> +	zs_pool_num--;
> +
>  	kfree(pool);
>  }
>  EXPORT_SYMBOL_GPL(zs_destroy_pool);
> @@ -1110,7 +1204,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>  
>  		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
>  		atomic_long_add(class->pages_per_zspage,
> -					&pool->pages_allocated);
> +					&pool->stats.pages_allocated);
> +		pool->stats.obj_allocated += get_maxobj_per_zspage(class->size,
> +				class->pages_per_zspage);
>  		spin_lock(&class->lock);
>  	}
>  
> @@ -1125,6 +1221,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>  	kunmap_atomic(vaddr);
>  
>  	first_page->inuse++;
> +	pool->stats.obj_used++;
>  	/* Now move the zspage to another fullness group, if required */
>  	fix_fullness_group(pool, first_page);
>  	spin_unlock(&class->lock);
> @@ -1164,12 +1261,15 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>  	first_page->freelist = (void *)obj;
>  
>  	first_page->inuse--;
> +	pool->stats.obj_used--;
>  	fullness = fix_fullness_group(pool, first_page);
>  	spin_unlock(&class->lock);
>  
>  	if (fullness == ZS_EMPTY) {
>  		atomic_long_sub(class->pages_per_zspage,
> -				&pool->pages_allocated);
> +				&pool->stats.pages_allocated);
> +		pool->stats.obj_allocated -= get_maxobj_per_zspage(class->size,
> +				class->pages_per_zspage);
>  		free_zspage(first_page);
>  	}
>  }
> @@ -1267,7 +1367,7 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
>  
>  unsigned long zs_get_total_pages(struct zs_pool *pool)
>  {
> -	return atomic_long_read(&pool->pages_allocated);
> +	return atomic_long_read(&pool->stats.pages_allocated);
>  }
>  EXPORT_SYMBOL_GPL(zs_get_total_pages);
>  
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
