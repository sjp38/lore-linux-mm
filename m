Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9EC326B0078
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:45:14 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C7jBKF008815
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 16:45:11 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3131845DE58
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EFBE145DE54
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D19E91DB8042
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C5C11DB8037
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:10 +0900 (JST)
Date: Fri, 12 Feb 2010 16:41:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: share event counter rather than duplicate
Message-Id: <20100212164145.e280399d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100212164018.092e1688.nishimura@mxp.nes.nec.co.jp>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212154857.f9d8f28e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212164018.092e1688.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 16:40:18 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 12 Feb 2010 15:48:57 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
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
> >  mm/memcontrol.c |   36 ++++++++++++------------------------
> >  1 file changed, 12 insertions(+), 24 deletions(-)
> > 
> > Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> > @@ -63,8 +63,8 @@ static int really_do_swap_account __init
> >  #define do_swap_account		(0)
> >  #endif
> >  
> > -#define SOFTLIMIT_EVENTS_THRESH (1000)
> > -#define THRESHOLDS_EVENTS_THRESH (100)
> > +#define SOFTLIMIT_EVENTS_THRESH (0x3ff) /* once in 1024 */
> > +#define THRESHOLDS_EVENTS_THRESH (0x7f) /* once in 128 */
> >  
> >  /*
> >   * Statistics for memory cgroup.
> > @@ -79,10 +79,7 @@ enum mem_cgroup_stat_index {
> >  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> >  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> >  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > -	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> > -					used by soft limit implementation */
> > -	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> > -					used by threshold implementation */
> > +	MEM_CGROUP_EVENTS,	/* incremented by 1 at pagein/pageout */
> >  
> >  	MEM_CGROUP_STAT_NSTATS,
> >  };
> > @@ -394,16 +391,12 @@ mem_cgroup_remove_exceeded(struct mem_cg
> >  
> >  static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> >  {
> > -	bool ret = false;
> >  	s64 val;
> >  
> > -	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > -	if (unlikely(val < 0)) {
> > -		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
> > -				SOFTLIMIT_EVENTS_THRESH);
> > -		ret = true;
> > -	}
> > -	return ret;
> > +	val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
> > +	if (unlikely(!(val & SOFTLIMIT_EVENTS_THRESH)))
> > +		return true;
> > +	return false;
> >  }
> >  
> >  static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
> > @@ -542,8 +535,7 @@ static void mem_cgroup_charge_statistics
> >  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
> >  	else
> >  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
> > -	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > -	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> > +	__this_cpu_dec(mem->stat->count[MEM_CGROUP_EVENTS]);
> >
> I think using __this_cpu_inc() would be more natural(and the patch description
> says "increment" :)).
> 
yes...yes..will post v2.

Thanks,
-Kame


> Thanks,
> Daisuke Nishimura.
> 
> >  	preempt_enable();
> >  }
> > @@ -3211,16 +3203,12 @@ static int mem_cgroup_swappiness_write(s
> >  
> >  static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> >  {
> > -	bool ret = false;
> >  	s64 val;
> >  
> > -	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> > -	if (unlikely(val < 0)) {
> > -		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS],
> > -				THRESHOLDS_EVENTS_THRESH);
> > -		ret = true;
> > -	}
> > -	return ret;
> > +	val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
> > +	if (unlikely(!(val & THRESHOLDS_EVENTS_THRESH)))
> > +		return true;
> > +	return false;
> >  }
> >  
> >  static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
