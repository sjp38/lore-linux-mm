Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14E686B0010
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 08:45:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g15-v6so2789095pfh.10
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 05:45:28 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50096.outbound.protection.outlook.com. [40.107.5.96])
        by mx.google.com with ESMTPS id g12-v6si378230pgu.515.2018.06.04.05.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 05:45:26 -0700 (PDT)
Subject: Re: [PATCH v7 00/17] Improve shrink_slab() scalability (old
 complexity was O(n^2), new is O(n))
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <0e725889-c42f-0557-ef41-76e4c87a3c9b@virtuozzo.com>
Date: Mon, 4 Jun 2018 15:45:17 +0300
MIME-Version: 1.0
In-Reply-To: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Hi, Andrew!

This patchset is reviewed by Vladimir Davydov. I see, there is
minor change in current linux-next.git, which makes the second
patch to apply not completely clean.

Could you tell what should I do with this? Is this OK or should
I rebase it on top of linux.next or do something else?

Thanks,
Kirill

On 22.05.2018 13:07, Kirill Tkhai wrote:
> Hi,
> 
> this patches solves the problem with slow shrink_slab() occuring
> on the machines having many shrinkers and memory cgroups (i.e.,
> with many containers). The problem is complexity of shrink_slab()
> is O(n^2) and it grows too fast with the growth of containers
> numbers.
> 
> Let we have 200 containers, and every container has 10 mounts
> and 10 cgroups. All container tasks are isolated, and they don't
> touch foreign containers mounts.
> 
> In case of global reclaim, a task has to iterate all over the memcgs
> and to call all the memcg-aware shrinkers for all of them. This means,
> the task has to visit 200 * 10 = 2000 shrinkers for every memcg,
> and since there are 2000 memcgs, the total calls of do_shrink_slab()
> are 2000 * 2000 = 4000000.
> 
> 4 million calls are not a number operations, which can takes 1 cpu cycle.
> E.g., super_cache_count() accesses at least two lists, and makes arifmetical
> calculations. Even, if there are no charged objects, we do these calculations,
> and replaces cpu caches by read memory. I observed nodes spending almost 100%
> time in kernel, in case of intensive writing and global reclaim. The writer
> consumes pages fast, but it's need to shrink_slab() before the reclaimer
> reached shrink pages function (and frees SWAP_CLUSTER_MAX pages). Even if
> there is no writing, the iterations just waste the time, and slows reclaim down.
> 
> Let's see the small test below:
> 
> $echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
> $mkdir /sys/fs/cgroup/memory/ct
> $echo 4000M > /sys/fs/cgroup/memory/ct/memory.kmem.limit_in_bytes
> $for i in `seq 0 4000`;
> 	do mkdir /sys/fs/cgroup/memory/ct/$i;
> 	echo $$ > /sys/fs/cgroup/memory/ct/$i/cgroup.procs;
> 	mkdir -p s/$i; mount -t tmpfs $i s/$i; touch s/$i/file;
> done
> 
> Then, let's see drop caches time (5 sequential calls):
> $time echo 3 > /proc/sys/vm/drop_caches
> 
> 0.00user 13.78system 0:13.78elapsed 99%CPU
> 0.00user 5.59system 0:05.60elapsed 99%CPU
> 0.00user 5.48system 0:05.48elapsed 99%CPU
> 0.00user 8.35system 0:08.35elapsed 99%CPU
> 0.00user 8.34system 0:08.35elapsed 99%CPU
> 
> 
> Last four calls don't actually shrink something. So, the iterations
> over slab shrinkers take 5.48 seconds. Not so good for scalability.
> 
> The patchset solves the problem by making shrink_slab() of O(n)
> complexity. There are following functional actions:
> 
> 1)Assign id to every registered memcg-aware shrinker.
> 2)Maintain per-memcgroup bitmap of memcg-aware shrinkers,
>   and set a shrinker-related bit after the first element
>   is added to lru list (also, when removed child memcg
>   elements are reparanted).
> 3)Split memcg-aware shrinkers and !memcg-aware shrinkers,
>   and call a shrinker if its bit is set in memcg's shrinker
>   bitmap.
>   (Also, there is a functionality to clear the bit, after
>   last element is shrinked).
> 
> This gives signify performance increase. The result after patchset is applied:
> 
> $time echo 3 > /proc/sys/vm/drop_caches
> 
> 0.00user 1.10system 0:01.10elapsed 99%CPU
> 0.00user 0.00system 0:00.01elapsed 64%CPU
> 0.00user 0.01system 0:00.01elapsed 82%CPU
> 0.00user 0.00system 0:00.01elapsed 64%CPU
> 0.00user 0.01system 0:00.01elapsed 82%CPU
> 
> The results show the performance increases at least in 548 times.
> 
> So, the patchset makes shrink_slab() of less complexity and improves
> the performance in such types of load I pointed. This will give a profit
> in case of !global reclaim case, since there also will be less
> do_shrink_slab() calls.
> 
> This patchset is made against linux-next.git tree.
> 
> v7: Refactorings and readability improvements.
> 
> v6: Added missed rcu_dereference() to memcg_set_shrinker_bit().
>     Use different functions for allocation and expanding map.
>     Use new memcg_shrinker_map_size variable in memcontrol.c.
>     Refactorings.
> 
> v5: Make the optimizing logic under CONFIG_MEMCG_SHRINKER instead of MEMCG && !SLOB
> 
> v4: Do not use memcg mem_cgroup_idr for iteration over mem cgroups
> 
> v3: Many changes requested in commentaries to v2:
> 
> 1)rebase on prealloc_shrinker() code base
> 2)root_mem_cgroup is made out of memcg maps
> 3)rwsem replaced with shrinkers_nr_max_mutex
> 4)changes around assignment of shrinker id to list lru
> 5)everything renamed
> 
> v2: Many changes requested in commentaries to v1:
> 
> 1)the code mostly moved to mm/memcontrol.c;
> 2)using IDR instead of array of shrinkers;
> 3)added a possibility to assign list_lru shrinker id
>   at the time of shrinker registering;
> 4)reorginized locking and renamed functions and variables.
> 
> ---
> 
> Kirill Tkhai (16):
>       list_lru: Combine code under the same define
>       mm: Introduce CONFIG_MEMCG_KMEM as combination of CONFIG_MEMCG && !CONFIG_SLOB
>       mm: Assign id to every memcg-aware shrinker
>       memcg: Move up for_each_mem_cgroup{,_tree} defines
>       mm: Assign memcg-aware shrinkers bitmap to memcg
>       mm: Refactoring in workingset_init()
>       fs: Refactoring in alloc_super()
>       fs: Propagate shrinker::id to list_lru
>       list_lru: Add memcg argument to list_lru_from_kmem()
>       list_lru: Pass dst_memcg argument to memcg_drain_list_lru_node()
>       list_lru: Pass lru argument to memcg_drain_list_lru_node()
>       mm: Export mem_cgroup_is_root()
>       mm: Set bit in memcg shrinker bitmap on first list_lru item apearance
>       mm: Iterate only over charged shrinkers during memcg shrink_slab()
>       mm: Add SHRINK_EMPTY shrinker methods return value
>       mm: Clear shrinker bit if there are no objects related to memcg
> 
> Vladimir Davydov (1):
>       mm: Generalize shrink_slab() calls in shrink_node()
> 
> 
>  fs/super.c                 |   11 ++
>  include/linux/list_lru.h   |   18 ++--
>  include/linux/memcontrol.h |   46 +++++++++-
>  include/linux/sched.h      |    2 
>  include/linux/shrinker.h   |   11 ++
>  include/linux/slab.h       |    2 
>  init/Kconfig               |    5 +
>  mm/list_lru.c              |   90 ++++++++++++++-----
>  mm/memcontrol.c            |  173 +++++++++++++++++++++++++++++++------
>  mm/slab.h                  |    6 +
>  mm/slab_common.c           |    8 +-
>  mm/vmscan.c                |  204 +++++++++++++++++++++++++++++++++++++++-----
>  mm/workingset.c            |   11 ++
>  13 files changed, 478 insertions(+), 109 deletions(-)
> 
> --
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
