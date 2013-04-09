Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 98B866B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:22:14 -0400 (EDT)
Date: Tue, 9 Apr 2013 19:22:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/3] memcg: Ignore soft limit until it is explicitly
 specified
Message-ID: <20130409172211.GO29860@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-3-git-send-email-mhocko@suse.cz>
 <51644B94.9060004@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51644B94.9060004@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Wed 10-04-13 02:10:44, KAMEZAWA Hiroyuki wrote:
> (2013/04/09 21:13), Michal Hocko wrote:
> > The soft limit has been traditionally initialized to RESOURCE_MAX
> > which means that the group is soft unlimited by default. This was
> > working more or less satisfactorily so far because the soft limit has
> > been interpreted as a tool to hint memory reclaim which groups to
> > reclaim first to free some memory so groups basically opted in for being
> > reclaimed more.
> > 
> > While this feature might be really helpful it would be even nicer if
> > the soft reclaim could be used as a certain working set protection -
> > only groups over their soft limit are reclaimed as far as the reclaim
> > is able to free memory. In order to accomplish this behavior we have to
> > reconsider the default soft limit value because with the current default
> > all groups would become soft unreclaimable and so the reclaim would have
> > to fall back to ignoring soft reclaim altogether harming those groups
> > that set up a limit as a protection against the reclaim. Changing the
> > default soft limit to 0 wouldn't work either because all groups would
> > become soft reclaimable as the parent's limit would overwrite all its
> > children down the hierarchy.
> > 
> > This patch doesn't change the default soft limit value. Rather than that
> > it distinguishes groups with the limit set by user by a per group flag.
> > All groups are considered soft reclaimable regardless their limit until
> > a limit is set. The default limit doesn't enforce reclaim down the
> > hierarchy.
> > 
> > TODO: How do we present default unlimited vs. RESOURCE_MAX set by the
> > user? One possible way could be returning -1 for RESOURCE_MAX && !soft_limited
> > but this is a change in user interface. Although nothing explicitly says
> > the value has to be greater > 0 I can imagine this could be PITA to use.
> > 
> 
> Hmm..
> 
> Now, if a user sets soft_limit to a memcg, it will be a victim. All other
> cgroups, which has default value, will be 2nd choice for memory reclaim.

Not really. All those with the default value will be the 1sth choice along
with those that are over the limit. Just to make sure we are on the same
page this is what I have currently after Johannes feedback:
bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
{
	struct mem_cgroup *parent = memcg;

	/* No specific soft limit set, eligible for soft reclaim */
	if (!memcg->soft_limited)
		return true;

	/* Soft limit exceeded, eligible for soft reclaim */
	if (res_counter_soft_limit_excess(&memcg->res))
		return true;

	/*
	 * If any parent up the hierarchy is over its soft limit then we
	 * have to obey and reclaim from this group as well.
	 */
	while((parent = parent_mem_cgroup(parent))) {
		if (parent->soft_limited &&
				res_counter_soft_limit_excess(&parent->res))
			return true;
	}

	return false;
}

Does this make more sense to you?

> When user sets RESOURCE_MAX, it will be 2nd choice, too.

No, it will be never soft reclaimed because it would have
memcg->soft_limited == true.

> In this case, soft-limit is for creating victims.
> 
> You want the another configuration that all cgroup must be 1st choice
> with the default value and protect memcg which has some soft-limit value.
> In this case, soft-limit is for protection.

Why should we distinguish default setting from over-the-limit groups?

> i.e. an opposite policy.
> 
> How about allowing users to set root memcg's soft-limit (to be 0 ?)

This is not forbidden AFAICS in mem_cgroup_write for RES_SOFT_LIMIT.
The 0 @ root is not good as I tried to explain in the changelog because
this would make a hiararchical pressure on all children so their limit
would be ignored basically.

> and allow the new choice of protection before creating children
> memcgs? (I think you can make this default policy as CONFIG option or
> some...)  Users can choice global soft-limit policy.  Complicated ?

Yes and I do not understand why a CONFIG option is needed.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
