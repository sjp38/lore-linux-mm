Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id B65466B0005
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 16:28:03 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id c13so2807352eaa.30
        for <linux-mm@kvack.org>; Mon, 11 Feb 2013 13:28:01 -0800 (PST)
Date: Mon, 11 Feb 2013 22:27:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130211212756.GC29000@dhcp22.suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
 <1357235661-29564-5-git-send-email-mhocko@suse.cz>
 <20130208193318.GA15951@cmpxchg.org>
 <20130211151649.GD19922@dhcp22.suse.cz>
 <20130211175619.GC13218@cmpxchg.org>
 <20130211192929.GB29000@dhcp22.suse.cz>
 <20130211195824.GB15951@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130211195824.GB15951@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Mon 11-02-13 14:58:24, Johannes Weiner wrote:
> On Mon, Feb 11, 2013 at 08:29:29PM +0100, Michal Hocko wrote:
> > On Mon 11-02-13 12:56:19, Johannes Weiner wrote:
> > > On Mon, Feb 11, 2013 at 04:16:49PM +0100, Michal Hocko wrote:
> > > > Maybe we could keep the counter per memcg but that would mean that we
> > > > would need to go up the hierarchy as well. We wouldn't have to go over
> > > > node-zone-priority cleanup so it would be much more lightweight.
> > > > 
> > > > I am not sure this is necessarily better than explicit cleanup because
> > > > it brings yet another kind of generation number to the game but I guess
> > > > I can live with it if people really thing the relaxed way is much
> > > > better.
> > > > What do you think about the patch below (untested yet)?
> > > 
> > > Better, but I think you can get rid of both locks:
> > 
> > What is the other lock you have in mind.
> 
> The iter lock itself.  I mean, multiple reclaimers can still race but
> there won't be any corruption (if you make iter->dead_count a long,
> setting it happens atomically, we nly need the memcg->dead_count to be
> an atomic because of the inc) and the worst that could happen is that
> a reclaim starts at the wrong point in hierarchy, right?

The lack of synchronization basically means that 2 parallel reclaimers
can reclaim every group exactly once (ideally) or up to each group
twice in the worst case.
So the exclusion was quite comfortable.

> But as you said in the changelog that introduced the lock, it's never
> actually been a practical problem.

That is true but those bugs would be subtle though so I wouldn't be
opposed to prevent from them before we get burnt. But if you think that
we should keep the previous semantic I can drop that patch.

> You just need to put the wmb back in place, so that we never see the
> dead_count give the green light while the cached position is stale, or
> we'll tryget random memory.
> 
> > > mem_cgroup_iter:
> > > rcu_read_lock()
> > > if atomic_read(&root->dead_count) == iter->dead_count:
> > >   smp_rmb()
> > >   if tryget(iter->position):
> > >     position = iter->position
> > > memcg = find_next(postion)
> > > css_put(position)
> > > iter->position = memcg
> > > smp_wmb() /* Write position cache BEFORE marking it uptodate */
> > > iter->dead_count = atomic_read(&root->dead_count)
> > > rcu_read_unlock()
> > 
> > Updated patch bellow:
> 
> Cool, thanks.  I hope you don't find it too ugly anymore :-)

It's getting trick and you know how people love when you have to play
and rely on atomics with memory barriers...
 
[...]
> > +
> > +			/*
> > +			 * last_visited might be invalid if some of the group
> > +			 * downwards was removed. As we do not know which one
> > +			 * disappeared we have to start all over again from the
> > +			 * root.
> > +			 * css ref count then makes sure that css won't
> > +			 * disappear while we iterate to the next memcg
> > +			 */
> > +			last_visited = iter->last_visited;
> > +			dead_count = atomic_read(&root->dead_count);
> > +			smp_rmb();
> 
> Confused about this barrier, see below.
> 
> As per above, if you remove the iter lock, those lines are mixed up.
> You need to read the dead count first because the writer updates the
> dead count after it sets the new position. 

You are right, we need
+			dead_count = atomic_read(&root->dead_count);
+			smp_rmb();
+			last_visited = iter->last_visited;

> That way, if the dead count gives the go-ahead, you KNOW that the
> position cache is valid, because it has been updated first.

OK, you are right. We can live without css_tryget because dead_count is
either OK which means that css would be alive at least this rcu period
(and RCU walk would be safe as well) or it is incremented which means
that we have started css_offline already and then css is dead already.
So css_tryget can be dropped.

> If either the two reads or the two writes get reordered, you risk
> seeing a matching dead count while the position cache is stale.
> 
> > +			if (last_visited &&
> > +					((dead_count != iter->last_dead_count) ||
> > +					 !css_tryget(&last_visited->css))) {
> > +				last_visited = NULL;
> > +			}
> >  		}
> >  
> >  		/*
> > @@ -1210,10 +1230,12 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  			if (css && !memcg)
> >  				curr = mem_cgroup_from_css(css);
> >  
> > -			/* make sure that the cached memcg is not removed */
> > -			if (curr)
> > -				css_get(&curr->css);
> > +			/*
> > +			 * No memory barrier is needed here because we are
> > +			 * protected by iter_lock
> > +			 */
> >  			iter->last_visited = curr;

+			smp_wmb();

> > +			iter->last_dead_count = atomic_read(&root->dead_count);
> >  
> >  			if (!css)
> >  				iter->generation++;
> > @@ -6375,10 +6397,36 @@ free_out:
> >  	return ERR_PTR(error);
> >  }
> >  
> > +/*
> > + * Announce all parents that a group from their hierarchy is gone.
> > + */
> > +static void mem_cgroup_uncache_from_reclaim(struct mem_cgroup *memcg)
> 
> How about
> 
> static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)

OK

> ?
> 
> > +{
> > +	struct mem_cgroup *parent = memcg;
> > +
> > +	while ((parent = parent_mem_cgroup(parent)))
> > +		atomic_inc(&parent->dead_count);
> > +
> > +	/*
> > +	 * if the root memcg is not hierarchical we have to check it
> > +	 * explicitely.
> > +	 */
> > +	if (!root_mem_cgroup->use_hierarchy)
> > +		atomic_inc(&parent->dead_count);
> 
> Increase root_mem_cgroup->dead_count instead?

Sure. C&P
 
> > +	/*
> > +	 * Make sure that dead_count updates are visible before other
> > +	 * cleanup from css_offline.
> > +	 * Pairs with smp_rmb in mem_cgroup_iter
> > +	 */
> > +	smp_wmb();
> 
> That's unexpected.  What other cleanups?  A race between this and
> mem_cgroup_iter should be fine because of the RCU synchronization.

OK, I was too careful, probably (memory barriers are always head
scratchers). I was worried about all dead_count should be committed
before we do other steps in the clean up like reparenting charges etc.
But as you say it will not do any changes.

I will get back to this tomorrow.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
