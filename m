Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id D94886B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:45:09 -0500 (EST)
Date: Thu, 8 Mar 2012 12:45:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3.3] memcg: free mem_cgroup by RCU to fix oops
Message-Id: <20120308124504.3639ce78.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils>
References: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Tejun Heo <tj@kernel.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Mar 2012 22:01:50 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> After fixing the GPF in mem_cgroup_lru_del_list(), three times one
> machine running a similar load (moving and removing memcgs while swapping)
> has oopsed in mem_cgroup_zone_nr_lru_pages(), when retrieving memcg zone
> numbers for get_scan_count() for shrink_mem_cgroup_zone(): this is where a
> struct mem_cgroup is first accessed after being chosen by mem_cgroup_iter().
> 
> Just what protects a struct mem_cgroup from being freed, in between
> mem_cgroup_iter()'s css_get_next() and its css_tryget()?  css_tryget()
> fails once css->refcnt is zero with CSS_REMOVED set in flags, yes: but
> what if that memory is freed and reused for something else, which sets
> "refcnt" non-zero?  Hmm, and scope for an indefinite freeze if refcnt
> is left at zero but flags are cleared.
> 
> It's tempting to move the css_tryget() into css_get_next(), to make it
> really "get" the css, but I don't think that actually solves anything:
> the same difficulty in moving from css_id found to stable css remains.
> 
> But we already have rcu_read_lock() around the two, so it's easily
> fixed if __mem_cgroup_free() just uses kfree_rcu() to free mem_cgroup.
> 
> However, a big struct mem_cgroup is allocated with vzalloc() instead
> of kzalloc(), and we're not allowed to vfree() at interrupt time:
> there doesn't appear to be a general vfree_rcu() to help with this,
> so roll our own using schedule_work().  The compiler decently removes
> vfree_work() and vfree_rcu() when the config doesn't need them.
> 
> ...
>
> @@ -4780,6 +4800,27 @@ out_free:
>  }
>  
>  /*
> + * Helpers for freeing a vzalloc()ed mem_cgroup by RCU,
> + * but in process context.  The work_freeing structure is overlaid
> + * on the rcu_freeing structure, which itself is overlaid on memsw.
> + */
> +static void vfree_work(struct work_struct *work)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	memcg = container_of(work, struct mem_cgroup, work_freeing);
> +	vfree(memcg);
> +}
> +static void vfree_rcu(struct rcu_head *rcu_head)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	memcg = container_of(rcu_head, struct mem_cgroup, rcu_freeing);
> +	INIT_WORK(&memcg->work_freeing, vfree_work);
> +	schedule_work(&memcg->work_freeing);
> +}
> +
> +/*
>   * At destroying mem_cgroup, references from swap_cgroup can remain.
>   * (scanning all at force_empty is too costly...)
>   *
> @@ -4802,9 +4843,9 @@ static void __mem_cgroup_free(struct mem
>  
>  	free_percpu(memcg->stat);
>  	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
> -		kfree(memcg);
> +		kfree_rcu(memcg, rcu_freeing);
>  	else
> -		vfree(memcg);
> +		call_rcu(&memcg->rcu_freeing, vfree_rcu);
>  }
>  

It's fairly possible that a vfree_rcu() will later turn up in
vmalloc.c.  I guess that for now, it's OK to add a private version and
we can cut-n-paste it over when the need arises..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
