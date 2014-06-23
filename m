Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id B2C9F6B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 17:46:16 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so6306167pbc.26
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:46:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tz6si23583991pbc.165.2014.06.23.14.46.15
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 14:46:15 -0700 (PDT)
Date: Mon, 23 Jun 2014 14:46:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4 3/6] mm/zpool: implement common zpool api to
 zbud/zsmalloc
Message-Id: <20140623144614.d4549fa0aecb03b7b8044bc7@linux-foundation.org>
In-Reply-To: <1401747586-11861-4-git-send-email-ddstreet@ieee.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-4-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon,  2 Jun 2014 18:19:43 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Add zpool api.
> 
> zpool provides an interface for memory storage, typically of compressed
> memory.  Users can select what backend to use; currently the only
> implementations are zbud, a low density implementation with up to
> two compressed pages per storage page, and zsmalloc, a higher density
> implementation with multiple compressed pages per storage page.
> 
> ...
>
> +/**
> + * zpool_create_pool() - Create a new zpool
> + * @type	The type of the zpool to create (e.g. zbud, zsmalloc)
> + * @flags	What GFP flags should be used when the zpool allocates memory.
> + * @ops		The optional ops callback.
> + *
> + * This creates a new zpool of the specified type.  The zpool will use the
> + * given flags when allocating any memory.  If the ops param is NULL, then
> + * the created zpool will not be shrinkable.
> + *
> + * Returns: New zpool on success, NULL on failure.
> + */
> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
> +			struct zpool_ops *ops);

It is unconventional to document the API in the .h file.  It's better
to put the documentation where people expect to find it.

It's irritating for me (for example) because this kernel convention has
permitted me to train my tags system to ignore prototypes in headers. 
But if I want to find the zpool_create_pool documentation I will need
to jump through hoops.

> 
> ...
>
> +int zpool_evict(void *pool, unsigned long handle)
> +{
> +	struct zpool *zpool;
> +
> +	spin_lock(&pools_lock);
> +	list_for_each_entry(zpool, &pools_head, list) {
> +		if (zpool->pool == pool) {
> +			spin_unlock(&pools_lock);

This is racy against zpool_unregister_driver().

> +			if (!zpool->ops || !zpool->ops->evict)
> +				return -EINVAL;
> +			return zpool->ops->evict(zpool, handle);
> +		}
> +	}
> +	spin_unlock(&pools_lock);
> +
> +	return -ENOENT;
> +}
> +EXPORT_SYMBOL(zpool_evict);
> +
> +static struct zpool_driver *zpool_get_driver(char *type)

In kernel convention, "get" implies "take a reference upon".  A better
name would be zpool_find_driver or zpool_lookup_driver.

This is especially important because the code appears to need a
for-real zpool_get_driver to fix the races!

> 
> ...
>
> +
> +struct zpool *zpool_create_pool(char *type, gfp_t flags,
> +			struct zpool_ops *ops)
> +{
> +	struct zpool_driver *driver;
> +	struct zpool *zpool;
> +
> +	pr_info("creating pool type %s\n", type);
> +
> +	spin_lock(&drivers_lock);
> +	driver = zpool_get_driver(type);
> +	spin_unlock(&drivers_lock);

Racy against unregister.  Can be solved with a standard get/put
refcounting implementation.  Or perhaps a big fat mutex.

> +	if (!driver) {
> +		request_module(type);
> +		spin_lock(&drivers_lock);
> +		driver = zpool_get_driver(type);
> +		spin_unlock(&drivers_lock);
> +	}
> +
> +	if (!driver) {
> +		pr_err("no driver for type %s\n", type);
> +		return NULL;
> +	}
> +
> +	zpool = kmalloc(sizeof(*zpool), GFP_KERNEL);
> +	if (!zpool) {
> +		pr_err("couldn't create zpool - out of memory\n");
> +		return NULL;
> +	}
> +
> +	zpool->type = driver->type;
> +	zpool->driver = driver;
> +	zpool->pool = driver->create(flags, ops);
> +	zpool->ops = ops;
> +
> +	if (!zpool->pool) {
> +		pr_err("couldn't create %s pool\n", type);
> +		kfree(zpool);
> +		return NULL;
> +	}
> +
> +	pr_info("created %s pool\n", type);
> +
> +	spin_lock(&pools_lock);
> +	list_add(&zpool->list, &pools_head);
> +	spin_unlock(&pools_lock);
> +
> +	return zpool;
> +}
> 
> ...
>
> +void zpool_destroy_pool(struct zpool *zpool)
> +{
> +	pr_info("destroying pool type %s\n", zpool->type);
> +
> +	spin_lock(&pools_lock);
> +	list_del(&zpool->list);
> +	spin_unlock(&pools_lock);
> +	zpool->driver->destroy(zpool->pool);
> +	kfree(zpool);
> +}

What are the lifecycle rules here?  How do we know that nobody else can
be concurrently using this pool?

> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
