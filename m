Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8CE346B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 03:55:42 -0400 (EDT)
Date: Tue, 11 Jun 2013 09:55:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130611075540.GD24031@dhcp22.suse.cz>
References: <20130606115031.GE7909@dhcp22.suse.cz>
 <20130607005242.GB16160@htj.dyndns.org>
 <20130607073754.GA8117@dhcp22.suse.cz>
 <20130607232557.GL14781@mtj.dyndns.org>
 <20130610080208.GB5138@dhcp22.suse.cz>
 <20130610195426.GC12461@mtj.dyndns.org>
 <20130610204801.GA21003@dhcp22.suse.cz>
 <20130610231358.GD12461@mtj.dyndns.org>
 <20130611072743.GB24031@dhcp22.suse.cz>
 <20130611074404.GE22530@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130611074404.GE22530@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Tue 11-06-13 00:44:04, Tejun Heo wrote:
> On Tue, Jun 11, 2013 at 09:27:43AM +0200, Michal Hocko wrote:
> >           .
> >           .
> >           .
> >           A (cached=E)
> >          /|\____________
> >         / |             \
> > 	 B  D (cached=E)   F<
> > 	/   |               \
> >      C<   E                G
> >           ^
> > 	 removed
> > 
> > * D level cache - nobody left for either approach approach
> > * A level is 
> > 	- F for next-to-visit
> > 	- C for last_visited
> > 
> > You have to get up the hierarchy and handle root cgroup as a special
> > case for !root->use_hierarchy. Once you have non-NULL new cache the it
> > can be propagated without a new search (which I haven't realized when
> > working on this approach the last time - not that it would safe some
> > code in the end).
> > 
> > Makes sense?
> 
> I don't think we're talking about the same thing.  I wasn't talking
> about skipping walking up the hierarchy (differently depending on
> use_hierarchy of course) when E is removed.  I was talking about
> skipped cleaning E's cache when removing E as it's guaranteed to be
> empty by then.

Ahh, sorry I have misread your reply then. You are right that caching
the next-to-visit would keep its own cache clean.

> The difference between caching the last and next one is that if we put
> the last one in the cache, E's cache could be pointing to itself and
> needs to be scanned.

Right.

> Not a big difference either way but if you combine that with the need
> for special rewinding which will basically come down to traversing the
> sibling list again, pointing to the next entry is just easier.
> 
> Anyways, I think we're getting too deep into details but one more
> thing, what do you mean by "non-NULL new cache"?

If you replace cached memcg by a new (non-NULL) one then all the parents
up the hierarchy can reuse the same replacement and do not have to
search again.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
