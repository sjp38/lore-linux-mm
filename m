Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 3DC5B6B007E
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 13:54:33 -0400 (EDT)
Date: Wed, 14 Mar 2012 18:54:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcg: count pte references from every member of
 the reclaimed hierarchy
Message-ID: <20120314175430.GJ4434@tiehlicka.suse.cz>
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
> The rmap walker checking page table references has historically
> ignored references from VMAs that were not part of the memcg that was
> being reclaimed during memcg hard limit reclaim.
> 
> When transitioning global reclaim to memcg hierarchy reclaim, I missed
> that bit and now references from outside a memcg are ignored even
> during global reclaim.
> 
> Reverting back to traditional behaviour - count all references during
> global reclaim and only mind references of the memcg being reclaimed
> during limit reclaim would be one option.
> 
> However, the more generic idea is to ignore references exactly then
> when they are outside the hierarchy that is currently under reclaim;
> because only then will their reclamation be of any use to help the
> pressure situation.  It makes no sense to ignore references from a
> sibling memcg and then evict a page that will be immediately refaulted
> by that sibling which contributes to the same usage of the common
> ancestor under reclaim.
> 
> The solution: make the rmap walker ignore references from VMAs that
> are not part of the hierarchy that is being reclaimed.
> 
> Flat limit reclaim will stay the same, hierarchical limit reclaim will
> mind the references only to pages that the hierarchy owns.  Global
> reclaim, since it reclaims from all memcgs, will be fixed to regard
> all references.
> 
> Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h |    6 +++++-
>  mm/memcontrol.c            |   16 +++++++++++-----
>  mm/vmscan.c                |    6 ++++--
>  3 files changed, 20 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8537c5d..661b54a 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -78,6 +78,7 @@ extern void mem_cgroup_uncharge_page(struct page *page);
>  extern void mem_cgroup_uncharge_cache_page(struct page *page);
>  
>  extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask);
> +bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *, struct mem_cgroup *);
>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
> @@ -88,10 +89,13 @@ static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
>  {
>  	struct mem_cgroup *memcg;
> +	int match;
> +
>  	rcu_read_lock();
>  	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
> +	match = __mem_cgroup_same_or_subtree(cgroup, memcg);
>  	rcu_read_unlock();
> -	return cgroup == memcg;
> +	return match;
>  }
>  
>  extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
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
>  
>  	/* Lumpy reclaim - ignore references */
> @@ -1710,7 +1711,8 @@ static void shrink_active_list(unsigned long nr_pages,
>  			continue;
>  		}
>  
> -		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags)) {
> +		if (page_referenced(page, 0, sc->target_mem_cgroup,
> +				    &vm_flags)) {
>  			nr_rotated += hpage_nr_pages(page);
>  			/*
>  			 * Identify referenced, file-backed active pages and
> -- 
> 1.7.7.6
> 

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
