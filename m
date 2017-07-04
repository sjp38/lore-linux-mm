Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10B986B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 06:59:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so45149580wrb.6
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 03:59:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x19si2242825wme.73.2017.07.04.03.59.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 03:59:17 -0700 (PDT)
Date: Tue, 4 Jul 2017 12:59:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch V2 2/2] mm/memory-hotplug: Switch locking to a percpu
 rwsem
Message-ID: <20170704105915.GL14722@dhcp22.suse.cz>
References: <20170704093232.995040438@linutronix.de>
 <20170704093421.506836322@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170704093421.506836322@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue 04-07-17 11:32:34, Thomas Gleixner wrote:
> Andrey reported a potential deadlock with the memory hotplug lock and the
> cpu hotplug lock.
> 
> The reason is that memory hotplug takes the memory hotplug lock and then
> calls stop_machine() which calls get_online_cpus(). That's the reverse lock
> order to get_online_cpus(); get_online_mems(); in mm/slub_common.c
> 
> The problem has been there forever. The reason why this was never reported
> is that the cpu hotplug locking had this homebrewn recursive reader writer
> semaphore construct which due to the recursion evaded the full lock dep
> coverage. The memory hotplug code copied that construct verbatim and
> therefor has similar issues.
> 
> Three steps to fix this:
> 
> 1) Convert the memory hotplug locking to a per cpu rwsem so the potential
>    issues get reported proper by lockdep.
> 
> 2) Lock the online cpus in mem_hotplug_begin() before taking the memory
>    hotplug rwsem and use stop_machine_cpuslocked() in the page_alloc code
>    and use to avoid recursive locking.
> 
> 3) The cpu hotpluck locking in #2 causes a recursive locking of the cpu
>    hotplug lock via __offline_pages() -> lru_add_drain_all(). Solve this by
>    invoking lru_add_drain_all_cpuslocked() instead.
> 
> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c |   89 ++++++++--------------------------------------------
>  mm/page_alloc.c     |    2 -
>  2 files changed, 16 insertions(+), 75 deletions(-)
> 
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -52,32 +52,17 @@ static void generic_online_page(struct p
>  static online_page_callback_t online_page_callback = generic_online_page;
>  static DEFINE_MUTEX(online_page_callback_lock);
>  
> -/* The same as the cpu_hotplug lock, but for memory hotplug. */
> -static struct {
> -	struct task_struct *active_writer;
> -	struct mutex lock; /* Synchronizes accesses to refcount, */
> -	/*
> -	 * Also blocks the new readers during
> -	 * an ongoing mem hotplug operation.
> -	 */
> -	int refcount;
> +DEFINE_STATIC_PERCPU_RWSEM(mem_hotplug_lock);
>  
> -#ifdef CONFIG_DEBUG_LOCK_ALLOC
> -	struct lockdep_map dep_map;
> -#endif
> -} mem_hotplug = {
> -	.active_writer = NULL,
> -	.lock = __MUTEX_INITIALIZER(mem_hotplug.lock),
> -	.refcount = 0,
> -#ifdef CONFIG_DEBUG_LOCK_ALLOC
> -	.dep_map = {.name = "mem_hotplug.lock" },
> -#endif
> -};
> +void get_online_mems(void)
> +{
> +	percpu_down_read(&mem_hotplug_lock);
> +}
>  
> -/* Lockdep annotations for get/put_online_mems() and mem_hotplug_begin/end() */
> -#define memhp_lock_acquire_read() lock_map_acquire_read(&mem_hotplug.dep_map)
> -#define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
> -#define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
> +void put_online_mems(void)
> +{
> +	percpu_up_read(&mem_hotplug_lock);
> +}
>  
>  #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
>  bool memhp_auto_online;
> @@ -97,60 +82,16 @@ static int __init setup_memhp_default_st
>  }
>  __setup("memhp_default_state=", setup_memhp_default_state);
>  
> -void get_online_mems(void)
> -{
> -	might_sleep();
> -	if (mem_hotplug.active_writer == current)
> -		return;
> -	memhp_lock_acquire_read();
> -	mutex_lock(&mem_hotplug.lock);
> -	mem_hotplug.refcount++;
> -	mutex_unlock(&mem_hotplug.lock);
> -
> -}
> -
> -void put_online_mems(void)
> -{
> -	if (mem_hotplug.active_writer == current)
> -		return;
> -	mutex_lock(&mem_hotplug.lock);
> -
> -	if (WARN_ON(!mem_hotplug.refcount))
> -		mem_hotplug.refcount++; /* try to fix things up */
> -
> -	if (!--mem_hotplug.refcount && unlikely(mem_hotplug.active_writer))
> -		wake_up_process(mem_hotplug.active_writer);
> -	mutex_unlock(&mem_hotplug.lock);
> -	memhp_lock_release();
> -
> -}
> -
> -/* Serializes write accesses to mem_hotplug.active_writer. */
> -static DEFINE_MUTEX(memory_add_remove_lock);
> -
>  void mem_hotplug_begin(void)
>  {
> -	mutex_lock(&memory_add_remove_lock);
> -
> -	mem_hotplug.active_writer = current;
> -
> -	memhp_lock_acquire();
> -	for (;;) {
> -		mutex_lock(&mem_hotplug.lock);
> -		if (likely(!mem_hotplug.refcount))
> -			break;
> -		__set_current_state(TASK_UNINTERRUPTIBLE);
> -		mutex_unlock(&mem_hotplug.lock);
> -		schedule();
> -	}
> +	cpus_read_lock();
> +	percpu_down_write(&mem_hotplug_lock);
>  }
>  
>  void mem_hotplug_done(void)
>  {
> -	mem_hotplug.active_writer = NULL;
> -	mutex_unlock(&mem_hotplug.lock);
> -	memhp_lock_release();
> -	mutex_unlock(&memory_add_remove_lock);
> +	percpu_up_write(&mem_hotplug_lock);
> +	cpus_read_unlock();
>  }
>  
>  /* add this memory to iomem resource */
> @@ -1919,7 +1860,7 @@ static int __ref __offline_pages(unsigne
>  		goto failed_removal;
>  	ret = 0;
>  	if (drain) {
> -		lru_add_drain_all();
> +		lru_add_drain_all_cpuslocked();
>  		cond_resched();
>  		drain_all_pages(zone);
>  	}
> @@ -1940,7 +1881,7 @@ static int __ref __offline_pages(unsigne
>  		}
>  	}
>  	/* drain all zone's lru pagevec, this is asynchronous... */
> -	lru_add_drain_all();
> +	lru_add_drain_all_cpuslocked();
>  	yield();
>  	/* drain pcp pages, this is synchronous. */
>  	drain_all_pages(zone);
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5216,7 +5216,7 @@ void __ref build_all_zonelists(pg_data_t
>  #endif
>  		/* we have to stop all cpus to guarantee there is no user
>  		   of zonelist */
> -		stop_machine(__build_all_zonelists, pgdat, NULL);
> +		stop_machine_cpuslocked(__build_all_zonelists, pgdat, NULL);
>  		/* cpuset refresh routine should be here */
>  	}
>  	vm_total_pages = nr_free_pagecache_pages();
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
