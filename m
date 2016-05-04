Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0B16B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 15:22:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m64so50564144lfd.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:22:57 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v195si7059479wmv.63.2016.05.04.12.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 12:22:55 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so12526725wmw.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:22:55 -0700 (PDT)
Date: Wed, 4 May 2016 21:22:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 14/14] mm, oom, compaction: prevent from
 should_compact_retry looping for ever for costly orders
Message-ID: <20160504192254.GD21490@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-15-git-send-email-mhocko@kernel.org>
 <20160504062748.GC10899@js1304-P5Q-DELUXE>
 <20160504090448.GF29978@dhcp22.suse.cz>
 <CAAmzW4Ohnhrx1RkAFywwQyLW1b1NiHhB9AkvVCp8NVC9vyevtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4Ohnhrx1RkAFywwQyLW1b1NiHhB9AkvVCp8NVC9vyevtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 05-05-16 00:14:51, Joonsoo Kim wrote:
> 2016-05-04 18:04 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 04-05-16 15:27:48, Joonsoo Kim wrote:
> >> On Wed, Apr 20, 2016 at 03:47:27PM -0400, Michal Hocko wrote:
> > [...]
> >> > +bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> >> > +           int alloc_flags)
> >> > +{
> >> > +   struct zone *zone;
> >> > +   struct zoneref *z;
> >> > +
> >> > +   /*
> >> > +    * Make sure at least one zone would pass __compaction_suitable if we continue
> >> > +    * retrying the reclaim.
> >> > +    */
> >> > +   for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> >> > +                                   ac->nodemask) {
> >> > +           unsigned long available;
> >> > +           enum compact_result compact_result;
> >> > +
> >> > +           /*
> >> > +            * Do not consider all the reclaimable memory because we do not
> >> > +            * want to trash just for a single high order allocation which
> >> > +            * is even not guaranteed to appear even if __compaction_suitable
> >> > +            * is happy about the watermark check.
> >> > +            */
> >> > +           available = zone_reclaimable_pages(zone) / order;
> >>
> >> I can't understand why '/ order' is needed here. Think about specific
> >> example.
> >>
> >> zone_reclaimable_pages = 100 MB
> >> NR_FREE_PAGES = 20 MB
> >> watermark = 40 MB
> >> order = 10
> >>
> >> I think that compaction should run in this situation and your logic
> >> doesn't. We should be conservative when guessing not to do something
> >> prematurely.
> >
> > I do not mind changing this. But pushing really hard on reclaim for
> > order-10 pages doesn't sound like a good idea. So we should somehow
> > reduce the target. I am open for any better suggestions.
> 
> If the situation is changed to order-2, it doesn't look good, either.

Why not? If we are not able to get over compaction_suitable watermark
check after we consider half of the reclaimable memory then we are really
close to oom. This will trigger only when the reclaimable LRUs are
really _tiny_. We are (very roughly) talking about:
low_wmark + 2<<order >= NR_FREE_PAGES + reclaimable/order - 1<<order
where low_wmark would be close to NR_FREE_PAGES so in the end we are asking
for order * 3<<order >= reclaimable and that sounds quite conservative
to me. Originally I wanted much more aggressive back off.

> I think that some reduction on zone_reclaimable_page() are needed since
> it's not possible to free all of them in certain case. But, reduction by order
> doesn't make any sense. if we need to consider order to guess probability of
> compaction, it should be considered in __compaction_suitable() instead of
> reduction from here.

I do agree that a more clever algorithm would be better and I also agree
that __compaction_suitable would be a better place for such a better
algorithm. I just wanted to have something simple first and more as a
safety net to stop endless retries (this has proven to work before I
found the real culprit compaction_ready patch). A more rigorous approach
would require a much deeper analysis what the actual compaction capacity
of the reclaimable memory really is. This is a quite hard problem and I
am not really convinced it is really needed.

> I think that following code that is used in should_reclaim_retry() would be
> good for here.
> 
> available -= DIV_ROUND_UP(no_progress_loops * available, MAX_RECLAIM_RETRIES)
> 
> Any thought?

I would prefer not to mix reclaim retry logic in here. Moreover it can
be argued that this is a kind of arbitrary as well because it has no
relevance to the compaction capacity of the reclaimable memory. If I
have to chose then I would rather go with simpler calculation than
something that is complex and we are even not sure it works any better.

> >> > +           available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> >> > +           compact_result = __compaction_suitable(zone, order, alloc_flags,
> >> > +                           ac->classzone_idx, available);
> >>
> >> It misses tracepoint in compaction_suitable().
> >
> > Why do you think the check would be useful. I have considered it more
> > confusing than halpful to I have intentionally not added it.
> 
> What confusing do you have in mind?
> If we try to analyze OOM, we need to know why should_compact_retry()
> return false and and tracepoint here could be helpful.

Because then you can easily confuse compaction_suitable from the
compaction decisions and the allocation retries. This code patch
definitely deserves a specific trace point and I plan to prepare one
along with others in the allocation path.

[...]
> >> > @@ -3040,9 +3040,11 @@ should_compact_retry(unsigned int order, enum compact_result compact_result,
> >> >     /*
> >> >      * make sure the compaction wasn't deferred or didn't bail out early
> >> >      * due to locks contention before we declare that we should give up.
> >> > +    * But do not retry if the given zonelist is not suitable for
> >> > +    * compaction.
> >> >      */
> >> >     if (compaction_withdrawn(compact_result))
> >> > -           return true;
> >> > +           return compaction_zonelist_suitable(ac, order, alloc_flags);
> >>
> >> I think that compaction_zonelist_suitable() should be checked first.
> >> If compaction_zonelist_suitable() returns false, it's useless to
> >> retry since it means that compaction cannot run if all reclaimable
> >> pages are reclaimed. Logic should be as following.
> >>
> >> if (!compaction_zonelist_suitable())
> >>         return false;
> >>
> >> if (compaction_withdrawn())
> >>         return true;
> >
> > That is certainly an option as well. The logic above is that I really
> > wanted to have a terminal condition when compaction can return
> > compaction_withdrawn for ever basically. Normally we are bound by a
> > number of successful reclaim rounds. Before we go an change there I
> > would like to see where it makes real change though.
> 
> It would not make real change because !compaction_withdrawn() and
> !compaction_zonelist_suitable() case doesn't happen easily.
> 
> But, change makes code more understandable so it's worth doing, IMO.

I dunno. I might be really biased here but I consider the current
ordering more appropriate for the reasons described above. Act as a
terminal condition for potentially endless compaction_withdrawn() rather
than a terminal condition on its own. Anyway I am not really sure this
is something crucial or do you consider this particular part really
important? I would prefer to not sneak last minute changes before the
upcoming merge windown just for readability which is even non-trivial.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
