Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 09F806B0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 12:37:49 -0500 (EST)
Date: Tue, 12 Feb 2013 12:37:41 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130212173741.GD25235@cmpxchg.org>
References: <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
 <20130212095419.GB4863@dhcp22.suse.cz>
 <20130212151002.GD15951@cmpxchg.org>
 <20130212154330.GG4863@dhcp22.suse.cz>
 <20130212161332.GI4863@dhcp22.suse.cz>
 <20130212162442.GJ4863@dhcp22.suse.cz>
 <63d3b5fa-dbc6-4bc9-8867-f9961e644305@email.android.com>
 <20130212171216.GA17663@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130212171216.GA17663@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue, Feb 12, 2013 at 06:12:16PM +0100, Michal Hocko wrote:
> On Tue 12-02-13 11:41:03, Johannes Weiner wrote:
> > 
> > 
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > >On Tue 12-02-13 17:13:32, Michal Hocko wrote:
> > >> On Tue 12-02-13 16:43:30, Michal Hocko wrote:
> > >> [...]
> > >> The example was not complete:
> > >> 
> > >> > Wait a moment. But what prevents from the following race?
> > >> > 
> > >> > rcu_read_lock()
> > >> 
> > >> cgroup_next_descendant_pre
> > >> css_tryget(css);
> > >> memcg = mem_cgroup_from_css(css)		atomic_add(CSS_DEACT_BIAS,
> > >&css->refcnt)
> > >> 
> > >> > 						mem_cgroup_css_offline(memcg)
> > >> 
> > >> We should be safe if we did synchronize_rcu() before
> > >root->dead_count++,
> > >> no?
> > >> Because then we would have a guarantee that if css_tryget(memcg)
> > >> suceeded then we wouldn't race with dead_count++ it triggered.
> > >> 
> > >> > 						root->dead_count++
> > >> > iter->last_dead_count = root->dead_count
> > >> > iter->last_visited = memcg
> > >> > 						// final
> > >> > 						css_put(memcg);
> > >> > // last_visited is still valid
> > >> > rcu_read_unlock()
> > >> > [...]
> > >> > // next iteration
> > >> > rcu_read_lock()
> > >> > iter->last_dead_count == root->dead_count
> > >> > // KABOOM
> > >
> > >Ohh I have missed that we took a reference on the current memcg which
> > >will be stored into last_visited. And then later, during the next
> > >iteration it will be still alive until we are done because previous
> > >patch moved css_put to the very end.
> > >So this race is not possible. I still need to think about parallel
> > >iteration and a race with removal.
> > 
> > I thought the whole point was to not have a reference in last_visited
> > because have the iterator might be unused indefinitely :-)
> 
> OK, it seems that I managed to confuse ;)
> 
> > We only store a pointer and validate it before use the next time
> > around.  So I think the race is still possible, but we can deal with
> > it by not losing concurrent dead count changes, i.e. one atomic read
> > in the iterator function.
> 
> All reads from root->dead_count are atomic already, so I am not sure
> what you mean here. Anyway, I hope I won't make this even more confusing
> if I post what I have right now:

Yes, but we are doing two reads.  Can't the memcg that we'll store in
last_visited be offlined during this and be freed after we drop the
rcu read lock?  If we had just one read, we would detect this
properly.

> ---
> >From 52121928be61282dc19e32179056615ffdf128a9 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Tue, 12 Feb 2013 18:08:26 +0100
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
> Locking rules got a bit complicated. We primarily rely on rcu read
> lock which makes sure that once we see an up-to-date dead_count then
> iter->last_visited is valid for RCU walk. smp_rmb makes sure that
> dead_count is read before last_visited and last_dead_count while smp_wmb
> makes sure that last_visited is updated before last_dead_count so the
> up-to-date last_dead_count cannot point to an outdated last_visited.
> css_tryget then makes sure that the last_visited is still alive.
> 
> Spotted-by: Ying Han <yinghan@google.com>
> Original-idea-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   69 +++++++++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 60 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 727ec39..31bb9b0 100644
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

Since we read and write this without a lock, I would feel more
comfortable if this were a full word, i.e. unsigned long.  That
guarantees we don't see any partial states.

> @@ -1156,17 +1162,36 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			int nid = zone_to_nid(reclaim->zone);
>  			int zid = zone_idx(reclaim->zone);
>  			struct mem_cgroup_per_zone *mz;
> +			unsigned int dead_count;
>  
>  			mz = mem_cgroup_zoneinfo(root, nid, zid);
>  			iter = &mz->reclaim_iter[reclaim->priority];
> -			last_visited = iter->last_visited;
>  			if (prev && reclaim->generation != iter->generation) {
> -				if (last_visited) {
> -					css_put(&last_visited->css);
> -					iter->last_visited = NULL;
> -				}
> +				iter->last_visited = NULL;
>  				goto out_unlock;
>  			}
> +
> +			/*
> +                         * If the dead_count mismatches, a destruction
> +                         * has happened or is happening concurrently.
> +                         * If the dead_count matches, a destruction
> +                         * might still happen concurrently, but since
> +                         * we checked under RCU, that destruction
> +                         * won't free the object until we release the
> +                         * RCU reader lock.  Thus, the dead_count
> +                         * check verifies the pointer is still valid,
> +                         * css_tryget() verifies the cgroup pointed to
> +                         * is alive.
> +			 */
> +			dead_count = atomic_read(&root->dead_count);
> +			smp_rmb();
> +			last_visited = iter->last_visited;
> +			if (last_visited) {
> +				if ((dead_count != iter->last_dead_count) ||
> +					!css_tryget(&last_visited->css)) {
> +					last_visited = NULL;
> +				}
> +			}
>  		}
>  
>  		/*
> @@ -1206,10 +1231,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			if (css && !memcg)
>  				curr = mem_cgroup_from_css(css);
>  
> -			/* make sure that the cached memcg is not removed */
> -			if (curr)
> -				css_get(&curr->css);
>  			iter->last_visited = curr;
> +			smp_wmb();
> +			iter->last_dead_count = atomic_read(&root->dead_count);

iter->last_dead_count = dead_count

This way, we detect if curr is offlined between the first reading and
the second reading.  Otherwise, it could get freed when the reference
is dropped and then last_visited points to invalid memory while the
dead_count is uptodate.

> @@ -6366,10 +6390,37 @@ free_out:
>  	return ERR_PTR(error);
>  }
>  
> +/*
> + * Announce all parents that a group from their hierarchy is gone.
> + */
> +static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *parent = memcg;
> +
> +	/*
> +	 * Make sure we are not racing with mem_cgroup_iter when it stores
> +	 * a new iter->last_visited. Wait until that RCU finishes so that
> +	 * it cannot see already incremented dead_count with memcg which
> +	 * would be already dead next time but dead_count wouldn't tell
> +	 * us about that.
> +	 */
> +	synchronize_rcu();

Ah, you are stabilizing the counter between the two reads.  It's
cheaper to just do one read instead.  Saves the atomic op and saves
the synchronization point :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
