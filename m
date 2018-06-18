Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65E9F6B0010
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 05:47:50 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d1-v6so5041349pga.15
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 02:47:50 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0138.outbound.protection.outlook.com. [104.47.2.138])
        by mx.google.com with ESMTPS id e189-v6si9557683pfe.80.2018.06.18.02.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jun 2018 02:47:48 -0700 (PDT)
Subject: [PATCH v7 REBASED 17/17] mm: Clear shrinker bit if there are no
 objects related to memcg
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 18 Jun 2018 12:47:40 +0300
Message-ID: <152931526012.28457.1427959514045414573.stgit@localhost.localdomain>
In-Reply-To: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
References: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

To avoid further unneed calls of do_shrink_slab()
for shrinkers, which already do not have any charged
objects in a memcg, their bits have to be cleared.

This patch introduces a lockless mechanism to do that
without races without parallel list lru add. After
do_shrink_slab() returns SHRINK_EMPTY the first time,
we clear the bit and call it once again. Then we restore
the bit, if the new return value is different.

Note, that single smp_mb__after_atomic() in shrink_slab_memcg()
covers two situations:

1)list_lru_add()     shrink_slab_memcg
    list_add_tail()    for_each_set_bit() <--- read bit
                         do_shrink_slab() <--- missed list update (no barrier)
    <MB>                 <MB>
    set_bit()            do_shrink_slab() <--- seen list update

This situation, when the first do_shrink_slab() sees set bit,
but it doesn't see list update (i.e., race with the first element
queueing), is rare. So we don't add <MB> before the first call
of do_shrink_slab() instead of this to do not slow down generic
case. Also, it's need the second call as seen in below in (2).

2)list_lru_add()      shrink_slab_memcg()
    list_add_tail()     ...
    set_bit()           ...
  ...                   for_each_set_bit()
  do_shrink_slab()        do_shrink_slab()
    clear_bit()           ...
  ...                     ...
  list_lru_add()          ...
    list_add_tail()       clear_bit()
    <MB>                  <MB>
    set_bit()             do_shrink_slab()

The barriers guarantees, the second do_shrink_slab()
in the right side task sees list update if really
cleared the bit. This case is drawn in the code comment.

[Results/performance of the patchset]

After the whole patchset applied the below test shows signify
increase of performance:

$echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
$mkdir /sys/fs/cgroup/memory/ct
$echo 4000M > /sys/fs/cgroup/memory/ct/memory.kmem.limit_in_bytes
    $for i in `seq 0 4000`; do mkdir /sys/fs/cgroup/memory/ct/$i;
			    echo $$ > /sys/fs/cgroup/memory/ct/$i/cgroup.procs;
			    mkdir -p s/$i; mount -t tmpfs $i s/$i;
			    touch s/$i/file; done

Then, 5 sequential calls of drop caches:
$time echo 3 > /proc/sys/vm/drop_caches

1)Before:
0.00user 13.78system 0:13.78elapsed 99%CPU
0.00user 5.59system 0:05.60elapsed 99%CPU
0.00user 5.48system 0:05.48elapsed 99%CPU
0.00user 8.35system 0:08.35elapsed 99%CPU
0.00user 8.34system 0:08.35elapsed 99%CPU

2)After
0.00user 1.10system 0:01.10elapsed 99%CPU
0.00user 0.00system 0:00.01elapsed 64%CPU
0.00user 0.01system 0:00.01elapsed 82%CPU
0.00user 0.00system 0:00.01elapsed 64%CPU
0.00user 0.01system 0:00.01elapsed 82%CPU

The results show the performance increases at least in 548 times.

Shakeel Butt tested this patchset with fork-bomb on his configuration:

 > I created 255 memcgs, 255 ext4 mounts and made each memcg create a
 > file containing few KiBs on corresponding mount. Then in a separate
 > memcg of 200 MiB limit ran a fork-bomb.
 >
 > I ran the "perf record -ag -- sleep 60" and below are the results:
 >
 > Without the patch series:
 > Samples: 4M of event 'cycles', Event count (approx.): 3279403076005
 > +  36.40%            fb.sh  [kernel.kallsyms]    [k] shrink_slab
 > +  18.97%            fb.sh  [kernel.kallsyms]    [k] list_lru_count_one
 > +   6.75%            fb.sh  [kernel.kallsyms]    [k] super_cache_count
 > +   0.49%            fb.sh  [kernel.kallsyms]    [k] down_read_trylock
 > +   0.44%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_iter
 > +   0.27%            fb.sh  [kernel.kallsyms]    [k] up_read
 > +   0.21%            fb.sh  [kernel.kallsyms]    [k] osq_lock
 > +   0.13%            fb.sh  [kernel.kallsyms]    [k] shmem_unused_huge_count
 > +   0.08%            fb.sh  [kernel.kallsyms]    [k] shrink_node_memcg
 > +   0.08%            fb.sh  [kernel.kallsyms]    [k] shrink_node
 >
 > With the patch series:
 > Samples: 4M of event 'cycles', Event count (approx.): 2756866824946
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

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/memcontrol.h |    2 ++
 mm/vmscan.c                |   25 +++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f2292ea7892d..d41c9350e6be 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1257,6 +1257,8 @@ static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
 
 		rcu_read_lock();
 		map = rcu_dereference(memcg->nodeinfo[nid]->shrinker_map);
+		/* Pairs with smp mb in shrink_slab() */
+		smp_mb__before_atomic();
 		set_bit(shrinker_id, map->map);
 		rcu_read_unlock();
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d24a3e16ade2..ef5f53411a57 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -597,8 +597,29 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 			continue;
 
 		ret = do_shrink_slab(&sc, shrinker, priority);
-		if (ret == SHRINK_EMPTY)
-			ret = 0;
+		if (ret == SHRINK_EMPTY) {
+			clear_bit(i, map->map);
+			/*
+			 * After the shrinker reported that it had no objects to free,
+			 * but before we cleared the corresponding bit in the memcg
+			 * shrinker map, a new object might have been added. To make
+			 * sure, we have the bit set in this case, we invoke the
+			 * shrinker one more time and re-set the bit if it reports that
+			 * it is not empty anymore. The memory barrier here pairs with
+			 * the barrier in memcg_set_shrinker_bit():
+			 *
+			 * list_lru_add()     shrink_slab_memcg()
+			 *   list_add_tail()    clear_bit()
+			 *   <MB>               <MB>
+			 *   set_bit()          do_shrink_slab()
+			 */
+			smp_mb__after_atomic();
+			ret = do_shrink_slab(&sc, shrinker, priority);
+			if (ret == SHRINK_EMPTY)
+				ret = 0;
+			else
+				memcg_set_shrinker_bit(memcg, nid, i);
+		}
 		freed += ret;
 
 		if (rwsem_is_contended(&shrinker_rwsem)) {
