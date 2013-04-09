Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id EABD96B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:42:17 -0400 (EDT)
Date: Tue, 9 Apr 2013 15:42:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/3] memcg: Ignore soft limit until it is explicitly
 specified
Message-ID: <20130409134215.GI29860@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-3-git-send-email-mhocko@suse.cz>
 <20130409132406.GQ1953@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130409132406.GQ1953@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Tue 09-04-13 09:24:06, Johannes Weiner wrote:
> On Tue, Apr 09, 2013 at 02:13:14PM +0200, Michal Hocko wrote:
[...]
> > @@ -2062,14 +2066,15 @@ static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
> >  
> >  /*
> >   * A group is eligible for the soft limit reclaim if it is
> > - * 	a) is over its soft limit
> > - * 	b) any parent up the hierarchy is over its soft limit
> > + * 	a) doesn't have any soft limit set
> > + * 	b) is over its soft limit
> > + * 	c) any parent up the hierarchy is over its soft limit
> >   */
> >  bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
> >  {
> >  	struct mem_cgroup *parent = memcg;
> >  
> > -	if (res_counter_soft_limit_excess(&memcg->res))
> > +	if (!memcg->soft_limited || res_counter_soft_limit_excess(&memcg->res))
> >  		return true;
> 
> With the very similar condition in the hierarchy walk down there, this
> was more confusing than I would have expected it to be.
> 
> Would you mind splitting this check and putting the comments directly
> over the individual checks?
> 
> 	/* No specific soft limit set, eligible for soft reclaim */
> 	if (!memcg->soft_limited)
> 		return true;
> 
> 	/* Soft limit exceeded, eligible for soft reclaim */
> 	if (res_counter_soft_limit_excess(&memcg->res))
> 		return true;
> 
> 	/* Parental limit exceeded, eligible for... soft reclaim! */

Sure thing.

> 	...
> 
> > @@ -2077,7 +2082,8 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
> >  	 * have to obey and reclaim from this group as well.
> >  	 */
> >  	while((parent = parent_mem_cgroup(parent))) {
> > -		if (res_counter_soft_limit_excess(&parent->res))
> > +		if (memcg->soft_limited &&
> > +				res_counter_soft_limit_excess(&parent->res))
> >  			return true;
> 
> Should this be parent->soft_limited instead of memcg->softlimited?

Yes. I haven't tested with deeper hierarchies yet... Thanks for catching
this.

> 
> > @@ -5237,6 +5243,14 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
> >  			ret = res_counter_set_soft_limit(&memcg->res, val);
> >  		else
> >  			ret = -EINVAL;
> > +
> > +		/*
> > +		 * We could disable soft_limited when we get RESOURCE_MAX but
> > +		 * then we have a little problem to distinguish the default
> > +		 * unlimited and limitted but never soft reclaimed groups.
> > +		 */
> > +		if (!ret)
> > +			memcg->soft_limited = true;
> 
> It's neither reversible nor distinguishable from userspace, so it
> would be good to either find a value or just make the soft_limited
> knob explicit and accessible from userspace.

I can export the knob but I would like to prevent from that if possible.
So far it seems it would be hard to keep backward compatibility. I hoped
somebody would come up with something clever ;)

One possible way would be returning -1 if soft_limited == false. Users
who use u64 would see the same value in the end so they shouldn't break
and those that are _really_ interested can check the string value as
well. What do you think?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
