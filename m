Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 058D46B00CC
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 12:46:29 -0400 (EDT)
Date: Wed, 12 Sep 2012 17:46:15 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Windows VM slow boot
Message-ID: <20120912164615.GA14173@alpha.arachsys.com>
References: <20120822124032.GA12647@alpha.arachsys.com>
 <5034D437.8070106@redhat.com>
 <20120822144150.GA1400@alpha.arachsys.com>
 <5034F8F4.3080301@redhat.com>
 <20120825174550.GA8619@alpha.arachsys.com>
 <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912122541.GO11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

Hi Mel - thanks for replying to my underhand bcc!

Mel Gorman wrote:
> I see that this is an old-ish bug but I did not read the full history.
> Is it now booting faster than 3.5.0 was? I'm asking because I'm
> interested to see if commit c67fe375 helped your particular case.

Yes, I think 3.6.0-rc5 is already better than 3.5.x but can still be
improved, as discussed.

> A follow-on from commit c67fe375 was the following patch (author cc'd)
> which addresses lock contention in isolate_migratepages_range where your
> perf report indicates that we're spending 95% of the time. Would you be
> willing to test it please?
>
> ---8<---
> From: Shaohua Li <shli@kernel.org>
> Subject: mm: compaction: check lock contention first before taking lock
>
> isolate_migratepages_range will take zone->lru_lock first and check if the
> lock is contented, if yes, it will release the lock.  This isn't
> efficient.  If the lock is truly contented, a lock/unlock pair will
> increase the lock contention.  We'd better check if the lock is contended
> first.  compact_trylock_irqsave perfectly meets the requirement.
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/compaction.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff -puN mm/compaction.c~mm-compaction-check-lock-contention-first-before-taking-lock mm/compaction.c
> --- a/mm/compaction.c~mm-compaction-check-lock-contention-first-before-taking-lock
> +++ a/mm/compaction.c
> @@ -349,8 +349,9 @@ isolate_migratepages_range(struct zone *
> 
>  	/* Time to isolate some pages for migration */
>  	cond_resched();
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	locked = true;
> +	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
> +	if (!locked)
> +		return 0;
>  	for (; low_pfn < end_pfn; low_pfn++) {
>  		struct page *page;

I have applied and tested again - perf results below.

isolate_migratepages_range is indeed much reduced.

There is now a lot of time in isolate_freepages_block and still quite a lot
of lock contention, although in a different place.


# ========
# captured on: Wed Sep 12 16:00:52 2012
# os release : 3.6.0-rc5-elastic+
# perf version : 3.5.2
# arch : x86_64
# nrcpus online : 16
# nrcpus avail : 16
# cpudesc : AMD Opteron(tm) Processor 6128
# cpuid : AuthenticAMD,16,9,1
# total memory : 131973280 kB
# cmdline : /home/root/bin/perf record -g -a 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# HEADER_NUMA_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 1M of event 'cycles'
# Event count (approx.): 560365005583
#
# Overhead          Command         Shared Object                                          Symbol
# ........  ...............  ....................  ..............................................
#
    43.95%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block                   
                   |
                   --- isolate_freepages_block
                      |          
                      |--99.99%-- compaction_alloc
                      |          migrate_pages
                      |          compact_zone
                      |          compact_zone_order
                      |          try_to_compact_pages
                      |          __alloc_pages_direct_compact
                      |          __alloc_pages_nodemask
                      |          alloc_pages_vma
                      |          do_huge_pmd_anonymous_page
                      |          handle_mm_fault
                      |          __get_user_pages
                      |          get_user_page_nowait
                      |          hva_to_pfn.isra.17
                      |          __gfn_to_pfn
                      |          gfn_to_pfn_async
                      |          try_async_pf
                      |          tdp_page_fault
                      |          kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--95.17%-- 0x10100000006
                      |          |          
                      |           --4.83%-- 0x10100000002
                       --0.01%-- [...]
    15.98%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave                    
                   |
                   --- _raw_spin_lock_irqsave
                      |          
                      |--97.18%-- compact_checklock_irqsave
                      |          |          
                      |          |--98.61%-- compaction_alloc
                      |          |          migrate_pages
                      |          |          compact_zone
                      |          |          compact_zone_order
                      |          |          try_to_compact_pages
                      |          |          __alloc_pages_direct_compact
                      |          |          __alloc_pages_nodemask
                      |          |          alloc_pages_vma
                      |          |          do_huge_pmd_anonymous_page
                      |          |          handle_mm_fault
                      |          |          __get_user_pages
                      |          |          get_user_page_nowait
                      |          |          hva_to_pfn.isra.17
                      |          |          __gfn_to_pfn
                      |          |          gfn_to_pfn_async
                      |          |          try_async_pf
                      |          |          tdp_page_fault
                      |          |          kvm_mmu_page_fault
                      |          |          pf_interception
                      |          |          handle_exit
                      |          |          kvm_arch_vcpu_ioctl_run
                      |          |          kvm_vcpu_ioctl
                      |          |          do_vfs_ioctl
                      |          |          sys_ioctl
                      |          |          system_call_fastpath
                      |          |          ioctl
                      |          |          |          
                      |          |          |--94.94%-- 0x10100000006
                      |          |          |          
                      |          |           --5.06%-- 0x10100000002
                      |          |          
                      |           --1.39%-- isolate_migratepages_range
                      |                     compact_zone
                      |                     compact_zone_order
                      |                     try_to_compact_pages
                      |                     __alloc_pages_direct_compact
                      |                     __alloc_pages_nodemask
                      |                     alloc_pages_vma
                      |                     do_huge_pmd_anonymous_page
                      |                     handle_mm_fault
                      |                     __get_user_pages
                      |                     get_user_page_nowait
                      |                     hva_to_pfn.isra.17
                      |                     __gfn_to_pfn
                      |                     gfn_to_pfn_async
                      |                     try_async_pf
                      |                     tdp_page_fault
                      |                     kvm_mmu_page_fault
                      |                     pf_interception
                      |                     handle_exit
                      |                     kvm_arch_vcpu_ioctl_run
                      |                     kvm_vcpu_ioctl
                      |                     do_vfs_ioctl
                      |                     sys_ioctl
                      |                     system_call_fastpath
                      |                     ioctl
                      |                     |          
                      |                     |--95.04%-- 0x10100000006
                      |                     |          
                      |                      --4.96%-- 0x10100000002
                      |          
                      |--1.94%-- compaction_alloc
                      |          migrate_pages
                      |          compact_zone
                      |          compact_zone_order
                      |          try_to_compact_pages
                      |          __alloc_pages_direct_compact
                      |          __alloc_pages_nodemask
                      |          alloc_pages_vma
                      |          do_huge_pmd_anonymous_page
                      |          handle_mm_fault
                      |          __get_user_pages
                      |          get_user_page_nowait
                      |          hva_to_pfn.isra.17
                      |          __gfn_to_pfn
                      |          gfn_to_pfn_async
                      |          try_async_pf
                      |          tdp_page_fault
                      |          kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--95.19%-- 0x10100000006
                      |          |          
                      |           --4.81%-- 0x10100000002
                       --0.88%-- [...]
     5.73%             ksmd  [kernel.kallsyms]     [k] memcmp                                    
                       |
                       --- memcmp
                          |          
                          |--99.79%-- memcmp_pages
                          |          |          
                          |          |--81.64%-- ksm_scan_thread
                          |          |          kthread
                          |          |          kernel_thread_helper
                          |          |          
                          |           --18.36%-- try_to_merge_with_ksm_page
                          |                     ksm_scan_thread
                          |                     kthread
                          |                     kernel_thread_helper
                           --0.21%-- [...]
     5.52%          swapper  [kernel.kallsyms]     [k] default_idle                              
                    |
                    --- default_idle
                       |          
                       |--99.51%-- cpu_idle
                       |          |          
                       |          |--86.19%-- start_secondary
                       |          |          
                       |           --13.81%-- rest_init
                       |                     start_kernel
                       |                     x86_64_start_reservations
                       |                     x86_64_start_kernel
                        --0.49%-- [...]
     2.90%         qemu-kvm  [kernel.kallsyms]     [k] yield_to                                  
                   |
                   --- yield_to
                      |          
                      |--99.70%-- kvm_vcpu_yield_to
                      |          kvm_vcpu_on_spin
                      |          pause_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--96.09%-- 0x10100000006
                      |          |          
                      |           --3.91%-- 0x10100000002
                       --0.30%-- [...]
     1.86%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                              
                   |
                   --- clear_page_c
                      |          
                      |--99.15%-- do_huge_pmd_anonymous_page
                      |          handle_mm_fault
                      |          __get_user_pages
                      |          get_user_page_nowait
                      |          hva_to_pfn.isra.17
                      |          __gfn_to_pfn
                      |          gfn_to_pfn_async
                      |          try_async_pf
                      |          tdp_page_fault
                      |          kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--96.03%-- 0x10100000006
                      |          |          
                      |           --3.97%-- 0x10100000002
                      |          
                       --0.85%-- __alloc_pages_nodemask
                                 |          
                                 |--78.22%-- alloc_pages_vma
                                 |          handle_pte_fault
                                 |          |          
                                 |          |--99.76%-- handle_mm_fault
                                 |          |          __get_user_pages
                                 |          |          get_user_page_nowait
                                 |          |          hva_to_pfn.isra.17
                                 |          |          __gfn_to_pfn
                                 |          |          gfn_to_pfn_async
                                 |          |          try_async_pf
                                 |          |          tdp_page_fault
                                 |          |          kvm_mmu_page_fault
                                 |          |          pf_interception
                                 |          |          handle_exit
                                 |          |          kvm_arch_vcpu_ioctl_run
                                 |          |          kvm_vcpu_ioctl
                                 |          |          do_vfs_ioctl
                                 |          |          sys_ioctl
                                 |          |          system_call_fastpath
                                 |          |          ioctl
                                 |          |          |          
                                 |          |          |--91.60%-- 0x10100000006
                                 |          |          |          
                                 |          |           --8.40%-- 0x10100000002
                                 |           --0.24%-- [...]
                                 |          
                                  --21.78%-- alloc_pages_current
                                            pte_alloc_one
                                            |          
                                            |--97.40%-- do_huge_pmd_anonymous_page
                                            |          handle_mm_fault
                                            |          __get_user_pages
                                            |          get_user_page_nowait
                                            |          hva_to_pfn.isra.17
                                            |          __gfn_to_pfn
                                            |          gfn_to_pfn_async
                                            |          try_async_pf
                                            |          tdp_page_fault
                                            |          kvm_mmu_page_fault
                                            |          pf_interception
                                            |          handle_exit
                                            |          kvm_arch_vcpu_ioctl_run
                                            |          kvm_vcpu_ioctl
                                            |          do_vfs_ioctl
                                            |          sys_ioctl
                                            |          system_call_fastpath
                                            |          ioctl
                                            |          |          
                                            |          |--93.12%-- 0x10100000006
                                            |          |          
                                            |           --6.88%-- 0x10100000002
                                            |          
                                             --2.60%-- __pte_alloc
                                                       do_huge_pmd_anonymous_page
                                                       handle_mm_fault
                                                       __get_user_pages
                                                       get_user_page_nowait
                                                       hva_to_pfn.isra.17
                                                       __gfn_to_pfn
                                                       gfn_to_pfn_async
                                                       try_async_pf
                                                       tdp_page_fault
                                                       kvm_mmu_page_fault
                                                       pf_interception
                                                       handle_exit
                                                       kvm_arch_vcpu_ioctl_run
                                                       kvm_vcpu_ioctl
                                                       do_vfs_ioctl
                                                       sys_ioctl
                                                       system_call_fastpath
                                                       ioctl
                                                       0x10100000006
     1.83%         qemu-kvm  [kernel.kallsyms]     [k] get_pageblock_flags_group                 
                   |
                   --- get_pageblock_flags_group
                      |          
                      |--51.38%-- isolate_migratepages_range
                      |          compact_zone
                      |          compact_zone_order
                      |          try_to_compact_pages
                      |          __alloc_pages_direct_compact
                      |          __alloc_pages_nodemask
                      |          alloc_pages_vma
                      |          do_huge_pmd_anonymous_page
                      |          handle_mm_fault
                      |          __get_user_pages
                      |          get_user_page_nowait
                      |          hva_to_pfn.isra.17
                      |          __gfn_to_pfn
                      |          gfn_to_pfn_async
                      |          try_async_pf
                      |          tdp_page_fault
                      |          kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--95.32%-- 0x10100000006
                      |          |          
                      |           --4.68%-- 0x10100000002
                      |          
                      |--43.05%-- suitable_migration_target
                      |          compaction_alloc
                      |          migrate_pages
                      |          compact_zone
                      |          compact_zone_order
                      |          try_to_compact_pages
                      |          __alloc_pages_direct_compact
                      |          __alloc_pages_nodemask
                      |          alloc_pages_vma
                      |          do_huge_pmd_anonymous_page
                      |          handle_mm_fault
                      |          __get_user_pages
                      |          get_user_page_nowait
                      |          hva_to_pfn.isra.17
                      |          __gfn_to_pfn
                      |          gfn_to_pfn_async
                      |          try_async_pf
                      |          tdp_page_fault
                      |          kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--95.52%-- 0x10100000006
                      |          |          
                      |           --4.48%-- 0x10100000002
                      |          
                      |--3.62%-- compact_zone
                      |          compact_zone_order
                      |          try_to_compact_pages
                      |          __alloc_pages_direct_compact
                      |          __alloc_pages_nodemask
                      |          alloc_pages_vma
                      |          do_huge_pmd_anonymous_page
                      |          handle_mm_fault
                      |          __get_user_pages
                      |          get_user_page_nowait
                      |          hva_to_pfn.isra.17
                      |          __gfn_to_pfn
                      |          gfn_to_pfn_async
                      |          try_async_pf
                      |          tdp_page_fault
                      |          kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--96.78%-- 0x10100000006
                      |          |          
                      |           --3.22%-- 0x10100000002
                      |          
                      |--1.20%-- compaction_alloc
                      |          migrate_pages
                      |          compact_zone
                      |          compact_zone_order
                      |          try_to_compact_pages
                      |          __alloc_pages_direct_compact
                      |          __alloc_pages_nodemask
                      |          alloc_pages_vma
                      |          do_huge_pmd_anonymous_page
                      |          handle_mm_fault
                      |          __get_user_pages
                      |          get_user_page_nowait
                      |          hva_to_pfn.isra.17
                      |          __gfn_to_pfn
                      |          gfn_to_pfn_async
                      |          try_async_pf
                      |          tdp_page_fault
                      |          kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--96.33%-- 0x10100000006
                      |          |          
                      |           --3.67%-- 0x10100000002
                      |          
                      |--0.61%-- free_hot_cold_page
                      |          |          
                      |          |--77.99%-- free_hot_cold_page_list
                      |          |          |          
                      |          |          |--95.93%-- release_pages
                      |          |          |          pagevec_lru_move_fn
                      |          |          |          __pagevec_lru_add
                      |          |          |          |          
                      |          |          |          |--98.44%-- __lru_cache_add
                      |          |          |          |          lru_cache_add_lru
                      |          |          |          |          putback_lru_page
                      |          |          |          |          migrate_pages
                      |          |          |          |          compact_zone
                      |          |          |          |          compact_zone_order
                      |          |          |          |          try_to_compact_pages
                      |          |          |          |          __alloc_pages_direct_compact
                      |          |          |          |          __alloc_pages_nodemask
                      |          |          |          |          alloc_pages_vma
                      |          |          |          |          do_huge_pmd_anonymous_page
                      |          |          |          |          handle_mm_fault
                      |          |          |          |          __get_user_pages
                      |          |          |          |          get_user_page_nowait
                      |          |          |          |          hva_to_pfn.isra.17
                      |          |          |          |          __gfn_to_pfn
                      |          |          |          |          gfn_to_pfn_async
                      |          |          |          |          try_async_pf
                      |          |          |          |          tdp_page_fault
                      |          |          |          |          kvm_mmu_page_fault
                      |          |          |          |          pf_interception
                      |          |          |          |          handle_exit
                      |          |          |          |          kvm_arch_vcpu_ioctl_run
                      |          |          |          |          kvm_vcpu_ioctl
                      |          |          |          |          do_vfs_ioctl
                      |          |          |          |          sys_ioctl
                      |          |          |          |          system_call_fastpath
                      |          |          |          |          ioctl
                      |          |          |          |          |          
                      |          |          |          |          |--96.77%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --3.23%-- 0x10100000002
                      |          |          |          |          
                      |          |          |           --1.56%-- lru_add_drain_cpu
                      |          |          |                     lru_add_drain
                      |          |          |                     migrate_prep_local
                      |          |          |                     compact_zone
                      |          |          |                     compact_zone_order
                      |          |          |                     try_to_compact_pages
                      |          |          |                     __alloc_pages_direct_compact
                      |          |          |                     __alloc_pages_nodemask
                      |          |          |                     alloc_pages_vma
                      |          |          |                     do_huge_pmd_anonymous_page
                      |          |          |                     handle_mm_fault
                      |          |          |                     __get_user_pages
                      |          |          |                     get_user_page_nowait
                      |          |          |                     hva_to_pfn.isra.17
                      |          |          |                     __gfn_to_pfn
                      |          |          |                     gfn_to_pfn_async
                      |          |          |                     try_async_pf
                      |          |          |                     tdp_page_fault
                      |          |          |                     kvm_mmu_page_fault
                      |          |          |                     pf_interception
                      |          |          |                     handle_exit
                      |          |          |                     kvm_arch_vcpu_ioctl_run
                      |          |          |                     kvm_vcpu_ioctl
                      |          |          |                     do_vfs_ioctl
                      |          |          |                     sys_ioctl
                      |          |          |                     system_call_fastpath
                      |          |          |                     ioctl
                      |          |          |                     0x10100000006
                      |          |          |          
                      |          |           --4.07%-- shrink_page_list
                      |          |                     shrink_inactive_list
                      |          |                     shrink_lruvec
                      |          |                     try_to_free_pages
                      |          |                     __alloc_pages_nodemask
                      |          |                     alloc_pages_vma
                      |          |                     do_huge_pmd_anonymous_page
                      |          |                     handle_mm_fault
                      |          |                     __get_user_pages
                      |          |                     get_user_page_nowait
                      |          |                     hva_to_pfn.isra.17
                      |          |                     __gfn_to_pfn
                      |          |                     gfn_to_pfn_async
                      |          |                     try_async_pf
                      |          |                     tdp_page_fault
                      |          |                     kvm_mmu_page_fault
                      |          |                     pf_interception
                      |          |                     handle_exit
                      |          |                     kvm_arch_vcpu_ioctl_run
                      |          |                     kvm_vcpu_ioctl
                      |          |                     do_vfs_ioctl
                      |          |                     sys_ioctl
                      |          |                     system_call_fastpath
                      |          |                     ioctl
                      |          |                     0x10100000006
                      |          |          
                      |          |--19.40%-- __free_pages
                      |          |          |          
                      |          |          |--85.71%-- release_freepages
                      |          |          |          compact_zone
                      |          |          |          compact_zone_order
                      |          |          |          try_to_compact_pages
                      |          |          |          __alloc_pages_direct_compact
                      |          |          |          __alloc_pages_nodemask
                      |          |          |          alloc_pages_vma
                      |          |          |          do_huge_pmd_anonymous_page
                      |          |          |          handle_mm_fault
                      |          |          |          __get_user_pages
                      |          |          |          get_user_page_nowait
                      |          |          |          hva_to_pfn.isra.17
                      |          |          |          __gfn_to_pfn
                      |          |          |          gfn_to_pfn_async
                      |          |          |          try_async_pf
                      |          |          |          tdp_page_fault
                      |          |          |          kvm_mmu_page_fault
                      |          |          |          pf_interception
                      |          |          |          handle_exit
                      |          |          |          kvm_arch_vcpu_ioctl_run
                      |          |          |          kvm_vcpu_ioctl
                      |          |          |          do_vfs_ioctl
                      |          |          |          sys_ioctl
                      |          |          |          system_call_fastpath
                      |          |          |          ioctl
                      |          |          |          |          
                      |          |          |          |--90.47%-- 0x10100000006
                      |          |          |          |          
                      |          |          |           --9.53%-- 0x10100000002
                      |          |          |          
                      |          |          |--10.21%-- do_huge_pmd_anonymous_page
                      |          |          |          handle_mm_fault
                      |          |          |          __get_user_pages
                      |          |          |          get_user_page_nowait
                      |          |          |          hva_to_pfn.isra.17
                      |          |          |          __gfn_to_pfn
                      |          |          |          gfn_to_pfn_async
                      |          |          |          try_async_pf
                      |          |          |          tdp_page_fault
                      |          |          |          kvm_mmu_page_fault
                      |          |          |          pf_interception
                      |          |          |          handle_exit
                      |          |          |          kvm_arch_vcpu_ioctl_run
                      |          |          |          kvm_vcpu_ioctl
                      |          |          |          do_vfs_ioctl
                      |          |          |          sys_ioctl
                      |          |          |          system_call_fastpath
                      |          |          |          ioctl
                      |          |          |          0x10100000006
                      |          |          |          
                      |          |           --4.08%-- __free_slab
                      |          |                     discard_slab
                      |          |                     __slab_free
                      |          |                     kmem_cache_free
                      |          |                     free_buffer_head
                      |          |                     try_to_free_buffers
                      |          |                     jbd2_journal_try_to_free_buffers
                      |          |                     bdev_try_to_free_page
                      |          |                     blkdev_releasepage
                      |          |                     try_to_release_page
                      |          |                     move_to_new_page
                      |          |                     migrate_pages
                      |          |                     compact_zone
                      |          |                     compact_zone_order
                      |          |                     try_to_compact_pages
                      |          |                     __alloc_pages_direct_compact
                      |          |                     __alloc_pages_nodemask
                      |          |                     alloc_pages_vma
                      |          |                     do_huge_pmd_anonymous_page
                      |          |                     handle_mm_fault
                      |          |                     __get_user_pages
                      |          |                     get_user_page_nowait
                      |          |                     hva_to_pfn.isra.17
                      |          |                     __gfn_to_pfn
                      |          |                     gfn_to_pfn_async
                      |          |                     try_async_pf
                      |          |                     tdp_page_fault
                      |          |                     kvm_mmu_page_fault
                      |          |                     pf_interception
                      |          |                     handle_exit
                      |          |                     kvm_arch_vcpu_ioctl_run
                      |          |                     kvm_vcpu_ioctl
                      |          |                     do_vfs_ioctl
                      |          |                     sys_ioctl
                      |          |                     system_call_fastpath
                      |          |                     ioctl
                      |          |                     0x10100000006
                      |          |          
                      |           --2.61%-- __put_single_page
                      |                     put_page
                      |                     |          
                      |                     |--91.27%-- putback_lru_page
                      |                     |          migrate_pages
                      |                     |          compact_zone
                      |                     |          compact_zone_order
                      |                     |          try_to_compact_pages
                      |                     |          __alloc_pages_direct_compact
                      |                     |          __alloc_pages_nodemask
                      |                     |          alloc_pages_vma
                      |                     |          do_huge_pmd_anonymous_page
                      |                     |          handle_mm_fault
                      |                     |          __get_user_pages
                      |                     |          get_user_page_nowait
                      |                     |          hva_to_pfn.isra.17
                      |                     |          __gfn_to_pfn
                      |                     |          gfn_to_pfn_async
                      |                     |          try_async_pf
                      |                     |          tdp_page_fault
                      |                     |          kvm_mmu_page_fault
                      |                     |          pf_interception
                      |                     |          handle_exit
                      |                     |          kvm_arch_vcpu_ioctl_run
                      |                     |          kvm_vcpu_ioctl
                      |                     |          do_vfs_ioctl
                      |                     |          sys_ioctl
                      |                     |          system_call_fastpath
                      |                     |          ioctl
                      |                     |          0x10100000006
                      |                     |          
                      |                      --8.73%-- skb_free_head.part.34
                      |                                skb_release_data
                      |                                __kfree_skb
                      |                                tcp_recvmsg
                      |                                inet_recvmsg
                      |                                sock_recvmsg
                      |                                sys_recvfrom
                      |                                system_call_fastpath
                      |                                recv
                      |                                0x0
                       --0.14%-- [...]
     1.54%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run                              
                   |
                   --- svm_vcpu_run
                      |          
                      |--99.52%-- kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--94.70%-- 0x10100000006
                      |          |          
                      |           --5.30%-- 0x10100000002
                       --0.48%-- [...]
     1.30%         qemu-kvm  [kernel.kallsyms]     [k] kvm_vcpu_on_spin                          
                   |
                   --- kvm_vcpu_on_spin
                      |          
                      |--99.45%-- pause_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--96.06%-- 0x10100000006
                      |          |          
                      |           --3.94%-- 0x10100000002
                      |          
                       --0.55%-- handle_exit
                                 kvm_arch_vcpu_ioctl_run
                                 kvm_vcpu_ioctl
                                 do_vfs_ioctl
                                 sys_ioctl
                                 system_call_fastpath
                                 ioctl
                                 |          
                                 |--97.59%-- 0x10100000006
                                 |          
                                  --2.41%-- 0x10100000002
     1.00%         qemu-kvm  qemu-kvm              [.] 0x0000000000254bc2                        
                   |          
                   |--1.63%-- 0x4eec20
                   |          |          
                   |          |--47.60%-- 0x2274280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--26.98%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --25.42%-- 0x16b5280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--1.63%-- 0x4eec6e
                   |          |          
                   |          |--52.41%-- 0x2274280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--38.99%-- 0x16b5280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --8.60%-- 0x309c280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--1.44%-- 0x5b4cb4
                   |          0x0
                   |          |          
                   |           --100.00%-- 0x822ee8fff96873e9
                   |          
                   |--1.32%-- 0x503457
                   |          0x0
                   |          
                   |--1.30%-- 0x65a186
                   |          0x0
                   |          
                   |--1.22%-- 0x541422
                   |          0x0
                   |          
                   |--1.08%-- 0x568f04
                   |          |          
                   |          |--93.81%-- 0x0
                   |          |          
                   |          |--6.01%-- 0x10100000006
                   |           --0.19%-- [...]
                   |          
                   |--1.06%-- 0x56a08e
                   |          |          
                   |          |--55.97%-- 0x2fa1410
                   |          |          0x0
                   |          |          
                   |          |--24.12%-- 0x2179410
                   |          |          0x0
                   |          |          
                   |           --19.92%-- 0x15ba410
                   |                     0x0
                   |          
                   |--1.05%-- 0x4eeeac
                   |          |          
                   |          |--66.23%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--19.06%-- 0x16b5280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --14.71%-- 0x2274280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--1.01%-- 0x6578d7
                   |          |          
                   |           --100.00%-- 0x0
                   |          
                   |--0.96%-- 0x52fb44
                   |          |          
                   |          |--91.88%-- 0x0
                   |          |          
                   |           --8.12%-- 0x10100000006
                   |          
                   |--0.95%-- 0x65a102
                   |          
                   |--0.94%-- 0x541aac
                   |          0x0
                   |          
                   |--0.93%-- 0x525261
                   |          0x0
                   |          |          
                   |           --100.00%-- 0x822ee8fff96873e9
                   |          
                   |--0.89%-- 0x540e24
                   |          
                   |--0.88%-- 0x477a32
                   |          0x0
                   |          
                   |--0.87%-- 0x4eee03
                   |          |          
                   |          |--47.23%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--32.15%-- 0x2274280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --20.62%-- 0x16b5280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.84%-- 0x530421
                   |          |          
                   |           --100.00%-- 0x0
                   |          
                   |--0.83%-- 0x4eeb52
                   |          
                   |--0.82%-- 0x40a6a9
                   |          
                   |--0.79%-- 0x672601
                   |          0x1
                   |          
                   |--0.78%-- 0x564e00
                   |          |          
                   |           --100.00%-- 0x0
                   |          
                   |--0.78%-- 0x568e38
                   |          |          
                   |          |--95.83%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--2.15%-- 0x10100000006
                   |          |          
                   |           --2.02%-- 0x16b5280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.74%-- 0x56e704
                   |          |          
                   |          |--47.84%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--38.61%-- 0x16b5280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--10.72%-- 0x2274280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --2.83%-- 0x10100000006
                   |          
                   |--0.73%-- 0x5308c3
                   |          
                   |--0.72%-- 0x654b22
                   |          0x0
                   |          
                   |--0.71%-- 0x530094
                   |          
                   |--0.71%-- 0x564e04
                   |          |          
                   |          |--87.21%-- 0x0
                   |          |          
                   |          |--12.59%-- 0x46b47b
                   |          |          0xdffebc0000a88169
                   |           --0.20%-- [...]
                   |          
                   |--0.71%-- 0x568e5f
                   |          |          
                   |          |--98.58%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --1.42%-- 0x16b5280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.70%-- 0x4ef092
                   |          
                   |--0.70%-- 0x52fac2
                   |          |          
                   |          |--99.12%-- 0x0
                   |          |          
                   |           --0.88%-- 0x10100000006
                   |          
                   |--0.68%-- 0x541ac1
                   |          
                   |--0.66%-- 0x4eec22
                   |          |          
                   |          |--44.90%-- 0x16b5280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--30.11%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --25.00%-- 0x2274280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.65%-- 0x5afab4
                   |          |          
                   |          |--48.10%-- 0x2179410
                   |          |          0x0
                   |          |          
                   |          |--41.94%-- 0x15ba410
                   |          |          0x0
                   |          |          
                   |          |--5.05%-- 0x0
                   |          |          |          
                   |          |          |--39.43%-- 0x3099550
                   |          |          |          0x5699c0
                   |          |          |          0x24448948004b4154
                   |          |          |          
                   |          |          |--35.76%-- 0x23c0e90
                   |          |          |          0x5699c0
                   |          |          |          0x24448948004b4154
                   |          |          |          
                   |          |           --24.81%-- 0x16b2130
                   |          |                     0x5699c0
                   |          |                     0x24448948004b4154
                   |          |          
                   |          |--4.00%-- 0x2fa1410
                   |          |          0x0
                   |          |          
                   |           --0.92%-- 0x6
                   |          
                   |--0.63%-- 0x65a3f6
                   |          0x1
                   |          
                   |--0.63%-- 0x659d12
                   |          0x0
                   |          
                   |--0.62%-- 0x530764
                   |          0x0
                   |          
                   |--0.62%-- 0x46e803
                   |          0x46b47b
                   |          |          
                   |          |--72.15%-- 0xdffebc0000a88169
                   |          |          
                   |          |--16.88%-- 0xdffebec000a08169
                   |          |          
                   |           --10.97%-- 0xdffeb1d000a88169
                   |          
                   |--0.61%-- 0x4eeba0
                   |          |          
                   |          |--45.41%-- 0x309c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--36.19%-- 0x16b5280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --18.40%-- 0x2274280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.60%-- 0x659d61
                   |          
                   |--0.60%-- 0x4ff496
                   |          
                   |--0.59%-- 0x5030db
                   |          
                   |--0.58%-- 0x477822
                   |          

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
