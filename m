Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB7186B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 04:13:17 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id he1so133735084pac.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:13:17 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 76si3272959pfl.272.2016.06.30.01.13.16
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 01:13:16 -0700 (PDT)
Date: Thu, 30 Jun 2016 17:16:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm, compaction: make sure freeing scanner isn't
 persistently expensive
Message-ID: <20160630081618.GD30114@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.10.1606281839050.101842@chino.kir.corp.google.com>
 <6685fe19-753d-7d76-aced-3bb071d7c81d@suse.cz>
 <alpine.DEB.2.10.1606291349320.145590@chino.kir.corp.google.com>
 <20160630073158.GA30114@js1304-P5Q-DELUXE>
 <843e8168-024e-267b-0c6f-45dd596923ad@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <843e8168-024e-267b-0c6f-45dd596923ad@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 30, 2016 at 09:42:36AM +0200, Vlastimil Babka wrote:
> On 06/30/2016 09:31 AM, Joonsoo Kim wrote:
> >On Wed, Jun 29, 2016 at 01:55:55PM -0700, David Rientjes wrote:
> >>On Wed, 29 Jun 2016, Vlastimil Babka wrote:
> >>
> >>>On 06/29/2016 03:39 AM, David Rientjes wrote:
> >>>>It's possible that the freeing scanner can be consistently expensive if
> >>>>memory is well compacted toward the end of the zone with few free pages
> >>>>available in that area.
> >>>>
> >>>>If all zone memory is synchronously compacted, say with
> >>>>/proc/sys/vm/compact_memory, and thp is faulted, it is possible to
> >>>>iterate a massive amount of memory even with the per-zone cached free
> >>>>position.
> >>>>
> >>>>For example, after compacting all memory and faulting thp for heap, it
> >>>>was observed that compact_free_scanned increased as much as 892518911 4KB
> >>>>pages while compact_stall only increased by 171.  The freeing scanner
> >>>>iterated ~20GB of memory for each compaction stall.
> >>>>
> >>>>To address this, if too much memory is spanned on the freeing scanner's
> >>>>freelist when releasing back to the system, return the low pfn rather than
> >>>>the high pfn.  It's declared that the freeing scanner will become too
> >>>>expensive if the high pfn is used, so use the low pfn instead.
> >>>>
> >>>>The amount of memory declared as too expensive to iterate is subjectively
> >>>>chosen at COMPACT_CLUSTER_MAX << PAGE_SHIFT, which is 512MB with 4KB
> >>>>pages.
> >>>>
> >>>>Signed-off-by: David Rientjes <rientjes@google.com>
> >>>
> >>>Hmm, I don't know. Seems it only works around one corner case of a larger
> >>>issue. The cost for the scanning was already paid, the patch prevents it from
> >>>being paid again, but only until the scanners are reset.
> >>>
> >>
> >>The only point of the per-zone cached pfn positions is to avoid doing the
> >>same work again unnecessarily.  Having the last 16GB of memory at the end
> >>of a zone being completely unfree is the same as a single page in the last
> >>pageblock free.  The number of PageBuddy pages in that amount of memory
> >>can be irrelevant up to COMPACT_CLUSTER_MAX.  We simply can't afford to
> >>scan 16GB of memory looking for free pages.
> >
> >We need to find a root cause of this problem, first.
> >
> >I guess that this problem would happen when isolate_freepages_block()
> >early stop due to watermark check (if your patch is applied to your
> >kernel). If scanner meets, cached pfn will be reset and your patch
> >doesn't have any effect. So, I guess that scanner doesn't meet.
> >
> >We enter the compaction with enough free memory so stop in
> >isolate_freepages_block() should be unlikely event but your number
> >shows that it happens frequently?
> 
> If it's THP faults, it could be also due to need_resched() or lock
> contention?

Okay. I missed that.

> 
> >Maybe, if we change all watermark check on compaction.c to use
> >min_wmark, problem would be disappeared.
> 
> Basically patches 13 and 16 in https://lkml.org/lkml/2016/6/24/222

Okay. I don't look at it but I like to change to use min_wmark.

> >Anyway, could you check how often isolate_freepages_block() is stopped
> >and why?
> >
> >In addition, I worry that your previous patch that makes
> >isolate_freepages_block() stop when watermark doesn't meet would cause
> >compaction non-progress. Amount of free memory can be flutuated so
> >watermark fail would be temporaral. We need to break compaction in
> >this case? It would decrease compaction success rate if there is a
> >memory hogger in parallel. Any idea?
> 
> I think it's better to stop and possibly switch to reclaim (or give
> up for THP's) than to continue hoping that somebody would free the
> memory for us. As I explained in the other thread, even if we
> removed watermark check completely and migration succeeded and
> formed high-order page, compact_finished() would see failed
> high-order watermark and return COMPACT_CONTINUE, even if the
> problem is actually order-0 watermarks. So maybe success rate would
> be bigger, but at enormous cost. IIRC you even proposed once to add

I understand your point. I'm not insisting to remove watermark check
in split_free_page(). However, my worry still remains. If we use
min_wmark, there would be no problem since memory hogger cannot
easily consume memory below the min_wmark. But, if we use low_wmark,
memory hogger consumes all free memory up to min_wmark repeatedly and
compaction will fail repeatedly. This is the problem about robustness
and correctness of the system so, even if we pay more, we prohibits
such a case. If we once make high order page, it would not be broken
easily so we can get it when next reclaim makes order 0 free memory up
to watermark. But, if we stop to make high order page when watermark
check is failed, we need to run compaction one more time after next
reclaim and there is a chance that memory hogger could consume all
reclaimed free memory.

> order-0 check (maybe even with some gap like compaction_suitable()?)
> to compact_finished() that would terminate compaction. Which
> shouldn't be necessary if we terminate due to split_free_page()
> failing.

I can't remember if I did it or not. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
