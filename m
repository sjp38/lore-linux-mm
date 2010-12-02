Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 55D1A6B0085
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 15:53:50 -0500 (EST)
Date: Thu, 2 Dec 2010 12:53:42 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: [patch]vmscan: make kswapd use a correct order
Message-ID: <20101202205342.GB1892@hostway.ca>
References: <1291172911.12777.58.camel@sli10-conroe> <20101201132730.ABC2.A69D9226@jp.fujitsu.com> <20101201155854.GA3372@barrios-desktop> <20101202101234.GR13268@csn.ul.ie> <20101202153526.GB1735@barrios-desktop> <20101202154235.GY13268@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101202154235.GY13268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 02, 2010 at 03:42:35PM +0000, Mel Gorman wrote:

> On Fri, Dec 03, 2010 at 12:35:26AM +0900, Minchan Kim wrote:
> > > > @@ -2550,8 +2558,13 @@ static int kswapd(void *p)
> > > >  			 */
> > > >  			order = new_order;
> > > >  		} else {
> > > > -			kswapd_try_to_sleep(pgdat, order);
> > > > -			order = pgdat->kswapd_max_order;
> > > > +			/*
> > > > +			 * If we wake up after enough sleeping, let's
> > > > +			 * start new order. Otherwise, it was a premature
> > > > +			 * sleep so we keep going on.
> > > > +			 */
> > > > +			if (kswapd_try_to_sleep(pgdat, order))
> > > > +				order = pgdat->kswapd_max_order;
> > > 
> > > Ok, we lose the old order if we slept enough. That is fine because if we
> > > slept enough it implies that reclaiming at that order was no longer
> > > necessary.
> > > 
> > > This needs a repost with a full changelog explaining why order has to be
> > > preserved if kswapd fails to go to sleep. There will be merge difficulties
> > > with the series aimed at fixing Simon's problem but it's unavoidable.
> > > Rebasing on top of my series isn't an option as I'm still patching
> > > against mainline until that issue is resolved.
> > 
> > So what's your point?
> 
> Only point was to comment "I think this part of the patch is fine".
> 
> > Do you want me to send this patch alone
> > regardless of your series for Simon's problem?
> > 
> 
> Yes, because I do not believe the problems are directly related. When/if
> I get something working with Simon, I'll backport your patch on top of it
> for testing by him just in case but I don't think it'll affect him.

We could test this and your patch together, no?  Your patch definitely
fixed the case for us where kswapd would just run all day long, throwing
out everything while trying to reach the order-3 watermark in zone Normal
while order-0 page cache allocations were splitting it back out again.

However, the subject of my original post was to do with too much free
memory and swap, which is still occurring:

	http://0x.ca/sim/ref/2.6.36/memory_mel_patch_week.png

But this is still occurring even if I tell slub to use only order-0 and
order-1, and disable jumbo frames (which I did on another box, not this
one).  It may not be quite as bad, but I think the increase in free
memory is just based on fragmentation that builds up over time.  I don't
have any long-running graphs of this yet, but I can see that pretty much
all of the free memory always is order-0, and even a "while true; do
sleep .01; done" is enough to make it throw out more order-0 while trying
to make room for order-1 task_struct allocations.

Maybe some pattern in the way that pages are reclaimed while they are
being allocated is resulting in increasing fragmentation?  All the boxes
I see this on start out fine, but after a day or week they end up in swap
and with lots of free memory.

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
