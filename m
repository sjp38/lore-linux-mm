Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5E85828E1
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:06:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so148054780pfa.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:06:55 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c69si8037370pfj.224.2016.07.21.00.06.54
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 00:06:55 -0700 (PDT)
Date: Thu, 21 Jul 2016 16:07:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v1
Message-ID: <20160721070714.GC31865@bbox>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

On Wed, Jul 20, 2016 at 04:21:46PM +0100, Mel Gorman wrote:
> Both Joonsoo Kim and Minchan Kim have reported premature OOM kills on
> a 32-bit platform. The common element is a zone-constrained high-order
> allocation failing. Two factors appear to be at fault -- pgdat being

Strictly speaking, my case is order-0 allocation failing, not high-order.
;)

> considered unreclaimable prematurely and insufficient rotation of the
> active list.
> 
> Unfortunately to date I have been unable to reproduce this with a variety
> of stress workloads on a 2G 32-bit KVM instance. It's not clear why as
> the steps are similar to what was described. It means I've been unable to
> determine if this series addresses the problem or not. I'm hoping they can
> test and report back before these are merged to mmotm. What I have checked
> is that a basic parallel DD workload completed successfully on the same
> machine I used for the node-lru performance tests. I'll leave the other
> tests running just in case anything interesting falls out.
> 
> The series is in three basic parts;
> 
> Patch 1 does not account for skipped pages as scanned. This avoids the pgdat
> 	being prematurely marked unreclaimable
> 
> Patches 2-4 add per-zone stats back in. The actual stats patch is different
> 	to Minchan's as the original patch did not account for unevictable
> 	LRU which would corrupt counters. The second two patches remove
> 	approximations based on pgdat statistics. It's effectively a
> 	revert of "mm, vmstat: remove zone and node double accounting by
> 	approximating retries" but different LRU stats are used. This
> 	is better than a full revert or a reworking of the series as
> 	it preserves history of why the zone stats are necessary.
> 
> 	If this work out, we may have to leave the double accounting in
> 	place for now until an alternative cheap solution presents itself.
> 
> Patch 5 rotates inactive/active lists for lowmem allocations. This is also
> 	quite different to Minchan's patch as the original patch did not
> 	account for memcg and would rotate if *any* eligible zone needed
> 	rotation which may rotate excessively. The new patch considers
> 	the ratio for all eligible zones which is more in line with
> 	node-lru in general.
> 

Now I tested and confirmed it works for me at the OOM point of view.
IOW, I cannot see OOM kill any more. But note that I tested it
without [1/5] which has a problem I mentioned in that thread.

If you want to merge [1/5], please resend updated version but
I doubt we need it at this moment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
