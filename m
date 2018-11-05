Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE09E6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 05:47:05 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id d8-v6so6285818wmb.5
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 02:47:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4-v6sor13277226wmd.21.2018.11.05.02.47.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 02:47:04 -0800 (PST)
Date: Mon, 5 Nov 2018 12:46:59 +0200
From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in
 page_frag_free()
Message-ID: <20181105104659.GA5347@apalos>
References: <20181105085820.6341-1-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181105085820.6341-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>

Hi Aaron,
> page_frag_free() calls __free_pages_ok() to free the page back to
> Buddy. This is OK for high order page, but for order-0 pages, it
> misses the optimization opportunity of using Per-Cpu-Pages and can
> cause zone lock contention when called frequently.
> 
> PaweA? Staszewski recently shared his result of 'how Linux kernel
> handles normal traffic'[1] and from perf data, Jesper Dangaard Brouer
> found the lock contention comes from page allocator:
> 
>   mlx5e_poll_tx_cq
>   |
>    --16.34%--napi_consume_skb
>              |
>              |--12.65%--__free_pages_ok
>              |          |
>              |           --11.86%--free_one_page
>              |                     |
>              |                     |--10.10%--queued_spin_lock_slowpath
>              |                     |
>              |                      --0.65%--_raw_spin_lock
>              |
>              |--1.55%--page_frag_free
>              |
>               --1.44%--skb_release_data
> 
> Jesper explained how it happened: mlx5 driver RX-page recycle
> mechanism is not effective in this workload and pages have to go
> through the page allocator. The lock contention happens during
> mlx5 DMA TX completion cycle. And the page allocator cannot keep
> up at these speeds.[2]
> 
> I thought that __free_pages_ok() are mostly freeing high order
> pages and thought this is an lock contention for high order pages
> but Jesper explained in detail that __free_pages_ok() here are
> actually freeing order-0 pages because mlx5 is using order-0 pages
> to satisfy its page pool allocation request.[3]
> 
> The free path as pointed out by Jesper is:
> skb_free_head()
>   -> skb_free_frag()
>     -> skb_free_frag()
>       -> page_frag_free()
> And the pages being freed on this path are order-0 pages.
> 
> Fix this by doing similar things as in __page_frag_cache_drain() -
> send the being freed page to PCP if it's an order-0 page, or
> directly to Buddy if it is a high order page.
> 
> With this change, PaweA? hasn't noticed lock contention yet in
> his workload and Jesper has noticed a 7% performance improvement
> using a micro benchmark and lock contention is gone.
I did the same tests on a 'low' speed 1Gbit interface on an cortex-a53.
I used socionext's netsec driver and switched buffer allocation from the 
current scheme to using page_pool API (which by default allocates order0 
pages).

Running 'perf top' pre and post patch got me the same results.
__free_pages_ok() disappeared from perf top and i got an ~11% 
performance boost testing with 64byte packets.

Acked-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Tested-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
