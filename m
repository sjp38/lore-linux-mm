Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D38306B0033
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:14:50 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t6so43632089pgt.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 21:14:50 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id i64si2427134pfd.9.2017.01.18.21.14.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 21:14:49 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 204so3172942pge.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 21:14:49 -0800 (PST)
Date: Thu, 19 Jan 2017 14:15:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zswap: change BUG to WARN in zswap_writeback_entry
Message-ID: <20170119051503.GB2046@jagdpanzerIV.localdomain>
References: <20170119030004.GA2046@jagdpanzerIV.localdomain>
 <20170119042029.31476-1-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119042029.31476-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, sss123next@list.ru, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

On (01/18/17 23:20), Dan Streetman wrote:
> Change the BUG calls to WARN, and return error.
> 
> There's no need to call BUG from this function, as it can safely return
> the error.  The only caller of this function is the zpool that zswap is
> using, when zswap is trying to reduce the zpool size.  While the error
> does indicate a bug, as none of the WARN conditions should ever happen,
> the zpool implementation can recover by trying to evict another page
> or zswap will recover by sending the new page to the swap disk.
> 
> This was reported in kernel bug 192571:
> https://bugzilla.kernel.org/show_bug.cgi?id=192571
> 
> Reported-by: Gluzskiy Alexandr <sss123next@list.ru>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  mm/zswap.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 067a0d6..60c4e6f 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -787,7 +787,10 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>  		return 0;
>  	}
>  	spin_unlock(&tree->lock);
> -	BUG_ON(offset != entry->offset);
> +	if (WARN_ON(offset != entry->offset)) {
> +		ret = -EINVAL;
> +		goto fail;
> +	}
>  
>  	/* try to allocate swap cache page */
>  	switch (zswap_get_swap_cache_page(swpentry, &page)) {
> @@ -813,8 +816,13 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>  		put_cpu_ptr(entry->pool->tfm);
>  		kunmap_atomic(dst);
>  		zpool_unmap_handle(entry->pool->zpool, entry->handle);
> -		BUG_ON(ret);
> -		BUG_ON(dlen != PAGE_SIZE);
> +		if (WARN(ret, "error decompressing page: %d\n", ret))
> +			goto fail;
> +		if (WARN(dlen != PAGE_SIZE,
> +			 "decompressed page only %x bytes\n", dlen)) {
> +			ret = -EINVAL;
> +			goto fail;
> +		}
>  
>  		/* page is up to date */
>  		SetPageUptodate(page);


+ zswap_frontswap_load() I suppose.

diff --git a/mm/zswap.c b/mm/zswap.c
index 067a0d62f318..e2743687a202 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1023,13 +1023,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
        put_cpu_ptr(entry->pool->tfm);
        kunmap_atomic(dst);
        zpool_unmap_handle(entry->pool->zpool, entry->handle);
-       BUG_ON(ret);
+       WARN(ret, "error decompressing page: %d\n", ret);
 
        spin_lock(&tree->lock);
        zswap_entry_put(tree, entry);
        spin_unlock(&tree->lock);
 
-       return 0;
+       return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
