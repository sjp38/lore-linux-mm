Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8D55B900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:15:09 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8328F3EE0BC
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:15:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 599AA45DE98
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:15:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41DC245DE95
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:15:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F29AE08003
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:15:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DBF56E08004
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:15:04 +0900 (JST)
Date: Tue, 26 Apr 2011 14:08:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] memcg bgreclaim core.
Message-Id: <20110426140815.8847062b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinn5Cs8F5beX6od41xhH4qQuRR5Rw@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinn5Cs8F5beX6od41xhH4qQuRR5Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Mon, 25 Apr 2011 21:59:06 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Apr 25, 2011 at 2:36 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Following patch will chagnge the logic. This is a core.
> > ==
> > This is the main loop of per-memcg background reclaim which is implemented in
> > function balance_mem_cgroup_pgdat().
> >
> > The function performs a priority loop similar to global reclaim. During each
> > iteration it frees memory from a selected victim node.
> > After reclaiming enough pages or scanning enough pages, it returns and find
> > next work with round-robin.
> >
> > changelog v8b..v7
> > 1. reworked for using work_queue rather than threads.
> > 2. changed shrink_mem_cgroup algorithm to fit workqueue. In short, avoid
> > A  long running and allow quick round-robin and unnecessary write page.
> > A  When a thread make pages dirty continuously, write back them by flusher
> > A  is far faster than writeback by background reclaim. This detail will
> > A  be fixed when dirty_ratio implemented. The logic around this will be
> > A  revisited in following patche.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A include/linux/memcontrol.h | A  11 ++++
> > A mm/memcontrol.c A  A  A  A  A  A | A  44 ++++++++++++++---
> > A mm/vmscan.c A  A  A  A  A  A  A  A | A 115 +++++++++++++++++++++++++++++++++++++++++++++
> > A 3 files changed, 162 insertions(+), 8 deletions(-)
> >
> > Index: memcg/include/linux/memcontrol.h
> > ===================================================================
> > --- memcg.orig/include/linux/memcontrol.h
> > +++ memcg/include/linux/memcontrol.h
> > @@ -89,6 +89,8 @@ extern int mem_cgroup_last_scanned_node(
> > A extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A const nodemask_t *nodes);
> >
> > +unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);
> > +
> > A static inline
> > A int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> > A {
> > @@ -112,6 +114,9 @@ extern void mem_cgroup_end_migration(str
> > A */
> > A int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> > A int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> > +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
> > +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  int nid, int zone_idx);
> > A unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct zone *zone,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  enum lru_list lru);
> > @@ -310,6 +315,12 @@ mem_cgroup_inactive_file_is_low(struct m
> > A }
> >
> > A static inline unsigned long
> > +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zone_idx)
> > +{
> > + A  A  A  return 0;
> > +}
> > +
> > +static inline unsigned long
> > A mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
> > A  A  A  A  A  A  A  A  A  A  A  A  enum lru_list lru)
> > A {
> > Index: memcg/mm/memcontrol.c
> > ===================================================================
> > --- memcg.orig/mm/memcontrol.c
> > +++ memcg/mm/memcontrol.c
> > @@ -1166,6 +1166,23 @@ int mem_cgroup_inactive_file_is_low(stru
> > A  A  A  A return (active > inactive);
> > A }
> >
> > +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  int nid, int zone_idx)
> > +{
> > + A  A  A  int nr;
> > + A  A  A  struct mem_cgroup_per_zone *mz =
> > + A  A  A  A  A  A  A  mem_cgroup_zoneinfo(memcg, nid, zone_idx);
> > +
> > + A  A  A  nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> > + A  A  A  A  A  A MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
> > +
> > + A  A  A  if (nr_swap_pages > 0)
> > + A  A  A  A  A  A  A  nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
> > + A  A  A  A  A  A  A  A  A  A  MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
> > +
> > + A  A  A  return nr;
> > +}
> > +
> > A unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct zone *zone,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  enum lru_list lru)
> > @@ -1286,7 +1303,7 @@ static unsigned long mem_cgroup_margin(s
> > A  A  A  A return margin >> PAGE_SHIFT;
> > A }
> >
> > -static unsigned int get_swappiness(struct mem_cgroup *memcg)
> > +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> > A {
> > A  A  A  A struct cgroup *cgrp = memcg->css.cgroup;
> >
> > @@ -1595,14 +1612,15 @@ static int mem_cgroup_hierarchical_recla
> > A  A  A  A  A  A  A  A /* we use swappiness of local cgroup */
> > A  A  A  A  A  A  A  A if (check_soft) {
> > A  A  A  A  A  A  A  A  A  A  A  A ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  noswap, get_swappiness(victim), zone,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  noswap, mem_cgroup_swappiness(victim), zone,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A &nr_scanned);
> > A  A  A  A  A  A  A  A  A  A  A  A *total_scanned += nr_scanned;
> > A  A  A  A  A  A  A  A  A  A  A  A mem_cgroup_soft_steal(victim, ret);
> > A  A  A  A  A  A  A  A  A  A  A  A mem_cgroup_soft_scan(victim, nr_scanned);
> > A  A  A  A  A  A  A  A } else
> > A  A  A  A  A  A  A  A  A  A  A  A ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  noswap, get_swappiness(victim));
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  noswap,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  mem_cgroup_swappiness(victim));
> > A  A  A  A  A  A  A  A css_put(&victim->css);
> > A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  * At shrinking usage, we can't check we should stop here or
> > @@ -1628,15 +1646,25 @@ static int mem_cgroup_hierarchical_recla
> > A int
> > A mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t *nodes)
> > A {
> > - A  A  A  int next_nid;
> > + A  A  A  int next_nid, i;
> > A  A  A  A int last_scanned;
> >
> > A  A  A  A last_scanned = mem->last_scanned_node;
> > - A  A  A  next_nid = next_node(last_scanned, *nodes);
> > + A  A  A  next_nid = last_scanned;
> > +rescan:
> > + A  A  A  next_nid = next_node(next_nid, *nodes);
> >
> > A  A  A  A if (next_nid == MAX_NUMNODES)
> > A  A  A  A  A  A  A  A next_nid = first_node(*nodes);
> >
> > + A  A  A  /* If no page on this node, skip */
> > + A  A  A  for (i = 0; i < MAX_NR_ZONES; i++)
> > + A  A  A  A  A  A  A  if (mem_cgroup_zone_reclaimable_pages(mem, next_nid, i))
> > + A  A  A  A  A  A  A  A  A  A  A  break;
> > +
> > + A  A  A  if (next_nid != last_scanned && (i == MAX_NR_ZONES))
> > + A  A  A  A  A  A  A  goto rescan;
> > +
> > A  A  A  A mem->last_scanned_node = next_nid;
> >
> > A  A  A  A return next_nid;
> > @@ -3649,7 +3677,7 @@ try_to_free:
> > A  A  A  A  A  A  A  A  A  A  A  A goto out;
> > A  A  A  A  A  A  A  A }
> > A  A  A  A  A  A  A  A progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  false, get_swappiness(mem));
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  false, mem_cgroup_swappiness(mem));
> > A  A  A  A  A  A  A  A if (!progress) {
> > A  A  A  A  A  A  A  A  A  A  A  A nr_retries--;
> > A  A  A  A  A  A  A  A  A  A  A  A /* maybe some writeback is necessary */
> > @@ -4073,7 +4101,7 @@ static u64 mem_cgroup_swappiness_read(st
> > A {
> > A  A  A  A struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> >
> > - A  A  A  return get_swappiness(memcg);
> > + A  A  A  return mem_cgroup_swappiness(memcg);
> > A }
> >
> > A static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
> > @@ -4849,7 +4877,7 @@ mem_cgroup_create(struct cgroup_subsys *
> > A  A  A  A INIT_LIST_HEAD(&mem->oom_notify);
> >
> > A  A  A  A if (parent)
> > - A  A  A  A  A  A  A  mem->swappiness = get_swappiness(parent);
> > + A  A  A  A  A  A  A  mem->swappiness = mem_cgroup_swappiness(parent);
> > A  A  A  A atomic_set(&mem->refcnt, 1);
> > A  A  A  A mem->move_charge_at_immigrate = 0;
> > A  A  A  A mutex_init(&mem->thresholds_lock);
> > Index: memcg/mm/vmscan.c
> > ===================================================================
> > --- memcg.orig/mm/vmscan.c
> > +++ memcg/mm/vmscan.c
> > @@ -42,6 +42,7 @@
> > A #include <linux/delayacct.h>
> > A #include <linux/sysctl.h>
> > A #include <linux/oom.h>
> > +#include <linux/res_counter.h>
> >
> > A #include <asm/tlbflush.h>
> > A #include <asm/div64.h>
> > @@ -2308,6 +2309,120 @@ static bool sleeping_prematurely(pg_data
> > A  A  A  A  A  A  A  A return !all_zones_ok;
> > A }
> >
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * The function is used for per-memcg LRU. It scanns all the zones of the
> > + * node and returns the nr_scanned and nr_reclaimed.
> > + */
> > +/*
> > + * Limit of scanning per iteration. For round-robin.
> > + */
> > +#define MEMCG_BGSCAN_LIMIT A  A  (2048)
> > +
> > +static void
> > +shrink_memcg_node(int nid, int priority, struct scan_control *sc)
> > +{
> > + A  A  A  unsigned long total_scanned = 0;
> > + A  A  A  struct mem_cgroup *mem_cont = sc->mem_cgroup;
> > + A  A  A  int i;
> > +
> > + A  A  A  /*
> > + A  A  A  A * This dma->highmem order is consistant with global reclaim.
> > + A  A  A  A * We do this because the page allocator works in the opposite
> > + A  A  A  A * direction although memcg user pages are mostly allocated at
> > + A  A  A  A * highmem.
> > + A  A  A  A */
> > + A  A  A  for (i = 0;
> > + A  A  A  A  A  A (i < NODE_DATA(nid)->nr_zones) &&
> > + A  A  A  A  A  A (total_scanned < MEMCG_BGSCAN_LIMIT);
> > + A  A  A  A  A  A i++) {
> > + A  A  A  A  A  A  A  struct zone *zone = NODE_DATA(nid)->node_zones + i;
> > + A  A  A  A  A  A  A  struct zone_reclaim_stat *zrs;
> > + A  A  A  A  A  A  A  unsigned long scan, rotate;
> > +
> > + A  A  A  A  A  A  A  if (!populated_zone(zone))
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > + A  A  A  A  A  A  A  scan = mem_cgroup_zone_reclaimable_pages(mem_cont, nid, i);
> > + A  A  A  A  A  A  A  if (!scan)
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > + A  A  A  A  A  A  A  /* If recent memory reclaim on this zone doesn't get good */
> > + A  A  A  A  A  A  A  zrs = get_reclaim_stat(zone, sc);
> > + A  A  A  A  A  A  A  scan = zrs->recent_scanned[0] + zrs->recent_scanned[1];
> > + A  A  A  A  A  A  A  rotate = zrs->recent_rotated[0] + zrs->recent_rotated[1];
> > +
> > + A  A  A  A  A  A  A  if (rotate > scan/2)
> > + A  A  A  A  A  A  A  A  A  A  A  sc->may_writepage = 1;
> > +
> > + A  A  A  A  A  A  A  sc->nr_scanned = 0;
> > + A  A  A  A  A  A  A  shrink_zone(priority, zone, sc);
> > + A  A  A  A  A  A  A  total_scanned += sc->nr_scanned;
> > + A  A  A  A  A  A  A  sc->may_writepage = 0;
> > + A  A  A  }
> > + A  A  A  sc->nr_scanned = total_scanned;
> > +}
> 
> I see the MEMCG_BGSCAN_LIMIT is a newly defined macro from previous
> post. So, now the number of pages to scan is capped on 2k for each
> memcg, and does it make difference on big vs small cgroup?
> 

Now, no difference. One reason is because low_watermark - high_watermark is
limited to 4MB, at most. It should be static 4MB in many cases and 2048 pages
is for scanning 8MB, twice of low_wmark - high_wmark. Another reason is
that I didn't have enough time for considering to tune this. 
By MEMCG_BGSCAN_LIMIT, round-robin can be simply fair and I think it's a
good start point.

If memory eater enough slow (because the threads needs to do some
work on allocated memory), this shrink_mem_cgroup() works fine and
helps to avoid hitting limit. Here, the amount of dirty pages is troublesome.

The penaly for cpu eating (hard-to-reclaim) cgroup is given by 'delay'.
(see patch 7.) This patch's congestion_wait is too bad and will be replaced
in patch 7 as 'delay'. In short, if memcg scanning seems to be not successful,
it gets HZ/10 delay until the next work.

If we have dirty_ratio + I/O less dirty throttling, I think we'll see much
better fairness on this watermark reclaim round robin.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
