Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2A02F6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:20:32 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so4111233wgg.28
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 05:20:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fn15si17588334wjc.73.2014.07.25.05.20.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 05:20:28 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:20:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V4 02/15] mm, compaction: defer each zone individually
 instead of preferred zone
Message-ID: <20140725122022.GW10819@suse.de>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
 <1405518503-27687-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405518503-27687-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Jul 16, 2014 at 03:48:10PM +0200, Vlastimil Babka wrote:
> When direct sync compaction is often unsuccessful, it may become deferred for
> some time to avoid further useless attempts, both sync and async. Successful
> high-order allocations un-defer compaction, while further unsuccessful
> compaction attempts prolong the copmaction deferred period.
> 
> Currently the checking and setting deferred status is performed only on the
> preferred zone of the allocation that invoked direct compaction. But compaction
> itself is attempted on all eligible zones in the zonelist, so the behavior is
> suboptimal and may lead both to scenarios where 1) compaction is attempted
> uselessly, or 2) where it's not attempted despite good chances of succeeding,
> as shown on the examples below:
> 
> 1) A direct compaction with Normal preferred zone failed and set deferred
>    compaction for the Normal zone. Another unrelated direct compaction with
>    DMA32 as preferred zone will attempt to compact DMA32 zone even though
>    the first compaction attempt also included DMA32 zone.
> 
>    In another scenario, compaction with Normal preferred zone failed to compact
>    Normal zone, but succeeded in the DMA32 zone, so it will not defer
>    compaction. In the next attempt, it will try Normal zone which will fail
>    again, instead of skipping Normal zone and trying DMA32 directly.
> 
> 2) Kswapd will balance DMA32 zone and reset defer status based on watermarks
>    looking good. A direct compaction with preferred Normal zone will skip
>    compaction of all zones including DMA32 because Normal was still deferred.
>    The allocation might have succeeded in DMA32, but won't.
> 
> This patch makes compaction deferring work on individual zone basis instead of
> preferred zone. For each zone, it checks compaction_deferred() to decide if the
> zone should be skipped. If watermarks fail after compacting the zone,
> defer_compaction() is called. The zone where watermarks passed can still be
> deferred when the allocation attempt is unsuccessful. When allocation is
> successful, compaction_defer_reset() is called for the zone containing the
> allocated page. This approach should approximate calling defer_compaction()
> only on zones where compaction was attempted and did not yield allocated page.
> There might be corner cases but that is inevitable as long as the decision
> to stop compacting dues not guarantee that a page will be allocated.
> 
> During testing on a two-node machine with a single very small Normal zone on
> node 1, this patch has improved success rates in stress-highalloc mmtests
> benchmark. The success here were previously made worse by commit 3a025760fc
> ("mm: page_alloc: spill to remote nodes before waking kswapd") as kswapd was
> no longer resetting often enough the deferred compaction for the Normal zone,
> and DMA32 zones on both nodes were thus not considered for compaction.
> On different machine, success rates were improved with __GFP_NO_KSWAPD
> allocations.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
