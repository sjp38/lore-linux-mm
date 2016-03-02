Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id EE08A828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 10:01:08 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id d205so72022438oia.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 07:01:08 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id rz4si8444402oeb.51.2016.03.02.07.01.07
        for <linux-mm@kvack.org>;
        Wed, 02 Mar 2016 07:01:08 -0800 (PST)
Date: Thu, 3 Mar 2016 00:01:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160302150112.GA18192@bbox>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20160302095056.GB26701@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Wed, Mar 02, 2016 at 10:50:56AM +0100, Michal Hocko wrote:
> On Wed 02-03-16 11:19:54, Joonsoo Kim wrote:
> > On Mon, Feb 29, 2016 at 10:02:13PM +0100, Michal Hocko wrote:
> [...]
> > > > +	/*
> > > > +	 * OK, so the watermak check has failed. Make sure we do all the
> > > > +	 * retries for !costly high order requests and hope that multiple
> > > > +	 * runs of compaction will generate some high order ones for us.
> > > > +	 *
> > > > +	 * XXX: ideally we should teach the compaction to try _really_ hard
> > > > +	 * if we are in the retry path - something like priority 0 for the
> > > > +	 * reclaim
> > > > +	 */
> > > > +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER)
> > > > +		return true;
> > > > +
> > > >  	return false;
> > 
> > This seems not a proper fix. Checking watermark with high order has
> > another meaning that there is high order page or not. This isn't
> > what we want here.
> 
> Why not? Why should we retry the reclaim if we do not have >=order page
> available? Reclaim itself doesn't guarantee any of the freed pages will
> form the requested order. The ordering on the LRU lists is pretty much
> random wrt. pfn ordering. On the other hand if we have a page available
> which is just hidden by watermarks then it makes perfect sense to retry
> and free even order-0 pages.
> 
> > So, following fix is needed.
> 
> > 'if (order)' check isn't needed. It is used to clarify the meaning of
> > this fix. You can remove it.
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1993894..8c80375 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3125,6 +3125,10 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> >         if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
> >                 return false;
> >  
> > +       /* To check whether compaction is available or not */
> > +       if (order)
> > +               order = 0;
> > +
> 
> This would enforce the order 0 wmark check which is IMHO not correct as
> per above.
> 
> >         /*
> >          * Keep reclaiming pages while there is a chance this will lead
> >          * somewhere.  If none of the target zones can satisfy our allocation
> > 
> > > >  }
> > > >  
> > > > @@ -3281,11 +3293,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  		goto noretry;
> > > >  
> > > >  	/*
> > > > -	 * Costly allocations might have made a progress but this doesn't mean
> > > > -	 * their order will become available due to high fragmentation so do
> > > > -	 * not reset the no progress counter for them
> > > > +	 * High order allocations might have made a progress but this doesn't
> > > > +	 * mean their order will become available due to high fragmentation so
> > > > +	 * do not reset the no progress counter for them
> > > >  	 */
> > > > -	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> > > > +	if (did_some_progress && !order)
> > > >  		no_progress_loops = 0;
> > > >  	else
> > > >  		no_progress_loops++;
> > 
> > This unconditionally increases no_progress_loops for high order
> > allocation, so, after 16 iterations, it will fail. If compaction isn't
> > enabled in Kconfig, 16 times reclaim attempt would not be sufficient
> > to make high order page. Should we consider this case also?
> 
> How many retries would help? I do not think any number will work
> reliably. Configurations without compaction enabled are asking for
> problems by definition IMHO. Relying on order-0 reclaim for high order
> allocations simply cannot work.

I left compaction code for a long time so a super hero might make it
perfect now but I don't think the dream come true yet and I believe
any algorithm has a drawback so we end up relying on a fallback approach
in case of not working compaction correctly.

My suggestion is to reintroduce *lumpy reclaim* and kicks in only when
compaction gave up by some reasons. It would be better to rely on
random number retrial of reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
