Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 022606B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 04:15:10 -0400 (EDT)
Date: Tue, 18 Sep 2012 09:14:55 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
Message-ID: <20120918081455.GA16395@alpha.arachsys.com>
References: <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
 <20120912164615.GA14173@alpha.arachsys.com>
 <20120913154824.44cc0e28@cuia.bos.redhat.com>
 <20120913155450.7634148f@cuia.bos.redhat.com>
 <20120915155524.GA24182@alpha.arachsys.com>
 <20120917122628.GF11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120917122628.GF11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

Hi Mel,

Thanks for your latest patch, I attach a perf report below with this on top
of all previous patches. There is still lock contention, though in a
different place.

Regarding Rik's question:

> > Mel asked for timings of the slow boots. It's very hard to give anything
> > useful here! A normal boot would be a minute or so, and many are like
> > that, but the slowest that I have seen (on 3.5.x) was several hours.
> > Basically, I just test many times until I get one which is noticeably
> > slow than normal and then run perf record on that one.
> >
> > The latest perf report for a slow boot is below. For the fast boots,
> > most of the time is in clean_page_c in do_huge_pmd_anonymous_page, but
> > for this slow one there is a lot of lock contention above that.
>
> How often do you run into slow boots, vs. fast ones?

It is about 1/3rd slow boots, some of which are slower than others. I do
about ten and send you the trace of the worst.

Experimentally, copying large files (the VM image files) immediately before
booting the VM seems to make a slow boot more likely.

Thanks,

Richard.


# ========
# captured on: Mon Sep 17 20:09:33 2012
# os release : 3.6.0-rc5-elastic+
# perf version : 3.5.2
# arch : x86_64
# nrcpus online : 16
# nrcpus avail : 16
# cpudesc : AMD Opteron(tm) Processor 6128
# cpuid : AuthenticAMD,16,9,1
# total memory : 131973280 kB
# cmdline : /home/root/bin/perf record -g -a 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# HEADER_NUMA_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 4M of event 'cycles'
# Event count (approx.): 1616311320818
#
# Overhead          Command         Shared Object                                          Symbol
# ........  ...............  ....................  ..............................................
#
    59.97%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave                    
                   |
                   --- _raw_spin_lock_irqsave
                      |          
                      |--99.30%-- compact_checklock_irqsave
                      |          |          
                      |          |--99.98%-- compaction_alloc
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
                      |          |          |--84.28%-- 0x10100000006
                      |          |          |          
                      |          |           --15.72%-- 0x10100000002
                      |           --0.02%-- [...]
                      |          
                      |--0.65%-- compaction_alloc
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
                      |          |--83.37%-- 0x10100000006
                      |          |          
                      |           --16.63%-- 0x10100000002
                       --0.05%-- [...]
    12.27%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block                   
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
                      |          |--82.90%-- 0x10100000006
                      |          |          
                      |           --17.10%-- 0x10100000002
                       --0.01%-- [...]
     7.90%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                              
                   |
                   --- clear_page_c
                      |          
                      |--99.19%-- do_huge_pmd_anonymous_page
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
                      |          |--64.93%-- 0x10100000006
                      |          |          
                      |           --35.07%-- 0x10100000002
                      |          
                       --0.81%-- __alloc_pages_nodemask
                                 |          
                                 |--84.23%-- alloc_pages_vma
                                 |          handle_pte_fault
                                 |          |          
                                 |          |--99.62%-- handle_mm_fault
                                 |          |          |          
                                 |          |          |--99.74%-- __get_user_pages
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
                                 |          |          |          |--76.24%-- 0x10100000006
                                 |          |          |          |          
                                 |          |          |           --23.76%-- 0x10100000002
                                 |          |           --0.26%-- [...]
                                 |           --0.38%-- [...]
                                 |          
                                  --15.77%-- alloc_pages_current
                                            pte_alloc_one
                                            |          
                                            |--97.49%-- do_huge_pmd_anonymous_page
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
                                            |          |--57.31%-- 0x10100000006
                                            |          |          
                                            |           --42.69%-- 0x10100000002
                                            |          
                                             --2.51%-- __pte_alloc
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
                                                       |          
                                                       |--61.90%-- 0x10100000006
                                                       |          
                                                        --38.10%-- 0x10100000002
     2.66%             ksmd  [kernel.kallsyms]     [k] smp_call_function_many                    
                       |
                       --- smp_call_function_many
                          |          
                          |--99.99%-- native_flush_tlb_others
                          |          |          
                          |          |--99.79%-- flush_tlb_page
                          |          |          ptep_clear_flush
                          |          |          try_to_merge_with_ksm_page
                          |          |          ksm_scan_thread
                          |          |          kthread
                          |          |          kernel_thread_helper
                          |           --0.21%-- [...]
                           --0.01%-- [...]
     1.62%         qemu-kvm  [kernel.kallsyms]     [k] yield_to                                  
                   |
                   --- yield_to
                      |          
                      |--99.58%-- kvm_vcpu_yield_to
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
                      |          |--77.42%-- 0x10100000006
                      |          |          
                      |           --22.58%-- 0x10100000002
                       --0.42%-- [...]
     1.17%             ksmd  [kernel.kallsyms]     [k] memcmp                                    
                       |
                       --- memcmp
                          |          
                          |--99.65%-- memcmp_pages
                          |          |          
                          |          |--78.67%-- ksm_scan_thread
                          |          |          kthread
                          |          |          kernel_thread_helper
                          |          |          
                          |           --21.33%-- try_to_merge_with_ksm_page
                          |                     ksm_scan_thread
                          |                     kthread
                          |                     kernel_thread_helper
                           --0.35%-- [...]
     1.16%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run                              
                   |
                   --- svm_vcpu_run
                      |          
                      |--99.47%-- kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--74.69%-- 0x10100000006
                      |          |          
                      |           --25.31%-- 0x10100000002
                      |          
                       --0.53%-- kvm_vcpu_ioctl
                                 do_vfs_ioctl
                                 sys_ioctl
                                 system_call_fastpath
                                 ioctl
                                 |          
                                 |--72.19%-- 0x10100000006
                                 |          
                                  --27.81%-- 0x10100000002
     1.09%          swapper  [kernel.kallsyms]     [k] default_idle                              
                    |
                    --- default_idle
                       |          
                       |--99.73%-- cpu_idle
                       |          |          
                       |          |--84.39%-- start_secondary
                       |          |          
                       |           --15.61%-- rest_init
                       |                     start_kernel
                       |                     x86_64_start_reservations
                       |                     x86_64_start_kernel
                        --0.27%-- [...]
     0.85%         qemu-kvm  [kernel.kallsyms]     [k] kvm_vcpu_on_spin                          
                   |
                   --- kvm_vcpu_on_spin
                      |          
                      |--99.40%-- pause_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--76.92%-- 0x10100000006
                      |          |          
                      |           --23.08%-- 0x10100000002
                      |          
                       --0.60%-- handle_exit
                                 kvm_arch_vcpu_ioctl_run
                                 kvm_vcpu_ioctl
                                 do_vfs_ioctl
                                 sys_ioctl
                                 system_call_fastpath
                                 ioctl
                                 |          
                                 |--75.02%-- 0x10100000006
                                 |          
                                  --24.98%-- 0x10100000002
     0.60%         qemu-kvm  [kernel.kallsyms]     [k] __srcu_read_lock                          
                   |
                   --- __srcu_read_lock
                      |          
                      |--92.87%-- kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--76.37%-- 0x10100000006
                      |          |          
                      |           --23.63%-- 0x10100000002
                      |          
                      |--6.18%-- kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--74.92%-- 0x10100000006
                      |          |          
                      |           --25.08%-- 0x10100000002
                       --0.95%-- [...]
     0.60%         qemu-kvm  [kernel.kallsyms]     [k] __rcu_read_unlock                         
                   |
                   --- __rcu_read_unlock
                      |          
                      |--79.70%-- get_pid_task
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
                      |          |--75.95%-- 0x10100000006
                      |          |          
                      |           --24.05%-- 0x10100000002
                      |          
                      |--11.44%-- kvm_vcpu_yield_to
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
                      |          |--75.32%-- 0x10100000006
                      |          |          
                      |           --24.68%-- 0x10100000002
                      |          
                      |--3.51%-- kvm_vcpu_on_spin
                      |          pause_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--76.56%-- 0x10100000006
                      |          |          
                      |           --23.44%-- 0x10100000002
                      |          
                      |--1.88%-- do_select
                      |          core_sys_select
                      |          sys_select
                      |          system_call_fastpath
                      |          __select
                      |          0x0
                      |          
                      |--1.30%-- fget_light
                      |          |          
                      |          |--71.87%-- do_select
                      |          |          core_sys_select
                      |          |          sys_select
                      |          |          system_call_fastpath
                      |          |          __select
                      |          |          0x0
                      |          |          
                      |          |--15.50%-- sys_ioctl
                      |          |          system_call_fastpath
                      |          |          ioctl
                      |          |          |          
                      |          |          |--50.94%-- 0x10100000002
                      |          |          |          
                      |          |          |--17.13%-- 0x2740310
                      |          |          |          0x0
                      |          |          |          
                      |          |          |--13.07%-- 0x225c310
                      |          |          |          0x0
                      |          |          |          
                      |          |          |--9.95%-- 0x2792310
                      |          |          |          0x0
                      |          |          |          
                      |          |          |--3.64%-- 0x75ed8548202c4b83
                      |          |          |          
                      |          |          |--1.87%-- 0x8800000
                      |          |          |          0x26433c0
                      |          |          |          
                      |          |          |--1.79%-- 0x10100000006
                      |          |          |          
                      |          |          |--0.95%-- 0x19800000
                      |          |          |          0x26953c0
                      |          |          |          
                      |          |           --0.67%-- 0x24bc8b4400000098
                      |          |          
                      |          |--7.32%-- sys_read
                      |          |          system_call_fastpath
                      |          |          read
                      |          |          |          
                      |          |           --100.00%-- pthread_mutex_lock@plt
                      |          |          
                      |          |--4.03%-- sys_write
                      |          |          system_call_fastpath
                      |          |          write
                      |          |          |          
                      |          |           --100.00%-- 0x0
                      |          |          
                      |          |--0.69%-- sys_pread64
                      |          |          system_call_fastpath
                      |          |          pread64
                      |          |          0x269d260
                      |          |          0x80
                      |          |          0x480050b9e1058b48
                      |           --0.59%-- [...]
                       --2.18%-- [...]
     0.49%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock                            
                   |
                   --- _raw_spin_lock
                      |          
                      |--50.00%-- yield_to
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
                      |          |--77.93%-- 0x10100000006
                      |          |          
                      |           --22.07%-- 0x10100000002
                      |          
                      |--11.97%-- free_pcppages_bulk
                      |          |          
                      |          |--67.09%-- free_hot_cold_page
                      |          |          |          
                      |          |          |--87.14%-- free_hot_cold_page_list
                      |          |          |          |          
                      |          |          |          |--62.82%-- shrink_page_list
                      |          |          |          |          shrink_inactive_list
                      |          |          |          |          shrink_lruvec
                      |          |          |          |          try_to_free_pages
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
                      |          |          |          |          |--77.85%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --22.15%-- 0x10100000002
                      |          |          |          |          
                      |          |          |           --37.18%-- release_pages
                      |          |          |                     pagevec_lru_move_fn
                      |          |          |                     __pagevec_lru_add
                      |          |          |                     |          
                      |          |          |                     |--99.76%-- __lru_cache_add
                      |          |          |                     |          lru_cache_add_lru
                      |          |          |                     |          putback_lru_page
                      |          |          |                     |          migrate_pages
                      |          |          |                     |          compact_zone
                      |          |          |                     |          compact_zone_order
                      |          |          |                     |          try_to_compact_pages
                      |          |          |                     |          __alloc_pages_direct_compact
                      |          |          |                     |          __alloc_pages_nodemask
                      |          |          |                     |          alloc_pages_vma
                      |          |          |                     |          do_huge_pmd_anonymous_page
                      |          |          |                     |          handle_mm_fault
                      |          |          |                     |          __get_user_pages
                      |          |          |                     |          get_user_page_nowait
                      |          |          |                     |          hva_to_pfn.isra.17
                      |          |          |                     |          __gfn_to_pfn
                      |          |          |                     |          gfn_to_pfn_async
                      |          |          |                     |          try_async_pf
                      |          |          |                     |          tdp_page_fault
                      |          |          |                     |          kvm_mmu_page_fault
                      |          |          |                     |          pf_interception
                      |          |          |                     |          handle_exit
                      |          |          |                     |          kvm_arch_vcpu_ioctl_run
                      |          |          |                     |          kvm_vcpu_ioctl
                      |          |          |                     |          do_vfs_ioctl
                      |          |          |                     |          sys_ioctl
                      |          |          |                     |          system_call_fastpath
                      |          |          |                     |          ioctl
                      |          |          |                     |          |          
                      |          |          |                     |          |--80.37%-- 0x10100000006
                      |          |          |                     |          |          
                      |          |          |                     |           --19.63%-- 0x10100000002
                      |          |          |                      --0.24%-- [...]
                      |          |          |          
                      |          |          |--10.98%-- __free_pages
                      |          |          |          |          
                      |          |          |          |--98.77%-- release_freepages
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
                      |          |          |          |          |--80.81%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --19.19%-- 0x10100000002
                      |          |          |          |          
                      |          |          |           --1.23%-- __free_slab
                      |          |          |                     discard_slab
                      |          |          |                     unfreeze_partials
                      |          |          |                     put_cpu_partial
                      |          |          |                     __slab_free
                      |          |          |                     kmem_cache_free
                      |          |          |                     free_buffer_head
                      |          |          |                     try_to_free_buffers
                      |          |          |                     jbd2_journal_try_to_free_buffers
                      |          |          |                     ext4_releasepage
                      |          |          |                     try_to_release_page
                      |          |          |                     shrink_page_list
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
                      |          |          |                     |--57.92%-- 0x10100000006
                      |          |          |                     |          
                      |          |          |                      --42.08%-- 0x10100000002
                      |          |          |          
                      |          |           --1.88%-- __put_single_page
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
                      |          |                     |--62.44%-- 0x10100000006
                      |          |                     |          
                      |          |                      --37.56%-- 0x10100000002
                      |          |          
                      |           --32.91%-- drain_pages
                      |                     |          
                      |                     |--75.89%-- drain_local_pages
                      |                     |          |          
                      |                     |          |--89.98%-- generic_smp_call_function_interrupt
                      |                     |          |          smp_call_function_interrupt
                      |                     |          |          call_function_interrupt
                      |                     |          |          |          
                      |                     |          |          |--44.57%-- compaction_alloc
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
                      |                     |          |          |          |--79.27%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --20.73%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--16.92%-- kvm_vcpu_ioctl
                      |                     |          |          |          do_vfs_ioctl
                      |                     |          |          |          sys_ioctl
                      |                     |          |          |          system_call_fastpath
                      |                     |          |          |          ioctl
                      |                     |          |          |          |          
                      |                     |          |          |          |--86.24%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --13.76%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--5.39%-- do_huge_pmd_anonymous_page
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
                      |                     |          |          |          |--75.62%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --24.38%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--3.26%-- buffer_migrate_page
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
                      |                     |          |          |          |--85.62%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --14.38%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--3.21%-- __remove_mapping
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
                      |                     |          |          |          |--78.75%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --21.25%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--3.01%-- free_hot_cold_page_list
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
                      |                     |          |          |          |--84.48%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --15.52%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--2.25%-- try_to_free_buffers
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
                      |                     |          |          |          |          
                      |                     |          |          |          |--58.91%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --41.09%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--2.07%-- compact_zone
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
                      |                     |          |          |          |--67.59%-- 0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --32.41%-- 0x10100000002
                      |                     |          |          |          
                      |                     |          |          |--1.80%-- native_flush_tlb_others
                      |                     |          |          |          |          
                      |                     |          |          |          |--75.08%-- flush_tlb_page
                      |                     |          |          |          |          |          
                      |                     |          |          |          |          |--82.69%-- ptep_clear_flush_young
                      |                     |          |          |          |          |          page_referenced_one
                      |                     |          |          |          |          |          page_referenced
                      |                     |          |          |          |          |          shrink_active_list
                      |                     |          |          |          |          |          shrink_lruvec
                      |                     |          |          |          |          |          try_to_free_pages
                      |                     |          |          |          |          |          __alloc_pages_nodemask
                      |                     |          |          |          |          |          alloc_pages_vma
                      |                     |          |          |          |          |          do_huge_pmd_anonymous_page
                      |                     |          |          |          |          |          handle_mm_fault
                      |                     |          |          |          |          |          __get_user_pages
                      |                     |          |          |          |          |          get_user_page_nowait
                      |                     |          |          |          |          |          hva_to_pfn.isra.17
                      |                     |          |          |          |          |          __gfn_to_pfn
                      |                     |          |          |          |          |          gfn_to_pfn_async
                      |                     |          |          |          |          |          try_async_pf
                      |                     |          |          |          |          |          tdp_page_fault
                      |                     |          |          |          |          |          kvm_mmu_page_fault
                      |                     |          |          |          |          |          pf_interception
                      |                     |          |          |          |          |          handle_exit
                      |                     |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          |          |          kvm_vcpu_ioctl
                      |                     |          |          |          |          |          do_vfs_ioctl
                      |                     |          |          |          |          |          sys_ioctl
                      |                     |          |          |          |          |          system_call_fastpath
                      |                     |          |          |          |          |          ioctl
                      |                     |          |          |          |          |          |          
                      |                     |          |          |          |          |          |--78.99%-- 0x10100000006
                      |                     |          |          |          |          |          |          
                      |                     |          |          |          |          |           --21.01%-- 0x10100000002
                      |                     |          |          |          |          |          
                      |                     |          |          |          |           --17.31%-- ptep_clear_flush
                      |                     |          |          |          |                     try_to_unmap_one
                      |                     |          |          |          |                     try_to_unmap_anon
                      |                     |          |          |          |                     try_to_unmap
                      |                     |          |          |          |                     migrate_pages
                      |                     |          |          |          |                     compact_zone
                      |                     |          |          |          |                     compact_zone_order
                      |                     |          |          |          |                     try_to_compact_pages
                      |                     |          |          |          |                     __alloc_pages_direct_compact
                      |                     |          |          |          |                     __alloc_pages_nodemask
                      |                     |          |          |          |                     alloc_pages_vma
                      |                     |          |          |          |                     do_huge_pmd_anonymous_page
                      |                     |          |          |          |                     handle_mm_fault
                      |                     |          |          |          |                     __get_user_pages
                      |                     |          |          |          |                     get_user_page_nowait
                      |                     |          |          |          |                     hva_to_pfn.isra.17
                      |                     |          |          |          |                     __gfn_to_pfn
                      |                     |          |          |          |                     gfn_to_pfn_async
                      |                     |          |          |          |                     try_async_pf
                      |                     |          |          |          |                     tdp_page_fault
                      |                     |          |          |          |                     kvm_mmu_page_fault
                      |                     |          |          |          |                     pf_interception
                      |                     |          |          |          |                     handle_exit
                      |                     |          |          |          |                     kvm_arch_vcpu_ioctl_run
                      |                     |          |          |          |                     kvm_vcpu_ioctl
                      |                     |          |          |          |                     do_vfs_ioctl
                      |                     |          |          |          |                     sys_ioctl
                      |                     |          |          |          |                     system_call_fastpath
                      |                     |          |          |          |                     ioctl
                      |                     |          |          |          |                     0x10100000006
                      |                     |          |          |          |          
                      |                     |          |          |           --24.92%-- flush_tlb_mm_range
                      |                     |          |          |                     pmdp_clear_flush_young
                      |                     |          |          |                     page_referenced_one
                      |                     |          |          |                     page_referenced
                      |                     |          |          |                     shrink_active_list
                      |                     |          |          |                     shrink_lruvec
                      |                     |          |          |                     try_to_free_pages
                      |                     |          |          |                     __alloc_pages_nodemask
                      |                     |          |          |                     alloc_pages_vma
                      |                     |          |          |                     do_huge_pmd_anonymous_page
                      |                     |          |          |                     handle_mm_fault
                      |                     |          |          |                     __get_user_pages
                      |                     |          |          |                     get_user_page_nowait
                      |                     |          |          |                     hva_to_pfn.isra.17
                      |                     |          |          |                     __gfn_to_pfn
                      |                     |          |          |                     gfn_to_pfn_async
                      |                     |          |          |                     try_async_pf
                      |                     |          |          |                     tdp_page_fault
                      |                     |          |          |                     kvm_mmu_page_fault
                      |                     |          |          |                     pf_interception
                      |                     |          |          |                     handle_exit
                      |                     |          |          |                     kvm_arch_vcpu_ioctl_run
                      |                     |          |          |                     kvm_vcpu_ioctl
                      |                     |          |          |                     do_vfs_ioctl
                      |                     |          |          |                     sys_ioctl
                      |                     |          |          |                     system_call_fastpath
                      |                     |          |          |                     ioctl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
