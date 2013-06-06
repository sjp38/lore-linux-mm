Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 556C66B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:21:11 -0400 (EDT)
Date: Thu, 6 Jun 2013 13:21:07 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 11/35] list_lru: per-node list infrastructure
Message-ID: <20130606032107.GQ29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-12-git-send-email-glommer@openvz.org>
 <20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Wed, Jun 05, 2013 at 04:08:04PM -0700, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:40 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Now that we have an LRU list API, we can start to enhance the
> > implementation.  This splits the single LRU list into per-node lists
> > and locks to enhance scalability.
> 
> Do we have any runtime measurements?  They're pretty important for
> justifying inclusion of the code.

Nothing I've officially posted, because I've been busy with other
XFS stuff. But, well, if you look here:

http://oss.sgi.com/pipermail/xfs/2013-June/026888.html

-  12.74%  [kernel]  [k] __ticket_spin_trylock
   - __ticket_spin_trylock
      - 60.49% _raw_spin_lock
         + 91.79% inode_add_lru			>>> inode_lru_lock
         + 2.98% dentry_lru_del			>>> dcache_lru_lock
         + 1.30% shrink_dentry_list
         + 0.71% evict
      - 20.42% do_raw_spin_lock
         - _raw_spin_lock
            + 13.41% inode_add_lru		>>> inode_lru_lock
            + 10.55% evict
            + 8.26% dentry_lru_del		>>> dcache_lru_lock
            + 7.62% __remove_inode_hash
....
      - 10.37% do_raw_spin_trylock
         - _raw_spin_trylock
            + 79.65% prune_icache_sb		>>> inode_lru_lock
            + 11.04% shrink_dentry_list
            + 9.24% prune_dcache_sb		>>> dcache_lru_lock
      - 8.72% _raw_spin_trylock
         + 46.33% prune_icache_sb		>>> inode_lru_lock
         + 46.08% shrink_dentry_list
         + 7.60% prune_dcache_sb		>>> dcache_lru_lock

This is from an 8p system w/ fake-numa=4 running an 8-way find+stat
workload on 50 million files. 12.5% CPU usage means we are burning
an entire CPU of that system just in __ticket_spin_trylock(), and
the numbers above indicate that roughly 60% of that CPU time is from
the inode_lru_lock.

So, more than half a CPU being spent just trying to get the
inode_lru_lock. The generic LRU list code drops
__ticket_spin_trylock() back down to roughly 2% of the total CPU
usage for the same workload - the CPU burn associated with the
contention on the global lock goes away.

It's pretty obvious if a global lock is causing contention issues on
an 8p system, then larger systems are going to be much, much worse.

> Measurememnts for non-NUMA and uniprocessor kernels would be useful in
> making that decision as well.

I get the same spinlock contention problems when I run without the
fake-numa kernel parameter on the VM. The generic LRU lists can't
fix the problem for non-numa systems.

> In fact a lot of the patchset is likely to be injurious to small
> machines.  We should quantify this and then persade ourselves that the
> large-machine gains are worth the small-machine losses.

I haven't been able to measure any CPU usage difference from the
changes for non-numa systems on workloads that stress the LRUs. if
you've got any ideas on how I might demonstrate a regression, then
I'm all ears. But If I can't measure the difference, there is
none...

> 
> > Items are placed on lists
> > according to the node the memory belongs to. To make scanning the
> > lists efficient, also track whether the per-node lists have entries
> > in them in a active nodemask.
> > 
> > Note:
> > We use a fixed-size array for the node LRU, this struct can be very big
> > if MAX_NUMNODES is big. If this becomes a problem this is fixable by
> > turning this into a pointer and dynamically allocating this to
> > nr_node_ids. This quantity is firwmare-provided, and still would provide
> > room for all nodes at the cost of a pointer lookup and an extra
> > allocation. Because that allocation will most likely come from a
> > different slab cache than the main structure holding this structure, we
> > may very well fail.
> 
> Surprised.  How big is MAX_NUMNODES likely to get?

AFAICT, 1024.

> lib/flex_array.c might be of use here.

Never heard of it :/

Perhaps it might, but that woul dbe something to do further down the
track...

> 
> >
> > ...
> >
> > -struct list_lru {
> > +struct list_lru_node {
> >  	spinlock_t		lock;
> >  	struct list_head	list;
> >  	long			nr_items;
> > +} ____cacheline_aligned_in_smp;
> > +
> > +struct list_lru {
> > +	/*
> > +	 * Because we use a fixed-size array, this struct can be very big if
> > +	 * MAX_NUMNODES is big. If this becomes a problem this is fixable by
> > +	 * turning this into a pointer and dynamically allocating this to
> > +	 * nr_node_ids. This quantity is firwmare-provided, and still would
> > +	 * provide room for all nodes at the cost of a pointer lookup and an
> > +	 * extra allocation. Because that allocation will most likely come from
> > +	 * a different slab cache than the main structure holding this
> > +	 * structure, we may very well fail.
> > +	 */
> > +	struct list_lru_node	node[MAX_NUMNODES];
> > +	nodemask_t		active_nodes;
> 
> Some documentation of the data structure would be helpful.  It appears
> that active_nodes tracks (ie: duplicates) node[x].nr_items!=0.
> 
> It's unclear that active_nodes is really needed - we could just iterate
> across all items in list_lru.node[].  Are we sure that the correct
> tradeoff decision was made here?

Yup. Think of all the cache line misses that checking
node[x].nr_items != 0 entails. If MAX_NUMNODES = 1024, there's 1024
cacheline misses right there. The nodemask is a much more cache
friendly method of storing active node state.

not to mention that for small machines with a large MAX_NUMNODES,
we'd be checking nodes that never have items stored on them...

> What's the story on NUMA node hotplug, btw?

Do we care? hotplug doesn't change MAX_NUMNODES, and if you are
removing a node you have to free all the memory on the node,
so that should already be tken care of by external code....

> 
> >  };
> >  
> >
> > ...
> >
> >  unsigned long
> > -list_lru_walk(
> > -	struct list_lru *lru,
> > -	list_lru_walk_cb isolate,
> > -	void		*cb_arg,
> > -	unsigned long	nr_to_walk)
> > +list_lru_count(struct list_lru *lru)
> >  {
> > +	long count = 0;
> > +	int nid;
> > +
> > +	for_each_node_mask(nid, lru->active_nodes) {
> > +		struct list_lru_node *nlru = &lru->node[nid];
> > +
> > +		spin_lock(&nlru->lock);
> > +		BUG_ON(nlru->nr_items < 0);
> 
> This is buggy.

Yup, good catch.

> > +EXPORT_SYMBOL_GPL(list_lru_count);
> 
> list_lru_count()'s return value is of course approximate.  If callers
> require that the returned value be exact, they will need to provide
> their own locking on top of list_lru's internal locking (which would
> then become redundant).
> 
> This is the sort of thing which should be discussed in the interface
> documentation.

Yup.

> list_lru_count() can be very expensive.

Well, yes. But it's far less expensive than a global LRU lock on a
machine of the size that we are concerned about list_lru_count()
being expensive.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
