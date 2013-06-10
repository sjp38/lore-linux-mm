Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id EA0616B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 16:48:05 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id d41so2166060eek.5
        for <linux-mm@kvack.org>; Mon, 10 Jun 2013 13:48:04 -0700 (PDT)
Date: Mon, 10 Jun 2013 22:48:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130610204801.GA21003@dhcp22.suse.cz>
References: <20130605200612.GH10693@mtj.dyndns.org>
 <20130605211704.GJ15721@cmpxchg.org>
 <20130605222021.GL10693@mtj.dyndns.org>
 <20130605222709.GM10693@mtj.dyndns.org>
 <20130606115031.GE7909@dhcp22.suse.cz>
 <20130607005242.GB16160@htj.dyndns.org>
 <20130607073754.GA8117@dhcp22.suse.cz>
 <20130607232557.GL14781@mtj.dyndns.org>
 <20130610080208.GB5138@dhcp22.suse.cz>
 <20130610195426.GC12461@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130610195426.GC12461@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Mon 10-06-13 12:54:26, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Jun 10, 2013 at 10:02:08AM +0200, Michal Hocko wrote:
> > Sure a next visit on the same root subtree (same node, zone and prio)
> > would css_put it but what if that root goes away itself. Still fixable,
> > if every group checks its own cached iters and css_put everybody but
> > that is even uglier. So doing the up-the-hierarchy cleanup in RCU
> > callback is much easier.
> 
> Ooh, right, we don't need cleanup of the cached cursors on destruction
> if we get this correct - especially if we make cursors point to the
> next cgroup to visit as self is always the first one to visit. 

You would need to pin the next-to-visit memcg as well, so you need a
cleanup on the removal.

> Yeah, if we can do away with that, doing that way is definitely
> better.

The only advantage I can see from next-to-visit caching is that the
destruction path can reuse __mem_cgroup_iter_next unlike last_visited
which would need to develop a code to get the previous member. Maybe it
is worth a try.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
