Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B520E6B005A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 01:18:28 -0400 (EDT)
Date: Wed, 2 Sep 2009 14:16:39 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mmotm][PATCH 2/2] memcg: reduce calls for soft limit excess
Message-Id: <20090902141639.565175d3.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090902093551.c8b171fb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902093551.c8b171fb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Sep 2009 09:35:51 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> In charge path, usage_in_excess is calculated repeatedly and
> it takes res_counter's spin_lock every time.
> 
Hmm, mem_cgroup_update_tree() is called in both charge and uncharge path.
So, this patch have effect on both path, doesn't it ?

> This patch removes unnecessary calls for res_count_soft_limit_excess.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   31 +++++++++++++++----------------
>  1 file changed, 15 insertions(+), 16 deletions(-)
> 
> Index: mmotm-2.6.31-Aug27/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.31-Aug27.orig/mm/memcontrol.c
> +++ mmotm-2.6.31-Aug27/mm/memcontrol.c
> @@ -313,7 +313,8 @@ soft_limit_tree_from_page(struct page *p
>  static void
>  __mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
>  				struct mem_cgroup_per_zone *mz,
> -				struct mem_cgroup_tree_per_zone *mctz)
> +				struct mem_cgroup_tree_per_zone *mctz,
> +				unsigned long new_usage_in_excess)
It might be a nitpick, shouldn't it be unsigned long long ?

Otherwise, it looks good to me.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

>  {
>  	struct rb_node **p = &mctz->rb_root.rb_node;
>  	struct rb_node *parent = NULL;
> @@ -322,7 +323,9 @@ __mem_cgroup_insert_exceeded(struct mem_
>  	if (mz->on_tree)
>  		return;
>  
> -	mz->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> +	mz->usage_in_excess = new_usage_in_excess;
> +	if (!mz->usage_in_excess)
> +		return;
>  	while (*p) {
>  		parent = *p;
>  		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
> @@ -382,7 +385,7 @@ static bool mem_cgroup_soft_limit_check(
>  
>  static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
>  {
> -	unsigned long long new_usage_in_excess;
> +	unsigned long long excess;
>  	struct mem_cgroup_per_zone *mz;
>  	struct mem_cgroup_tree_per_zone *mctz;
>  	int nid = page_to_nid(page);
> @@ -395,25 +398,21 @@ static void mem_cgroup_update_tree(struc
>  	 */
>  	for (; mem; mem = parent_mem_cgroup(mem)) {
>  		mz = mem_cgroup_zoneinfo(mem, nid, zid);
> -		new_usage_in_excess =
> -			res_counter_soft_limit_excess(&mem->res);
> +		excess = res_counter_soft_limit_excess(&mem->res);
>  		/*
>  		 * We have to update the tree if mz is on RB-tree or
>  		 * mem is over its softlimit.
>  		 */
> -		if (new_usage_in_excess || mz->on_tree) {
> +		if (excess || mz->on_tree) {
>  			spin_lock(&mctz->lock);
>  			/* if on-tree, remove it */
>  			if (mz->on_tree)
>  				__mem_cgroup_remove_exceeded(mem, mz, mctz);
>  			/*
> -			 * if over soft limit, insert again. mz->usage_in_excess
> -			 * will be updated properly.
> +			 * Insert again. mz->usage_in_excess will be updated.
> +			 * If excess is 0, no tree ops.
>  			 */
> -			if (new_usage_in_excess)
> -				__mem_cgroup_insert_exceeded(mem, mz, mctz);
> -			else
> -				mz->usage_in_excess = 0;
> +			__mem_cgroup_insert_exceeded(mem, mz, mctz, excess);
>  			spin_unlock(&mctz->lock);
>  		}
>  	}
> @@ -2216,6 +2215,7 @@ unsigned long mem_cgroup_soft_limit_recl
>  	unsigned long reclaimed;
>  	int loop = 0;
>  	struct mem_cgroup_tree_per_zone *mctz;
> +	unsigned long long excess;
>  
>  	if (order > 0)
>  		return 0;
> @@ -2260,9 +2260,8 @@ unsigned long mem_cgroup_soft_limit_recl
>  				__mem_cgroup_largest_soft_limit_node(mctz);
>  			} while (next_mz == mz);
>  		}
> -		mz->usage_in_excess =
> -			res_counter_soft_limit_excess(&mz->mem->res);
>  		__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
> +		excess = res_counter_soft_limit_excess(&mz->mem->res);
>  		/*
>  		 * One school of thought says that we should not add
>  		 * back the node to the tree if reclaim returns 0.
> @@ -2271,8 +2270,8 @@ unsigned long mem_cgroup_soft_limit_recl
>  		 * memory to reclaim from. Consider this as a longer
>  		 * term TODO.
>  		 */
> -		if (mz->usage_in_excess)
> -			__mem_cgroup_insert_exceeded(mz->mem, mz, mctz);
> +		/* If excess == 0, no tree ops */
> +		__mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
>  		spin_unlock(&mctz->lock);
>  		css_put(&mz->mem->css);
>  		loop++;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
