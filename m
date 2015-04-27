Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A4BA66B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:29:28 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so78322433wic.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 01:29:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tb3si11542708wic.122.2015.04.27.01.29.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 01:29:27 -0700 (PDT)
Date: Mon, 27 Apr 2015 09:29:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 3/3] mm: support active anti-fragmentation algorithm
Message-ID: <20150427082923.GG2449@suse.de>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1430119421-13536-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1430119421-13536-3-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Mon, Apr 27, 2015 at 04:23:41PM +0900, Joonsoo Kim wrote:
> We already have antifragmentation policy in page allocator. It works well
> when system memory is sufficient, but, it doesn't works well when system
> memory isn't sufficient because memory is already highly fragmented and
> fallback/steal mechanism cannot get whole pageblock. If there is severe
> unmovable allocation requestor like zram, problem could get worse.
> 
> CPU: 8
> RAM: 512 MB with zram swap
> WORKLOAD: kernel build with -j12
> OPTION: page owner is enabled to measure fragmentation
> After finishing the build, check fragmentation by 'cat /proc/pagetypeinfo'
> 
> * Before
> Number of blocks type (movable)
> DMA32: 207
> 
> Number of mixed blocks (movable)
> DMA32: 111.2
> 
> Mixed blocks means that there is one or more allocated page for
> unmovable/reclaimable allocation in movable pageblock. Results shows that
> more than half of movable pageblock is tainted by other migratetype
> allocation.
> 
> To mitigate this fragmentation, this patch implements active
> anti-fragmentation algorithm. Idea is really simple. When some
> unmovable/reclaimable steal happens from movable pageblock, we try to
> migrate out other pages that can be migratable in this pageblock are and
> use these generated freepage for further allocation request of
> corresponding migratetype.
> 
> Once unmovable allocation taints movable pageblock, it cannot easily
> recover. Instead of praying that it gets restored, making it unmovable
> pageblock as much as possible and using it further unmovable request
> would be more reasonable approach.
> 
> Below is result of this idea.
> 
> * After
> Number of blocks type (movable)
> DMA32: 208.2
> 
> Number of mixed blocks (movable)
> DMA32: 55.8
> 
> Result shows that non-mixed block increase by 59% in this case.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I haven't read the patch in detail but there were a few reasons why
active avoidance was not implemented originally.

1. If pages in the target block were reclaimed then it potentially
   increased stall latency in the future when they had to be refaulted
   again. A prototype that used lumpy reclaim originally suffered extreme
   stalls and was ultimately abandoned. The alternative at the time was
   to increase min_free_kbytes by default as it had a similar effect with
   much less disruption

2. If the pages in the target block were migrated then there was
   compaction overhead with no guarantee of success. Again, there were
   concerns about stalls. This was not deferred to an external thread
   because if the fragmenting process did not stall then it could simply
   cause more fragmentation-related damage while the thread executes. It
   becomes very unpredictable. While migration is in progress, processes
   also potentially stall if they reference the targetted pages.

3. Further on 2, the migration itself potentially triggers more fallback
   events while pages are isolated for the migration.

4. Migrating pages to another node is a bad idea. It requires a NUMA
   machine at the very least but more importantly it could violate memory
   policies. If the page was mapped then the VMA could be checked but if the
   pages were unmapped then the kernel potentially violates memory policies

At the time it was implemented, fragmentation avoidance was primarily
concerned about allocating hugetlbfs pages and later THP. Failing either
was not a functional failure that users would care about but large stalls
due to active fragmentation avoidance would disrupt workloads badly.

Just be sure to take the stalling and memory policy problems into
account.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
