Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 63AD66B0082
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 07:57:38 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 184233EE0AE
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 20:57:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E5B9145DE66
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 20:57:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE22B45DE57
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 20:57:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0FB01DB8040
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 20:57:34 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C816C1DB803F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 20:57:32 +0900 (JST)
Date: Thu, 14 Jul 2011 20:50:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-Id: <20110714205012.8b78691e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110714113009.GL19408@tiehlicka.suse.cz>
References: <cover.1310561078.git.mhocko@suse.cz>
	<50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
	<20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714090017.GD19408@tiehlicka.suse.cz>
	<20110714183014.8b15e9b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714095152.GG19408@tiehlicka.suse.cz>
	<20110714191728.058859cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714110935.GK19408@tiehlicka.suse.cz>
	<20110714113009.GL19408@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 14 Jul 2011 13:30:09 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> What about this? Just compile tested:
> --- 
> From 90ab974eb69c61c2e3b94beabe9b6745fa319936 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 13 Jul 2011 13:05:49 +0200
> Subject: [PATCH] memcg: make oom_lock 0 and 1 based rather than coutner
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
> Consider a process (call it A) which gets the oom_lock (the first one
> that got to mem_cgroup_handle_oom and grabbed memcg_oom_mutex). All
> other processes are blocked on the mutex.
> While A releases the mutex and calls mem_cgroup_out_of_memory others
> will wake up (one after another) and increase the counter and fall into
> sleep (memcg_oom_waitq). Once A finishes mem_cgroup_out_of_memory it
> takes the mutex again and decreases oom_lock and wakes other tasks (if
> releasing memory of the killed task hasn't done it yet).
> The main problem here is that everybody still race for the mutex and
> there is no guarantee that we will get counter back to 0 for those
> that got back to mem_cgroup_handle_oom. In the end the whole convoy
> in/decreases the counter but we do not get to 1 that would enable
> killing so nothing useful is going on.
> The time is basically unbounded because it highly depends on scheduling
> and ordering on mutex.
> 
> This patch replaces the counter by a simple {un}lock semantic. We are
> using only 0 and 1 to distinguish those two states.
> As mem_cgroup_oom_{un}lock works on the a subtree of a hierarchy we have
> to make sure that nobody else races with us which is guaranteed by the
> memcg_oom_mutex. All other consumers just read the value atomically for
> a single group which is sufficient because we set the value atomically.
> mem_cgroup_oom_lock has to be really careful because we might be in
> higher in a hierarchy than already oom locked subtree of the same
> hierarchy:
>           A
>         /   \
>        B     \
>       /\      \
>      C  D     E
> 
> B - C - D tree might be already locked. While we want to enable locking E
> subtree because OOM situations cannot influence each other we definitely
> do not want to allow locking A.
> Therefore we have to refuse lock if any subtree is already locked and
> clear up the lock for all nodes that have been set up to the failure
> point.
> Unlock path is then very easy because we always unlock only that subtree
> we have locked previously.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   48 +++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 39 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e013b8e..29f00d0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1803,22 +1803,51 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  /*
>   * Check OOM-Killer is already running under our hierarchy.
>   * If someone is running, return false.
> + * Has to be called with memcg_oom_mutex
>   */
>  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
>  {
> -	int x, lock_count = 0;
> -	struct mem_cgroup *iter;
> +	int x, lock_count = -1;
> +	struct mem_cgroup *iter, *failed = NULL;
> +	bool cond = true;
>  
> -	for_each_mem_cgroup_tree(iter, mem) {
> -		x = atomic_inc_return(&iter->oom_lock);
> -		lock_count = max(x, lock_count);
> +	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> +		if (lock_count == -1)
> +			lock_count = x;
> +		else if (lock_count != x) {
> +			/*
> +			 * this subtree of our hierarchy is already locked
> +			 * so we cannot give a lock.
> +			 */
> +			lock_count = 0;
> +			failed = iter;
> +			cond = false;
> +		}
>  	}

Hm ? assuming B-C-D is locked and a new thread tries a lock on A-B-C-D-E.
And for_each_mem_cgroup_tree will find groups in order of A->B->C->D->E.
Before lock
  A  0
  B  1
  C  1
  D  1
  E  0

After lock
  A  1
  B  1
  C  1
  D  1
  E  0

here, failed = B, cond = false. Undo routine will unlock A.
Hmm, seems to work in this case.

But....A's oom_lock==0 and memcg_oom_wakeup() at el will not able to
know "A" is in OOM. wakeup processes in A which is waiting for oom recover..

Will this work ?
==
 # cgcreate -g memory:A
 # cgset -r memory.use_hierarchy=1 A
 # cgset -r memory.oom_control=1   A
 # cgset -r memory.limit_in_bytes= 100M
 # cgset -r memory.memsw.limit_in_bytes= 100M
 # cgcreate -g memory:A/B
 # cgset -r memory.oom_control=1 A/B
 # cgset -r memory.limit_in_bytes=20M
 # cgset -r memory.memsw.limit_in_bytes=20M

 Assume malloc XXX is a program allocating XXX Megabytes of memory.

 # cgexec -g memory:A/B malloc 30  &    #->this will be blocked by OOM of group B
 # cgexec -g memory:A   malloc 80  &    #->this will be blocked by OOM of group A


Here, 2 procs are blocked by OOM. Here, relax A's limitation and clear OOM.

 # cgset -r memory.memsw.limit_in_bytes=300M A
 # cgset -r memory.limit_in_bytes=300M A

 malloc 80 will end.

Thanks,
-Kame




>  
> -	if (lock_count == 1)
> -		return true;
> -	return false;
> +	if (!failed)
> +		goto done;
> +
> +	/*
> +	 * OK, we failed to lock the whole subtree so we have to clean up
> +	 * what we set up to the failing subtree
> +	 */
> +	cond = true;
> +	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> +		if (iter == failed) {
> +			cond = false;
> +			continue;
> +		}
> +		atomic_set(&iter->oom_lock, 0)
> +	}









> +done:
> +	return lock_count;
>  }
>  
> +/*
> + * Has to be called with memcg_oom_mutex
> + */
>  static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
>  {
>  	struct mem_cgroup *iter;
> @@ -1916,7 +1945,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  	}
>  	mutex_lock(&memcg_oom_mutex);
> -	mem_cgroup_oom_unlock(mem);
> +	if (locked)
> +		mem_cgroup_oom_unlock(mem);
>  	memcg_wakeup_oom(mem);
>  	mutex_unlock(&memcg_oom_mutex);
>  
> -- 
> 1.7.5.4
> 
> 
> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
