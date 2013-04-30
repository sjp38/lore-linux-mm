Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3F7486B00D7
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 09:22:44 -0400 (EDT)
Date: Tue, 30 Apr 2013 14:22:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 02/31] vmscan: take at least one pass with shrinkers
Message-ID: <20130430132239.GB6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-3-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-3-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Sat, Apr 27, 2013 at 03:18:58AM +0400, Glauber Costa wrote:
> In very low free kernel memory situations, it may be the case that we
> have less objects to free than our initial batch size. If this is the
> case, it is better to shrink those, and open space for the new workload
> then to keep them and fail the new allocations.
> 
> More specifically, this happens because we encode this in a loop with
> the condition: "while (total_scan >= batch_size)". So if we are in such
> a case, we'll not even enter the loop.
> 
> This patch modifies turns it into a do () while {} loop, that will
> guarantee that we scan it at least once, while keeping the behaviour
> exactly the same for the cases in which total_scan > batch_size.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Dave Chinner <david@fromorbit.com>
> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
> CC: "Theodore Ts'o" <tytso@mit.edu>
> CC: Al Viro <viro@zeniv.linux.org.uk>

There are two cases where this *might* cause a problem and worth keeping
an eye out for.

The first is that it's possible for caches to shrink to zero where before
the last SHRINK_SLAB objects would often be protected for any slab. If
this is an inode or dentry cache and there are very few objects then it's
possible that objects will be reclaimed before they can be used by the
process allocating them.

The second is if any of the shrinker users have generally a small number
of large objects then any shrink of them may chunk out even the live
objects. This will depend on the quality of the shrinker implementation
but it might expose problems that were hidden before.

Neither potential issue are the fault of your patch so I'm not going
to nack. However, bear in mind that we should watch out for bugs where
processes stall making forward progress because they are constantly
reallocating inodes or bugs like graphics stalls because their objects
keep getting fully reclaimed as only a small number exist.

I suspect that you need this patch because it's very reasonable for a memcg
to have slabs with tiny numbers of objects you want to reclaim. However,
if my imagined scenarios are a problem in reality then you'll need to
revert this patch and special case for memcg. Alternatively you could
shrink in two passes. The first which never shrinks a slab below
shrinker->batch *but* if all slabs are below that threshold then shrink
the slab to 0.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
