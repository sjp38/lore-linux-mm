Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 82F616B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 00:00:18 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6M3qKVV005186
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 21:52:20 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o6M40EdS129752
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:00:15 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6M40DbO001480
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:00:14 -0600
Date: Thu, 22 Jul 2010 09:30:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/7] memcg reclaim tracepoint
Message-ID: <20100722040007.GJ14369@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100716191006.7369.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100716191006.7369.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-07-16 19:12:46]:

> Recently, Mel Gorman added some vmscan tracepoint. but they can't
> trace memcg. So, This patch series does.
> 
> 
> following three patches are nit fix and cleanups.
> 
>   memcg: sc.nr_to_reclaim should be initialized
>   memcg: mem_cgroup_shrink_node_zone() doesn't need sc.nodemask
>   memcg: nid and zid can be calculated from zone
> 
> following four patches are tracepoint conversion and adding memcg tracepoints.
> 
>   vmscan:        convert direct reclaim tracepoint to DEFINE_EVENT
>   memcg, vmscan: add memcg reclaim tracepoint
>   vmscan:        convert mm_vmscan_lru_isolate to DEFINE_EVENT
>   memcg, vmscan: add mm_vmscan_memcg_isolate tracepoint
> 
> 
> diffstat
> ================
>  include/linux/memcontrol.h    |    6 ++--
>  include/linux/mmzone.h        |    5 +++
>  include/linux/swap.h          |    3 +-
>  include/trace/events/vmscan.h |   79 +++++++++++++++++++++++++++++++++++++++--
>  mm/memcontrol.c               |   15 +++++---
>  mm/vmscan.c                   |   35 ++++++++++++------
>  6 files changed, 118 insertions(+), 25 deletions(-)
> 
> 
> Sameple output is here.
> =========================
> 
>               dd-1851  [001]   158.837763: mm_vmscan_memcg_reclaim_begin: order=0 may_writepage=1 gfp_flags=GFP_HIGHUSER_MOVABLE
>               dd-1851  [001]   158.837783: mm_vmscan_memcg_isolate: isolate_mode=0 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>               dd-1851  [001]   158.837860: mm_vmscan_memcg_reclaim_end: nr_reclaimed=32
>   (...)
>               dd-1970  [000]   266.608235: mm_vmscan_wakeup_kswapd: nid=0 zid=1 order=0
>               dd-1970  [000]   266.608239: mm_vmscan_wakeup_kswapd: nid=1 zid=1 order=0
>               dd-1970  [000]   266.608248: mm_vmscan_wakeup_kswapd: nid=2 zid=1 order=0
>          kswapd1-348   [001]   266.608254: mm_vmscan_kswapd_wake: nid=1 order=0
>               dd-1970  [000]   266.608254: mm_vmscan_wakeup_kswapd: nid=3 zid=1 order=0
>          kswapd3-350   [000]   266.608266: mm_vmscan_kswapd_wake: nid=3 order=0
>   (...)
>          kswapd0-347   [001]   267.328891: mm_vmscan_memcg_softlimit_reclaim_begin: order=0 may_writepage=1 gfp_flags=GFP_HIGHUSER_MOVABLE
>          kswapd0-347   [001]   267.328897: mm_vmscan_memcg_isolate: isolate_mode=0 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>          kswapd0-347   [001]   267.328915: mm_vmscan_memcg_isolate: isolate_mode=0 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>          kswapd0-347   [001]   267.328989: mm_vmscan_memcg_softlimit_reclaim_end: nr_reclaimed=32
>          kswapd0-347   [001]   267.329019: mm_vmscan_lru_isolate: isolate_mode=1 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>          kswapd0-347   [001]   267.330562: mm_vmscan_lru_isolate: isolate_mode=1 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>   (...)
>          kswapd2-349   [001]   267.407081: mm_vmscan_kswapd_sleep: nid=2
>          kswapd3-350   [001]   267.408077: mm_vmscan_kswapd_sleep: nid=3
>          kswapd1-348   [000]   267.427858: mm_vmscan_kswapd_sleep: nid=1
>          kswapd0-347   [001]   267.430064: mm_vmscan_kswapd_sleep: nid=0
>

This looks interesting, but I think I need to look deeper to see how
the name like mm_vmscan_memcg_softlimit_reclaim_begin is generated. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
