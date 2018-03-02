Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4226B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 19:09:56 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j28so5113679wrd.17
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 16:09:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z4si3385701wrh.1.2018.03.01.16.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 16:09:54 -0800 (PST)
Date: Thu, 1 Mar 2018 16:09:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 3/3] mm/free_pcppages_bulk: prefetch buddy while not
 holding lock
Message-Id: <20180301160950.b561d6b8b561217bad511229@linux-foundation.org>
In-Reply-To: <20180301062845.26038-4-aaron.lu@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
	<20180301062845.26038-4-aaron.lu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Thu,  1 Mar 2018 14:28:45 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> When a page is freed back to the global pool, its buddy will be checked
> to see if it's possible to do a merge. This requires accessing buddy's
> page structure and that access could take a long time if it's cache cold.
> 
> This patch adds a prefetch to the to-be-freed page's buddy outside of
> zone->lock in hope of accessing buddy's page structure later under
> zone->lock will be faster. Since we *always* do buddy merging and check
> an order-0 page's buddy to try to merge it when it goes into the main
> allocator, the cacheline will always come in, i.e. the prefetched data
> will never be unused.
> 
> In the meantime, there are two concerns:
> 1 the prefetch could potentially evict existing cachelines, especially
>   for L1D cache since it is not huge;
> 2 there is some additional instruction overhead, namely calculating
>   buddy pfn twice.
> 
> For 1, it's hard to say, this microbenchmark though shows good result but
> the actual benefit of this patch will be workload/CPU dependant;
> For 2, since the calculation is a XOR on two local variables, it's expected
> in many cases that cycles spent will be offset by reduced memory latency
> later. This is especially true for NUMA machines where multiple CPUs are
> contending on zone->lock and the most time consuming part under zone->lock
> is the wait of 'struct page' cacheline of the to-be-freed pages and their
> buddies.
> 
> Test with will-it-scale/page_fault1 full load:
> 
> kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> v4.16-rc2+  9034215        7971818       13667135       15677465
> patch2/3    9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%
> this patch 10338868 +8.4%  8544477 +2.8% 14839808 +5.5% 17155464 +2.9%
> Note: this patch's performance improvement percent is against patch2/3.
> 
> ...
>
> @@ -1150,6 +1153,18 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  				continue;
>  
>  			list_add_tail(&page->lru, &head);
> +
> +			/*
> +			 * We are going to put the page back to the global
> +			 * pool, prefetch its buddy to speed up later access
> +			 * under zone->lock. It is believed the overhead of
> +			 * calculating buddy_pfn here can be offset by reduced
> +			 * memory latency later.
> +			 */
> +			pfn = page_to_pfn(page);
> +			buddy_pfn = __find_buddy_pfn(pfn, 0);
> +			buddy = page + (buddy_pfn - pfn);
> +			prefetch(buddy);

What is the typical list length here?  Maybe it's approximately the pcp
batch size which is typically 128 pages?

If so, I'm a bit surprised that it is effective to prefetch 128 page
frames before using any them for real.  I guess they'll fit in the L2
cache.   Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
