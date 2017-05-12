Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A861B6B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 22:25:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p29so37104648pgn.3
        for <linux-mm@kvack.org>; Thu, 11 May 2017 19:25:32 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e9si1884388plk.170.2017.05.11.19.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 19:25:31 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u187so5705807pgb.1
        for <linux-mm@kvack.org>; Thu, 11 May 2017 19:25:31 -0700 (PDT)
Message-ID: <1494555922.21563.1.camel@gmail.com>
Subject: Re: [PATCH] mm: per-cgroup memory reclaim stats
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 12 May 2017 12:25:22 +1000
In-Reply-To: <1494530183-30808-1-git-send-email-guro@fb.com>
References: <1494530183-30808-1-git-send-email-guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2017-05-11 at 20:16 +0100, Roman Gushchin wrote:
> Track the following reclaim counters for every memory cgroup:
> PGREFILL, PGSCAN, PGSTEAL, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE and
> PGLAZYFREED.
> 
> These values are exposed using the memory.stats interface of cgroup v2.

The changelog could also describe what is currently there and what
is missing. Is there a user space program that uses the newly exported
values? Or is this just for consistency of stats?

> 
> The meaning of each value is the same as for global counters,
> available using /proc/vmstat.
> 
> Also, for consistency, rename mem_cgroup_count_vm_event() to
> count_memcg_event_mm().
> 

I still prefer the mem_cgroup_count_vm_event() name, or memcg_count_vm_event(),
the namespace upfront makes it easier to parse where to look for the the
implementation and also grep. In any case the rename should be independent
patch, but I don't like the name you've proposed.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Li Zefan <lizefan@huawei.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  Documentation/cgroup-v2.txt | 28 ++++++++++++++++++++++++++
>  fs/dax.c                    |  2 +-
>  fs/ncpfs/mmap.c             |  2 +-
>  include/linux/memcontrol.h  | 48 ++++++++++++++++++++++++++++++++++++++++++---
>  mm/filemap.c                |  2 +-
>  mm/memcontrol.c             | 10 ++++++++++
>  mm/memory.c                 |  4 ++--
>  mm/shmem.c                  |  3 +--
>  mm/swap.c                   |  1 +
>  mm/vmscan.c                 | 30 +++++++++++++++++++++-------
>  10 files changed, 113 insertions(+), 17 deletions(-)
> 
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index e50b95c..5804355 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -918,6 +918,34 @@ PAGE_SIZE multiple when read back.
>  
>  		Number of major page faults incurred
>  
> +	  pgrefill
> +
> +		Amount of scanned pages (in an active LRU list)
> +
> +	  pgscan
> +
> +		Amount of scanned pages (in an inactive LRU list)
> +
> +	  pgsteal
> +
> +		Amount of reclaimed pages
> +
> +	  pgactivate
> +
> +		Amount of pages moved to the active LRU list
> +
> +	  pgdeactivate
> +
> +		Amount of pages moved to the inactive LRU lis
> +
> +	  pglazyfree
> +
> +		Amount of pages postponed to be freed under memory pressure
> +
> +	  pglazyfreed
> +
> +		Amount of reclaimed lazyfree pages
> +
>    memory.swap.current
>  
>  	A read-only single value file which exists on non-root
> diff --git a/fs/dax.c b/fs/dax.c
> index 66d7906..9aac521d 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1230,7 +1230,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
>  	case IOMAP_MAPPED:
>  		if (iomap.flags & IOMAP_F_NEW) {
>  			count_vm_event(PGMAJFAULT);
> -			mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT);
> +			count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>  			major = VM_FAULT_MAJOR;
>  		}
>  		error = dax_insert_mapping(mapping, iomap.bdev, iomap.dax_dev,
> diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
> index 0c3905e..6719c0b 100644
> --- a/fs/ncpfs/mmap.c
> +++ b/fs/ncpfs/mmap.c
> @@ -89,7 +89,7 @@ static int ncp_file_mmap_fault(struct vm_fault *vmf)
>  	 * -- nyc
>  	 */
>  	count_vm_event(PGMAJFAULT);
> -	mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT);
> +	count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>  	return VM_FAULT_MAJOR;
>  }
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 899949b..b2a5b1c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -357,6 +357,17 @@ static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
>  }
>  struct mem_cgroup *mem_cgroup_from_id(unsigned short id);
>  
> +static inline struct mem_cgroup *lruvec_memcg(struct lruvec *lruvec)

mem_cgroup_from_lruvec()?

> +{
> +	struct mem_cgroup_per_node *mz;
> +
> +	if (mem_cgroup_disabled())
> +		return NULL;
> +
> +	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> +	return mz->memcg;
> +}
> +
>  /**
>   * parent_mem_cgroup - find the accounting parent of a memcg
>   * @memcg: memcg whose parent to find
> @@ -546,8 +557,23 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>  						gfp_t gfp_mask,
>  						unsigned long *total_scanned);
>  
> -static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> -					     enum vm_event_item idx)
> +static inline void count_memcg_events(struct mem_cgroup *memcg,
> +				      enum vm_event_item idx,
> +				      unsigned long count)
> +{
> +	if (!mem_cgroup_disabled())
> +		this_cpu_add(memcg->stat->events[idx], count);
> +}
> +
> +static inline void count_memcg_page_event(struct page *page,
> +					  enum memcg_stat_item idx)
> +{
> +	if (page->mem_cgroup)
> +		count_memcg_events(page->mem_cgroup, idx, 1);
> +}
> +
> +static inline void count_memcg_event_mm(struct mm_struct *mm,
> +					enum vm_event_item idx)
>  {
>  	struct mem_cgroup *memcg;
>  
> @@ -675,6 +701,11 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  	return NULL;
>  }
>  
> +static inline struct mem_cgroup *lruvec_memcg(struct lruvec *lruvec)
> +{
> +	return NULL;
> +}
> +
>  static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
>  {
>  	return true;
> @@ -789,8 +820,19 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head)
>  {
>  }
>  
> +static inline void count_memcg_events(struct mem_cgroup *memcg,
> +				      enum vm_event_item idx,
> +				      unsigned long count)
> +{
> +}
> +
> +static inline void count_memcg_page_event(struct page *page,
> +					  enum memcg_stat_item idx)
> +{
> +}
> +
>  static inline
> -void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
> +void count_memcg_event_mm(struct mm_struct *mm, enum vm_event_item idx)
>  {
>  }
>  #endif /* CONFIG_MEMCG */
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b7b973b..d640613 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2226,7 +2226,7 @@ int filemap_fault(struct vm_fault *vmf)
>  		/* No page in the page cache at all */
>  		do_sync_mmap_readahead(vmf->vma, ra, file, offset);
>  		count_vm_event(PGMAJFAULT);
> -		mem_cgroup_count_vm_event(vmf->vma->vm_mm, PGMAJFAULT);
> +		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>  		ret = VM_FAULT_MAJOR;
>  retry_find:
>  		page = find_get_page(mapping, offset);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ff73899..0cfa0aa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5231,6 +5231,16 @@ static int memory_stat_show(struct seq_file *m, void *v)
>  	seq_printf(m, "pgfault %lu\n", events[PGFAULT]);
>  	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
>  
> +	seq_printf(m, "pgrefill %lu\n", events[PGREFILL]);
> +	seq_printf(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
> +		   events[PGSCAN_DIRECT]);
> +	seq_printf(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
> +		   events[PGSTEAL_DIRECT]);
> +	seq_printf(m, "pgactivate %lu\n", events[PGACTIVATE]);
> +	seq_printf(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
> +	seq_printf(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
> +	seq_printf(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
> +
>  	seq_printf(m, "workingset_refault %lu\n",
>  		   stat[WORKINGSET_REFAULT]);
>  	seq_printf(m, "workingset_activate %lu\n",
> diff --git a/mm/memory.c b/mm/memory.c
> index 6ff5d72..5aa1348 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2719,7 +2719,7 @@ int do_swap_page(struct vm_fault *vmf)
>  		/* Had to read the page from swap area: Major fault */
>  		ret = VM_FAULT_MAJOR;
>  		count_vm_event(PGMAJFAULT);
> -		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> +		count_memcg_event_mm(vma->vm_mm, PGMAJFAULT);
>  	} else if (PageHWPoison(page)) {
>  		/*
>  		 * hwpoisoned dirty swapcache pages are kept for killing
> @@ -3855,7 +3855,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  	__set_current_state(TASK_RUNNING);
>  
>  	count_vm_event(PGFAULT);
> -	mem_cgroup_count_vm_event(vma->vm_mm, PGFAULT);
> +	count_memcg_event_mm(vma->vm_mm, PGFAULT);
>  
>  	/* do counter updates before entering really critical section. */
>  	check_sync_rss_stat(current);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index e67d6ba..8cf16fb 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1645,8 +1645,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  			if (fault_type) {
>  				*fault_type |= VM_FAULT_MAJOR;
>  				count_vm_event(PGMAJFAULT);
> -				mem_cgroup_count_vm_event(charge_mm,
> -							  PGMAJFAULT);
> +				count_memcg_event_mm(charge_mm, PGMAJFAULT);
>  			}
>  			/* Here we actually start the io */
>  			page = shmem_swapin(swap, gfp, info, index);
> diff --git a/mm/swap.c b/mm/swap.c
> index 98d08b4..4f44dbd 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -591,6 +591,7 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
>  		add_page_to_lru_list(page, lruvec, LRU_INACTIVE_FILE);
>  
>  		__count_vm_events(PGLAZYFREE, hpage_nr_pages(page));
> +		count_memcg_page_event(page, PGLAZYFREE);
>  		update_page_reclaim_stat(lruvec, 1, 0);
>  	}
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5ebf468..76e98b5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1266,6 +1266,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  
>  			count_vm_event(PGLAZYFREED);
> +			count_memcg_page_event(page, PGLAZYFREED);
>  		} else if (!mapping || !__remove_mapping(mapping, page, true))
>  			goto keep_locked;
>  		/*
> @@ -1295,6 +1296,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (!PageMlocked(page)) {
>  			SetPageActive(page);
>  			pgactivate++;
> +			count_memcg_page_event(page, PGACTIVATE);
>  		}
>  keep_locked:
>  		unlock_page(page);
> @@ -1725,11 +1727,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
> -	if (global_reclaim(sc)) {
> -		if (current_is_kswapd())
> +	if (current_is_kswapd()) {
> +		if (global_reclaim(sc))
>  			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
> -		else
> +		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
> +				   nr_scanned);
> +	} else {
> +		if (global_reclaim(sc))
>  			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
> +		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
> +				   nr_scanned);
>  	}
>  	spin_unlock_irq(&pgdat->lru_lock);
>  
> @@ -1741,11 +1748,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  
>  	spin_lock_irq(&pgdat->lru_lock);
>  
> -	if (global_reclaim(sc)) {
> -		if (current_is_kswapd())
> +	if (current_is_kswapd()) {
> +		if (global_reclaim(sc))
>  			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
> -		else
> +		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
> +				   nr_reclaimed);

Has the else gone missing? What happens if it's global_reclaim(), do
we still account the count in memcg?

> +	} else {
> +		if (global_reclaim(sc))
>  			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
> +		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
> +				   nr_reclaimed);

It sounds like memcg accumlates both global and memcg reclaim driver
counts -- is this what we want?

>  	}
>  
>  	putback_inactive_pages(lruvec, &page_list);
> @@ -1890,8 +1902,11 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
>  		}
>  	}
>  
> -	if (!is_active_lru(lru))
> +	if (!is_active_lru(lru)) {
>  		__count_vm_events(PGDEACTIVATE, nr_moved);
> +		count_memcg_events(lruvec_memcg(lruvec), PGDEACTIVATE,
> +				   nr_moved);
> +	}
>  
>  	return nr_moved;
>  }
> @@ -1929,6 +1944,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	__count_vm_events(PGREFILL, nr_scanned);
> +	count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
>  
>  	spin_unlock_irq(&pgdat->lru_lock);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
