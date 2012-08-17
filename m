Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 892406B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 03:55:10 -0400 (EDT)
Date: Fri, 17 Aug 2012 17:54:40 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
Message-ID: <20120817075440.GD2776@devil.redhat.com>
References: <1345150417-30856-1-git-send-email-yinghan@google.com>
 <502D61E1.8040704@redhat.com>
 <20120816234157.GB2776@devil.redhat.com>
 <502DD35F.7080009@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502DD35F.7080009@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Fri, Aug 17, 2012 at 09:15:11AM +0400, Glauber Costa wrote:
> On 08/17/2012 03:41 AM, Dave Chinner wrote:
> > On Thu, Aug 16, 2012 at 05:10:57PM -0400, Rik van Riel wrote:
> >> On 08/16/2012 04:53 PM, Ying Han wrote:
> >>> The patchset adds the functionality of isolating the vfs slab objects per-memcg
> >>> under reclaim. This feature is a *must-have* after the kernel slab memory
> >>> accounting which starts charging the slab objects into individual memcgs. The
> >>> existing per-superblock shrinker doesn't work since it will end up reclaiming
> >>> slabs being charged to other memcgs.
> > 
> > What list was this posted to?
> 
> This what? per-memcg slab accounting ? linux-mm and cgroups, and at
> least once to lkml.

Hi Glauber, I must have lost it in the noise of lkml because
anything that doesn't hit my procmail filters generally gets deleted
without being read.

> You can also find the up2date version in my git tree:
> 
>   git://github.com/glommer/linux.git memcg-3.5/kmemcg-slab
> 
> But then you mainly lose the discussion. You can find the thread at
> http://lwn.net/Articles/508087/, and if you scan recent messages to
> linux-mm, there is a lot there too.

If I'm lucky, I'll get to looking at that sometime next week.

> > The per-sb shrinkers are not intended for memcg granularity - they
> > are for scalability in that they allow the removal of the global
> > inode and dcache LRU locks and allow significant flexibility in
> > cache relcaim strategies for filesystems. Hint: reclaiming
> > the VFS inode cache doesn't free any memory on an XFS filesystem -
> > it's the XFS inode cache shrinker that is integrated into the per-sb
> > shrinker infrastructure that frees all the memory. It doesn't work
> > without the per-sb shrinker functionality and it's an extremely
> > performance critical balancing act. Hence any changes to this
> > shrinker infrastructure need a lot of consideration and testing,
> > most especially to ensure that the balance of the system has not
> > been disturbed.
> > 
> 
> I was actually wondering where the balance would stand between hooking
> this into the current shrinking mechanism, and having something totally
> separate for memcg. It is tempting to believe that we could get away
> with something that works well for memcg-only, but this already proved
> to be not true for the user pages lru list...

Learn from past mistakes. ;P

> > Also how do yo propose to solve the problem of inodes and dentries
> > shared across multiple memcgs?  They can only be tracked in one LRU,
> > but the caches are global and are globally accessed. 
> 
> I think the proposal is to not solve this problem. Because at first it
> sounds a bit weird, let me explain myself:
> 
> 1) Not all processes in the system will sit on a memcg.
> Technically they will, but the root cgroup is never accounted, so a big
> part of the workload can be considered "global" and will have no
> attached memcg information whatsoever.
> 
> 2) Not all child memcgs will have associated vfs objects, or kernel
> objects at all, for that matter. This happens only when specifically
> requested by the user.
>
> Due to that, I believe that although sharing is obviously a reality
> within the VFS, but the workloads associated to this will tend to be
> fairly local.

I have my doubts about that - I've heard it said many times but no
data has been provided to prove the assertion....

> When sharing does happen, we currently account to the
> first process to ever touch the object. This is also how memcg treats
> shared memory users for userspace pages and it is working well so far.
> It doesn't *always* give you good behavior, but I guess those fall in
> the list of "workloads memcg is not good for".

And that list contains?

> Do we want to extend this list of use cases?  Sure. There is also
> discussion going on about how to improve this in the future. That would
> allow a policy to specify which memcg is to be "responsible" for the
> shared objects, be them kernel memory or shared memory regions. Even
> then, we'll always have one of the two scenarios:
> 
> 1) There is a memcg that is responsible for accounting that object, and
> then is clear we should reclaim from that memcg.
> 
> 2) There is no memcg associated with the object, and then we should not
> bother with that object at all.
> 
> I fully understand your concern, specifically because we talked about
> that in details in the past. But I believe most of the cases that would
> justify it would fall in 2).

Which then leads to this: the no-memcg object case needs to scale.

> Another thing to keep in mind is that we don't actually track objects.
> We track pages, and try to make sure that objects in the same page
> belong to the same memcg. (That could be important for your analysis or
> not...)

Hmmmm. So you're basically using the characteristics of internal
slab fragmentation to keep objects allocated to different memcg's
apart? That's .... devious. :)

> > Having mem
> > pressure in a single memcg that causes globally accessed dentries
> > and inodes to be tossed from memory will simply cause cache
> > thrashing and performance across the system will tank.
> > 
> 
> As said above. I don't consider global accessed dentries to be
> representative of the current use cases for memcg.

But they have to co-exist, and I think that's our big problem. If
you have a workload in a memcg, and the underlying directory
structure is exported via NFS or CIFS, then there is still global
access to that "memcg local" dentry structure.

> >>> The patch now is only handling dentry cache by given the nature dentry pinned
> >>> inode. Based on the data we've collected, that contributes the main factor of
> >>> the reclaimable slab objects. We also could make a generic infrastructure for
> >>> all the shrinkers (if needed).
> >>
> >> Dave Chinner has some prototype code for that.
> > 
> > The patchset I have makes the dcache lru locks per-sb as the first
> > step to introducing generic per-sb LRU lists, and then builds on
> > that to provide generic kernel-wide LRU lists with integrated
> > shrinkers, and builds on that to introduce node-awareness (i.e. NUMA
> > scalability) into the LRU list so everyone gets scalable shrinkers.
> > 
> 
> If you are building a generic infrastructure for shrinkers, what is the
> big point about per-sb? I'll give you that most of the memory will come
> from the VFS, but other objects are shrinkable too, that bears no
> relationship with the vfs.

Without any more information, it's hard to understand what I'm
doing.  The shrinker itself cannot lock or determine if an object is
reclaimable - that involves reference counts, status flags, whether
it is currently being freed, etc - so the generic shrinker has to
use callbacks for the objects to be freed. A generic shrinker looks
like this:

struct shrinker_lru_node {
       spinlock_t              lock;
       long                    lru_items;
       struct list_head        lru;
} ____cacheline_aligned_in_smp;

struct shrinker_lru {
       struct shrinker_lru_node node[MAX_NUMNODES];
       struct shrinker_lru_node expedited_reclaim;
       nodemask_t              active_nodes;

       int (*isolate_item)(struct list_head *, spinlock_t *, struct list_head *);
       int (*dispose)(struct list_head *);
};

and when you want to shrink the LRU you call shrinker_lru_shrink().
This walks the items on the LRU is calls the .isolate_item method
for the subsystem to try to remove the item from the LRU under the
LRU lock passed to the callback. The callback can drop the LRU lock
to free the item, or it can move it to the supplied dispose list
without dropping the lock. If the LRU lock is dropped, the scan has
to restart from the start of the list, so there's some interesting
issues with return values here.

Once all the items are scanned and moved to the dispose list, the
.dispose method is called to free all the items on the list.

This is basically a generic encoding of the methods used by both the
inode and dentry caches for optimised, low overhead, large-scale
batch freeing of objects.  The overall structure of the caches,
locking and LRU management is completely unchanged. It's just that
all the LRU code is generic....

IOWs, the context surrounding the shrinker and LRU doesn't change.
The LRU is still embedded in some structure somewhere, and it still
has the same relationships to other caches as it had before. e.g.
setting up the superblock shrinker:

               s->s_shrink.seeks = DEFAULT_SEEKS;
               s->s_shrink.shrink = prune_super;
               s->s_shrink.count_objects = prune_super_count;
               s->s_shrink.batch = 1024;
               shrinker_lru_init(&s->s_inode_lru);
               shrinker_lru_init(&s->s_dentry_lru);
               s->s_dentry_lru.isolate_item = dentry_isolate_one;
               s->s_dentry_lru.dispose = dispose_dentries;
               s->s_inode_lru.isolate_item = inode_isolate_one;
               s->s_inode_lru.dispose = dispose_inodes;

shows that we now also have to set up the LRUs appropriately for
the different objects that each LRU contains.

Then there is LRU object counting, as called by shrink_slab()
instead of tha nasty nr_to_scan = 0 hack:

static long
prune_super_count(
	struct shrinker *shrink)
	{
	struct super_block *sb;
	long    total_objects = 0;

	sb = container_of(shrink, struct super_block, s_shrink);

	if (!grab_super_passive(sb))
	       return -1;

	if (sb->s_op && sb->s_op->nr_cached_objects)
	       total_objects = sb->s_op->nr_cached_objects(sb);

	total_objects += shrinker_lru_count(&sb->s_dentry_lru);
	total_objects += shrinker_lru_count(&sb->s_inode_lru);

        total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
        drop_super(sb);
        return total_objects;
}

And the guts of prune_super(), which is later called by shrink_slab() once it
has worked out how much to scan:

	dentries = shrinker_lru_count(&sb->s_dentry_lru);
	inodes = shrinker_lru_count(&sb->s_inode_lru);
	if (sb->s_op && sb->s_op->nr_cached_objects)
	        fs_objects = sb->s_op->nr_cached_objects(sb);

	total_objects = dentries + inodes + fs_objects + 1;

	/* proportion the scan between the caches */
	dentries = (sc->nr_to_scan * dentries) / total_objects;
	inodes = (sc->nr_to_scan * inodes) / total_objects;
	if (fs_objects)
	        fs_objects = (sc->nr_to_scan * fs_objects) / total_objects;

	/*
	 * prune the dcache first as the icache is pinned by it, then
	 * prune the icache, followed by the filesystem specific caches
	 */
	sc->nr_to_scan = dentries;
	nr = shrinker_lru_shrink(&sb->s_dentry_lru, sc);
	sc->nr_to_scan = inodes;
	nr += shrinker_lru_shrink(&sb->s_inode_lru, sc);

	if (fs_objects && sb->s_op->free_cached_objects) {
	        sc->nr_to_scan = fs_objects;
	        nr += sb->s_op->free_cached_objects(sb, sc);
	}

	drop_super(sb);
	return nr;
}

IOWs, it's still the same count/scan shrinker interface, just with
all the LRU and shrinker bits abstracted and implemented in common
code. The generic LRU abstraction is that it only knows about the
list-head in the structure that is passed to it, and it passes that
listhead to the per-object callbacks for the subsystem to do the
specific work that is needed. The LRU/shrinker doesn't need to know
anything about the object being added or freed, so it only needs to
concern itself with lists of opaque objects. Hence we can change the
LRU internals without having to change any of the per-subsystem
code.

But it does not alter the fact that the subsystem is ultimately
responsible for how the shrinker is controlled and interoperates
with other subsystems...

> > I've looked at memcg awareness in the past, but the problem is the
> > overhead - the explosion of LRUs because of the per-sb X per-node X
> > per-memcg object tracking matrix.  It's a huge amount of overhead
> > and complexity, and unless there's a way of efficiently tracking
> > objects both per-node and per-memcg simulatneously then I'm of the
> > opinion that memcg awareness is simply too much trouble, complexity
> > and overhead to bother with.
> > 
> > So, convince me you can solve the various problems. ;)
> 
> I believe we are open minded regarding a solution for that, and your
> input is obviously top. So let me take a step back and restate the problem:
> 
> 1) Some memcgs, not all, will have memory pressure regardless of the
> memory pressure in the rest of the system
> 2) that memory pressure may or may not involve kernel objects.
> 3) if kernel objects are involved, we can assume the level of sharing is
> low.

I don't think you can make this assumption. You could simply have a
circle-thrash of a shared object where the first memcg reads it,
caches it, then reclaims it, then the second does the same thing,
then the third, and so on around the circle....

> 4) We then need to shrink memory from that memcg, affecting the
> others the least we can.
> 
> Do you have any proposals for that, in any shape?
> 
> One thing that crossed my mind, was instead of having per-sb x
> per-node objects, we could have per-"group" x per-node objects.
> The group would then be either a memcg or a sb.

Perhaps we've all been looking at the problem the wrong way.

As I was writing this, it came to me that the problem is not that
"the object is owned either per-sb or per-memcg". The issue is how
to track the objects in a given context. The overall LRU manipulations
and ownership of the object is identical in both the global and
memcg cases - it's the LRU that the object is placed on that
matters! With a generic LRU+shrinker implementation, this detail is
completely confined to the internals of the LRU+shrinker subsystem.

IOWs, if you are tagging the object with memcg info at a slab page
level, the LRU and shrinker need to operate at the same level, not
at the per-object level. The LRU implementation I have currently
selects the internal LRU list according to the node the object was
allocated on. i.e. by looking at the page:

int
shrinker_lru_add(
	struct shrinker_lru *lru,
	struct list_head *item)
{
>>>>>	int node_id = page_to_nid(virt_to_page(item)); <<<<<<<<<
	struct shrinker_lru_node *nlru = &lru->node[node_id];

	spin_lock(&nlru->lock);
	lru_list_check(lru, nlru, node_id);
	if (list_empty(item)) {
	       list_add(item, &nlru->lru);
	       if (nlru->lru_items++ == 0)
		       node_set(node_id, lru->active_nodes);
	       BUG_ON(nlru->lru_items < 1);
	       spin_unlock(&nlru->lock);
	       pr_info("shrinker_lru_add: item %p, node %d %p, items 0x%lx",
		       item, node_id, nlru, nlru->lru_items);
	       return 1;
	}
	lru_list_check(lru, nlru, node_id);
	spin_unlock(&nlru->lock);
	return 0;
}
EXPORT_SYMBOL(shrinker_lru_add);

There is no reason why we couldn't determine if an object was being
tracked by a memcg in the same way. Do we have a page_to_memcg()
function? If we've got that, then all we need to add to the struct
shrinker_lru is a method of dynamically adding and looking up the
memcg to get the appropriate struct shrinker_lru_node from the
memcg. The memcg would need a struct shrinker_lru_node per generic
LRU in use, and this probably means we need to uniquely identify
each struct shrinker_lru instance so the memcg code can kept a
dynamic list of them.

With that, we could track objects per memcg or globally on the
per-node lists.  If we then add a memcg id to the struct
scan_control, the shrinker can then walk the related memcg LRU
rather than the per-node LRU.  That means that general per-node
reclaim won't find memcg related objects, and memcg related reclaim
won't scan the global per-node objects. This could be changed as
needed, though.

What it does, though, is preserve the correct balance of related
caches in the memcg because they use exactly the same subsystem code
that defines the relationship for the global cache. It also
preserves the scalabilty of the non-memcg based processes, and
allows us to tune the global vs memcg LRU reclaim algorithm in a
single place.

That, to me, sounds almost ideal - memcg tracking and reclaim works
with very little added complexity, it has no additional memory
overhead, and scalability is not compromised. What have I missed? :P

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
