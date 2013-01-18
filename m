Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 0D12C6B0005
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 19:10:33 -0500 (EST)
Date: Fri, 18 Jan 2013 11:10:29 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
Message-ID: <20130118001029.GK2498@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-10-git-send-email-david@fromorbit.com>
 <50F6FDC8.5020909@parallels.com>
 <20130116225521.GF2498@dastard>
 <50F7475F.90609@parallels.com>
 <20130117042245.GG2498@dastard>
 <50F84118.7030608@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F84118.7030608@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On Thu, Jan 17, 2013 at 10:21:12AM -0800, Glauber Costa wrote:
> >> Deepest fears:
> >>
> >> 1) snakes.
> > 
> > Snakes are merely poisonous. Drop Bears are far more dangerous :P
> 
> fears are irrational anyway...
> 
> >> 2) It won't surprise you to know that I am adapting your work, which
> >> provides a very sane and helpful API, to memcg shrinking.
> >>
> >> The dumb and simple approach in there is to copy all lrus that are
> >> marked memcg aware at memcg creation time. The API is kept the same,
> >> but when you do something like list_lru_add(lru, obj), for instance, we
> >> derive the memcg context from obj and relay it to the right list.
> > 
> > At which point, you don't want the overhead of per-node lists.
> 
> This is one of the assumptions we may have to end up doing here.

*nod*. Good to get it out in the open to see if we can work around
it....

> > This is a problem that superblock contexts don't care about - they
> > are global by their very nature. Hence I'm wondering if trying to
> > fit these two very different behaviours into the one LRU list is
> > the wrong approach.
> > 
> 
> I am not that much concerned about that, honestly. I like the API, and I
> like the fact that it allow me to have the subsystems using it
> transparently, just by referring to the "master" lru (the dentry, inode,
> etc). It reduces complexity to reuse the data structures, but that is
> not paramount.
> 
> However, a more flexible data structure in which we could select at
> least at creation time if we want per-node lists or not, would be quite
> helpful.

*nod*

> > Consider this: these patches give us a generic LRU list structure.
> > It currently uses a list_head in each object for indexing, and we
> > are talking about single LRU lists because of this limitation and
> > trying to build infrastructure that can support this indexing
> > mechanism.
> > 
> > I think that all of thses problems go away if we replace the
> > list_head index in the object with a "struct lru_item" index. To
> > start with, it's just a s/list_head/lru_item/ changeover, but from
> > there we can expand.
> > 
> > What I'm getting at is that we want to have multiple axis of
> > tracking and reclaim, but we only have a single axis for tracking.
> > If the lru_item grew a second list_head called "memcg_lru", then
> > suddenly the memcg LRUs can be maintained separately to the global
> > (per-superblock) LRU. i.e.:
> > 
> > struct lru_item {
> > 	struct list_head global_list;
> > 	struct list_head memcg_list;
> > }
> > 
> 
> I may be misunderstanding you, but that is not how I see it. Your global
> list AFAIU, is more like a hook to keep the lists together. The actual
> accesses to it are controlled by a parent structure, like the
> super-block, which in turns, embeds a shrinker.
> 
> So we get (in the sb case), from shrinker to sb, and from sb to dentry
> list (or inode). We never care about the global list head.
> 
> From this point on, we "entered" the LRU, but we still don't know which
> list to reclaim from: there is one list per node, and we need to figure
> out which is our target, based on the flags.
> 
> This list selection mechanism is where I am usually hooking memcg: and
> for the same way you are using an array - given a node, you want fast
> access to the underlying list - so am I. Given the memcg context, I want
> to get to the corresponding memcg list.
> 
> Now, in my earliest implementations, the memcg would still take me to a
> node-wide array, and an extra level would be required. We seem to agree
> that (at least as a starting point) getting rid of this extra level, so
> the memcg colapses all objects in the same list would provide decent
> behavior in most cases, while still keeping the footprint manageable. So
> that is what I am pursuing at the moment.

Ah, I think that maybe you misunderstood. There are two main
triggers for reclaim: global memory is short, or a memcg is short on
memory.

To find appropriate objects quickly for reclaim, we need objects on
appropriate lists. E.g. if we are doing global reclaim (e.g. from
kswapd) it means a node is short of memory and needs more. Hence
just walking a per-node list is the most efficient method of doing
this. Having to walk all the memcg LRU lists to find objects on a
specific node is not feasible. OTOH, if we are doing memcg specific
reclaim, the opposite is true.

SO, if we have:

struct lru_list_head {
	struct list_head	head;
	spinlock_t		lock;
	u64			nr_items;
}

struct lru_list {
	struct lru_list_node	*per_node;
	int			numnodes;
	nodemask_t		active_nodes;
	void			*memcg_lists;	/* managed by memcg code */
	....
}

lru_list_init(bool per_node)
{
	numnodes = 1;
	if (pernode)
		numnodes = NRNODES;
	lru_list->pernode = alloc(numnodes * sizeof(struct lru_list_head));
	....
}

And then each object uses:

struct lru_item {
	struct list_head global_list;
	struct list_head memcg_list;
}

and we end up with:

lru_add(struct lru_list *lru, struct lru_item *item)
{
	node_id = min(object_to_nid(item), lru->numnodes);
	
	__lru_add(lru, node_id, &item->global_list);
	if (memcg) {
		memcg_lru = find_memcg_lru(lru->memcg_lists, memcg_id)
		__lru_add_(memcg_lru, node_id, &item->memcg_list);
	}
}

Then when it comes to reclaim, the reclaim information passed tot eh
shrinker needs to indicate either the node to reclaim from or the
memcg_id (or both), so that reclaim can walk the appropriate list to
find objects to reclaim. Then we delete them from both lists and
reclaim the object....

And the memcg lists can instantiate new struct lru_list and index
them appropriately according to some <handwave> criteria. Then all
the generic LRU code cares about is that the memcg lookup returns
the correct struct lru_list for it to operate on...

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
