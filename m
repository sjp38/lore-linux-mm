Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3F0756B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 02:15:44 -0400 (EDT)
Date: Sat, 15 Aug 2009 13:45:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090815054524.GB11387@localhost>
References: <20090813010356.GA7619@localhost> <4A843565.3010104@redhat.com> <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com> <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org> <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org> <20090814095106.GA3345@localhost> <4A856467.6050102@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A856467.6050102@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 09:19:35PM +0800, Rik van Riel wrote:
> Wu Fengguang wrote:
> > On Fri, Aug 14, 2009 at 05:10:55PM +0800, Johannes Weiner wrote:
> 
> >> So even with the active list being a FIFO, we keep usage information
> >> gathered from the inactive list.  If we deactivate pages in arbitrary
> >> list intervals, we throw this away.
> > 
> > We do have the danger of FIFO, if inactive list is small enough, so
> > that (unconditionally) deactivated pages quickly get reclaimed and
> > their life window in inactive list is too small to be useful.
> 
> This one of the reasons why we unconditionally deactivate
> the active anon pages, and do background scanning of the
> active anon list when reclaiming page cache pages.
> 
> We want to always move some pages to the inactive anon
> list, so it does not get too small.

Right, the current code tries to pull inactive list out of
smallish-size state as long as there are vmscan activities.

However there is a possible (and tricky) hole: mem cgroups
don't do batched vmscan. shrink_zone() may call shrink_list()
with nr_to_scan=1, in which case shrink_list() _still_ calls
isolate_pages() with the much larger SWAP_CLUSTER_MAX.

It effectively scales up the inactive list scan rate by 10 times when
it is still small, and may thus prevent it from growing up for ever.

In that case, LRU becomes FIFO.

Jeff, can you confirm if the mem cgroup's inactive list is small?
If so, this patch should help.

Thanks,
Fengguang
---

mm: do batched scans for mem_cgroup

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/memcontrol.h |    3 +++
 mm/memcontrol.c            |   12 ++++++++++++
 mm/vmscan.c                |    9 +++++----
 3 files changed, 20 insertions(+), 4 deletions(-)

--- linux.orig/include/linux/memcontrol.h	2009-08-15 13:12:49.000000000 +0800
+++ linux/include/linux/memcontrol.h	2009-08-15 13:18:13.000000000 +0800
@@ -98,6 +98,9 @@ int mem_cgroup_inactive_file_is_low(stru
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
+unsigned long *mem_cgroup_get_saved_scan(struct mem_cgroup *memcg,
+					 struct zone *zone,
+					 enum lru_list lru);
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
--- linux.orig/mm/memcontrol.c	2009-08-15 13:07:34.000000000 +0800
+++ linux/mm/memcontrol.c	2009-08-15 13:17:56.000000000 +0800
@@ -115,6 +115,7 @@ struct mem_cgroup_per_zone {
 	 */
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
+	unsigned long		nr_saved_scan[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
 };
@@ -597,6 +598,17 @@ unsigned long mem_cgroup_zone_nr_pages(s
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
+unsigned long *mem_cgroup_get_saved_scan(struct mem_cgroup *memcg,
+					 struct zone *zone,
+					 enum lru_list lru)
+{
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+
+	return &mz->nr_saved_scan[lru];
+}
+
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
--- linux.orig/mm/vmscan.c	2009-08-15 13:04:54.000000000 +0800
+++ linux/mm/vmscan.c	2009-08-15 13:19:03.000000000 +0800
@@ -1534,6 +1534,7 @@ static void shrink_zone(int priority, st
 	for_each_evictable_lru(l) {
 		int file = is_file_lru(l);
 		unsigned long scan;
+		unsigned long *saved_scan;
 
 		scan = zone_nr_pages(zone, sc, l);
 		if (priority || noswap) {
@@ -1541,11 +1542,11 @@ static void shrink_zone(int priority, st
 			scan = (scan * percent[file]) / 100;
 		}
 		if (scanning_global_lru(sc))
-			nr[l] = nr_scan_try_batch(scan,
-						  &zone->lru[l].nr_saved_scan,
-						  swap_cluster_max);
+			saved_scan = &zone->lru[l].nr_saved_scan;
 		else
-			nr[l] = scan;
+			saved_scan = mem_cgroup_get_saved_scan(sc->mem_cgroup,
+							       zone, l);
+		nr[l] = nr_scan_try_batch(scan, saved_scan, swap_cluster_max);
 	}
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
