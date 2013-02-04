Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id EE3E66B0002
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 21:49:52 -0500 (EST)
Date: Mon, 4 Feb 2013 11:49:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Questin about swap_slot free and invalidate page
Message-ID: <20130204024950.GD2688@blaptop>
References: <20130131051140.GB23548@blaptop>
 <alpine.LNX.2.00.1302031732520.4050@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302031732520.4050@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hi Hugh,

On Sun, Feb 03, 2013 at 05:51:14PM -0800, Hugh Dickins wrote:
> On Thu, 31 Jan 2013, Minchan Kim wrote:
> 
> > When I reviewed zswap, I was curious about frontswap_store.
> > It said following as.
> > 
> >  * If frontswap already contains a page with matching swaptype and
> >  * offset, the frontswap implementation may either overwrite the data and
> >  * return success or invalidate the page from frontswap and return failure.
> > 
> > It didn't say why it happens. we already have __frontswap_invalidate_page
> > and call it whenever swap_slot frees. If we don't free swap slot,
> > scan_swap_map can't find the slot for swap out so I thought overwriting of
> > data shouldn't happen in frontswap.
> > 
> > As I looked the code, the curplit is reuse_swap_page. It couldn't free swap
> > slot if the page founded is PG_writeback but miss calling frontswap_invalidate_page
> > so data overwriting on frontswap can happen. I'm not sure frontswap guys
> > already discussed it long time ago.
> > 
> > If we can fix it, we can remove duplication entry handling logic
> > in all of backend of frontswap. All of backend should handle it although
> > it's pretty rare. Of course, zram could be fixed. It might be trivial now
> > but more there are many backend of frontswap, more it would be a headache.
> > 
> > If we are trying to fix it in swap layer,  we might fix it following as
> > 
> > int reuse_swap_page(struct page *page)
> > {
> >         ..
> >         ..
> >         if (count == 1) {
> >                 if (!PageWriteback(page)) {
> >                         delete_from_swap_cache(page);
> >                         SetPageDirty(page);
> >                 } else {
> >                         frontswap_invalidate_page();
> >                         swap_slot_free_notify();
> >                 }
> >         }
> > }
> > 
> > But not sure, it is worth at the moment and there might be other places
> > to be fixed.(I hope Hugh can point out if we are missing something if he
> > has a time)
> 
> I expect you are right that reuse_swap_page() is the only way it would
> happen for frontswap; but I'm too unfamiliar with frontswap to promise
> you that - it's better that you insert WARN_ONs in your testing to verify.
> 
> But I think it's a general tmem property, isn't it?  To define what
> happens if you do give it the same key again.  So I doubt it's something

I am too unfamiliar with tmem property but thing I am seeing is
EXPORT_SYMBOL(__frontswap_store). It's a one of frontend and is tighly very
coupled with swap subsystem.

> that has to be fixed; but if you do find it helpful to fix it, bear in
> mind that reuse_swap_page() is an odd corner, which may one day give the
> "stable pages" DIF/DIX people trouble, though they've not yet complained.
> 
> I'd prefer a patch not specific to frontswap, but along the lines below:
> I think that's the most robust way to express it, though I don't think
> the (count == 0) case can actually occur inside that block (whereas
> count == 0 certainly can occur in the !PageSwapCache case).
> 
> I believe that I once upon a time took statistics of how often the
> PageWriteback case happens here, and concluded that it wasn't often
> enough that refusing to reuse in this case would be likely to slow
> anyone down noticeably.

I agree. I had a test about that with zram and that case wasn't common.
so your patch looks good to me.

I am waiting Dan's reply(He will come in this week) and then, judge what's
the best.

Thanks!

> 
> > 
> > If we are reluctant to it, at least, we should write out comment above
> > frontswap_store about that to notice curious guys who spend many
> > time to know WHY and smart guys who are going to fix it with nice way.
> > 
> > Mr. Frontswap, What do you think about it?
> 
> He's not me of course :)
> 
> Hugh
> 
> --- 3.8-rc6/mm/swapfile.c	2012-12-22 09:43:27.668015583 -0800
> +++ linux/mm/swapfile.c	2013-02-03 17:31:04.148181857 -0800
> @@ -637,8 +637,11 @@ int reuse_swap_page(struct page *page)
>  		return 0;
>  	count = page_mapcount(page);
>  	if (count <= 1 && PageSwapCache(page)) {
> -		count += page_swapcount(page);
> -		if (count == 1 && !PageWriteback(page)) {
> +		if (PageWriteback(page))
> +			count = 2;	/* not safe yet to free its swap */
> +		else
> +			count += page_swapcount(page);
> +		if (count <= 1) {
>  			delete_from_swap_cache(page);
>  			SetPageDirty(page);
>  		}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
