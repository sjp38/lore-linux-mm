Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AD5CD440313
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 00:28:06 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so164148300pac.0
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 21:28:06 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id z10si37162443pas.74.2015.10.04.21.28.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 21:28:05 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so164147956pac.0
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 21:28:05 -0700 (PDT)
Date: Sun, 4 Oct 2015 21:28:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 3/4] mm, shmem: Add shmem resident memory accounting
In-Reply-To: <1443792951-13944-4-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.LSU.2.11.1510042124580.15067@eggly.anvils>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz> <1443792951-13944-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri, 2 Oct 2015, Vlastimil Babka wrote:

> From: Jerome Marchand <jmarchan@redhat.com>
> 
> Currently looking at /proc/<pid>/status or statm, there is no way to
> distinguish shmem pages from pages mapped to a regular file (shmem
> pages are mapped to /dev/zero), even though their implication in
> actual memory use is quite different.
> This patch adds MM_SHMEMPAGES counter to mm_rss_stat to account for
> shmem pages instead of MM_FILEPAGES.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Hugh Dickins <hughd@google.com>

Good, this one long overdue, I've grown tired for writing those if/elses.
I'd have probably have done without mm_counter_file(), but it's okay.

> ---
>  arch/s390/mm/pgtable.c   |  5 +----
>  fs/proc/task_mmu.c       |  3 ++-
>  include/linux/mm.h       | 18 +++++++++++++++++-
>  include/linux/mm_types.h |  7 ++++---
>  kernel/events/uprobes.c  |  2 +-
>  mm/memory.c              | 30 ++++++++++--------------------
>  mm/oom_kill.c            |  5 +++--
>  mm/rmap.c                | 12 +++---------
>  8 files changed, 41 insertions(+), 41 deletions(-)
> 
> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
> index 54ef3bc..9816f25 100644
> --- a/arch/s390/mm/pgtable.c
> +++ b/arch/s390/mm/pgtable.c
> @@ -603,10 +603,7 @@ static void gmap_zap_swap_entry(swp_entry_t entry, struct mm_struct *mm)
>  	else if (is_migration_entry(entry)) {
>  		struct page *page = migration_entry_to_page(entry);
>  
> -		if (PageAnon(page))
> -			dec_mm_counter(mm, MM_ANONPAGES);
> -		else
> -			dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter(page));
>  	}
>  	free_swap_and_cache(entry);
>  }
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 103457c..9b9708e 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -83,7 +83,8 @@ unsigned long task_statm(struct mm_struct *mm,
>  			 unsigned long *shared, unsigned long *text,
>  			 unsigned long *data, unsigned long *resident)
>  {
> -	*shared = get_mm_counter(mm, MM_FILEPAGES);
> +	*shared = get_mm_counter(mm, MM_FILEPAGES) +
> +			get_mm_counter(mm, MM_SHMEMPAGES);
>  	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
>  								>> PAGE_SHIFT;
>  	*data = mm->total_vm - mm->shared_vm;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index d30eea3..8be4efc 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1361,10 +1361,26 @@ static inline void dec_mm_counter(struct mm_struct *mm, int member)
>  	atomic_long_dec(&mm->rss_stat.count[member]);
>  }
>  
> +/* Optimized variant when page is already known not to be PageAnon */
> +static inline int mm_counter_file(struct page *page)
> +{
> +	if (PageSwapBacked(page))
> +		return MM_SHMEMPAGES;
> +	return MM_FILEPAGES;
> +}
> +
> +static inline int mm_counter(struct page *page)
> +{
> +	if (PageAnon(page))
> +		return MM_ANONPAGES;
> +	return mm_counter_file(page);
> +}
> +
>  static inline unsigned long get_mm_rss(struct mm_struct *mm)
>  {
>  	return get_mm_counter(mm, MM_FILEPAGES) +
> -		get_mm_counter(mm, MM_ANONPAGES);
> +		get_mm_counter(mm, MM_ANONPAGES) +
> +		get_mm_counter(mm, MM_SHMEMPAGES);
>  }
>  
>  static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index f8d1492..207890b 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -369,9 +369,10 @@ struct core_state {
>  };
>  
>  enum {
> -	MM_FILEPAGES,
> -	MM_ANONPAGES,
> -	MM_SWAPENTS,
> +	MM_FILEPAGES,	/* Resident file mapping pages */
> +	MM_ANONPAGES,	/* Resident anonymous pages */
> +	MM_SWAPENTS,	/* Anonymous swap entries */
> +	MM_SHMEMPAGES,	/* Resident shared memory pages */
>  	NR_MM_COUNTERS
>  };
>  
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 4e5e979..6288606 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -180,7 +180,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	lru_cache_add_active_or_unevictable(kpage, vma);
>  
>  	if (!PageAnon(page)) {
> -		dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter_file(page));
>  		inc_mm_counter(mm, MM_ANONPAGES);
>  	}
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 3bd465a..f10d458 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -832,10 +832,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  		} else if (is_migration_entry(entry)) {
>  			page = migration_entry_to_page(entry);
>  
> -			if (PageAnon(page))
> -				rss[MM_ANONPAGES]++;
> -			else
> -				rss[MM_FILEPAGES]++;
> +			rss[mm_counter(page)]++;
>  
>  			if (is_write_migration_entry(entry) &&
>  					is_cow_mapping(vm_flags)) {
> @@ -874,10 +871,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	if (page) {
>  		get_page(page);
>  		page_dup_rmap(page);
> -		if (PageAnon(page))
> -			rss[MM_ANONPAGES]++;
> -		else
> -			rss[MM_FILEPAGES]++;
> +		rss[mm_counter(page)]++;
>  	}
>  
>  out_set_pte:
> @@ -1113,9 +1107,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  			tlb_remove_tlb_entry(tlb, pte, addr);
>  			if (unlikely(!page))
>  				continue;
> -			if (PageAnon(page))
> -				rss[MM_ANONPAGES]--;
> -			else {
> +
> +			if (!PageAnon(page)) {
>  				if (pte_dirty(ptent)) {
>  					force_flush = 1;
>  					set_page_dirty(page);
> @@ -1123,8 +1116,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  				if (pte_young(ptent) &&
>  				    likely(!(vma->vm_flags & VM_SEQ_READ)))
>  					mark_page_accessed(page);
> -				rss[MM_FILEPAGES]--;
>  			}
> +			rss[mm_counter(page)]--;
>  			page_remove_rmap(page);
>  			if (unlikely(page_mapcount(page) < 0))
>  				print_bad_pte(vma, addr, ptent, page);
> @@ -1146,11 +1139,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  			struct page *page;
>  
>  			page = migration_entry_to_page(entry);
> -
> -			if (PageAnon(page))
> -				rss[MM_ANONPAGES]--;
> -			else
> -				rss[MM_FILEPAGES]--;
> +			rss[mm_counter(page)]--;
>  		}
>  		if (unlikely(!free_swap_and_cache(entry)))
>  			print_bad_pte(vma, addr, ptent, NULL);
> @@ -1460,7 +1449,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	/* Ok, finally just insert the thing.. */
>  	get_page(page);
> -	inc_mm_counter_fast(mm, MM_FILEPAGES);
> +	inc_mm_counter_fast(mm, mm_counter_file(page));
>  	page_add_file_rmap(page);
>  	set_pte_at(mm, addr, pte, mk_pte(page, prot));
>  
> @@ -2097,7 +2086,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (likely(pte_same(*page_table, orig_pte))) {
>  		if (old_page) {
>  			if (!PageAnon(old_page)) {
> -				dec_mm_counter_fast(mm, MM_FILEPAGES);
> +				dec_mm_counter_fast(mm,
> +						mm_counter_file(old_page));
>  				inc_mm_counter_fast(mm, MM_ANONPAGES);
>  			}
>  		} else {
> @@ -2818,7 +2808,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  		page_add_new_anon_rmap(page, vma, address);
>  	} else {
> -		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
> +		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
>  		page_add_file_rmap(page);
>  	}
>  	set_pte_at(vma->vm_mm, address, pte, entry);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4766e25..127e2d6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -567,10 +567,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	 */
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>  	mark_oom_victim(victim);
> -	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> +	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> -		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
> +		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> +		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
>  	task_unlock(victim);
>  
>  	/*
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0ce371a..6c89356 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1383,10 +1383,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		if (PageHuge(page)) {
>  			hugetlb_count_sub(1 << compound_order(page), mm);
>  		} else {
> -			if (PageAnon(page))
> -				dec_mm_counter(mm, MM_ANONPAGES);
> -			else
> -				dec_mm_counter(mm, MM_FILEPAGES);
> +			dec_mm_counter(mm, mm_counter(page));
>  		}
>  		set_pte_at(mm, address, pte,
>  			   swp_entry_to_pte(make_hwpoison_entry(page)));
> @@ -1396,10 +1393,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		 * interest anymore. Simply discard the pte, vmscan
>  		 * will take care of the rest.
>  		 */
> -		if (PageAnon(page))
> -			dec_mm_counter(mm, MM_ANONPAGES);
> -		else
> -			dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter(page));
>  	} else if (PageAnon(page)) {
>  		swp_entry_t entry = { .val = page_private(page) };
>  		pte_t swp_pte;
> @@ -1455,7 +1449,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		entry = make_migration_entry(page, pte_write(pteval));
>  		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>  	} else
> -		dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter_file(page));
>  
>  discard:
>  	page_remove_rmap(page);
> -- 
> 2.5.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
