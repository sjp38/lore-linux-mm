Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E476D6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 11:22:23 -0400 (EDT)
Date: Tue, 9 Aug 2011 17:22:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-ID: <20110809152218.GK7463@tiehlicka.suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
 <44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
 <20110809140312.GA2265@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809140312.GA2265@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue 09-08-11 16:03:12, Johannes Weiner wrote:
> On Wed, Jul 13, 2011 at 01:05:49PM +0200, Michal Hocko wrote:
> > @@ -1803,37 +1806,83 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  /*
> >   * Check OOM-Killer is already running under our hierarchy.
> >   * If someone is running, return false.
> > + * Has to be called with memcg_oom_mutex
> >   */
> >  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> >  {
> > -	int x, lock_count = 0;
> > -	struct mem_cgroup *iter;
> > +	int lock_count = -1;
> > +	struct mem_cgroup *iter, *failed = NULL;
> > +	bool cond = true;
> >  
> > -	for_each_mem_cgroup_tree(iter, mem) {
> > -		x = atomic_inc_return(&iter->oom_lock);
> > -		lock_count = max(x, lock_count);
> > +	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> > +		bool locked = iter->oom_lock;
> > +
> > +		iter->oom_lock = true;
> > +		if (lock_count == -1)
> > +			lock_count = iter->oom_lock;
> > +		else if (lock_count != locked) {
> > +			/*
> > +			 * this subtree of our hierarchy is already locked
> > +			 * so we cannot give a lock.
> > +			 */
> > +			lock_count = 0;
> > +			failed = iter;
> > +			cond = false;
> > +		}
> 
> I noticed system-wide hangs during a parallel/hierarchical memcg test
> and found that a single task with a central i_mutex held was sleeping
> on the memcg oom waitqueue, stalling everyone else contending for that
> same inode.

Nasty. Thanks for reporting and fixing this. The condition is screwed
totally :/

> 
> The problem is the above code, which never succeeds in hierarchies
> with more than one member.  The first task going OOM tries to oom lock
> the hierarchy, fails, goes to sleep on the OOM waitqueue with the
> mutex held, without anybody actually OOM killing anything to make
> progress.
> 
> Here is a patch that rectified things for me.
> 
> ---
> From c4b52cbe01ed67d6487a96850400cdf5a9de91aa Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <jweiner@redhat.com>
> Date: Tue, 9 Aug 2011 15:31:30 +0200
> Subject: [patch] memcg: fix hierarchical oom locking
> 
> Commit "79dfdac memcg: make oom_lock 0 and 1 based rather than
> counter" tried to oom lock the hierarchy and roll back upon
> encountering an already locked memcg.
> 
> The code is pretty confused when it comes to detecting a locked memcg,
> though, so it would fail and rollback after locking one memcg and
> encountering an unlocked second one.
> 
> The result is that oom-locking hierarchies fails unconditionally and
> that every oom killer invocation simply goes to sleep on the oom
> waitqueue forever.  The tasks practically hang forever without anyone
> intervening, possibly holding locks that trip up unrelated tasks, too.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Looks good. Thanks!
Just a minor nit about done label bellow.

Acked-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   14 ++++----------
>  1 files changed, 4 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 930de94..649c568 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1841,25 +1841,19 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>   */
>  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
>  {
> -	int lock_count = -1;

Yes, the whole lock_count thingy is just stupid. We care just about all
or nothing and state of the first is really not important.

>  	struct mem_cgroup *iter, *failed = NULL;
>  	bool cond = true;
>  
>  	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> -		bool locked = iter->oom_lock;
> -
> -		iter->oom_lock = true;
> -		if (lock_count == -1)
> -			lock_count = iter->oom_lock;
> -		else if (lock_count != locked) {
> +		if (iter->oom_lock) {
>  			/*
>  			 * this subtree of our hierarchy is already locked
>  			 * so we cannot give a lock.
>  			 */
> -			lock_count = 0;
>  			failed = iter;
>  			cond = false;
> -		}
> +		} else
> +			iter->oom_lock = true;
>  	}
>  
>  	if (!failed)

We can return here and get rid of done label.

> @@ -1878,7 +1872,7 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
>  		iter->oom_lock = false;
>  	}
>  done:
> -	return lock_count;
> +	return failed == NULL;
>  }
>  
>  /*
> -- 
> 1.7.6

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
