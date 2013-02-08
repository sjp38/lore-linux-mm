Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 7C9596B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 14:33:33 -0500 (EST)
Date: Fri, 8 Feb 2013 14:33:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130208193318.GA15951@cmpxchg.org>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
 <1357235661-29564-5-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357235661-29564-5-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Thu, Jan 03, 2013 at 06:54:18PM +0100, Michal Hocko wrote:
> Now that per-node-zone-priority iterator caches memory cgroups rather
> than their css ids we have to be careful and remove them from the
> iterator when they are on the way out otherwise they might hang for
> unbounded amount of time (until the global/targeted reclaim triggers the
> zone under priority to find out the group is dead and let it to find the
> final rest).
> 
> This is solved by hooking into mem_cgroup_css_offline and checking all
> per-node-zone-priority iterators up the way to the root cgroup. If the
> current memcg is found in the respective iter->last_visited then it is
> replaced by the previous one in the same sub-hierarchy.
> 
> This guarantees that no group gets more reclaiming than necessary and
> the next iteration will continue without noticing that the removed group
> has disappeared.
> 
> Spotted-by: Ying Han <yinghan@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 89 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e9f5c47..4f81abd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6375,10 +6375,99 @@ free_out:
>  	return ERR_PTR(error);
>  }
>  
> +/*
> + * Helper to find memcg's previous group under the given root
> + * hierarchy.
> + */
> +struct mem_cgroup *__find_prev_memcg(struct mem_cgroup *root,
> +		struct mem_cgroup *memcg)
> +{
> +	struct cgroup *memcg_cgroup = memcg->css.cgroup;
> +	struct cgroup *root_cgroup = root->css.cgroup;
> +	struct cgroup *prev_cgroup = NULL;
> +	struct cgroup *iter;
> +
> +	cgroup_for_each_descendant_pre(iter, root_cgroup) {
> +		if (iter == memcg_cgroup)
> +			break;
> +		prev_cgroup = iter;
> +	}
> +
> +	return (prev_cgroup) ? mem_cgroup_from_cont(prev_cgroup) : NULL;
> +}
> +
> +/*
> + * Remove the given memcg under given root from all per-node per-zone
> + * per-priority chached iterators.
> + */
> +static void mem_cgroup_uncache_reclaim_iters(struct mem_cgroup *root,
> +		struct mem_cgroup *memcg)
> +{
> +	int node;
> +
> +	for_each_node(node) {
> +		struct mem_cgroup_per_node *pn = root->info.nodeinfo[node];
> +		int zone;
> +
> +		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
> +			struct mem_cgroup_per_zone *mz;
> +			int prio;
> +
> +			mz = &pn->zoneinfo[zone];
> +			for (prio = 0; prio < DEF_PRIORITY + 1; prio++) {
> +				struct mem_cgroup_reclaim_iter *iter;
> +
> +				/*
> +				 * Just drop the reference on the removed memcg
> +				 * cached last_visited. No need to lock iter as
> +				 * the memcg is on the way out and cannot be
> +				 * reclaimed.
> +				 */
> +				iter = &mz->reclaim_iter[prio];
> +				if (root == memcg) {
> +					if (iter->last_visited)
> +						css_put(&iter->last_visited->css);
> +					continue;
> +				}
> +
> +				rcu_read_lock();
> +				spin_lock(&iter->iter_lock);
> +				if (iter->last_visited == memcg) {
> +					iter->last_visited = __find_prev_memcg(
> +							root, memcg);
> +					css_put(&memcg->css);
> +				}
> +				spin_unlock(&iter->iter_lock);
> +				rcu_read_unlock();
> +			}
> +		}
> +	}
> +}
> +
> +/*
> + * Remove the given memcg from all cached reclaim iterators.
> + */
> +static void mem_cgroup_uncache_from_reclaim(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *parent = memcg;
> +
> +	do {
> +		mem_cgroup_uncache_reclaim_iters(parent, memcg);
> +	} while ((parent = parent_mem_cgroup(parent)));
> +
> +	/*
> +	 * if the root memcg is not hierarchical we have to check it
> +	 * explicitely.
> +	 */
> +	if (!root_mem_cgroup->use_hierarchy)
> +		mem_cgroup_uncache_reclaim_iters(root_mem_cgroup, memcg);
> +}

for each in hierarchy:
  for each node:
    for each zone:
      for each reclaim priority:

every time a cgroup is destroyed.  I don't think such a hammer is
justified in general, let alone for consolidating code a little.

Can we invalidate the position cache lazily?  Have a global "cgroup
destruction" counter and store a snapshot of that counter whenever we
put a cgroup pointer in the position cache.  We only use the cached
pointer if that counter has not changed in the meantime, so we know
that the cgroup still exists.

It is pretty pretty imprecise and we invalidate the whole cache every
time a cgroup is destroyed, but I think that should be okay.  If not,
better ideas are welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
