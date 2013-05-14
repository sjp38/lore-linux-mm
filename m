Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 6F99E6B008A
	for <linux-mm@kvack.org>; Tue, 14 May 2013 05:52:05 -0400 (EDT)
Date: Tue, 14 May 2013 19:52:00 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 12/31] fs: convert inode and dentry shrinking to be
 node aware
Message-ID: <20130514095200.GI29466@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-13-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368382432-25462-13-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@parallels.com>

On Sun, May 12, 2013 at 10:13:33PM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that the shrinker is passing a nodemask in the scan control
> structure, we can pass this to the the generic LRU list code to
> isolate reclaim to the lists on matching nodes.
> 
> This requires a small amount of refactoring of the LRU list API,
> which might be best split out into a separate patch.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

What I see at this point is that the superblock shrinkers appear to
be way too agressive. As soon as memory pressure hits, the slab
caches are getting emptied down to almost nothing. I'm testing on a
4 node fake-numa system here, so I initially suspected what is
happening is that the amount of reclaim has just been multiplied by
4.

Peak performance is good, it's just that there is no stable steady
state - the caches are either filling at maximum rate, or being
emptied at maximum rate - and that implies that the shrinkers are
doing more work than they need to.

I think this is the point at what we need to ensure that the balance
between the dentry/inode caches and the page cache is balanced, so
I'm going to see what happens when I tweak a few numbers. e.g. see
what effect tweaking shrink.seeks has on the rate of change of the
cache sizes.....

Changing the seek count doesn't change the fact that it's
fundamentally unstable. More investigation needed. Trace points.

kswapd0-632 mm_shrink_slab_start: objects to shrink 945211
		gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 7046
		cache items 600456 delta 1363 total_scan 300228

Bingo. We've got windup!

	objects to shrink = shrinker->nr_in_batch
			  = 945211
			  = large amount of deferred work
	cache items = max_pass
		    = current cache size
		    = 600456
	total_scan  = 300228
		    = (cache items) / 2.
	delta	    = 1363

And this code:

                /*
                 * We need to avoid excessive windup on filesystem shrinkers
                 * due to large numbers of GFP_NOFS allocations causing the
                 * shrinkers to return -1 all the time. This results in a large
                 * nr being built up so when a shrink that can do some work
                 * comes along it empties the entire cache due to nr >>>
                 * max_pass.  This is bad for sustaining a working set in
                 * memory.
                 *
                 * Hence only allow the shrinker to scan the entire cache when
                 * a large delta change is calculated directly.
                 */
                if (delta < max_pass / 4)
                        total_scan = min(total_scan, max_pass / 2);

Has obviously triggered.

So, it would seem to me that we have a relatively small amount of
incremental memory pressure, but an awful lot of deferred work. When
I see this:

kswapd0-632 1210443.469309: mm_shrink_slab_start: cache items 600456 delta 1363 total_scan 300228
kswapd3-635 1210443.510311: mm_shrink_slab_start: cache items 514885 delta 1250 total_scan 101025
kswapd1-633 1210443.517440: mm_shrink_slab_start: cache items 613824 delta 1357 total_scan 97727
kswapd2-634 1210443.527026: mm_shrink_slab_start: cache items 568610 delta 1331 total_scan 259185
kswapd3-635 1210443.573165: mm_shrink_slab_start: cache items 486408 delta 1277 total_scan 243204
kswapd1-633 1210443.697012: mm_shrink_slab_start: cache items 550827 delta 1224 total_scan 82231

in the space of 230ms, I can see why the caches are getting
completely emptied. kswapds are making multiple, large scale scan
passes on the caches. Looks like our problem is an impedence
mismatch: global windup counter, per-node cache scan calculations.

So, that's the mess we really need to cleaning up before going much
further with this patchset. We need stable behaviour from the
shrinkers - I'll look into this a bit deeper tomorrow.

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
