Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 36D9A6B0258
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 04:26:39 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l68so23176713wml.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 01:26:39 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id di9si47594269wjc.18.2016.03.03.01.26.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 01:26:37 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id n186so3075403wmn.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 01:26:37 -0800 (PST)
Date: Thu, 3 Mar 2016 10:26:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160303092634.GB26202@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
 <20160302140611.GI26686@dhcp22.suse.cz>
 <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Wed 02-03-16 23:34:21, Joonsoo Kim wrote:
> 2016-03-02 23:06 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 02-03-16 22:32:09, Joonsoo Kim wrote:
> >> 2016-03-02 18:50 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> >> > On Wed 02-03-16 11:19:54, Joonsoo Kim wrote:
> >> >> On Mon, Feb 29, 2016 at 10:02:13PM +0100, Michal Hocko wrote:
> >> > [...]
> >> >> > > + /*
> >> >> > > +  * OK, so the watermak check has failed. Make sure we do all the
> >> >> > > +  * retries for !costly high order requests and hope that multiple
> >> >> > > +  * runs of compaction will generate some high order ones for us.
> >> >> > > +  *
> >> >> > > +  * XXX: ideally we should teach the compaction to try _really_ hard
> >> >> > > +  * if we are in the retry path - something like priority 0 for the
> >> >> > > +  * reclaim
> >> >> > > +  */
> >> >> > > + if (order && order <= PAGE_ALLOC_COSTLY_ORDER)
> >> >> > > +         return true;
> >> >> > > +
> >> >> > >   return false;
> >> >>
> >> >> This seems not a proper fix. Checking watermark with high order has
> >> >> another meaning that there is high order page or not. This isn't
> >> >> what we want here.
> >> >
> >> > Why not? Why should we retry the reclaim if we do not have >=order page
> >> > available? Reclaim itself doesn't guarantee any of the freed pages will
> >> > form the requested order. The ordering on the LRU lists is pretty much
> >> > random wrt. pfn ordering. On the other hand if we have a page available
> >> > which is just hidden by watermarks then it makes perfect sense to retry
> >> > and free even order-0 pages.
> >>
> >> If we have >= order page available, we would not reach here. We would
> >> just allocate it.
> >
> > not really, we can still be under the low watermark. Note that the
> 
> you mean min watermark?

ohh, right...
 
> > target for the should_reclaim_retry watermark check includes also the
> > reclaimable memory.
> 
> I guess that usual case for high order allocation failure has enough freepage.

Not sure I understand you mean here but I wouldn't be surprised if high
order failed even with enough free pages. And that is exactly why I am
claiming that reclaiming more pages is no free ticket to high order
pages.

[...]
> >> I just did quick review to your patches so maybe I am wrong.
> >> Am I missing something?
> >
> > The core idea behind should_reclaim_retry is to check whether the
> > reclaiming all the pages would help to get over the watermark and there
> > is at least one >= order page. Then it really makes sense to retry. As
> 
> How you can judge that reclaiming all the pages would help to check
> there is at least one >= order page?

Again, not sure I understand you here. __zone_watermark_ok checks both
wmark and an available page of the sufficient order. While increased
free_pages (which includes reclaimable pages as well) will tell us
whether we have a chance to get over the min wmark, the order check will
tell us we have something to allocate from after we reach the min wmark.
 
> > the compaction has already was performed before this is called we should
> > have created some high order pages already. The decay guarantees that we
> 
> Not really. Compaction could fail.

Yes it could have failed. But what is the point to retry endlessly then?

[...]
> >> At least, reset no_progress_loops when did_some_progress. High
> >> order allocation up to PAGE_ALLOC_COSTLY_ORDER is as important
> >> as order 0. And, reclaim something would increase probability of
> >> compaction success.
> >
> > This is something I still do not understand. Why would reclaiming
> > random order-0 pages help compaction? Could you clarify this please?
> 
> I just can tell simple version. Please check the link from me on another reply.
> Compaction could scan more range of memory if we have more freepage.
> This is due to algorithm limitation. Anyway, so, reclaiming random
> order-0 pages helps compaction.

I will have a look at that code but this just doesn't make any sense.
The compaction should be reshuffling pages, this shouldn't be a function
of free memory.

> >> Why do we limit retry as 16 times with no evidence of potential
> >> impossibility of making high order page?
> >
> > If we tried to compact 16 times without any progress then this sounds
> > like a sufficient evidence to me. Well, this number is somehow arbitrary
> > but the main point is to limit it to _some_ number, if we can show that
> > a larger value would work better then we can update it of course.
> 
> My arguing is for your band aid patch.
> My point is that why retry count for order-0 is reset if there is some progress,
> but, retry counter for order up to costly isn't reset even if there is
> some progress

Because we know that order-0 requests have chance to proceed if we keep
reclaiming order-0 pages while this is not true for order > 0. If we did
reset the no_progress_loops for order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER 
then we would be back to the zone_reclaimable heuristic. Why? Because
order-0 reclaim progress will keep !costly in the reclaim loop while
compaction still might not make any progress. So we either have to fail
when __zone_watermark_ok fails for the order (which turned out to be
too easy to trigger) or have the fixed amount of retries regardless the
watermark check result. We cannot relax both unless we have other
measures in place.

Sure we can be more intelligent and reset the counter if the
feedback from compaction is optimistic and we are making some
progress. This would be less hackish and the XXX comment points into
that direction. For now I would like this to catch most loads reasonably
and build better heuristics on top. I would like to do as much as
possible to close the obvious regressions but I guess we have to expect
there will be cases where the OOM fires and hasn't before and vice
versa.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
