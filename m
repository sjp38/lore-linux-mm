Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D26276B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 03:11:22 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so19711412wib.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 00:11:22 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id b19si3432826wic.93.2015.07.31.00.11.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 00:11:21 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id EE8569889E
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:11:19 +0000 (UTC)
Date: Fri, 31 Jul 2015 08:11:13 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150731071113.GA5840@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-10-git-send-email-mgorman@suse.com>
 <20150731055407.GA15912@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150731055407.GA15912@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 31, 2015 at 02:54:07PM +0900, Joonsoo Kim wrote:
> Hello, Mel.
> 
> On Mon, Jul 20, 2015 at 09:00:18AM +0100, Mel Gorman wrote:
> > From: Mel Gorman <mgorman@suse.de>
> > 
> > High-order watermark checking exists for two reasons --  kswapd high-order
> > awareness and protection for high-order atomic requests. Historically we
> > depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order free
> > pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> > that reserves pageblocks for high-order atomic allocations. This is expected
> > to be more reliable than MIGRATE_RESERVE was.
> 
> I have some concerns on this patch.
> 
> 1) This patch breaks intention of __GFP_WAIT.
> __GFP_WAIT is used when we want to succeed allocation even if we need
> to do some reclaim/compaction work. That implies importance of
> allocation success. But, reserved pageblock for MIGRATE_HIGHATOMIC makes
> atomic allocation (~__GFP_WAIT) more successful than allocation with
> __GFP_WAIT in many situation. It breaks basic assumption of gfp flags
> and doesn't make any sense.
> 

Currently allocation requests that do not specify __GFP_WAIT get the
ALLOC_HARDER flag which allows them to dip further into watermark reserves.
It already is the case that there are corner cases where a high atomic
allocation can succeed when a non-atomic allocation would reclaim.

> 2) Who care about success of high-order atomic allocation with this
> reliability?

Historically network configurations with large MTUs that could not scatter
gather. These days network will also attempt atomic order-3 allocations
to reduce overhead. SLUB also attempts atomic high-order allocations to
reduce overhead. It's why MIGRATE_RESERVE exists at all so the intent of
the patch is to preserve what MIGRATE_RESERVE was for but do it better.

> In case of allocation without __GFP_WAIT, requestor preare sufficient
> fallback method. They just want to success if it is easily successful.
> They don't want to succeed allocation with paying great cost that slow
> down general workload by this patch that can be accidentally reserve
> too much memory.
> 

Not necessary true. In the historical case, the network request was atomic
because it was from IRQ context and could not sleep.

> > A MIGRATE_HIGHORDER pageblock is created when an allocation request steals
> > a pageblock but limits the total number to 10% of the zone.
> 
> When steals happens, pageblock already can be fragmented and we can't
> fully utilize this pageblock without allowing order-0 allocation. This
> is very waste.
> 

If the pageblock was stolen, it implies there was at least 1 usable page
of the correct order. As the pageblock is then reserved, any pages that
free in that block stay free for use by high-order atomic allocations.
Else, the number of pageblocks will increase again until the 10% limit
is hit.

> > The pageblocks are unreserved if an allocation fails after a direct
> > reclaim attempt.
> > 
> > The watermark checks account for the reserved pageblocks when the allocation
> > request is not a high-order atomic allocation.
> > 
> > The stutter benchmark was used to evaluate this but while it was running
> > there was a systemtap script that randomly allocated between 1 and 1G worth
> > of order-3 pages using GFP_ATOMIC. In kernel 4.2-rc1 running this workload
> > on a single-node machine there were 339574 allocation failures. With this
> > patch applied there were 28798 failures -- a 92% reduction. On a 4-node
> > machine, allocation failures went from 76917 to 0 failures.
> 
> There is some missing information to justify benchmark result.
> Especially, I'd like to know:
> 
> 1) Detailed system setup (CPU, MEMORY, etc...)

CPUs were 8 core Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz with 8G of RAM.

> 2) Total number of attempt of GFP_ATOMIC allocation request
> 

Each attempt was between 1 and 1G randomly as described already.

> I don't know how you modify stutter benchmark in mmtests but it
> looks like there is no delay when continually requesting GFP_ATOMIC
> allocation.
> 1G of order-3 allocation request without delay seems insane
> to me. Could you tell me how you modify that benchmark for this patch?
> 

The stutter benchmark was not modified. The watch-stress-highorder-atomic
monitor was run in parallel and that's what is doing the allocation. It's
true that up to 1G of order-3 allocations without delay would be insane
in a normal situation. The point was to show an extreme case where atomic
allocations were used and to test whether the reserves held up or not.


> > There are minor theoritical side-effects. If the system is intensively
> > making large numbers of long-lived high-order atomic allocations then
> > there will be a lot of reserved pageblocks. This may push some workloads
> > into reclaim until the number of reserved pageblocks is reduced again. This
> > problem was not observed in reclaim intensive workloads but such workloads
> > are also not atomic high-order intensive.
> 
> I don't think this is theoritical side-effects. It can happen easily.
> Recently, network subsystem makes some of their high-order allocation
> request ~_GFP_WAIT (fb05e7a89f50: net: don't wait for order-3 page
> allocation). And, I've submitted similar patch for slub today
> (mm/slub: don't wait for high-order page allocation). That
> makes system atomic high-order allocation request more and this side-effect
> can be possible in many situation.
> 

The key is long-lived allocations. The network subsystem frees theirs. I
was not able to trigger a situation in a variety of workloads where these
happened which is why I classified it as theoritical.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
