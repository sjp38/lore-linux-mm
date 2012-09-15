Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 721546B005D
	for <linux-mm@kvack.org>; Sat, 15 Sep 2012 11:55:36 -0400 (EDT)
Date: Sat, 15 Sep 2012 16:55:24 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
Message-ID: <20120915155524.GA24182@alpha.arachsys.com>
References: <5034F8F4.3080301@redhat.com>
 <20120825174550.GA8619@alpha.arachsys.com>
 <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
 <20120912164615.GA14173@alpha.arachsys.com>
 <20120913154824.44cc0e28@cuia.bos.redhat.com>
 <20120913155450.7634148f@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913155450.7634148f@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

Hi Rik, Mel and Shaohua,

Thank you for your latest patches. I attach my latest perf report for a slow
boot with all of these applied.

Mel asked for timings of the slow boots. It's very hard to give anything
useful here! A normal boot would be a minute or so, and many are like that,
but the slowest that I have seen (on 3.5.x) was several hours. Basically, I
just test many times until I get one which is noticeably slow than normal
and then run perf record on that one.

The latest perf report for a slow boot is below. For the fast boots, most of
the time is in clean_page_c in do_huge_pmd_anonymous_page, but for this slow
one there is a lot of lock contention above that.

Thanks,

Richard.


# ========
# captured on: Sat Sep 15 15:40:54 2012
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
# Samples: 3M of event 'cycles'
# Event count (approx.): 1457256240581
#
# Overhead          Command         Shared Object                                          Symbol
# ........  ...............  ....................  ..............................................
#
    58.49%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave                    
                   |
                   --- _raw_spin_lock_irqsave
                      |          
                      |--95.07%-- compact_checklock_irqsave
                      |          |          
                      |          |--70.03%-- isolate_migratepages_range
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
                      |          |          |--92.76%-- 0x10100000006
                      |          |          |          
                      |          |           --7.24%-- 0x10100000002
                      |          |          
                      |           --29.97%-- compaction_alloc
                      |                     migrate_pages
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
                      |                     |--90.69%-- 0x10100000006
                      |                     |          
                      |                      --9.31%-- 0x10100000002
                      |          
                      |--4.53%-- isolate_migratepages_range
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
                      |          |--92.22%-- 0x10100000006
                      |          |          
                      |           --7.78%-- 0x10100000002
                       --0.40%-- [...]
    13.14%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                              
                   |
                   --- clear_page_c
                      |          
                      |--99.38%-- do_huge_pmd_anonymous_page
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
                      |          |--51.86%-- 0x10100000006
                      |          |          
                      |          |--48.14%-- 0x10100000002
                      |           --0.01%-- [...]
                      |          
                       --0.62%-- __alloc_pages_nodemask
                                 |          
                                 |--76.27%-- alloc_pages_vma
                                 |          handle_pte_fault
                                 |          |          
                                 |          |--99.57%-- handle_mm_fault
                                 |          |          |          
                                 |          |          |--99.65%-- __get_user_pages
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
                                 |          |          |          |--91.77%-- 0x10100000006
                                 |          |          |          |          
                                 |          |          |           --8.23%-- 0x10100000002
                                 |          |           --0.35%-- [...]
                                 |           --0.43%-- [...]
                                 |          
                                  --23.73%-- alloc_pages_current
                                            |          
                                            |--99.20%-- pte_alloc_one
                                            |          |          
                                            |          |--98.68%-- do_huge_pmd_anonymous_page
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
                                            |          |          |--58.61%-- 0x10100000002
                                            |          |          |          
                                            |          |           --41.39%-- 0x10100000006
                                            |          |          
                                            |           --1.32%-- __pte_alloc
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
                                            |                     0x10100000006
                                            |          
                                            |--0.69%-- __vmalloc_node_range
                                            |          __vmalloc_node
                                            |          vzalloc
                                            |          __kvm_set_memory_region
                                            |          kvm_set_memory_region
                                            |          kvm_vm_ioctl_set_memory_region
                                            |          kvm_vm_ioctl
                                            |          do_vfs_ioctl
                                            |          sys_ioctl
                                            |          system_call_fastpath
                                            |          ioctl
                                             --0.12%-- [...]
     6.31%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block                   
                   |
                   --- isolate_freepages_block
                      |          
                      |--99.98%-- compaction_alloc
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
                      |          |--91.13%-- 0x10100000006
                      |          |          
                      |           --8.87%-- 0x10100000002
                       --0.02%-- [...]
     1.68%         qemu-kvm  [kernel.kallsyms]     [k] yield_to                                  
                   |
                   --- yield_to
                      |          
                      |--99.65%-- kvm_vcpu_yield_to
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
                      |          |--88.78%-- 0x10100000006
                      |          |          
                      |           --11.22%-- 0x10100000002
                       --0.35%-- [...]
     1.24%             ksmd  [kernel.kallsyms]     [k] memcmp                                    
                       |
                       --- memcmp
                          |          
                          |--99.78%-- memcmp_pages
                          |          |          
                          |          |--77.17%-- ksm_scan_thread
                          |          |          kthread
                          |          |          kernel_thread_helper
                          |          |          
                          |           --22.83%-- try_to_merge_with_ksm_page
                          |                     ksm_scan_thread
                          |                     kthread
                          |                     kernel_thread_helper
                           --0.22%-- [...]
     1.09%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run                              
                   |
                   --- svm_vcpu_run
                      |          
                      |--99.44%-- kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--82.15%-- 0x10100000006
                      |          |          
                      |          |--17.85%-- 0x10100000002
                      |           --0.00%-- [...]
                      |          
                       --0.56%-- kvm_vcpu_ioctl
                                 do_vfs_ioctl
                                 sys_ioctl
                                 system_call_fastpath
                                 ioctl
                                 |          
                                 |--75.21%-- 0x10100000006
                                 |          
                                  --24.79%-- 0x10100000002
     1.09%          swapper  [kernel.kallsyms]     [k] default_idle                              
                    |
                    --- default_idle
                       |          
                       |--99.74%-- cpu_idle
                       |          |          
                       |          |--76.31%-- start_secondary
                       |          |          
                       |           --23.69%-- rest_init
                       |                     start_kernel
                       |                     x86_64_start_reservations
                       |                     x86_64_start_kernel
                        --0.26%-- [...]
     1.08%             ksmd  [kernel.kallsyms]     [k] smp_call_function_many                    
                       |
                       --- smp_call_function_many
                          |          
                          |--99.97%-- native_flush_tlb_others
                          |          |          
                          |          |--99.78%-- flush_tlb_page
                          |          |          ptep_clear_flush
                          |          |          try_to_merge_with_ksm_page
                          |          |          ksm_scan_thread
                          |          |          kthread
                          |          |          kernel_thread_helper
                          |           --0.22%-- [...]
                           --0.03%-- [...]
     0.77%         qemu-kvm  [kernel.kallsyms]     [k] kvm_vcpu_on_spin                          
                   |
                   --- kvm_vcpu_on_spin
                      |          
                      |--99.36%-- pause_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--90.08%-- 0x10100000006
                      |          |          
                      |          |--9.92%-- 0x10100000002
                      |           --0.00%-- [...]
                      |          
                       --0.64%-- handle_exit
                                 kvm_arch_vcpu_ioctl_run
                                 kvm_vcpu_ioctl
                                 do_vfs_ioctl
                                 sys_ioctl
                                 system_call_fastpath
                                 ioctl
                                 |          
                                 |--87.37%-- 0x10100000006
                                 |          
                                  --12.63%-- 0x10100000002
     0.75%         qemu-kvm  [kernel.kallsyms]     [k] compact_zone                              
                   |
                   --- compact_zone
                      |          
                      |--99.98%-- compact_zone_order
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
                      |          |--91.29%-- 0x10100000006
                      |          |          
                      |           --8.71%-- 0x10100000002
                       --0.02%-- [...]
     0.68%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock                            
                   |
                   --- _raw_spin_lock
                      |          
                      |--39.71%-- yield_to
                      |          kvm_vcpu_yield_to
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
                      |          |--90.52%-- 0x10100000006
                      |          |          
                      |           --9.48%-- 0x10100000002
                      |          
                      |--15.63%-- kvm_vcpu_yield_to
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
                      |          |--90.96%-- 0x10100000006
                      |          |          
                      |           --9.04%-- 0x10100000002
                      |          
                      |--6.55%-- tdp_page_fault
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
                      |          |--78.78%-- 0x10100000006
                      |          |          
                      |           --21.22%-- 0x10100000002
                      |          
                      |--4.87%-- free_pcppages_bulk
                      |          |          
                      |          |--51.10%-- free_hot_cold_page
                      |          |          |          
                      |          |          |--83.60%-- free_hot_cold_page_list
                      |          |          |          |          
                      |          |          |          |--62.17%-- release_pages
                      |          |          |          |          pagevec_lru_move_fn
                      |          |          |          |          __pagevec_lru_add
                      |          |          |          |          |          
                      |          |          |          |          |--99.22%-- __lru_cache_add
                      |          |          |          |          |          lru_cache_add_lru
                      |          |          |          |          |          putback_lru_page
                      |          |          |          |          |          |          
                      |          |          |          |          |          |--99.61%-- migrate_pages
                      |          |          |          |          |          |          compact_zone
                      |          |          |          |          |          |          compact_zone_order
                      |          |          |          |          |          |          try_to_compact_pages
                      |          |          |          |          |          |          __alloc_pages_direct_compact
                      |          |          |          |          |          |          __alloc_pages_nodemask
                      |          |          |          |          |          |          alloc_pages_vma
                      |          |          |          |          |          |          do_huge_pmd_anonymous_page
                      |          |          |          |          |          |          handle_mm_fault
                      |          |          |          |          |          |          __get_user_pages
                      |          |          |          |          |          |          get_user_page_nowait
                      |          |          |          |          |          |          hva_to_pfn.isra.17
                      |          |          |          |          |          |          __gfn_to_pfn
                      |          |          |          |          |          |          gfn_to_pfn_async
                      |          |          |          |          |          |          try_async_pf
                      |          |          |          |          |          |          tdp_page_fault
                      |          |          |          |          |          |          kvm_mmu_page_fault
                      |          |          |          |          |          |          pf_interception
                      |          |          |          |          |          |          handle_exit
                      |          |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                      |          |          |          |          |          |          kvm_vcpu_ioctl
                      |          |          |          |          |          |          do_vfs_ioctl
                      |          |          |          |          |          |          sys_ioctl
                      |          |          |          |          |          |          system_call_fastpath
                      |          |          |          |          |          |          ioctl
                      |          |          |          |          |          |          |          
                      |          |          |          |          |          |          |--88.98%-- 0x10100000006
                      |          |          |          |          |          |          |          
                      |          |          |          |          |          |           --11.02%-- 0x10100000002
                      |          |          |          |          |           --0.39%-- [...]
                      |          |          |          |          |          
                      |          |          |          |           --0.78%-- lru_add_drain_cpu
                      |          |          |          |                     lru_add_drain
                      |          |          |          |                     migrate_prep_local
                      |          |          |          |                     compact_zone
                      |          |          |          |                     compact_zone_order
                      |          |          |          |                     try_to_compact_pages
                      |          |          |          |                     __alloc_pages_direct_compact
                      |          |          |          |                     __alloc_pages_nodemask
                      |          |          |          |                     alloc_pages_vma
                      |          |          |          |                     do_huge_pmd_anonymous_page
                      |          |          |          |                     handle_mm_fault
                      |          |          |          |                     __get_user_pages
                      |          |          |          |                     get_user_page_nowait
                      |          |          |          |                     hva_to_pfn.isra.17
                      |          |          |          |                     __gfn_to_pfn
                      |          |          |          |                     gfn_to_pfn_async
                      |          |          |          |                     try_async_pf
                      |          |          |          |                     tdp_page_fault
                      |          |          |          |                     kvm_mmu_page_fault
                      |          |          |          |                     pf_interception
                      |          |          |          |                     handle_exit
                      |          |          |          |                     kvm_arch_vcpu_ioctl_run
                      |          |          |          |                     kvm_vcpu_ioctl
                      |          |          |          |                     do_vfs_ioctl
                      |          |          |          |                     sys_ioctl
                      |          |          |          |                     system_call_fastpath
                      |          |          |          |                     ioctl
                      |          |          |          |                     0x10100000006
                      |          |          |          |          
                      |          |          |           --37.83%-- shrink_page_list
                      |          |          |                     shrink_inactive_list
                      |          |          |                     shrink_lruvec
                      |          |          |                     try_to_free_pages
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
                      |          |          |                     |          
                      |          |          |                     |--86.38%-- 0x10100000006
                      |          |          |                     |          
                      |          |          |                      --13.62%-- 0x10100000002
                      |          |          |          
                      |          |          |--12.96%-- __free_pages
                      |          |          |          |          
                      |          |          |          |--98.43%-- release_freepages
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
                      |          |          |          |          |--90.49%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --9.51%-- 0x10100000002
                      |          |          |          |          
                      |          |          |           --1.57%-- __free_slab
                      |          |          |                     discard_slab
                      |          |          |                     unfreeze_partials
                      |          |          |                     put_cpu_partial
                      |          |          |                     __slab_free
                      |          |          |                     kmem_cache_free
                      |          |          |                     free_buffer_head
                      |          |          |                     try_to_free_buffers
                      |          |          |                     jbd2_journal_try_to_free_buffers
                      |          |          |                     bdev_try_to_free_page
                      |          |          |                     blkdev_releasepage
                      |          |          |                     try_to_release_page
                      |          |          |                     move_to_new_page
                      |          |          |                     migrate_pages
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
                      |          |           --3.44%-- __put_single_page
                      |          |                     put_page
                      |          |                     putback_lru_page
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
                      |          |                     |          
                      |          |                     |--88.25%-- 0x10100000006
                      |          |                     |          
                      |          |                      --11.75%-- 0x10100000002
                      |          |          
                      |           --48.90%-- drain_pages
                      |                     |          
                      |                     |--88.65%-- drain_local_pages
                      |                     |          |          
                      |                     |          |--96.33%-- generic_smp_call_function_interrupt
                      |                     |          |          smp_call_function_interrupt
                      |                     |          |          call_function_interrupt
                      |                     |          |          |          
                      |                     |          |          |--23.46%-- __remove_mapping
                      |                     |          |          |          shrink_page_list
                      |                     |          |          |          shrink_inactive_list
                      |                     |          |          |          shrink_lruvec
                      |                     |          |          |          try_to_free_pages
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--93.81%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --6.19%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--19.93%-- kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--93.65%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --6.35%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--14.19%-- compaction_alloc
                      |                     |          |          |          migrate_pages
                      |                     |          |          |          compact_zone
                      |                     |          |          |          compact_zone_order
                      |                     |          |          |          try_to_compact_pages
                      |                     |          |          |          __alloc_pages_direct_compact
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--89.88%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --10.12%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--8.57%-- isolate_migratepages_range
                      |                     |          |          |          compact_zone
                      |                     |          |          |          compact_zone_order
                      |                     |          |          |          try_to_compact_pages
                      |                     |          |          |          __alloc_pages_direct_compact
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--92.14%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --7.86%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--5.05%-- do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--92.53%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --7.47%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--4.49%-- shrink_inactive_list
                      |                     |          |          |          shrink_lruvec
                      |                     |          |          |          try_to_free_pages
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--94.61%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --5.39%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--2.80%-- free_hot_cold_page_list
                      |                     |          |          |          shrink_page_list
                      |                     |          |          |          shrink_inactive_list
                      |                     |          |          |          shrink_lruvec
                      |                     |          |          |          try_to_free_pages
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--91.24%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --8.76%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--1.96%-- buffer_migrate_page
                      |                     |          |          |          move_to_new_page
                      |                     |          |          |          migrate_pages
                      |                     |          |          |          compact_zone
                      |                     |          |          |          compact_zone_order
                      |                     |          |          |          try_to_compact_pages
                      |                     |          |          |          __alloc_pages_direct_compact
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--63.14%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --36.86%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--1.62%-- try_to_free_buffers
                      |                     |          |          |          jbd2_journal_try_to_free_buffers
                      |                     |          |          |          ext4_releasepage
                      |                     |          |          |          try_to_release_page
                      |                     |          |          |          shrink_page_list
                      |                     |          |          |          shrink_inactive_list
                      |                     |          |          |          shrink_lruvec
                      |                     |          |          |          try_to_free_pages
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          0x10100000006
                      |                     |          |          |          
                      |                     |          |          |--1.49%-- compact_checklock_irqsave
                      |                     |          |          |          isolate_migratepages_range
                      |                     |          |          |          compact_zone
                      |                     |          |          |          compact_zone_order
                      |                     |          |          |          try_to_compact_pages
                      |                     |          |          |          __alloc_pages_direct_compact
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          0x10100000006
                      |                     |          |          |          
                      |                     |          |          |--1.46%-- __mutex_lock_slowpath
                      |                     |          |          |          mutex_lock
                      |                     |          |          |          page_lock_anon_vma
                      |                     |          |          |          page_referenced
                      |                     |          |          |          shrink_active_list
                      |                     |          |          |          shrink_lruvec
                      |                     |          |          |          try_to_free_pages
                      |                     |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          alloc_pages_vma
                      |                     |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          handle_mm_fault
                      |                     |          |          |          __get_user_pages
                      |                     |          |          |          get_user_page_nowait
                      |                     |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          __gfn_to_pfn
                      |                     |          |          |          gfn_to_pfn_async
                      |                     |          |          |          try_async_pf
                      |                     |          |          |          tdp_page_fault
                      |                     |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          pf_interception
                      |                     |          |          |          handle_exit
                      |                     |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          0x10100000006
                      |                     |          |          |          
                      |                     |          |          |--1.41%-- native_flush_tlb_others
                      |                     |          |          |          flush_tlb_page
                      |                     |          |          |          |          
                      |                     |          |          |          |--67.10%-- ptep_clear_flush
                      |                     |          |          |          |          try_to_unmap_one
                      |                     |          |          |          |          try_to_unmap_anon
                      |                     |          |          |          |          try_to_unmap
                      |                     |          |          |          |          migrate_pages
                      |                     |          |          |          |          compact_zone
                      |                     |          |          |          |          compact_zone_order
                      |                     |          |          |          |          try_to_compact_pages
                      |                     |          |          |          |          __alloc_pages_direct_compact
                      |                     |          |          |          |          __alloc_pages_nodemask

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
