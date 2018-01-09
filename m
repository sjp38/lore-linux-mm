Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30EDF6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 23:48:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c25so9550648pfi.11
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 20:48:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 97sor4578204plm.97.2018.01.08.20.48.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 20:48:22 -0800 (PST)
Date: Tue, 9 Jan 2018 13:48:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zswap: only save zswap header if zpool is shrinkable
Message-ID: <20180109044817.GB6953@jagdpanzerIV>
References: <20180108225101.15790-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108225101.15790-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/08/18 14:51), Yu Zhao wrote:
[..]
>  int zpool_shrink(struct zpool *zpool, unsigned int pages,
>  			unsigned int *reclaimed)
>  {
> -	return zpool->driver->shrink(zpool->pool, pages, reclaimed);
> +	return zpool_shrinkable(zpool) ?
> +	       zpool->driver->shrink(zpool->pool, pages, reclaimed) : -EINVAL;
>  }
>  
>  /**
> @@ -355,6 +356,20 @@ u64 zpool_get_total_size(struct zpool *zpool)
>  	return zpool->driver->total_size(zpool->pool);
>  }
>  
> +/**
> + * zpool_shrinkable() - Test if zpool is shrinkable
> + * @pool	The zpool to test
> + *
> + * Zpool is only shrinkable when it's created with struct
> + * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
> + *
> + * Returns: true if shrinkable; false otherwise.
> + */
> +bool zpool_shrinkable(struct zpool *zpool)
> +{
> +	return zpool->ops && zpool->ops->evict && zpool->driver->shrink;
> +}

just a side note,
it might be a bit confusing and maybe there is a better
name for it. zsmalloc is shrinkable (we register a shrinker
callback), but not in the way zpool defines it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
