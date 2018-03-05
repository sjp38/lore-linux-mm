Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 817846B0055
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 06:41:04 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s21so1427567pfm.15
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 03:41:04 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x87si10127947pff.17.2018.03.05.03.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 03:41:02 -0800 (PST)
Date: Mon, 5 Mar 2018 19:41:59 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v4 3/3] mm/free_pcppages_bulk: prefetch buddy while not
 holding lock
Message-ID: <20180305114159.GA32573@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301140044.GK15057@dhcp22.suse.cz>
 <cb158b3d-c992-6679-24df-b37d2bb170e0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cb158b3d-c992-6679-24df-b37d2bb170e0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Fri, Mar 02, 2018 at 06:55:25PM +0100, Vlastimil Babka wrote:
> On 03/01/2018 03:00 PM, Michal Hocko wrote:
> > On Thu 01-03-18 14:28:45, Aaron Lu wrote:
> >> When a page is freed back to the global pool, its buddy will be checked
> >> to see if it's possible to do a merge. This requires accessing buddy's
> >> page structure and that access could take a long time if it's cache cold.
> >>
> >> This patch adds a prefetch to the to-be-freed page's buddy outside of
> >> zone->lock in hope of accessing buddy's page structure later under
> >> zone->lock will be faster. Since we *always* do buddy merging and check
> >> an order-0 page's buddy to try to merge it when it goes into the main
> >> allocator, the cacheline will always come in, i.e. the prefetched data
> >> will never be unused.
> >>
> >> In the meantime, there are two concerns:
> >> 1 the prefetch could potentially evict existing cachelines, especially
> >>   for L1D cache since it is not huge;
> >> 2 there is some additional instruction overhead, namely calculating
> >>   buddy pfn twice.
> >>
> >> For 1, it's hard to say, this microbenchmark though shows good result but
> >> the actual benefit of this patch will be workload/CPU dependant;
> >> For 2, since the calculation is a XOR on two local variables, it's expected
> >> in many cases that cycles spent will be offset by reduced memory latency
> >> later. This is especially true for NUMA machines where multiple CPUs are
> >> contending on zone->lock and the most time consuming part under zone->lock
> >> is the wait of 'struct page' cacheline of the to-be-freed pages and their
> >> buddies.
> >>
> >> Test with will-it-scale/page_fault1 full load:
> >>
> >> kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> >> v4.16-rc2+  9034215        7971818       13667135       15677465
> >> patch2/3    9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%
> >> this patch 10338868 +8.4%  8544477 +2.8% 14839808 +5.5% 17155464 +2.9%
> >> Note: this patch's performance improvement percent is against patch2/3.
> > 
> > I am really surprised that this has such a big impact.
> 
> It's even stranger to me. Struct page is 64 bytes these days, exactly a
> a cache line. Unless that changed, Intel CPUs prefetched a "buddy" cache
> line (that forms an aligned 128 bytes block with the one we touch).
> Which is exactly a order-0 buddy struct page! Maybe that implicit
> prefetching stopped at L2 and explicit goes all the way to L1, can't

The Intel Architecture Optimization Manual section 7.3.2 says:

prefetchT0 - fetch data into all cache levels
Intel Xeon Processors based on Nehalem, Westmere, Sandy Bridge and newer
microarchitectures: 1st, 2nd and 3rd level cache.

prefetchT2 - fetch data into 2nd and 3rd level caches (identical to
prefetchT1)
Intel Xeon Processors based on Nehalem, Westmere, Sandy Bridge and newer
microarchitectures: 2nd and 3rd level cache.

prefetchNTA - fetch data into non-temporal cache close to the processor,
minimizing cache pollution
Intel Xeon Processors based on Nehalem, Westmere, Sandy Bridge and newer
microarchitectures: must fetch into 3rd level cache with fast replacement.

I tried 'prefetcht0' and 'prefetcht2' instead of the default
'prefetchNTA' on a 2 sockets Intel Skylake, the two ended up with about
the same performance number as prefetchNTA. I had expected prefetchT0 to
deliver a better score if it was indeed due to L1D since prefetchT2 will
not place data into L1 while prefetchT0 will, but looks like it is not
the case here.

It feels more like the buddy cacheline isn't in any level of the caches
without prefetch for some reason.

> remember. Would that make such a difference? It would be nice to do some
> perf tests with cache counters to see what is really going on...

Compare prefetchT2 to no-prefetch, I saw these metrics change:

no-prefetch          change  prefetchT2       metrics
            \                          \
	   stddev                     stddev
------------------------------------------------------------------------
      0.18            +0.0        0.18        perf-stat.branch-miss-rate%                                       
 8.268e+09            +3.8%  8.585e+09        perf-stat.branch-misses                               
 2.333e+10            +4.7%  2.443e+10        perf-stat.cache-misses                                            
 2.402e+11            +5.0%  2.522e+11        perf-stat.cache-references                                    
      3.52            -1.1%       3.48        perf-stat.cpi                                                     
      0.02            -0.0        0.01 +-3%    perf-stat.dTLB-load-miss-rate%                           
 8.677e+08            -7.3%  8.048e+08 +-3%    perf-stat.dTLB-load-misses                                        
      1.18            +0.0        1.19        perf-stat.dTLB-store-miss-rate%             
 2.359e+10            +6.0%  2.502e+10        perf-stat.dTLB-store-misses                                       
 1.979e+12            +5.0%  2.078e+12        perf-stat.dTLB-stores                     
 6.126e+09           +10.1%  6.745e+09 +-3%    perf-stat.iTLB-load-misses                                        
      3464            -8.4%       3172 +-3%    perf-stat.instructions-per-iTLB-miss            
      0.28            +1.1%       0.29        perf-stat.ipc                                                     
 2.929e+09            +5.1%  3.077e+09        perf-stat.minor-faults                         
 9.244e+09            +4.7%  9.681e+09        perf-stat.node-loads                                              
 2.491e+08            +5.8%  2.634e+08        perf-stat.node-store-misses               
 6.472e+09            +6.1%  6.869e+09        perf-stat.node-stores                                             
 2.929e+09            +5.1%  3.077e+09        perf-stat.page-faults                          
   2182469            -4.2%    2090977        perf-stat.path-length

Not sure if this is useful though...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
