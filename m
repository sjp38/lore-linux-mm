Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 240FC6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 02:39:58 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vd14so14665357pab.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 23:39:58 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id qy6si8043697pab.154.2016.08.23.23.34.06
        for <linux-mm@kvack.org>;
        Tue, 23 Aug 2016 23:34:13 -0700 (PDT)
Date: Wed, 24 Aug 2016 14:01:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160824050157.GA22781@js1304-P5Q-DELUXE>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160823045245.GC17039@js1304-P5Q-DELUXE>
 <20160823073318.GA23577@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823073318.GA23577@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Looks like my mail client eat my reply so I resend.

On Tue, Aug 23, 2016 at 09:33:18AM +0200, Michal Hocko wrote:
> On Tue 23-08-16 13:52:45, Joonsoo Kim wrote:
> [...]
> > Hello, Michal.
> > 
> > I agree with partial revert but revert should be a different form.
> > Below change try to reuse should_compact_retry() version for
> > !CONFIG_COMPACTION but it turned out that it also causes regression in
> > Markus report [1].
> 
> I would argue that CONFIG_COMPACTION=n behaves so arbitrary for high
> order workloads that calling any change in that behavior a regression
> is little bit exaggerated. Disabling compaction should have a very
> strong reason. I haven't heard any so far. I am even wondering whether
> there is a legitimate reason for that these days.
> 
> > Theoretical reason for this regression is that it would stop retry
> > even if there are enough lru pages. It only checks if freepage
> > excesses min watermark or not for retry decision. To prevent
> > pre-mature OOM killer, we need to keep allocation loop when there are
> > enough lru pages. So, logic should be something like that.
> > 
> > should_compact_retry()
> > {
> >         for_each_zone_zonelist_nodemask {
> >                 available = zone_reclaimable_pages(zone);
> >                 available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> >                 if (__zone_watermark_ok(zone, *0*, min_wmark_pages(zone),
> >                         ac_classzone_idx(ac), alloc_flags, available))
> >                         return true;
> > 
> >         }
> > }
> > 
> > I suggested it before and current situation looks like it is indeed
> > needed.
> 
> this just opens doors for an unbounded reclaim/threshing becacause
> you can reclaim as much as you like and there is no guarantee of a
> forward progress. The reason why !COMPACTION should_compact_retry only
> checks for the min_wmark without the reclaimable bias is that this will
> guarantee a retry if we are failing due to high order wmark check rather
> than a lack of memory. This condition is guaranteed to converge and the
> probability of the unbounded reclaim is much more reduced.

In case of a lack of memory with a lot of reclaimable lru pages, why 
do we stop reclaim/compaction?

With your partial reverting patch, allocation logic would be like as
following.

Assume following situation:
o a lot of reclaimable lru pages
o no order-2 freepage
o not enough order-0 freepage for min watermark
o order-2 allocation

1. order-2 allocation failed due to min watermark
2. go to reclaim/compaction
3. reclaim some pages (maybe SWAP_CLUSTER_MAX (32) pages) but still
min watermark isn't met for order-0
4. compaction is skipped due to not enough freepage
5. should_reclaim_retry() returns false because min watermark for
order-2 page isn't met
6. should_compact_retry() returns false because min watermark for
order-0 page isn't met
6. allocation is failed without any retry and OOM is invoked.

Is it what you want?

And, please elaborate more on how your logic guarantee to converge.
After order-0 freepage exceed min watermark, there is no way to stop
reclaim/threshing. Number of freepage just increase monotonically and
retry cannot be stopped until order-2 allocation succeed. Am I missing
something?


> > And, I still think that your OOM detection rework has some flaws.
> >
> > 1) It doesn't consider freeable objects that can be freed by shrink_slab().
> > There are many subsystems that cache many objects and they will be
> > freed by shrink_slab() interface. But, you don't account them when
> > making the OOM decision.
> 
> I fully rely on the reclaim and compaction feedback. And that is the
> place where we should strive for improvements. So if we are growing way
> too many slab objects we should take care about that in the slab reclaim
> which is tightly coupled with the LRU reclaim rather than up the layer
> in the page allocator.

No. slab shrink logic which is tightly coupled with the LRU reclaim
totally makes sense. What doesn't makes sense is the way of using
these functionality and utilizing these freebacks on your OOM
detection rework.

For example, compaction will do it's best with current resource. But,
as I said before, compaction will be more powerful if the system has
more free memory. Your logic just guarantee to give it to minimum
amount of free memory to run so I don't think it's result is
reliable to determine if we are in OOM or not.

And, your logic doesn't consider how many pages can be freed by slab
shrink. As I said before, there would exist high order reclaimable
page or we can make high order freepage by actual free.

Most importantly, I think that it is fundamentally impossible to
anticipate if we can make high order freepage or not by snapshot of
information about number of freeable page. So, your logic rely on
compaction but there are many types of pages that cannot be migrated
by compaction but can be reclaimed. So, fully relying on compaction
result for OOM decision would cause the problem.

I know that there is a trade-off. But, your logic makes me worry that
we lose too much accuracy for deterministic behaviour.

>  
> > Think about following situation that we are trying to find order-2
> > freepage and some subsystem has order-2 freepage. It can be freed by
> > shrink_slab(). Your logic doesn't guarantee that shrink_slab() is
> > invoked to free this order-2 freepage in that subsystem. OOM would be
> > triggered when compaction fails even if there is a order-2 freeable
> > page. I think that if decision is made before whole lru list is
> > scanned and then shrink_slab() is invoked for whole freeable objects,
> > it would cause pre-mature OOM.
> 
> I do not see why we would need to scan through the whole LRU list when
> we are under a high order pressure. It is true, though, that slab
> shrinkers can and should be more sensitive to the requested order to
> help release higher order pages preferably.
> 
> > It seems that you already knows this issue [2].
> > 
> > 2) 'OOM detection rework' depends on compaction too much. Compaction
> > algorithm is racy and has some limitation. It's failure doesn't mean we
> > are in OOM situation.
> 
> As long as this is the only reliable source of higher order pages then
> we do not have any other choice in order to have deterministic behavior.
> 
> > Even if Vlastimil's patchset and mine is
> > applied, it is still possible that compaction scanner cannot find enough
> > freepage due to race condition and return pre-mature failure. To
> > reduce this race effect, I hope to give more chances to retry even if
> > full compaction is failed.
> 
> Than we can improve compaction_failed() heuristic and do not call it the
> end of the day after a single attempt to get a high order page after
> scanning the whole memory. But to me this all sounds like an internal
> implementation detail of the compaction and the OOM detection in the
> page allocator should be as much independent on it as possible - same as
> it is independent on the internal reclaim decisions. That was the whole
> point of my rework. To actually melt "do something as long as at least a
> single page is reclaimed" into an actual algorithm which can be measured
> and reason about.

As you said before, your logic cannot be independent of these
feedbacks.

 "I fully rely on the reclaim and compaction feedback"

Your logic need to consider implementation details.

> 
> > We can remove this heuristic when we make sure that compaction is
> > stable enough.
> 
> How do we know that, though, if we do not rely on it? Artificial tests
> do not exhibit those corner cases. I was bashing my testing systems to
> cause as much fragmentation as possible, yet I wasn't able to trigger
> issues reported recently by real world workloads. Do not take me wrong,
> I understand your concerns but OOM detection will never be perfect. We
> can easily get to one or other extremes. We should strive to make it
> work in most workloads. So far it seems that there were no regressions
> for order-0 pressure and we can improve compaction to cover higher
> orders. I am willing to reconsider this after we hit a cliff where we

As I said before, I fully agree that your work will work well for
order-0 pressure.

> cannot do much more in the compaction proper and still hit pre-mature
> oom killer invocations in not-so-insane workloads, though.

If you understand my concners, it would be better to prevent the known
possible problem in advance? You cannot know whole real workload in
the world. Your logic has some limitations at least theoretically and
cause a lot of regressions already. Why do you continue to insist
"let's see other report by real workload?" Bug report can be reported
long time later and it would be not appropriate time to fix the issue.

> 
> I believe that Vlastimil's patches show the path to go longterm. Get rid
> of the latency heuristics for allocations where that matters in the
> first step. Then try to squeeze as much for reliability for !costly
> orders as possible.
> 
> I also believe that these issues will be less of the problem once we
> switch to vmalloc stacks because this is the primary source of high
> order allocations these days. Most others are more an optimization than
> a reliability thing.

Even if vmalloc stacks patches are applied, there are other
core cases. For example, ARM uses order-2 allocation for page table
allocation(pgd). It is just one allocation per process rather per
thread so less aggressive but it caused the problem before in our system.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
