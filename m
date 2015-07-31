Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 354866B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 01:49:15 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so37519853pdj.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 22:49:14 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id fk2si4199824pab.155.2015.07.30.22.49.13
        for <linux-mm@kvack.org>;
        Thu, 30 Jul 2015 22:49:14 -0700 (PDT)
Date: Fri, 31 Jul 2015 14:54:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150731055407.GA15912@js1304-P5Q-DELUXE>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-10-git-send-email-mgorman@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437379219-9160-10-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Hello, Mel.

On Mon, Jul 20, 2015 at 09:00:18AM +0100, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
> 
> High-order watermark checking exists for two reasons --  kswapd high-order
> awareness and protection for high-order atomic requests. Historically we
> depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order free
> pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> that reserves pageblocks for high-order atomic allocations. This is expected
> to be more reliable than MIGRATE_RESERVE was.

I have some concerns on this patch.

1) This patch breaks intention of __GFP_WAIT.
__GFP_WAIT is used when we want to succeed allocation even if we need
to do some reclaim/compaction work. That implies importance of
allocation success. But, reserved pageblock for MIGRATE_HIGHATOMIC makes
atomic allocation (~__GFP_WAIT) more successful than allocation with
__GFP_WAIT in many situation. It breaks basic assumption of gfp flags
and doesn't make any sense.

2) Who care about success of high-order atomic allocation with this
reliability?
In case of allocation without __GFP_WAIT, requestor preare sufficient
fallback method. They just want to success if it is easily successful.
They don't want to succeed allocation with paying great cost that slow
down general workload by this patch that can be accidentally reserve
too much memory.

> A MIGRATE_HIGHORDER pageblock is created when an allocation request steals
> a pageblock but limits the total number to 10% of the zone.

When steals happens, pageblock already can be fragmented and we can't
fully utilize this pageblock without allowing order-0 allocation. This
is very waste.

> The pageblocks are unreserved if an allocation fails after a direct
> reclaim attempt.
> 
> The watermark checks account for the reserved pageblocks when the allocation
> request is not a high-order atomic allocation.
> 
> The stutter benchmark was used to evaluate this but while it was running
> there was a systemtap script that randomly allocated between 1 and 1G worth
> of order-3 pages using GFP_ATOMIC. In kernel 4.2-rc1 running this workload
> on a single-node machine there were 339574 allocation failures. With this
> patch applied there were 28798 failures -- a 92% reduction. On a 4-node
> machine, allocation failures went from 76917 to 0 failures.

There is some missing information to justify benchmark result.
Especially, I'd like to know:

1) Detailed system setup (CPU, MEMORY, etc...)
2) Total number of attempt of GFP_ATOMIC allocation request

I don't know how you modify stutter benchmark in mmtests but it
looks like there is no delay when continually requesting GFP_ATOMIC
allocation. 1G of order-3 allocation request without delay seems insane
to me. Could you tell me how you modify that benchmark for this patch?

> There are minor theoritical side-effects. If the system is intensively
> making large numbers of long-lived high-order atomic allocations then
> there will be a lot of reserved pageblocks. This may push some workloads
> into reclaim until the number of reserved pageblocks is reduced again. This
> problem was not observed in reclaim intensive workloads but such workloads
> are also not atomic high-order intensive.

I don't think this is theoritical side-effects. It can happen easily.
Recently, network subsystem makes some of their high-order allocation
request ~_GFP_WAIT (fb05e7a89f50: net: don't wait for order-3 page
allocation). And, I've submitted similar patch for slub today
(mm/slub: don't wait for high-order page allocation). That
makes system atomic high-order allocation request more and this side-effect
can be possible in many situation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
