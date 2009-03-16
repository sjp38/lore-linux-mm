Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2704F6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 04:51:09 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2G8p6NB026964
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Mar 2009 17:51:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 25E0845DD84
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:51:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0004745DD7F
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:51:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0F60E08005
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:51:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FB4F1DB803C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:51:05 +0900 (JST)
Date: Mon, 16 Mar 2009 17:49:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090316083512.GV16897@balbir.in.ibm.com>
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain>
	<20090314173111.16591.68465.sendpatchset@localhost.localdomain>
	<20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316083512.GV16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009 14:05:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > 
> > >  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> > > @@ -889,14 +963,42 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> > >   * If shrink==true, for avoiding to free too much, this returns immedieately.
> > >   */
> > >  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > > -				   gfp_t gfp_mask, bool noswap, bool shrink)
> > > +						struct zonelist *zl,
> > > +						gfp_t gfp_mask,
> > > +						unsigned long reclaim_options)
> > >  {
> > >  	struct mem_cgroup *victim;
> > >  	int ret, total = 0;
> > >  	int loop = 0;
> > > +	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> > > +	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
> > > +	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
> > > +	unsigned long excess = mem_cgroup_get_excess(root_mem);
> > >  
> > > -	while (loop < 2) {
> > > +	while (1) {
> > > +		if (loop >= 2) {
> > > +			if (!check_soft)
> > > +				break;
> > > +			/*
> > > +			 * We want to do more targetted reclaim. excess >> 4
> > > +			 * >> 4 is not to excessive so as to reclaim too
> > > +			 * much, nor too less that we keep coming back
> > > +			 * to reclaim from this cgroup
> > > +			 */
> > > +			if (total >= (excess >> 4))
> > > +				break;
> > > +		}
> > 
> > I wonder this means, in very bad case, the thread cannot exit this loop...
> > right ?
> 
> Potentially. When we do force empty, we actually reclaim all pages in a loop.
> Do you want to see additional checks here?

plz fix. In user enviroments, once-in-1000years trouble can happen
in my experience....

> > > +		if (!reclaimed) {
> > > +			do {
> > > +				/*
> > > +				 * By the time we get the soft_limit lock
> > > +				 * again, someone might have aded the
> > > +				 * group back on the RB tree. Iterate to
> > > +				 * make sure we get a different mem.
> > > +				 * mem_cgroup_largest_soft_limit_node returns
> > > +				 * NULL if no other cgroup is present on
> > > +				 * the tree
> > > +				 */
> > Do we have to allow "someone will push back" case ?
> > 
> 
> Not sure I understand your comment completely? When you say push back,
> are you referring to some one else adding back the RB-Tree to the
> node? 
yes.

> If so, yes, that is quite possible and I've seen it happen.
> 
Hmm. So, it results that several threads start recalim on the same memcg.
Can't we make this "selected" victim is guaranteed  to be out-of-tree while
some reclaims memory on it ?

> > > +				next_mem =
> > > +					__mem_cgroup_largest_soft_limit_node();
> > > +			} while (next_mem == mem);
> > > +		}
> > > +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > > +		__mem_cgroup_remove_exceeded(mem);
> > > +		if (mem->usage_in_excess)
> > > +			__mem_cgroup_insert_exceeded(mem);
> > 
> > If next_mem == NULL here, (means "mem" is an only mem_cgroup which excess softlimit.)
> > mem will be found again even if !reclaimed.
> > plz check.
> 
> Yes, We need to add a if (!next_mem) break; Thanks!
> 
> > 
> > > +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > > +		css_put(&mem->css);
> > > +	} while (!nr_reclaimed);
> > > +	return nr_reclaimed;
> > > +}
> > > +
> > >  /*
> > >   * This routine traverse page_cgroup in given list and drop them all.
> > >   * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
> > > @@ -1995,7 +2160,7 @@ try_to_free:
> > >  			ret = -EINTR;
> > >  			goto out;
> > >  		}
> > > -		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> > > +		progress = try_to_free_mem_cgroup_pages(mem, NULL, GFP_KERNEL,
> > >  						false, get_swappiness(mem));
> > >  		if (!progress) {
> > >  			nr_retries--;
> > > @@ -2600,6 +2765,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> > >  	mem->last_scanned_child = 0;
> > >  	mem->usage_in_excess = 0;
> > >  	mem->last_tree_update = 0;	/* Yes, time begins at 0 here */
> > > +	mem->on_tree = false;
> > > +
> > >  	spin_lock_init(&mem->reclaim_param_lock);
> > >  
> > >  	if (parent)
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index f8fd1e2..5e1a6ca 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1598,7 +1598,14 @@ nofail_alloc:
> > >  	reclaim_state.reclaimed_slab = 0;
> > >  	p->reclaim_state = &reclaim_state;
> > >  
> > > -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > +	/*
> > > +	 * Try to free up some pages from the memory controllers soft
> > > +	 * limit queue.
> > > +	 */
> > > +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> > > +	if (order || !did_some_progress)
> > > +		did_some_progress += try_to_free_pages(zonelist, order,
> > > +							gfp_mask);
> > I'm not sure but do we have to call try_to_free()...twice ?
> 
> We call it twice, once for the memory controller and once for normal
> reclaim (try_to_free_mem_cgroup_pages() and try_to_free_pages()), is
> that an issue?
> 
Maybe "HugePage Allocation" benchmark is necessary to check "calling twice"
is bad or not. But, in general, calling twice is not very good, I think.



> > 
> > if (order)
> >    did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);       
> > if (!order || did_some_progrees)
> >    did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> >
> 
> I don't understand the code snippet above.
>  
Sorry. Ignore above.


> > IIRC, why Kosaki said "don't check order" is because this was called by kswapd() case.
> > 
> > BTW, mem_cgroup_soft_limit_reclaim() can do enough job even under 
> > (gfp_mask & (__GFP_IO|__GFP_FS)) == 0 case ?
> >
> 
> What about clean page cache? Anyway, we pass the gfp_mask, so the reclaimer
> knows what pages to reclaim from, so it should return quickly if it
> can't reclaim. Am I missing something?
>  
My point is, if sc->mem_cgroup is not NULL, we have to be careful that
important routines will not be called.

For example, shrink_slab() is not called. and this must be called.

For exmaple, we may have to add 
 sc->call_shrink_slab
flag and set it "true" at soft limit reclaim. 

In other words, we need some changes in vmscan.c. We should have good eyes to check
whethere a routine should be called or not.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
