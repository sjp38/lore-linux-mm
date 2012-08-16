Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 9A6946B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 16:53:40 -0400 (EDT)
Received: by lboj14 with SMTP id j14so148751lbo.2
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:53:38 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
Date: Thu, 16 Aug 2012 13:53:37 -0700
Message-Id: <1345150417-30856-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

The patchset adds the functionality of isolating the vfs slab objects per-memcg
under reclaim. This feature is a *must-have* after the kernel slab memory
accounting which starts charging the slab objects into individual memcgs. The
existing per-superblock shrinker doesn't work since it will end up reclaiming
slabs being charged to other memcgs.

The last rebase of the patch is v3.3 and now the kernel is up and running on
our enviroment. I rebased it on top of v3.5 w/ little conflicts for posting
here, and this post is mainly a RFC for the design.

There is a functional dependency of this patchset on slab accounting, where it
queries the owner of the slab object. I left that commented out in order to
get the kernel at least compile for now. Regarding the two implementations of
the kernel slab accounting in google vs upstream, they shares lots of
similarities and the main difference is how reparenting works under
mem_cgroup_destroy(). In google, we have the kmem_cache reparented to root as
well as the dentry objects. So further pressure applies under root will end up
reclaiming the objects as well. By given the kernel slab accounting feature is
still under discussion now, I will leave that on the side for this RFC and
assume the reparenting to root still hold.

The patch now is only handling dentry cache by given the nature dentry pinned
inode. Based on the data we've collected, that contributes the main factor of
the reclaimable slab objects. We also could make a generic infrastructure for
all the shrinkers (if needed). But as we discussed during last KS, making dentry
works would be a good start. Eventually, that might be the only thing we cares
about.

Before getting into the implementation, we did consider other options:
1. keep the global list but does the filtering when scan. The performance is
really bad under our tests.
2. make per-superblock per-memcg lru list. The implementation would be very
complicated considering all the race conditions.

The work was started by Andrew Bresticker (a former intern) and also greatly
inspired by Nikhil Rao<ncrao@google.com>, Greg Thelen(gthelen@google.com>
and Suleiman Souhlal<suleiman@google.com> for the slab accounting.

Ying Han (6):
  mm: pass priority to prune_icache_sb()
  mm: memcg add target_mem_cgroup, mem_cgroup fields to shrink_control
  mm: memcg restructure shrink_slab to walk memory cgroup hierarchy
  mm: shrink slab with memcg context
  mm: move dcache slabs to root lru when memcg exits
  mm: shrink slab during memcg reclaim

 fs/dcache.c                |  214 ++++++++++++++++++++++++++++++++++++++++---
 fs/inode.c                 |   40 ++++++++-
 fs/super.c                 |   30 +++++--
 include/linux/dcache.h     |    8 ++
 include/linux/fs.h         |   34 ++++++-
 include/linux/memcontrol.h |    8 ++
 include/linux/shrinker.h   |   12 +++
 include/linux/slab_def.h   |    5 +
 mm/memcontrol.c            |   49 ++++++++++
 mm/slab.c                  |    8 ++
 mm/vmscan.c                |   70 +++++++++++----
 11 files changed, 432 insertions(+), 46 deletions(-)

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
