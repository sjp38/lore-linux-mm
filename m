Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2056B0008
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:37:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c2-v6so5531392edi.20
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:37:37 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00132.outbound.protection.outlook.com. [40.107.0.132])
        by mx.google.com with ESMTPS id o5-v6si1491845edd.67.2018.08.07.08.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:37:35 -0700 (PDT)
Subject: [PATCH RFC 00/10] Introduce lockless shrink_slab()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:37:19 +0300
Message-ID: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

After bitmaps of not-empty memcg shrinkers were implemented
(see "[PATCH v9 00/17] Improve shrink_slab() scalability..."
series, which is already in mm tree), all the evil in perf
trace has moved from shrink_slab() to down_read_trylock().
As reported by Shakeel Butt:

     > I created 255 memcgs, 255 ext4 mounts and made each memcg create a
     > file containing few KiBs on corresponding mount. Then in a separate
     > memcg of 200 MiB limit ran a fork-bomb.
     >
     > I ran the "perf record -ag -- sleep 60" and below are the results:
     > +  47.49%            fb.sh  [kernel.kallsyms]    [k] down_read_trylock
     > +  30.72%            fb.sh  [kernel.kallsyms]    [k] up_read
     > +   9.51%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_iter
     > +   1.69%            fb.sh  [kernel.kallsyms]    [k] shrink_node_memcg
     > +   1.35%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_protected
     > +   1.05%            fb.sh  [kernel.kallsyms]    [k] queued_spin_lock_slowpath
     > +   0.85%            fb.sh  [kernel.kallsyms]    [k] _raw_spin_lock
     > +   0.78%            fb.sh  [kernel.kallsyms]    [k] lruvec_lru_size
     > +   0.57%            fb.sh  [kernel.kallsyms]    [k] shrink_node
     > +   0.54%            fb.sh  [kernel.kallsyms]    [k] queue_work_on
     > +   0.46%            fb.sh  [kernel.kallsyms]    [k] shrink_slab_memcg

The patchset continues to improve shrink_slab() scalability and makes
it lockless completely. Here are several steps for that:

1)Use SRCU to synchronize shrink_slab() and unregister_shrinker().
  Nothing exiting is here, just srcu_read_lock() in shrink_slab()
  and shrink_slab_memcg() and synchronize_srcu() in unregister_shrinker().
  See [2/10] for details.
2)The above requires to make SRCU unconditional enabled.
  [1/10] makes this. Note, that if we can't always enable
  SRCU, we may use percpu_rw_semaphore instead of this.
  See comment to [2/10] for details.
3)Convert shrinker_rwsem to mutex. Just cleanup.

4)Further patches make possible to speed up unregister_shrinker()
  by splitting it in two stages. The first stage unlinks shrinker
  from shrinker_list and shrinker_idr, while the second finalizes
  the thing by calling synchronize_srcu() and freeing memory.
  Patch [4/10] actually splits unregister_shrinker(), while
  [10/10] makes superblock shrinker to use the new helpers
  (unregister_shrinker_delayed_{initiate,finalize}().

5)Patches [5-9/10] are preparations on fs, which make possible
  to split superblock unregistration in two stages. They sequentially
  make super_cache_count() and super_cache_scan() safe to be called
  on unregistering shrinker:

  [cpu0]                                           [cpu1]
  unregister_shrinker_delayed_initiate(shrinker)
  ...                                              shrink_slab(shrinker) (OK!)
  unregister_shrinker_delayed_finalize(shrinker)

After all of this, shrink_slab() becomes lockless, while unregister_shrinker()
remains fast at least for superblock shrinker (another shrinkers also
can be made to unregister in the same delayed manner).

(This requires "mm: Use special value SHRINKER_REGISTERING instead list_empty() check"
 from https://lkml.org/lkml/2018/8/6/276, which is on the way to -mm tree, as said
 by -mm tree notification message from Andrew).

---

Kirill Tkhai (10):
      rcu: Make CONFIG_SRCU unconditionally enabled
      mm: Make shrink_slab() lockless
      mm: Convert shrinker_rwsem to mutex
      mm: Split unregister_shrinker()
      fs: Move list_lru_destroy() to destroy_super_work()
      fs: Shrink only (SB_ACTIVE|SB_BORN) superblocks in super_cache_scan()
      fs: Introduce struct super_operations::destroy_super() callback.
      xfs: Introduce xfs_fs_destroy_super()
      shmem: Implement shmem_destroy_super()
      fs: Use unregister_shrinker_delayed_{initiate,finalize} for super_block shrinker


 drivers/base/core.c                                |   42 ----------
 fs/super.c                                         |   32 ++++----
 fs/xfs/xfs_super.c                                 |   14 +++
 include/linux/device.h                             |    2 
 include/linux/fs.h                                 |    6 +
 include/linux/rcutiny.h                            |    4 -
 include/linux/shrinker.h                           |    2 
 include/linux/srcu.h                               |    5 -
 kernel/notifier.c                                  |    3 -
 kernel/rcu/Kconfig                                 |   12 ---
 kernel/rcu/tree.h                                  |    5 -
 kernel/rcu/update.c                                |    4 -
 mm/shmem.c                                         |    8 ++
 mm/vmscan.c                                        |   82 ++++++++++----------
 .../selftests/rcutorture/doc/TREE_RCU-kconfig.txt  |    5 -
 15 files changed, 89 insertions(+), 137 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
