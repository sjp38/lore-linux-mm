Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8C6306B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 00:27:33 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB75RTQe004306
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Dec 2010 14:27:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6357945DE5D
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 14:27:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ABA245DE5B
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 14:27:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B1F51DB8050
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 14:27:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E6F051DB803F
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 14:27:28 +0900 (JST)
Date: Tue, 7 Dec 2010 14:21:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Per cgroup background reclaim.
Message-Id: <20101207142124.a5386cd7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimm1NrMJ2owLnKbeRe2=p-dHQpJGd7j+A2Sixap@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-4-git-send-email-yinghan@google.com>
	<20101130165142.bff427b0.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimm1NrMJ2owLnKbeRe2=p-dHQpJGd7j+A2Sixap@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Dec 2010 18:25:55 -0800
Ying Han <yinghan@google.com> wrote:

> On Mon, Nov 29, 2010 at 11:51 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 29 Nov 2010 22:49:44 -0800
> > Ying Han <yinghan@google.com> wrote:
> >
> >> The current implementation of memcg only supports direct reclaim and this
> >> patch adds the support for background reclaim. Per cgroup background reclaim
> >> is needed which spreads out the memory pressure over longer period of time
> >> and smoothes out the system performance.
> >>
> >> There is a kswapd kernel thread for each memory node. We add a different kswapd
> >> for each cgroup. The kswapd is sleeping in the wait queue headed at kswapd_wait
> >> field of a kswapd descriptor.
> >>
> >> The kswapd() function now is shared between global and per cgroup kswapd thread.
> >> It is passed in with the kswapd descriptor which contains the information of
> >> either node or cgroup. Then the new function balance_mem_cgroup_pgdat is invoked
> >> if it is per cgroup kswapd thread. The balance_mem_cgroup_pgdat performs a
> >> priority loop similar to global reclaim. In each iteration it invokes
> >> balance_pgdat_node for all nodes on the system, which is a new function performs
> >> background reclaim per node. After reclaiming each node, it checks
> >> mem_cgroup_watermark_ok() and breaks the priority loop if returns true. A per
> >> memcg zone will be marked as "unreclaimable" if the scanning rate is much
> >> greater than the reclaiming rate on the per cgroup LRU. The bit is cleared when
> >> there is a page charged to the cgroup being freed. Kswapd breaks the priority
> >> loop if all the zones are marked as "unreclaimable".
> >>
> >> Signed-off-by: Ying Han <yinghan@google.com>
> >> ---
> >> A include/linux/memcontrol.h | A  30 +++++++
> >> A mm/memcontrol.c A  A  A  A  A  A | A 182 ++++++++++++++++++++++++++++++++++++++-
> >> A mm/page_alloc.c A  A  A  A  A  A | A  A 2 +
> >> A mm/vmscan.c A  A  A  A  A  A  A  A | A 205 +++++++++++++++++++++++++++++++++++++++++++-
> >> A 4 files changed, 416 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> >> index 90fe7fe..dbed45d 100644
> >> --- a/include/linux/memcontrol.h
> >> +++ b/include/linux/memcontrol.h
> >> @@ -127,6 +127,12 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  gfp_t gfp_mask);
> >> A u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> >>
> >> +void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *zone);
> >> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid);
> >> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
> >> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
> >> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long nr_scanned);
> >> A #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >> A struct mem_cgroup;
> >>
> >> @@ -299,6 +305,25 @@ static inline void mem_cgroup_update_file_mapped(struct page *page,
> >> A {
> >> A }
> >>
> >> +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct zone *zone,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long nr_scanned)
> >> +{
> >> +}
> >> +
> >> +static inline void mem_cgroup_clear_unreclaimable(struct page *page,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct zone *zone)
> >> +{
> >> +}
> >> +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem,
> >> + A  A  A  A  A  A  struct zone *zone)
> >> +{
> >> +}
> >> +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct zone *zone)
> >> +{
> >> +}
> >> +
> >> A static inline
> >> A unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  gfp_t gfp_mask)
> >> @@ -312,6 +337,11 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
> >> A  A  A  return 0;
> >> A }
> >>
> >> +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  int zid)
> >> +{
> >> + A  A  return false;
> >> +}
> >> A #endif /* CONFIG_CGROUP_MEM_CONT */
> >>
> >> A #endif /* _LINUX_MEMCONTROL_H */
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index a0c6ed9..1d39b65 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -48,6 +48,8 @@
> >> A #include <linux/page_cgroup.h>
> >> A #include <linux/cpu.h>
> >> A #include <linux/oom.h>
> >> +#include <linux/kthread.h>
> >> +
> >> A #include "internal.h"
> >>
> >> A #include <asm/uaccess.h>
> >> @@ -118,7 +120,10 @@ struct mem_cgroup_per_zone {
> >> A  A  A  bool A  A  A  A  A  A  A  A  A  A on_tree;
> >> A  A  A  struct mem_cgroup A  A  A  *mem; A  A  A  A  A  /* Back pointer, we cannot */
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  /* use container_of A  A  A  A */
> >> + A  A  unsigned long A  A  A  A  A  pages_scanned; A /* since last reclaim */
> >> + A  A  int A  A  A  A  A  A  A  A  A  A  all_unreclaimable; A  A  A /* All pages pinned */
> >> A };
> >> +
> >> A /* Macro for accessing counter */
> >> A #define MEM_CGROUP_ZSTAT(mz, idx) A  A ((mz)->count[(idx)])
> >>
> >> @@ -372,6 +377,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
> >> A static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> >> A static void drain_all_stock_async(void);
> >> A static unsigned long get_min_free_kbytes(struct mem_cgroup *mem);
> >> +static inline void wake_memcg_kswapd(struct mem_cgroup *mem);
> >>
> >> A static struct mem_cgroup_per_zone *
> >> A mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> >> @@ -1086,6 +1092,106 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
> >> A  A  A  return &mz->reclaim_stat;
> >> A }
> >>
> >> +unsigned long mem_cgroup_zone_reclaimable_pages(
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct mem_cgroup_per_zone *mz)
> >> +{
> >> + A  A  int nr;
> >> + A  A  nr = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
> >> + A  A  A  A  A  A  MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
> >> +
> >> + A  A  if (nr_swap_pages > 0)
> >> + A  A  A  A  A  A  nr += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON) +
> >> + A  A  A  A  A  A  A  A  A  A  MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
> >> +
> >> + A  A  return nr;
> >> +}
> >> +
> >> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long nr_scanned)
> >> +{
> >> + A  A  struct mem_cgroup_per_zone *mz = NULL;
> >> + A  A  int nid = zone_to_nid(zone);
> >> + A  A  int zid = zone_idx(zone);
> >> +
> >> + A  A  if (!mem)
> >> + A  A  A  A  A  A  return;
> >> +
> >> + A  A  mz = mem_cgroup_zoneinfo(mem, nid, zid);
> >> + A  A  if (mz)
> >> + A  A  A  A  A  A  mz->pages_scanned += nr_scanned;
> >> +}
> >> +
> >> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid)
> >> +{
> >> + A  A  struct mem_cgroup_per_zone *mz = NULL;
> >> +
> >> + A  A  if (!mem)
> >> + A  A  A  A  A  A  return 0;
> >> +
> >> + A  A  mz = mem_cgroup_zoneinfo(mem, nid, zid);
> >> + A  A  if (mz)
> >> + A  A  A  A  A  A  return mz->pages_scanned <
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  mem_cgroup_zone_reclaimable_pages(mz) * 6;
> >> + A  A  return 0;
> >> +}
> >> +
> >> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
> >> +{
> >> + A  A  struct mem_cgroup_per_zone *mz = NULL;
> >> + A  A  int nid = zone_to_nid(zone);
> >> + A  A  int zid = zone_idx(zone);
> >> +
> >> + A  A  if (!mem)
> >> + A  A  A  A  A  A  return 0;
> >> +
> >> + A  A  mz = mem_cgroup_zoneinfo(mem, nid, zid);
> >> + A  A  if (mz)
> >> + A  A  A  A  A  A  return mz->all_unreclaimable;
> >> +
> >> + A  A  return 0;
> >> +}
> >> +
> >> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
> >> +{
> >> + A  A  struct mem_cgroup_per_zone *mz = NULL;
> >> + A  A  int nid = zone_to_nid(zone);
> >> + A  A  int zid = zone_idx(zone);
> >> +
> >> + A  A  if (!mem)
> >> + A  A  A  A  A  A  return;
> >> +
> >> + A  A  mz = mem_cgroup_zoneinfo(mem, nid, zid);
> >> + A  A  if (mz)
> >> + A  A  A  A  A  A  mz->all_unreclaimable = 1;
> >> +}
> >> +
> >> +void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *zone)
> >> +{
> >> + A  A  struct mem_cgroup_per_zone *mz = NULL;
> >> + A  A  struct mem_cgroup *mem = NULL;
> >> + A  A  int nid = zone_to_nid(zone);
> >> + A  A  int zid = zone_idx(zone);
> >> + A  A  struct page_cgroup *pc = lookup_page_cgroup(page);
> >> +
> >> + A  A  if (unlikely(!pc))
> >> + A  A  A  A  A  A  return;
> >> +
> >> + A  A  rcu_read_lock();
> >> + A  A  mem = pc->mem_cgroup;
> >
> > This is incorrect. you have to do css_tryget(&mem->css) before rcu_read_unlock.
> >
> >> + A  A  rcu_read_unlock();
> >> +
> >> + A  A  if (!mem)
> >> + A  A  A  A  A  A  return;
> >> +
> >> + A  A  mz = mem_cgroup_zoneinfo(mem, nid, zid);
> >> + A  A  if (mz) {
> >> + A  A  A  A  A  A  mz->pages_scanned = 0;
> >> + A  A  A  A  A  A  mz->all_unreclaimable = 0;
> >> + A  A  }
> >> +
> >> + A  A  return;
> >> +}
> >> +
> >> A unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct list_head *dst,
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long *scanned, int order,
> >> @@ -1887,6 +1993,20 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
> >> A  A  A  struct res_counter *fail_res;
> >> A  A  A  unsigned long flags = 0;
> >> A  A  A  int ret;
> >> + A  A  unsigned long min_free_kbytes = 0;
> >> +
> >> + A  A  min_free_kbytes = get_min_free_kbytes(mem);
> >> + A  A  if (min_free_kbytes) {
> >> + A  A  A  A  A  A  ret = res_counter_charge(&mem->res, csize, CHARGE_WMARK_LOW,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  &fail_res);
> >> + A  A  A  A  A  A  if (likely(!ret)) {
> >> + A  A  A  A  A  A  A  A  A  A  return CHARGE_OK;
> >> + A  A  A  A  A  A  } else {
> >> + A  A  A  A  A  A  A  A  A  A  mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  res);
> >> + A  A  A  A  A  A  A  A  A  A  wake_memcg_kswapd(mem_over_limit);
> >> + A  A  A  A  A  A  }
> >> + A  A  }
> >
> > I think this check can be moved out to periodic-check as threshould notifiers.
> 
> Yes. This will be changed in V2.
> 
> >
> >
> >
> >>
> >> A  A  A  ret = res_counter_charge(&mem->res, csize, CHARGE_WMARK_MIN, &fail_res);
> >>
> >> @@ -3037,6 +3157,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >> A  A  A  A  A  A  A  A  A  A  A  else
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  memcg->memsw_is_minimum = false;
> >> A  A  A  A  A  A  A  }
> >> + A  A  A  A  A  A  setup_per_memcg_wmarks(memcg);
> >> A  A  A  A  A  A  A  mutex_unlock(&set_limit_mutex);
> >>
> >> A  A  A  A  A  A  A  if (!ret)
> >> @@ -3046,7 +3167,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  MEM_CGROUP_RECLAIM_SHRINK);
> >> A  A  A  A  A  A  A  curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> >> A  A  A  A  A  A  A  /* Usage is reduced ? */
> >> - A  A  A  A  A  A  if (curusage >= oldusage)
> >> + A  A  A  A  A  A  if (curusage >= oldusage)
> >> A  A  A  A  A  A  A  A  A  A  A  retry_count--;
> >> A  A  A  A  A  A  A  else
> >> A  A  A  A  A  A  A  A  A  A  A  oldusage = curusage;
> >
> > What's changed here ?
> >
> >> @@ -3096,6 +3217,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >> A  A  A  A  A  A  A  A  A  A  A  else
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  memcg->memsw_is_minimum = false;
> >> A  A  A  A  A  A  A  }
> >> + A  A  A  A  A  A  setup_per_memcg_wmarks(memcg);
> >> A  A  A  A  A  A  A  mutex_unlock(&set_limit_mutex);
> >>
> >> A  A  A  A  A  A  A  if (!ret)
> >> @@ -4352,6 +4474,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
> >> A static void __mem_cgroup_free(struct mem_cgroup *mem)
> >> A {
> >> A  A  A  int node;
> >> + A  A  struct kswapd *kswapd_p;
> >> + A  A  wait_queue_head_t *wait;
> >>
> >> A  A  A  mem_cgroup_remove_from_trees(mem);
> >> A  A  A  free_css_id(&mem_cgroup_subsys, &mem->css);
> >> @@ -4360,6 +4484,15 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
> >> A  A  A  A  A  A  A  free_mem_cgroup_per_zone_info(mem, node);
> >>
> >> A  A  A  free_percpu(mem->stat);
> >> +
> >> + A  A  wait = mem->kswapd_wait;
> >> + A  A  kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> >> + A  A  if (kswapd_p) {
> >> + A  A  A  A  A  A  if (kswapd_p->kswapd_task)
> >> + A  A  A  A  A  A  A  A  A  A  kthread_stop(kswapd_p->kswapd_task);
> >> + A  A  A  A  A  A  kfree(kswapd_p);
> >> + A  A  }
> >> +
> >> A  A  A  if (sizeof(struct mem_cgroup) < PAGE_SIZE)
> >> A  A  A  A  A  A  A  kfree(mem);
> >> A  A  A  else
> >> @@ -4421,6 +4554,39 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
> >> A  A  A  return ret;
> >> A }
> >>
> >> +static inline
> >> +void wake_memcg_kswapd(struct mem_cgroup *mem)
> >> +{
> >> + A  A  wait_queue_head_t *wait;
> >> + A  A  struct kswapd *kswapd_p;
> >> + A  A  struct task_struct *thr;
> >> + A  A  static char memcg_name[PATH_MAX];
> >> +
> >> + A  A  if (!mem)
> >> + A  A  A  A  A  A  return;
> >> +
> >> + A  A  wait = mem->kswapd_wait;
> >> + A  A  kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> >> + A  A  if (!kswapd_p->kswapd_task) {
> >> + A  A  A  A  A  A  if (mem->css.cgroup)
> >> + A  A  A  A  A  A  A  A  A  A  cgroup_path(mem->css.cgroup, memcg_name, PATH_MAX);
> >> + A  A  A  A  A  A  else
> >> + A  A  A  A  A  A  A  A  A  A  sprintf(memcg_name, "no_name");
> >> +
> >> + A  A  A  A  A  A  thr = kthread_run(kswapd, kswapd_p, "kswapd%s", memcg_name);
> >
> > I don't think reusing the name of "kswapd" isn't good. and this name cannot
> > be long as PATH_MAX...IIUC, this name is for comm[] field which is 16bytes long.
> >
> > So, how about naming this as
> >
> > A "memcg%d", mem->css.id ?
> >
> > Exporing css.id will be okay if necessary.
> 
> I am not if that is working since the mem->css hasn't been initialized
> during mem_cgroup_create(). So that is one of the reasons that I put
> the kswapd creation at triggering wmarks instead of creating cgroup,
> since I have all that information ready by the time.
> 
> However, I agree that adding into the cgroup creation is better for
> performance perspective since we won't add the overhead for the page
> allocation. ( Although only the first wmark triggering ). Any
> suggestion?
> 

Hmm, my recommendation is to start the thread when the limit is set.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
