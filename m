Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 130C86B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 14:21:37 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id f194-v6so2636523lfe.10
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 11:21:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4sor2460365ljh.106.2018.04.22.11.21.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 11:21:35 -0700 (PDT)
Date: Sun, 22 Apr 2018 21:21:32 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 12/12] mm: Clear shrinker bit if there are no objects
 related to memcg
Message-ID: <20180422182132.c4tqkyy4ojgi7l7q@esperanza>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399129187.3456.5685999465635300270.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152399129187.3456.5685999465635300270.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, Apr 17, 2018 at 09:54:51PM +0300, Kirill Tkhai wrote:
> To avoid further unneed calls of do_shrink_slab()
> for shrinkers, which already do not have any charged
> objects in a memcg, their bits have to be cleared.
> 
> This patch introduces a lockless mechanism to do that
> without races without parallel list lru add. After
> do_shrink_slab() returns SHRINK_EMPTY the first time,
> we clear the bit and call it once again. Then we restore
> the bit, if the new return value is different.
> 
> Note, that single smp_mb__after_atomic() in shrink_slab_memcg()
> covers two situations:
> 
> 1)list_lru_add()     shrink_slab_memcg
>     list_add_tail()    for_each_set_bit() <--- read bit
>                          do_shrink_slab() <--- missed list update (no barrier)
>     <MB>                 <MB>
>     set_bit()            do_shrink_slab() <--- seen list update
> 
> This situation, when the first do_shrink_slab() sees set bit,
> but it doesn't see list update (i.e., race with the first element
> queueing), is rare. So we don't add <MB> before the first call
> of do_shrink_slab() instead of this to do not slow down generic
> case. Also, it's need the second call as seen in below in (2).
> 
> 2)list_lru_add()      shrink_slab_memcg()
>     list_add_tail()     ...
>     set_bit()           ...
>   ...                   for_each_set_bit()
>   do_shrink_slab()        do_shrink_slab()
>     clear_bit()           ...
>   ...                     ...
>   list_lru_add()          ...
>     list_add_tail()       clear_bit()
>     <MB>                  <MB>
>     set_bit()             do_shrink_slab()
> 
> The barriers guarantees, the second do_shrink_slab()
> in the right side task sees list update if really
> cleared the bit. This case is drawn in the code comment.
> 
> [Results/performance of the patchset]
> 
> After the whole patchset applied the below test shows signify
> increase of performance:
> 
> $echo 1 > /sys/fs/cgroup/memory/memory.use_hierarchy
> $mkdir /sys/fs/cgroup/memory/ct
> $echo 4000M > /sys/fs/cgroup/memory/ct/memory.kmem.limit_in_bytes
>     $for i in `seq 0 4000`; do mkdir /sys/fs/cgroup/memory/ct/$i; echo $$ > /sys/fs/cgroup/memory/ct/$i/cgroup.procs; mkdir -p s/$i; mount -t tmpfs $i s/$i; touch s/$i/file; done
> 
> Then, 4 sequential calls of drop caches:
> $time echo 3 > /proc/sys/vm/drop_caches
> 
> 1)Before:
> 0.00user 8.99system 0:08.99elapsed 99%CPU
> 0.00user 5.97system 0:05.97elapsed 100%CPU
> 0.00user 5.97system 0:05.97elapsed 100%CPU
> 0.00user 5.85system 0:05.85elapsed 100%CPU
> 
> 2)After
> 0.00user 1.11system 0:01.12elapsed 99%CPU
> 0.00user 0.00system 0:00.00elapsed 100%CPU
> 0.00user 0.00system 0:00.00elapsed 100%CPU
> 0.00user 0.00system 0:00.00elapsed 100%CPU
> 
> Even if we round 0:00.00 up to 0:00.01, the results shows
> the performance increases at least in 585 times.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |    2 ++
>  mm/vmscan.c                |   19 +++++++++++++++++--
>  2 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index e1c1fa8e417a..1c5c68550e2f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1245,6 +1245,8 @@ static inline void set_shrinker_bit(struct mem_cgroup *memcg, int nid, int nr)
>  
>  		rcu_read_lock();
>  		map = SHRINKERS_MAP(memcg, nid);
> +		/* Pairs with smp mb in shrink_slab() */
> +		smp_mb__before_atomic();
>  		set_bit(nr, map->map);
>  		rcu_read_unlock();
>  	}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3be9b4d81c13..a8733bc5377b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -579,8 +579,23 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>  		}
>  
>  		ret = do_shrink_slab(&sc, shrinker, priority);
> -		if (ret == SHRINK_EMPTY)
> -			ret = 0;
> +		if (ret == SHRINK_EMPTY) {
> +			clear_bit(i, map->map);
> +			/*
> +			 * Pairs with mb in set_shrinker_bit():
> +			 *
> +			 * list_lru_add()     shrink_slab_memcg()
> +			 *   list_add_tail()    clear_bit()
> +			 *   <MB>               <MB>
> +			 *   set_bit()          do_shrink_slab()
> +			 */
> +			smp_mb__after_atomic();
> +			ret = do_shrink_slab(&sc, shrinker, priority);
> +			if (ret == SHRINK_EMPTY)
> +				ret = 0;
> +			else
> +				set_shrinker_bit(memcg, nid, i);
> +		}

This is mind-boggling. Are there any alternatives? For instance, can't
we clear the bit in list_lru_del, when we hold the list lock?

>  		freed += ret;
>  
>  		if (rwsem_is_contended(&shrinker_rwsem)) {
> 
