Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45B998D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:30:44 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2TFUM6W017900
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 02:30:22 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2TFUTJC1478792
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 02:30:31 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2TFUSGE007891
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 02:30:29 +1100
Date: Tue, 29 Mar 2011 21:00:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Add the pagefault count into memcg stats.
Message-ID: <20110329153023.GC2879@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1301184884-17155-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1301184884-17155-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-03-26 17:14:44]:

> Two new stats in per-memcg memory.stat which tracks the number of
> page faults and number of major page faults.
> 
> "pgfault"
> "pgmajfault"
> 
> It is valuable to track the two stats for both measuring application's
> performance as well as the efficiency of the kernel page reclaim path.
> 
> Functional test: check the total number of pgfault/pgmajfault of all
> memcgs and compare with global vmstat value:
> 
> $ cat /proc/vmstat | grep fault
> pgfault 1070751
> pgmajfault 553
> 
> $ cat /dev/cgroup/memory.stat | grep fault
> pgfault 1069962
> pgmajfault 553
> total_pgfault 1069966
> total_pgmajfault 553
> 
> $ cat /dev/cgroup/A/memory.stat | grep fault
> pgfault 199
> pgmajfault 0
> total_pgfault 199
> total_pgmajfault 0
> 
> Performance test: run page fault test(pft) wit 16 thread on faulting in 15G
> anon pages in 16G container. There is no regression noticed on the "flt/cpu/s"
> 
> Sample output from pft:
> TAG pft:anon-sys-default:
>   Gb  Thr CLine   User     System     Wall    flt/cpu/s fault/wsec
>   15   16   1     0.67s   232.11s    14.68s   16892.130 267796.518
> 
> $ ./ministat mmotm.txt mmotm_fault.txt
> x mmotm.txt (w/o patch)
> + mmotm_fault.txt (w/ patch)
> +-------------------------------------------------------------------------+
>     N           Min           Max        Median           Avg        Stddev
> x  10     16682.962     17344.027     16913.524     16928.812      166.5362
> +  10      16696.49      17480.09     16949.143     16951.448     223.56288
> No difference proven at 95.0% confidence
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  Documentation/cgroups/memory.txt |    4 +++
>  fs/ncpfs/mmap.c                  |    2 +
>  include/linux/memcontrol.h       |   22 +++++++++++++++
>  mm/filemap.c                     |    1 +
>  mm/memcontrol.c                  |   54 ++++++++++++++++++++++++++++++++++++++
>  mm/memory.c                      |    2 +
>  mm/shmem.c                       |    1 +
>  7 files changed, 86 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index b6ed61c..2db6103 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -385,6 +385,8 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
>  swap		- # of bytes of swap usage
> +pgfault		- # of page faults.
> +pgmajfault	- # of major page faults.
>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>  		LRU list.
>  active_anon	- # of bytes of anonymous and swap cache memory on active
> @@ -406,6 +408,8 @@ total_mapped_file	- sum of all children's "cache"
>  total_pgpgin		- sum of all children's "pgpgin"
>  total_pgpgout		- sum of all children's "pgpgout"
>  total_swap		- sum of all children's "swap"
> +total_pgfault		- sum of all children's "pgfault"
> +total_pgmajfault	- sum of all children's "pgmajfault"
>  total_inactive_anon	- sum of all children's "inactive_anon"
>  total_active_anon	- sum of all children's "active_anon"
>  total_inactive_file	- sum of all children's "inactive_file"
> diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
> index a7c07b4..adb3f45 100644
> --- a/fs/ncpfs/mmap.c
> +++ b/fs/ncpfs/mmap.c
> @@ -16,6 +16,7 @@
>  #include <linux/mman.h>
>  #include <linux/string.h>
>  #include <linux/fcntl.h>
> +#include <linux/memcontrol.h>
> 
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
> @@ -92,6 +93,7 @@ static int ncp_file_mmap_fault(struct vm_area_struct *area,
>  	 * -- wli
>  	 */
>  	count_vm_event(PGMAJFAULT);
> +	mem_cgroup_pgmajfault_from_mm(area->vm_mm);
>  	return VM_FAULT_MAJOR;
>  }
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5a5ce70..f771fc1 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -147,6 +147,11 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> 
> +void mem_cgroup_pgfault(struct mem_cgroup *memcg, int val);
> +void mem_cgroup_pgmajfault(struct mem_cgroup *memcg, int val);
> +void mem_cgroup_pgfault_from_mm(struct mm_struct *mm);
> +void mem_cgroup_pgmajfault_from_mm(struct mm_struct *mm);
> +
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
>  #endif
> @@ -354,6 +359,23 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
>  {
>  }
> 
> +static inline void mem_cgroup_pgfault(struct mem_cgroup *memcg,
> +				      int val)
> +{
> +}
> +
> +static inline void mem_cgroup_pgmajfault(struct mem_cgroup *memcg,
> +					 int val)
> +{
> +}
> +
> +static inline void mem_cgroup_pgfault_from_mm(struct mm_struct *mm)
> +{
> +}
> +
> +static inline void mem_cgroup_pgmajfault_from_mm(struct mm_struct *mm)
> +{
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a6cfecf..5dc5401 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1683,6 +1683,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  		/* No page in the page cache at all */
>  		do_sync_mmap_readahead(vma, ra, file, offset);
>  		count_vm_event(PGMAJFAULT);
> +		mem_cgroup_pgmajfault_from_mm(vma->vm_mm);
>  		ret = VM_FAULT_MAJOR;
>  retry_find:
>  		page = find_get_page(mapping, offset);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4407dd0..63d66f1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -94,6 +94,8 @@ enum mem_cgroup_events_index {
>  	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
>  	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
>  	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
> +	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
> +	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
>  	MEM_CGROUP_EVENTS_NSTATS,
>  };
>  /*
> @@ -585,6 +587,16 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
>  	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
>  }
> 
> +void mem_cgroup_pgfault(struct mem_cgroup *mem, int val)
> +{
> +	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGFAULT], val);
> +}
> +
> +void mem_cgroup_pgmajfault(struct mem_cgroup *mem, int val)
> +{
> +	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT], val);
> +}
> +
>  static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
>  					    enum mem_cgroup_events_index idx)
>  {
> @@ -813,6 +825,40 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
>  	return (mem == root_mem_cgroup);
>  }
> 
> +void mem_cgroup_pgfault_from_mm(struct mm_struct *mm)
> +{
> +	struct mem_cgroup *mem;
> +
> +	if (!mm)
> +		return;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	if (unlikely(!mem))
> +		goto out;

A lot of this can be reused, just a minor nitpick. May be you can
combine this function and the one below

> +	mem_cgroup_pgfault(mem, 1);
> +
> +out:
> +	rcu_read_unlock();
> +}
> +
> +void mem_cgroup_pgmajfault_from_mm(struct mm_struct *mm)
> +{
> +	struct mem_cgroup *mem;
> +
> +	if (!mm)
> +		return;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	if (unlikely(!mem))
> +		goto out;
> +	mem_cgroup_pgmajfault(mem, 1);
> +out:
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(mem_cgroup_pgmajfault_from_mm);
> +
>  /*
>   * Following LRU functions are allowed to be used without PCG_LOCK.
>   * Operations are called by routine of global LRU independently from memcg.
> @@ -3772,6 +3818,8 @@ enum {
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
>  	MCS_SWAP,
> +	MCS_PGFAULT,
> +	MCS_PGMAJFAULT,
>  	MCS_INACTIVE_ANON,
>  	MCS_ACTIVE_ANON,
>  	MCS_INACTIVE_FILE,
> @@ -3794,6 +3842,8 @@ struct {
>  	{"pgpgin", "total_pgpgin"},
>  	{"pgpgout", "total_pgpgout"},
>  	{"swap", "total_swap"},
> +	{"pgfault", "total_pgfault"},
> +	{"pgmajfault", "total_pgmajfault"},
>  	{"inactive_anon", "total_inactive_anon"},
>  	{"active_anon", "total_active_anon"},
>  	{"inactive_file", "total_inactive_file"},
> @@ -3822,6 +3872,10 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
>  		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
>  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
>  	}
> +	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFAULT);
> +	s->stat[MCS_PGFAULT] += val;
> +	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAULT);
> +	s->stat[MCS_PGMAJFAULT] += val;
> 
>  	/* per zone stat */
>  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
> diff --git a/mm/memory.c b/mm/memory.c
> index 8617d39..0f7ebc9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2836,6 +2836,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		/* Had to read the page from swap area: Major fault */
>  		ret = VM_FAULT_MAJOR;
>  		count_vm_event(PGMAJFAULT);
> +		mem_cgroup_pgmajfault_from_mm(mm);
>  	} else if (PageHWPoison(page)) {
>  		/*
>  		 * hwpoisoned dirty swapcache pages are kept for killing
> @@ -3375,6 +3376,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	__set_current_state(TASK_RUNNING);
> 
>  	count_vm_event(PGFAULT);
> +	mem_cgroup_pgfault_from_mm(mm);
> 
>  	/* do counter updates before entering really critical section. */
>  	check_sync_rss_stat(current);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ad8346b..5a82674 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1289,6 +1289,7 @@ repeat:
>  			/* here we actually do the io */
>  			if (type && !(*type & VM_FAULT_MAJOR)) {
>  				__count_vm_event(PGMAJFAULT);
> +				mem_cgroup_pgmajfault_from_mm(current->mm);
>  				*type |= VM_FAULT_MAJOR;
>  			}
>  			spin_unlock(&info->lock);
> -- 
> 1.7.3.1
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
