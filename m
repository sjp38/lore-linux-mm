Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3B446B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 22:23:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 4so120271444pfw.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 19:23:32 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id kg11si13965679pab.171.2016.05.11.19.23.30
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 19:23:31 -0700 (PDT)
Date: Thu, 12 May 2016 11:23:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160512022334.GA8215@js1304-P5Q-DELUXE>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <20160504084737.GB29978@dhcp22.suse.cz>
 <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
 <20160504181608.GA21490@dhcp22.suse.cz>
 <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
 <20160510094347.GH23576@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160510094347.GH23576@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 10, 2016 at 11:43:48AM +0200, Michal Hocko wrote:
> On Tue 10-05-16 15:41:04, Joonsoo Kim wrote:
> > 2016-05-05 3:16 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > > On Wed 04-05-16 23:32:31, Joonsoo Kim wrote:
> > >> 2016-05-04 17:47 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> [...]
> > >> > progress. What is the usual reason to disable compaction in the first
> > >> > place?
> > >>
> > >> I don't disable it. But, who knows who disable compaction? It's been *not*
> > >> a long time that CONFIG_COMPACTION is default enable. Maybe, 3 years?
> > >
> > > I would really like to hear about real life usecase before we go and
> > > cripple otherwise deterministic algorithms. It might be very well
> > > possible that those configurations simply do not have problems with high
> > > order allocations because they are too specific.
> 
> Sorry for insisting but I would really like to hear some answer for
> this, please.

I don't know. Who knows? How you can make sure that? And, I don't like
below fixup. Theoretically, it could retry forever.

> 
> [...]
> > >> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > >> > index 2e7e26c5d3ba..f48b9e9b1869 100644
> > >> > --- a/mm/page_alloc.c
> > >> > +++ b/mm/page_alloc.c
> > >> > @@ -3319,6 +3319,24 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> > >> >                      enum migrate_mode *migrate_mode,
> > >> >                      int compaction_retries)
> > >> >  {
> > >> > +       struct zone *zone;
> > >> > +       struct zoneref *z;
> > >> > +
> > >> > +       if (order > PAGE_ALLOC_COSTLY_ORDER)
> > >> > +               return false;
> > >> > +
> > >> > +       /*
> > >> > +        * There are setups with compaction disabled which would prefer to loop
> > >> > +        * inside the allocator rather than hit the oom killer prematurely. Let's
> > >> > +        * give them a good hope and keep retrying while the order-0 watermarks
> > >> > +        * are OK.
> > >> > +        */
> > >> > +       for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> > >> > +                                       ac->nodemask) {
> > >> > +               if(zone_watermark_ok(zone, 0, min_wmark_pages(zone),
> > >> > +                                       ac->high_zoneidx, alloc_flags))
> > >> > +                       return true;
> > >> > +       }
> > >> >         return false;
> [...]
> > My benchmark is too specific so I make another one. It does very
> > simple things.
> > 
> > 1) Run the system with 256 MB memory and 2 GB swap
> > 2) Run memory-hogger which takes (anonymous memory) 256 MB
> > 3) Make 1000 new processes by fork (It will take 16 MB order-2 pages)
> > 
> > You can do it yourself with above instructions.
> > 
> > On current upstream kernel without CONFIG_COMPACTION, OOM doesn't happen.
> > On next-20160509 kernel without CONFIG_COMPACTION, OOM happens when
> > roughly *500* processes forked.
> > 
> > With CONFIG_COMPACTION, OOM doesn't happen on any kernel.
> 
> Does the patch I have posted helped?

I guess that it will help but please do it by yourself. It's simple.

> > Other kernels doesn't trigger OOM even if I make 10000 new processes.
> 
> Is this an usual load on !CONFIG_COMPACTION configurations?

I don't know. User-space developer doesn't take care about kernel
configuration and it seems that fork 500 times when memory is full is
not a corner case to me.

> > This example is very intuitive and reasonable. I think that it's not
> > artificial.  It has enough swap space so OOM should not happen.
> 
> I am not really convinced this is true actually. You can have an
> arbitrary amount of the swap space yet it still won't help you
> because more reclaimed memory simply doesn't imply a more continuous
> memory. This is a fundamental problem. So I think that relying on
> !CONFIG_COMPACTION for heavy fork (or other high order) loads simply
> never works reliably.

I think that you don't understand how powerful the reclaim and
compaction are. In the system with large disk swap, what compaction can do
is also possible for reclaim. Reclaim can do more.

Think about following examples.

_: free
U: used(unmovable)
M: used(migratable and reclaimable)

_MUU _U_U MMMM MMMM

With compaction (assume theoretically best algorithm),
just 3 contiguous region can be made like as following:

MMUU MUMU ___M MMMM

With reclaim, we can make 8 contiguous region.

__UU _U_U ____ ____

Reclaim can be easily affected by thrashing but it is fundamentally
more powerful than compaction.

Even, there are not migratable but reclaimable pages and it could weak
power of the compaction.

> > This failure shows that fundamental assumption of your patch is
> > wrong. You triggers OOM even if there is enough reclaimable memory but
> > no high order freepage depending on the fact that we can't guarantee
> > that we can make high order page with reclaiming these reclaimable
> > memory. Yes, we can't guarantee it but we also doesn't know if it
> > can be possible or not. We should not stop reclaim until this
> > estimation is is proved. Otherwise, it would be premature OOM.
> 
> We've been through this before and you keep repeating this argument. 
> I have tried to explain that a deterministic behavior is more reasonable
> than a random retry loops which pretty much depends on timing and which
> can hugely over-reclaim which might be even worse than an OOM killer
> invocation which would target a single process.

I didn't say that deterministic behavior is less reasonable. I like
it. What I insist is the your criteria for deterministic behavior
is wrong and please use another criteria for deterministic behavior.
That's what I want.

> I do agree that relying solely on the compaction is not the right way
> but combining the two (reclaim & compaction) should work reasonably well
> in practice. The only regression I have heard so far resulted from the
> lack of compaction feedback.

I agree that combining is needed. But, base criteria looks not
reasonable to me.

> > You applied band-aid for CONFIG_COMPACTION and fixed some reported
> > problem but it is also fragile. Assume almost pageblock's skipbit are
> > set. In this case, compaction easily returns COMPACT_COMPLETE and your
> > logic will stop retry. Compaction isn't designed to report accurate
> > fragmentation state of the system so depending on it's return value
> > for OOM is fragile.
> 
> Which is a deficiency of compaction. And the one which is worked on as
> already said by Vlastimil. Even with that deficiency, I am not able
> to trigger pre-mature OOM so it sounds more theoretical than a real
> issue. I am convinced that deeper surgery into compaction is really due
> as it has been mostly designed for THP case completely ignoring !costly
> allocations.
> 
> > Please fix your fundamental assumption and don't add band-aid using
> > compaction.
> 
> I do not consider compaction feedback design as a "band-aid". There is
> no other reliable source of high order pages except for compaction.
> 
> > I said same thing again and again and I can't convince you until now.
> > I'm not sure what I can do more.
> 
> Yes and yet I haven't seen any real life cases where this feedback
> mechanism doesn't work from you. You keep claiming that more reclaiming
> _might_ be useful without any grounds for that statement. Even when the
> more reclaim would help to survive a particular case we have to weigh
> pros and cons of the over reclaim and potential trashing which is worse
> than an OOM killer sometimes (staring at your machine you can ping but
> you cannot even log in...).

I didn't say that your OOM rework is totally wrong. I just said that
you should fix !costly order case since your criteria doesn't make
sense to this case.

> 
> Considering that we are in a clear disagreement in the compaction aspect
> I think we need others to either back your concern or you show a clear
> justification why compaction feedback is not viable way longterm even
> after we make further changes which would make it less THP oriented.

I can't understand why I need to convince you. Conventionally, patch
author needs to convince reviewer. Anyway, above exmaple would be helpful
to understand limitation of the compaction.

If explanation in this reply also would not convince you, I
won't insist more. Discussing more on this topic would not be
productive for us.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
