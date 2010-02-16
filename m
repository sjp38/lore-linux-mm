Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0031C6B0082
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 19:20:27 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G0KPs1008371
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Feb 2010 09:20:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB54945DE50
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:20:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC95945DE4F
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:20:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B7145E38001
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:20:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46E2C1DB803E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:20:21 +0900 (JST)
Date: Tue, 16 Feb 2010 09:16:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg : share event counter rather than duplicate
 v2
Message-Id: <20100216091656.f7e7a03c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab1002150257y65bb3856x4a4c60e5c6218a50@mail.gmail.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180508.eb58a4d1.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180952.28b2f6c5.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab1002150257y65bb3856x4a4c60e5c6218a50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 12:57:30 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Feb 12, 2010 at 11:09 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Memcg has 2 eventcountes which counts "the same" event. Just usages are
> > different from each other. This patch tries to reduce event counter.
> >
> > Now logic uses "only increment, no reset" counter and masks for each
> > checks. Softlimit chesk was done per 1000 evetns. So, the similar check
> > can be done by !(new_counter & 0x3ff). Threshold check was done per 100
> > events. So, the similar check can be done by (!new_counter & 0x7f)
> >
> > ALL event checks are done right after EVENT percpu counter is updated.
> >
> > Changelog: 2010/02/12
> > A - fixed to use "inc" rather than "dec"
> > A - modified to be more unified style of counter handling.
> > A - taking care of account-move.
> >
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/memcontrol.c | A  86 ++++++++++++++++++++++++++------------------------------
> > A 1 file changed, 41 insertions(+), 45 deletions(-)
> >
> > Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> > @@ -63,8 +63,15 @@ static int really_do_swap_account __init
> > A #define do_swap_account A  A  A  A  A  A  A  A (0)
> > A #endif
> >
> > -#define SOFTLIMIT_EVENTS_THRESH (1000)
> > -#define THRESHOLDS_EVENTS_THRESH (100)
> > +/*
> > + * Per memcg event counter is incremented at every pagein/pageout. This counter
> > + * is used for trigger some periodic events. This is straightforward and better
> > + * than using jiffies etc. to handle periodic memcg event.
> > + *
> > + * These values will be used as !((event) & ((1 <<(thresh)) - 1))
> > + */
> > +#define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
> > +#define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
> >
> > A /*
> > A * Statistics for memory cgroup.
> > @@ -79,10 +86,7 @@ enum mem_cgroup_stat_index {
> > A  A  A  A MEM_CGROUP_STAT_PGPGIN_COUNT, A  /* # of pages paged in */
> > A  A  A  A MEM_CGROUP_STAT_PGPGOUT_COUNT, A /* # of pages paged out */
> > A  A  A  A MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > - A  A  A  MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  used by soft limit implementation */
> > - A  A  A  MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  used by threshold implementation */
> > + A  A  A  MEM_CGROUP_EVENTS, A  A  A /* incremented at every A pagein/pageout */
> >
> > A  A  A  A MEM_CGROUP_STAT_NSTATS,
> > A };
> > @@ -154,7 +158,6 @@ struct mem_cgroup_threshold_ary {
> > A  A  A  A struct mem_cgroup_threshold entries[0];
> > A };
> >
> > -static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
> > A static void mem_cgroup_threshold(struct mem_cgroup *mem);
> >
> > A /*
> > @@ -392,19 +395,6 @@ mem_cgroup_remove_exceeded(struct mem_cg
> > A  A  A  A spin_unlock(&mctz->lock);
> > A }
> >
> > -static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> > -{
> > - A  A  A  bool ret = false;
> > - A  A  A  s64 val;
> > -
> > - A  A  A  val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > - A  A  A  if (unlikely(val < 0)) {
> > - A  A  A  A  A  A  A  this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  SOFTLIMIT_EVENTS_THRESH);
> > - A  A  A  A  A  A  A  ret = true;
> > - A  A  A  }
> > - A  A  A  return ret;
> > -}
> >
> > A static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
> > A {
> > @@ -542,8 +532,7 @@ static void mem_cgroup_charge_statistics
> > A  A  A  A  A  A  A  A __this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
> > A  A  A  A else
> > A  A  A  A  A  A  A  A __this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
> > - A  A  A  __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > - A  A  A  __this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> > + A  A  A  __this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]);
> >
> > A  A  A  A preempt_enable();
> > A }
> > @@ -563,6 +552,29 @@ static unsigned long mem_cgroup_get_loca
> > A  A  A  A return total;
> > A }
> >
> > +static bool __memcg_event_check(struct mem_cgroup *mem, int event_mask_shift)
> 
> inline?
> 
> > +{
> > + A  A  A  s64 val;
> > +
> > + A  A  A  val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
> > +
> > + A  A  A  return !(val & ((1 << event_mask_shift) - 1));
> > +}
> > +
> > +/*
> > + * Check events in order.
> > + *
> > + */
> > +static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
> 
> Ditto.
> 
I'd like to depend on compiler.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
