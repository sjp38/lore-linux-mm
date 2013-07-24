Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 4C4076B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 10:25:59 -0400 (EDT)
Date: Wed, 24 Jul 2013 16:25:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 5/8] memcg: convert to use cgroup id
Message-ID: <20130724142557.GH2540@dhcp22.suse.cz>
References: <51EFA554.6080801@huawei.com>
 <51EFA611.8000706@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51EFA611.8000706@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 24-07-13 18:01:53, Li Zefan wrote:
> Use cgroup id instead of css id. This is a preparation to kill css id.
> 
> Note, as memcg treats 0 as an invalid id, while cgroup id starts with 0,
> we define memcg_id == cgroup_id + 1.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

two thing bellow

> ---
>  mm/memcontrol.c | 25 +++++++++++++++++--------
>  1 file changed, 17 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 626c426..35d8286 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -512,6 +512,15 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>  	return (memcg == root_mem_cgroup);
>  }
>  
> +static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
> +{
> +	/*
> +	 * The ID of the root cgroup is 0, but memcg treat 0 as an
> +	 * valid ID, so we return (cgroup_id + 1).

s/valid/invalid/ you meant, right?

> +	 */
> +	return memcg->css.cgroup->id + 1;
> +}
> +

Could you add mem_cgroup_from_id(short id) which would hide "id - 1".

>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
> @@ -2821,15 +2830,15 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
>   */
>  static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>  {
> -	struct cgroup_subsys_state *css;
> +	struct cgroup *cgrp;
>  
>  	/* ID 0 is unused ID */
>  	if (!id)
>  		return NULL;
> -	css = css_lookup(&mem_cgroup_subsys, id);
> -	if (!css)
> +	cgrp = cgroup_from_id(&mem_cgroup_subsys, id - 1);
> +	if (!cgrp)
>  		return NULL;
> -	return mem_cgroup_from_css(css);
> +	return mem_cgroup_from_cont(cgrp);
>  }
>  
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> @@ -4328,7 +4337,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  	 * css_get() was called in uncharge().
>  	 */
>  	if (do_swap_account && swapout && memcg)
> -		swap_cgroup_record(ent, css_id(&memcg->css));
> +		swap_cgroup_record(ent, mem_cgroup_id(memcg));
>  }
>  #endif
>  
> @@ -4380,8 +4389,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>  {
>  	unsigned short old_id, new_id;
>  
> -	old_id = css_id(&from->css);
> -	new_id = css_id(&to->css);
> +	old_id = mem_cgroup_id(from);
> +	new_id = mem_cgroup_id(to);
>  
>  	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
>  		mem_cgroup_swap_statistics(from, false);
> @@ -6542,7 +6551,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
>  	}
>  	/* There is a swap entry and a page doesn't exist or isn't charged */
>  	if (ent.val && !ret &&
> -			css_id(&mc.from->css) == lookup_swap_cgroup_id(ent)) {
> +	    mem_cgroup_id(mc.from) == lookup_swap_cgroup_id(ent)) {
>  		ret = MC_TARGET_SWAP;
>  		if (target)
>  			target->ent = ent;
> -- 
> 1.8.0.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
