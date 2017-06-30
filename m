Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5E72802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:27:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l81so6299585wmg.8
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 02:27:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n184si9989866wmn.34.2017.06.30.02.27.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 02:27:49 -0700 (PDT)
Date: Fri, 30 Jun 2017 11:27:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
Message-ID: <20170630092747.GD22917@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1706291803380.1861@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1706291803380.1861@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

[CC Vladimir and Heiko who were touching this area lately]

On Thu 29-06-17 18:11:15, Thomas Gleixner wrote:
> Andrey reported a potential deadlock with the memory hotplug lock and the
> cpu hotplug lock.
> 
> The reason is that memory hotplug takes the memory hotplug lock and then
> calls stop_machine() which calls get_online_cpus(). That's the reverse lock
> order to get_online_cpus(); get_online_mems(); in mm/slub_common.c

I always considered the stop_machine usage there totally gross. But
never had time to look into it properly. Memory hotplug locking is a
story of its own.
 
> The problem has been there forever. The reason why this was never reported
> is that the cpu hotplug locking had this homebrewn recursive reader writer
> semaphore construct which due to the recursion evaded the full lock dep
> coverage. The memory hotplug code copied that construct verbatim and
> therefor has similar issues.
> 
> Two steps to fix this:
> 
> 1) Convert the memory hotplug locking to a per cpu rwsem so the potential
>    issues get reported proper by lockdep.
> 
> 2) Lock the online cpus in mem_hotplug_begin() before taking the memory
>    hotplug rwsem and use stop_machine_cpuslocked() in the page_alloc code
>    to avoid recursive locking.

So I like this simplification a lot! Even if we can get rid of the
stop_machine eventually this patch would be an improvement. A short
comment on why the per-cpu semaphore over the regular one is better
would be nice.

I cannot give my ack yet, I have to mull over the patch some
more because this has been an area of subtle bugs (especially
the lock dependency with the hotplug device locking - look at
lock_device_hotplug_sysfs if you dare) but it looks good from the first
look. Give me few days, please.

> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> ---
> 
> Note 1:
>  Applies against -next or
>      
>    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git smp/hotplug
> 
>  which contains the hotplug locking rework including stop_machine_cpuslocked()
> 
> Note 2:
> 
>  Most of the call sites of get_online_mems() are also calling get_online_cpus().
> 
>  So we could switch the whole machinery to use the CPU hotplug locking for
>  protecting both memory and CPU hotplug. That actually works and removes
>  another 40 lines of code.
> 
> ---
>  mm/memory_hotplug.c |   85 +++++++---------------------------------------------
>  mm/page_alloc.c     |    2 -
>  2 files changed, 14 insertions(+), 73 deletions(-)
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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
