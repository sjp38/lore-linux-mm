Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0B16B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:57:49 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id s10so49414618itb.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 22:57:49 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g188si11797316pfc.136.2017.01.12.22.57.47
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 22:57:48 -0800 (PST)
Date: Fri, 13 Jan 2017 16:03:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [LSF/MM TOPIC] wmark based pro-active compaction
Message-ID: <20170113070331.GA7874@js1304-P5Q-DELUXE>
References: <20161230131412.GI13301@dhcp22.suse.cz>
 <20161230140651.nud2ozpmvmziqyx4@suse.de>
 <cde489a7-4c08-f5ba-e6e8-07d8537bc7d8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cde489a7-4c08-f5ba-e6e8-07d8537bc7d8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

I'm also interested in this topic.

lkml.kernel.org/r/1430119421-13536-3-git-send-email-iamjoonsoo.kim@lge.com

On Thu, Jan 05, 2017 at 10:53:59AM +0100, Vlastimil Babka wrote:
> [CC Joonsoo and Johannes]
> 
> On 12/30/2016 03:06 PM, Mel Gorman wrote:
> > On Fri, Dec 30, 2016 at 02:14:12PM +0100, Michal Hocko wrote:
> >> Hi,
> >> I didn't originally want to send this proposal because Vlastimil is
> >> planning to do some work in this area so I've expected him to send
> >> something similar. But the recent discussion about the THP defrag
> >> options pushed me to send out my thoughts.
> 
> No problem.
> 
> >> So what is the problem? The demand for high order pages is growing and
> >> that seems to be the general trend. The problem is that while they can
> >> bring performance benefit they can get be really expensive to allocate
> >> especially when we enter the direct compaction. So we really want to
> >> prevent from expensive path and defer as much as possible to the
> >> background. A huge step forward was kcompactd introduced by Vlastimil.
> >> We are still not there yet though, because it might be already quite
> >> late when we wakeup_kcompactd(). The memory might be already fragmented
> >> when we hit there.
> 
> Right.

Before we talk about pro-active compaction, I'd like to know the
usecase that really needs pro-active compaction. For THP, IMHO, it's
better not to do pro-active compaction, because high-order page made
by pro-active compaction could be broken before it is used. And,
THP page can be setup lately by THP daemon. Benefit of pro-active
compaction would not compensate overhead of it in this case. I guess
that almost cases that have a fallback would hit this category.

For the order lower than costly order, system would have such a
freepage usually. So, my question is pro-active compaction is really
needed even if it's cost is really high? Reason I ask this question is
that I tested some patches to do pro-active compaction and found that
cost looks too much high. I heard that someone want this feature but
I'm not sure they will use it with this high cost. Anyway, I will post
some patches for pro-active compaction, soon.

> 
> >> Moreover we do not have any way to actually tell
> >> which orders we do care about.
> 
> Who is "we" here? The system admin?
> 
> >> Therefore I believe we need a watermark based pro-active compaction
> >> which would keep the background compaction busy as long as we have
> >> less pages of the configured order.
> 
> Again, configured by what, admin? I would rather try to avoid tunables
> here, if possible. While THP is quite well known example with stable
> order, the pressure for other orders is rather implementation specific
> (drivers, SLAB/SLUB) and may change with kernel versions (e.g. virtually
> mapped stacks, although that example is about non-costly order). Would
> the admin be expected to study the implementation to know which orders
> are needed, or react to page allocation failure reports? Neither sounds
> nice.

It would be really good if we can auto tune this. My patches mentioned
above just use tunables that you don't like. :)

> >> kcompactd should wake up
> >> periodically, I think, and check for the status so that we can catch
> >> the fragmentation before we get low on memory.
> >> The interface could look something like:
> >> /proc/sys/vm/compact_wmark
> >> time_period order count
> 
> IMHO it would be better if the system could auto-tune this, e.g. by
> counting high-order alloc failures/needs for direct compaction per order
> between wakeups, and trying to bring them to zero.
> 
> >> There are many details that would have to be solved of course - e.g. do
> >> not burn cycles pointlessly when we know that no further progress can be
> >> made etc... but in principle the idea show work.
> 
> Yeah with auto-tuning there's even more inputs to consider and
> parameters that would be auto-adjusted based on them. Right now I can
> think of:
> 
> Inputs
> - the per-order "pressure" (e.g. the failures/direct compactions above)
>   - ideally somehow including the "importance". That might be the
> trickiest part when wanting to avoid tunables. THP failures might be
> least important, allocations with expensive or no fallback most
> important. Probably not just simple relation between order. Hopefully
> gfp flags such as __GFP_NORETRY and __GFP_REPEAT can help here? Without
> such metric, everything will easily be dominated by THP pressure.
> - recent compaction efficiency (as you mentioned above)
> 
> Parameters
> - wake up period for kcompactd
> - target per-order goals for kcompactd
> - lowest efficiency where it's still considered worth to compact?
> 
> An important question: how to evaluate this? Metrics should be feasible
> (improved success rate, % of compaction that was handled by kcompactd
> and not direct compaction...), but what are the good testcases?

Usecase should be defined first? Anyway, I hope that new testcase would
be finished in short time. stress-highalloc test takes too much time
to test various ideas.

> > I'd be very interested in this. I'd also like to add to the list to revisit
> > the concept of pre-emptively moving movable pages from pageblocks stolen for
> > unmovable pages to reduce future events that degrade fragmentation. Before
> > the Christmas I was mulling over whether it would be appropriate to have a
> > workqueue of pageblocks that need "cleaning". This could be either instead
> > of or in conjunction with wmark-based compaction.
> 
> Yes, that could be useful as well.

I tried this one, too. :)

lkml.kernel.org/r/1430119421-13536-3-git-send-email-iamjoonsoo.kim@lge.com

My approach is to maintain dedicated thread and it migrates all movable
pages in the pageblock stolen for unmovable allocation to prevent the
future event that unmovable allocation happens in another movable
pageblock. This patches help to prevent it but not perfectly since it
sometimes cannot catch-up allocation speed. With pro-active compaction,
we may prevent it, too.

> 
> Ideally I would also revisit the topic of compaction mechanism (migrate
> and free scanners) itself. It's been shown that they usually meet in the

+1

> 1/3 or 1/2 of zone, which means the rest of the zone is only
> defragmented by "plugging free holes" by migrated pages, although it
> might actually contain pageblocks more suitable for migrating from, than
> the first part of the zone. It's also expensive for the free scanner to
> actually find free pages, according to the stats.

Scalable approach would be [3] since it finds freepage by O(1) unlike
others that are O(N).

> 
> Some approaches were proposed in recent years, but never got far as it's
> always some kind of a trade-off (this partially goes back to the problem
> of evaluation, often limited to stress-highalloc from mmtests):
> 
> - "pivot" based approach where scanners' starting point changes and
> isn't always zone boundaries [1]
> - both scanners scan whole zone moving in the same direction, just
> making sure they don't operate on the same pageblock at the same time [2]
> - replacing free scanner by directly taking free pages from freelist
> 
> However, the problem with this subtopic is that it might be too much
> specialized for the full MM room.

Right. :)

Thanks.

> 
> [1] https://lkml.org/lkml/2015/1/19/158
> [2] https://lkml.org/lkml/2015/6/24/706
> [3] https://lkml.org/lkml/2015/12/3/63

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
