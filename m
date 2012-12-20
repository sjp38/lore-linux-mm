Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 8F1816B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 06:45:25 -0500 (EST)
Message-ID: <50D2FA58.9030605@parallels.com>
Date: Thu, 20 Dec 2012 15:45:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
In-Reply-To: <1354058086-27937-1-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On 11/28/2012 03:14 AM, Dave Chinner wrote:
> Hi Glauber,
> 
> Here's a working version of my patchset for generic LRU lists and
> NUMA-aware shrinkers.
> 
> There are several parts to this patch set. The NUMA aware shrinkers
> are based on having a generic node-based LRU list implementation,
> and there are subsystems that need to be converted to use these
> lists as part of the process. There is also a long overdue change to
> the shrinker API to give it separate object count and object scan
> callbacks, getting rid of the magic and confusing "nr_to_scan = 0"
> semantics.
> 
> First of all, the patch set is based on a current 3.7-rc7 tree with
> the current xfs dev tree merged into it [can be found at
> git://oss.sgi.com/xfs/xfs]. That's because there are lots of XFS
> changes in the patch set, and theres no way I'm going to write them
> a second time in a couple of weeks when the current dev tree is
> merged into 3.8-rc1....
> 
> So, where's what the patches do:
> 
> [PATCH 01/19] dcache: convert dentry_stat.nr_unused to per-cpu
> [PATCH 02/19] dentry: move to per-sb LRU locks
> [PATCH 03/19] dcache: remove dentries from LRU before putting on
> 
> These three patches are preparation of the dcache for moving to the
> generic LRU list API. it basically gets rid of the global dentry LRU
> lock, and in doing so has to avoid several creative abuses of the
> lru list detection to allow dentries on shrink lists to be still
> magically be on the LRU list. The main change here is that now
> dentries on the shrink lists *must* have the DCACHE_SHRINK_LIST flag
> set and be entirely removed from the LRU before being disposed of.
> 
> This is probably a good cleanup to do regardless of the rest of the
> patch set because it removes a couple of landmines in
> shrink_dentry_list() that took me a while to work out...
> 
> [PATCH 04/19] mm: new shrinker API
> [PATCH 05/19] shrinker: convert superblock shrinkers to new API
> 
> These introduce the count/scan shrinker API, and for testing
> purposes convert the superblock shrinker to use it before any other
> changes are made. This gives a clean separation of counting the
> number of objects in a cache for pressure calculations, and the act
> of scanning objects in an attempt to free memory. Indeed, the
> scan_objects() callback now returns the number of objects freed by
> the scan instead of having to try to work out whether any progress
> was made by comparing absolute counts.
> 
> This is also more efficient as we don't have to count all the
> objects in a cache on every scan pass. It is now done once per
> shrink_slab() invocation to calculate how much to scan, and we get
> direct feedback on how much gets reclaimed in that pass. i.e. we get
> reliable, accurate feedback on shrinker progress.
> 
> [PATCH 06/19] list: add a new LRU list type
> [PATCH 07/19] inode: convert inode lru list to generic lru list
> [PATCH 08/19] dcache: convert to use new lru list infrastructure
> 
> These add the generic LRU list API and infrastructure and convert
> the inode and dentry caches to use it. This is still just a single
> global list per LRU at this point, so it's really only changing the
> where the LRU implemenation is rather than the fundamental
> algorithm. It does, however, introduce a new method of walking the
> LRU lists and building the dispose list of items for shrinkers, but
> because we are still dealing with a global list the algorithmic
> changes are minimal.
> 
> [PATCH 09/19] list_lru: per-node list infrastructure
> 
> This makes the generic LRU list much more scalable by changing it to
> a {list,lock,count} tuple per node. There are no external API
> changes to this changeover, so is transparent to current users.
> 
> [PATCH 10/19] shrinker: add node awareness
> [PATCH 11/19] fs: convert inode and dentry shrinking to be node
> 
> Adds a nodemask to the struct shrink_control for callers of
> shrink_slab to set appropriately for their reclaim context. This
> nodemask is then passed by the inode and dentry cache reclaim code
> to the generic LRU list code to implement node aware shrinking.
> 
> What this doesn't do is convert the internal shrink_slab() algorithm
> to be node aware. I'm not sure what the best approach is here, but
> it strikes me that it should really be calculating and keeping track
> of scan counts and pressure on a per-node basis. The current code
> seems to work OK at the moment, though.
> 
> [PATCH 12/19] xfs: convert buftarg LRU to generic code
> [PATCH 13/19] xfs: Node aware direct inode reclaim
> [PATCH 14/19] xfs: use generic AG walk for background inode reclaim
> [PATCH 15/19] xfs: convert dquot cache lru to list_lru
> 
> These patches convert all the XFS LRUs and shrinkers to be node
> aware. This gets rid of a lot of hairy, special case code in the
> inode cache shrinker for avoiding concurrent shrinker contention and
> to throttle direct reclaim to prevent premature OOM conditions.
> Removing this code greatly simplifies inode cache reclaim whilst
> reducing overhead and improving performance. In all, it converts
> three separate caches and shrinkers to use the generic LRU lists and
> pass nodemasks around appropriately.
> 
> This is how I've really tested the code - lots of interesting
> filesystem workloads that generate simultaneous slab and page cache
> pressure on VM's with and without fake_numa configs....
> 
> [PATCH 16/19] fs: convert fs shrinkers to new scan/count API
> [PATCH 17/19] drivers: convert shrinkers to new count/scan API
> [PATCH 18/19] shrinker: convert remaining shrinkers to count/scan
> [PATCH 19/19] shrinker: Kill old ->shrink API.
> 
> These last three patches convert all the other shrinker
> implementations to the new count/scan API.  The fs, android and dm
> shrinkers are pretty well behaved and are implemented as is expected
> for there intended purposes. The driver and staging code, however,
> is basically a bunch of hacks to try to do something resembling
> reclaim when a shrinker tells it there is memory pressure. Looking
> at all the driver and staging code is not an exercise I recommend if
> you value your eyes and/or your sanity.
> 
> I haven't even tried to compile this on a CONFIG_SMP=n
> configuration, nor have I done extensive allmod style build tests
> and it's only been built and tested on x86-64. That said, apart from
> CONFIG_SMP=n, I don't see there being any major problems here.
> 
> There's still a bunch of cleanup work needed. e.g. the LRU list
> walk/isolation code needs to use enums for the isolate callback
> return code, there needs to be a generic list_lru_for_each() style
> function for walking all the objects in the cache (which will allow
> the list_lru structures to be used for things like the per-sb inode
> list). Indeed, even the name "list_lru" is probably something that
> should be changed - I think the list has become more of a general
> per-node list than it's initial functionality as a scalable LRU list
> implementation and I can see uses for it outside of LRUs...
> 
> Comments, thoughts and flames all welcome.
> 

I like the general idea, and after a small PoC on my side, I can say it
can at least provide us with a good and sound route to solve the
targetted memcg shrinking problem.

I've already provided you some small feedback about the interface in the
specific patches.

But on a broader sense: The only thing that still bothers me personally
(meaning: it created particular pain points), is the very loose coupling
between all the elements involved in the shrinking process:

1) the shrinker, always present
2) the lru, usually present
3) the cache, usually present, specially when there is an LRU.

I of course understand that they are not always present, and when they
are, they are not in a 1:1 relation.

But still, it would be nice to be able to register them to one another,
so that we can easily answer things like:

"Given a set of caches, what is the set of shrinkers that will shrink them?"

"What are the lrus that are driven by this shrinker?"

This would allow me to do things like this:

* When a per-memcg cache is created (not all of the caches are
replicated), find the shrinkers that can shrink them.

* For each shrinker, also replicate the LRUs that are driven by them.

Does that make any sense to you ?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
