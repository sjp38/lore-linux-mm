Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5652B6B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 03:33:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so78104102wmu.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:33:22 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id kq1si1843066wjb.150.2016.08.23.00.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 00:33:20 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id o80so180288666wme.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:33:20 -0700 (PDT)
Date: Tue, 23 Aug 2016 09:33:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160823073318.GA23577@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160823045245.GC17039@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823045245.GC17039@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 23-08-16 13:52:45, Joonsoo Kim wrote:
[...]
> Hello, Michal.
> 
> I agree with partial revert but revert should be a different form.
> Below change try to reuse should_compact_retry() version for
> !CONFIG_COMPACTION but it turned out that it also causes regression in
> Markus report [1].

I would argue that CONFIG_COMPACTION=n behaves so arbitrary for high
order workloads that calling any change in that behavior a regression
is little bit exaggerated. Disabling compaction should have a very
strong reason. I haven't heard any so far. I am even wondering whether
there is a legitimate reason for that these days.

> Theoretical reason for this regression is that it would stop retry
> even if there are enough lru pages. It only checks if freepage
> excesses min watermark or not for retry decision. To prevent
> pre-mature OOM killer, we need to keep allocation loop when there are
> enough lru pages. So, logic should be something like that.
> 
> should_compact_retry()
> {
>         for_each_zone_zonelist_nodemask {
>                 available = zone_reclaimable_pages(zone);
>                 available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>                 if (__zone_watermark_ok(zone, *0*, min_wmark_pages(zone),
>                         ac_classzone_idx(ac), alloc_flags, available))
>                         return true;
> 
>         }
> }
> 
> I suggested it before and current situation looks like it is indeed
> needed.

this just opens doors for an unbounded reclaim/threshing becacause
you can reclaim as much as you like and there is no guarantee of a
forward progress. The reason why !COMPACTION should_compact_retry only
checks for the min_wmark without the reclaimable bias is that this will
guarantee a retry if we are failing due to high order wmark check rather
than a lack of memory. This condition is guaranteed to converge and the
probability of the unbounded reclaim is much more reduced.

> And, I still think that your OOM detection rework has some flaws.
>
> 1) It doesn't consider freeable objects that can be freed by shrink_slab().
> There are many subsystems that cache many objects and they will be
> freed by shrink_slab() interface. But, you don't account them when
> making the OOM decision.

I fully rely on the reclaim and compaction feedback. And that is the
place where we should strive for improvements. So if we are growing way
too many slab objects we should take care about that in the slab reclaim
which is tightly coupled with the LRU reclaim rather than up the layer
in the page allocator.
 
> Think about following situation that we are trying to find order-2
> freepage and some subsystem has order-2 freepage. It can be freed by
> shrink_slab(). Your logic doesn't guarantee that shrink_slab() is
> invoked to free this order-2 freepage in that subsystem. OOM would be
> triggered when compaction fails even if there is a order-2 freeable
> page. I think that if decision is made before whole lru list is
> scanned and then shrink_slab() is invoked for whole freeable objects,
> it would cause pre-mature OOM.

I do not see why we would need to scan through the whole LRU list when
we are under a high order pressure. It is true, though, that slab
shrinkers can and should be more sensitive to the requested order to
help release higher order pages preferably.

> It seems that you already knows this issue [2].
> 
> 2) 'OOM detection rework' depends on compaction too much. Compaction
> algorithm is racy and has some limitation. It's failure doesn't mean we
> are in OOM situation.

As long as this is the only reliable source of higher order pages then
we do not have any other choice in order to have deterministic behavior.

> Even if Vlastimil's patchset and mine is
> applied, it is still possible that compaction scanner cannot find enough
> freepage due to race condition and return pre-mature failure. To
> reduce this race effect, I hope to give more chances to retry even if
> full compaction is failed.

Than we can improve compaction_failed() heuristic and do not call it the
end of the day after a single attempt to get a high order page after
scanning the whole memory. But to me this all sounds like an internal
implementation detail of the compaction and the OOM detection in the
page allocator should be as much independent on it as possible - same as
it is independent on the internal reclaim decisions. That was the whole
point of my rework. To actually melt "do something as long as at least a
single page is reclaimed" into an actual algorithm which can be measured
and reason about.

> We can remove this heuristic when we make sure that compaction is
> stable enough.

How do we know that, though, if we do not rely on it? Artificial tests
do not exhibit those corner cases. I was bashing my testing systems to
cause as much fragmentation as possible, yet I wasn't able to trigger
issues reported recently by real world workloads. Do not take me wrong,
I understand your concerns but OOM detection will never be perfect. We
can easily get to one or other extremes. We should strive to make it
work in most workloads. So far it seems that there were no regressions
for order-0 pressure and we can improve compaction to cover higher
orders. I am willing to reconsider this after we hit a cliff where we
cannot do much more in the compaction proper and still hit pre-mature
oom killer invocations in not-so-insane workloads, though.

I believe that Vlastimil's patches show the path to go longterm. Get rid
of the latency heuristics for allocations where that matters in the
first step. Then try to squeeze as much for reliability for !costly
orders as possible.

I also believe that these issues will be less of the problem once we
switch to vmalloc stacks because this is the primary source of high
order allocations these days. Most others are more an optimization than
a reliability thing.

> As you know, I said these things several times but isn't accepted.
> Please consider them more deeply at this time.
> 
> Thanks.
> 
> [1] http://lkml.kernel.org/r/20160731051121.GB307@x4
> [2] https://bugzilla.opensuse.org/show_bug.cgi?id=994066
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
