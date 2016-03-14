Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 914306B0253
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 02:52:47 -0400 (EDT)
Received: by mail-io0-f169.google.com with SMTP id z76so211825305iof.3
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 23:52:47 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j10si7449346igx.27.2016.03.13.23.52.46
        for <linux-mm@kvack.org>;
        Sun, 13 Mar 2016 23:52:46 -0700 (PDT)
Date: Mon, 14 Mar 2016 15:53:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v3 3/5] mm/zsmalloc: introduce zs_huge_object()
Message-ID: <20160314065331.GA12337@bbox>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-4-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457016363-11339-4-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Mar 03, 2016 at 11:46:01PM +0900, Sergey Senozhatsky wrote:
> zsmalloc knows the watermark after which classes are considered
> to be ->huge -- every object stored consumes the entire zspage (which
> consist of a single order-0 page). On x86_64, PAGE_SHIFT 12 box, the
> first non-huge class size is 3264, so starting down from size 3264,
> objects share page(-s) and thus minimize memory wastage.
> 
> zram, however, has its own statically defined watermark for `bad'
> compression "3 * PAGE_SIZE / 4 = 3072", and stores every object
> larger than this watermark (3072) as a PAGE_SIZE, object, IOW,
> to a ->huge class, this results in increased memory consumption and
> memory wastage. (With a small exception: 3264 bytes class. zs_malloc()
> adds ZS_HANDLE_SIZE to the object's size, so some objects can pass
> 3072 bytes and get_size_class_index(size) will return 3264 bytes size
> class).
> 
> Introduce zs_huge_object() function which tells whether the supplied
> object's size belongs to a huge class; so zram now can store objects
> to ->huge clases only when those objects have sizes greater than
> huge_class_size_watermark.

I understand the problem you pointed out but I don't like this way.

Huge class is internal thing in zsmalloc so zram shouldn't be coupled
with it. Zram uses just zsmalloc to minimize meory wastage which is
all zram should know about zsmalloc.

Instead, how about changing max_zpage_size?

        static const size_t max_zpage_size = 4096;

So, if compression doesn't help memory efficiency, we don't
need to have decompress overhead. Only that case, we store
decompressed page.

For other huge size class(e.g., PAGE_SIZE / 4 * 3 ~ PAGE_SIZE),
you sent a patch to reduce waste memory as 5/5 so I think it's
a good justification between memory efficiency VS.
decompress overhead.

Thanks.

> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  include/linux/zsmalloc.h |  2 ++
>  mm/zsmalloc.c            | 13 +++++++++++++
>  2 files changed, 15 insertions(+)
> 
> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> index 34eb160..7184ee1 100644
> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -55,4 +55,6 @@ unsigned long zs_get_total_pages(struct zs_pool *pool);
>  unsigned long zs_compact(struct zs_pool *pool);
>  
>  void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
> +
> +bool zs_huge_object(size_t sz);
>  #endif
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 0bb060f..06a7d87 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -188,6 +188,11 @@ static struct dentry *zs_stat_root;
>  static int zs_size_classes;
>  
>  /*
> + * All classes above this class_size are huge classes
> + */
> +static size_t huge_class_size_watermark;
> +
> +/*
>   * We assign a page to ZS_ALMOST_EMPTY fullness group when:
>   *	n <= N / f, where
>   * n = number of allocated objects
> @@ -1244,6 +1249,12 @@ unsigned long zs_get_total_pages(struct zs_pool *pool)
>  }
>  EXPORT_SYMBOL_GPL(zs_get_total_pages);
>  
> +bool zs_huge_object(size_t sz)
> +{
> +	return sz > huge_class_size_watermark;
> +}
> +EXPORT_SYMBOL_GPL(zs_huge_object);
> +
>  /**
>   * zs_map_object - get address of allocated object from handle.
>   * @pool: pool from which the object was allocated
> @@ -1922,6 +1933,8 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>  		pool->size_class[i] = class;
>  
>  		prev_class = class;
> +		if (!class->huge && !huge_class_size_watermark)
> +			huge_class_size_watermark = size - ZS_HANDLE_SIZE;
>  	}
>  
>  	pool->flags = flags;
> -- 
> 2.8.0.rc0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
