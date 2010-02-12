Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D62786B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 03:23:18 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C8NFTB025268
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 17:23:16 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A24282AEA81
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:23:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 08D8C1F7042
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:23:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4777E18003
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:23:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A2991DB803B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 17:23:14 +0900 (JST)
Date: Fri, 12 Feb 2010 17:19:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: share event counter rather than duplicate
Message-Id: <20100212171948.16346836.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab1002120007v1dfdfac0te0c2a8b750919c15@mail.gmail.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212154857.f9d8f28e.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab1002120007v1dfdfac0te0c2a8b750919c15@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 10:07:25 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Feb 12, 2010 at 8:48 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Memcg has 2 eventcountes which counts "the same" event. Just usages are
> > different from each other. This patch tries to reduce event counter.
> >
> > This patch's logic uses "only increment, no reset" new_counter and masks for each
> > checks. Softlimit chesk was done per 1000 events. So, the similar check
> > can be done by !(new_counter & 0x3ff). Threshold check was done per 100
> > events. So, the similar check can be done by (!new_counter & 0x7f)
> 
> IIUC, with this change we have to check counter after each update,
> since we check
> for exact value. 

Yes. 
> So we have to move checks to mem_cgroup_charge_statistics() or
> call them after each statistics charging. I'm not sure how it affects
> performance.
> 

My patch 1/2 does it.

But hmm, move-task does counter updates in asynchronous manner. Then, there are
bug. I'll add check in the next version.

Maybe calling update_tree and threshold_check at the end of mova_task is
better. Does thresholds user take care of batched-move manner in task_move ?
Should we check one by one ?
(Maybe there will be another trouble when we handle hugepages...)

Thanks,
-Kame


> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/memcontrol.c | A  36 ++++++++++++------------------------
> > A 1 file changed, 12 insertions(+), 24 deletions(-)
> >
> > Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> > @@ -63,8 +63,8 @@ static int really_do_swap_account __init
> > A #define do_swap_account A  A  A  A  A  A  A  A (0)
> > A #endif
> >
> > -#define SOFTLIMIT_EVENTS_THRESH (1000)
> > -#define THRESHOLDS_EVENTS_THRESH (100)
> > +#define SOFTLIMIT_EVENTS_THRESH (0x3ff) /* once in 1024 */
> > +#define THRESHOLDS_EVENTS_THRESH (0x7f) /* once in 128 */
> >
> > A /*
> > A * Statistics for memory cgroup.
> > @@ -79,10 +79,7 @@ enum mem_cgroup_stat_index {
> > A  A  A  A MEM_CGROUP_STAT_PGPGIN_COUNT, A  /* # of pages paged in */
> > A  A  A  A MEM_CGROUP_STAT_PGPGOUT_COUNT, A /* # of pages paged out */
> > A  A  A  A MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > - A  A  A  MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  used by soft limit implementation */
> > - A  A  A  MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  used by threshold implementation */
> > + A  A  A  MEM_CGROUP_EVENTS, A  A  A /* incremented by 1 at pagein/pageout */
> >
> > A  A  A  A MEM_CGROUP_STAT_NSTATS,
> > A };
> > @@ -394,16 +391,12 @@ mem_cgroup_remove_exceeded(struct mem_cg
> >
> > A static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> > A {
> > - A  A  A  bool ret = false;
> > A  A  A  A s64 val;
> >
> > - A  A  A  val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > - A  A  A  if (unlikely(val < 0)) {
> > - A  A  A  A  A  A  A  this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  SOFTLIMIT_EVENTS_THRESH);
> > - A  A  A  A  A  A  A  ret = true;
> > - A  A  A  }
> > - A  A  A  return ret;
> > + A  A  A  val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
> > + A  A  A  if (unlikely(!(val & SOFTLIMIT_EVENTS_THRESH)))
> > + A  A  A  A  A  A  A  return true;
> > + A  A  A  return false;
> > A }
> >
> > A static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
> > @@ -542,8 +535,7 @@ static void mem_cgroup_charge_statistics
> > A  A  A  A  A  A  A  A __this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
> > A  A  A  A else
> > A  A  A  A  A  A  A  A __this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
> > - A  A  A  __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > - A  A  A  __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> > + A  A  A  __this_cpu_dec(mem->stat->count[MEM_CGROUP_EVENTS]);
> >
> > A  A  A  A preempt_enable();
> > A }
> > @@ -3211,16 +3203,12 @@ static int mem_cgroup_swappiness_write(s
> >
> > A static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> > A {
> > - A  A  A  bool ret = false;
> > A  A  A  A s64 val;
> >
> > - A  A  A  val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> > - A  A  A  if (unlikely(val < 0)) {
> > - A  A  A  A  A  A  A  this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS],
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  THRESHOLDS_EVENTS_THRESH);
> > - A  A  A  A  A  A  A  ret = true;
> > - A  A  A  }
> > - A  A  A  return ret;
> > + A  A  A  val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
> > + A  A  A  if (unlikely(!(val & THRESHOLDS_EVENTS_THRESH)))
> > + A  A  A  A  A  A  A  return true;
> > + A  A  A  return false;
> > A }
> >
> > A static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> >
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
