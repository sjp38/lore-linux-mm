Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 99CCD5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 20:03:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F032lX001143
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Apr 2009 09:03:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BDD145DE54
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 09:03:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4078645DE53
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 09:03:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 098C01DB8043
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 09:03:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 828181DB8040
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 09:03:01 +0900 (JST)
Date: Wed, 15 Apr 2009 09:01:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Add file RSS accounting to the memory resource
 controller
Message-Id: <20090415090130.26813449.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090414180706.GQ7082@balbir.in.ibm.com>
References: <20090414180706.GQ7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

I think your concept is good. A few comments below.

On Tue, 14 Apr 2009 23:37:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> Feature: Add file RSS tracking per memory cgroup
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Testing
> 
> 1. Feature enabled, built and booted the kernel. Mounted the memory
> resource controller and verified the statistics
> 2. Compiled with CGROUP_MEM_RES_CTLR disabled
> 
> We currently don't track file RSS, the RSS we report is actually anon RSS.
> All the file mapped pages, come in through the page cache and get accounted
> there. This patch adds support for accounting file RSS pages. It should
> 
> 1. Help improve the metrics reported by the memory resource controller
> 2. Will form the basis for a future shared memory accounting heuristic
>    that has been proposed by Kamezawa.
> 
> Unfortunately, we cannot rename the existing "rss" keyword used in memory.stat
> to "anon_rss". We however, add "file_rss" data and hope to educate the end
> user through documentation.
> ---
> 
>  include/linux/memcontrol.h |    7 +++++++
>  include/linux/rmap.h       |    4 ++--
>  mm/filemap_xip.c           |    2 +-
>  mm/fremap.c                |    2 +-
>  mm/memcontrol.c            |   34 +++++++++++++++++++++++++++++++++-
>  mm/memory.c                |    8 ++++----
>  mm/migrate.c               |    2 +-
>  mm/rmap.c                  |   13 ++++++++-----
>  8 files changed, 57 insertions(+), 15 deletions(-)
> 
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 18146c9..c844a13 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -116,6 +116,8 @@ static inline bool mem_cgroup_disabled(void)
>  }
>  
>  extern bool mem_cgroup_oom_called(struct task_struct *task);
> +extern void
> +mem_cgroup_update_statistics(struct page *page, struct mm_struct *mm, int val);
>  
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
> @@ -264,6 +266,11 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
>  }
>  
> +static inline void
> +mem_cgroup_update_statistics(struct page *page, struct mm_struct *mm, int val)
> +{
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index b35bc0e..01b4af1 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -68,8 +68,8 @@ void __anon_vma_link(struct vm_area_struct *);
>   */
>  void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
>  void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
> -void page_add_file_rmap(struct page *);
> -void page_remove_rmap(struct page *);
> +void page_add_file_rmap(struct page *, struct vm_area_struct *);
> +void page_remove_rmap(struct page *, struct vm_area_struct *);
>  
>  #ifdef CONFIG_DEBUG_VM
>  void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address);
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> index 427dfe3..e8b2b18 100644
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -193,7 +193,7 @@ retry:
>  			/* Nuke the page table entry. */
>  			flush_cache_page(vma, address, pte_pfn(*pte));
>  			pteval = ptep_clear_flush_notify(vma, address, pte);
> -			page_remove_rmap(page);
> +			page_remove_rmap(page, vma);
>  			dec_mm_counter(mm, file_rss);
>  			BUG_ON(pte_dirty(pteval));
>  			pte_unmap_unlock(pte, ptl);
> diff --git a/mm/fremap.c b/mm/fremap.c
> index b6ec85a..01ea2da 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -37,7 +37,7 @@ static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
>  		if (page) {
>  			if (pte_dirty(pte))
>  				set_page_dirty(page);
> -			page_remove_rmap(page);
> +			page_remove_rmap(page, vma);
>  			page_cache_release(page);
>  			update_hiwater_rss(mm);
>  			dec_mm_counter(mm, file_rss);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e44fb0f..d903b61 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -62,7 +62,8 @@ enum mem_cgroup_stat_index {
>  	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
>  	 */
>  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
> +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_FILE_RSS,  /* # of pages charged as file rss */

I don't like the word "FILE RSS". MAPPED FILE PAGES or some will be more straigtforward.
(IIUC, meminfo shows this information as MAPPED_FILE)

>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  
> @@ -321,6 +322,33 @@ static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
>  	return css_is_removed(&mem->css);
>  }
>  
> +/*
> + * Currently used to update file_rss statistics, but the routine can be
> + * generalized to update other statistics as well.
> + */
> +void
> +mem_cgroup_update_statistics(struct page *page, struct mm_struct *mm, int val)
> +{

Hmm. "mem_cgroup_update_statistics()" have wider meaning than what it does..
Could you 
  - modify function name for showing "this function counts MAPPED_FILE"
 or
  - add a function argument as "Which counter should be modified."


> +	struct mem_cgroup *mem;
> +	struct mem_cgroup_stat *stat;
> +	struct mem_cgroup_stat_cpu *cpustat;
> +	int cpu = get_cpu();
> +
> +	if (!page_is_file_cache(page))
> +		return;
> +
> +	if (unlikely(!mm))
> +		mm = &init_mm;
> +
> +	mem = try_get_mem_cgroup_from_mm(mm);
> +	if (!mem)
> +		return;
> +
> +	stat = &mem->stat;
> +	cpustat = &stat->cpustat[cpu];
> +
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_RSS, val);
> +}
>  
>  /*
>   * Call callback function against all cgroup under hierarchy tree.
> @@ -2051,6 +2079,7 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
>  enum {
>  	MCS_CACHE,
>  	MCS_RSS,
> +	MCS_FILE_RSS,
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
>  	MCS_INACTIVE_ANON,
> @@ -2071,6 +2100,7 @@ struct {
>  } memcg_stat_strings[NR_MCS_STAT] = {
>  	{"cache", "total_cache"},
>  	{"rss", "total_rss"},
> +	{"file_rss", "total_file_rss"},
>  	{"pgpgin", "total_pgpgin"},
>  	{"pgpgout", "total_pgpgout"},
>  	{"inactive_anon", "total_inactive_anon"},
> @@ -2091,6 +2121,8 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
>  	s->stat[MCS_CACHE] += val * PAGE_SIZE;
>  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
>  	s->stat[MCS_RSS] += val * PAGE_SIZE;
> +	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_FILE_RSS);
> +	s->stat[MCS_FILE_RSS] += val * PAGE_SIZE;
>  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGIN_COUNT);
>  	s->stat[MCS_PGPGIN] += val;
>  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);

IIUC, you have to add hook to force_empty() and move FILE_RSS counter to the parent.
I hope there is no terrible race around force empty...

Thanks,
-Kame


> diff --git a/mm/memory.c b/mm/memory.c
> index a715b19..95a9ded 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -822,7 +822,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  					mark_page_accessed(page);
>  				file_rss--;
>  			}
> -			page_remove_rmap(page);
> +			page_remove_rmap(page, vma);
>  			if (unlikely(page_mapcount(page) < 0))
>  				print_bad_pte(vma, addr, ptent, page);
>  			tlb_remove_page(tlb, page);
> @@ -1421,7 +1421,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>  	/* Ok, finally just insert the thing.. */
>  	get_page(page);
>  	inc_mm_counter(mm, file_rss);
> -	page_add_file_rmap(page);
> +	page_add_file_rmap(page, vma);
>  	set_pte_at(mm, addr, pte, mk_pte(page, prot));
>  
>  	retval = 0;
> @@ -2080,7 +2080,7 @@ gotten:
>  			 * mapcount is visible. So transitively, TLBs to
>  			 * old page will be flushed before it can be reused.
>  			 */
> -			page_remove_rmap(old_page);
> +			page_remove_rmap(old_page, vma);
>  		}
>  
>  		/* Free the old page.. */
> @@ -2718,7 +2718,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			page_add_new_anon_rmap(page, vma, address);
>  		} else {
>  			inc_mm_counter(mm, file_rss);
> -			page_add_file_rmap(page);
> +			page_add_file_rmap(page, vma);
>  			if (flags & FAULT_FLAG_WRITE) {
>  				dirty_page = page;
>  				get_page(dirty_page);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 068655d..098d365 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -131,7 +131,7 @@ static void remove_migration_pte(struct vm_area_struct *vma,
>  	if (PageAnon(new))
>  		page_add_anon_rmap(new, vma, addr);
>  	else
> -		page_add_file_rmap(new);
> +		page_add_file_rmap(new, vma);
>  
>  	/* No need to invalidate - it was non-present before */
>  	update_mmu_cache(vma, addr, pte);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 1652166..3ece45e 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -686,10 +686,12 @@ void page_add_new_anon_rmap(struct page *page,
>   *
>   * The caller needs to hold the pte lock.
>   */
> -void page_add_file_rmap(struct page *page)
> +void page_add_file_rmap(struct page *page, struct vm_area_struct *vma)
>  {
> -	if (atomic_inc_and_test(&page->_mapcount))
> +	if (atomic_inc_and_test(&page->_mapcount)) {
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> +		mem_cgroup_update_statistics(page, vma->vm_mm, 1);
> +	}
>  }
>  
>  #ifdef CONFIG_DEBUG_VM
> @@ -719,7 +721,7 @@ void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long
>   *
>   * The caller needs to hold the pte lock.
>   */
> -void page_remove_rmap(struct page *page)
> +void page_remove_rmap(struct page *page, struct vm_area_struct *vma)
>  {
>  	if (atomic_add_negative(-1, &page->_mapcount)) {
>  		/*
> @@ -738,6 +740,7 @@ void page_remove_rmap(struct page *page)
>  			mem_cgroup_uncharge_page(page);
>  		__dec_zone_page_state(page,
>  			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
> +		mem_cgroup_update_statistics(page, vma->vm_mm, -1);
>  		/*
>  		 * It would be tidy to reset the PageAnon mapping here,
>  		 * but that might overwrite a racing page_add_anon_rmap
> @@ -835,7 +838,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		dec_mm_counter(mm, file_rss);
>  
>  
> -	page_remove_rmap(page);
> +	page_remove_rmap(page, vma);
>  	page_cache_release(page);
>  
>  out_unmap:
> @@ -950,7 +953,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  		if (pte_dirty(pteval))
>  			set_page_dirty(page);
>  
> -		page_remove_rmap(page);
> +		page_remove_rmap(page, vma);
>  		page_cache_release(page);
>  		dec_mm_counter(mm, file_rss);
>  		(*mapcount)--;
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
