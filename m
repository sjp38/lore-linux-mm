Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C83B828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:06:16 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so86970741wml.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:06:15 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id sc8si43151829wjb.216.2016.03.02.06.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 06:06:14 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id 1so9811377wmg.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:06:14 -0800 (PST)
Date: Wed, 2 Mar 2016 15:06:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160302140611.GI26686@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Wed 02-03-16 22:32:09, Joonsoo Kim wrote:
> 2016-03-02 18:50 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 02-03-16 11:19:54, Joonsoo Kim wrote:
> >> On Mon, Feb 29, 2016 at 10:02:13PM +0100, Michal Hocko wrote:
> > [...]
> >> > > + /*
> >> > > +  * OK, so the watermak check has failed. Make sure we do all the
> >> > > +  * retries for !costly high order requests and hope that multiple
> >> > > +  * runs of compaction will generate some high order ones for us.
> >> > > +  *
> >> > > +  * XXX: ideally we should teach the compaction to try _really_ hard
> >> > > +  * if we are in the retry path - something like priority 0 for the
> >> > > +  * reclaim
> >> > > +  */
> >> > > + if (order && order <= PAGE_ALLOC_COSTLY_ORDER)
> >> > > +         return true;
> >> > > +
> >> > >   return false;
> >>
> >> This seems not a proper fix. Checking watermark with high order has
> >> another meaning that there is high order page or not. This isn't
> >> what we want here.
> >
> > Why not? Why should we retry the reclaim if we do not have >=order page
> > available? Reclaim itself doesn't guarantee any of the freed pages will
> > form the requested order. The ordering on the LRU lists is pretty much
> > random wrt. pfn ordering. On the other hand if we have a page available
> > which is just hidden by watermarks then it makes perfect sense to retry
> > and free even order-0 pages.
> 
> If we have >= order page available, we would not reach here. We would
> just allocate it.

not really, we can still be under the low watermark. Note that the
target for the should_reclaim_retry watermark check includes also the
reclaimable memory.
 
> And, should_reclaim_retry() is not just for reclaim. It is also for
> retrying compaction.
> 
> That watermark check is to check further reclaim/compaction
> is meaningful. And, for high order case, if there is enough freepage,
> compaction could make high order page even if there is no high order
> page now.
> 
> Adding freeable memory and checking watermark with it doesn't help
> in this case because number of high order page isn't changed with it.
> 
> I just did quick review to your patches so maybe I am wrong.
> Am I missing something?

The core idea behind should_reclaim_retry is to check whether the
reclaiming all the pages would help to get over the watermark and there
is at least one >= order page. Then it really makes sense to retry. As
the compaction has already was performed before this is called we should
have created some high order pages already. The decay guarantees that we
eventually trigger the OOM killer after some attempts.

If the compaction can backoff and ignore our requests then we are
screwed of course and that should be addressed imho at the compaction
layer. Maybe we can tell the compaction to try harder but I would like
to understand why this shouldn't be a default behavior for !costly
orders.
 
[...]
> >> > > @@ -3281,11 +3293,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >> > >           goto noretry;
> >> > >
> >> > >   /*
> >> > > -  * Costly allocations might have made a progress but this doesn't mean
> >> > > -  * their order will become available due to high fragmentation so do
> >> > > -  * not reset the no progress counter for them
> >> > > +  * High order allocations might have made a progress but this doesn't
> >> > > +  * mean their order will become available due to high fragmentation so
> >> > > +  * do not reset the no progress counter for them
> >> > >    */
> >> > > - if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> >> > > + if (did_some_progress && !order)
> >> > >           no_progress_loops = 0;
> >> > >   else
> >> > >           no_progress_loops++;
> >>
> >> This unconditionally increases no_progress_loops for high order
> >> allocation, so, after 16 iterations, it will fail. If compaction isn't
> >> enabled in Kconfig, 16 times reclaim attempt would not be sufficient
> >> to make high order page. Should we consider this case also?
> >
> > How many retries would help? I do not think any number will work
> > reliably. Configurations without compaction enabled are asking for
> > problems by definition IMHO. Relying on order-0 reclaim for high order
> > allocations simply cannot work.
> 
> At least, reset no_progress_loops when did_some_progress. High
> order allocation up to PAGE_ALLOC_COSTLY_ORDER is as important
> as order 0. And, reclaim something would increase probability of
> compaction success.

This is something I still do not understand. Why would reclaiming
random order-0 pages help compaction? Could you clarify this please?

> Why do we limit retry as 16 times with no evidence of potential
> impossibility of making high order page?

If we tried to compact 16 times without any progress then this sounds
like a sufficient evidence to me. Well, this number is somehow arbitrary
but the main point is to limit it to _some_ number, if we can show that
a larger value would work better then we can update it of course.

> And, 16 retry looks not good to me because compaction could defer
> actual doing up to 64 times.

OK, this is something that needs to be handled in a better way. The
primary question would be why to defer the compaction for <=
PAGE_ALLOC_COSTLY_ORDER requests in the first place. I guess I do see
why it makes sense it for the best effort mode of operation but !costly
orders should be trying much harder as they are nofail, no?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
