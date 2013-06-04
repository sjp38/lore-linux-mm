Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 60DEF6B003A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 09:18:45 -0400 (EDT)
Date: Tue, 4 Jun 2013 15:18:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130604131843.GF31242@dhcp22.suse.cz>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370306679-13129-4-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Mon 03-06-13 17:44:39, Tejun Heo wrote:
[...]
> @@ -1267,7 +1226,20 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			break;
>  
>  		iter->generation++;
> +		last_visited = NULL;
>  	}
> +
> +	/*
> +	 * Update @iter to the new position.  As multiple tasks could be
> +	 * executing this path, atomically swap the new and old.  We want
> +	 * RCU assignment here but there's no rcu_xchg() and the plain
> +	 * xchg() has enough memory barrier semantics.
> +	 */
> +	if (memcg)
> +		css_get(&memcg->css);

This is all good and nice but it re-introduces the same problem which
has been fixed by (5f578161: memcg: relax memcg iter caching). You are
pinning memcg in memory for unbounded amount of time because css
reference will not let object to leave and rest.

I understand your frustration about the complexity of the current
synchronization but we didn't come up with anything easier.
Originally I though that your tree walk updates which allow dropping rcu
would help here but then I realized that not really because the iterator
(resp. pos) has to be a valid pointer and there is only one possibility
to do that AFAICS here and that is css pinning. And is no-go.

> +	last_visited = xchg(&iter->last_visited, memcg);
> +	if (last_visited)
> +		css_put(&last_visited->css);
>  out_unlock:
>  	rcu_read_unlock();
>  out_css_put:
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
