Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 956416B0034
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:10 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z5so3049968lbh.21
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:08 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 00/16] kmemcg shrinkers
Date: Sun,  7 Jul 2013 11:56:40 -0400
Message-Id: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>

Now that the list_lru seems to have stabilized, I am sending this out for review
again. This now contains only the memcg part of the patchset, rebased on top of
today's linux-next. Comments appreciated.

This patchset implements targeted shrinking for memcg when kmem limits are
present. So far, we've been accounting kernel objects but failing allocations
when short of memory. This is because our only option would be to call the
global shrinker, depleting objects from all caches and breaking isolation.

The main idea is to associate per-memcg lists with each of the LRUs. The main
LRU still provides a single entry point and when adding or removing an element
from the LRU, we use the page information to figure out which memcg it belongs
to and relay it to the right list.

Main changes from *v9
* Fixed iteration over all memcgs from list_lru side.

Main changes from *v8
* fixed xfs umount bug
* rebase to current linux-next

Main changes from *v7:
* Fixed races for memcg
* Enhanced memcg hierarchy walks during global pressure (we were walking only
  the global list, not all memcgs)

Main changes from *v6:
* Change nr_unused_dentry to long, Dave reported an int not being enough
* Fixed shrink_list leak, by Dave
* LRU API now gets a node id, instead of a node mask.
* per-node deferred work, leading to smoother behavior

Main changes from *v5:
* Rebased to linux-next, and fix the conflicts with the dcache.
* Make sure LRU_RETRY only retry once
* Prevent the bcache shrinker to scan the caches when disabled (by returning
  0 in the count function)
* Fix i915 return code when mutex cannot be acquired.
* Only scan less-than-batch objects in memcg scenarios

Main changes from *v4:
* Fixed a bug in user-generated memcg pressure
* Fixed overly-agressive slab shrinker behavior spotted by Mel Gorman
* Various other fixes and comments by Mel Gorman

Main changes from *v3:
* Merged suggestions from mailing list.
* Removed the memcg-walking code from LRU. vmscan now drives all the hierarchy
  decisions, which makes more sense
* lazily free the old memcg arrays (needs now to be saved in struct lru). Since
  we need to call synchronize_rcu, calling it for every LRU can become expensive
* Moved the dead memcg shrinker to vmpressure. Already independently sent to
  linux-mm for review.
* Changed locking convention for LRU_RETRY. It now needs to return locked, which
  silents warnings about possible lock unbalance (although previous code was
  correct)

Main changes from *v2:
* shrink dead memcgs when global pressure kicks in. Uses the new lru API.
* bugfixes and comments from the mailing list.
* proper hierarchy-aware walk in shrink_slab.

Main changes from *v1:
* merged comments from the mailing list
* reworked lru-memcg API
* effective proportional shrinking
* sanitized locking on the memcg side
* bill user memory first when kmem == umem
* various bugfixes

*** BLURB HERE ***

Glauber Costa (16):
  memcg: make cache index determination more robust
  memcg: consolidate callers of memcg_cache_id
  vmscan: also shrink slab in memcg pressure
  memcg: move stop and resume accounting functions
  memcg,list_lru: duplicate LRUs upon kmemcg creation
  lru: add an element to a memcg list
  list_lru: per-memcg walks
  memcg: move initialization to memcg creation
  memcg: per-memcg kmem shrinking
  memcg: scan cache objects hierarchically
  vmscan: take at least one pass with shrinkers
  super: targeted memcg reclaim
  memcg: allow kmem limit to be resized down
  vmpressure: in-kernel notifications
  memcg: reap dead memcgs upon global memory pressure
  memcg: flush memcg items upon memcg destruction

 fs/dcache.c                |   7 +-
 fs/inode.c                 |   7 +-
 fs/internal.h              |   5 +-
 fs/super.c                 |  35 ++-
 include/linux/list_lru.h   |  94 +++++++-
 include/linux/memcontrol.h |  43 ++++
 include/linux/shrinker.h   |   6 +-
 include/linux/swap.h       |   2 +
 include/linux/vmpressure.h |   6 +
 mm/list_lru.c              | 246 +++++++++++++++++--
 mm/memcontrol.c            | 574 +++++++++++++++++++++++++++++++++++++++------
 mm/slab_common.c           |   1 -
 mm/vmpressure.c            |  52 +++-
 mm/vmscan.c                | 179 ++++++++++++--
 14 files changed, 1116 insertions(+), 141 deletions(-)

-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
