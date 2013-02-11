Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BC9AE6B000A
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 14:58:38 -0500 (EST)
Date: Mon, 11 Feb 2013 14:58:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130211195824.GB15951@cmpxchg.org>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
 <1357235661-29564-5-git-send-email-mhocko@suse.cz>
 <20130208193318.GA15951@cmpxchg.org>
 <20130211151649.GD19922@dhcp22.suse.cz>
 <20130211175619.GC13218@cmpxchg.org>
 <20130211192929.GB29000@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130211192929.GB29000@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Mon, Feb 11, 2013 at 08:29:29PM +0100, Michal Hocko wrote:
> On Mon 11-02-13 12:56:19, Johannes Weiner wrote:
> > On Mon, Feb 11, 2013 at 04:16:49PM +0100, Michal Hocko wrote:
> > > Maybe we could keep the counter per memcg but that would mean that we
> > > would need to go up the hierarchy as well. We wouldn't have to go over
> > > node-zone-priority cleanup so it would be much more lightweight.
> > > 
> > > I am not sure this is necessarily better than explicit cleanup because
> > > it brings yet another kind of generation number to the game but I guess
> > > I can live with it if people really thing the relaxed way is much
> > > better.
> > > What do you think about the patch below (untested yet)?
> > 
> > Better, but I think you can get rid of both locks:
> 
> What is the other lock you have in mind.

The iter lock itself.  I mean, multiple reclaimers can still race but
there won't be any corruption (if you make iter->dead_count a long,
setting it happens atomically, we nly need the memcg->dead_count to be
an atomic because of the inc) and the worst that could happen is that
a reclaim starts at the wrong point in hierarchy, right?  But as you
said in the changelog that introduced the lock, it's never actually
been a practical problem.  You just need to put the wmb back in place,
so that we never see the dead_count give the green light while the
cached position is stale, or we'll tryget random memory.

> > mem_cgroup_iter:
> > rcu_read_lock()
> > if atomic_read(&root->dead_count) == iter->dead_count:
> >   smp_rmb()
> >   if tryget(iter->position):
> >     position = iter->position
> > memcg = find_next(postion)
> > css_put(position)
> > iter->position = memcg
> > smp_wmb() /* Write position cache BEFORE marking it uptodate */
> > iter->dead_count = atomic_read(&root->dead_count)
> > rcu_read_unlock()
> 
> Updated patch bellow:

Cool, thanks.  I hope you don't find it too ugly anymore :-)

> >From 756c4f0091d250bc5ff816f8e9d11840e8522b3a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 11 Feb 2013 20:23:51 +0100
> Subject: [PATCH] memcg: relax memcg iter caching
> 
> Now that per-node-zone-priority iterator caches memory cgroups rather
> than their css ids we have to be careful and remove them from the
> iterator when they are on the way out otherwise they might hang for
> unbounded amount of time (until the global/targeted reclaim triggers the
> zone under priority to find out the group is dead and let it to find the
> final rest).
> 
> We can fix this issue by relaxing rules for the last_visited memcg as
> well.
> Instead of taking reference to css before it is stored into
> iter->last_visited we can just store its pointer and track the number of
> removed groups for each memcg. This number would be stored into iterator
> everytime when a memcg is cached. If the iter count doesn't match the
> curent walker root's one we will start over from the root again. The
> group counter is incremented upwards the hierarchy every time a group is
> removed.
> 
> Locking rules are a bit complicated but we primarily rely on rcu which
> protects css from disappearing while it is proved to be still valid. The
> validity is checked in two steps. First the iter->last_dead_count has
> to match root->dead_count and second css_tryget has to confirm the
> that the group is still alive and it pins it until we get a next memcg.
> 
> Spotted-by: Ying Han <yinghan@google.com>
> Original-idea-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   66 +++++++++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 57 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e9f5c47..f9b5719 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -144,8 +144,13 @@ struct mem_cgroup_stat_cpu {
>  };
>  
>  struct mem_cgroup_reclaim_iter {
> -	/* last scanned hierarchy member with elevated css ref count */
> +	/*
> +	 * last scanned hierarchy member. Valid only if last_dead_count
> +	 * matches memcg->dead_count of the hierarchy root group.
> +	 */
>  	struct mem_cgroup *last_visited;
> +	unsigned int last_dead_count;
> +
>  	/* scan generation, increased every round-trip */
>  	unsigned int generation;
>  	/* lock to protect the position and generation */
> @@ -357,6 +362,7 @@ struct mem_cgroup {
>  	struct mem_cgroup_stat_cpu nocpu_base;
>  	spinlock_t pcp_counter_lock;
>  
> +	atomic_t	dead_count;
>  #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
>  	struct tcp_memcontrol tcp_mem;
>  #endif
> @@ -1158,19 +1164,33 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			int nid = zone_to_nid(reclaim->zone);
>  			int zid = zone_idx(reclaim->zone);
>  			struct mem_cgroup_per_zone *mz;
> +			unsigned int dead_count;
>  
>  			mz = mem_cgroup_zoneinfo(root, nid, zid);
>  			iter = &mz->reclaim_iter[reclaim->priority];
>  			spin_lock(&iter->iter_lock);
> -			last_visited = iter->last_visited;
>  			if (prev && reclaim->generation != iter->generation) {
> -				if (last_visited) {
> -					css_put(&last_visited->css);
> -					iter->last_visited = NULL;
> -				}
> +				iter->last_visited = NULL;
>  				spin_unlock(&iter->iter_lock);
>  				goto out_unlock;
>  			}
> +
> +			/*
> +			 * last_visited might be invalid if some of the group
> +			 * downwards was removed. As we do not know which one
> +			 * disappeared we have to start all over again from the
> +			 * root.
> +			 * css ref count then makes sure that css won't
> +			 * disappear while we iterate to the next memcg
> +			 */
> +			last_visited = iter->last_visited;
> +			dead_count = atomic_read(&root->dead_count);
> +			smp_rmb();

Confused about this barrier, see below.

As per above, if you remove the iter lock, those lines are mixed up.
You need to read the dead count first because the writer updates the
dead count after it sets the new position.  That way, if the dead
count gives the go-ahead, you KNOW that the position cache is valid,
because it has been updated first.  If either the two reads or the two
writes get reordered, you risk seeing a matching dead count while the
position cache is stale.

> +			if (last_visited &&
> +					((dead_count != iter->last_dead_count) ||
> +					 !css_tryget(&last_visited->css))) {
> +				last_visited = NULL;
> +			}
>  		}
>  
>  		/*
> @@ -1210,10 +1230,12 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			if (css && !memcg)
>  				curr = mem_cgroup_from_css(css);
>  
> -			/* make sure that the cached memcg is not removed */
> -			if (curr)
> -				css_get(&curr->css);
> +			/*
> +			 * No memory barrier is needed here because we are
> +			 * protected by iter_lock
> +			 */
>  			iter->last_visited = curr;
> +			iter->last_dead_count = atomic_read(&root->dead_count);
>  
>  			if (!css)
>  				iter->generation++;
> @@ -6375,10 +6397,36 @@ free_out:
>  	return ERR_PTR(error);
>  }
>  
> +/*
> + * Announce all parents that a group from their hierarchy is gone.
> + */
> +static void mem_cgroup_uncache_from_reclaim(struct mem_cgroup *memcg)

How about

static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)

?

> +{
> +	struct mem_cgroup *parent = memcg;
> +
> +	while ((parent = parent_mem_cgroup(parent)))
> +		atomic_inc(&parent->dead_count);
> +
> +	/*
> +	 * if the root memcg is not hierarchical we have to check it
> +	 * explicitely.
> +	 */
> +	if (!root_mem_cgroup->use_hierarchy)
> +		atomic_inc(&parent->dead_count);

Increase root_mem_cgroup->dead_count instead?

> +	/*
> +	 * Make sure that dead_count updates are visible before other
> +	 * cleanup from css_offline.
> +	 * Pairs with smp_rmb in mem_cgroup_iter
> +	 */
> +	smp_wmb();

That's unexpected.  What other cleanups?  A race between this and
mem_cgroup_iter should be fine because of the RCU synchronization.

Thanks!
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
