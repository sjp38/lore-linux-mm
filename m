Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 413056B0036
	for <linux-mm@kvack.org>; Mon, 13 May 2013 21:48:11 -0400 (EDT)
Date: Tue, 14 May 2013 11:48:05 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 00/31] kmemcg shrinkers
Message-ID: <20130514014805.GA29466@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <20130513071359.GM32675@dastard>
 <51909D84.7040800@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51909D84.7040800@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org

On Mon, May 13, 2013 at 12:00:04PM +0400, Glauber Costa wrote:
> On 05/13/2013 11:14 AM, Dave Chinner wrote:
> > On Sun, May 12, 2013 at 10:13:21PM +0400, Glauber Costa wrote:
> >> Initial notes:
> >> ==============
> >>
> >> Mel, Dave, this is the last round of fixes I have for the series. The fixes are
> >> few, and I was mostly interested in getting this out based on an up2date tree
> >> so Dave can verify it. This should apply fine ontop of Friday's linux-next.
> >> Alternatively, please grab from branch "kmemcg-lru-shrinker" at:
> >>
> >> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git
> >>
> >> Main changes from *v5:
> >> * Rebased to linux-next, and fix the conflicts with the dcache.
> >> * Make sure LRU_RETRY only retry once
> >> * Prevent the bcache shrinker to scan the caches when disabled (by returning
> >>   0 in the count function)
> >> * Fix i915 return code when mutex cannot be acquired.
> >> * Only scan less-than-batch objects in memcg scenarios
> > 
> > Ok, this is behaving a *lot* better than v5 in terms of initial
> > balance and sustained behaviour under pure inode/dentry press
> > workloads. The previous version was all over the place, not to
> > mention unstable and prone to unrealted lockups in the block layer.
> > 
> 
> Good to hear. About the problems you are seeing, if possible, I think
> it would beneficial to do what Mel did, and run a test workload without
> the upper half of the patches, IOW, excluding memcg. It should at least
> give us an indication about whether or not the problem lies in the way
> we are handling the LRU list, or in any memcg adaptation problem.
> 
> > However, I'm not sure that the LRUness of reclaim is working
> > correctly at this point. When I switch from a write only workload to
> > a read-only workload (i.e. fsmark finishes and find starts), I see
> > this:
> > 
> >  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> > 1923037 1807201  93%    1.12K  68729       28   2199328K xfs_inode
> > 1914624 490812  25%    0.22K  53184       36    425472K xfs_ili
> > 
> > Note the xfs_ili slab capacity - there's half a million objects
> > still in the cache, and they are only present on *dirty* inodes.
> 
> May a xfs-ignorant kernel hacker ask you what exactly xfs_ili is ?

struct xfs_inode_log_item.

It's the structure used to track the inode through the journalling
subsystem, and it's only allocated when the inode is first modified.
The embedded xfs_log_item is the abstraction used throughout the
core transaction and journalling subsystems - every dirty metadata
object in XFS has a xfs_log_item attached to it in some way.

> > Now, the read-only workload is iterating through a cold-cache lookup
> > workload of 50 million inodes - at roughly 150,000/s. It's a
> > touch-once workload, so shoul dbe turning the cache over completely
> > every 10 seconds. However, in the time it's taken for me to explain
> > this:
> > 
> >  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
> > 1954493 1764661  90%    1.12K  69831       28   2234592K xfs_inode
> > 1643868 281962  17%    0.22K  45663       36    365304K xfs_ili   
> > 
> > Only 200k xfs_ili's have been freed. So the rate of reclaim of them
> > is roughly 5k/s. Given the read-only nature of this workload, they
> > should be gone from the cache in a few seconds. Another indication
> > of problems here is the level of internal fragmentation of the
> > xfs_ili slab. They should cycle out of the cache in LRU manner, just
> > like inodes - the modify workload is a "touch once" workload as
> > well, so there should be no internal fragmentation of the slab
> > cache.
> > 
> 
> Initial testing I have done indicates - although it does not undoubtly
> prove  - that the problem may be with dentries, not inodes

That tallies with the stats I'm seeing showing a significant
difference in the balance of allocated vs "free" dentries. On a 3.9 kernel,
the is little difference between them - dentries move quickly to the
LRU and are considered free, while this patchset starts the same
they quickly diverge, with the free count dropping well away from
the allocated count.

....

> You are seeing problems in the inode behavior, but since the dentry
> cache may pin them, I believe it is possible that the change in behavior
> in the dentry cache may drive the change in behavior in the inode cache,
> by keeping inodes that should be freed, pinned. (So far, just a theory)

Yup, that's the theory I'm working to given the inode used vs free
count differences reflect the differences in the dentry behaviour...

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
