Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 31C516B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 00:23:02 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id m184so51788676iof.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 21:23:02 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m16si1943715igt.54.2016.03.03.21.23.00
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 21:23:01 -0800 (PST)
Date: Fri, 4 Mar 2016 14:23:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160304052327.GA13022@js1304-P5Q-DELUXE>
References: <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
 <20160302140611.GI26686@dhcp22.suse.cz>
 <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
 <20160303092634.GB26202@dhcp22.suse.cz>
 <CAAmzW4NQznWcCWrwKk836yB0bhOaHNygocznzuaj5sJeepHfYQ@mail.gmail.com>
 <20160303152514.GG26202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160303152514.GG26202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Mar 03, 2016 at 04:25:15PM +0100, Michal Hocko wrote:
> On Thu 03-03-16 23:10:09, Joonsoo Kim wrote:
> > 2016-03-03 18:26 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > > On Wed 02-03-16 23:34:21, Joonsoo Kim wrote:
> > >> 2016-03-02 23:06 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > >> > On Wed 02-03-16 22:32:09, Joonsoo Kim wrote:
> > >> >> 2016-03-02 18:50 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > >> >> > On Wed 02-03-16 11:19:54, Joonsoo Kim wrote:
> > >> >> >> On Mon, Feb 29, 2016 at 10:02:13PM +0100, Michal Hocko wrote:
> > >> >> > [...]
> > >> >> >> > > + /*
> > >> >> >> > > +  * OK, so the watermak check has failed. Make sure we do all the
> > >> >> >> > > +  * retries for !costly high order requests and hope that multiple
> > >> >> >> > > +  * runs of compaction will generate some high order ones for us.
> > >> >> >> > > +  *
> > >> >> >> > > +  * XXX: ideally we should teach the compaction to try _really_ hard
> > >> >> >> > > +  * if we are in the retry path - something like priority 0 for the
> > >> >> >> > > +  * reclaim
> > >> >> >> > > +  */
> > >> >> >> > > + if (order && order <= PAGE_ALLOC_COSTLY_ORDER)
> > >> >> >> > > +         return true;
> > >> >> >> > > +
> > >> >> >> > >   return false;
> > >> >> >>
> > >> >> >> This seems not a proper fix. Checking watermark with high order has
> > >> >> >> another meaning that there is high order page or not. This isn't
> > >> >> >> what we want here.
> > >> >> >
> > >> >> > Why not? Why should we retry the reclaim if we do not have >=order page
> > >> >> > available? Reclaim itself doesn't guarantee any of the freed pages will
> > >> >> > form the requested order. The ordering on the LRU lists is pretty much
> > >> >> > random wrt. pfn ordering. On the other hand if we have a page available
> > >> >> > which is just hidden by watermarks then it makes perfect sense to retry
> > >> >> > and free even order-0 pages.
> > >> >>
> > >> >> If we have >= order page available, we would not reach here. We would
> > >> >> just allocate it.
> > >> >
> > >> > not really, we can still be under the low watermark. Note that the
> > >>
> > >> you mean min watermark?
> > >
> > > ohh, right...
> > >
> > >> > target for the should_reclaim_retry watermark check includes also the
> > >> > reclaimable memory.
> > >>
> > >> I guess that usual case for high order allocation failure has enough freepage.
> > >
> > > Not sure I understand you mean here but I wouldn't be surprised if high
> > > order failed even with enough free pages. And that is exactly why I am
> > > claiming that reclaiming more pages is no free ticket to high order
> > > pages.
> > 
> > I didn't say that it's free ticket. OOM kill would be the most expensive ticket
> > that we have. Why do you want to kill something?
> 
> Because all the attempts so far have failed and we should rather not
> retry endlessly. With the band-aid we know we will retry
> MAX_RECLAIM_RETRIES at most. So compaction had that many attempts to
> resolve the situation along with the same amount of reclaim rounds to
> help and get over watermarks.
> 
> > It also doesn't guarantee to make high order pages. It is just another
> > way of reclaiming memory. What is the difference between plain reclaim
> > and OOM kill? Why do we use OOM kill in this case?
> 
> What is our alternative other than keep looping endlessly?

Loop as long as free memory or estimated available memory (free +
reclaimable) increases. This means that we did some progress. And,
they will not grow forever because we have just limited reclaimable
memory and limited memory. You can reset no_progress_loops = 0 when
those metric increases than before.

With this bound, we can do our best to try to solve this unpleasant
situation before OOM.

Unconditional 16 looping and then OOM kill really doesn't make any
sense, because it doesn't mean that we already do our best. OOM
should not be called prematurely and AFAIK it is one of goals
on your patches.

If above suggestion doesn't make sense to you, please try to find
another way rather than suggesting work-around that could cause
OOM prematurely in high order allocation case.

Thanks.

> 
> > > [...]
> > >> >> I just did quick review to your patches so maybe I am wrong.
> > >> >> Am I missing something?
> > >> >
> > >> > The core idea behind should_reclaim_retry is to check whether the
> > >> > reclaiming all the pages would help to get over the watermark and there
> > >> > is at least one >= order page. Then it really makes sense to retry. As
> > >>
> > >> How you can judge that reclaiming all the pages would help to check
> > >> there is at least one >= order page?
> > >
> > > Again, not sure I understand you here. __zone_watermark_ok checks both
> > > wmark and an available page of the sufficient order. While increased
> > > free_pages (which includes reclaimable pages as well) will tell us
> > > whether we have a chance to get over the min wmark, the order check will
> > > tell us we have something to allocate from after we reach the min wmark.
> > 
> > Again, your assumption would be different with mine. My assumption is that
> > high order allocation problem happens due to fragmentation rather than
> > low free memory. In this case, there is no high order page. Even if you can
> > reclaim 1TB and add this counter to freepage counter, high order page
> > counter will not be changed and watermark check would fail. So, high order
> > allocation will not go through retry logic. This is what you want?
> 
> I really want to base the decision on something measurable rather
> than a good hope. This is what all the zone_reclaimable() is about. I
> understand your concerns that compaction doesn't guarantee anything but
> I am quite convinced that we really need an upper bound for retries
> (unlike now when zone_reclaimable is basically unbounded assuming
> order-0 reclaim makes some progress). What is the best bound is harder
> to tell, of course.
> 
> [...]
> > >> My arguing is for your band aid patch.
> > >> My point is that why retry count for order-0 is reset if there is some progress,
> > >> but, retry counter for order up to costly isn't reset even if there is
> > >> some progress
> > >
> > > Because we know that order-0 requests have chance to proceed if we keep
> > > reclaiming order-0 pages while this is not true for order > 0. If we did
> > > reset the no_progress_loops for order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER
> > > then we would be back to the zone_reclaimable heuristic. Why? Because
> > > order-0 reclaim progress will keep !costly in the reclaim loop while
> > > compaction still might not make any progress. So we either have to fail
> > > when __zone_watermark_ok fails for the order (which turned out to be
> > > too easy to trigger) or have the fixed amount of retries regardless the
> > > watermark check result. We cannot relax both unless we have other
> > > measures in place.
> > 
> > As mentioned before, OOM kill also doesn't guarantee to make high order page.
> 
> Yes, of course, apart from the kernel stack which is high order there is
> no guarantee.
> 
> > Reclaim more memory as much as possible makes more sense to me.
> 
> But then we are back to square one. How much and how to decide when it
> makes sense to give up. Do you have any suggestions on what should be
> the criteria? Is there any feedback mechanism from the compaction which
> would tell us to keep retrying? Something like did_some_progress from
> the order-0 reclaim? Is any of deferred_compaction resp.
> contended_compaction usable? Or is there any per-zone flag we can check
> and prefer over wmark order check?
> 
> Thanks
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
