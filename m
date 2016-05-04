Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 99AA56B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 05:04:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so43099796wme.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 02:04:51 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id hn10si3646855wjc.65.2016.05.04.02.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 02:04:50 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so9065642wmn.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 02:04:49 -0700 (PDT)
Date: Wed, 4 May 2016 11:04:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 14/14] mm, oom, compaction: prevent from
 should_compact_retry looping for ever for costly orders
Message-ID: <20160504090448.GF29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-15-git-send-email-mhocko@kernel.org>
 <20160504062748.GC10899@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504062748.GC10899@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-16 15:27:48, Joonsoo Kim wrote:
> On Wed, Apr 20, 2016 at 03:47:27PM -0400, Michal Hocko wrote:
[...]
> > +bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> > +		int alloc_flags)
> > +{
> > +	struct zone *zone;
> > +	struct zoneref *z;
> > +
> > +	/*
> > +	 * Make sure at least one zone would pass __compaction_suitable if we continue
> > +	 * retrying the reclaim.
> > +	 */
> > +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> > +					ac->nodemask) {
> > +		unsigned long available;
> > +		enum compact_result compact_result;
> > +
> > +		/*
> > +		 * Do not consider all the reclaimable memory because we do not
> > +		 * want to trash just for a single high order allocation which
> > +		 * is even not guaranteed to appear even if __compaction_suitable
> > +		 * is happy about the watermark check.
> > +		 */
> > +		available = zone_reclaimable_pages(zone) / order;
> 
> I can't understand why '/ order' is needed here. Think about specific
> example.
> 
> zone_reclaimable_pages = 100 MB
> NR_FREE_PAGES = 20 MB
> watermark = 40 MB
> order = 10
> 
> I think that compaction should run in this situation and your logic
> doesn't. We should be conservative when guessing not to do something
> prematurely.

I do not mind changing this. But pushing really hard on reclaim for
order-10 pages doesn't sound like a good idea. So we should somehow
reduce the target. I am open for any better suggestions.

> > +		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> > +		compact_result = __compaction_suitable(zone, order, alloc_flags,
> > +				ac->classzone_idx, available);
> 
> It misses tracepoint in compaction_suitable().

Why do you think the check would be useful. I have considered it more
confusing than halpful to I have intentionally not added it.

> 
> > +		if (compact_result != COMPACT_SKIPPED &&
> > +				compact_result != COMPACT_NOT_SUITABLE_ZONE)
> 
> It's undesirable to use COMPACT_NOT_SUITABLE_ZONE here. It is just for
> detailed tracepoint output.

Well this is a compaction code so I considered it acceptable. If you
consider it a big deal I can extract a wrapper and hide this detail.

[...]

> > @@ -3040,9 +3040,11 @@ should_compact_retry(unsigned int order, enum compact_result compact_result,
> >  	/*
> >  	 * make sure the compaction wasn't deferred or didn't bail out early
> >  	 * due to locks contention before we declare that we should give up.
> > +	 * But do not retry if the given zonelist is not suitable for
> > +	 * compaction.
> >  	 */
> >  	if (compaction_withdrawn(compact_result))
> > -		return true;
> > +		return compaction_zonelist_suitable(ac, order, alloc_flags);
> 
> I think that compaction_zonelist_suitable() should be checked first.
> If compaction_zonelist_suitable() returns false, it's useless to
> retry since it means that compaction cannot run if all reclaimable
> pages are reclaimed. Logic should be as following.
> 
> if (!compaction_zonelist_suitable())
>         return false;
> 
> if (compaction_withdrawn())
>         return true;

That is certainly an option as well. The logic above is that I really
wanted to have a terminal condition when compaction can return
compaction_withdrawn for ever basically. Normally we are bound by a
number of successful reclaim rounds. Before we go an change there I
would like to see where it makes real change though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
