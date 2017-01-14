Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8B3A6B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 13:48:46 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id c69so75526139qkg.1
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:48:46 -0800 (PST)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id a199si1046382qkb.101.2017.01.14.10.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 10:48:45 -0800 (PST)
Received: by mail-qk0-x241.google.com with SMTP id u25so11413831qki.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:48:45 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET v2] slab: make memcg slab destruction scalable
Date: Sat, 14 Jan 2017 13:48:26 -0500
Message-Id: <20170114184834.8658-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

This is v2.  Changes from the last version[L] are

* 0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch was
  incorrect and dropped.

* 0006-slab-don-t-put-memcg-caches-on-slab_caches-list.patch
  incorrectly converted places which needed to walk all caches.
  Replaced with 0005-slab-implement-slab_root_caches-list.patch which
  adds root-only list instead of converting slab_caches list to list
  only root caches.

* Misc fixes.

With kmem cgroup support enabled, kmem_caches can be created and
destroyed frequently and a great number of near empty kmem_caches can
accumulate if there are a lot of transient cgroups and the system is
not under memory pressure.  When memory reclaim starts under such
conditions, it can lead to consecutive deactivation and destruction of
many kmem_caches, easily hundreds of thousands on moderately large
systems, exposing scalability issues in the current slab management
code.

I've seen machines which end up with hundred thousands of caches and
many millions of kernfs_nodes.  The current code is O(N^2) on the
total number of caches and has synchronous rcu_barrier() and
synchronize_sched() in cgroup offline / release path which is executed
while holding cgroup_mutex.  Combined, this leads to very expensive
and slow cache destruction operations which can easily keep running
for half a day.

This also messes up /proc/slabinfo along with other cache iterating
operations.  seq_file operates on 4k chunks and on each 4k boundary
tries to seek to the last position in the list.  With a huge number of
caches on the list, this becomes very slow and very prone to the list
content changing underneath it leading to a lot of missing and/or
duplicate entries.

This patchset addresses the scalability problem.

* Add root and per-memcg lists.  Update each user to use the
  appropriate list.

* Replace rcu_barrier() and synchronize_rcu() with call_rcu() and
  call_rcu_sched().

* For dying empty slub caches, remove the sysfs files after
  deactivation so that we don't end up with millions of sysfs files
  without any useful information on them.

This patchset contains the following nine patches.

 0001-Revert-slub-move-synchronize_sched-out-of-slab_mutex.patch
 0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch
 0003-slab-reorganize-memcg_cache_params.patch
 0004-slab-link-memcg-kmem_caches-on-their-associated-memo.patch
 0005-slab-implement-slab_root_caches-list.patch
 0006-slab-introduce-__kmemcg_cache_deactivate.patch
 0007-slab-remove-synchronous-synchronize_sched-from-memcg.patch
 0008-slab-remove-slub-sysfs-interface-files-early-for-emp.patch

0001 reverts an existing optimization to prepare for the following
changes.  0002 replaces rcu_barrier() in release path with call_rcu().
0004-0005 separate out the lists.  0006-0007 replace
synchronize_sched() in slub destruction path with call_rcu_sched().
0008 removes sysfs files early for empty dying caches.

This patchset is on top of the current linus#master a121103c9228 and
also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-kmemcg-scalability

diffstat follows.  Thanks.

 include/linux/memcontrol.h |    1 
 include/linux/slab.h       |   45 ++++++-
 include/linux/slab_def.h   |    5 
 include/linux/slub_def.h   |    9 +
 mm/memcontrol.c            |    7 -
 mm/slab.c                  |    7 +
 mm/slab.h                  |   32 ++++-
 mm/slab_common.c           |  269 +++++++++++++++++++++++++++------------------
 mm/slub.c                  |   55 +++++++++
 9 files changed, 302 insertions(+), 128 deletions(-)

--
tejun

[L] http://lkml.kernel.org/r/<20170114055449.11044-1-tj@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
