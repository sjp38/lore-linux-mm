Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A78DB2802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 09:22:59 -0400 (EDT)
Received: by pdbdz6 with SMTP id dz6so10910545pdb.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:22:59 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id rd8si29109331pab.72.2015.07.06.06.22.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 06:22:58 -0700 (PDT)
Received: by pdbdz6 with SMTP id dz6so10910277pdb.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:22:58 -0700 (PDT)
Date: Mon, 6 Jul 2015 22:22:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 6/7] zsmalloc: account the number of compacted pages
Message-ID: <20150706132249.GA16529@blaptop>
References: <1436185070-1940-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436185070-1940-7-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436185070-1940-7-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 06, 2015 at 09:17:49PM +0900, Sergey Senozhatsky wrote:
> Compaction returns back to zram the number of migrated objects,
> which is quite uninformative -- we have objects of different
> sizes so user space cannot obtain any valuable data from that
> number. Change compaction to operate in terms of pages and
> return back to compaction issuer the number of pages that
> were freed during compaction. So from now on `num_compacted'
> column in zram<id>/mm_stat represents more meaningful value:
> the number of freed (compacted) pages.

Fair enough.
 
The main reason I introduced num_migrated is to investigate
the effieciency of compaction. ie, num_freed / num_migrated.
However, I didn't put num_freed at that time so I can't get 
my goal with only num_migrated.
 
We could put new knob num_compacted as well as num_migrated
but I don't think we need it now. Zram's compaction would be
much efficient compared to VM's compaction because we don't
have any non-movable objects in zspages and we can account
exact number of free slots.

So, I want to change name from num_migrated to num_compacted
and maintain only it which is more useful for admin, you said.

It's not far since we introduced num_migrated so I don't think
change name wouldn't be a big problem for userspace,(I hope).

> 
> Return first_page's fullness_group from putback_zspage(),
> so we now for sure know that putback_zspage() has issued
> free_zspage() and we must update compaction stats.
> 
> Update documentation.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  Documentation/blockdev/zram.txt |  3 ++-
>  mm/zsmalloc.c                   | 27 +++++++++++++++++----------
>  2 files changed, 19 insertions(+), 11 deletions(-)
> 
> diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> index c4de576..71f4744 100644
> --- a/Documentation/blockdev/zram.txt
> +++ b/Documentation/blockdev/zram.txt
> @@ -144,7 +144,8 @@ mem_used_max      RW    the maximum amount memory zram have consumed to
>                          store compressed data
>  mem_limit         RW    the maximum amount of memory ZRAM can use to store
>                          the compressed data
> -num_migrated      RO    the number of objects migrated migrated by compaction
> +num_migrated      RO    the number of pages freed during compaction
> +                        (available only via zram<id>/mm_stat node)
>  compact           WO    trigger memory compaction
>  
>  WARNING
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index e0f508a..a761733 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -245,7 +245,7 @@ struct zs_pool {
>  	/* Allocation flags used when growing pool */
>  	gfp_t			flags;
>  	atomic_long_t		pages_allocated;
> -	/* How many objects were migrated */
> +	/* How many pages were migrated (freed) */
>  	unsigned long		num_migrated;
>  
>  #ifdef CONFIG_ZSMALLOC_STAT
> @@ -1596,8 +1596,6 @@ struct zs_compact_control {
>  	 /* Starting object index within @s_page which used for live object
>  	  * in the subpage. */
>  	int index;
> -	/* How many of objects were migrated */
> -	int nr_migrated;
>  };
>  
>  static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
> @@ -1634,7 +1632,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>  		record_obj(handle, free_obj);
>  		unpin_tag(handle);
>  		obj_free(pool, class, used_obj);
> -		cc->nr_migrated++;
>  	}
>  
>  	/* Remember last position in this iteration */
> @@ -1660,8 +1657,17 @@ static struct page *isolate_target_page(struct size_class *class)
>  	return page;
>  }
>  
> -static void putback_zspage(struct zs_pool *pool, struct size_class *class,
> -				struct page *first_page)
> +/*
> + * putback_zspage - add @first_page into right class's fullness list
> + * @pool: target pool
> + * @class: destination class
> + * @first_page: target page
> + *
> + * Return @fist_page's fullness_group
> + */
> +static enum fullness_group putback_zspage(struct zs_pool *pool,
> +			struct size_class *class,
> +			struct page *first_page)
>  {
>  	enum fullness_group fullness;
>  
> @@ -1679,6 +1685,8 @@ static void putback_zspage(struct zs_pool *pool, struct size_class *class,
>  
>  		free_zspage(first_page);
>  	}
> +
> +	return fullness;
>  }
>  
>  static struct page *isolate_source_page(struct size_class *class)
> @@ -1720,7 +1728,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  	struct page *src_page;
>  	struct page *dst_page = NULL;
>  
> -	cc.nr_migrated = 0;
>  	spin_lock(&class->lock);
>  	while ((src_page = isolate_source_page(class))) {
>  
> @@ -1749,7 +1756,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  			break;
>  
>  		putback_zspage(pool, class, dst_page);
> -		putback_zspage(pool, class, src_page);
> +		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
> +			pool->num_migrated +=
> +				get_pages_per_zspage(class->size);
>  		spin_unlock(&class->lock);
>  		cond_resched();
>  		spin_lock(&class->lock);
> @@ -1758,8 +1767,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  	if (src_page)
>  		putback_zspage(pool, class, src_page);
>  
> -	pool->num_migrated += cc.nr_migrated;
> -
>  	spin_unlock(&class->lock);
>  }
>  
> -- 
> 2.5.0.rc0.3.g912bd49
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
