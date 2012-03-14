Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9E7BB6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 10:25:22 -0400 (EDT)
Date: Wed, 14 Mar 2012 15:25:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcg: count pte references from every member of
 the reclaimed hierarchy
Message-ID: <20120314142519.GF4434@tiehlicka.suse.cz>
References: <1330438489-21909-1-git-send-email-hannes@cmpxchg.org>
 <1330438489-21909-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1330438489-21909-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 28-02-12 15:14:49, Johannes Weiner wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b4622fb..21004df 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1044,17 +1044,23 @@ struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
>   * Checks whether given mem is same or in the root_mem_cgroup's
>   * hierarchy subtree
>   */
> -static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> -		struct mem_cgroup *memcg)
> +bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> +				  struct mem_cgroup *memcg)
>  {
> -	bool ret;
> -
>  	if (root_memcg == memcg)
>  		return true;
>  	if (!root_memcg->use_hierarchy)
>  		return false;
> +	return css_is_ancestor(&memcg->css, &root_memcg->css);
> +}
> +
> +static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> +				       struct mem_cgroup *memcg)
> +{
> +	bool ret;
> +
>  	rcu_read_lock();
> -	ret = css_is_ancestor(&memcg->css, &root_memcg->css);
> +	ret = __mem_cgroup_same_or_subtree(root_memcg, memcg);
>  	rcu_read_unlock();
>  	return ret;
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c631234..120646e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -708,7 +708,8 @@ static enum page_references page_check_references(struct page *page,
>  	int referenced_ptes, referenced_page;
>  	unsigned long vm_flags;
>  
> -	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
> +	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
> +					  &vm_flags);
>  	referenced_page = TestClearPageReferenced(page);

Maybe a stupid question but isn't target_mem_cgroup NULL in the global
reclaim case? And we doesn't handle that in __mem_cgroup_same_or_subtree...

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
