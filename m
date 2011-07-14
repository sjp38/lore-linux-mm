Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 819F36B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 05:00:24 -0400 (EDT)
Date: Thu, 14 Jul 2011 11:00:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-ID: <20110714090017.GD19408@tiehlicka.suse.cz>
References: <cover.1310561078.git.mhocko@suse.cz>
 <50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
 <20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu 14-07-11 11:59:13, KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Jul 2011 10:02:59 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 13 Jul 2011 13:05:49 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > > This patch replaces the counter by a simple {un}lock semantic. We are
> > > using only 0 and 1 to distinguish those two states.
> > > As mem_cgroup_oom_{un}lock works on the hierarchy we have to make sure
> > > that we cannot race with somebody else which is already guaranteed
> > > because we call both functions with the mutex held. All other consumers
> > > just read the value atomically for a single group which is sufficient
> > > because we set the value atomically.
> > > The other thing is that only that process which locked the oom will
> > > unlock it once the OOM is handled.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > ---
> > >  mm/memcontrol.c |   24 +++++++++++++++++-------
> > >  1 files changed, 17 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index e013b8e..f6c9ead 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1803,22 +1803,31 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > >  /*
> > >   * Check OOM-Killer is already running under our hierarchy.
> > >   * If someone is running, return false.
> > > + * Has to be called with memcg_oom_mutex
> > >   */
> > >  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> > >  {
> > > -	int x, lock_count = 0;
> > > +	int x, lock_count = -1;
> > >  	struct mem_cgroup *iter;
> > >  
> > >  	for_each_mem_cgroup_tree(iter, mem) {
> > > -		x = atomic_inc_return(&iter->oom_lock);
> > > -		lock_count = max(x, lock_count);
> > > +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > > +		if (lock_count == -1)
> > > +			lock_count = x;
> > > +
> > 
> > 
> > Hmm...Assume following hierarchy.
> > 
> > 	  A
> >        B     C
> >       D E 

IIUC, A, B, D, E are one hierarchy, right?

> > 
> > The orignal code hanldes the situation
> > 
> >  1. B-D-E is under OOM
> >  2. A enters OOM after 1.
> > 
> > In original code, A will not invoke OOM (because B-D-E oom will kill a process.)
> > The new code invokes A will invoke new OOM....right ?

Sorry, I do not understand what you mean by that. The original code and
the new code do the same in that regards they lock the whole hierarchy.
The only difference is that the original one increments the counter for
all groups in the hierarchy while the new one just sets it to from 0->1
BUG_ON just checks that we are not racing with somebody else.

> > 
> > I wonder this kind of code
> > ==
> > 	bool success = true;
> > 	...
> > 	for_each_mem_cgroup_tree(iter, mem) {
> > 		success &= !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > 		/* "break" loop is not allowed because of css refcount....*/
> > 	}
> > 	return success.
> > ==
> > Then, one hierarchy can invoke one OOM kill within it.
> > But this will not work because we can't do proper unlock.

Why cannot we do a proper unlock?

> > 
> > 
> > Hm. how about this ? This has only one lock point and we'll not see the BUG.
> > Not tested yet..
> > 
> Here, tested patch + test program. this seems to work well.

Will look at it later. At first glance it looks rather complicated. But
maybe I am missing something. I have to confess I am not absolutely sure
when it comes to hierarchies.

> ==
> From 8c878b3413b4d796844dbcb18fa7cfccf44860d7 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 14 Jul 2011 11:36:50 +0900
> Subject: [PATCH] memcg: fix livelock at oom.
> 
> 867578cb "memcg: fix oom kill behavior" introduced oom_lock counter
> which is incremented by mem_cgroup_oom_lock when we are about to handle
> memcg OOM situation. mem_cgroup_handle_oom falls back to a sleep if
> oom_lock > 1 to prevent from multiple oom kills at the same time.
> The counter is then decremented by mem_cgroup_oom_unlock called from the
> same function.
> 
> This works correctly but it can lead to serious starvations when we
> have many processes triggering OOM.
> 
> example.
> 
> Make a hierarchy of memcg, which has 300MB memory+swap limit.
> 
>  %cgcreate -g memory:A
>  %cgset -r memory.use_hierarchy=1 A
>  %cgset -r memory.limit_in_bytes=300M A
>  %cgset -r memory.memsw.limit_in_bytes=300M A
>  %cgcreate -g memory:A/B
>  %cgcreate -g memory:A/C
>  %cgcreate -g memory:A/B/X
>  %cgcreate -g memory:A/B/Y
> 
> Then, running folloing program under A/B/X.
>  %cgexec -g memory:A/B/X ./fork
> ==
> int main(int argc, char *argv[])
> {
>         int i;
>         int status;
> 
>         for (i = 0; i < 5000; i++) {
>                 if (fork() == 0) {
>                         char *c;
>                         c = malloc(1024*1024);
>                         memset(c, 0, 1024*1024);
>                         sleep(20);
>                         fprintf(stderr, "[%d]\n", i);
>                         exit(0);
>                 }
>                 printf("%d\n", i);
>                 waitpid(-1, &status, WNOHANG);
>         }
>         while (1) {
>                 int ret;
>                 ret = waitpid(-1, &status, WNOHANG);
> 
>                 if (ret == -1)
>                         break;
>                 if (!ret)
>                         sleep(1);
>         }
>         return 0;
> }
> ==
> 
> This forks a process and the child malloc(1M). Then, after forking 300
> childrens, the memcg goes int OOM. Expected behavior is oom-killer
> will kill process and make progress. But, 300 children will try to get
> oom_lock and oom kill...and the program seems not to make progress.
> 
> The reason is that memcg invokes OOM-Kill when the counter oom_lock is 0.
> But if many process runs, it never goes down to 0 because it's incremanted
> before all processes quits sleep by previous oom-lock, which decremetns
> oom_lock.
> 
> This patch fixes the behavior. This patch makes the oom-hierarchy should
> have only one lock value 1/0. For example, in following hierarchy,
> 
> 	A
>        /
>       B
>      / \
>     C   D
> 
> When C goes into OOM because of limit by B, set B->oom_lock=1
> After that, when A goes into OOM because of limit by A,
> clear B->oom_lock as 0 and set A->oom_lock=1.
> 
> At unlocking, the ancestor which has ()->oom_lock=1 will be cleared.
> 
> After this, above program will do fork 5000 procs with 4000+ oom-killer.
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Changelog:
>   - fixed under_oom counter reset.
> ---
>  mm/memcontrol.c |   77 +++++++++++++++++++++++++++++++++++++-----------------
>  1 files changed, 53 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e013b8e..5f9661b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -246,7 +246,8 @@ struct mem_cgroup {
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> -	atomic_t	oom_lock;
> +	int		oom_lock;
> +	atomic_t	under_oom;
>  	atomic_t	refcnt;
>  
>  	unsigned int	swappiness;
> @@ -1801,36 +1802,63 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  }
>  
>  /*
> - * Check OOM-Killer is already running under our hierarchy.
> + * Check whether OOM-Killer is already running under our hierarchy.
>   * If someone is running, return false.
>   */
> -static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> +static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
>  {
> -	int x, lock_count = 0;
>  	struct mem_cgroup *iter;
> +	bool ret;
>  
> -	for_each_mem_cgroup_tree(iter, mem) {
> -		x = atomic_inc_return(&iter->oom_lock);
> -		lock_count = max(x, lock_count);
> +	/*
> +	 * If an ancestor (including this memcg) is the owner of OOM Lock.
> +	 * return false;
> +	 */
> +	for (iter = memcg; iter != NULL; iter = parent_mem_cgroup(iter)) {
> +		if (iter->oom_lock)
> +			break;
> +		if (!iter->use_hierarchy) {
> +			iter = NULL;
> +			break;
> +		}
>  	}
>  
> -	if (lock_count == 1)
> -		return true;
> -	return false;
> +	if (iter)
> +		return false;
> +	/*
> +	 * Make the owner of OOM lock to be the highest ancestor of hierarchy
> +	 * under OOM. IOW, move children's OOM owner information to this memcg
> +	 * if a child is owner. In this case, an OOM killer is running and
> +	 * we return false. But make this memcg as owner of oom-lock.
> +	 */
> +	ret = true;
> +	for_each_mem_cgroup_tree(iter, memcg) {
> +		if (iter->oom_lock) {
> +			iter->oom_lock = 0;
> +			ret = false;
> +		}
> +		atomic_set(&iter->under_oom, 1);
> +	}
> +	/* Make this memcg as the owner of OOM lock. */
> +	memcg->oom_lock = 1;
> +	return ret;
>  }
>  
> -static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
> +static void mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
>  {
> -	struct mem_cgroup *iter;
> +	struct mem_cgroup *iter, *iter2;
>  
> -	/*
> -	 * When a new child is created while the hierarchy is under oom,
> -	 * mem_cgroup_oom_lock() may not be called. We have to use
> -	 * atomic_add_unless() here.
> -	 */
> -	for_each_mem_cgroup_tree(iter, mem)
> -		atomic_add_unless(&iter->oom_lock, -1, 0);
> -	return 0;
> +	for (iter = memcg; iter != NULL; iter = parent_mem_cgroup(iter)) {
> +		if (iter->oom_lock) {
> +			iter->oom_lock = 0;
> +			break;
> +		}
> +	}
> +	BUG_ON(!iter);
> +
> +	for_each_mem_cgroup_tree(iter2, iter)
> +		atomic_set(&iter2->under_oom, 0);
> +	return;
>  }
>  
>  
> @@ -1875,7 +1903,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
>  
>  static void memcg_oom_recover(struct mem_cgroup *mem)
>  {
> -	if (mem && atomic_read(&mem->oom_lock))
> +	if (mem && atomic_read(&mem->under_oom))
>  		memcg_wakeup_oom(mem);
>  }
>  
> @@ -1916,7 +1944,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  	}
>  	mutex_lock(&memcg_oom_mutex);
> -	mem_cgroup_oom_unlock(mem);
> +	if (locked)
> +		mem_cgroup_oom_unlock(mem);
>  	memcg_wakeup_oom(mem);
>  	mutex_unlock(&memcg_oom_mutex);
>  
> @@ -4584,7 +4613,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
>  	list_add(&event->list, &memcg->oom_notify);
>  
>  	/* already in OOM ? */
> -	if (atomic_read(&memcg->oom_lock))
> +	if (atomic_read(&memcg->under_oom))
>  		eventfd_signal(eventfd, 1);
>  	mutex_unlock(&memcg_oom_mutex);
>  
> @@ -4619,7 +4648,7 @@ static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
>  
>  	cb->fill(cb, "oom_kill_disable", mem->oom_kill_disable);
>  
> -	if (atomic_read(&mem->oom_lock))
> +	if (atomic_read(&mem->under_oom))
>  		cb->fill(cb, "under_oom", 1);
>  	else
>  		cb->fill(cb, "under_oom", 0);
> -- 
> 1.7.4.1
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
