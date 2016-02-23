Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id F15F76B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:04:22 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id a4so94603wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:04:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bm5si46702234wjb.92.2016.02.23.12.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 12:04:21 -0800 (PST)
Date: Tue, 23 Feb 2016 12:04:16 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 00/27] Move LRU page reclaim from zones to nodes v2
Message-ID: <20160223200416.GA27563@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:23PM +0000, Mel Gorman wrote:
> In many benchmarks, there is an obvious difference in the number of
> allocations from each zone as the fair zone allocation policy is removed
> towards the end of the series. For example, this is the allocation stats
> when running blogbench that showed no difference in headling performance
> 
>                           mmotm-20160209   nodelru-v2
> DMA allocs                           0           0
> DMA32 allocs                   7218763      608067
> Normal allocs                 12701806    18821286
> Movable allocs                       0           0

According to the mmotm numbers, your DMA32 zone is over a third of
available memory, yet in the nodelru-v2 kernel sees only 3% of the
allocations. That's an insanely high level of aging inversion, where
the lifetime of a cache entry is again highly dependent on placement.

The fact that this doesn't make a performance difference in the
specific benchmarks you ran only proves just that: these specific
benchmarks don't care. IMO, benchmarking is not enough here. If this
is truly supposed to be unproblematic, then I think we need a reasoned
explanation. I can't imagine how it possibly could be, though.

If reclaim can't guarantee a balanced zone utilization then the
allocator has to keep doing it. :( As far as I'm concerned, the
original reason for the fair zone allocator still applies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
