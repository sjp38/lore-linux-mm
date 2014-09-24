Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id CFCDF6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 12:47:43 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id x48so5118223wes.1
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 09:47:43 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id az8si7506793wib.60.2014.09.24.09.47.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 09:47:42 -0700 (PDT)
Received: by mail-wi0-f170.google.com with SMTP id fb4so6853625wid.1
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 09:47:41 -0700 (PDT)
Date: Wed, 24 Sep 2014 18:47:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] mm: memcontrol: convert reclaim iterator to simple
 css refcounting
Message-ID: <20140924164739.GA15897@dhcp22.suse.cz>
References: <1411161059-16552-1-git-send-email-hannes@cmpxchg.org>
 <20140919212843.GA23861@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140919212843.GA23861@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 19-09-14 17:28:43, Johannes Weiner wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 19 Sep 2014 12:39:18 -0400
> Subject: [patch v2] mm: memcontrol: convert reclaim iterator to simple css
>  refcounting
> 
> The memcg reclaim iterators use a complicated weak reference scheme to
> prevent pinning cgroups indefinitely in the absence of memory pressure.
> 
> However, during the ongoing cgroup core rework, css lifetime has been
> decoupled such that a pinned css no longer interferes with removal of
> the user-visible cgroup, and all this complexity is now unnecessary.

I very much welcome simplification in this area but I would also very much
appreciate more details why some checks are no longer needed. Why don't
we need ->generation or (next_css->flags & CSS_ONLINE) check anymore?

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 201 ++++++++++----------------------------------------------
>  1 file changed, 34 insertions(+), 167 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index dfd3b15a57e8..154161bb7d4c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
>  	rcu_read_lock();
> -	while (!memcg) {
> -		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
> -		int uninitialized_var(seq);
>  
> -		if (reclaim) {
> -			struct mem_cgroup_per_zone *mz;
> +	if (reclaim) {
> +		mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
> +		priority = reclaim->priority;
>  
> -			mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
> -			iter = &mz->reclaim_iter[reclaim->priority];
> -			if (prev && reclaim->generation != iter->generation) {
> -				iter->last_visited = NULL;
> -				goto out_unlock;
> -			}
> -
> -			last_visited = mem_cgroup_iter_load(iter, root, &seq);
> -		}
> -
> -		memcg = __mem_cgroup_iter_next(root, last_visited);
> +		do {
> +			pos = ACCESS_ONCE(mz->reclaim_iter[priority]);
> +		} while (pos && !css_tryget(&pos->css));

This is a bit confusing. AFAIU css_tryget fails only when the current
ref count is zero already. When do we keep cached memcg with zero count
behind? We always do css_get after cmpxchg.

Hmm, there is a small window between cmpxchg and css_get when we store
the current memcg into the reclaim_iter[priority]. If the current memcg
is root then we do not take any css reference before cmpxchg and so it
might drop down to zero in the mean time so other CPU might see zero I
guess. But I do not see how css_get after cmpxchg on such css works.
I guess I should go and check the css reference counting again.

Anyway this would deserve a comment.

> +	}
>  
> -		if (reclaim) {
> -			mem_cgroup_iter_update(iter, last_visited, memcg, root,
> -					seq);
> +	if (pos)
> +		css = &pos->css;
>  
> -			if (!memcg)
> -				iter->generation++;
> -			else if (!prev && memcg)
> -				reclaim->generation = iter->generation;
> +	for (;;) {
> +		css = css_next_descendant_pre(css, &root->css);
> +		if (!css) {
> +			if (prev)
> +				goto out_unlock;
> +			continue;
> +		}
> +		if (css == &root->css || css_tryget_online(css)) {
> +			memcg = mem_cgroup_from_css(css);
> +			break;
>  		}
> +	}
>  
> -		if (prev && !memcg)
> -			goto out_unlock;
> +	if (reclaim) {
> +		if (cmpxchg(&mz->reclaim_iter[priority], pos, memcg) == pos)
> +			css_get(&memcg->css);
> +		if (pos)
> +			css_put(&pos->css);
>  	}
> +
>  out_unlock:
>  	rcu_read_unlock();
> -out_css_put:
> +out:
>  	if (prev && prev != root)
>  		css_put(&prev->css);
>  
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
