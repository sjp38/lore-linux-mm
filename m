Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF0556B005C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 06:48:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d19so7273567pgn.20
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 03:48:32 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e22-v6si7629987plj.143.2018.03.05.03.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 03:48:31 -0800 (PST)
Date: Mon, 5 Mar 2018 19:48:27 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v4 3/3] mm/free_pcppages_bulk: prefetch buddy while not
 holding lock
Message-ID: <20180305114826.GA2184@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301140044.GK15057@dhcp22.suse.cz>
 <cb158b3d-c992-6679-24df-b37d2bb170e0@suse.cz>
 <20180305114159.GA32573@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305114159.GA32573@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Mon, Mar 05, 2018 at 07:41:59PM +0800, Aaron Lu wrote:
> On Fri, Mar 02, 2018 at 06:55:25PM +0100, Vlastimil Babka wrote:
> > On 03/01/2018 03:00 PM, Michal Hocko wrote:
> > > On Thu 01-03-18 14:28:45, Aaron Lu wrote:
> > >> When a page is freed back to the global pool, its buddy will be checked
> > >> to see if it's possible to do a merge. This requires accessing buddy's
> > >> page structure and that access could take a long time if it's cache cold.
> > >>
> > >> This patch adds a prefetch to the to-be-freed page's buddy outside of
> > >> zone->lock in hope of accessing buddy's page structure later under
> > >> zone->lock will be faster. Since we *always* do buddy merging and check
> > >> an order-0 page's buddy to try to merge it when it goes into the main
> > >> allocator, the cacheline will always come in, i.e. the prefetched data
> > >> will never be unused.
> > >>
> > >> In the meantime, there are two concerns:
> > >> 1 the prefetch could potentially evict existing cachelines, especially
> > >>   for L1D cache since it is not huge;
> > >> 2 there is some additional instruction overhead, namely calculating
> > >>   buddy pfn twice.
> > >>
> > >> For 1, it's hard to say, this microbenchmark though shows good result but
> > >> the actual benefit of this patch will be workload/CPU dependant;
> > >> For 2, since the calculation is a XOR on two local variables, it's expected
> > >> in many cases that cycles spent will be offset by reduced memory latency
> > >> later. This is especially true for NUMA machines where multiple CPUs are
> > >> contending on zone->lock and the most time consuming part under zone->lock
> > >> is the wait of 'struct page' cacheline of the to-be-freed pages and their
> > >> buddies.
> > >>
> > >> Test with will-it-scale/page_fault1 full load:
> > >>
> > >> kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> > >> v4.16-rc2+  9034215        7971818       13667135       15677465
> > >> patch2/3    9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%
> > >> this patch 10338868 +8.4%  8544477 +2.8% 14839808 +5.5% 17155464 +2.9%
> > >> Note: this patch's performance improvement percent is against patch2/3.
> > > 
> > > I am really surprised that this has such a big impact.
> > 
> > It's even stranger to me. Struct page is 64 bytes these days, exactly a
> > a cache line. Unless that changed, Intel CPUs prefetched a "buddy" cache
> > line (that forms an aligned 128 bytes block with the one we touch).
> > Which is exactly a order-0 buddy struct page! Maybe that implicit
> > prefetching stopped at L2 and explicit goes all the way to L1, can't
> 
> The Intel Architecture Optimization Manual section 7.3.2 says:
> 
> prefetchT0 - fetch data into all cache levels
> Intel Xeon Processors based on Nehalem, Westmere, Sandy Bridge and newer
> microarchitectures: 1st, 2nd and 3rd level cache.
> 
> prefetchT2 - fetch data into 2nd and 3rd level caches (identical to
> prefetchT1)
> Intel Xeon Processors based on Nehalem, Westmere, Sandy Bridge and newer
> microarchitectures: 2nd and 3rd level cache.
> 
> prefetchNTA - fetch data into non-temporal cache close to the processor,
> minimizing cache pollution
> Intel Xeon Processors based on Nehalem, Westmere, Sandy Bridge and newer
> microarchitectures: must fetch into 3rd level cache with fast replacement.
> 
> I tried 'prefetcht0' and 'prefetcht2' instead of the default
> 'prefetchNTA' on a 2 sockets Intel Skylake, the two ended up with about
                                     ~~~~~~~
               Correction: should be Broadwell here.

> the same performance number as prefetchNTA. I had expected prefetchT0 to
> deliver a better score if it was indeed due to L1D since prefetchT2 will
> not place data into L1 while prefetchT0 will, but looks like it is not
> the case here.
> 
> It feels more like the buddy cacheline isn't in any level of the caches
> without prefetch for some reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
