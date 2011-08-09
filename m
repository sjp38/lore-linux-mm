Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1E96B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 11:43:51 -0400 (EDT)
Date: Tue, 9 Aug 2011 17:43:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-ID: <20110809154346.GA18800@tiehlicka.suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
 <44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
 <20110809140312.GA2265@redhat.com>
 <20110809152218.GK7463@tiehlicka.suse.cz>
 <20110809153732.GC13411@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809153732.GC13411@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue 09-08-11 17:37:32, Johannes Weiner wrote:
> On Tue, Aug 09, 2011 at 05:22:18PM +0200, Michal Hocko wrote:
> > On Tue 09-08-11 16:03:12, Johannes Weiner wrote:
> > >  	struct mem_cgroup *iter, *failed = NULL;
> > >  	bool cond = true;
> > >  
> > >  	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> > > -		bool locked = iter->oom_lock;
> > > -
> > > -		iter->oom_lock = true;
> > > -		if (lock_count == -1)
> > > -			lock_count = iter->oom_lock;
> > > -		else if (lock_count != locked) {
> > > +		if (iter->oom_lock) {
> > >  			/*
> > >  			 * this subtree of our hierarchy is already locked
> > >  			 * so we cannot give a lock.
> > >  			 */
> > > -			lock_count = 0;
> > >  			failed = iter;
> > >  			cond = false;
> > > -		}
> > > +		} else
> > > +			iter->oom_lock = true;
> > >  	}
> > >  
> > >  	if (!failed)
> > 
> > We can return here and get rid of done label.
> 
> Ah, right you are.  Here is an update.

Thanks!

> 
> ---
> From 86b36904033e6c6a1af4716e9deef13ebd31e64c Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <jweiner@redhat.com>
> Date: Tue, 9 Aug 2011 15:31:30 +0200
> Subject: [patch] memcg: fix hierarchical oom locking
> 
> Commit "79dfdac memcg: make oom_lock 0 and 1 based rather than
> counter" tried to oom lock the hierarchy and roll back upon
> encountering an already locked memcg.
> 
> The code is confused when it comes to detecting a locked memcg,
> though, so it would fail and rollback after locking one memcg and
> encountering an unlocked second one.

It is actually worse than that. The way how it is broken also allows to
lock a hierarchy which already contains locked subtree...

> 
> The result is that oom-locking hierarchies fails unconditionally and
> that every oom killer invocation simply goes to sleep on the oom
> waitqueue forever.  The tasks practically hang forever without anyone
> intervening, possibly holding locks that trip up unrelated tasks, too.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   17 +++++------------
>  1 files changed, 5 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c6faa32..f39c8fb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1843,29 +1843,23 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>   */
>  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
>  {
> -	int lock_count = -1;
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
> -		goto done;
> +		return true;
>  
>  	/*
>  	 * OK, we failed to lock the whole subtree so we have to clean up
> @@ -1879,8 +1873,7 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
>  		}
>  		iter->oom_lock = false;
>  	}
> -done:
> -	return lock_count;
> +	return false;
>  }
>  
>  /*
> -- 
> 1.7.6
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
