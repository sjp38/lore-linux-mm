Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7156B0006
	for <linux-mm@kvack.org>; Tue, 15 May 2018 01:59:18 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h129-v6so4961763lfg.14
        for <linux-mm@kvack.org>; Mon, 14 May 2018 22:59:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d81-v6sor259703lfd.6.2018.05.14.22.59.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 22:59:16 -0700 (PDT)
Date: Tue, 15 May 2018 08:59:13 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v5 13/13] mm: Clear shrinker bit if there are no objects
 related to memcg
Message-ID: <20180515055913.alk3pau43e3jps3y@esperanza>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594605549.22949.16491037134168999424.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152594605549.22949.16491037134168999424.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Thu, May 10, 2018 at 12:54:15PM +0300, Kirill Tkhai wrote:
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
> Then, 5 sequential calls of drop caches:
> $time echo 3 > /proc/sys/vm/drop_caches
> 
> 1)Before:
> 0.00user 13.78system 0:13.78elapsed 99%CPU
> 0.00user 5.59system 0:05.60elapsed 99%CPU
> 0.00user 5.48system 0:05.48elapsed 99%CPU
> 0.00user 8.35system 0:08.35elapsed 99%CPU
> 0.00user 8.34system 0:08.35elapsed 99%CPU
> 
> 2)After
> 0.00user 1.10system 0:01.10elapsed 99%CPU
> 0.00user 0.00system 0:00.01elapsed 64%CPU
> 0.00user 0.01system 0:00.01elapsed 82%CPU
> 0.00user 0.00system 0:00.01elapsed 64%CPU
> 0.00user 0.01system 0:00.01elapsed 82%CPU
> 
> The results show the performance increases at least in 548 times.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |    2 ++
>  mm/vmscan.c                |   19 +++++++++++++++++--
>  2 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 436691a66500..82c0bf2d0579 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1283,6 +1283,8 @@ static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg, int nid, int
>  
>  		rcu_read_lock();
>  		map = MEMCG_SHRINKER_MAP(memcg, nid);
> +		/* Pairs with smp mb in shrink_slab() */
> +		smp_mb__before_atomic();
>  		set_bit(nr, map->map);
>  		rcu_read_unlock();
>  	}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7b0075612d73..189b163bef4a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -586,8 +586,23 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>  			continue;
>  
>  		ret = do_shrink_slab(&sc, shrinker, priority);
> -		if (ret == SHRINK_EMPTY)
> -			ret = 0;
> +		if (ret == SHRINK_EMPTY) {
> +			clear_bit(i, map->map);
> +			/*
> +			 * Pairs with mb in memcg_set_shrinker_bit():
> +			 *
> +			 * list_lru_add()     shrink_slab_memcg()
> +			 *   list_add_tail()    clear_bit()
> +			 *   <MB>               <MB>
> +			 *   set_bit()          do_shrink_slab()
> +			 */

Please improve the comment so that it isn't just a diagram.

> +			smp_mb__after_atomic();
> +			ret = do_shrink_slab(&sc, shrinker, priority);
> +			if (ret == SHRINK_EMPTY)
> +				ret = 0;
> +			else
> +				memcg_set_shrinker_bit(memcg, nid, i);
> +		}
>  		freed += ret;
>  
>  		if (rwsem_is_contended(&shrinker_rwsem)) {
> 
