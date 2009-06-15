Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25B186B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 22:53:27 -0400 (EDT)
Date: Mon, 15 Jun 2009 11:50:21 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
	<20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009 15:19:24 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 12 Jun 2009 14:33:46 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > I found a problem about rmdir: rmdir doesn't return(or take a very very long time).
> > Actually, I found this problem long ago, but I've not had enough time to
> > track it down until the stale swap cache problem has been fixed.
> > 
> > The cause of this problem is the commit ec64f51545fffbc4cb968f0cea56341a4b07e85a
> > (cgroup: fix frequent -EBUSY at rmdir) and memcg's behavior about swap-in.
> > 
> > The commit introduced cgroup_rmdir_waitq and make rmdir wait until someone
> > (who will decrement css->refcnt to 1) wake it up.
> > But even after we have succeeded pre_destroy, which means mem.usage has
> > become 0, a process which has moved to another cgroup from the cgroup being removed
> > can increment mem.usage(and css->refcnt as a result) by doing swap-in.
> > This css->refcnt won't be dropped, that is the rmdir process won't be woken up,
> > until the owner process frees the page.
> > 
> > So, just "waking up after a while" by a patch below can fix this problem.
> > 
> > ===
> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > index 3737a68..2fe9645 100644
> > --- a/kernel/cgroup.c
> > +++ b/kernel/cgroup.c
> > @@ -2722,7 +2722,7 @@ again:
> >  
> >  	if (!cgroup_clear_css_refs(cgrp)) {
> >  		mutex_unlock(&cgroup_mutex);
> > -		schedule();
> > +		schedule_timeout(HZ/10);	/* don't wait forever */
> >  		finish_wait(&cgroup_rmdir_waitq, &wait);
> >  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> >  		if (signal_pending(current))
> > ===
> > 
> This is not a choice, maybe.
> 
> 
> 
> > But, is there any reason why we should charge a NEW swap-in'ed page to
> > "the group to which the swap has been charged", not to "the group in which
> > the process is now" ?
> > I agree that we should uncharge "swap" at swap-in from "the group to which
> > the swap has been charged", but IIUC, memcg before/without mem+swap controller behaves
> > as the latter about the charge of a swap-in'ed page.
> > 
> I have no objection to this direction. But this implies the resouce usage
> can be moved from a cgroup to other silently.
> But this bahavior is not different from behavior of page caches, I think
> this one is a choice.
> 
> This happens only when swapped-out pages are swapped-in by a process in other
> cgroup. Maybe rare case.
> 
It would be rare case if rmdir is executed after all the tasks have exited,
but I think it would not be so rare if we do "move tasks to another cgroup
and rmdir the old cgroup". 

> 
> 
> > I've confirmed that a patch below can also fix this rmdir problem.
> > 
> > ===
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 6ceb6f2..dbece65 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1063,7 +1063,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
> >  
> >  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> >  {
> > -	struct mem_cgroup *mem;
> > +	struct mem_cgroup *mem = NULL;
> >  	struct page_cgroup *pc;
> >  	unsigned short id;
> >  	swp_entry_t ent;
> > @@ -1079,14 +1079,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> >  		mem = pc->mem_cgroup;
> >  		if (mem && !css_tryget(&mem->css))
> >  			mem = NULL;
> > -	} else {
> > -		ent.val = page_private(page);
> > -		id = lookup_swap_cgroup(ent);
> > -		rcu_read_lock();
> > -		mem = mem_cgroup_lookup(id);
> > -		if (mem && !css_tryget(&mem->css))
> > -			mem = NULL;
> > -		rcu_read_unlock();
> >  	}
> >  	unlock_page_cgroup(pc);
> >  	return mem;
> > ===
> > 
> > 
> > Any suggestions ?
> > 
> 
> After this,  swap-cache behavior will be highly complecated ;(
> 
>  - If swap-cache is newly swapped-in, it's charged to current user and resource
>    usage moves.
>  - If swap-cache is used (or unmapped recently), it's charged to old user and
>    resource usage don't move.
> 
> Then, my suggestion is here.
> ==
> } else {
> 	ent.val = page_private(page);
> 	id = lookup_swap_cgroup(ent);
> 	rcu_read_lock();
> 	mem = mem_cgroup_lookup(id);
> 	if (mem) {
> 		if (css_tryget(mem->css)) {
> 			/*
> 			 * If no processes in this cgroup, accounting back to
> 			 * this cgroup seems silly and prevents RMDIR.
> 			 */
> 			struct cgroup *cg = mem->css.cgroup;
> 			if (!atomic_read(&cg->count) && list_empty(&cg->children)) {
> 				css_put(&mem->css);
> 				mem = NULL;
> 			}
> 	}
> 	rcu_read_unlock();
>  }
> ==
> 
Thank you for your suggestion.
To be honest, I think swap cache behavior would be complicated anyway :(

I prefer my change because the behavior would become consistent with
the case we don't use mem+swap controller and with the behavior of page cache.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
