Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5AB905F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 20:53:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3G0sXhA031860
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Apr 2009 09:54:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 62C1A45DD74
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:54:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 41BAB45DD72
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:54:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B85D1DB8014
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:54:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E02661DB8012
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:54:32 +0900 (JST)
Date: Thu, 16 Apr 2009 09:53:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090415120510.GX7082@balbir.in.ibm.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Apr 2009 17:35:10 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +void mem_cgroup_update_mapped_file_stat(struct page *page, struct mm_struct *mm,
> +					int val)
> +{
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
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
> +}
>  
put_cpu() is necessary.



>  /*
>   * Call callback function against all cgroup under hierarchy tree.
> @@ -1096,6 +1124,9 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  	struct mem_cgroup_per_zone *from_mz, *to_mz;
>  	int nid, zid;
>  	int ret = -EBUSY;
> +	struct mem_cgroup_stat *stat;
> +	struct mem_cgroup_stat_cpu *cpustat;
> +	int cpu;
>  
>  	VM_BUG_ON(from == to);
>  	VM_BUG_ON(PageLRU(pc->page));
> @@ -1116,6 +1147,18 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  
>  	res_counter_uncharge(&from->res, PAGE_SIZE);
>  	mem_cgroup_charge_statistics(from, pc, false);
> +
> +	cpu = get_cpu();
> +	/* Update mapped_file data for mem_cgroup "from" */
> +	stat = &from->stat;
> +	cpustat = &stat->cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, -1);
> +
> +	/* Update mapped_file data for mem_cgroup "to" */
> +	stat = &to->stat;
> +	cpustat = &stat->cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, 1);
> +
here, too.

Seems no troubles in other parts.

Regards,
-Kame

>  	if (do_swap_account)
>  		res_counter_uncharge(&from->memsw, PAGE_SIZE);
>  	css_put(&from->css);
> @@ -2051,6 +2094,7 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
>  enum {
>  	MCS_CACHE,
>  	MCS_RSS,
> +	MCS_MAPPED_FILE,
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
>  	MCS_INACTIVE_ANON,
> @@ -2071,6 +2115,7 @@ struct {
>  } memcg_stat_strings[NR_MCS_STAT] = {
>  	{"cache", "total_cache"},
>  	{"rss", "total_rss"},
> +	{"mapped_file", "total_mapped_file"},
>  	{"pgpgin", "total_pgpgin"},
>  	{"pgpgout", "total_pgpgout"},
>  	{"inactive_anon", "total_inactive_anon"},
> @@ -2091,6 +2136,8 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
>  	s->stat[MCS_CACHE] += val * PAGE_SIZE;
>  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
>  	s->stat[MCS_RSS] += val * PAGE_SIZE;
> +	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_MAPPED_FILE);
> +	s->stat[MCS_MAPPED_FILE] += val * PAGE_SIZE;
>  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGIN_COUNT);
>  	s->stat[MCS_PGPGIN] += val;
>  	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);
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
> index 1652166..3e29864 100644
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
> +		mem_cgroup_update_mapped_file_stat(page, vma->vm_mm, 1);
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
> +		mem_cgroup_update_mapped_file_stat(page, vma->vm_mm, -1);
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
