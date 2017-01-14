Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58EE76B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:54:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 75so4481565pgf.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:54:55 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id j191si7424853pgd.132.2017.01.13.21.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 21:54:54 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 75so343941pgf.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:54:54 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] slab: make memcg slab destruction scalable
Date: Sat, 14 Jan 2017 00:54:40 -0500
Message-Id: <20170114055449.11044-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

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

* Separate out root and memcg cache lists and add per-memcg list.
  Update each user to use the appropriate list.

* Replace rcu_barrier() and synchronize_rcu() with call_rcu() and
  call_rcu_sched().

* For dying empty slub caches, remove the sysfs files after
  deactivation so that we don't end up with millions of sysfs files
  without any useful information on them.

This patchset contains the following nine patches.

 0001-Revert-slub-move-synchronize_sched-out-of-slab_mutex.patch
 0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch
 0003-slab-simplify-shutdown_memcg_caches.patch
 0004-slab-reorganize-memcg_cache_params.patch
 0005-slab-link-memcg-kmem_caches-on-their-associated-memo.patch
 0006-slab-don-t-put-memcg-caches-on-slab_caches-list.patch
 0007-slab-introduce-__kmemcg_cache_deactivate.patch
 0008-slab-remove-synchronous-synchronize_sched-from-memcg.patch
 0009-slab-remove-slub-sysfs-interface-files-early-for-emp.patch

0001 reverts an existing optimization to prepare for the following
changes.  0002 replaces rcu_barrier() in release path with call_rcu().
0003-0006 separate out the lists.  0007-0008 replace
synchronize_sched() in slub destruction path with call_rcu_sched().
0009 removes sysfs files early for empty dying caches.

This patchset is on top of the current linus#master a121103c9228 and
also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-kmemcg-scalability

diffstat follows.  Thanks.

 include/linux/memcontrol.h |    1 
 include/linux/slab.h       |   39 ++++-
 include/linux/slab_def.h   |    5 
 include/linux/slub_def.h   |    9 -
 mm/memcontrol.c            |    7 -
 mm/slab.c                  |    7 +
 mm/slab.h                  |   21 ++-
 mm/slab_common.c           |  306 ++++++++++++++++++++++++---------------------
 mm/slub.c                  |   54 +++++++
 9 files changed, 283 insertions(+), 166 deletions(-)

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
