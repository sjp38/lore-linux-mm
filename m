Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 619E96B00C1
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 06:57:10 -0400 (EDT)
Date: Wed, 12 Sep 2012 11:56:59 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Windows VM slow boot
Message-ID: <20120912105659.GA23818@alpha.arachsys.com>
References: <20120821152107.GA16363@alpha.arachsys.com>
 <5034A18B.5040408@redhat.com>
 <20120822124032.GA12647@alpha.arachsys.com>
 <5034D437.8070106@redhat.com>
 <20120822144150.GA1400@alpha.arachsys.com>
 <5034F8F4.3080301@redhat.com>
 <20120825174550.GA8619@alpha.arachsys.com>
 <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120906092039.GA19234@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

[ adding linux-mm - previously at http://marc.info/?t=134511509400003 ]

Hi Rik,

Since qemu-kvm 1.2.0 and Linux 3.6.0-rc5 came out, I thought that I would
retest with these.

The typical symptom now appears to be that the Windows VMs boot reasonably
fast, but then there is high CPU use and load for many minutes afterwards -
the high CPU use is both for the qemu-kvm processes themselves and also for
% sys.

I attach a perf report which seems to show that the high CPU use is in the
memory manager.

Cheers,

Richard.


# ========
# captured on: Wed Sep 12 10:25:43 2012
# os release : 3.6.0-rc5-elastic
# perf version : 3.5.2
# arch : x86_64
# nrcpus online : 16
# nrcpus avail : 16
# cpudesc : AMD Opteron(tm) Processor 6128
# cpuid : AuthenticAMD,16,9,1
# total memory : 131973280 kB
# cmdline : /home/root/bin/perf record -g -a 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# HEADER_NUMA_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 870K of event 'cycles'
# Event count (approx.): 432968175910
#
# Overhead          Command         Shared Object                                          Symbol
# ........  ...............  ....................  ..............................................
#
    89.14%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave                    
                   |
                   --- _raw_spin_lock_irqsave
                      |          
                      |--95.47%-- isolate_migratepages_range
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
                      |          |--55.64%-- 0x10100000002
                      |          |          
                      |           --44.36%-- 0x10100000006
                      |          
                      |--4.53%-- compact_zone
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
                      |          |--55.36%-- 0x10100000002
                      |          |          
                      |           --44.64%-- 0x10100000006
                       --0.00%-- [...]
     4.92%         qemu-kvm  [kernel.kallsyms]     [k] migrate_pages                             
                   |
                   --- migrate_pages
                      |          
                      |--99.74%-- compact_zone
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
                      |          |--55.80%-- 0x10100000002
                      |          |          
                      |           --44.20%-- 0x10100000006
                       --0.26%-- [...]
     1.59%             ksmd  [kernel.kallsyms]     [k] memcmp                                    
                       |
                       --- memcmp
                          |          
                          |--99.69%-- memcmp_pages
                          |          |          
                          |          |--78.86%-- ksm_scan_thread
                          |          |          kthread
                          |          |          kernel_thread_helper
                          |          |          
                          |           --21.14%-- try_to_merge_with_ksm_page
                          |                     ksm_scan_thread
                          |                     kthread
                          |                     kernel_thread_helper
                           --0.31%-- [...]
     0.85%             ksmd  [kernel.kallsyms]     [k] smp_call_function_many                    
                       |
                       --- smp_call_function_many
                           native_flush_tlb_others
                          |          
                          |--99.81%-- flush_tlb_page
                          |          ptep_clear_flush
                          |          try_to_merge_with_ksm_page
                          |          ksm_scan_thread
                          |          kthread
                          |          kernel_thread_helper
                           --0.19%-- [...]
     0.38%          swapper  [kernel.kallsyms]     [k] default_idle                              
                    |
                    --- default_idle
                       |          
                       |--99.80%-- cpu_idle
                       |          |          
                       |          |--90.53%-- start_secondary
                       |          |          
                       |           --9.47%-- rest_init
                       |                     start_kernel
                       |                     x86_64_start_reservations
                       |                     x86_64_start_kernel
                        --0.20%-- [...]
     0.38%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_unlock_irqrestore               
                   |
                   --- _raw_spin_unlock_irqrestore
                      |          
                      |--94.31%-- compact_checklock_irqsave
                      |          isolate_migratepages_range
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
                      |          |--59.74%-- 0x10100000006
                      |          |          
                      |           --40.26%-- 0x10100000002
                      |          
                      |--3.41%-- isolate_migratepages_range
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
                      |          |--53.57%-- 0x10100000006
                      |          |          
                      |           --46.43%-- 0x10100000002
                      |          
                      |--0.82%-- ntp_tick_length
                      |          do_timer
                      |          tick_do_update_jiffies64
                      |          tick_sched_timer
                      |          __run_hrtimer.isra.28
                      |          hrtimer_interrupt
                      |          smp_apic_timer_interrupt
                      |          apic_timer_interrupt
                      |          compact_checklock_irqsave
                      |          isolate_migratepages_range
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
                      |          0x10100000002
                      |          
                      |--0.76%-- __page_cache_release.part.11
                      |          __put_compound_page
                      |          put_compound_page
                      |          release_pages
                      |          free_pages_and_swap_cache
                      |          tlb_flush_mmu
                      |          tlb_finish_mmu
                      |          exit_mmap
                      |          mmput
                      |          exit_mm
                      |          do_exit
                      |          do_group_exit
                      |          get_signal_to_deliver
                      |          do_signal
                      |          do_notify_resume
                      |          int_signal
                       --0.70%-- [...]
     0.26%         qemu-kvm  [kernel.kallsyms]     [k] isolate_migratepages_range                
                   |
                   --- isolate_migratepages_range
                      |          
                      |--95.44%-- compact_zone
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
                      |          |--52.46%-- 0x10100000002
                      |          |          
                      |           --47.54%-- 0x10100000006
                      |          
                       --4.56%-- compact_zone_order
                                 try_to_compact_pages
                                 __alloc_pages_direct_compact
                                 __alloc_pages_nodemask
                                 alloc_pages_vma
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
                                 |--53.84%-- 0x10100000006
                                 |          
                                  --46.16%-- 0x10100000002
     0.21%         qemu-kvm  [kernel.kallsyms]     [k] compact_zone                              
                   |
                   --- compact_zone
                       compact_zone_order
                       try_to_compact_pages
                       __alloc_pages_direct_compact
                       __alloc_pages_nodemask
                       alloc_pages_vma
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
                      |--53.46%-- 0x10100000002
                      |          
                       --46.54%-- 0x10100000006
     0.14%         qemu-kvm  [kernel.kallsyms]     [k] mod_zone_page_state                       
                   |
                   --- mod_zone_page_state
                      |          
                      |--70.21%-- isolate_migratepages_range
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
                      |          |--55.97%-- 0x10100000002
                      |          |          
                      |           --44.03%-- 0x10100000006
                      |          
                      |--29.71%-- compact_zone
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
                      |          |--61.19%-- 0x10100000002
                      |          |          
                      |           --38.81%-- 0x10100000006
                       --0.08%-- [...]
     0.13%         qemu-kvm  [kernel.kallsyms]     [k] flush_tlb_func                            
                   |
                   --- flush_tlb_func
                      |          
                      |--99.47%-- generic_smp_call_function_interrupt
                      |          smp_call_function_interrupt
                      |          call_function_interrupt
                      |          |          
                      |          |--91.76%-- compact_checklock_irqsave
                      |          |          isolate_migratepages_range
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
                      |          |          |--76.39%-- 0x10100000006
                      |          |          |          
                      |          |           --23.61%-- 0x10100000002
                      |          |          
                      |          |--7.61%-- compact_zone
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
                      |          |          |--70.59%-- 0x10100000006
                      |          |          |          
                      |          |           --29.41%-- 0x10100000002
                      |           --0.63%-- [...]
                      |          
                       --0.53%-- smp_call_function_interrupt
                                 call_function_interrupt
                                 |          
                                 |--83.32%-- compact_checklock_irqsave
                                 |          isolate_migratepages_range
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
                                 |          |--79.99%-- 0x10100000006
                                 |          |          
                                 |           --20.01%-- 0x10100000002
                                 |          
                                  --16.68%-- compact_zone
                                            compact_zone_order
                                            try_to_compact_pages
                                            __alloc_pages_direct_compact
                                            __alloc_pages_nodemask
                                            alloc_pages_vma
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
                                            0x10100000002
     0.09%         qemu-kvm  [kernel.kallsyms]     [k] free_pages_prepare                        
                   |
                   --- free_pages_prepare
                      |          
                      |--99.75%-- __free_pages_ok
                      |          |          
                      |          |--99.84%-- free_compound_page
                      |          |          __put_compound_page
                      |          |          put_compound_page
                      |          |          release_pages
                      |          |          free_pages_and_swap_cache
                      |          |          tlb_flush_mmu
                      |          |          tlb_finish_mmu
                      |          |          exit_mmap
                      |          |          mmput
                      |          |          exit_mm
                      |          |          do_exit
                      |          |          do_group_exit
                      |          |          get_signal_to_deliver
                      |          |          do_signal
                      |          |          do_notify_resume
                      |          |          int_signal
                      |           --0.16%-- [...]
                       --0.25%-- [...]
     0.08%            :2585  [kernel.kallsyms]     [k] free_pages_prepare                        
                      |
                      --- free_pages_prepare
                         |          
                         |--99.47%-- __free_pages_ok
                         |          free_compound_page
                         |          __put_compound_page
                         |          put_compound_page
                         |          release_pages
                         |          free_pages_and_swap_cache
                         |          tlb_flush_mmu
                         |          tlb_finish_mmu
                         |          exit_mmap
                         |          mmput
                         |          exit_mm
                         |          do_exit
                         |          do_group_exit
                         |          get_signal_to_deliver
                         |          do_signal
                         |          do_notify_resume
                         |          int_signal
                         |          
                          --0.53%-- free_hot_cold_page
                                    __free_pages
                                    |          
                                    |--50.65%-- zap_huge_pmd
                                    |          unmap_single_vma
                                    |          unmap_vmas
                                    |          exit_mmap
                                    |          mmput
                                    |          exit_mm
                                    |          do_exit
                                    |          do_group_exit
                                    |          get_signal_to_deliver
                                    |          do_signal
                                    |          do_notify_resume
                                    |          int_signal
                                    |          
                                     --49.35%-- __vunmap
                                               vfree
                                               kvm_free_physmem_slot
                                               kvm_free_physmem
                                               kvm_put_kvm
                                               kvm_vcpu_release
                                               __fput
                                               ____fput
                                               task_work_run
                                               do_exit
                                               do_group_exit
                                               get_signal_to_deliver
                                               do_signal
                                               do_notify_resume
                                               int_signal
     0.07%            :2561  [kernel.kallsyms]     [k] free_pages_prepare                        
                      |
                      --- free_pages_prepare
                         |          
                         |--99.55%-- __free_pages_ok
                         |          free_compound_page
                         |          __put_compound_page
                         |          put_compound_page
                         |          release_pages
                         |          free_pages_and_swap_cache
                         |          tlb_flush_mmu
                         |          tlb_finish_mmu
                         |          exit_mmap
                         |          mmput
                         |          exit_mm
                         |          do_exit
                         |          do_group_exit
                         |          get_signal_to_deliver
                         |          do_signal
                         |          do_notify_resume
                         |          int_signal
                          --0.45%-- [...]
     0.07%         qemu-kvm  [kernel.kallsyms]     [k] __zone_watermark_ok                       
                   |
                   --- __zone_watermark_ok
                      |          
                      |--56.52%-- zone_watermark_ok
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
                      |          |--59.67%-- 0x10100000002
                      |          |          
                      |           --40.33%-- 0x10100000006
                      |          
                       --43.48%-- compact_zone
                                 compact_zone_order
                                 try_to_compact_pages
                                 __alloc_pages_direct_compact
                                 __alloc_pages_nodemask
                                 alloc_pages_vma
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
                                 |--58.50%-- 0x10100000002
                                 |          
                                  --41.50%-- 0x10100000006
     0.06%             perf  [kernel.kallsyms]     [k] copy_user_generic_string                  
                       |
                       --- copy_user_generic_string
                          |          
                          |--99.82%-- generic_file_buffered_write
                          |          __generic_file_aio_write
                          |          generic_file_aio_write
                          |          ext4_file_write
                          |          do_sync_write
                          |          vfs_write
                          |          sys_write
                          |          system_call_fastpath
                          |          write
                          |          run_builtin
                          |          main
                          |          __libc_start_main
                           --0.18%-- [...]
     0.05%         qemu-kvm  [kernel.kallsyms]     [k] compact_checklock_irqsave                 
                   |
                   --- compact_checklock_irqsave
                      |          
                      |--82.09%-- isolate_migratepages_range
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
                      |          |--54.69%-- 0x10100000002
                      |          |          
                      |           --45.31%-- 0x10100000006
                      |          
                       --17.91%-- compact_zone
                                 compact_zone_order
                                 try_to_compact_pages
                                 __alloc_pages_direct_compact
                                 __alloc_pages_nodemask
                                 alloc_pages_vma
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
                                 |--59.49%-- 0x10100000002
                                 |          
                                  --40.51%-- 0x10100000006
     0.04%         qemu-kvm  [kernel.kallsyms]     [k] call_function_interrupt                   
                   |
                   --- call_function_interrupt
                      |          
                      |--91.95%-- compact_checklock_irqsave
                      |          isolate_migratepages_range
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
                      |          |--72.81%-- 0x10100000006
                      |          |          
                      |           --27.19%-- 0x10100000002
                      |          
                      |--7.50%-- compact_zone
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
                      |          |--55.56%-- 0x10100000006
                      |          |          
                      |           --44.44%-- 0x10100000002
                       --0.56%-- [...]
     0.04%             ksmd  [kernel.kallsyms]     [k] default_send_IPI_mask_sequence_phys       
                       |
                       --- default_send_IPI_mask_sequence_phys
                          |          
                          |--99.44%-- physflat_send_IPI_mask
                          |          native_send_call_func_ipi
                          |          smp_call_function_many
                          |          native_flush_tlb_others
                          |          flush_tlb_page
                          |          ptep_clear_flush
                          |          try_to_merge_with_ksm_page
                          |          ksm_scan_thread
                          |          kthread
                          |          kernel_thread_helper
                          |          
                           --0.56%-- native_send_call_func_ipi
                                     smp_call_function_many
                                     native_flush_tlb_others
                                     flush_tlb_page
                                     ptep_clear_flush
                                     try_to_merge_with_ksm_page
                                     ksm_scan_thread
                                     kthread
                                     kernel_thread_helper
     0.03%         qemu-kvm  [kernel.kallsyms]     [k] generic_smp_call_function_interrupt       
                   |
                   --- generic_smp_call_function_interrupt
                      |          
                      |--96.97%-- smp_call_function_interrupt
                      |          call_function_interrupt
                      |          |          
                      |          |--97.39%-- compact_checklock_irqsave
                      |          |          isolate_migratepages_range
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
                      |          |          |--78.65%-- 0x10100000006
                      |          |          |          
                      |          |           --21.35%-- 0x10100000002
                      |          |          
                      |          |--2.43%-- compact_zone
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
                      |          |          |--57.14%-- 0x10100000002
                      |          |          |          
                      |          |           --42.86%-- 0x10100000006
                      |           --0.19%-- [...]
                      |          
                       --3.03%-- call_function_interrupt
                                 |          
                                 |--77.79%-- compact_checklock_irqsave
                                 |          isolate_migratepages_range
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
                                 |          |--71.42%-- 0x10100000006
                                 |          |          
                                 |           --28.58%-- 0x10100000002
                                 |          
                                  --22.21%-- compact_zone
                                            compact_zone_order
                                            try_to_compact_pages
                                            __alloc_pages_direct_compact
                                            __alloc_pages_nodemask
                                            alloc_pages_vma
                                            do_huge_pmd_anonymous_page
                                            handle_mm_fault
                                            __get_user_pages
                                            get_user_page_nowait
                                            hva_to_pfn.isra.17
                                            __gfn_to_pfn
                                            gfn_to_pfn_async

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
