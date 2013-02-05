Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C2DBF6B00D1
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 20:24:42 -0500 (EST)
Date: Tue, 5 Feb 2013 10:24:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Questin about swap_slot free and invalidate page
Message-ID: <20130205012440.GF2610@blaptop>
References: <20130131051140.GB23548@blaptop>
 <alpine.LNX.2.00.1302031732520.4050@eggly.anvils>
 <20130204024950.GD2688@blaptop>
 <d6fc41b7-8448-40be-84c3-c24d0833bd85@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6fc41b7-8448-40be-84c3-c24d0833bd85@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Feb 04, 2013 at 01:28:55PM -0800, Dan Magenheimer wrote:
> > From: Minchan Kim [mailto:minchan@kernel.org]
> > Sent: Sunday, February 03, 2013 7:50 PM
> > To: Hugh Dickins
> > Cc: Nitin Gupta; Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; linux-mm@kvack.org; linux-
> > kernel@vger.kernel.org; Andrew Morton
> > Subject: Re: Questin about swap_slot free and invalidate page
> > 
> > Hi Hugh,
> > 
> > On Sun, Feb 03, 2013 at 05:51:14PM -0800, Hugh Dickins wrote:
> > > On Thu, 31 Jan 2013, Minchan Kim wrote:
> > >
> > > > When I reviewed zswap, I was curious about frontswap_store.
> > > > It said following as.
> > > >
> > > >  * If frontswap already contains a page with matching swaptype and
> > > >  * offset, the frontswap implementation may either overwrite the data and
> > > >  * return success or invalidate the page from frontswap and return failure.
> > > >
> > > > It didn't say why it happens. we already have __frontswap_invalidate_page
> > > > and call it whenever swap_slot frees. If we don't free swap slot,
> > > > scan_swap_map can't find the slot for swap out so I thought overwriting of
> > > > data shouldn't happen in frontswap.
> > > >
> > > > As I looked the code, the curplit is reuse_swap_page. It couldn't free swap
> > > > slot if the page founded is PG_writeback but miss calling frontswap_invalidate_page
> > > > so data overwriting on frontswap can happen. I'm not sure frontswap guys
> > > > already discussed it long time ago.
> > > >
> > > > If we can fix it, we can remove duplication entry handling logic
> > > > in all of backend of frontswap. All of backend should handle it although
> > > > it's pretty rare. Of course, zram could be fixed. It might be trivial now
> > > > but more there are many backend of frontswap, more it would be a headache.
> > > >
> > > > If we are trying to fix it in swap layer,  we might fix it following as
> > > >
> > > > int reuse_swap_page(struct page *page)
> > > > {
> > > >         ..
> > > >         ..
> > > >         if (count == 1) {
> > > >                 if (!PageWriteback(page)) {
> > > >                         delete_from_swap_cache(page);
> > > >                         SetPageDirty(page);
> > > >                 } else {
> > > >                         frontswap_invalidate_page();
> > > >                         swap_slot_free_notify();
> > > >                 }
> > > >         }
> > > > }
> > > >
> > > > But not sure, it is worth at the moment and there might be other places
> > > > to be fixed.(I hope Hugh can point out if we are missing something if he
> > > > has a time)
> > >
> > > I expect you are right that reuse_swap_page() is the only way it would
> > > happen for frontswap; but I'm too unfamiliar with frontswap to promise
> > > you that - it's better that you insert WARN_ONs in your testing to verify.
> > >
> > > But I think it's a general tmem property, isn't it?  To define what
> > > happens if you do give it the same key again.  So I doubt it's something
> > 
> > I am too unfamiliar with tmem property but thing I am seeing is
> > EXPORT_SYMBOL(__frontswap_store). It's a one of frontend and is tighly very
> > coupled with swap subsystem.
> > 
> > > that has to be fixed; but if you do find it helpful to fix it, bear in
> > > mind that reuse_swap_page() is an odd corner, which may one day give the
> > > "stable pages" DIF/DIX people trouble, though they've not yet complained.
> > >
> > > I'd prefer a patch not specific to frontswap, but along the lines below:
> > > I think that's the most robust way to express it, though I don't think
> > > the (count == 0) case can actually occur inside that block (whereas
> > > count == 0 certainly can occur in the !PageSwapCache case).
> > >
> > > I believe that I once upon a time took statistics of how often the
> > > PageWriteback case happens here, and concluded that it wasn't often
> > > enough that refusing to reuse in this case would be likely to slow
> > > anyone down noticeably.
> > 
> > I agree. I had a test about that with zram and that case wasn't common.
> > so your patch looks good to me.
> > 
> > I am waiting Dan's reply(He will come in this week) and then, judge what's
> > the best.
> 
> Hugh is right that handling the possibility of duplicates is
> part of the tmem ABI.  If there is any possibility of duplicates,
> the ABI defines how a backend must handle them to avoid data
> coherency issues.
> 
> The kernel implements an in-kernel API which implements the tmem
> ABI.  If the frontend and backend can always agree that duplicates
> are never possible, I agree that the backend could avoid that
> special case.  However, duplicates occur rarely enough and the
> consequences (data loss) are bad enough that I think the case
> should still be checked, at least with a BUG_ON.  I also wonder
> if it is worth it to make changes to the core swap subsystem
> to avoid code to implement a zswap corner case.

It wasn't only zswap but it could be applied zram, too.

> 
> Remember that zswap is an oversimplified special case of tmem
> that handles only one frontend (Linux frontswap) and one backend
> (zswap).  Tmem goes well beyond that and already supports other
> more general backends including Xen and ramster, and could also
> support other frontends such as a BSD or Solaris equivalent
> of frontswap, for example with a Linux ramster/zcache backend.
> I'm not sure how wise it is to tear out generic code and replace
> it with simplistic code unless there is absolutely no chance that
> the generic code will be necessary.

Fair enough.

Thanks for clarifying that, Hugh, Dan.

> 
> My two cents,
> Dan
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
