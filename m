Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB5E6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 05:43:51 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8so6436114lfd.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 02:43:51 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 204si30957664wmg.36.2016.05.10.02.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 02:43:49 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so1701241wmw.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 02:43:49 -0700 (PDT)
Date: Tue, 10 May 2016 11:43:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160510094347.GH23576@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <20160504084737.GB29978@dhcp22.suse.cz>
 <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
 <20160504181608.GA21490@dhcp22.suse.cz>
 <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 10-05-16 15:41:04, Joonsoo Kim wrote:
> 2016-05-05 3:16 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 04-05-16 23:32:31, Joonsoo Kim wrote:
> >> 2016-05-04 17:47 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
[...]
> >> > progress. What is the usual reason to disable compaction in the first
> >> > place?
> >>
> >> I don't disable it. But, who knows who disable compaction? It's been *not*
> >> a long time that CONFIG_COMPACTION is default enable. Maybe, 3 years?
> >
> > I would really like to hear about real life usecase before we go and
> > cripple otherwise deterministic algorithms. It might be very well
> > possible that those configurations simply do not have problems with high
> > order allocations because they are too specific.

Sorry for insisting but I would really like to hear some answer for
this, please.

[...]
> >> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> > index 2e7e26c5d3ba..f48b9e9b1869 100644
> >> > --- a/mm/page_alloc.c
> >> > +++ b/mm/page_alloc.c
> >> > @@ -3319,6 +3319,24 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> >> >                      enum migrate_mode *migrate_mode,
> >> >                      int compaction_retries)
> >> >  {
> >> > +       struct zone *zone;
> >> > +       struct zoneref *z;
> >> > +
> >> > +       if (order > PAGE_ALLOC_COSTLY_ORDER)
> >> > +               return false;
> >> > +
> >> > +       /*
> >> > +        * There are setups with compaction disabled which would prefer to loop
> >> > +        * inside the allocator rather than hit the oom killer prematurely. Let's
> >> > +        * give them a good hope and keep retrying while the order-0 watermarks
> >> > +        * are OK.
> >> > +        */
> >> > +       for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> >> > +                                       ac->nodemask) {
> >> > +               if(zone_watermark_ok(zone, 0, min_wmark_pages(zone),
> >> > +                                       ac->high_zoneidx, alloc_flags))
> >> > +                       return true;
> >> > +       }
> >> >         return false;
[...]
> My benchmark is too specific so I make another one. It does very
> simple things.
> 
> 1) Run the system with 256 MB memory and 2 GB swap
> 2) Run memory-hogger which takes (anonymous memory) 256 MB
> 3) Make 1000 new processes by fork (It will take 16 MB order-2 pages)
> 
> You can do it yourself with above instructions.
> 
> On current upstream kernel without CONFIG_COMPACTION, OOM doesn't happen.
> On next-20160509 kernel without CONFIG_COMPACTION, OOM happens when
> roughly *500* processes forked.
> 
> With CONFIG_COMPACTION, OOM doesn't happen on any kernel.

Does the patch I have posted helped?

> Other kernels doesn't trigger OOM even if I make 10000 new processes.

Is this an usual load on !CONFIG_COMPACTION configurations?

> This example is very intuitive and reasonable. I think that it's not
> artificial.  It has enough swap space so OOM should not happen.

I am not really convinced this is true actually. You can have an
arbitrary amount of the swap space yet it still won't help you
because more reclaimed memory simply doesn't imply a more continuous
memory. This is a fundamental problem. So I think that relying on
!CONFIG_COMPACTION for heavy fork (or other high order) loads simply
never works reliably.

> This failure shows that fundamental assumption of your patch is
> wrong. You triggers OOM even if there is enough reclaimable memory but
> no high order freepage depending on the fact that we can't guarantee
> that we can make high order page with reclaiming these reclaimable
> memory. Yes, we can't guarantee it but we also doesn't know if it
> can be possible or not. We should not stop reclaim until this
> estimation is is proved. Otherwise, it would be premature OOM.

We've been through this before and you keep repeating this argument. 
I have tried to explain that a deterministic behavior is more reasonable
than a random retry loops which pretty much depends on timing and which
can hugely over-reclaim which might be even worse than an OOM killer
invocation which would target a single process.

I do agree that relying solely on the compaction is not the right way
but combining the two (reclaim & compaction) should work reasonably well
in practice. The only regression I have heard so far resulted from the
lack of compaction feedback.

> You applied band-aid for CONFIG_COMPACTION and fixed some reported
> problem but it is also fragile. Assume almost pageblock's skipbit are
> set. In this case, compaction easily returns COMPACT_COMPLETE and your
> logic will stop retry. Compaction isn't designed to report accurate
> fragmentation state of the system so depending on it's return value
> for OOM is fragile.

Which is a deficiency of compaction. And the one which is worked on as
already said by Vlastimil. Even with that deficiency, I am not able
to trigger pre-mature OOM so it sounds more theoretical than a real
issue. I am convinced that deeper surgery into compaction is really due
as it has been mostly designed for THP case completely ignoring !costly
allocations.

> Please fix your fundamental assumption and don't add band-aid using
> compaction.

I do not consider compaction feedback design as a "band-aid". There is
no other reliable source of high order pages except for compaction.

> I said same thing again and again and I can't convince you until now.
> I'm not sure what I can do more.

Yes and yet I haven't seen any real life cases where this feedback
mechanism doesn't work from you. You keep claiming that more reclaiming
_might_ be useful without any grounds for that statement. Even when the
more reclaim would help to survive a particular case we have to weigh
pros and cons of the over reclaim and potential trashing which is worse
than an OOM killer sometimes (staring at your machine you can ping but
you cannot even log in...).

Considering that we are in a clear disagreement in the compaction aspect
I think we need others to either back your concern or you show a clear
justification why compaction feedback is not viable way longterm even
after we make further changes which would make it less THP oriented.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
