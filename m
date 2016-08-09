Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26CA86B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 08:14:35 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id e141so8876119ybf.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 05:14:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 132si13084243qkf.152.2016.08.09.05.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 05:14:34 -0700 (PDT)
Date: Tue, 9 Aug 2016 14:14:22 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Message-ID: <20160809141422.4f98b072@redhat.com>
In-Reply-To: <20160808183428.GA87737@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
	<1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
	<1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160803174107.GA38399@ast-mbp.thefacebook.com>
	<20160804181913.26ee17b9@redhat.com>
	<1470381333.13693.48.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160808021525.GA81429@ast-mbp>
	<20160808100115.143d6ed3@redhat.com>
	<20160808183428.GA87737@ast-mbp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Rana Shahout <rana.shahot@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net, netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com, hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>, Daniel Borkmann <daniel@iogearbox.net>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>, brouer@redhat.com


> > On Sun, 7 Aug 2016 19:15:27 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
[...]
> > > could you please share the performance numbers for mlx5 order-0 vs order-N ?
> > > You mentioned that there was some performance improvement. We need to know
> > > how much we'll lose when we turn off order-N.  

There is an really easy way (after XDP) to benchmark this
order-0 vs order-N, for the driver mlx4.

I simply load a XDP program, that returns XDP_PASS, because loading XDP
will reallocate the RX rings to use a single frame/packet and order-0
pages (for RX ring slots).

Result summary: (order-3 pages) 4,453,022 -> (XDP_PASS) 3,295,798 pps
 * 3295798 - 4453022 = -1157224 pps slower
 * (3295798/4453022-1)*100 = -25.98% slower
 * (1/4453022-1/3295798)*10^9 - -78.85 nanosec slower
 * Approx convert nanosec to cycles (78.85 * 4GHz) = 315 cycles slower

Where does this performance regression originate from. Well, this
basically only changed the page allocation strategy and number of DMA
calls in the driver.  Thus, lets look at the performance of the page
allocator (see tool Page_bench_ and MM_slides_ page 9)

On this machine:
 * Cost of order-0: 237 cycles(tsc)  59.336 ns
 * Cost of order-3: 423 cycles(tsc) 106.029 ns

The order-3 cost is amortized, as it can store 21 frames of size 1536,
to cost per page-fragment 20 cycles / 5.049 ns. Thus, I would expect
to see a (59.336-5.049) 54.287 ns performance reduction, not 78.85,
which is 24.563 ns higher than expected (extra dma maps cannot explain
this on a Intel platform).

There is a higher percentage of L3/LLC-load-misses, which is strange,
as I though the simple XDP (inc map cnt and return XDP_PASS) program
should not touch the data.  Quick experiment with xdp-prog that touch
data like xdp1 and always return XDP_PASS, show 3209235 with is only
8ns slower ((1/3209235-1/3295798)*10^9 = 8.184 ns).  Thus, the extra
24ns (or 16ns) might originate from an earlier cache-miss.

Conclusion: These measurements confirm that we need a page recycle
facility for the drivers before switching to order-0 allocations.


Links:

.. _Page_bench: https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench01.c

.. _MM_slides: http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.odp



Benchmarking notes and perf results below:

Base setup:
 * Drop packets in iptables RAW
 * Disable Ethernet flow control
 * Disable GRO (changes driver code path)
 * Mlx4 NIC CX3-pro (mlx4_core log_num_mgm_entry_size=-2)
 * CPU: i7-4790K CPU @ 4.00GHz (turbostat report 4.3GHz)

Baseline: 4.7.0-baseline+ #102 SMP PREEMPT
 * instant rx:4558943 tx:0 pps n:162 average: rx:4453022 tx:0 pps
   (instant variation TX 0.000 ns (min:0.000 max:0.000) RX 5.217 ns)

Baseline perf stat::

 $ sudo perf stat -C3 -e L1-icache-load-misses -e cycles:k -e  instructions:k -e cache-misses:k -e   cache-references:k  -e LLC-store-misses:k -e LLC-store -e LLC-load-misses:k -e  LLC-load -r 5 sleep 1

Performance counter stats for 'CPU(s) 3' (5 runs) ::

       271,417  L1-icache-load-misses  ( +-  0.69% )  (33.32%)
 4,383,371,009  cycles:k               ( +-  0.01% )  (44.51%)
 7,587,502,193  instructions:k #  1.50  insns per cycle     (+- 0.01% )(55.62%)
     5,856,640  cache-misses:k # 48.435 % of all cache refs (+- 0.01% )(66.72%)
    12,091,854  cache-references:k                         ( +-  0.04%)(66.72%)
       451,681  LLC-store-misses                           ( +-  0.13%)(66.72%)
       463,152  LLC-store                                  ( +-  0.12%)(66.68%)
     5,408,934  LLC-load-misses # 47.26% of all LL-cache hits (0.01%) (22.19%)
    11,446,060  LLC-load                                 ( +-  0.04%) (22.19%)

 Samples: 40K of event 'cycles', Event count (approx.): 43956150960 ::
  Overhead  Command        Shared Object        Symbol
 +   36.59%  ksoftirqd/3    [kernel.vmlinux]     [k] memcpy_erms
 +    6.76%  ksoftirqd/3    [mlx4_en]            [k] mlx4_en_process_rx_cq
 +    6.66%  ksoftirqd/3    [ip_tables]          [k] ipt_do_table
 +    6.03%  ksoftirqd/3    [kernel.vmlinux]     [k] __build_skb
 +    4.65%  ksoftirqd/3    [kernel.vmlinux]     [k] ip_rcv
 +    4.22%  ksoftirqd/3    [mlx4_en]            [k] mlx4_en_prepare_rx_desc
 +    3.46%  ksoftirqd/3    [mlx4_en]            [k] mlx4_en_free_frag
 +    3.37%  ksoftirqd/3    [kernel.vmlinux]     [k] __netif_receive_skb_core
 +    3.04%  ksoftirqd/3    [kernel.vmlinux]     [k] __netdev_alloc_skb
 +    2.80%  ksoftirqd/3    [kernel.vmlinux]     [k] kmem_cache_alloc
 +    2.38%  ksoftirqd/3    [kernel.vmlinux]     [k] __free_page_frag
 +    1.88%  ksoftirqd/3    [kernel.vmlinux]     [k] kmem_cache_free
 +    1.65%  ksoftirqd/3    [kernel.vmlinux]     [k] nf_iterate
 +    1.59%  ksoftirqd/3    [kernel.vmlinux]     [k] nf_hook_slow
 +    1.31%  ksoftirqd/3    [kernel.vmlinux]     [k] __rcu_read_unlock
 +    0.91%  ksoftirqd/3    [kernel.vmlinux]     [k] __alloc_page_frag
 +    0.88%  ksoftirqd/3    [kernel.vmlinux]     [k] eth_type_trans
 +    0.77%  ksoftirqd/3    [kernel.vmlinux]     [k] dev_gro_receive
 +    0.76%  ksoftirqd/3    [kernel.vmlinux]     [k] skb_release_data
 +    0.76%  ksoftirqd/3    [kernel.vmlinux]     [k] __local_bh_enable_ip
 +    0.72%  ksoftirqd/3    [kernel.vmlinux]     [k] netif_receive_skb_internal
 +    0.66%  ksoftirqd/3    [kernel.vmlinux]     [k] napi_gro_receive
 +    0.66%  ksoftirqd/3    [kernel.vmlinux]     [k] __rcu_read_lock
 +    0.65%  ksoftirqd/3    [kernel.vmlinux]     [k] skb_release_head_state
 +    0.57%  ksoftirqd/3    [kernel.vmlinux]     [k] get_page_from_freelist
 +    0.57%  ksoftirqd/3    [kernel.vmlinux]     [k] __free_pages_ok
 +    0.51%  ksoftirqd/3    [kernel.vmlinux]     [k] kfree_skb
 +    0.43%  ksoftirqd/3    [kernel.vmlinux]     [k] skb_release_all

Result-xdp-pass: loading XDP_PASS program
 * instant rx:3374269 tx:0 pps n:537 average: rx:3295798 tx:0 pps
   (instant variation TX 0.000 ns (min:0.000 max:0.000) RX 7.056 ns)

Difference: 4,453,022 -> 3,295,798 pps
 * 3295798 - 4453022 = -1157224 pps slower
 * (3295798/4453022-1)*100 = -25.98% slower
 * (1/4453022-1/3295798)*10^9 - -78.85 nanosec slower

Perf stats xdp-pass::

  Performance counter stats for 'CPU(s) 3' (5 runs):

       294,219 L1-icache-load-misses  (+-0.25% )  (33.33%)
 4,382,764,897 cycles:k               (+-0.00% )  (44.51%)
 7,223,252,624 instructions:k #  1.65  insns per cycle     (+-0.00%)(55.62%)
     7,166,907 cache-misses:k # 58.792 % of all cache refs (+-0.01%)(66.72%)
    12,190,275 cache-references:k        (+-0.03% )  (66.72%)
       525,262 LLC-store-misses          (+-0.11% )  (66.72%)
       587,354 LLC-store                 (+-0.09% )  (66.68%)
     6,647,957 LLC-load-misses # 58.23% of all LL-cache hits (+-0.02%)(22.19%)
    11,417,001 LLC-load                                      (+-0.03%)(22.19%)

There is a higher percentage of L3/LLC-load-misses, which is strange,
as I though the simple XDP (return XDP_PASS and inc map cnt) program
would not touch the data.

Perf report xdp-pass::

 Samples: 40K of event 'cycles', Event count (approx.): 43953682891
   Overhead  Command        Shared Object     Symbol
 +   25.79%  ksoftirqd/3    [kernel.vmlinux]  [k] memcpy_erms
 +    7.29%  ksoftirqd/3    [mlx4_en]         [k] mlx4_en_process_rx_cq
 +    5.42%  ksoftirqd/3    [mlx4_en]         [k] mlx4_en_free_frag
 +    5.16%  ksoftirqd/3    [kernel.vmlinux]  [k] get_page_from_freelist
 +    4.55%  ksoftirqd/3    [ip_tables]       [k] ipt_do_table
 +    4.46%  ksoftirqd/3    [mlx4_en]         [k] mlx4_alloc_pages.isra.19
 +    3.97%  ksoftirqd/3    [kernel.vmlinux]  [k] __build_skb
 +    3.67%  ksoftirqd/3    [kernel.vmlinux]  [k] free_hot_cold_page
 +    3.46%  ksoftirqd/3    [kernel.vmlinux]  [k] ip_rcv
 +    2.71%  ksoftirqd/3    [kernel.vmlinux]  [k] __alloc_pages_nodemask
 +    2.62%  ksoftirqd/3    [kernel.vmlinux]  [k] __netif_receive_skb_core
 +    2.46%  ksoftirqd/3    [kernel.vmlinux]  [k] kmem_cache_alloc
 +    2.24%  ksoftirqd/3    [kernel.vmlinux]  [k] __netdev_alloc_skb
 +    2.15%  ksoftirqd/3    [mlx4_en]         [k] mlx4_en_prepare_rx_desc
 +    1.88%  ksoftirqd/3    [kernel.vmlinux]  [k] __free_page_frag
 +    1.55%  ksoftirqd/3    [kernel.vmlinux]  [k] kmem_cache_free
 +    1.42%  ksoftirqd/3    [kernel.vmlinux]  [k] __rcu_read_unlock
 +    1.27%  ksoftirqd/3    [kernel.vmlinux]  [k] nf_iterate
 +    1.14%  ksoftirqd/3    [kernel.vmlinux]  [k] nf_hook_slow
 +    1.05%  ksoftirqd/3    [kernel.vmlinux]  [k] alloc_pages_current
 +    0.83%  ksoftirqd/3    [kernel.vmlinux]  [k] __inc_zone_state
 +    0.73%  ksoftirqd/3    [kernel.vmlinux]  [k] __list_del_entry
 +    0.69%  ksoftirqd/3    [kernel.vmlinux]  [k] __list_add
 +    0.64%  ksoftirqd/3    [kernel.vmlinux]  [k] __local_bh_enable_ip
 +    0.64%  ksoftirqd/3    [kernel.vmlinux]  [k] __rcu_read_lock
 +    0.62%  ksoftirqd/3    [kernel.vmlinux]  [k] dev_gro_receive
 +    0.62%  ksoftirqd/3    [kernel.vmlinux]  [k] swiotlb_map_page
 +    0.61%  ksoftirqd/3    [kernel.vmlinux]  [k] skb_release_data
 +    0.60%  ksoftirqd/3    [kernel.vmlinux]  [k] __alloc_page_frag
 +    0.58%  ksoftirqd/3    [kernel.vmlinux]  [k] eth_type_trans
 +    0.57%  ksoftirqd/3    [kernel.vmlinux]  [k] policy_zonelist
 +    0.51%  ksoftirqd/3    [pps_core]        [k] 0x000000000000692d
 +    0.51%  ksoftirqd/3    [kernel.vmlinux]  [k] netif_receive_skb_internal
 +    0.50%  ksoftirqd/3    [kernel.vmlinux]  [k] napi_gro_receive
 +    0.49%  ksoftirqd/3    [kernel.vmlinux]  [k] __put_page
 +    0.49%  ksoftirqd/3    [kernel.vmlinux]  [k] skb_release_head_state
 +    0.42%  ksoftirqd/3    [kernel.vmlinux]  [k] kfree_skb
 +    0.34%  ksoftirqd/3    [pps_core]        [k] 0x0000000000006935
 +    0.33%  ksoftirqd/3    [kernel.vmlinux]  [k] skb_free_head
 +    0.32%  ksoftirqd/3    [kernel.vmlinux]  [k] __netif_receive_skb
 +    0.31%  ksoftirqd/3    [kernel.vmlinux]  [k] swiotlb_sync_single
 +    0.31%  ksoftirqd/3    [kernel.vmlinux]  [k] skb_gro_reset_offset
 +    0.29%  ksoftirqd/3    [kernel.vmlinux]  [k] swiotlb_sync_single_for_cpu
 +    0.29%  ksoftirqd/3    [kernel.vmlinux]  [k] list_del
 +    0.27%  ksoftirqd/3    [iptable_raw]     [k] iptable_raw_hook
 +    0.27%  ksoftirqd/3    [kernel.vmlinux]  [k] skb_release_all
 +    0.26%  ksoftirqd/3    [kernel.vmlinux]  [k] kfree_skbmem
 +    0.25%  ksoftirqd/3    [kernel.vmlinux]  [k] swiotlb_unmap_page
 +    0.23%  ksoftirqd/3    [kernel.vmlinux]  [k] bpf_map_lookup_elem
 +    0.22%  ksoftirqd/3    [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
 +    0.20%  ksoftirqd/3    [kernel.vmlinux]  [k] __page_cache_release

In perf-diff notice the increase for:
 * get_page_from_freelist(0.57%) +4.59%,
 * mlx4_en_free_frag     (3.46%) +1.96%,
 * mlx4_alloc_pages      (0.26%) +4.20%
 * __alloc_pages_nodemask(0.14%) +2.57%
 * swiotlb_map_page      (0.04%) +0.57%

Perf diff::

 # Baseline    Delta  Shared Object        Symbol
 # ........  .......  ...................  ................................
 #
    36.59%  -10.80%  [kernel.vmlinux]     [k] memcpy_erms
     6.76%   +0.53%  [mlx4_en]            [k] mlx4_en_process_rx_cq
     6.66%   -2.11%  [ip_tables]          [k] ipt_do_table
     6.03%   -2.06%  [kernel.vmlinux]     [k] __build_skb
     4.65%   -1.18%  [kernel.vmlinux]     [k] ip_rcv
     4.22%   -2.06%  [mlx4_en]            [k] mlx4_en_prepare_rx_desc
     3.46%   +1.96%  [mlx4_en]            [k] mlx4_en_free_frag
     3.37%   -0.75%  [kernel.vmlinux]     [k] __netif_receive_skb_core
     3.04%   -0.80%  [kernel.vmlinux]     [k] __netdev_alloc_skb
     2.80%   -0.34%  [kernel.vmlinux]     [k] kmem_cache_alloc
     2.38%   -0.50%  [kernel.vmlinux]     [k] __free_page_frag
     1.88%   -0.34%  [kernel.vmlinux]     [k] kmem_cache_free
     1.65%   -0.38%  [kernel.vmlinux]     [k] nf_iterate
     1.59%   -0.45%  [kernel.vmlinux]     [k] nf_hook_slow
     1.31%   +0.11%  [kernel.vmlinux]     [k] __rcu_read_unlock
     0.91%   -0.31%  [kernel.vmlinux]     [k] __alloc_page_frag
     0.88%   -0.30%  [kernel.vmlinux]     [k] eth_type_trans
     0.77%   -0.15%  [kernel.vmlinux]     [k] dev_gro_receive
     0.76%   -0.15%  [kernel.vmlinux]     [k] skb_release_data
     0.76%   -0.12%  [kernel.vmlinux]     [k] __local_bh_enable_ip
     0.72%   -0.21%  [kernel.vmlinux]     [k] netif_receive_skb_internal
     0.66%   -0.16%  [kernel.vmlinux]     [k] napi_gro_receive
     0.66%   -0.02%  [kernel.vmlinux]     [k] __rcu_read_lock
     0.65%   -0.17%  [kernel.vmlinux]     [k] skb_release_head_state
     0.57%   +4.59%  [kernel.vmlinux]     [k] get_page_from_freelist
     0.57%           [kernel.vmlinux]     [k] __free_pages_ok
     0.51%   -0.09%  [kernel.vmlinux]     [k] kfree_skb
     0.43%   -0.15%  [kernel.vmlinux]     [k] skb_release_all
     0.42%   -0.11%  [kernel.vmlinux]     [k] skb_gro_reset_offset
     0.41%   -0.08%  [kernel.vmlinux]     [k] skb_free_head
     0.39%   -0.07%  [kernel.vmlinux]     [k] __netif_receive_skb
     0.36%   -0.08%  [iptable_raw]        [k] iptable_raw_hook
     0.34%   -0.08%  [kernel.vmlinux]     [k] kfree_skbmem
     0.28%   +0.01%  [kernel.vmlinux]     [k] swiotlb_sync_single_for_cpu
     0.26%   +4.20%  [mlx4_en]            [k] mlx4_alloc_pages.isra.19
     0.20%   +0.11%  [kernel.vmlinux]     [k] swiotlb_sync_single
     0.15%   -0.03%  [kernel.vmlinux]     [k] __do_softirq
     0.14%   +2.57%  [kernel.vmlinux]     [k] __alloc_pages_nodemask
     0.14%           [kernel.vmlinux]     [k] free_one_page
     0.13%   -0.13%  [kernel.vmlinux]     [k] _raw_spin_lock_irqsave
     0.13%   -0.12%  [kernel.vmlinux]     [k] _raw_spin_lock
     0.10%           [kernel.vmlinux]     [k] __mod_zone_page_state
     0.09%   +0.06%  [kernel.vmlinux]     [k] net_rx_action
     0.09%           [kernel.vmlinux]     [k] __rmqueue
     0.07%           [kernel.vmlinux]     [k] __zone_watermark_ok
     0.07%           [kernel.vmlinux]     [k] PageHuge
     0.06%   +0.77%  [kernel.vmlinux]     [k] __inc_zone_state
     0.76%   -0.15%  [kernel.vmlinux]     [k] skb_release_data
     0.76%   -0.12%  [kernel.vmlinux]     [k] __local_bh_enable_ip
     0.72%   -0.21%  [kernel.vmlinux]     [k] netif_receive_skb_internal
     0.66%   -0.16%  [kernel.vmlinux]     [k] napi_gro_receive
     0.66%   -0.02%  [kernel.vmlinux]     [k] __rcu_read_lock
     0.65%   -0.17%  [kernel.vmlinux]     [k] skb_release_head_state
     0.57%   +4.59%  [kernel.vmlinux]     [k] get_page_from_freelist
     0.57%           [kernel.vmlinux]     [k] __free_pages_ok
     0.51%   -0.09%  [kernel.vmlinux]     [k] kfree_skb
     0.43%   -0.15%  [kernel.vmlinux]     [k] skb_release_all
     0.42%   -0.11%  [kernel.vmlinux]     [k] skb_gro_reset_offset
     0.41%   -0.08%  [kernel.vmlinux]     [k] skb_free_head
     0.39%   -0.07%  [kernel.vmlinux]     [k] __netif_receive_skb
     0.36%   -0.08%  [iptable_raw]        [k] iptable_raw_hook
     0.34%   -0.08%  [kernel.vmlinux]     [k] kfree_skbmem
     0.28%   +0.01%  [kernel.vmlinux]     [k] swiotlb_sync_single_for_cpu
     0.26%   +4.20%  [mlx4_en]            [k] mlx4_alloc_pages.isra.19
     0.20%   +0.11%  [kernel.vmlinux]     [k] swiotlb_sync_single
     0.15%   -0.03%  [kernel.vmlinux]     [k] __do_softirq
     0.14%   +2.57%  [kernel.vmlinux]     [k] __alloc_pages_nodemask
     0.14%           [kernel.vmlinux]     [k] free_one_page
     0.13%   -0.13%  [kernel.vmlinux]     [k] _raw_spin_lock_irqsave
     0.13%   -0.12%  [kernel.vmlinux]     [k] _raw_spin_lock
     0.10%           [kernel.vmlinux]     [k] __mod_zone_page_state
     0.09%   +0.06%  [kernel.vmlinux]     [k] net_rx_action
     0.09%           [kernel.vmlinux]     [k] __rmqueue
     0.07%           [kernel.vmlinux]     [k] __zone_watermark_ok
     0.07%           [kernel.vmlinux]     [k] PageHuge
     0.06%   +0.77%  [kernel.vmlinux]     [k] __inc_zone_state
     0.06%   +0.98%  [kernel.vmlinux]     [k] alloc_pages_current
     0.06%   +0.51%  [kernel.vmlinux]     [k] policy_zonelist
     0.06%   +0.01%  [kernel.vmlinux]     [k] delay_tsc
     0.05%   -0.00%  [mlx4_en]            [k] mlx4_en_poll_rx_cq
     0.05%   +0.01%  [kernel.vmlinux]     [k] __memcpy
     0.04%   +0.57%  [kernel.vmlinux]     [k] swiotlb_map_page
     0.04%   +0.69%  [kernel.vmlinux]     [k] __list_del_entry
     0.04%           [kernel.vmlinux]     [k] free_compound_page
     0.04%           [kernel.vmlinux]     [k] __put_compound_page
     0.03%   +0.66%  [kernel.vmlinux]     [k] __list_add



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
