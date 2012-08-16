Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2ED326B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 19:42:26 -0400 (EDT)
Date: Fri, 17 Aug 2012 09:41:57 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
Message-ID: <20120816234157.GB2776@devil.redhat.com>
References: <1345150417-30856-1-git-send-email-yinghan@google.com>
 <502D61E1.8040704@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502D61E1.8040704@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org

On Thu, Aug 16, 2012 at 05:10:57PM -0400, Rik van Riel wrote:
> On 08/16/2012 04:53 PM, Ying Han wrote:
> >The patchset adds the functionality of isolating the vfs slab objects per-memcg
> >under reclaim. This feature is a *must-have* after the kernel slab memory
> >accounting which starts charging the slab objects into individual memcgs. The
> >existing per-superblock shrinker doesn't work since it will end up reclaiming
> >slabs being charged to other memcgs.

What list was this posted to?

The per-sb shrinkers are not intended for memcg granularity - they
are for scalability in that they allow the removal of the global
inode and dcache LRU locks and allow significant flexibility in
cache relcaim strategies for filesystems. Hint: reclaiming
the VFS inode cache doesn't free any memory on an XFS filesystem -
it's the XFS inode cache shrinker that is integrated into the per-sb
shrinker infrastructure that frees all the memory. It doesn't work
without the per-sb shrinker functionality and it's an extremely
performance critical balancing act. Hence any changes to this
shrinker infrastructure need a lot of consideration and testing,
most especially to ensure that the balance of the system has not
been disturbed.

Also how do yo propose to solve the problem of inodes and dentries
shared across multiple memcgs?  They can only be tracked in one LRU,
but the caches are global and are globally accessed. Having mem
pressure in a single memcg that causes globally accessed dentries
and inodes to be tossed from memory will simply cause cache
thrashing and performance across the system will tank.

> >The patch now is only handling dentry cache by given the nature dentry pinned
> >inode. Based on the data we've collected, that contributes the main factor of
> >the reclaimable slab objects. We also could make a generic infrastructure for
> >all the shrinkers (if needed).
> 
> Dave Chinner has some prototype code for that.

The patchset I have makes the dcache lru locks per-sb as the first
step to introducing generic per-sb LRU lists, and then builds on
that to provide generic kernel-wide LRU lists with integrated
shrinkers, and builds on that to introduce node-awareness (i.e. NUMA
scalability) into the LRU list so everyone gets scalable shrinkers.

I've looked at memcg awareness in the past, but the problem is the
overhead - the explosion of LRUs because of the per-sb X per-node X
per-memcg object tracking matrix.  It's a huge amount of overhead
and complexity, and unless there's a way of efficiently tracking
objects both per-node and per-memcg simulatneously then I'm of the
opinion that memcg awareness is simply too much trouble, complexity
and overhead to bother with.

So, convince me you can solve the various problems. ;)

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
