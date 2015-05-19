Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3AAE96B009A
	for <linux-mm@kvack.org>; Tue, 19 May 2015 03:46:57 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so12744027pad.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 00:46:57 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id kd10si19795733pbd.87.2015.05.19.00.46.53
        for <linux-mm@kvack.org>;
        Tue, 19 May 2015 00:46:56 -0700 (PDT)
Date: Tue, 19 May 2015 16:47:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm/page_alloc: stop fallback allocation if we
 already get some freepage
Message-ID: <20150519074708.GD12092@js1304-P5Q-DELUXE>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1430119421-13536-2-git-send-email-iamjoonsoo.kim@lge.com>
 <5551BB98.2040703@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5551BB98.2040703@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Tue, May 12, 2015 at 10:36:40AM +0200, Vlastimil Babka wrote:
> On 04/27/2015 09:23 AM, Joonsoo Kim wrote:
> >Sometimes we try to get more freepages from buddy list than how much
> >we really need, in order to refill pcp list. This may speed up following
> >allocation request, but, there is a possibility to increase fragmentation
> >if we steal freepages from other migratetype buddy list excessively. This
> >patch changes this behaviour to stop fallback allocation in order to
> >reduce fragmentation if we already get some freepages.
> >
> >CPU: 8
> >RAM: 512 MB with zram swap
> >WORKLOAD: kernel build with -j12
> >OPTION: page owner is enabled to measure fragmentation
> >After finishing the build, check fragmentation by 'cat /proc/pagetypeinfo'
> >
> >* Before
> >Number of blocks type (movable)
> >DMA32: 208.4
> >
> >Number of mixed blocks (movable)
> >DMA32: 139
> >
> >Mixed blocks means that there is one or more allocated page for
> >unmovable/reclaimable allocation in movable pageblock. Results shows that
> >more than half of movable pageblock is tainted by other migratetype
> >allocation.
> >
> >* After
> >Number of blocks type (movable)
> >DMA32: 207
> >
> >Number of mixed blocks (movable)
> >DMA32: 111.2
> >
> >This result shows that non-mixed block increase by 38% in this case.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> I agree that keeping fragmentation low is more important than
> filling up the pcplists. Wouldn't expect such large difference
> though. Are the results stable?

Yes, I think that improvement is very stable. stdev is roughly 8 in 5 runs.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
