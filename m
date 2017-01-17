Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD066B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 18:54:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so75842134pge.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:17 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id f6si16916633plm.125.2017.01.17.15.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 15:54:16 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id t6so5033176pgt.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:54:15 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET v3] slab: make memcg slab destruction scalable
Date: Tue, 17 Jan 2017 15:54:01 -0800
Message-Id: <20170117235411.9408-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

Changes from [V2] to V3.

* 0002-slub-separate-out-sysfs_slab_release-from-sysfs_slab.patch
  separated out from
  0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch.

* 0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch
  replaced with
  0003-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch.
  It now keeps rcu_barrier() in the kmem_cache destruction path.

* 0010-slab-memcg-wq.patch added to limit concurrency on destruction
  work items.

Changes from [V1] to [V2].

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

* Make rcu_barrier() for SLAB_DESTROY_BY_RCU caches globally batched
  and asynchronous.

* For dying empty slub caches, remove the sysfs files after
  deactivation so that we don't end up with millions of sysfs files
  without any useful information on them.

This patchset contains the following nine patches.

 0001-Revert-slub-move-synchronize_sched-out-of-slab_mutex.patch
 0002-slub-separate-out-sysfs_slab_release-from-sysfs_slab.patch
 0003-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch
 0004-slab-reorganize-memcg_cache_params.patch
 0005-slab-link-memcg-kmem_caches-on-their-associated-memo.patch
 0006-slab-implement-slab_root_caches-list.patch
 0007-slab-introduce-__kmemcg_cache_deactivate.patch
 0008-slab-remove-synchronous-synchronize_sched-from-memcg.patch
 0009-slab-remove-slub-sysfs-interface-files-early-for-emp.patch
 0010-slab-use-memcg_kmem_cache_wq-for-slab-destruction-op.patch

0001 reverts an existing optimization to prepare for the following
changes.  0002 is a prep patch.  0003 makes rcu_barrier() in release
path batched and asynchronous.  0004-0006 separate out the lists.
0007-0008 replace synchronize_sched() in slub destruction path with
call_rcu_sched().  0009 removes sysfs files early for empty dying
caches.  0010 makes destruction work items use a workqueue with
limited concurrency.

This patchset is on top of the current linus#master a121103c9228 and
also available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-kmemcg-scalability

diffstat follows.  Thanks.

 include/linux/memcontrol.h |    2 
 include/linux/slab.h       |   45 +++++--
 include/linux/slub_def.h   |    4 
 mm/memcontrol.c            |   23 +--
 mm/slab.c                  |    7 +
 mm/slab.h                  |   27 +++-
 mm/slab_common.c           |  289 +++++++++++++++++++++++++++++----------------
 mm/slub.c                  |   55 ++++++++
 8 files changed, 325 insertions(+), 127 deletions(-)

--
tejun

[V1] http://lkml.kernel.org/r/<20170114055449.11044-1-tj@kernel.org>
[V2] http://lkml.kernel.org/r/<20170114184834.8658-1-tj@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
