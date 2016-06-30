Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3064D6B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 03:28:58 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f6so144560164ith.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 00:28:58 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 18si3290224ios.147.2016.06.30.00.28.56
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 00:28:57 -0700 (PDT)
Date: Thu, 30 Jun 2016 16:31:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm, compaction: make sure freeing scanner isn't
 persistently expensive
Message-ID: <20160630073158.GA30114@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.10.1606281839050.101842@chino.kir.corp.google.com>
 <6685fe19-753d-7d76-aced-3bb071d7c81d@suse.cz>
 <alpine.DEB.2.10.1606291349320.145590@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1606291349320.145590@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 29, 2016 at 01:55:55PM -0700, David Rientjes wrote:
> On Wed, 29 Jun 2016, Vlastimil Babka wrote:
> 
> > On 06/29/2016 03:39 AM, David Rientjes wrote:
> > > It's possible that the freeing scanner can be consistently expensive if
> > > memory is well compacted toward the end of the zone with few free pages
> > > available in that area.
> > > 
> > > If all zone memory is synchronously compacted, say with
> > > /proc/sys/vm/compact_memory, and thp is faulted, it is possible to
> > > iterate a massive amount of memory even with the per-zone cached free
> > > position.
> > > 
> > > For example, after compacting all memory and faulting thp for heap, it
> > > was observed that compact_free_scanned increased as much as 892518911 4KB
> > > pages while compact_stall only increased by 171.  The freeing scanner
> > > iterated ~20GB of memory for each compaction stall.
> > > 
> > > To address this, if too much memory is spanned on the freeing scanner's
> > > freelist when releasing back to the system, return the low pfn rather than
> > > the high pfn.  It's declared that the freeing scanner will become too
> > > expensive if the high pfn is used, so use the low pfn instead.
> > > 
> > > The amount of memory declared as too expensive to iterate is subjectively
> > > chosen at COMPACT_CLUSTER_MAX << PAGE_SHIFT, which is 512MB with 4KB
> > > pages.
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > Hmm, I don't know. Seems it only works around one corner case of a larger
> > issue. The cost for the scanning was already paid, the patch prevents it from
> > being paid again, but only until the scanners are reset.
> > 
> 
> The only point of the per-zone cached pfn positions is to avoid doing the 
> same work again unnecessarily.  Having the last 16GB of memory at the end 
> of a zone being completely unfree is the same as a single page in the last 
> pageblock free.  The number of PageBuddy pages in that amount of memory 
> can be irrelevant up to COMPACT_CLUSTER_MAX.  We simply can't afford to 
> scan 16GB of memory looking for free pages.

We need to find a root cause of this problem, first.

I guess that this problem would happen when isolate_freepages_block()
early stop due to watermark check (if your patch is applied to your
kernel). If scanner meets, cached pfn will be reset and your patch
doesn't have any effect. So, I guess that scanner doesn't meet.

We enter the compaction with enough free memory so stop in
isolate_freepages_block() should be unlikely event but your number
shows that it happens frequently?

Maybe, if we change all watermark check on compaction.c to use
min_wmark, problem would be disappeared.

Anyway, could you check how often isolate_freepages_block() is stopped
and why?

In addition, I worry that your previous patch that makes
isolate_freepages_block() stop when watermark doesn't meet would cause
compaction non-progress. Amount of free memory can be flutuated so
watermark fail would be temporaral. We need to break compaction in
this case? It would decrease compaction success rate if there is a
memory hogger in parallel. Any idea?

Thanks.

> 
> > Note also that THP's no longer do direct compaction by default in recent
> > kernels.
> > 
> > To fully solve the freepage scanning issue, we should probably pick and finish
> > one of the proposed reworks from Joonsoo or myself, or the approach that
> > replaces free scanner with direct freelist allocations.
> > 
> 
> Feel free to post the patches, but I believe this simple change makes 
> release_freepages() exceedingly better and can better target memory for 
> the freeing scanner.
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
