Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 880466B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:05:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b7-v6so3795496pgv.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:05:35 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0121.outbound.protection.outlook.com. [104.47.1.121])
        by mx.google.com with ESMTPS id w4-v6si43413822plp.357.2018.06.07.11.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 11:05:33 -0700 (PDT)
Subject: Re: [PATCH v7 00/17] Improve shrink_slab() scalability (old
 complexity was O(n^2), new is O(n))
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
 <CALvZod5==RV=emZ_gqC1UhGsx7W=YkMtSXJ-Uzc04HQH29zERA@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <8d3d8b28-8b80-2953-45ac-cbaee6147ccd@virtuozzo.com>
Date: Thu, 7 Jun 2018 21:05:16 +0300
MIME-Version: 1.0
In-Reply-To: <CALvZod5==RV=emZ_gqC1UhGsx7W=YkMtSXJ-Uzc04HQH29zERA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>

Hi, Shakeel,

thanks for the testing results.

On 06.06.2018 23:49, Shakeel Butt wrote:
> On Tue, May 22, 2018 at 3:07 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> Hi,
>>
>> this patches solves the problem with slow shrink_slab() occuring
>> on the machines having many shrinkers and memory cgroups (i.e.,
>> with many containers). The problem is complexity of shrink_slab()
>> is O(n^2) and it grows too fast with the growth of containers
>> numbers.
>>
>> Let we have 200 containers, and every container has 10 mounts
>> and 10 cgroups. All container tasks are isolated, and they don't
>> touch foreign containers mounts.
>>
>> In case of global reclaim, a task has to iterate all over the memcgs
>> and to call all the memcg-aware shrinkers for all of them. This means,
>> the task has to visit 200 * 10 = 2000 shrinkers for every memcg,
>> and since there are 2000 memcgs, the total calls of do_shrink_slab()
>> are 2000 * 2000 = 4000000.
>>
>> 4 million calls are not a number operations, which can takes 1 cpu cycle.
>> E.g., super_cache_count() accesses at least two lists, and makes arifmetical
>> calculations. Even, if there are no charged objects, we do these calculations,
>> and replaces cpu caches by read memory. I observed nodes spending almost 100%
>> time in kernel, in case of intensive writing and global reclaim. The writer
>> consumes pages fast, but it's need to shrink_slab() before the reclaimer
>> reached shrink pages function (and frees SWAP_CLUSTER_MAX pages). Even if
>> there is no writing, the iterations just waste the time, and slows reclaim down.
>>
>> Let's see the small test below:
>>
>> $echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
>> $mkdir /sys/fs/cgroup/memory/ct
>> $echo 4000M > /sys/fs/cgroup/memory/ct/memory.kmem.limit_in_bytes
>> $for i in `seq 0 4000`;
>>         do mkdir /sys/fs/cgroup/memory/ct/$i;
>>         echo $$ > /sys/fs/cgroup/memory/ct/$i/cgroup.procs;
>>         mkdir -p s/$i; mount -t tmpfs $i s/$i; touch s/$i/file;
>> done
>>
>> Then, let's see drop caches time (5 sequential calls):
>> $time echo 3 > /proc/sys/vm/drop_caches
>>
>> 0.00user 13.78system 0:13.78elapsed 99%CPU
>> 0.00user 5.59system 0:05.60elapsed 99%CPU
>> 0.00user 5.48system 0:05.48elapsed 99%CPU
>> 0.00user 8.35system 0:08.35elapsed 99%CPU
>> 0.00user 8.34system 0:08.35elapsed 99%CPU
>>
>>
>> Last four calls don't actually shrink something. So, the iterations
>> over slab shrinkers take 5.48 seconds. Not so good for scalability.
>>
>> The patchset solves the problem by making shrink_slab() of O(n)
>> complexity. There are following functional actions:
>>
>> 1)Assign id to every registered memcg-aware shrinker.
>> 2)Maintain per-memcgroup bitmap of memcg-aware shrinkers,
>>   and set a shrinker-related bit after the first element
>>   is added to lru list (also, when removed child memcg
>>   elements are reparanted).
>> 3)Split memcg-aware shrinkers and !memcg-aware shrinkers,
>>   and call a shrinker if its bit is set in memcg's shrinker
>>   bitmap.
>>   (Also, there is a functionality to clear the bit, after
>>   last element is shrinked).
>>
>> This gives signify performance increase. The result after patchset is applied:
>>
>> $time echo 3 > /proc/sys/vm/drop_caches
>>
>> 0.00user 1.10system 0:01.10elapsed 99%CPU
>> 0.00user 0.00system 0:00.01elapsed 64%CPU
>> 0.00user 0.01system 0:00.01elapsed 82%CPU
>> 0.00user 0.00system 0:00.01elapsed 64%CPU
>> 0.00user 0.01system 0:00.01elapsed 82%CPU
>>
>> The results show the performance increases at least in 548 times.
>>
>> So, the patchset makes shrink_slab() of less complexity and improves
>> the performance in such types of load I pointed. This will give a profit
>> in case of !global reclaim case, since there also will be less
>> do_shrink_slab() calls.
>>
>> This patchset is made against linux-next.git tree.
>>
>> v7: Refactorings and readability improvements.
>>
>> v6: Added missed rcu_dereference() to memcg_set_shrinker_bit().
>>     Use different functions for allocation and expanding map.
>>     Use new memcg_shrinker_map_size variable in memcontrol.c.
>>     Refactorings.
>>
>> v5: Make the optimizing logic under CONFIG_MEMCG_SHRINKER instead of MEMCG && !SLOB
>>
>> v4: Do not use memcg mem_cgroup_idr for iteration over mem cgroups
>>
>> v3: Many changes requested in commentaries to v2:
>>
>> 1)rebase on prealloc_shrinker() code base
>> 2)root_mem_cgroup is made out of memcg maps
>> 3)rwsem replaced with shrinkers_nr_max_mutex
>> 4)changes around assignment of shrinker id to list lru
>> 5)everything renamed
>>
>> v2: Many changes requested in commentaries to v1:
>>
>> 1)the code mostly moved to mm/memcontrol.c;
>> 2)using IDR instead of array of shrinkers;
>> 3)added a possibility to assign list_lru shrinker id
>>   at the time of shrinker registering;
>> 4)reorginized locking and renamed functions and variables.
>>
>> ---
>>
>> Kirill Tkhai (16):
>>       list_lru: Combine code under the same define
>>       mm: Introduce CONFIG_MEMCG_KMEM as combination of CONFIG_MEMCG && !CONFIG_SLOB
>>       mm: Assign id to every memcg-aware shrinker
>>       memcg: Move up for_each_mem_cgroup{,_tree} defines
>>       mm: Assign memcg-aware shrinkers bitmap to memcg
>>       mm: Refactoring in workingset_init()
>>       fs: Refactoring in alloc_super()
>>       fs: Propagate shrinker::id to list_lru
>>       list_lru: Add memcg argument to list_lru_from_kmem()
>>       list_lru: Pass dst_memcg argument to memcg_drain_list_lru_node()
>>       list_lru: Pass lru argument to memcg_drain_list_lru_node()
>>       mm: Export mem_cgroup_is_root()
>>       mm: Set bit in memcg shrinker bitmap on first list_lru item apearance
>>       mm: Iterate only over charged shrinkers during memcg shrink_slab()
>>       mm: Add SHRINK_EMPTY shrinker methods return value
>>       mm: Clear shrinker bit if there are no objects related to memcg
>>
>> Vladimir Davydov (1):
>>       mm: Generalize shrink_slab() calls in shrink_node()
>>
>>
>>  fs/super.c                 |   11 ++
>>  include/linux/list_lru.h   |   18 ++--
>>  include/linux/memcontrol.h |   46 +++++++++-
>>  include/linux/sched.h      |    2
>>  include/linux/shrinker.h   |   11 ++
>>  include/linux/slab.h       |    2
>>  init/Kconfig               |    5 +
>>  mm/list_lru.c              |   90 ++++++++++++++-----
>>  mm/memcontrol.c            |  173 +++++++++++++++++++++++++++++++------
>>  mm/slab.h                  |    6 +
>>  mm/slab_common.c           |    8 +-
>>  mm/vmscan.c                |  204 +++++++++++++++++++++++++++++++++++++++-----
>>  mm/workingset.c            |   11 ++
>>  13 files changed, 478 insertions(+), 109 deletions(-)
>>
>> --
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> Hi Kirill,
> 
> I tested this patch series on mmotm tree's
> v4.17-rc6-mmotm-2018-05-25-14-52 tag. I did experiment similar to the
> one I did for your lockless lru_list patch but on an actual machine.
> 
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

The interesting results. In the first case we had iterations over long list
of shrinkers placed somewhere in memory. Since there are many allocated
structures (not only shrinkers) on mount(), the most likely case I think
is the most shrinkers do not share the same cache line. These actions
are so bad, that we don't see the trashing from down_read_trylock(),
since it's a small subset of introduced trashing.

After patches are applied, trashing from down_read_trylock() is the only
trashing and it's visible.

There were: down_read_trylock()/mem_cgroup_iter() = 0.49/0.44 ~ 1.1
It became: 47.49/9.51 ~ 5.0.

This looks like shrinker_rwsem is a good candidate to be placed in separate
__cacheline_aligned place (to prevent its impact on neighbours,
e.g. almost read-only shrinker_idr and shrinker_nr_max). This shouldn't
change perf trace (I assume), but this should be good for real workload.

> Next I did a simple hack by removing shrinker_rwsem lock/unlock from
> shrink_slab_memcg (which is functionally not correct but I made sure
> there aren't any parallel mounts). I got the following result:
> 
> Samples: 5M of event 'cycles', Event count (approx.): 3473394237366
> +  40.13%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_protected
> +  17.66%            fb.sh  [kernel.kallsyms]    [k] shrink_node_memcg
> +  14.78%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_iter
> +   7.07%            fb.sh  [kernel.kallsyms]    [k] lruvec_lru_size
> +   3.19%            fb.sh  [kernel.kallsyms]    [k] shrink_slab_memcg
> +   2.82%            fb.sh  [kernel.kallsyms]    [k] queued_spin_lock_slowpath
> +   1.96%            fb.sh  [kernel.kallsyms]    [k] try_charge
> +   1.81%            fb.sh  [kernel.kallsyms]    [k] shrink_node
> +   0.91%            fb.sh  [kernel.kallsyms]    [k] page_counter_try_charge
> +   0.65%            fb.sh  [kernel.kallsyms]    [k] css_next_descendant_pre
> +   0.62%            fb.sh  [kernel.kallsyms]    [k] cgroup_file_notify
> 
> From the result it seems like, in the workload where one job is
> thrashing and affecting the whole system, this patch series moves the
> load from shrinker list traversal to the shrinker_rwsem lock as there
> isn't much to traverse. Since shrink_slab_memcg only takes read lock
> on shrinker_rwsem, this seems like cache misses/thrashing for rwsem.
> Maybe next direction is to go lockless.

Yeah, this sounds reasonable for me. Maybe we may simply use percpu rwsem
for this (if it also has something like rwsem_is_contended()).

Thanks,
Kirill
