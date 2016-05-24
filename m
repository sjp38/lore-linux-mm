Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8B66B025E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 01:28:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id x1so3112633pav.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 22:28:34 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id t12si10707008pfj.44.2016.05.23.22.28.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 22:28:33 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 145so947155pfz.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 22:28:33 -0700 (PDT)
Date: Tue, 24 May 2016 14:28:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160524052824.GA496@swordfish>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463754225-31311-12-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (05/20/16 23:23), Minchan Kim wrote:
[..]
> +static int get_zspage_isolation(struct zspage *zspage)
> +{
> +	return zspage->isolated;
> +}
> +

may be is_zspage_isolated()?

[..]
> @@ -502,23 +556,19 @@ static int get_size_class_index(int size)
>  static inline void zs_stat_inc(struct size_class *class,
>  				enum zs_stat_type type, unsigned long cnt)
>  {
> -	if (type < NR_ZS_STAT_TYPE)
> -		class->stats.objs[type] += cnt;
> +	class->stats.objs[type] += cnt;
>  }
>  
>  static inline void zs_stat_dec(struct size_class *class,
>  				enum zs_stat_type type, unsigned long cnt)
>  {
> -	if (type < NR_ZS_STAT_TYPE)
> -		class->stats.objs[type] -= cnt;
> +	class->stats.objs[type] -= cnt;
>  }
>  
>  static inline unsigned long zs_stat_get(struct size_class *class,
>  				enum zs_stat_type type)
>  {
> -	if (type < NR_ZS_STAT_TYPE)
> -		return class->stats.objs[type];
> -	return 0;
> +	return class->stats.objs[type];
>  }

hmm... the ordering of STAT types and those if-conditions were here for
a reason:

commit 6fe5186f0c7c18a8beb6d96c21e2390df7a12375
Author: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date:   Fri Nov 6 16:29:38 2015 -0800

    zsmalloc: reduce size_class memory usage
    
    Each `struct size_class' contains `struct zs_size_stat': an array of
    NR_ZS_STAT_TYPE `unsigned long'.  For zsmalloc built with no
    CONFIG_ZSMALLOC_STAT this results in a waste of `2 * sizeof(unsigned
    long)' per-class.
    
    The patch removes unneeded `struct zs_size_stat' members by redefining
    NR_ZS_STAT_TYPE (max stat idx in array).
    
    Since both NR_ZS_STAT_TYPE and zs_stat_type are compile time constants,
    GCC can eliminate zs_stat_inc()/zs_stat_dec() calls that use zs_stat_type
    larger than NR_ZS_STAT_TYPE: CLASS_ALMOST_EMPTY and CLASS_ALMOST_FULL at
    the moment.
    
    ./scripts/bloat-o-meter mm/zsmalloc.o.old mm/zsmalloc.o.new
    add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-39 (-39)
    function                                     old     new   delta
    fix_fullness_group                            97      94      -3
    insert_zspage                                100      86     -14
    remove_zspage                                141     119     -22
    
    To summarize:
    a) each class now uses less memory
    b) we avoid a number of dec/inc stats (a minor optimization,
       but still).
    
    The gain will increase once we introduce additional stats.

so it helped to eliminate instructions at compile time from a very hot
path for !CONFIG_ZSMALLOC_STAT builds (which is 99% of the builds I think,
I doubt anyone apart from us is using ZSMALLOC_STAT).


[..]
> +static int get_first_obj_offset(struct size_class *class,
> +				struct page *first_page, struct page *page)
>  {
> -	return page->next;
> +	int pos, bound;
> +	int page_idx = 0;
> +	int ofs = 0;
> +	struct page *cursor = first_page;
> +
> +	if (first_page == page)
> +		goto out;
> +
> +	while (page != cursor) {
> +		page_idx++;
> +		cursor = get_next_page(cursor);
> +	}
> +
> +	bound = PAGE_SIZE * page_idx;

'bound' not used.


> +	pos = (((class->objs_per_zspage * class->size) *
> +		page_idx / class->pages_per_zspage) / class->size
> +	      ) * class->size;


something went wrong with the indentation here :)

so... it's

	(((class->objs_per_zspage * class->size) * page_idx / class->pages_per_zspage) / class->size ) * class->size;

the last ' / class->size ) * class->size' can be dropped, I think.

[..]
> +		pos += class->size;
> +	}
> +
> +	/*
> +	 * Here, any user cannot access all objects in the zspage so let's move.
                 "no one can access any object" ?

[..]
> +	spin_lock(&class->lock);
> +	dec_zspage_isolation(zspage);
> +	if (!get_zspage_isolation(zspage)) {
> +		fg = putback_zspage(class, zspage);
> +		/*
> +		 * Due to page_lock, we cannot free zspage immediately
> +		 * so let's defer.
> +		 */
> +		if (fg == ZS_EMPTY)
> +			schedule_work(&pool->free_work);

hm... zsmalloc is getting sooo complex now.

`system_wq' -- can we have problems here when the system is getting
low on memory and workers are getting increasingly busy trying to
allocate the memory for some other purposes?

_theoretically_ zsmalloc can stack a number of ready-to-release zspages,
which won't be accessible to zsmalloc, nor will they be released. how likely
is this? hm, can zsmalloc take zspages from that deferred release list when
it wants to allocate a new zspage?

do you also want to kick the deferred page release from the shrinker
callback, for example?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
