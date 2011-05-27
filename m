Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E69906B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 21:19:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E28783EE0C0
	for <linux-mm@kvack.org>; Fri, 27 May 2011 10:19:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EB7045DEBD
	for <linux-mm@kvack.org>; Fri, 27 May 2011 10:19:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 662B745DEBA
	for <linux-mm@kvack.org>; Fri, 27 May 2011 10:19:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5813B1DB8041
	for <linux-mm@kvack.org>; Fri, 27 May 2011 10:19:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DB941DB803E
	for <linux-mm@kvack.org>; Fri, 27 May 2011 10:19:24 +0900 (JST)
Date: Fri, 27 May 2011 10:12:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 10/10] memcg : reclaim statistics
Message-Id: <20110527101237.30157c4a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTim+hj4Y5wUhB+BHoSOsXdaMYeKqbA@mail.gmail.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526143631.adc2c911.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim+hj4Y5wUhB+BHoSOsXdaMYeKqbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, 26 May 2011 18:17:04 -0700
Ying Han <yinghan@google.com> wrote:

> Hi Kame:
> 
> I applied the patch on top of mmotm-2011-05-12-15-52. After boot up, i
> keep getting the following crash by reading the
> /dev/cgroup/memory/memory.reclaim_stat
> 
> [  200.776366] Kernel panic - not syncing: Fatal exception
> [  200.781591] Pid: 7535, comm: cat Tainted: G      D W   2.6.39-mcg-DEV #130
> [  200.788463] Call Trace:
> [  200.790916]  [<ffffffff81405a75>] panic+0x91/0x194
> [  200.797096]  [<ffffffff81408ac8>] oops_end+0xae/0xbe
> [  200.803450]  [<ffffffff810398d3>] die+0x5a/0x63
> [  200.809366]  [<ffffffff81408561>] do_trap+0x121/0x130
> [  200.814427]  [<ffffffff81037fe6>] do_divide_error+0x90/0x99
> [#1] SMP
> [  200.821395]  [<ffffffff81112bcb>] ? mem_cgroup_reclaim_stat_read+0x28/0xf0
> [  200.829624]  [<ffffffff81104509>] ? page_add_new_anon_rmap+0x7e/0x90
> [  200.837372]  [<ffffffff810fb7f8>] ? handle_pte_fault+0x28a/0x775
> [  200.844773]  [<ffffffff8140f0f5>] divide_error+0x15/0x20
> [  200.851471]  [<ffffffff81112bcb>] ? mem_cgroup_reclaim_stat_read+0x28/0xf0
> [  200.859729]  [<ffffffff810a4a01>] cgroup_seqfile_show+0x38/0x46
> [  200.867036]  [<ffffffff810a4d72>] ? cgroup_lock+0x17/0x17
> [  200.872444]  [<ffffffff81133f2c>] seq_read+0x182/0x361
> [  200.878984]  [<ffffffff8111a0c4>] vfs_read+0xab/0x107
> [  200.885403]  [<ffffffff8111a1e0>] sys_read+0x4a/0x6e
> [  200.891764]  [<ffffffff8140f469>] sysenter_dispatch+0x7/0x27
> 
> I will debug it, but like to post here in case i missed some patches in between.
> 

maybe mem->scanned is 0. It must be mem->scanned +1. thank you for report.

Thanks,
-kame

> --Ying
> 
> On Wed, May 25, 2011 at 10:36 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > This patch adds a file memory.reclaim_stat.
> >
> > This file shows following.
> > ==
> > recent_scan_success_ratio A 12 # recent reclaim/scan ratio.
> > limit_scan_pages 671 A  A  A  A  A # scan caused by hitting limit.
> > limit_freed_pages 538 A  A  A  A  # freed pages by limit_scan
> > limit_elapsed_ns 518555076 A  A # elapsed time in LRU scanning by limit.
> > soft_scan_pages 0 A  A  A  A  A  A  # scan caused by softlimit.
> > soft_freed_pages 0 A  A  A  A  A  A # freed pages by soft_scan.
> > soft_elapsed_ns 0 A  A  A  A  A  A  # elapsed time in LRU scanning by softlimit.
> > margin_scan_pages 16744221 A  A # scan caused by auto-keep-margin
> > margin_freed_pages 565943 A  A  # freed pages by auto-keep-margin.
> > margin_elapsed_ns 5545388791 A # elapsed time in LRU scanning by auto-keep-margin
> >
> > This patch adds a new file rather than adding more stats to memory.stat. By it,
> > this support "reset" accounting by
> >
> > A # echo 0 > .../memory.reclaim_stat
> >
> > This is good for debug and tuning.
> >
> > TODO:
> > A - add Documentaion.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/memcontrol.c | A  87 ++++++++++++++++++++++++++++++++++++++++++++++++++------
> > A 1 file changed, 79 insertions(+), 8 deletions(-)
> >
> > Index: memcg_async/mm/memcontrol.c
> > ===================================================================
> > --- memcg_async.orig/mm/memcontrol.c
> > +++ memcg_async/mm/memcontrol.c
> > @@ -216,6 +216,13 @@ static void mem_cgroup_update_margin_to_
> > A static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
> > A static void mem_cgroup_reflesh_scan_ratio(struct mem_cgroup *mem);
> >
> > +enum scan_type {
> > + A  A  A  LIMIT_SCAN, A  A  /* scan memory because memcg hits limit */
> > + A  A  A  SOFT_SCAN, A  A  A /* scan memory because of soft limit */
> > + A  A  A  MARGIN_SCAN, A  A /* scan memory for making margin to limit */
> > + A  A  A  NR_SCAN_TYPES,
> > +};
> > +
> > A /*
> > A * The memory controller data structure. The memory controller controls both
> > A * page cache and RSS per cgroup. We would eventually like to provide
> > @@ -300,6 +307,13 @@ struct mem_cgroup {
> > A  A  A  A unsigned long A  scanned;
> > A  A  A  A unsigned long A  reclaimed;
> > A  A  A  A unsigned long A  next_scanratio_update;
> > + A  A  A  /* For statistics */
> > + A  A  A  struct {
> > + A  A  A  A  A  A  A  unsigned long nr_scanned_pages;
> > + A  A  A  A  A  A  A  unsigned long nr_reclaimed_pages;
> > + A  A  A  A  A  A  A  unsigned long elapsed_ns;
> > + A  A  A  } scan_stat[NR_SCAN_TYPES];
> > +
> > A  A  A  A /*
> > A  A  A  A  * percpu counter.
> > A  A  A  A  */
> > @@ -1426,7 +1440,9 @@ unsigned int mem_cgroup_swappiness(struc
> >
> > A static void __mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A unsigned long scanned,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long reclaimed)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long reclaimed,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long elapsed,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  enum scan_type type)
> > A {
> > A  A  A  A unsigned long limit;
> >
> > @@ -1439,6 +1455,9 @@ static void __mem_cgroup_update_scan_rat
> > A  A  A  A  A  A  A  A mem->scanned /= 2;
> > A  A  A  A  A  A  A  A mem->reclaimed /= 2;
> > A  A  A  A }
> > + A  A  A  mem->scan_stat[type].nr_scanned_pages += scanned;
> > + A  A  A  mem->scan_stat[type].nr_reclaimed_pages += reclaimed;
> > + A  A  A  mem->scan_stat[type].elapsed_ns += elapsed;
> > A  A  A  A spin_unlock(&mem->scan_stat_lock);
> > A }
> >
> > @@ -1448,6 +1467,8 @@ static void __mem_cgroup_update_scan_rat
> > A * @root : root memcg of hierarchy walk.
> > A * @scanned : scanned pages
> > A * @reclaimed: reclaimed pages.
> > + * @elapsed: used time for memory reclaim
> > + * @type : scan type as LIMIT_SCAN, SOFT_SCAN, MARGIN_SCAN.
> > A *
> > A * record scan/reclaim ratio to the memcg both to a child and it's root
> > A * mem cgroup, which is a reclaim target. This value is used for
> > @@ -1457,11 +1478,14 @@ static void __mem_cgroup_update_scan_rat
> > A static void mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A struct mem_cgroup *root,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A unsigned long scanned,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long reclaimed)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long reclaimed,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long elapsed,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  int type)
> > A {
> > - A  A  A  __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed);
> > + A  A  A  __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed, elapsed, type);
> > A  A  A  A if (mem != root)
> > - A  A  A  A  A  A  A  __mem_cgroup_update_scan_ratio(root, scanned, reclaimed);
> > + A  A  A  A  A  A  A  __mem_cgroup_update_scan_ratio(root, scanned, reclaimed,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  elapsed, type);
> >
> > A }
> >
> > @@ -1906,6 +1930,7 @@ static int mem_cgroup_hierarchical_recla
> > A  A  A  A bool is_kswapd = false;
> > A  A  A  A unsigned long excess;
> > A  A  A  A unsigned long nr_scanned;
> > + A  A  A  unsigned long start, end, elapsed;
> >
> > A  A  A  A excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
> >
> > @@ -1947,18 +1972,24 @@ static int mem_cgroup_hierarchical_recla
> > A  A  A  A  A  A  A  A }
> > A  A  A  A  A  A  A  A /* we use swappiness of local cgroup */
> > A  A  A  A  A  A  A  A if (check_soft) {
> > + A  A  A  A  A  A  A  A  A  A  A  start = sched_clock();
> > A  A  A  A  A  A  A  A  A  A  A  A ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A noswap, zone, &nr_scanned);
> > + A  A  A  A  A  A  A  A  A  A  A  end = sched_clock();
> > + A  A  A  A  A  A  A  A  A  A  A  elapsed = end - start;
> > A  A  A  A  A  A  A  A  A  A  A  A *total_scanned += nr_scanned;
> > A  A  A  A  A  A  A  A  A  A  A  A mem_cgroup_soft_steal(victim, is_kswapd, ret);
> > A  A  A  A  A  A  A  A  A  A  A  A mem_cgroup_soft_scan(victim, is_kswapd, nr_scanned);
> > A  A  A  A  A  A  A  A  A  A  A  A mem_cgroup_update_scan_ratio(victim,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  root_mem, nr_scanned, ret);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  root_mem, nr_scanned, ret, elapsed, SOFT_SCAN);
> > A  A  A  A  A  A  A  A } else {
> > + A  A  A  A  A  A  A  A  A  A  A  start = sched_clock();
> > A  A  A  A  A  A  A  A  A  A  A  A ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A noswap, &nr_scanned);
> > + A  A  A  A  A  A  A  A  A  A  A  end = sched_clock();
> > + A  A  A  A  A  A  A  A  A  A  A  elapsed = end - start;
> > A  A  A  A  A  A  A  A  A  A  A  A mem_cgroup_update_scan_ratio(victim,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  root_mem, nr_scanned, ret);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  root_mem, nr_scanned, ret, elapsed, LIMIT_SCAN);
> > A  A  A  A  A  A  A  A }
> > A  A  A  A  A  A  A  A css_put(&victim->css);
> > A  A  A  A  A  A  A  A /*
> > @@ -4003,7 +4034,7 @@ static void mem_cgroup_async_shrink_work
> > A  A  A  A struct delayed_work *dw = to_delayed_work(work);
> > A  A  A  A struct mem_cgroup *mem, *victim;
> > A  A  A  A long nr_to_reclaim;
> > - A  A  A  unsigned long nr_scanned, nr_reclaimed;
> > + A  A  A  unsigned long nr_scanned, nr_reclaimed, start, end;
> > A  A  A  A int delay = 0;
> >
> > A  A  A  A mem = container_of(dw, struct mem_cgroup, async_work);
> > @@ -4022,9 +4053,12 @@ static void mem_cgroup_async_shrink_work
> > A  A  A  A if (!victim)
> > A  A  A  A  A  A  A  A goto finish_scan;
> >
> > + A  A  A  start = sched_clock();
> > A  A  A  A nr_reclaimed = mem_cgroup_shrink_rate_limited(victim, nr_to_reclaim,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A &nr_scanned);
> > - A  A  A  mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_reclaimed);
> > + A  A  A  end = sched_clock();
> > + A  A  A  mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_reclaimed,
> > + A  A  A  A  A  A  A  A  A  A  A  end - start, MARGIN_SCAN);
> > A  A  A  A css_put(&victim->css);
> >
> > A  A  A  A /* If margin is enough big, stop */
> > @@ -4680,6 +4714,38 @@ static int mem_control_stat_show(struct
> > A  A  A  A return 0;
> > A }
> >
> > +static int mem_cgroup_reclaim_stat_read(struct cgroup *cont, struct cftype *cft,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A struct cgroup_map_cb *cb)
> > +{
> > + A  A  A  struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> > + A  A  A  u64 val;
> > + A  A  A  int i; /* for indexing scan_stat[] */
> > +
> > + A  A  A  val = mem->reclaimed * 100 / mem->scanned;
> > + A  A  A  cb->fill(cb, "recent_scan_success_ratio", val);
> > + A  A  A  i A = LIMIT_SCAN;
> > + A  A  A  cb->fill(cb, "limit_scan_pages", mem->scan_stat[i].nr_scanned_pages);
> > + A  A  A  cb->fill(cb, "limit_freed_pages", mem->scan_stat[i].nr_reclaimed_pages);
> > + A  A  A  cb->fill(cb, "limit_elapsed_ns", mem->scan_stat[i].elapsed_ns);
> > + A  A  A  i = SOFT_SCAN;
> > + A  A  A  cb->fill(cb, "soft_scan_pages", mem->scan_stat[i].nr_scanned_pages);
> > + A  A  A  cb->fill(cb, "soft_freed_pages", mem->scan_stat[i].nr_reclaimed_pages);
> > + A  A  A  cb->fill(cb, "soft_elapsed_ns", mem->scan_stat[i].elapsed_ns);
> > + A  A  A  i = MARGIN_SCAN;
> > + A  A  A  cb->fill(cb, "margin_scan_pages", mem->scan_stat[i].nr_scanned_pages);
> > + A  A  A  cb->fill(cb, "margin_freed_pages", mem->scan_stat[i].nr_reclaimed_pages);
> > + A  A  A  cb->fill(cb, "margin_elapsed_ns", mem->scan_stat[i].elapsed_ns);
> > + A  A  A  return 0;
> > +}
> > +
> > +static int mem_cgroup_reclaim_stat_reset(struct cgroup *cgrp, unsigned int event)
> > +{
> > + A  A  A  struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> > + A  A  A  memset(mem->scan_stat, 0, sizeof(mem->scan_stat));
> > + A  A  A  return 0;
> > +}
> > +
> > +
> > A /*
> > A * User flags for async_control is a subset of mem->async_flags. But
> > A * this needs to be defined independently to hide implemation details.
> > @@ -5163,6 +5229,11 @@ static struct cftype mem_cgroup_files[]
> > A  A  A  A  A  A  A  A .open = mem_control_numa_stat_open,
> > A  A  A  A },
> > A #endif
> > + A  A  A  {
> > + A  A  A  A  A  A  A  .name = "reclaim_stat",
> > + A  A  A  A  A  A  A  .read_map = mem_cgroup_reclaim_stat_read,
> > + A  A  A  A  A  A  A  .trigger = mem_cgroup_reclaim_stat_reset,
> > + A  A  A  }
> > A };
> >
> > A #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
