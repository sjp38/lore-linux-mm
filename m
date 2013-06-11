Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 9A0A76B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 03:27:45 -0400 (EDT)
Date: Tue, 11 Jun 2013 09:27:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130611072743.GB24031@dhcp22.suse.cz>
References: <20130605222021.GL10693@mtj.dyndns.org>
 <20130605222709.GM10693@mtj.dyndns.org>
 <20130606115031.GE7909@dhcp22.suse.cz>
 <20130607005242.GB16160@htj.dyndns.org>
 <20130607073754.GA8117@dhcp22.suse.cz>
 <20130607232557.GL14781@mtj.dyndns.org>
 <20130610080208.GB5138@dhcp22.suse.cz>
 <20130610195426.GC12461@mtj.dyndns.org>
 <20130610204801.GA21003@dhcp22.suse.cz>
 <20130610231358.GD12461@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130610231358.GD12461@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Mon 10-06-13 16:13:58, Tejun Heo wrote:
> Hey,
> 
> On Mon, Jun 10, 2013 at 10:48:01PM +0200, Michal Hocko wrote:
> > > Ooh, right, we don't need cleanup of the cached cursors on destruction
> > > if we get this correct - especially if we make cursors point to the
> > > next cgroup to visit as self is always the first one to visit. 
> > 
> > You would need to pin the next-to-visit memcg as well, so you need a
> > cleanup on the removal.
> 
> But that'd be one of the descendants of the said cgroup and there can
> no descendant left when the cgroup is being removed.  What am I
> missing?
            .
            .
            .
            A (cached=E)
	   /|\____________
          / |             \
	 B  D (cached=E)   F<
	/   |               \
       C<   E                G
            ^
	 removed

* D level cache - nobody left for either approach approach
* A level is 
	- F for next-to-visit
	- C for last_visited

You have to get up the hierarchy and handle root cgroup as a special
case for !root->use_hierarchy. Once you have non-NULL new cache the it
can be propagated without a new search (which I haven't realized when
working on this approach the last time - not that it would safe some
code in the end).

Makes sense?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
