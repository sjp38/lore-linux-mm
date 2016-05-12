Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8556B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 06:59:56 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id f14so10408393lbb.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 03:59:56 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id jo9si15550279wjc.10.2016.05.12.03.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 03:59:55 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so15210235wmw.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 03:59:54 -0700 (PDT)
Date: Thu, 12 May 2016 12:59:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160512105953.GD4200@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <20160504084737.GB29978@dhcp22.suse.cz>
 <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
 <20160504181608.GA21490@dhcp22.suse.cz>
 <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
 <20160510094347.GH23576@dhcp22.suse.cz>
 <20160512022334.GA8215@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160512022334.GA8215@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 12-05-16 11:23:34, Joonsoo Kim wrote:
> On Tue, May 10, 2016 at 11:43:48AM +0200, Michal Hocko wrote:
> > On Tue 10-05-16 15:41:04, Joonsoo Kim wrote:
> > > 2016-05-05 3:16 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > > > On Wed 04-05-16 23:32:31, Joonsoo Kim wrote:
> > > >> 2016-05-04 17:47 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > [...]
> > > >> > progress. What is the usual reason to disable compaction in the first
> > > >> > place?
> > > >>
> > > >> I don't disable it. But, who knows who disable compaction? It's been *not*
> > > >> a long time that CONFIG_COMPACTION is default enable. Maybe, 3 years?
> > > >
> > > > I would really like to hear about real life usecase before we go and
> > > > cripple otherwise deterministic algorithms. It might be very well
> > > > possible that those configurations simply do not have problems with high
> > > > order allocations because they are too specific.
> > 
> > Sorry for insisting but I would really like to hear some answer for
> > this, please.
> 
> I don't know. Who knows? How you can make sure that?

This is pretty much a corner case configuration. I would assume that
somebody who wants to save memory for such an important feature for high
order allocations would have a very specific workloads.

> And, I don't like below fixup. Theoretically, it could retry forever.

Sure it can retry forever if we are constantly over the watermark and the
reclaim makes progress. This is the primary thing I hate about the
current implementation and the follow up fix reintroduces that behavior
for !COMPACTION case. It will OOM as soon as there is no reclaim
progress or all available zones are not passing the watermark check so
there shouldn't be any regressions.

> > [...]
> > > >> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > >> > index 2e7e26c5d3ba..f48b9e9b1869 100644
> > > >> > --- a/mm/page_alloc.c
> > > >> > +++ b/mm/page_alloc.c
> > > >> > @@ -3319,6 +3319,24 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> > > >> >                      enum migrate_mode *migrate_mode,
> > > >> >                      int compaction_retries)
> > > >> >  {
> > > >> > +       struct zone *zone;
> > > >> > +       struct zoneref *z;
> > > >> > +
> > > >> > +       if (order > PAGE_ALLOC_COSTLY_ORDER)
> > > >> > +               return false;
> > > >> > +
> > > >> > +       /*
> > > >> > +        * There are setups with compaction disabled which would prefer to loop
> > > >> > +        * inside the allocator rather than hit the oom killer prematurely. Let's
> > > >> > +        * give them a good hope and keep retrying while the order-0 watermarks
> > > >> > +        * are OK.
> > > >> > +        */
> > > >> > +       for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> > > >> > +                                       ac->nodemask) {
> > > >> > +               if(zone_watermark_ok(zone, 0, min_wmark_pages(zone),
> > > >> > +                                       ac->high_zoneidx, alloc_flags))
> > > >> > +                       return true;
> > > >> > +       }
> > > >> >         return false;
> > [...]
> > > My benchmark is too specific so I make another one. It does very
> > > simple things.
> > > 
> > > 1) Run the system with 256 MB memory and 2 GB swap
> > > 2) Run memory-hogger which takes (anonymous memory) 256 MB
> > > 3) Make 1000 new processes by fork (It will take 16 MB order-2 pages)
> > > 
> > > You can do it yourself with above instructions.
> > > 
> > > On current upstream kernel without CONFIG_COMPACTION, OOM doesn't happen.
> > > On next-20160509 kernel without CONFIG_COMPACTION, OOM happens when
> > > roughly *500* processes forked.
> > > 
> > > With CONFIG_COMPACTION, OOM doesn't happen on any kernel.
> > 
> > Does the patch I have posted helped?
> 
> I guess that it will help but please do it by yourself. It's simple.

Fair enough. I have prepared a similar setup (virtual machine with
2 CPUs, 256M RAM, 2G swap space, CONFIG_COMPACTION disabled and the
current mmotm tree). mem_eater does MAP_POPULATE 512MB of anon private
memory and then I start an aggressive fork test which is forking
short term children (which exit after a short <1s random timeout) as
quickly as possible and it makes sure there are always 1000 children
running. All this racing with the mem_eater. This was the test I was
originally using to test oom rework with COMPACTION enabled.

This triggered the OOM for order-2 allocation requests. With the patch
applied the test has survived.
             total       used       free     shared    buffers     cached
Mem:        232572     228748       3824          0       1164       2480
-/+ buffers/cache:     225104       7468
Swap:      2097148     348320    1748828
Node 0, zone      DMA
  pages free     282
        min      33
        low      41
--
Node 0, zone    DMA32
  pages free     610
        min      441
        low      551
nr_children:1000
^CCreated 11494416 children

I will post the patch shortly.

[...]

> I think that you don't understand how powerful the reclaim and
> compaction are. In the system with large disk swap, what compaction can do
> is also possible for reclaim. Reclaim can do more.
> 
> Think about following examples.
> 
> _: free
> U: used(unmovable)
> M: used(migratable and reclaimable)
> 
> _MUU _U_U MMMM MMMM
> 
> With compaction (assume theoretically best algorithm),
> just 3 contiguous region can be made like as following:
> 
> MMUU MUMU ___M MMMM
> 
> With reclaim, we can make 8 contiguous region.
> 
> __UU _U_U ____ ____
> 
> Reclaim can be easily affected by thrashing but it is fundamentally
> more powerful than compaction.

OK, it seems I was ambiguous in my previous statements, sorry about
that. Of course that reclaiming all (or large portion of) the memory
will free up more high order slots. But this is quite unreasonable
behavior to get few !costly blocks of memory because it affects most
processes. There should be some balance there.

> Even, there are not migratable but reclaimable pages and it could weak
> power of the compaction.
> 
> > > This failure shows that fundamental assumption of your patch is
> > > wrong. You triggers OOM even if there is enough reclaimable memory but
> > > no high order freepage depending on the fact that we can't guarantee
> > > that we can make high order page with reclaiming these reclaimable
> > > memory. Yes, we can't guarantee it but we also doesn't know if it
> > > can be possible or not. We should not stop reclaim until this
> > > estimation is is proved. Otherwise, it would be premature OOM.
> > 
> > We've been through this before and you keep repeating this argument. 
> > I have tried to explain that a deterministic behavior is more reasonable
> > than a random retry loops which pretty much depends on timing and which
> > can hugely over-reclaim which might be even worse than an OOM killer
> > invocation which would target a single process.
> 
> I didn't say that deterministic behavior is less reasonable. I like
> it. What I insist is the your criteria for deterministic behavior
> is wrong and please use another criteria for deterministic behavior.
> That's what I want.

I have structured my current criteria to be as independent on both
reclaim and compaction as possible and understandable at the same
time. I simply do not see how I would do it differently at this
moment. The current code behaves reasonably well with workloads I was
testing. I am not claiming this will need some surgery later on but I
would rather see oom reports and tweak the current implementation in
incremental steps than over engineer something from the early beginning
for theoretical issues which I even cannot get rid of completely. This
is a _heuristic_ and as such it can handle certain class of workloads
better than others. This is the case with the current implementation as
well.

[...]

> > Considering that we are in a clear disagreement in the compaction aspect
> > I think we need others to either back your concern or you show a clear
> > justification why compaction feedback is not viable way longterm even
> > after we make further changes which would make it less THP oriented.
> 
> I can't understand why I need to convince you. Conventionally, patch
> author needs to convince reviewer.

I am trying my best to clarify/justify my changes but it is really hard
when you disagree with some core principles with theoretical problems
which I do not see in practice. This is a heuristic and as such it will
never cover 100% cases. I aim to be as good as possible and the results
so far look reasonable to me.

> Anyway, above exmaple would be helpful to understand limitation of the
> compaction.

I understand that the compaction is not omnipotent and I can see there
will be corner cases but there always have been some in this area I am
just replacing the current by less fuzzy ones.
 
> If explanation in this reply also would not convince you, I
> won't insist more. Discussing more on this topic would not be
> productive for us.

I am afraid I haven't heard any such a strong argument to re-evaluate my
current position. As I've said we might need some tweaks here and there
in the future but at least we can build on a solid and deterministic
grounds which I find the most important aspect of the new
implementation.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
