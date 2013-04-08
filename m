Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id AA7476B0103
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:57:03 -0400 (EDT)
Date: Mon, 8 Apr 2013 16:57:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/8] memcg: convert to use cgroup->id
Message-ID: <20130408145702.GM17178@dhcp22.suse.cz>
References: <51627DA9.7020507@huawei.com>
 <51627E33.4090107@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627E33.4090107@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon 08-04-13 16:22:11, Li Zefan wrote:
> This is a preparation to kill css_id.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

This patch depends on the following patch, doesn't it? There is no
guarantee that id fits into short right now. Not such a big deal but
would be nicer to have that guarantee for bisectability.

The patch on its own looks good.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3561d0b..c4e0173 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -492,6 +492,11 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>  	return (memcg == root_mem_cgroup);
>  }
>  
> +static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
> +{
> +	return memcg->css.cgroup->id;
> +}
> +
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
> @@ -4234,7 +4239,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  	 * css_get() was called in uncharge().
>  	 */
>  	if (do_swap_account && swapout && memcg)
> -		swap_cgroup_record(ent, css_id(&memcg->css));
> +		swap_cgroup_record(ent, mem_cgroup_id(memcg));
>  }
>  #endif
>  
> @@ -4286,8 +4291,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
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
> @@ -6428,7 +6433,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
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
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
