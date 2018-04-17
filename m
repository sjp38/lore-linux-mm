Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0745A6B000A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:53:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a21so3119111pfo.8
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:53:11 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10118.outbound.protection.outlook.com. [40.107.1.118])
        by mx.google.com with ESMTPS id b6-v6si14608274plm.202.2018.04.17.08.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:53:10 -0700 (PDT)
Subject: [PATCH v2 00/12] Improve shrink_slab() scalability (old complexity
 was O(n^2), new is O(n))
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:52:53 +0300
Message-ID: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Hi,

this patches solves the problem with slow shrink_slab() occuring
on the machines having many shrinkers and memory cgroups (i.e.,
with many containers). The problem is complexity of shrink_slab()
is O(n^2) and it grows too fast with the growth of containers
numbers.

Let we have 200 containers, and every container has 10 mounts
and 10 cgroups. All container tasks are isolated, and they don't
touch foreign containers mounts.

In case of global reclaim, a task has to iterate all over the memcgs
and to call all the memcg-aware shrinkers for all of them. This means,
the task has to visit 200 * 10 = 2000 shrinkers for every memcg,
and since there are 2000 memcgs, the total calls of do_shrink_slab()
are 2000 * 2000 = 4000000.

4 million calls are not a number operations, which can takes 1 cpu cycle.
E.g., super_cache_count() accesses at least two lists, and makes arifmetical
calculations. Even, if there are no charged objects, we do these calculations,
and replaces cpu caches by read memory. I observed nodes spending almost 100%
time in kernel, in case of intensive writing and global reclaim. The writer
consumes pages fast, but it's need to shrink_slab() before the reclaimer
reached shrink pages function (and frees SWAP_CLUSTER_MAX pages). Even if
there is no writing, the iterations just waste the time, and slows reclaim down.

Let's see the small test below:

$echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
$mkdir /sys/fs/cgroup/memory/ct
$echo 4000M > /sys/fs/cgroup/memory/ct/memory.kmem.limit_in_bytes
$for i in `seq 0 4000`;
	do mkdir /sys/fs/cgroup/memory/ct/$i;
	echo $$ > /sys/fs/cgroup/memory/ct/$i/cgroup.procs;
	mkdir -p s/$i; mount -t tmpfs $i s/$i; touch s/$i/file;
done

Then, let's see drop caches time (4 sequential calls):
$time echo 3 > /proc/sys/vm/drop_caches

0.00user 8.99system 0:08.99elapsed 99%CPU
0.00user 5.97system 0:05.97elapsed 100%CPU
0.00user 5.97system 0:05.97elapsed 100%CPU
0.00user 5.85system 0:05.85elapsed 100%CPU

Last three calls don't actually shrink something. So, the iterations
over slab shrinkers take 5.85 seconds. Not so good for scalability.

The patchset solves the problem by making shrink_slab() of O(n)
complexity. There are following functional actions:

1)Assign id to every registered memcg-aware shrinker.
2)Maintain per-memcgroup bitmap of memcg-aware shrinkers,
  and set a shrinker-related bit after the first element
  is added to lru list (also, when removed child memcg
  elements are reparanted).
3)Split memcg-aware shrinkers and !memcg-aware shrinkers,
  and call a shrinker if its bit is set in memcg's shrinker
  bitmap.
  (Also, there is a functionality to clear the bit, after
  last element is shrinked).

This gives signify performance increase. The result after patchset is applied:

$time echo 3 > /proc/sys/vm/drop_caches
0.00user 1.11system 0:01.12elapsed 99%CPU
0.00user 0.00system 0:00.00elapsed 100%CPU
0.00user 0.00system 0:00.00elapsed 100%CPU
0.00user 0.00system 0:00.00elapsed 100%CPU

Even if we round 0:00.00 up to 0:00.01, the results shows
the performance increases at least in 585 times.

So, the patchset makes shrink_slab() of less complexity and improves
the performance in such types of load I pointed. This will give a profit
in case of !global reclaim case, since there also will be less
do_shrink_slab() calls.

This patchset is made against linux-next.git tree.

v2: Many changes requested in commentaries to v1:

1)the code mostly moved to mm/memcontrol.c;
2)using IDR instead of array of shrinkers;
3)added a possibility to assign list_lru shrinker id
  at the time of shrinker registering;
4)reorginized locking and renamed functions and variables.
---

Kirill Tkhai (12):
      mm: Assign id to every memcg-aware shrinker
      memcg: Refactoring in mem_cgroup_alloc()
      memcg: Refactoring in alloc_mem_cgroup_per_node_info()
      mm: Assign memcg-aware shrinkers bitmap to memcg
      fs: Propagate shrinker::id to list_lru
      list_lru: Add memcg argument to list_lru_from_kmem()
      list_lru: Pass dst_memcg argument to memcg_drain_list_lru_node()
      list_lru: Pass lru argument to memcg_drain_list_lru_node()
      mm: Set bit in memcg shrinker bitmap on first list_lru item apearance
      mm: Iterate only over charged shrinkers during memcg shrink_slab()
      mm: Add SHRINK_EMPTY shrinker methods return value
      mm: Clear shrinker bit if there are no objects related to memcg


 fs/super.c                 |    7 +-
 include/linux/list_lru.h   |    3 -
 include/linux/memcontrol.h |   30 +++++++
 include/linux/shrinker.h   |   17 +++-
 mm/list_lru.c              |   64 +++++++++++----
 mm/memcontrol.c            |  160 ++++++++++++++++++++++++++++++++----
 mm/vmscan.c                |  194 +++++++++++++++++++++++++++++++++++++++-----
 mm/workingset.c            |    6 +
 8 files changed, 422 insertions(+), 59 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
