Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6758F6B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 21:29:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so11288527pfb.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 18:29:12 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g1si1219588pfd.0.2016.05.02.18.29.10
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 18:29:11 -0700 (PDT)
Date: Tue, 3 May 2016 10:29:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/6] Introduce ZONE_CMA
Message-ID: <20160503012934.GA4060@js1304-P5Q-DELUXE>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160425053653.GA25662@js1304-P5Q-DELUXE>
 <20160428103927.GM2858@techsingularity.net>
 <20160429065145.GA19896@js1304-P5Q-DELUXE>
 <20160429092902.GQ2858@techsingularity.net>
 <20160502061423.GA31646@js1304-P5Q-DELUXE>
 <5727069B.5070600@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5727069B.5070600@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 02, 2016 at 09:49:47AM +0200, Vlastimil Babka wrote:
> On 05/02/2016 08:14 AM, Joonsoo Kim wrote:
> >>>> >Although it's separate issue, I should mentioned one thing. Related to
> >>>> >I/O pinning issue, ZONE_CMA don't get blockdev allocation request so
> >>>> >I/O pinning problem is much reduced.
> >>>> >
> >>>
> >>>This is not super-clear from the patch. blockdev is using GFP_USER so it
> >>>already should not be classed as MOVABLE. I could easily be looking in
> >>>the wrong place or missed which allocation path sets GFP_MOVABLE.
> >Okay. Please see sb_bread(), sb_getblk(), __getblk() and __bread() in
> >include/linux/buffer_head.h. These are main functions used by blockdev
> >and they uses GFP_MOVABLE. To fix permanent allocation case which is
> >used by mount and cannot be released until umount, Gioh introduces
> >sb_bread_unmovable() but there are many remaining issues that prevent
> >migration at the moment and avoid blockdev allocation from CMA area is
> >preferable approach.
> 
> Hm Patch 3/6 describes the lack of blockdev allocations mostly as a
> limitation, although it does mention the possible advantages later.

Because what this patch try to do isn't an optimization. It would be
best to maintain previous behaviour as much as possible but it
doesn't. Therfore, I mentioned it as side-effect of this patch
although it seems to be a good thing to me.

> Anyway, this doesn't have to be specific to ZONE_CMA, right? You
> could just change ALLOC_CMA handling to consider
> GFP_HIGHUSER_MOVABLE instead of just __GFP_MOVABLE. For ZONE_CMA it
> might be inevitable as you describe, but it's already possible to do
> that now, if the advantages are larger than the disadvantages.

I think that it's not easy. Even if we just allow freepages on CMA area
when GFP_HIGHUSER_MOVABLE allocation request comes, compaction could move
__GFP_MOVABLE pages to freepages on CMA pageblock. Allocated page has no
knowledge about requested gfp and compaction just assume that
migration within a single zone is safe. So, compaction would migrate
__GFP_MOVABLE blockdev pages on ordinary pageblock to the page on CMA
pageblock and we can't easily prevent it. I guess it would be marginal
amount but I'm not sure whether it causes some other problems or not.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
