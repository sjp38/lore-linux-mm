Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85E156B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 14:16:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so49066276lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 11:16:12 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e18si6471259wjx.104.2016.05.04.11.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 11:16:10 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so12232291wme.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 11:16:10 -0700 (PDT)
Date: Wed, 4 May 2016 20:16:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160504181608.GA21490@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <20160504084737.GB29978@dhcp22.suse.cz>
 <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-16 23:32:31, Joonsoo Kim wrote:
> 2016-05-04 17:47 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 04-05-16 14:45:02, Joonsoo Kim wrote:
> >> On Wed, Apr 20, 2016 at 03:47:13PM -0400, Michal Hocko wrote:
> >> > Hi,
> >> >
> >> > This is v6 of the series. The previous version was posted [1]. The
> >> > code hasn't changed much since then. I have found one old standing
> >> > bug (patch 1) which just got much more severe and visible with this
> >> > series. Other than that I have reorganized the series and put the
> >> > compaction feedback abstraction to the front just in case we find out
> >> > that parts of the series would have to be reverted later on for some
> >> > reason. The premature oom killer invocation reported by Hugh [2] seems
> >> > to be addressed.
> >> >
> >> > We have discussed this series at LSF/MM summit in Raleigh and there
> >> > didn't seem to be any concerns/objections to go on with the patch set
> >> > and target it for the next merge window.
> >>
> >> I still don't agree with some part of this patchset that deal with
> >> !costly order. As you know, there was two regression reports from Hugh
> >> and Aaron and you fixed them by ensuring to trigger compaction. I
> >> think that these show the problem of this patchset. Previous kernel
> >> doesn't need to ensure to trigger compaction and just works fine in
> >> any case. Your series make compaction necessary for all. OOM handling
> >> is essential part in MM but compaction isn't. OOM handling should not
> >> depend on compaction. I tested my own benchmark without
> >> CONFIG_COMPACTION and found that premature OOM happens.
> >
> > High order allocations without compaction are basically a lost game. You
> 
> I don't think that order 1 or 2 allocation has a big trouble without compaction.
> They can be made by buddy algorithm that keeps high order freepages
> as long as possible.
> 
> > can wait unbounded amount of time and still have no guarantee of any
> 
> I know that it has no guarantee. But, it doesn't mean that it's better to
> give up early. Since OOM could causes serious problem, if there is
> reclaimable memory, we need to reclaim all of them at least once
> with praying for high order page before triggering OOM. Optimizing
> this situation by incomplete guessing is a dangerous idea.
> 
> > progress. What is the usual reason to disable compaction in the first
> > place?
> 
> I don't disable it. But, who knows who disable compaction? It's been *not*
> a long time that CONFIG_COMPACTION is default enable. Maybe, 3 years?

I would really like to hear about real life usecase before we go and
cripple otherwise deterministic algorithms. It might be very well
possible that those configurations simply do not have problems with high
order allocations because they are too specific.

> > Anyway if this is _really_ a big issue then we can do something like the
> > following to emulate the previous behavior. We are losing the
> > determinism but if you really thing that the !COMPACTION workloads
> > already reconcile with it I can live with that.
> > ---
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2e7e26c5d3ba..f48b9e9b1869 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3319,6 +3319,24 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> >                      enum migrate_mode *migrate_mode,
> >                      int compaction_retries)
> >  {
> > +       struct zone *zone;
> > +       struct zoneref *z;
> > +
> > +       if (order > PAGE_ALLOC_COSTLY_ORDER)
> > +               return false;
> > +
> > +       /*
> > +        * There are setups with compaction disabled which would prefer to loop
> > +        * inside the allocator rather than hit the oom killer prematurely. Let's
> > +        * give them a good hope and keep retrying while the order-0 watermarks
> > +        * are OK.
> > +        */
> > +       for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> > +                                       ac->nodemask) {
> > +               if(zone_watermark_ok(zone, 0, min_wmark_pages(zone),
> > +                                       ac->high_zoneidx, alloc_flags))
> > +                       return true;
> > +       }
> >         return false;
> 
> I hope that this kind of logic is added to should_reclaim_retry() so
> that this logic is
> applied in any setup. should_compact_retry() should not become a fundamental
> criteria to determine OOM. What compaction does can be changed in the future
> and it's undesirable that it's change affects OOM condition greatly.

I disagree. High order allocations relying on the reclaim is a bad idea
because there is no guarantee that reclaiming more memory leads to the
success. This is the whole idea of the oom detection rework. So the
whole point of should_reclaim_retry is to get over watermarks while
should_compact_retry is about retrying when high order allocations might
make a progress. I really hate to tweak this for a configuration which
relies on the pure luck. So if we really need to do something
undeterministic then !COMPACTION should_compact_retry is the place where
it should be done.

If you are able to reproduce pre mature OOMs with !COMPACTION then I
would really appreciate if you could test with this patch so that I can
prepare a full patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
