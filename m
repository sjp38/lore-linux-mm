Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F40A86B0036
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 09:27:10 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id rd3so4042895pab.33
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 06:27:10 -0700 (PDT)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id ar5si4574107pbd.272.2013.11.01.06.27.06
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 06:27:07 -0700 (PDT)
Message-ID: <5273AC22.9010109@parallels.com>
Date: Fri, 1 Nov 2013 17:26:58 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [Devel] [PATCH v11 00/15] kmemcg shrinkers
References: <cover.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, glommer@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>

I've run kernbench in a first-level memory cgroup to prove there is no 
performance degradation due to the series, and here are the results.

HW: 2 socket x 6 core x 2 HT (2 NUMA nodes, 24 logical CPUs in total), 
24 GB RAM (12+12)
Test case: time make -j48 vmlinux
Legend:
   base - 3.12.0-rc6
   patched - 3.12.0-rc6 + patchset

1) To compute the overhead of making s_inode_lru and s_dentry_lru lists 
per-memcg, the test was run in a first-level memory cgroup with the 
following parameters:

memory.limit_in_bytes=-1
memory.kmem_limit_in_bytes=2147483648

[the kmem limit is set in order to activate kmem accounting in memcg, 
but since it is high enough to accommodate all kernel objects created 
during the test, the reclaimer is never called]

* base
Elapsed time: 314.7 +- 0.9 sec
User time: 5103.5 +- 11.0 sec
System time: 540.7 +- 1.0 sec
CPU usage: 1793.2 +- 6.1 %

* patched
Elapsed time: 313.6 +- 1.4 sec
User time: 5096.4 +- 10.8 sec
System time: 538.9 +- 1.6 sec
CPU usage: 1796.2 +- 9.4 %

 From the results above, one may conclude there is practically no 
overhead of making the inode and dentry lists per-memcg.

2) To compute the impact of the series on the memory reclaimer, the test 
was run in a first-level cgroup with the following parameters:

memory.limit_in_bytes=2147483648
memory.kmem_limit_in_bytes=2147483648

[48 compilation threads competing for 2GB of RAM create memory pressure 
high enough to trigger memory reclaimer]

* base
Elapsed time: 705.2 +- 104.2 sec
User time: 4489.1 +- 48.2 sec
System time: 494.4 +- 4.9 sec
CPU usage: 724.0 +- 122.3 %

* patched
Elapsed time: 659.6 +- 98.4 sec (-45.6 sec / -6.4 % vs base)
User time: 4506.5 +- 52.7 sec (+17.4 sec / +0.4 % vs base)
System time: 494.7 +- 7.8 sec (+0.3 sec / +0.0 % vs base)
CPU usage: 774.7 +- 115.6 % (+50.7 % / +7.0 % bs base)

It seems that shrinking icache/dcache along with page caches resulted in 
slight improvement in CPU utilization and overall performance (elapsed 
time). This is predictable, because the kernel w/o the patchset applied 
in fact does not shrink icache/dcache at all under memcg pressure 
keeping them in memory during all the test run. In total, this can 
result in up to 300 MB of memory wasted. In contrary, the patched kernel 
tries to reclaim kernel objects along with user pages freeing space for 
the effective working set.

Thus, I guess the overhead introduced by the series is reasonable.

Thanks.

On 10/24/2013 04:04 PM, Vladimir Davydov wrote:
> This patchset implements targeted shrinking for memcg when kmem limits are
> present. So far, we've been accounting kernel objects but failing allocations
> when short of memory. This is because our only option would be to call the
> global shrinker, depleting objects from all caches and breaking isolation.
>
> The main idea is to associate per-memcg lists with each of the LRUs. The main
> LRU still provides a single entry point and when adding or removing an element
> from the LRU, we use the page information to figure out which memcg it belongs
> to and relay it to the right list.
>
> The bulk of the code is written by Glauber Costa. The only change I introduced
> myself in this iteration is reworking per-memcg LRU lists. Instead of extending
> the existing list_lru structure, which seems to be neat as is, I introduced a
> new one, memcg_list_lru, which aggregates list_lru objects for each kmem-active
> memcg and keeps them uptodate as memcgs are created/destroyed. I hope this
> simplified call paths and made the code easier to read.
>
> The patchset is based on top of Linux 3.12-rc6.
>
> Any comments and proposals are appreciated.
>
> == Known issues ==
>
>   * In case kmem limit is less than sum mem limit, reaching memcg kmem limit
>     will result in an attempt to shrink all memcg slabs (see
>     try_to_free_mem_cgroup_kmem()). Although this is better than simply failing
>     allocation as it works now, it is still to be improved.
>
>   * Since FS shrinkers can't be executed on __GFP_FS allocations, such
>     allocations will fail if memcg kmem limit is less than sum mem limit and the
>     memcg kmem usage is close to its limit. Glauber proposed to schedule a
>     worker which would shrink kmem in the background on such allocations.
>     However, this approach does not eliminate failures completely, it just makes
>     them rarer. I'm thinking on implementing soft limits for memcg kmem so that
>     striking the soft limit will trigger the reclaimer, but won't fail the
>     allocation. I would appreciate any other proposals on how this can be fixed.
>
>   * Only dcache and icache are reclaimed on memcg pressure. Other FS objects are
>     left for global pressure only. However, it should not be a serious problem
>     to make them reclaimable too by passing on memcg to the FS-layer and letting
>     each FS decide if its internal objects are shrinkable on memcg pressure.
>
> == Changes from v10 ==
>
>   * Rework per-memcg list_lru infrastructure.
>
> Previous iteration (with full changelog) can be found here:
>
> http://www.spinics.net/lists/linux-fsdevel/msg66632.html
>
> Glauber Costa (12):
>    memcg: make cache index determination more robust
>    memcg: consolidate callers of memcg_cache_id
>    vmscan: also shrink slab in memcg pressure
>    memcg: move initialization to memcg creation
>    memcg: move stop and resume accounting functions
>    memcg: per-memcg kmem shrinking
>    memcg: scan cache objects hierarchically
>    vmscan: take at least one pass with shrinkers
>    memcg: allow kmem limit to be resized down
>    vmpressure: in-kernel notifications
>    memcg: reap dead memcgs upon global memory pressure
>    memcg: flush memcg items upon memcg destruction
>
> Vladimir Davydov (3):
>    memcg,list_lru: add per-memcg LRU list infrastructure
>    memcg,list_lru: add function walking over all lists of a per-memcg
>      LRU
>    super: make icache, dcache shrinkers memcg-aware
>
>   fs/dcache.c                |   25 +-
>   fs/inode.c                 |   16 +-
>   fs/internal.h              |    9 +-
>   fs/super.c                 |   47 +--
>   include/linux/fs.h         |    4 +-
>   include/linux/list_lru.h   |   77 +++++
>   include/linux/memcontrol.h |   23 ++
>   include/linux/shrinker.h   |    6 +-
>   include/linux/swap.h       |    2 +
>   include/linux/vmpressure.h |    5 +
>   mm/memcontrol.c            |  704 +++++++++++++++++++++++++++++++++++++++-----
>   mm/vmpressure.c            |   53 +++-
>   mm/vmscan.c                |  178 +++++++++--
>   13 files changed, 1014 insertions(+), 135 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
