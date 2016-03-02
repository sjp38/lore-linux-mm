Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3342E6B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 21:54:49 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 124so62887694pfg.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 18:54:49 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 28si8628516pfk.37.2016.03.01.18.54.47
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 18:54:48 -0800 (PST)
Date: Wed, 2 Mar 2016 11:55:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160302025507.GC22355@js1304-P5Q-DELUXE>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
 <56D5DBF0.2020004@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D5DBF0.2020004@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 01, 2016 at 07:14:08PM +0100, Vlastimil Babka wrote:
> On 03/01/2016 02:38 PM, Michal Hocko wrote:
> >$ grep compact /proc/vmstat
> >compact_migrate_scanned 113983
> >compact_free_scanned 1433503
> >compact_isolated 134307
> >compact_stall 128
> >compact_fail 26
> >compact_success 102
> >compact_kcompatd_wake 0
> >
> >So the whole load has done the direct compaction only 128 times during
> >that test. This doesn't sound much to me
> >$ grep allocstall /proc/vmstat
> >allocstall 1061
> >
> >we entered the direct reclaim much more but most of the load will be
> >order-0 so this might be still ok. So I've tried the following:
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 1993894b4219..107d444afdb1 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -2910,6 +2910,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  						mode, contended_compaction);
> >  	current->flags &= ~PF_MEMALLOC;
> >
> >+	if (order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER)
> >+		trace_printk("order:%d gfp_mask:%pGg compact_result:%lu\n", order, &gfp_mask, compact_result);
> >+
> >  	switch (compact_result) {
> >  	case COMPACT_DEFERRED:
> >  		*deferred_compaction = true;
> >
> >And the result was:
> >$ cat /debug/tracing/trace_pipe | tee ~/trace.log
> >              gcc-8707  [001] ....   137.946370: __alloc_pages_direct_compact: order:2 gfp_mask:GFP_KERNEL_ACCOUNT|__GFP_NOTRACK compact_result:1
> >              gcc-8726  [000] ....   138.528571: __alloc_pages_direct_compact: order:2 gfp_mask:GFP_KERNEL_ACCOUNT|__GFP_NOTRACK compact_result:1
> >
> >this shows that order-2 memory pressure is not overly high in my
> >setup. Both attempts ended up COMPACT_SKIPPED which is interesting.
> >
> >So I went back to 800M of hugetlb pages and tried again. It took ages
> >so I have interrupted that after one hour (there was still no OOM). The
> >trace log is quite interesting regardless:
> >$ wc -l ~/trace.log
> >371 /root/trace.log
> >
> >$ grep compact_stall /proc/vmstat
> >compact_stall 190
> >
> >so the compaction was still ignored more than actually invoked for
> >!costly allocations:
> >sed 's@.*order:\([[:digit:]]\).* compact_result:\([[:digit:]]\)@\1 \2@' ~/trace.log | sort | uniq -c
> >     190 2 1
> >     122 2 3
> >      59 2 4
> >
> >#define COMPACT_SKIPPED         1
> >#define COMPACT_PARTIAL         3
> >#define COMPACT_COMPLETE        4
> >
> >that means that compaction is even not tried in half cases! This
> >doesn't sounds right to me, especially when we are talking about
> ><= PAGE_ALLOC_COSTLY_ORDER requests which are implicitly nofail, because
> >then we simply rely on the order-0 reclaim to automagically form higher
> >blocks. This might indeed work when we retry many times but I guess this
> >is not a good approach. It leads to a excessive reclaim and the stall
> >for allocation can be really large.
> >
> >One of the suspicious places is __compaction_suitable which does order-0
> >watermark check (increased by 2<<order). I have put another trace_printk
> >there and it clearly pointed out this was the case.
> 
> Yes, compaction is historically quite careful to avoid making low
> memory conditions worse, and to prevent work if it doesn't look like
> it can ultimately succeed the allocation (so having not enough base
> pages means that compacting them is considered pointless). This
> aspect of preventing non-zero-order OOMs is somewhat unexpected :)

It's better not to assume that compaction would succeed all the times.
Compaction has some limitations so it sometimes fails.
For example, in lowmem situation, it only scans small parts of memory
and if that part is fragmented by non-movable page, compaction would fail.
And, compaction would defer requests 64 times at maximum if successive
compaction failure happens before.

Depending on compaction heavily is right direction to go but I think
that it's not ready for now. More reclaim would relieve problem.

I tried to fix this situation but not yet finished.

http://thread.gmane.org/gmane.linux.kernel.mm/142364
https://lkml.org/lkml/2015/8/23/182


> >So I have tried the following:
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index 4d99e1f5055c..7364e48cf69a 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -1276,6 +1276,9 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
> >  								alloc_flags))
> >  		return COMPACT_PARTIAL;
> >
> >+	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> >+		return COMPACT_CONTINUE;
> >+
> >  	/*
> >  	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
> >  	 * This is because during migration, copies of pages need to be
> >
> >and retried the same test (without huge pages):
> >$ time make -j20 > /dev/null
> >
> >real    8m46.626s
> >user    14m15.823s
> >sys     2m45.471s
> >
> >the time increased but I haven't checked how stable the result is.
> >
> >$ grep compact /proc/vmstat
> >compact_migrate_scanned 139822
> >compact_free_scanned 1661642
> >compact_isolated 139407
> >compact_stall 129
> >compact_fail 58
> >compact_success 71
> >compact_kcompatd_wake 1
> >
> >$ grep allocstall /proc/vmstat
> >allocstall 1665
> >
> >this is worse because we have scanned more pages for migration but the
> >overall success rate was much smaller and the direct reclaim was invoked
> >more. I do not have a good theory for that and will play with this some
> >more. Maybe other changes are needed deeper in the compaction code.
> 
> I was under impression that similar checks to compaction_suitable()
> were done also in compact_finished(), to stop compacting if memory
> got low due to parallel activity. But I guess it was a patch from
> Joonsoo that didn't get merged.
> 
> My only other theory so far is that watermark checks fail in
> __isolate_free_page() when we want to grab page(s) as migration
> targets. I would suggest enabling all compaction tracepoint and the
> migration tracepoint. Looking at the trace could hopefully help
> faster than going one trace_printk() per attempt.

Agreed. It's best thing to do now.

Thanks.

> 
> Once we learn all the relevant places/checks, we can think about how
> to communicate to them that this compaction attempt is "important"
> and should continue as long as possible even in low-memory
> conditions. Maybe not just a costly order check, but we also have
> alloc_flags or could add something to compact_control, etc.
> 
> >I will play with this some more but I would be really interested to hear
> >whether this helped Hugh with his setup. Vlastimi, Joonsoo does this
> >even make sense to you?
> >
> >>I was only suggesting to allocate hugetlb pages, if you preferred
> >>not to reboot with artificially reduced RAM.  Not an issue if you're
> >>booting VMs.
> >
> >Ohh, I see.
> >
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
