Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87A756B0033
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:23:47 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bb5-v6so3073082plb.22
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:23:47 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0119.outbound.protection.outlook.com. [104.47.0.119])
        by mx.google.com with ESMTPS id m39-v6si3947582plg.447.2018.03.21.06.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:23:46 -0700 (PDT)
Subject: Re: [PATCH 00/10] Improve shrink_slab() scalability (old complexity
 was O(n^2), new is O(n))
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <9e15217f-5739-3d6a-679c-740571091429@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:23:36 +0300
MIME-Version: 1.0
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

This is actually RFC, so comments are welcome!

On 21.03.2018 16:21, Kirill Tkhai wrote:
> Imagine a big node with many cpus, memory cgroups and containers.
> Let we have 200 containers, and every container has 10 mounts
> and 10 cgroups. All container tasks don't touch foreign containers
> mounts.
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
> time in kernel, in case of intensive writing and global reclaim. Even if
> there is no writing, the iterations just waste the time, and slows reclaim down.
> 
> Let's see the small test below:
>     $echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
>     $mkdir /sys/fs/cgroup/memory/ct
>     $echo 4000M > /sys/fs/cgroup/memory/ct/memory.kmem.limit_in_bytes
>     $for i in `seq 0 4000`; do mkdir /sys/fs/cgroup/memory/ct/$i; echo $$ > /sys/fs/cgroup/memory/ct/$i/cgroup.procs; mkdir -p s/$i; mount -t tmpfs $i s/$i; touch s/$i/file; done
> 
> Then, let's see drop caches time (4 sequential calls):
>     $time echo 3 > /proc/sys/vm/drop_caches
>     0.00user 6.80system 0:06.82elapsed 99%CPU 
>     0.00user 4.61system 0:04.62elapsed 99%CPU
>     0.00user 4.61system 0:04.61elapsed 99%CPU
>     0.00user 4.61system 0:04.61elapsed 99%CPU
> 
> Last three calls don't actually shrink something. So, the iterations
> over slab shrinkers take 4.61 seconds. Not so good for scalability.
> 
> The patchset solves the problem with following actions:
> 1)Assign id to every registered memcg-aware shrinker.
> 2)Maintain per-memcgroup bitmap of memcg-aware shrinkers,
>   and set a shrinker-related bit after the first element
>   is added to lru list (also, when removed child memcg
>   elements are reparanted).
> 3)Split memcg-aware shrinkers and !memcg-aware shrinkers,
>   and call a shrinker if its bit is set in memcg's shrinker
>   bitmap
> (Also, there is a functionality to clear the bit, after
>  last element is shrinked).
> 
> This gives signify performance increase. The result after patchset is applied:
> 
>     $time echo 3 > /proc/sys/vm/drop_caches
>     0.00user 0.93system 0:00.94elapsed 99%CPU
>     0.00user 0.00system 0:00.01elapsed 80%CPU
>     0.00user 0.00system 0:00.01elapsed 80%CPU
>     0.00user 0.00system 0:00.01elapsed 81%CPU
>     (4.61s/0.01s = 461 times faster)
> 
> Currenly, all memcg-aware shrinkers are implemented via list_lru.
> The only exception is XFS cached objects backlog (which is completelly
> no memcg-aware, but pretends to be memcg-aware). See
> xfs_fs_nr_cached_objects() and xfs_fs_free_cached_objects() for
> the details. It seems, this can be reworked to fix this lack.
> 
> So, the patchset makes shrink_slab() of less complexity and improves
> the performance in such types of load I pointed. This will give a profit
> in case of !global reclaim case, since there also will be less do_shrink_slab()
> calls.
> 
> This patchset is made against linux-next.git tree.
> 
> ---
> 
> Kirill Tkhai (10):
>       mm: Assign id to every memcg-aware shrinker
>       mm: Maintain memcg-aware shrinkers in mcg_shrinkers array
>       mm: Assign memcg-aware shrinkers bitmap to memcg
>       fs: Propagate shrinker::id to list_lru
>       list_lru: Add memcg argument to list_lru_from_kmem()
>       list_lru: Pass dst_memcg argument to memcg_drain_list_lru_node()
>       list_lru: Pass lru argument to memcg_drain_list_lru_node()
>       mm: Set bit in memcg shrinker bitmap on first list_lru item apearance
>       mm: Iterate only over charged shrinkers during memcg shrink_slab()
>       mm: Clear shrinker bit if there are no objects related to memcg
> 
> 
>  fs/super.c                 |    8 +
>  include/linux/list_lru.h   |    3 
>  include/linux/memcontrol.h |   20 +++
>  include/linux/shrinker.h   |    9 +
>  mm/list_lru.c              |   65 ++++++--
>  mm/memcontrol.c            |    7 +
>  mm/vmscan.c                |  337 ++++++++++++++++++++++++++++++++++++++++++--
>  mm/workingset.c            |    6 +
>  8 files changed, 418 insertions(+), 37 deletions(-)
> 
> --
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
