Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 973E26B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 07:50:33 -0400 (EDT)
Date: Thu, 6 Jun 2013 13:50:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130606115031.GE7909@dhcp22.suse.cz>
References: <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
 <20130605172212.GA10693@mtj.dyndns.org>
 <20130605194552.GI15721@cmpxchg.org>
 <20130605200612.GH10693@mtj.dyndns.org>
 <20130605211704.GJ15721@cmpxchg.org>
 <20130605222021.GL10693@mtj.dyndns.org>
 <20130605222709.GM10693@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605222709.GM10693@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed 05-06-13 15:27:09, Tejun Heo wrote:
> On Wed, Jun 05, 2013 at 03:20:21PM -0700, Tejun Heo wrote:
> > Yo,
> > 
> > On Wed, Jun 05, 2013 at 05:17:04PM -0400, Johannes Weiner wrote:
> > > That could be an advantage, yes.  But keep in mind that every
> > > destruction has to perform this invalidation operation against the
> > > global root_mem_cgroup's nr_node * nr_zone * nr_priority_levels
> > > iterators, so you can't muck around forever, while possibly holding a
> > > lock at this level.  It's not a hot path, but you don't want to turn
> > > it into one, either.
> > 
> > nr_node tends to be pretty low in most cases, so it shouldn't be a
> > problem there but yeah with high enough nodes and high enough rate of
> 
> Also, do we need to hold a lock?  It doesn't have to be completely
> strict, so we might as well get away with something like,
> 
> 	for_each_cached_pos() {
> 		if (hint == me) {
> 			/* simple clearing implementation, we prolly wanna push it forward */
> 			cached = xchg(hint, NULL);
> 			if (cached)
> 				css_put(cached);
> 		}
> 	}

This would be racy:
mem_cgroup_iter
  rcu_read_lock
  __mem_cgroup_iter_next		cgroup_destroy_locked
    css_tryget(memcg)
  					  atomic_add(CSS_DEACT_BIAS)
    					  offline_css(memcg)
					    xchg(memcg, NULL)
  mem_cgroup_iter_update
    iter->last_visited = memcg
  rcy_read_unlock

But if it was called from call_rcu the we should be safe AFAICS.

> It still scans the memory but wouldn't create any contention.
> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
