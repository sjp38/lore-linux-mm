Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 390B76B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:49:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C7ndBm010587
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 16:49:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8273345DE51
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:49:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D73445DE4E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:49:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 480E11DB803E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:49:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E488BE78003
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:49:38 +0900 (JST)
Date: Fri, 12 Feb 2010 16:46:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: share event counter rather than duplicate
Message-Id: <20100212164614.4fe18ac5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab1002112346tc9a40a6x53ff9c8a8a8c6dc4@mail.gmail.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212154857.f9d8f28e.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab1002112346tc9a40a6x53ff9c8a8a8c6dc4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 09:46:17 +0200
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
> >
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
> 
> Probably, better to define it as power of two here. Like
> 
> #define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
> #define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
> 
> And change logic of checks accordingly. What do you think?
> 

Okay, maybe it's cleaner. I'll try that.


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
> 
> Decrement??
> 
my bug. I'll fix.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
