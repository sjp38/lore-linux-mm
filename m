Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEAE6B0008
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 09:31:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 31so9594479wrr.2
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 06:31:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si429027wrh.108.2018.04.03.06.31.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 06:31:17 -0700 (PDT)
Date: Tue, 3 Apr 2018 15:31:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
Message-ID: <20180403133115.GA5501@dhcp22.suse.cz>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org

On Mon 02-04-18 09:24:22, Buddy Lumpkin wrote:
> Page replacement is handled in the Linux Kernel in one of two ways:
> 
> 1) Asynchronously via kswapd
> 2) Synchronously, via direct reclaim
> 
> At page allocation time the allocating task is immediately given a page
> from the zone free list allowing it to go right back to work doing
> whatever it was doing; Probably directly or indirectly executing business
> logic.
> 
> Just prior to satisfying the allocation, free pages is checked to see if
> it has reached the zone low watermark and if so, kswapd is awakened.
> Kswapd will start scanning pages looking for inactive pages to evict to
> make room for new page allocations. The work of kswapd allows tasks to
> continue allocating memory from their respective zone free list without
> incurring any delay.
> 
> When the demand for free pages exceeds the rate that kswapd tasks can
> supply them, page allocation works differently. Once the allocating task
> finds that the number of free pages is at or below the zone min watermark,
> the task will no longer pull pages from the free list. Instead, the task
> will run the same CPU-bound routines as kswapd to satisfy its own
> allocation by scanning and evicting pages. This is called a direct reclaim.
> 
> The time spent performing a direct reclaim can be substantial, often
> taking tens to hundreds of milliseconds for small order0 allocations to
> half a second or more for order9 huge-page allocations. In fact, kswapd is
> not actually required on a linux system. It exists for the sole purpose of
> optimizing performance by preventing direct reclaims.
> 
> When memory shortfall is sufficient to trigger direct reclaims, they can
> occur in any task that is running on the system. A single aggressive
> memory allocating task can set the stage for collateral damage to occur in
> small tasks that rarely allocate additional memory. Consider the impact of
> injecting an additional 100ms of latency when nscd allocates memory to
> facilitate caching of a DNS query.
> 
> The presence of direct reclaims 10 years ago was a fairly reliable
> indicator that too much was being asked of a Linux system. Kswapd was
> likely wasting time scanning pages that were ineligible for eviction.
> Adding RAM or reducing the working set size would usually make the problem
> go away. Since then hardware has evolved to bring a new struggle for
> kswapd. Storage speeds have increased by orders of magnitude while CPU
> clock speeds stayed the same or even slowed down in exchange for more
> cores per package. This presents a throughput problem for a single
> threaded kswapd that will get worse with each generation of new hardware.

AFAIR we used to scale the number of kswapd workers many years ago. It
just turned out to be not all that great. We have a kswapd reclaim
window for quite some time and that can allow to tune how much proactive
kswapd should be.

Also please note that the direct reclaim is a way to throttle overly
aggressive memory consumers. The more we do in the background context
the easier for them it will be to allocate faster. So I am not really
sure that more background threads will solve the underlying problem. It
is just a matter of memory hogs tunning to end in the very same
situtation AFAICS. Moreover the more they are going to allocate the more
less CPU time will _other_ (non-allocating) task get.

> Test Details

I will have to study this more to comment.

[...]
> By increasing the number of kswapd threads, throughput increased by ~50%
> while kernel mode CPU utilization decreased or stayed the same, likely due
> to a decrease in the number of parallel tasks at any given time doing page
> replacement.

Well, isn't that just an effect of more work being done on behalf of
other workload that might run along with your tests (and which doesn't
really need to allocate a lot of memory)? In other words how
does the patch behaves with a non-artificial mixed workloads?

Please note that I am not saying that we absolutely have to stick with the
current single-thread-per-node implementation but I would really like to
see more background on why we should be allowing heavy memory hogs to
allocate faster or how to prevent that. I would be also very interested
to see how to scale the number of threads based on how CPUs are utilized
by other workloads.
-- 
Michal Hocko
SUSE Labs
