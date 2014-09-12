Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4BC6B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 19:13:20 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2298703pab.4
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 16:13:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j7si10675857pdo.21.2014.09.12.16.13.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 16:13:19 -0700 (PDT)
Date: Fri, 12 Sep 2014 16:13:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: dmapool: add/remove sysfs file outside of the pool
 lock
Message-Id: <20140912161317.f38c0d2c3b589aea94bdb870@linux-foundation.org>
In-Reply-To: <1410463876-21265-1-git-send-email-bigeasy@linutronix.de>
References: <1410463876-21265-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Sep 2014 21:31:16 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> cat /sys/___/pools followed by removal the device leads to:
> 
> |======================================================
> |[ INFO: possible circular locking dependency detected ]
> |3.17.0-rc4+ #1498 Not tainted
> |-------------------------------------------------------
> |rmmod/2505 is trying to acquire lock:
> | (s_active#28){++++.+}, at: [<c017f754>] kernfs_remove_by_name_ns+0x3c/0x88
> |
> |but task is already holding lock:
> | (pools_lock){+.+.+.}, at: [<c011494c>] dma_pool_destroy+0x18/0x17c
> |
> |which lock already depends on the new lock.
> 
> The problem is the lock order of pools_lock and kernfs_mutex in
> dma_pool_destroy() vs show_pools().

Important details were omitted.  What's the call path whereby
show_pools() is called under kernfs_mutex?

> This patch breaks out the creation of the sysfs file outside of the
> pools_lock mutex.

I think the patch adds races.  They're improbable, but they're there.

> In theory we would have to create the link in the error path of
> device_create_file() in case the dev->dma_pools list is not empty. In
> reality I doubt that there will be a single device creating dma-pools in
> parallel where it would matter.

Maybe you're saying the same thing here, but the changelog lacks
sufficient detail for me to tell because it doesn't explain *why* "we
would have to create the link".

> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -132,6 +132,7 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  {
>  	struct dma_pool *retval;
>  	size_t allocation;
> +	bool empty = false;
>  
>  	if (align == 0) {
>  		align = 1;
> @@ -173,14 +174,22 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>  	INIT_LIST_HEAD(&retval->pools);
>  
>  	mutex_lock(&pools_lock);
> -	if (list_empty(&dev->dma_pools) &&
> -	    device_create_file(dev, &dev_attr_pools)) {
> -		kfree(retval);
> -		return NULL;
> -	} else
> -		list_add(&retval->pools, &dev->dma_pools);
> +	if (list_empty(&dev->dma_pools))
> +		empty = true;
> +	list_add(&retval->pools, &dev->dma_pools);
>  	mutex_unlock(&pools_lock);
> -
> +	if (empty) {
> +		int err;
> +
> +		err = device_create_file(dev, &dev_attr_pools);
> +		if (err) {
> +			mutex_lock(&pools_lock);
> +			list_del(&retval->pools);
> +			mutex_unlock(&pools_lock);
> +			kfree(retval);
> +			return NULL;
> +		}
> +	}
>  	return retval;
>  }
>  EXPORT_SYMBOL(dma_pool_create);
> @@ -251,11 +260,15 @@ static void pool_free_page(struct dma_pool *pool, struct dma_page *page)
>   */
>  void dma_pool_destroy(struct dma_pool *pool)
>  {
> +	bool empty = false;
> +
>  	mutex_lock(&pools_lock);
>  	list_del(&pool->pools);
>  	if (pool->dev && list_empty(&pool->dev->dma_pools))
> -		device_remove_file(pool->dev, &dev_attr_pools);
> +		empty = true;
>  	mutex_unlock(&pools_lock);

For example, if another process now runs dma_pool_create(), it will try
to create the sysfs file and will presumably fail because it's already
there.  Then when this process runs, the file gets removed again.  So
we'll get a nasty warning from device_create_file() (I assume) and the
dma_pool_create() call will fail.

There's probably a similar race in the destroy()-interrupts-create()
path but I'm lazy.

> +	if (empty)
> +		device_remove_file(pool->dev, &dev_attr_pools);
>  


This problem is pretty ugly.

It's a bit surprising that it hasn't happened elsewhere.  Perhaps this
is because dmapool went and broke the sysfs rules and has multiple
values in a single sysfs file.  This causes dmapool to walk a list
under kernfs_lock and that list walk requires a lock.

And it's too late to fix this by switching to one-value-per-file.  Ugh.
Maybe there's some wizardly hack we can use in dma_pool_create() and
dma_pool_destroy() to avoid the races.  Maybe use your patch as-is but
add yet another mutex to serialise dma_pool_create() against
dma_pool_destroy() so they can never run concurrently?  There may
already be higher-level locking which ensures this so perhaps we can
"fix" the races with suitable code comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
