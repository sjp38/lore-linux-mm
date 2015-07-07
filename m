Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 63E206B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 09:21:47 -0400 (EDT)
Received: by pddu5 with SMTP id u5so38416252pdd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 06:21:47 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id nk17si34711509pdb.116.2015.07.07.06.21.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 06:21:46 -0700 (PDT)
Received: by pdbci14 with SMTP id ci14so125881887pdb.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 06:21:45 -0700 (PDT)
Date: Tue, 7 Jul 2015 22:21:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 3/7] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150707132136.GA3898@blaptop>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-4-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436270221-17844-4-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, Jul 07, 2015 at 08:56:57PM +0900, Sergey Senozhatsky wrote:
> This function checks if class compaction will free any pages.
> Rephrasing -- do we have enough unused objects to form at least
> one ZS_EMPTY page and free it. It aborts compaction if class
> compaction will not result in any (further) savings.
> 
> EXAMPLE (this debug output is not part of this patch set):
> 
> -- class size
> -- number of allocated objects
> -- number of used objects
> -- max objects per zspage
> -- pages per zspage
> -- estimated number of pages that will be freed
> 
> [..]
> class-512 objs:544 inuse:540 maxobj-per-zspage:8  pages-per-zspage:1 zspages-to-free:0
>  ... class-512 compaction is useless. break
> class-496 objs:660 inuse:570 maxobj-per-zspage:33 pages-per-zspage:4 zspages-to-free:2
> class-496 objs:627 inuse:570 maxobj-per-zspage:33 pages-per-zspage:4 zspages-to-free:1
> class-496 objs:594 inuse:570 maxobj-per-zspage:33 pages-per-zspage:4 zspages-to-free:0
>  ... class-496 compaction is useless. break
> class-448 objs:657 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:4
> class-448 objs:648 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:3
> class-448 objs:639 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:2
> class-448 objs:630 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:1
> class-448 objs:621 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:0
>  ... class-448 compaction is useless. break
> class-432 objs:728 inuse:685 maxobj-per-zspage:28 pages-per-zspage:3 zspages-to-free:1
> class-432 objs:700 inuse:685 maxobj-per-zspage:28 pages-per-zspage:3 zspages-to-free:0
>  ... class-432 compaction is useless. break
> class-416 objs:819 inuse:705 maxobj-per-zspage:39 pages-per-zspage:4 zspages-to-free:2
> class-416 objs:780 inuse:705 maxobj-per-zspage:39 pages-per-zspage:4 zspages-to-free:1
> class-416 objs:741 inuse:705 maxobj-per-zspage:39 pages-per-zspage:4 zspages-to-free:0
>  ... class-416 compaction is useless. break
> class-400 objs:690 inuse:674 maxobj-per-zspage:10 pages-per-zspage:1 zspages-to-free:1
> class-400 objs:680 inuse:674 maxobj-per-zspage:10 pages-per-zspage:1 zspages-to-free:0
>  ... class-400 compaction is useless. break
> class-384 objs:736 inuse:709 maxobj-per-zspage:32 pages-per-zspage:3 zspages-to-free:0
>  ... class-384 compaction is useless. break
> [..]
> 
> Every "compaction is useless" indicates that we saved CPU cycles.
> 
> class-512 has
> 	544	object allocated
> 	540	objects used
> 	8	objects per-page
> 
> Even if we have a ALMOST_EMPTY zspage, we still don't have enough room to
> migrate all of its objects and free this zspage; so compaction will not
> make a lot of sense, it's better to just leave it as is.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

A nit below.

> ---
>  mm/zsmalloc.c | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 036baa8..b7410c1 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1685,6 +1685,28 @@ static struct page *isolate_source_page(struct size_class *class)
>  	return page;
>  }
>  
> +/*
> + *
> + * Based on the number of unused allocated objects calculate
> + * and return the number of pages that we can free.
> + *
> + * Should be called under class->lock.
> + */
> +static unsigned long zs_can_compact(struct size_class *class)
> +{
> +	unsigned long obj_wasted;
> +
> +	if (!zs_stat_get(class, CLASS_ALMOST_EMPTY))
> +		return 0;
> +
> +	obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
> +		zs_stat_get(class, OBJ_USED);
> +
> +	obj_wasted /= get_maxobj_per_zspage(class->size,
> +			class->pages_per_zspage);

Normally, I insert blank line before last return and I look at
other code under mm, it seems to be a common rule.

> +	return obj_wasted * get_pages_per_zspage(class->size);
> +}
> +
>  static unsigned long __zs_compact(struct zs_pool *pool,
>  				struct size_class *class)
>  {
> @@ -1698,6 +1720,9 @@ static unsigned long __zs_compact(struct zs_pool *pool,
>  
>  		BUG_ON(!is_first_page(src_page));
>  
> +		if (!zs_can_compact(class))
> +			break;
> +
>  		cc.index = 0;
>  		cc.s_page = src_page;
>  
> -- 
> 2.4.5
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
