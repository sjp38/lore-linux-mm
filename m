Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 017B76B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 15:32:19 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so34838403wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:32:18 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ur8si6486643wjc.155.2015.09.25.12.32.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 12:32:17 -0700 (PDT)
Date: Fri, 25 Sep 2015 15:32:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150925193206.GE16359@cmpxchg.org>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <20150921120317.GC3068@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921120317.GC3068@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 21, 2015 at 01:03:17PM +0100, Mel Gorman wrote:
> The primary purpose of watermarks is to ensure that reclaim can always
> make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> These assume that order-0 allocations are all that is necessary for
> forward progress.
> 
> High-order watermarks serve a different purpose. Kswapd
> had no high-order awareness before they were introduced
> (https://lkml.kernel.org/r/413AA7B2.4000907@yahoo.com.au).  This was
> particularly important when there were high-order atomic requests.
> The watermarks both gave kswapd awareness and made a reserve for those
> atomic requests.
> 
> There are two important side-effects of this. The most important is that
> a non-atomic high-order request can fail even though free pages are available
> and the order-0 watermarks are ok. The second is that high-order watermark
> checks are expensive as the free list counts up to the requested order must
> be examined.
> 
> With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
> have high-order watermarks. Kswapd and compaction still need high-order
> awareness which is handled by checking that at least one suitable high-order
> page is free.
> 
> With the patch applied, there was little difference in the allocation
> failure rates as the atomic reserves are small relative to the number of
> allocation attempts. The expected impact is that there will never be an
> allocation failure report that shows suitable pages on the free lists.
> 
> The one potential side-effect of this is that in a vanilla kernel, the
> watermark checks may have kept a free page for an atomic allocation. Now,
> we are 100% relying on the HighAtomic reserves and an early allocation to
> have allocated them.  If the first high-order atomic allocation is after
> the system is already heavily fragmented then it'll fail.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Michal Hocko <mhocko@suse.com>

Nice. This really is a great improvement over the way we used to
ensure higher-order page availability.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
