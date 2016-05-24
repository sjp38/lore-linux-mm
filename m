Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09E396B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 02:27:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 77so14486346pfz.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 23:27:50 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j69si13949798pfa.97.2016.05.23.23.27.47
        for <linux-mm@kvack.org>;
        Mon, 23 May 2016 23:27:48 -0700 (PDT)
Date: Tue, 24 May 2016 15:28:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160524062801.GB29094@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
 <20160524052824.GA496@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524052824.GA496@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, May 24, 2016 at 02:28:24PM +0900, Sergey Senozhatsky wrote:
> On (05/20/16 23:23), Minchan Kim wrote:
> [..]
> > +static int get_zspage_isolation(struct zspage *zspage)
> > +{
> > +	return zspage->isolated;
> > +}
> > +
> 
> may be is_zspage_isolated()?

Now, it would be better. I will change it.

> 
> [..]
> > @@ -502,23 +556,19 @@ static int get_size_class_index(int size)
> >  static inline void zs_stat_inc(struct size_class *class,
> >  				enum zs_stat_type type, unsigned long cnt)
> >  {
> > -	if (type < NR_ZS_STAT_TYPE)
> > -		class->stats.objs[type] += cnt;
> > +	class->stats.objs[type] += cnt;
> >  }
> >  
> >  static inline void zs_stat_dec(struct size_class *class,
> >  				enum zs_stat_type type, unsigned long cnt)
> >  {
> > -	if (type < NR_ZS_STAT_TYPE)
> > -		class->stats.objs[type] -= cnt;
> > +	class->stats.objs[type] -= cnt;
> >  }
> >  
> >  static inline unsigned long zs_stat_get(struct size_class *class,
> >  				enum zs_stat_type type)
> >  {
> > -	if (type < NR_ZS_STAT_TYPE)
> > -		return class->stats.objs[type];
> > -	return 0;
> > +	return class->stats.objs[type];
> >  }
> 
> hmm... the ordering of STAT types and those if-conditions were here for
> a reason:
> 
> commit 6fe5186f0c7c18a8beb6d96c21e2390df7a12375
> Author: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Date:   Fri Nov 6 16:29:38 2015 -0800
> 
>     zsmalloc: reduce size_class memory usage
>     
>     Each `struct size_class' contains `struct zs_size_stat': an array of
>     NR_ZS_STAT_TYPE `unsigned long'.  For zsmalloc built with no
>     CONFIG_ZSMALLOC_STAT this results in a waste of `2 * sizeof(unsigned
>     long)' per-class.
>     
>     The patch removes unneeded `struct zs_size_stat' members by redefining
>     NR_ZS_STAT_TYPE (max stat idx in array).
>     
>     Since both NR_ZS_STAT_TYPE and zs_stat_type are compile time constants,
>     GCC can eliminate zs_stat_inc()/zs_stat_dec() calls that use zs_stat_type
>     larger than NR_ZS_STAT_TYPE: CLASS_ALMOST_EMPTY and CLASS_ALMOST_FULL at
>     the moment.
>     
>     ./scripts/bloat-o-meter mm/zsmalloc.o.old mm/zsmalloc.o.new
>     add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-39 (-39)
>     function                                     old     new   delta
>     fix_fullness_group                            97      94      -3
>     insert_zspage                                100      86     -14
>     remove_zspage                                141     119     -22
>     
>     To summarize:
>     a) each class now uses less memory
>     b) we avoid a number of dec/inc stats (a minor optimization,
>        but still).
>     
>     The gain will increase once we introduce additional stats.
> 
> so it helped to eliminate instructions at compile time from a very hot
> path for !CONFIG_ZSMALLOC_STAT builds (which is 99% of the builds I think,
> I doubt anyone apart from us is using ZSMALLOC_STAT).

Most important point to me is that it makes code *simple* at the cost of
addtional wasting memory. Now, every zspage lives in *a* list so we don't
need to check zspage groupness to use list_empty of zspage.
I'm not sure how you feel it makes code simple a lot.
However, while I implement page migration logic, the check with condition
that zspage's groupness is either almost_empty and almost_full is really
bogus and tricky to me so I should debug several time to find what's
wrong.

Compared to old, zsmalloc is complicated day by day so I want to weight
on *simple* for easy maintainance.

One more note:
Now, ZS_EMPTY is used as pool. Look at find_get_zspage. So adding
"empty" column in ZSMALLOC_STAT might be worth but I wanted to handle it
as another topic.

So if you don't feel strong the saving is really huge, I want to
go with this. And if we are adding more wasted memory in future,
let's handle it then.

About CONFIG_ZSMALLOC_STAT, It might be off-topic. Frankly speaking,
I have guided production team to enable it because when I profile the
overhead caused by ZSMALLOC_STAT, there is no performance lost
in real workload. However, the stat gives more detailed useful
information.

> 
> 
> [..]
> > +static int get_first_obj_offset(struct size_class *class,
> > +				struct page *first_page, struct page *page)
> >  {
> > -	return page->next;
> > +	int pos, bound;
> > +	int page_idx = 0;
> > +	int ofs = 0;
> > +	struct page *cursor = first_page;
> > +
> > +	if (first_page == page)
> > +		goto out;
> > +
> > +	while (page != cursor) {
> > +		page_idx++;
> > +		cursor = get_next_page(cursor);
> > +	}
> > +
> > +	bound = PAGE_SIZE * page_idx;
> 
> 'bound' not used.

-_-;;

> 
> 
> > +	pos = (((class->objs_per_zspage * class->size) *
> > +		page_idx / class->pages_per_zspage) / class->size
> > +	      ) * class->size;
> 
> 
> something went wrong with the indentation here :)
> 
> so... it's
> 
> 	(((class->objs_per_zspage * class->size) * page_idx / class->pages_per_zspage) / class->size ) * class->size;
> 
> the last ' / class->size ) * class->size' can be dropped, I think.

You prove I didn't learn math.
Will drop it.

> 
> [..]
> > +		pos += class->size;
> > +	}
> > +
> > +	/*
> > +	 * Here, any user cannot access all objects in the zspage so let's move.
>                  "no one can access any object" ?
> 
> [..]
> > +	spin_lock(&class->lock);
> > +	dec_zspage_isolation(zspage);
> > +	if (!get_zspage_isolation(zspage)) {
> > +		fg = putback_zspage(class, zspage);
> > +		/*
> > +		 * Due to page_lock, we cannot free zspage immediately
> > +		 * so let's defer.
> > +		 */
> > +		if (fg == ZS_EMPTY)
> > +			schedule_work(&pool->free_work);
> 
> hm... zsmalloc is getting sooo complex now.
> 
> `system_wq' -- can we have problems here when the system is getting
> low on memory and workers are getting increasingly busy trying to
> allocate the memory for some other purposes?
> 
> _theoretically_ zsmalloc can stack a number of ready-to-release zspages,
> which won't be accessible to zsmalloc, nor will they be released. how likely
> is this? hm, can zsmalloc take zspages from that deferred release list when
> it wants to allocate a new zspage?

Done.

> 
> do you also want to kick the deferred page release from the shrinker
> callback, for example?

Yeb, it can be. I will do it at next revision. :)
Thanks!

> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
