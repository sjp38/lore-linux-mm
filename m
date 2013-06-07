Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DD2386B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 20:52:47 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id a1so72261qcx.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2013 17:52:47 -0700 (PDT)
Date: Thu, 6 Jun 2013 17:52:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130607005242.GB16160@htj.dyndns.org>
References: <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
 <20130605172212.GA10693@mtj.dyndns.org>
 <20130605194552.GI15721@cmpxchg.org>
 <20130605200612.GH10693@mtj.dyndns.org>
 <20130605211704.GJ15721@cmpxchg.org>
 <20130605222021.GL10693@mtj.dyndns.org>
 <20130605222709.GM10693@mtj.dyndns.org>
 <20130606115031.GE7909@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130606115031.GE7909@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello,

On Thu, Jun 06, 2013 at 01:50:31PM +0200, Michal Hocko wrote:
> > Also, do we need to hold a lock?  It doesn't have to be completely
> > strict, so we might as well get away with something like,
> > 
> > 	for_each_cached_pos() {
> > 		if (hint == me) {
> > 			/* simple clearing implementation, we prolly wanna push it forward */
> > 			cached = xchg(hint, NULL);
> > 			if (cached)
> > 				css_put(cached);
> > 		}
> > 	}
> 
> This would be racy:
> mem_cgroup_iter
>   rcu_read_lock
>   __mem_cgroup_iter_next		cgroup_destroy_locked
>     css_tryget(memcg)
>   					  atomic_add(CSS_DEACT_BIAS)
>     					  offline_css(memcg)
> 					    xchg(memcg, NULL)
>   mem_cgroup_iter_update
>     iter->last_visited = memcg
>   rcy_read_unlock
> 
> But if it was called from call_rcu the we should be safe AFAICS.

Oh yeah, it is racy.  That's what I meant by "not having to be
completely strict".  The race window is small enough and it's not like
we're messing up refcnt or may end up with use-after-free.  Doing it
from RCU would make the race go away but I'm not sure whether the
extra RCU bouncing is worthwhile.  I don't know.  Maybe.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
