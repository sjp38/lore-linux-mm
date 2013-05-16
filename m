Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id E48FE6B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 20:02:37 -0400 (EDT)
Date: Thu, 16 May 2013 10:02:16 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 12/31] fs: convert inode and dentry shrinking to be
 node aware
Message-ID: <20130516000216.GC24635@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-13-git-send-email-glommer@openvz.org>
 <20130514095200.GI29466@dastard>
 <5193A95E.70205@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5193A95E.70205@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Wed, May 15, 2013 at 07:27:26PM +0400, Glauber Costa wrote:
> On 05/14/2013 01:52 PM, Dave Chinner wrote:
> > kswapd0-632 1210443.469309: mm_shrink_slab_start: cache items 600456 delta 1363 total_scan 300228
> > kswapd3-635 1210443.510311: mm_shrink_slab_start: cache items 514885 delta 1250 total_scan 101025
> > kswapd1-633 1210443.517440: mm_shrink_slab_start: cache items 613824 delta 1357 total_scan 97727
> > kswapd2-634 1210443.527026: mm_shrink_slab_start: cache items 568610 delta 1331 total_scan 259185
> > kswapd3-635 1210443.573165: mm_shrink_slab_start: cache items 486408 delta 1277 total_scan 243204
> > kswapd1-633 1210443.697012: mm_shrink_slab_start: cache items 550827 delta 1224 total_scan 82231
> > 
> > in the space of 230ms, I can see why the caches are getting
> > completely emptied. kswapds are making multiple, large scale scan
> > passes on the caches. Looks like our problem is an impedence
> > mismatch: global windup counter, per-node cache scan calculations.
> > 
> > So, that's the mess we really need to cleaning up before going much
> > further with this patchset. We need stable behaviour from the
> > shrinkers - I'll look into this a bit deeper tomorrow.
> 
> That doesn't totally make sense to me.
> 
> Both our scan and count functions will be per-node now. This means we
> will always try to keep ourselves within reasonable maximums on a
> per-node basis as well.

Right, but if we have a bunch of GFP_NOFS reclaims on multiple nodes
at the same time, we get:

	max_pass = shr->count_objects;
	nr = shr->nr_in_batch
	shr->nr_in_batch = 0
	/* total_scan has new delta added */
	/* nothing scanned */
	shr->nr_in_batch += total_scan;

And then the next node does the same, and so on.

What I cut from the above output was the shr->nr_in_batch values.
They were:

 kswapd1-633   [001] 1210443.500045: objects to shrink 4077
	 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 7096 cache
	 items 623079 delta 1404 total_scan 5481
 kswapd1-633   [001] 1210443.504315: objects to shrink 15138
	 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 7224 cache
	 items 620936 delta 1375 total_scan 16513
 kswapd3-635   [007] 1210443.510311: objects to shrink 99775
	 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 6587 cache
	 items 514885 delta 1250 total_scan 101025
 kswapd1-633   [001] 1210443.517440: objects to shrink 96370
	 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 7236 cache
	 items 613824 delta 1357 total_scan 97727
 kswapd2-634   [006] 1210443.527026: objects to shrink 257854
	 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 6831 cache
	 items 568610 delta 1331 total_scan 259185
 kswapd3-635   [007] 1210443.573165: objects to shrink 1034342
	 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 6089 cache
	 items 486408 delta 1277 total_scan 243204

So you can see that the number of objects being deferred is driving
the total_scan count completely in these cases.

This is over a period of 70ms - shr->nr_in_batch has gone from
roughly zero to 1034342 because of deferred work. Between these
traces are hundreds of GFP_NOFS reclaims from all 8 cpus (i.e.
direct reclaim, every 300-400us on *each* CPU), each adding ~1200 to
shr->nr_in_batch, and the only thing able to reclaim memory is
kswapd as it does GFP_KERNEL context reclaim.

IOWs, each kswapd is taking the global windup and applying it to
each per-node list, when in fact the windup is not distributed that
way. The trace leading up to this kswapd scan:

 kswapd1-633   [001] 1210443.517440: objects to shrink 96370
	 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 7236 cache
	 items 613824 delta 1357 total_scan 97727

Shows that most of the deferred work has come from CPUs 2, 3, 4 and
a little from CPU 5. The cpu->node map shows that only CPU 5 is on
node 1 (cpus 1 and 5 are on node 1), so this means that less than a
quarter of the work that this node 1 shrinker is being asked to do
was deferred from node 1. Most of it was deferred from nodes 0, 2
and 3, and so this work the shrinker is doing is doing nothing to
relieve the memory pressure on those nodes. So direct reclaim on
those nodes continues to wind up the nr_in_batch count.

And look at where the per-node cache count and windup is getting to
at times in this process:

fs_mark-5561  [002] 1210443.555528: objects to shrink 2914436
	gfp_flags GFP_NOFS|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|GFP_NOTRACK
	pgs_scanned 32 lru_pgs 26591
	cache items 2085764 delta 1254 total_scan 1042882

What we see here is a node with more than 2 million filesystem items cached on
it. The other nodes are around 500,000 at this point, indicating
that we definitely have a per-node reclaim imbalance....

IOWs, shr->nr_in_batch can grow much larger than any single node LRU
list, and the deffered count is only limited to (2 * max_pass).
Hence if the same node is the one that keeps stealing the global
shr->nr_in_batch calculation, it will always be a number related to
the size of the cache on that node. All the other nodes will simply
keep adding their delta counts to it.

Hence if you've got a node with less cache in it than others, and
kswapd comes along, it will see a gigantic amount of deferred work
in nr_in_batch, and then we end up removing a large amount of the
cache on that node, even though it hasn't had a significant amount
of pressure. And the node that has pressure continues to wind up
nr_in_batch until it's the one that gets hit by a kswapd run with
that wound up nr_in_batch....

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
