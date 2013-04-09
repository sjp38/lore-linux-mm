Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 0D3DD6B0038
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:24:13 -0400 (EDT)
Date: Tue, 9 Apr 2013 09:24:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 2/3] memcg: Ignore soft limit until it is explicitly
 specified
Message-ID: <20130409132406.GQ1953@cmpxchg.org>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365509595-665-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Tue, Apr 09, 2013 at 02:13:14PM +0200, Michal Hocko wrote:
> The soft limit has been traditionally initialized to RESOURCE_MAX
> which means that the group is soft unlimited by default. This was
> working more or less satisfactorily so far because the soft limit has
> been interpreted as a tool to hint memory reclaim which groups to
> reclaim first to free some memory so groups basically opted in for being
> reclaimed more.
> 
> While this feature might be really helpful it would be even nicer if
> the soft reclaim could be used as a certain working set protection -
> only groups over their soft limit are reclaimed as far as the reclaim
> is able to free memory. In order to accomplish this behavior we have to
> reconsider the default soft limit value because with the current default
> all groups would become soft unreclaimable and so the reclaim would have
> to fall back to ignoring soft reclaim altogether harming those groups
> that set up a limit as a protection against the reclaim. Changing the
> default soft limit to 0 wouldn't work either because all groups would
> become soft reclaimable as the parent's limit would overwrite all its
> children down the hierarchy.
> 
> This patch doesn't change the default soft limit value. Rather than that
> it distinguishes groups with the limit set by user by a per group flag.
> All groups are considered soft reclaimable regardless their limit until
> a limit is set. The default limit doesn't enforce reclaim down the
> hierarchy.
> 
> TODO: How do we present default unlimited vs. RESOURCE_MAX set by the
> user? One possible way could be returning -1 for RESOURCE_MAX && !soft_limited
> but this is a change in user interface. Although nothing explicitly says
> the value has to be greater > 0 I can imagine this could be PITA to use.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   22 ++++++++++++++++++----
>  1 file changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 33424d8..043d760 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -292,6 +292,10 @@ struct mem_cgroup {
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> +	/*
> +	 * Is the group soft limited?
> +	 */
> +	bool soft_limited;
>  	unsigned long kmem_account_flags; /* See KMEM_ACCOUNTED_*, below */
>  
>  	bool		oom_lock;
> @@ -2062,14 +2066,15 @@ static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
>  
>  /*
>   * A group is eligible for the soft limit reclaim if it is
> - * 	a) is over its soft limit
> - * 	b) any parent up the hierarchy is over its soft limit
> + * 	a) doesn't have any soft limit set
> + * 	b) is over its soft limit
> + * 	c) any parent up the hierarchy is over its soft limit
>   */
>  bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
>  {
>  	struct mem_cgroup *parent = memcg;
>  
> -	if (res_counter_soft_limit_excess(&memcg->res))
> +	if (!memcg->soft_limited || res_counter_soft_limit_excess(&memcg->res))
>  		return true;

With the very similar condition in the hierarchy walk down there, this
was more confusing than I would have expected it to be.

Would you mind splitting this check and putting the comments directly
over the individual checks?

	/* No specific soft limit set, eligible for soft reclaim */
	if (!memcg->soft_limited)
		return true;

	/* Soft limit exceeded, eligible for soft reclaim */
	if (res_counter_soft_limit_excess(&memcg->res))
		return true;

	/* Parental limit exceeded, eligible for... soft reclaim! */
	...

> @@ -2077,7 +2082,8 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
>  	 * have to obey and reclaim from this group as well.
>  	 */
>  	while((parent = parent_mem_cgroup(parent))) {
> -		if (res_counter_soft_limit_excess(&parent->res))
> +		if (memcg->soft_limited &&
> +				res_counter_soft_limit_excess(&parent->res))
>  			return true;

Should this be parent->soft_limited instead of memcg->softlimited?

> @@ -5237,6 +5243,14 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>  			ret = res_counter_set_soft_limit(&memcg->res, val);
>  		else
>  			ret = -EINVAL;
> +
> +		/*
> +		 * We could disable soft_limited when we get RESOURCE_MAX but
> +		 * then we have a little problem to distinguish the default
> +		 * unlimited and limitted but never soft reclaimed groups.
> +		 */
> +		if (!ret)
> +			memcg->soft_limited = true;

It's neither reversible nor distinguishable from userspace, so it
would be good to either find a value or just make the soft_limited
knob explicit and accessible from userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
