Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D7F0C6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 02:20:20 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5C6Ku71014363
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Jun 2009 15:20:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDD2F45DD76
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 15:20:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B963745DD74
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 15:20:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93121E08002
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 15:20:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BA241DB8013
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 15:20:55 +0900 (JST)
Date: Fri, 12 Jun 2009 15:19:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009 14:33:46 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> I found a problem about rmdir: rmdir doesn't return(or take a very very long time).
> Actually, I found this problem long ago, but I've not had enough time to
> track it down until the stale swap cache problem has been fixed.
> 
> The cause of this problem is the commit ec64f51545fffbc4cb968f0cea56341a4b07e85a
> (cgroup: fix frequent -EBUSY at rmdir) and memcg's behavior about swap-in.
> 
> The commit introduced cgroup_rmdir_waitq and make rmdir wait until someone
> (who will decrement css->refcnt to 1) wake it up.
> But even after we have succeeded pre_destroy, which means mem.usage has
> become 0, a process which has moved to another cgroup from the cgroup being removed
> can increment mem.usage(and css->refcnt as a result) by doing swap-in.
> This css->refcnt won't be dropped, that is the rmdir process won't be woken up,
> until the owner process frees the page.
> 
> So, just "waking up after a while" by a patch below can fix this problem.
> 
> ===
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 3737a68..2fe9645 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2722,7 +2722,7 @@ again:
>  
>  	if (!cgroup_clear_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
> -		schedule();
> +		schedule_timeout(HZ/10);	/* don't wait forever */
>  		finish_wait(&cgroup_rmdir_waitq, &wait);
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		if (signal_pending(current))
> ===
> 
This is not a choice, maybe.



> But, is there any reason why we should charge a NEW swap-in'ed page to
> "the group to which the swap has been charged", not to "the group in which
> the process is now" ?
> I agree that we should uncharge "swap" at swap-in from "the group to which
> the swap has been charged", but IIUC, memcg before/without mem+swap controller behaves
> as the latter about the charge of a swap-in'ed page.
> 
I have no objection to this direction. But this implies the resouce usage
can be moved from a cgroup to other silently.
But this bahavior is not different from behavior of page caches, I think
this one is a choice.

This happens only when swapped-out pages are swapped-in by a process in other
cgroup. Maybe rare case.



> I've confirmed that a patch below can also fix this rmdir problem.
> 
> ===
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6ceb6f2..dbece65 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1063,7 +1063,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>  
>  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  {
> -	struct mem_cgroup *mem;
> +	struct mem_cgroup *mem = NULL;
>  	struct page_cgroup *pc;
>  	unsigned short id;
>  	swp_entry_t ent;
> @@ -1079,14 +1079,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  		mem = pc->mem_cgroup;
>  		if (mem && !css_tryget(&mem->css))
>  			mem = NULL;
> -	} else {
> -		ent.val = page_private(page);
> -		id = lookup_swap_cgroup(ent);
> -		rcu_read_lock();
> -		mem = mem_cgroup_lookup(id);
> -		if (mem && !css_tryget(&mem->css))
> -			mem = NULL;
> -		rcu_read_unlock();
>  	}
>  	unlock_page_cgroup(pc);
>  	return mem;
> ===
> 
> 
> Any suggestions ?
> 

After this,  swap-cache behavior will be highly complecated ;(

 - If swap-cache is newly swapped-in, it's charged to current user and resource
   usage moves.
 - If swap-cache is used (or unmapped recently), it's charged to old user and
   resource usage don't move.

Then, my suggestion is here.
==
} else {
	ent.val = page_private(page);
	id = lookup_swap_cgroup(ent);
	rcu_read_lock();
	mem = mem_cgroup_lookup(id);
	if (mem) {
		if (css_tryget(mem->css)) {
			/*
			 * If no processes in this cgroup, accounting back to
			 * this cgroup seems silly and prevents RMDIR.
			 */
			struct cgroup *cg = mem->css.cgroup;
			if (!atomic_read(&cg->count) && list_empty(&cg->children)) {
				css_put(&mem->css);
				mem = NULL;
			}
	}
	rcu_read_unlock();
 }
==

nonsense ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
