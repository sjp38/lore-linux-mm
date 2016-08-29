Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44DE0830E7
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:39:42 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so293145216pfd.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 02:39:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 27si38294212pfn.124.2016.08.29.02.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 02:39:41 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7T9decQ050353
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:39:40 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2533rktbn3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:39:40 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 19:38:52 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id BDC972CE8046
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 19:38:49 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7T9cnrJ2818452
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 19:38:49 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7T9cmnF009830
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 19:38:49 +1000
Date: Mon, 29 Aug 2016 15:08:44 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 07/34] mm, vmscan: make kswapd reclaim in terms of nodes
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
Message-Id: <20160829093844.GA2592@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>

> Patch "mm: vmscan: Begin reclaiming pages on a per-node basis" started
> thinking of reclaim in terms of nodes but kswapd is still zone-centric. This
> patch gets rid of many of the node-based versus zone-based decisions.
> 
> o A node is considered balanced when any eligible lower zone is balanced.
>   This eliminates one class of age-inversion problem because we avoid
>   reclaiming a newer page just because it's in the wrong zone
> o pgdat_balanced disappears because we now only care about one zone being
>   balanced.
> o Some anomalies related to writeback and congestion tracking being based on
>   zones disappear.
> o kswapd no longer has to take care to reclaim zones in the reverse order
>   that the page allocator uses.
> o Most importantly of all, reclaim from node 0 with multiple zones will
>   have similar aging and reclaiming characteristics as every
>   other node.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

This patch seems to hurt FA_DUMP functionality. This behaviour is not
seen on v4.7 but only after this patch.

So when a kernel on a multinode machine with memblock_reserve() such
that most of the nodes have zero available memory, kswapd seems to be
consuming 100% of the time.

This is independent of CONFIG_DEFERRED_STRUCT_PAGE, i.e this problem is
seen even with parallel page struct initialization disabled.


top - 13:48:52 up  1:07,  3 users,  load average: 15.25, 15.32, 21.18
Tasks: 11080 total,  16 running, 11064 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  2.7 sy,  0.0 ni, 97.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:  15929941+total,  8637824 used, 15843563+free,     2304 buffers
KiB Swap: 91898816 total,        0 used, 91898816 free.  1381312 cached Mem

    PID USER      PR  NI    VIRT    RES    SHR S     %CPU  %MEM     TIME+ COMMAND
  10824 root      20   0       0      0      0 R  100.000 0.000  65:30.76 kswapd2
  10837 root      20   0       0      0      0 R  100.000 0.000  65:31.17 kswapd15
  10823 root      20   0       0      0      0 R   97.059 0.000  65:30.85 kswapd1
  10825 root      20   0       0      0      0 R   97.059 0.000  65:31.10 kswapd3
  10826 root      20   0       0      0      0 R   97.059 0.000  65:31.18 kswapd4
  10827 root      20   0       0      0      0 R   97.059 0.000  65:31.08 kswapd5
  10828 root      20   0       0      0      0 R   97.059 0.000  65:30.91 kswapd6
  10829 root      20   0       0      0      0 R   97.059 0.000  65:31.17 kswapd7
  10830 root      20   0       0      0      0 R   97.059 0.000  65:31.17 kswapd8
  10831 root      20   0       0      0      0 R   97.059 0.000  65:31.18 kswapd9
  10832 root      20   0       0      0      0 R   97.059 0.000  65:31.12 kswapd10
  10833 root      20   0       0      0      0 R   97.059 0.000  65:31.19 kswapd11
  10834 root      20   0       0      0      0 R   97.059 0.000  65:31.13 kswapd12
  10835 root      20   0       0      0      0 R   97.059 0.000  65:31.09 kswapd13
  10836 root      20   0       0      0      0 R   97.059 0.000  65:31.18 kswapd14
 277155 srikar    20   0   16960  13760   3264 R   52.941 0.001   0:00.37 top

top - 13:48:55 up  1:07,  3 users,  load average: 15.23, 15.32, 21.15
Tasks: 11080 total,  16 running, 11064 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  1.0 sy,  0.0 ni, 99.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:  15929941+total,  8637824 used, 15843563+free,     2304 buffers
KiB Swap: 91898816 total,        0 used, 91898816 free.  1381312 cached Mem

    PID USER      PR  NI    VIRT    RES    SHR S     %CPU  %MEM     TIME+ COMMAND
  10836 root      20   0       0      0      0 R  100.000 0.000  65:33.39 kswapd14
  10823 root      20   0       0      0      0 R  100.000 0.000  65:33.05 kswapd1
  10824 root      20   0       0      0      0 R  100.000 0.000  65:32.96 kswapd2
  10825 root      20   0       0      0      0 R  100.000 0.000  65:33.30 kswapd3
  10826 root      20   0       0      0      0 R  100.000 0.000  65:33.38 kswapd4
  10827 root      20   0       0      0      0 R  100.000 0.000  65:33.28 kswapd5
  10828 root      20   0       0      0      0 R  100.000 0.000  65:33.11 kswapd6
  10829 root      20   0       0      0      0 R  100.000 0.000  65:33.37 kswapd7
  10830 root      20   0       0      0      0 R  100.000 0.000  65:33.37 kswapd8
  10831 root      20   0       0      0      0 R  100.000 0.000  65:33.38 kswapd9
  10832 root      20   0       0      0      0 R  100.000 0.000  65:33.32 kswapd10
  10833 root      20   0       0      0      0 R  100.000 0.000  65:33.39 kswapd11
  10834 root      20   0       0      0      0 R  100.000 0.000  65:33.33 kswapd12
  10835 root      20   0       0      0      0 R  100.000 0.000  65:33.29 kswapd13
  10837 root      20   0       0      0      0 R  100.000 0.000  65:33.37 kswapd15
 277155 srikar    20   0   17536  14912   3264 R    9.091 0.001   0:00.57 top
   1092 root      rt   0       0      0      0 S    0.455 0.000   0:00.08 watchdog/178

Please see that there is no used swap space. However 15 kswapd threads
corresponding to 15 out of the 16 nodes are running full throttle.  The
only node 0 has memory, other nodes memory is fully reserved.

git bisect output
I tried git bisect between v4.7 and v4.8-rc3 filtered to mm/vmscan.c

# bad: [d7f05528eedb047efe2288cff777676b028747b6] mm, vmscan: account for skipped pages as a partial scan
# good: [b1123ea6d3b3da25af5c8a9d843bd07ab63213f4] mm: balloon: use general non-lru movable page feature
git bisect start 'HEAD' 'b1123ea6' '--' 'mm/vmscan.c'
# bad: [c4a25635b60d08853a3e4eaae3ab34419a36cfa2] mm: move vmscan writes and file write accounting to the node
git bisect bad c4a25635b60d08853a3e4eaae3ab34419a36cfa2
# bad: [38087d9b0360987a6db46c2c2c4ece37cd048abe] mm, vmscan: simplify the logic deciding whether kswapd sleeps
git bisect bad 38087d9b0360987a6db46c2c2c4ece37cd048abe
# good: [b2e18757f2c9d1cdd746a882e9878852fdec9501] mm, vmscan: begin reclaiming pages on a per-node basis
git bisect good b2e18757f2c9d1cdd746a882e9878852fdec9501
# bad: [1d82de618ddde0f1164e640f79af152f01994c18] mm, vmscan: make kswapd reclaim in terms of nodes
git bisect bad 1d82de618ddde0f1164e640f79af152f01994c18
# good: [f7b60926ebc05944f73d93ffaf6690503b796a88] mm, vmscan: have kswapd only scan based on the highest requested zone
git bisect good f7b60926ebc05944f73d93ffaf6690503b796a88
# first bad commit: [1d82de618ddde0f1164e640f79af152f01994c18] mm, vmscan: make kswapd reclaim in terms of nodes

Here is perf top output on the kernel where kswapd is hogging cpu.

-   93.50%     0.01%  [kernel]                 [k] kswapd
   - kswapd
      - 114.31% shrink_node
         - 111.51% shrink_node_memcg
            - pgdat_reclaimable
               - 95.51% pgdat_reclaimable_pages
                  - 86.34% pgdat_reclaimable_pages
                  - 6.69% _find_next_bit.part.0
                  - 2.47% find_next_bit
               - 14.46% pgdat_reclaimable
                 1.13% _find_next_bit.part.0
               + 0.30% find_next_bit
         - 2.38% shrink_slab
            - super_cache_count
               - 0
                  - __list_lru_count_one.isra.1
                       _raw_spin_lock
      - 28.04% pgdat_reclaimable
         - 23.97% pgdat_reclaimable_pages
            - 21.66% pgdat_reclaimable_pages
            - 1.69% _find_next_bit.part.0
              0.63% find_next_bit
         - 3.70% pgdat_reclaimable
           0.29% _find_next_bit.part.0
      - 16.33% zone_balanced
         - zone_watermark_ok_safe
            - 14.86% zone_watermark_ok_safe
              1.15% _find_next_bit.part.0
              0.31% find_next_bit
      - 2.72% prepare_kswapd_sleep
         - zone_balanced
            - zone_watermark_ok_safe
                 zone_watermark_ok_safe
-   80.72%    10.51%  [kernel]                 [k] pgdat_reclaimable
   - 140.49% pgdat_reclaimable
      - 138.40% pgdat_reclaimable_pages
         - 125.10% pgdat_reclaimable_pages
         - 9.71% _find_next_bit.part.0
         - 3.59% find_next_bit
        1.64% _find_next_bit.part.0
      + 0.44% find_next_bit
   - 21.03% ret_from_kernel_thread
        kthread
      - kswapd
         - 16.75% shrink_node
              shrink_node_memcg
         - 4.28% pgdat_reclaimable
              pgdat_reclaimable
-   69.17%    62.48%  [kernel]                 [k] pgdat_reclaimable_pages
   - 145.91% ret_from_kernel_thread
        kthread
   - 15.61% pgdat_reclaimable_pages
      - 11.33% _find_next_bit.part.0
      - 4.19% find_next_bit
-   66.18%     0.01%  [kernel]                 [k] shrink_node
   - shrink_node
      - 157.54% shrink_node_memcg
         - pgdat_reclaimable
            - 134.94% pgdat_reclaimable_pages
               - 121.99% pgdat_reclaimable_pages
               - 9.46% _find_next_bit.part.0
               - 3.49% find_next_bit
            - 20.44% pgdat_reclaimable
              1.59% _find_next_bit.part.0
            + 0.42% find_next_bit
      - 3.37% shrink_slab
         - super_cache_count
            - 0
               - __list_lru_count_one.isra.1
                    _raw_spin_lock
-   64.56%     0.03%  [kernel]                 [k] shrink_node_memcg
   - shrink_node_memcg
      - pgdat_reclaimable
         - 138.31% pgdat_reclaimable_pages
            - 125.04% pgdat_reclaimable_pages
            - 9.69% _find_next_bit.part.0
            - 3.58% find_next_bit
         - 20.95% pgdat_reclaimable
           1.63% _find_next_bit.part.0
         + 0.43% find_next_bit
    53.73%     0.00%  [kernel]                 [k] kthread
    53.73%     0.00%  [kernel]                 [k] ret_from_kernel_thread
-   11.04%    10.04%  [kernel]                 [k] zone_watermark_ok_safe
   - 146.80% ret_from_kernel_thread
        kthread
      - kswapd
         - 125.81% zone_balanced
              zone_watermark_ok_safe
         - 20.97% prepare_kswapd_sleep
              zone_balanced
              zone_watermark_ok_safe
   - 14.55% zone_watermark_ok_safe
        11.38% _find_next_bit.part.0
        3.06% find_next_bit
-   11.03%     0.00%  [kernel]                 [k] zone_balanced
   - zone_balanced
      - zone_watermark_ok_safe
           145.84% zone_watermark_ok_safe
           11.31% _find_next_bit.part.0
           3.04% find_next_bit


-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
