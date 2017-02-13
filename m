Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C78446B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 00:06:39 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 145so115011264pfv.6
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 21:06:39 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id v185si8955981pgd.419.2017.02.12.21.06.37
        for <linux-mm@kvack.org>;
        Sun, 12 Feb 2017 21:06:38 -0800 (PST)
Date: Mon, 13 Feb 2017 14:06:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V2 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170213050636.GB27544@bbox>
References: <cover.1486163864.git.shli@fb.com>
 <9426fa2cf9fe320a15bfb20744c451eb6af1710a.1486163864.git.shli@fb.com>
 <20170210065839.GD25078@bbox>
 <20170210174307.GC86050@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210174307.GC86050@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 10, 2017 at 09:43:07AM -0800, Shaohua Li wrote:

< snip >

> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 947ab6f..b304a84 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -864,7 +864,7 @@ static enum page_references page_check_references(struct page *page,
> > >  		return PAGEREF_RECLAIM;
> > >  
> > >  	if (referenced_ptes) {
> > > -		if (PageSwapBacked(page))
> > > +		if (PageSwapBacked(page) || PageAnon(page))
> > 
> > If anyone accesses MADV_FREEed range with load op, not store,
> > why shouldn't we discard that pages?
> 
> Don't have strong opinion about this, userspace probably shouldn't do this. I'm
> ok to delete it if you insist.

Yes, I prefer to removing unnecessary code unless there is a some reaason.

> 
> > >  			return PAGEREF_ACTIVATE;
> > >  		/*
> > >  		 * All mapped pages start out with page table

< snip >

> > > @@ -971,7 +971,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  		int may_enter_fs;
> > >  		enum page_references references = PAGEREF_RECLAIM_CLEAN;
> > >  		bool dirty, writeback;
> > > -		bool lazyfree = false;
> > > +		bool lazyfree;
> > >  		int ret = SWAP_SUCCESS;
> > >  
> > >  		cond_resched();
> > > @@ -986,6 +986,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  
> > >  		sc->nr_scanned++;
> > >  
> > > +		lazyfree = page_is_lazyfree(page);
> > > +
> > >  		if (unlikely(!page_evictable(page)))
> > >  			goto cull_mlocked;
> > >  
> > > @@ -993,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  			goto keep_locked;
> > >  
> > >  		/* Double the slab pressure for mapped and swapcache pages */
> > > -		if (page_mapped(page) || PageSwapCache(page))
> > > +		if ((page_mapped(page) || PageSwapCache(page)) && !lazyfree)
> > >  			sc->nr_scanned++;
> > 
> > In this phase, we cannot know whether lazyfree marked page is discarable
> > or not. If it is freeable and mapped, this logic makes sense. However,
> > if the page is dirty?
> 
> I think this doesn't matter. If the page is dirty, it will go to reclaim in
> next round and swap out. At that time, we will add nr_scanned there.

If the lazyfree page in LRU comes around again into this, it's true but
the page could be freed before that.
Having said that, I don't know how critical it is and what kinds of rationale
was to push slab reclaim so I don't insist on it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
