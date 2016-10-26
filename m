Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31C586B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:40:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n18so41046170pfe.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 21:40:18 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g11si392354pgn.73.2016.10.25.21.40.16
        for <linux-mm@kvack.org>;
        Tue, 25 Oct 2016 21:40:17 -0700 (PDT)
Date: Wed, 26 Oct 2016 13:41:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/5] mm/page_alloc: use smallest fallback page first
 in movable allocation
Message-ID: <20161026044125.GC2901@js1304-P5Q-DELUXE>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-3-git-send-email-iamjoonsoo.kim@lge.com>
 <2567dd30-89c7-b9d2-c327-5dec8c536040@suse.cz>
 <20161014012615.GB4993@js1304-P5Q-DELUXE>
 <8de00249-2a73-0a9b-b5ab-7ac6423454b0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8de00249-2a73-0a9b-b5ab-7ac6423454b0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 14, 2016 at 12:52:26PM +0200, Vlastimil Babka wrote:
> On 10/14/2016 03:26 AM, Joonsoo Kim wrote:
> >On Thu, Oct 13, 2016 at 11:12:10AM +0200, Vlastimil Babka wrote:
> >>On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> >>>From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >>>
> >>>When we try to find freepage in fallback buddy list, we always serach
> >>>the largest one. This would help for fragmentation if we process
> >>>unmovable/reclaimable allocation request because it could cause permanent
> >>>fragmentation on movable pageblock and spread out such allocations would
> >>>cause more fragmentation. But, movable allocation request is
> >>>rather different. It would be simply freed or migrated so it doesn't
> >>>contribute to fragmentation on the other pageblock. In this case, it would
> >>>be better not to break the precious highest order freepage so we need to
> >>>search the smallest freepage first.
> >>
> >>I've also pondered this, but then found a lower hanging fruit that
> >>should be hopefully clear win and mitigate most cases of breaking
> >>high-order pages unnecessarily:
> >>
> >>http://marc.info/?l=linux-mm&m=147582914330198&w=2
> >
> >Yes, I agree with that change. That's the similar patch what I tried
> >before.
> >
> >"mm/page_alloc: don't break highest order freepage if steal"
> >http://marc.info/?l=linux-mm&m=143011930520417&w=2
> 
> Ah, indeed, I forgot about it and had to rediscover :)
> 
> >
> >>
> >>So I would try that first, and then test your patch on top? In your
> >>patch there's a risk that we make it harder for
> >>unmovable/reclaimable pageblocks to become movable again (we start
> >>with the smallest page which means there's lower chance that
> >>move_freepages_block() will convert more than half of the block).
> >
> >Indeed, but, with your "count movable pages when stealing", risk would
> >disappear. :)
> 
> Hmm, but that counting is only triggered when we attempt to steal
> whole pageblock. For movable allocation, can_steal_fallback() allows
> that only for
> (order >= pageblock_order / 2), and since your patch makes "order"
> as small as possible for movable allocations, the chances are lower?

Chances are lower than current but we eventually try to steal that
(order >= pageblock_order / 2) freepage from unmovable pageblock and
your logic will result in changing pageblock migratetype from
unmovable to movable.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
