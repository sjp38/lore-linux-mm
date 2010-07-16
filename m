Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 937A46B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 06:12:53 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6GACmnO012719
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Jul 2010 19:12:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4126C3A62C2
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:12:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F80345DE51
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:12:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B63991DB801D
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:12:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 412811DB8015
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:12:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 0/7] memcg reclaim tracepoint
Message-Id: <20100716191006.7369.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Jul 2010 19:12:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Recently, Mel Gorman added some vmscan tracepoint. but they can't
trace memcg. So, This patch series does.


following three patches are nit fix and cleanups.

  memcg: sc.nr_to_reclaim should be initialized
  memcg: mem_cgroup_shrink_node_zone() doesn't need sc.nodemask
  memcg: nid and zid can be calculated from zone

following four patches are tracepoint conversion and adding memcg tracepoints.

  vmscan:        convert direct reclaim tracepoint to DEFINE_EVENT
  memcg, vmscan: add memcg reclaim tracepoint
  vmscan:        convert mm_vmscan_lru_isolate to DEFINE_EVENT
  memcg, vmscan: add mm_vmscan_memcg_isolate tracepoint


diffstat
================
 include/linux/memcontrol.h    |    6 ++--
 include/linux/mmzone.h        |    5 +++
 include/linux/swap.h          |    3 +-
 include/trace/events/vmscan.h |   79 +++++++++++++++++++++++++++++++++++++++--
 mm/memcontrol.c               |   15 +++++---
 mm/vmscan.c                   |   35 ++++++++++++------
 6 files changed, 118 insertions(+), 25 deletions(-)


Sameple output is here.
=========================

              dd-1851  [001]   158.837763: mm_vmscan_memcg_reclaim_begin: order=0 may_writepage=1 gfp_flags=GFP_HIGHUSER_MOVABLE
              dd-1851  [001]   158.837783: mm_vmscan_memcg_isolate: isolate_mode=0 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
              dd-1851  [001]   158.837860: mm_vmscan_memcg_reclaim_end: nr_reclaimed=32
  (...)
              dd-1970  [000]   266.608235: mm_vmscan_wakeup_kswapd: nid=0 zid=1 order=0
              dd-1970  [000]   266.608239: mm_vmscan_wakeup_kswapd: nid=1 zid=1 order=0
              dd-1970  [000]   266.608248: mm_vmscan_wakeup_kswapd: nid=2 zid=1 order=0
         kswapd1-348   [001]   266.608254: mm_vmscan_kswapd_wake: nid=1 order=0
              dd-1970  [000]   266.608254: mm_vmscan_wakeup_kswapd: nid=3 zid=1 order=0
         kswapd3-350   [000]   266.608266: mm_vmscan_kswapd_wake: nid=3 order=0
  (...)
         kswapd0-347   [001]   267.328891: mm_vmscan_memcg_softlimit_reclaim_begin: order=0 may_writepage=1 gfp_flags=GFP_HIGHUSER_MOVABLE
         kswapd0-347   [001]   267.328897: mm_vmscan_memcg_isolate: isolate_mode=0 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
         kswapd0-347   [001]   267.328915: mm_vmscan_memcg_isolate: isolate_mode=0 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
         kswapd0-347   [001]   267.328989: mm_vmscan_memcg_softlimit_reclaim_end: nr_reclaimed=32
         kswapd0-347   [001]   267.329019: mm_vmscan_lru_isolate: isolate_mode=1 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
         kswapd0-347   [001]   267.330562: mm_vmscan_lru_isolate: isolate_mode=1 order=0 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
  (...)
         kswapd2-349   [001]   267.407081: mm_vmscan_kswapd_sleep: nid=2
         kswapd3-350   [001]   267.408077: mm_vmscan_kswapd_sleep: nid=3
         kswapd1-348   [000]   267.427858: mm_vmscan_kswapd_sleep: nid=1
         kswapd0-347   [001]   267.430064: mm_vmscan_kswapd_sleep: nid=0





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
