Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 464492806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 10:32:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y22so5420029wry.1
        for <linux-mm@kvack.org>; Fri, 19 May 2017 07:32:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a90si7288042ede.336.2017.05.19.07.32.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 07:32:48 -0700 (PDT)
Date: Fri, 19 May 2017 16:32:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom_kill: count global and memory cgroup oom kills
Message-ID: <20170519143246.GJ29839@dhcp22.suse.cz>
References: <149520375057.74196.2843113275800730971.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149520375057.74196.2843113275800730971.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

[CC Vladimir and Johannes as this involves memcg]

i will get to this early next week but from a quick look it seems
acceptable.

On Fri 19-05-17 17:22:30, Konstantin Khlebnikov wrote:
> Show count of global oom killer invocations in /proc/vmstat and
> count of oom kills inside memory cgroup in knob "memory.events"
> (in memory.oom_control for v1 cgroup).
> 
> Also describe difference between "oom" and "oom_kill" in memory
> cgroup documentation. Currently oom in memory cgroup kills tasks
> iff shortage has happened inside page fault.
> 
> These counters helps in monitoring oom kills - for now
> the only way is grepping for magic words in kernel log.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  Documentation/cgroup-v2.txt   |   12 +++++++++++-
>  include/linux/memcontrol.h    |    1 +
>  include/linux/vm_event_item.h |    1 +
>  mm/memcontrol.c               |    2 ++
>  mm/oom_kill.c                 |    6 ++++++
>  mm/vmstat.c                   |    1 +
>  6 files changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index dc5e2dcdbef4..a742008d76aa 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -830,9 +830,19 @@ PAGE_SIZE multiple when read back.
>  
>  	  oom
>  
> +		The number of time the cgroup's memory usage was
> +		reached the limit and allocation was about to fail.
> +		Result could be oom kill, -ENOMEM from any syscall or
> +		completely ignored in cases like disk readahead.
> +		For now oom in memory cgroup kills tasks iff shortage
> +		has happened inside page fault.
> +
> +	  oom_kill
> +
>  		The number of times the OOM killer has been invoked in
>  		the cgroup.  This may not exactly match the number of
> -		processes killed but should generally be close.
> +		processes killed but should generally be close:	each
> +		invocation could kill several processes at once.
>  
>    memory.stat
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 899949bbb2f9..2cdcebb78b58 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -55,6 +55,7 @@ enum memcg_event_item {
>  	MEMCG_HIGH,
>  	MEMCG_MAX,
>  	MEMCG_OOM,
> +	MEMCG_OOM_KILL,
>  	MEMCG_NR_EVENTS,
>  };
>  
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index d84ae90ccd5c..1707e0a7d943 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -41,6 +41,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
>  		PAGEOUTRUN, PGROTATED,
>  		DROP_PAGECACHE, DROP_SLAB,
> +		OOM_KILL,
>  #ifdef CONFIG_NUMA_BALANCING
>  		NUMA_PTE_UPDATES,
>  		NUMA_HUGE_PTE_UPDATES,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 94172089f52f..416024837b81 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3574,6 +3574,7 @@ static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
>  
>  	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
>  	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
> +	seq_printf(sf, "oom_kill %lu\n", memcg_sum_events(memcg, MEMCG_OOM_KILL));
>  	return 0;
>  }
>  
> @@ -5165,6 +5166,7 @@ static int memory_events_show(struct seq_file *m, void *v)
>  	seq_printf(m, "high %lu\n", memcg_sum_events(memcg, MEMCG_HIGH));
>  	seq_printf(m, "max %lu\n", memcg_sum_events(memcg, MEMCG_MAX));
>  	seq_printf(m, "oom %lu\n", memcg_sum_events(memcg, MEMCG_OOM));
> +	seq_printf(m, "oom_kill %lu\n", memcg_sum_events(memcg, MEMCG_OOM_KILL));
>  
>  	return 0;
>  }
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 04c9143a8625..c50bff3c3409 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -873,6 +873,12 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  		victim = p;
>  	}
>  
> +	/* Raise event before sending signal: reaper must see this */
> +	if (!is_memcg_oom(oc))
> +		count_vm_event(OOM_KILL);
> +	else
> +		mem_cgroup_event(oc->memcg, MEMCG_OOM_KILL);
> +
>  	/* Get a reference to safely compare mm after task_unlock(victim) */
>  	mm = victim->mm;
>  	mmgrab(mm);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 76f73670200a..fe80b81a86e0 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1018,6 +1018,7 @@ const char * const vmstat_text[] = {
>  
>  	"drop_pagecache",
>  	"drop_slab",
> +	"oom_kill",
>  
>  #ifdef CONFIG_NUMA_BALANCING
>  	"numa_pte_updates",
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
