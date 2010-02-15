Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 03EE06B007E
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 19:22:38 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F0MaUq012583
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Feb 2010 09:22:36 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 331F245DE4E
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:22:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 17D8945DE4C
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:22:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 02D131DB803E
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:22:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 994A41DB8038
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 09:22:32 +0900 (JST)
Date: Mon, 15 Feb 2010 09:19:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg : share event counter rather than duplicate
 v2
Message-Id: <20100215091906.c08a6ed7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100212204810.704f90f0.d-nishimura@mtf.biglobe.ne.jp>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180508.eb58a4d1.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180952.28b2f6c5.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212204810.704f90f0.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 20:48:10 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> On Fri, 12 Feb 2010 18:09:52 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
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
> >  - fixed to use "inc" rather than "dec"
> >  - modified to be more unified style of counter handling.
> >  - taking care of account-move.
> > 
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   86 ++++++++++++++++++++++++++------------------------------
> >  1 file changed, 41 insertions(+), 45 deletions(-)
> > 
> > Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> > @@ -63,8 +63,15 @@ static int really_do_swap_account __init
> >  #define do_swap_account		(0)
> >  #endif
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
> >  /*
> >   * Statistics for memory cgroup.
> > @@ -79,10 +86,7 @@ enum mem_cgroup_stat_index {
> >  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> >  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> >  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > -	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> > -					used by soft limit implementation */
> > -	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> > -					used by threshold implementation */
> > +	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> >  
> >  	MEM_CGROUP_STAT_NSTATS,
> >  };
> > @@ -154,7 +158,6 @@ struct mem_cgroup_threshold_ary {
> >  	struct mem_cgroup_threshold entries[0];
> >  };
> >  
> > -static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
> >  static void mem_cgroup_threshold(struct mem_cgroup *mem);
> >  
> >  /*
> > @@ -392,19 +395,6 @@ mem_cgroup_remove_exceeded(struct mem_cg
> >  	spin_unlock(&mctz->lock);
> >  }
> >  
> > -static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> > -{
> > -	bool ret = false;
> > -	s64 val;
> > -
> > -	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > -	if (unlikely(val < 0)) {
> > -		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
> > -				SOFTLIMIT_EVENTS_THRESH);
> > -		ret = true;
> > -	}
> > -	return ret;
> > -}
> >  
> >  static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
> >  {
> > @@ -542,8 +532,7 @@ static void mem_cgroup_charge_statistics
> >  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
> >  	else
> >  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
> > -	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> > -	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> > +	__this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]);
> >  
> >  	preempt_enable();
> >  }
> > @@ -563,6 +552,29 @@ static unsigned long mem_cgroup_get_loca
> >  	return total;
> >  }
> >  
> > +static bool __memcg_event_check(struct mem_cgroup *mem, int event_mask_shift)
> > +{
> > +	s64 val;
> > +
> > +	val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
> > +
> > +	return !(val & ((1 << event_mask_shift) - 1));
> > +}
> > +
> > +/*
> > + * Check events in order.
> > + *
> > + */
> > +static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
> > +{
> > +	/* threshold event is triggered in finer grain than soft limit */
> > +	if (unlikely(__memcg_event_check(mem, THRESHOLDS_EVENTS_THRESH))) {
> > +		mem_cgroup_threshold(mem);
> > +		if (unlikely(__memcg_event_check(mem, SOFTLIMIT_EVENTS_THRESH)))
> > +			mem_cgroup_update_tree(mem, page);
> > +	}
> > +}
> > +
> >  static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> >  {
> >  	return container_of(cgroup_subsys_state(cont,
> > @@ -1686,11 +1698,7 @@ static void __mem_cgroup_commit_charge(s
> >  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> >  	 * if they exceeds softlimit.
> >  	 */
> > -	if (mem_cgroup_soft_limit_check(mem))
> > -		mem_cgroup_update_tree(mem, pc->page);
> > -	if (mem_cgroup_threshold_check(mem))
> > -		mem_cgroup_threshold(mem);
> > -
> > +	memcg_check_events(mem, pc->page);
> >  }
> >  
> >  /**
> > @@ -1760,6 +1768,11 @@ static int mem_cgroup_move_account(struc
> >  		ret = 0;
> >  	}
> >  	unlock_page_cgroup(pc);
> > +	/*
> > +	 * check events
> > +	 */
> > +	memcg_check_events(to, pc->page);
> > +	memcg_check_events(from, pc->page);
> >  	return ret;
> >  }
> >  
> Strictly speaking, "if (!ret)" would be needed(it's not a big deal, though).
> 
Hmm. ok. I'll check.

Thanks,
-kame


> Thanks,
> Daisuke Nishimura.
> 
> > @@ -2128,10 +2141,7 @@ __mem_cgroup_uncharge_common(struct page
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	unlock_page_cgroup(pc);
> >  
> > -	if (mem_cgroup_soft_limit_check(mem))
> > -		mem_cgroup_update_tree(mem, page);
> > -	if (mem_cgroup_threshold_check(mem))
> > -		mem_cgroup_threshold(mem);
> > +	memcg_check_events(mem, page);
> >  	/* at swapout, this memcg will be accessed to record to swap */
> >  	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> >  		css_put(&mem->css);
> > @@ -3207,20 +3217,6 @@ static int mem_cgroup_swappiness_write(s
> >  	return 0;
> >  }
> >  
> > -static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> > -{
> > -	bool ret = false;
> > -	s64 val;
> > -
> > -	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> > -	if (unlikely(val < 0)) {
> > -		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS],
> > -				THRESHOLDS_EVENTS_THRESH);
> > -		ret = true;
> > -	}
> > -	return ret;
> > -}
> > -
> >  static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> >  {
> >  	struct mem_cgroup_threshold_ary *t;
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
