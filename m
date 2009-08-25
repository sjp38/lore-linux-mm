Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 008F46B00FA
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 19:49:38 -0400 (EDT)
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail9.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P8eLK2003766
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 17:40:21 +0900
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P8dkJb031767
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 17:39:46 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E09345DE51
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:39:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F7D445DE4E
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:39:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 15A721DB8038
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:39:46 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4402F1DB8046
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:39:42 +0900 (JST)
Date: Tue, 25 Aug 2009 17:37:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][preview] [patch 1/2] memcg: batched uncharge base
Message-Id: <20090825173743.61f737ee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090825170735.6acd3ace.nishimura@mxp.nes.nec.co.jp>
References: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
	<20090825112919.259ab97c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090825170735.6acd3ace.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009 17:07:35 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> First of all, I think these patches are good optimization.
> 
> I have a few comments for now.
> 
> On Tue, 25 Aug 2009 11:29:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > In massive parallel enviroment, res_counter can be a performance bottleneck.
> > This patch is a trial for reducing lock contention in memcg.
> > 
> > One strong techinque to reduce lock contention is reducing calls themselves by
> > do some amount of calls into a call, in batch.
> > 
> > Considering charge/uncharge chatacteristic,
> > 	- charge is done one by one via demand-paging.
> > 	- uncharge is done by
> > 		- in continuous call at munmap, truncate, exit, execve...
> > 		- one by one via vmscan/paging.
> > 
> > It seems we have a chance to batched-uncharge.
> > This patch is a base patch for batched uncharge. For avoiding
> > scattering memcg's structure as argument, this patch adds memcg batch uncharge
> > information to the task. please see start/end usage in next patch.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |   12 ++++++++++
> >  include/linux/sched.h      |    8 +++++++
> >  mm/memcontrol.c            |   51 ++++++++++++++++++++++++++++++++++++++++++---
> >  3 files changed, 68 insertions(+), 3 deletions(-)
> > 
> > Index: linux-2.6.31-rc7/include/linux/memcontrol.h
> > ===================================================================
> > --- linux-2.6.31-rc7.orig/include/linux/memcontrol.h
> > +++ linux-2.6.31-rc7/include/linux/memcontrol.h
> > @@ -54,6 +54,10 @@ extern void mem_cgroup_rotate_lru_list(s
> >  extern void mem_cgroup_del_lru(struct page *page);
> >  extern void mem_cgroup_move_lists(struct page *page,
> >  				  enum lru_list from, enum lru_list to);
> > +
> > +extern void mem_cgroup_uncharge_batch_start(void);
> > +extern void mem_cgroup_uncharge_batch_end(void);
> > +
> >  extern void mem_cgroup_uncharge_page(struct page *page);
> >  extern void mem_cgroup_uncharge_cache_page(struct page *page);
> >  extern int mem_cgroup_shmem_charge_fallback(struct page *page,
> > @@ -148,6 +152,14 @@ static inline void mem_cgroup_cancel_cha
> >  {
> >  }
> >  
> > +static inline void mem_cgroup_uncharge_batch_start(void)
> > +{
> > +}
> > +
> > +static inline void mem_cgroup_uncharge_batch_start(void)
> > +{
> > +}
> > +
> >  static inline void mem_cgroup_uncharge_page(struct page *page)
> >  {
> >  }
> > Index: linux-2.6.31-rc7/mm/memcontrol.c
> > ===================================================================
> > --- linux-2.6.31-rc7.orig/mm/memcontrol.c
> > +++ linux-2.6.31-rc7/mm/memcontrol.c
> > @@ -1500,6 +1500,7 @@ __mem_cgroup_uncharge_common(struct page
> >  	struct page_cgroup *pc;
> >  	struct mem_cgroup *mem = NULL;
> >  	struct mem_cgroup_per_zone *mz;
> > +	struct memcg_batch_info *batch = NULL;
> >  
> >  	if (mem_cgroup_disabled())
> >  		return NULL;
> > @@ -1537,10 +1538,25 @@ __mem_cgroup_uncharge_common(struct page
> >  	default:
> >  		break;
> >  	}
> > +	if (current->batch_memcg.batch_mode)
> > +		batch = &current->batch_memcg;
> >  
> > -	res_counter_uncharge(&mem->res, PAGE_SIZE);
> > -	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> > -		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +	if (!batch || batch->memcg != mem) {
> > +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> > +		if (do_swap_account &&
> > +		    (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> > +			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +		if (batch) {
> > +			batch->memcg = mem;
> What if we have set batch->memcg to a different memcg and it has some batch->nr_pages(nr_memsw) ?
> Shouldn't we flush them first ?
> 
Ah, this is bug. this should be
==
  if (batch && !batch->memcg)
==
(my current code does this.) thank you for pointing out.

I wonder it's not necessary to flush. just ignore it as no-batch.
This batched uncharge is done at
	- truncate/invalidate file cache per 14pages.(PAGEVECSIZE)
	- per vma unmapping.

Then, flush-and-exchange or just-do-synchronous-uncharge here or not
will not be important, I think.

> And, it might be a overkill, how about flushing all the batched-uncharges
> before invoking oom at __mem_cgroup_try_charge() ?
> 
Hmm. Maybe, I selected region of batched-uncharge to be enough small...
then, adding synchronize_rcu() or congestion_wait() or some before
retrying next-loop of reclaim will be enough.

Or, prevent batched-uncharge if someone runs into reclaim will be a smart choice.
It will be easy midification to  mem_cgroup_uncharge_batch_start(void).

Thanks,
-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 
> > +			css_get(&mem->css);
> > +		}
> > +	} else {
> > +		/* instead of modifing res_counter, remember it */
> > +		batch->nr_pages += PAGE_SIZE;
> > +		if (do_swap_account &&
> > +		    (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> > +			batch->nr_memsw += PAGE_SIZE;
> > +	}
> >  	mem_cgroup_charge_statistics(mem, pc, false);
> >  
> >  	ClearPageCgroupUsed(pc);
> > @@ -1582,6 +1598,35 @@ void mem_cgroup_uncharge_cache_page(stru
> >  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> >  }
> >  
> > +void mem_cgroup_uncharge_batch_start(void)
> > +{
> > +	VM_BUG_ON(current->batch_memcg.batch_mode);
> > +	current->batch_memcg.batch_mode = 1;
> > +	current->batch_memcg.memcg = NULL;
> > +	current->batch_memcg.nr_pages = 0;
> > +	current->batch_memcg.nr_memsw = 0;
> > +}
> > +
> > +void mem_cgroup_uncharge_batch_end(void)
> > +{
> > +	struct mem_cgroup *mem;
> > +
> > +	VM_BUG_ON(!current->batch_memcg.batch_mode);
> > +	current->batch_memcg.batch_mode = 0;
> > +
> > +	mem = current->batch_memcg.memcg;
> > +	if (!mem)
> > +		return;
> > +	if (current->batch_memcg.nr_pages)
> > +		res_counter_uncharge(&mem->res,
> > +				     current->batch_memcg.nr_pages);
> > +	if (current->batch_memcg.nr_memsw)
> > +		res_counter_uncharge(&mem->memsw,
> > +				     current->batch_memcg.nr_memsw);
> > +	/* we got css's refcnt */
> > +	cgroup_release_and_wakeup_rmdir(&mem->css);
> > +}
> > +
> >  #ifdef CONFIG_SWAP
> >  /*
> >   * called after __delete_from_swap_cache() and drop "page" account.
> > Index: linux-2.6.31-rc7/include/linux/sched.h
> > ===================================================================
> > --- linux-2.6.31-rc7.orig/include/linux/sched.h
> > +++ linux-2.6.31-rc7/include/linux/sched.h
> > @@ -1480,6 +1480,14 @@ struct task_struct {
> >  	/* bitmask of trace recursion */
> >  	unsigned long trace_recursion;
> >  #endif /* CONFIG_TRACING */
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +	/* For implicit argument for batched uncharge */
> > +	struct memcg_batch_info {
> > +		struct mem_cgroup *memcg;
> > +		int batch_mode;
> > +		unsigned long nr_pages, nr_memsw;
> > +	} batch_memcg;
> > +#endif
> >  };
> >  
> >  /* Future-safe accessor for struct task_struct's cpus_allowed. */
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
