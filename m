Date: Wed, 10 Nov 2004 14:08:40 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-Id: <20041110140840.7e1769c9.akpm@digeo.com>
In-Reply-To: <20041110181450.GB12867@logos.cnet>
References: <20041109164642.GE7632@logos.cnet>
	<20041109121945.7f35d104.akpm@osdl.org>
	<20041109174125.GF7632@logos.cnet>
	<20041109133343.0b34896d.akpm@osdl.org>
	<20041109182622.GA8300@logos.cnet>
	<20041109142257.1d1411e1.akpm@osdl.org>
	<20041109203143.GC8414@logos.cnet>
	<20041109162801.7f7ca242.akpm@osdl.org>
	<20041110181450.GB12867@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> On Tue, Nov 09, 2004 at 04:28:01PM -0800, Andrew Morton wrote:
> > Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> > >
> > > Back to arguing in favour of my patch - it seemed to me that kswapd could 
> > >  go to sleep leaving allocators which can't reclaim pages themselves in a 
> > >  bad situation. 
> > 
> > Yes, but those processes would be sleeping in blk_congestion_wait() during,
> > say, a GFP_NOIO/GFP_NOFS allocation attempt.  And in that case, they may be
> > holding locks whcih prevent kswapd from being able to do any work either.
> > 
> > >  It would have to be waken up by another instance of alloc_pages to then 
> > >  execute and start doing its job, while if it was executing already (madly 
> > >  scanning as you say), the chance it would find freeable pages quite
> > >  earlier.
> > > 
> > >  Note that not only disk IO can cause pages to become freeable. A user
> > >  can give up its reference on pagecache page for example (leaving
> > >  the page on LRU to be found and freed by kswapd).
> > 
> > yup.  Or munlock(), or direct-io completion.
> 
> Andrew,
> 
> Shouldnt the kernel ideally clear zone->all_unreclaimable in those 
> situations? (munlock, direct-io completion, last reference on pagecache
> page, etc).

The design intent here is that a zone shouldn't enter the all-unreclaimable
state until we've absolutely scanned the crap out of it.  So we assume that
once a zone is all-unreclaimable then it will stay that way for a
relatively long time.  We do little, short scans just to poll the status of
the zone.  If one of those short scans ends up freeing a page then the zone
is removed from the all_unreclaimable state.

So if someone does one of the above things then we hope that a subsequent
short-scan will free a page and will wake the zone up.  This has the obvious
drawback that it might take us a number of scanning passes before we
discover a reclaimable page.   1<<DEF_PRIORITY passes, worst-case.

For munlock we'd need to actually examine the zone of each affected page,
which is a bunch of new code - a full pte walk.  We don't want munlocks of
ZONE_HIGHMEM to trigger these huge scans of a lower zone.

We could possibly put special-case code in the direct-io completion
handler, but it's all a bit weird.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
