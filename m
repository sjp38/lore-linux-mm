Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A27AF6B0253
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 03:21:11 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so1664146wmd.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 00:21:11 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id t14si1968575wme.122.2016.12.02.00.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 00:21:10 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id xy5so29246085wjc.1
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 00:21:10 -0800 (PST)
Date: Fri, 2 Dec 2016 09:21:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: page_alloc: High-order per-cpu page allocator v5
Message-ID: <20161202082108.GB6830@dhcp22.suse.cz>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-3-mgorman@techsingularity.net>
 <20161202060346.GA21434@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202060346.GA21434@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Fri 02-12-16 15:03:46, Joonsoo Kim wrote:
[...]
> > o pcp accounting during free is now confined to free_pcppages_bulk as it's
> >   impossible for the caller to know exactly how many pages were freed.
> >   Due to the high-order caches, the number of pages drained for a request
> >   is no longer precise.
> > 
> > o The high watermark for per-cpu pages is increased to reduce the probability
> >   that a single refill causes a drain on the next free.
[...]
> I guess that this patch would cause following problems.
> 
> 1. If pcp->batch is too small, high order page will not be freed
> easily and survive longer. Think about following situation.
> 
> Batch count: 7
> MIGRATE_UNMOVABLE -> MIGRATE_MOVABLE -> MIGRATE_RECLAIMABLE -> order 1
> -> order 2...
> 
> free count: 1 + 1 + 1 + 2 + 4 = 9
> so order 3 would not be freed.

I guess the second paragraph above in the changelog tries to clarify
that...
 
> 2. And, It seems that this logic penalties high order pages. One free
> to high order page means 1 << order pages free rather than just
> one page free. This logic do round-robin to choose the target page so
> amount of freed page will be different by the order.

Yes this is indeed possible. The first paragraph above mentions this
problem.

> I think that it
> makes some sense because high order page are less important to cache
> in pcp than lower order but I'd like to know if it is intended or not.
> If intended, it deserves the comment.
> 
> 3. I guess that order-0 file/anon page alloc/free is dominent in many
> workloads. If this case happen, it invalidates effect of high order
> cache in pcp since cached high order pages would be also freed to the
> buddy when burst order-0 free happens.

Yes this is true and I was wondering the same but I believe this can be
enahanced later on. E.g. we can check the order when crossing pcp->high
mark and only the given order portion of the batch. I just wouldn't over
optimize at this stage.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
