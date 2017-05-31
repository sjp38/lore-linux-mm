Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3F16B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 04:31:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so1241752wmf.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 01:31:48 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id h14si15078410wrc.165.2017.05.31.01.31.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 01:31:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 82AD699618
	for <linux-mm@kvack.org>; Wed, 31 May 2017 08:31:46 +0000 (UTC)
Date: Wed, 31 May 2017 09:31:45 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: fallback to smallest page when not
 stealing whole pageblock
Message-ID: <20170531083145.2s5pk5zhkf2kh4ga@techsingularity.net>
References: <20170529093947.22618-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170529093947.22618-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Mon, May 29, 2017 at 11:39:47AM +0200, Vlastimil Babka wrote:
> Since commit 3bc48f96cf11 ("mm, page_alloc: split smallest stolen page in
> fallback") we pick the smallest (but sufficient) page of all that have been
> stolen from a pageblock of different migratetype. However, there are cases when
> we decide not to steal the whole pageblock. Practically in the current
> implementation it means that we are trying to fallback for a MIGRATE_MOVABLE
> allocation of order X, go through the freelists from MAX_ORDER-1 down to X, and
> find free page of order Y. If Y is less than pageblock_order / 2, we decide not
> to steal all pages from the pageblock. When Y > X, it means we are potentially
> splitting a larger page than we need, as there might be other pages of order Z,
> where X <= Z < Y. Since Y is already too small to steal whole pageblock,
> picking smallest available Z will result in the same decision and we avoid
> splitting a higher-order page in a MIGRATE_UNMOVABLE or MIGRATE_RECLAIMABLE
> pageblock.
> 
> This patch therefore changes the fallback algorithm so that in the situation
> described above, we switch the fallback search strategy to go from order X
> upwards to find the smallest suitable fallback. In theory there shouldn't be
> a downside of this change wrt fragmentation.
> 
> This has been tested with mmtests' stress-highalloc performing GFP_KERNEL
> order-4 allocations, here is the relevant extfrag tracepoint statistics:
> 
>                                                       4.12.0-rc2      4.12.0-rc2
>                                                        1-kernel4       2-kernel4
> Page alloc extfrag event                                  25640976    69680977
> Extfrag fragmenting                                       25621086    69661364
> Extfrag fragmenting for unmovable                            74409       73204
> Extfrag fragmenting unmovable placed with movable            69003       67684
> Extfrag fragmenting unmovable placed with reclaim.            5406        5520
> Extfrag fragmenting for reclaimable                           6398        8467
> Extfrag fragmenting reclaimable placed with movable            869         884
> Extfrag fragmenting reclaimable placed with unmov.            5529        7583
> Extfrag fragmenting for movable                           25540279    69579693
> 
> Since we force movable allocations to steal the smallest available page (which
> we then practially always split), we steal less per fallback, so the number of
> fallbacks increases and steals potentially happen from different pageblocks.
> This is however not an issue for movable pages that can be compacted.
> 

Way back I was worried that more fragmenting events for movable like
this may lead to more unmovable fragmenting events and increase overall
fragmentation. At the time, it was also the case that I was mostly testing
32-bit and smaller memory sizes but that is now obviously different and the
mix of high-order allocation sizes has also changed considerably. Also,
while your data indicates there are more fragmenting events, there are
fewer for unmovable allocations so the data supports your position. Hence,
I can't backup by concerns other than with vague hand-waving about vague
recollections from 10 years ago so

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
