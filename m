Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C13196B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:25:51 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so97681305pac.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 18:25:51 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s3si16445777pfi.277.2016.10.13.18.25.50
        for <linux-mm@kvack.org>;
        Thu, 13 Oct 2016 18:25:50 -0700 (PDT)
Date: Fri, 14 Oct 2016 10:26:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/5] mm/page_alloc: use smallest fallback page first
 in movable allocation
Message-ID: <20161014012615.GB4993@js1304-P5Q-DELUXE>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-3-git-send-email-iamjoonsoo.kim@lge.com>
 <2567dd30-89c7-b9d2-c327-5dec8c536040@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2567dd30-89c7-b9d2-c327-5dec8c536040@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 13, 2016 at 11:12:10AM +0200, Vlastimil Babka wrote:
> On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >When we try to find freepage in fallback buddy list, we always serach
> >the largest one. This would help for fragmentation if we process
> >unmovable/reclaimable allocation request because it could cause permanent
> >fragmentation on movable pageblock and spread out such allocations would
> >cause more fragmentation. But, movable allocation request is
> >rather different. It would be simply freed or migrated so it doesn't
> >contribute to fragmentation on the other pageblock. In this case, it would
> >be better not to break the precious highest order freepage so we need to
> >search the smallest freepage first.
> 
> I've also pondered this, but then found a lower hanging fruit that
> should be hopefully clear win and mitigate most cases of breaking
> high-order pages unnecessarily:
> 
> http://marc.info/?l=linux-mm&m=147582914330198&w=2

Yes, I agree with that change. That's the similar patch what I tried
before.

"mm/page_alloc: don't break highest order freepage if steal"
http://marc.info/?l=linux-mm&m=143011930520417&w=2

> 
> So I would try that first, and then test your patch on top? In your
> patch there's a risk that we make it harder for
> unmovable/reclaimable pageblocks to become movable again (we start
> with the smallest page which means there's lower chance that
> move_freepages_block() will convert more than half of the block).

Indeed, but, with your "count movable pages when stealing", risk would
disappear. :)

> And Johannes's report seems to be about a regression in exactly this
> aspect of the heuristics.

Even if your change slows down the breaking high order freepage, but,
it would provide just a small delay to break. High order freepage
would be broken soon and we cannot prevent to decrease high order
freepage in the system. With my approach, high order freepage would
stay longer time.

For Johannes case, my approach doesn't aim at recovering from that
situation. Instead, it tries to prevent such situation that
migratetype of pageblock is changed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
