Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 45F606B002B
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:17:11 -0400 (EDT)
Date: Fri, 21 Sep 2012 10:17:01 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [PATCH 0/6] Reduce compaction scanning and lock contention
Message-ID: <20120921091701.GC32081@alpha.arachsys.com>
References: <1348149875-29678-1-git-send-email-mgorman@suse.de>
 <20120921091333.GA32081@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120921091333.GA32081@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Richard Davies wrote:
> I did manage to get a couple which were slightly worse, but nothing like as
> bad as before. Here are the results:
> 
> # grep -F '[k]' report | head -8
>     45.60%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
>     11.26%       qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
>      3.21%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock
>      2.27%           ksmd  [kernel.kallsyms]     [k] memcmp
>      2.02%        swapper  [kernel.kallsyms]     [k] default_idle
>      1.58%       qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
>      1.30%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave
>      1.09%       qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist

# ========
# captured on: Fri Sep 21 08:17:52 2012
# os release : 3.6.0-rc5-elastic+
# perf version : 3.5.2
# arch : x86_64
# nrcpus online : 16
# nrcpus avail : 16
# cpudesc : AMD Opteron(tm) Processor 6128
# cpuid : AuthenticAMD,16,9,1
# total memory : 131973276 kB
# cmdline : /home/root/bin/perf record -g -a 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# HEADER_NUMA_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 283K of event 'cycles'
# Event count (approx.): 109057976176
#
# Overhead        Command         Shared Object                                          Symbol
# ........  .............  ....................  ..............................................
#
    45.60%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                              
                 |
                 --- clear_page_c
                    |          
                    |--93.35%-- do_huge_pmd_anonymous_page
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
                    |          
                     --6.65%-- __alloc_pages_nodemask
                               |          
                               |--98.71%-- alloc_pages_vma
                               |          handle_pte_fault
                               |          |          
                               |          |--99.78%-- handle_mm_fault
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
                               |          |          |--98.94%-- 0x10100000006
                               |          |          |          
                               |          |           --1.06%-- 0x10100000002
                               |           --0.22%-- [...]
                               |          
                                --1.29%-- alloc_pages_current
                                          pte_alloc_one
                                          |          
                                          |--80.44%-- do_huge_pmd_anonymous_page
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
                                          |          |--89.97%-- 0x10100000006
                                          |          |          
                                          |           --10.03%-- 0x10100000002
                                          |          
                                           --19.56%-- __pte_alloc
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
    11.26%       qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block                   
                 |
                 --- isolate_freepages_block
                     compaction_alloc
                     migrate_pages
                     compact_zone
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
                    |--96.34%-- 0x10100000006
                    |          
                     --3.66%-- 0x10100000002
     3.21%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock                            
                 |
                 --- _raw_spin_lock
                    |          
                    |--39.96%-- tdp_page_fault
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
                    |          |--99.27%-- 0x10100000006
                    |          |          
                    |           --0.73%-- 0x10100000002
                    |          
                    |--8.69%-- follow_page
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
                    |          |--98.41%-- 0x10100000006
                    |          |          
                    |           --1.59%-- 0x10100000002
                    |          
                    |--8.12%-- kvm_mmu_page_fault
                    |          pf_interception
                    |          handle_exit
                    |          kvm_arch_vcpu_ioctl_run
                    |          kvm_vcpu_ioctl
                    |          do_vfs_ioctl
                    |          sys_ioctl
                    |          system_call_fastpath
                    |          ioctl
                    |          |          
                    |          |--99.54%-- 0x10100000006
                    |           --0.46%-- [...]
                    |          
                    |--7.52%-- kvm_mmu_load
                    |          kvm_arch_vcpu_ioctl_run
                    |          kvm_vcpu_ioctl
                    |          do_vfs_ioctl
                    |          sys_ioctl
                    |          system_call_fastpath
                    |          ioctl
                    |          |          
                    |          |--99.16%-- 0x10100000006
                    |          |          
                    |           --0.84%-- 0x10100000002
                    |          
                    |--7.42%-- grab_super_passive
                    |          prune_super
                    |          shrink_slab
                    |          try_to_free_pages
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
                    |          |--93.29%-- 0x10100000006
                    |          |          
                    |           --6.71%-- 0x10100000002
                    |          
                    |--7.14%-- put_super
                    |          drop_super
                    |          prune_super
                    |          shrink_slab
                    |          try_to_free_pages
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
                    |          |--94.13%-- 0x10100000006
                    |          |          
                    |           --5.87%-- 0x10100000002
                    |          
                    |--5.17%-- mmu_free_roots
                    |          nonpaging_free
                    |          kvm_mmu_reset_context
                    |          kvm_set_cr4
                    |          emulator_set_cr
                    |          em_cr_write
                    |          x86_emulate_insn
                    |          x86_emulate_instruction
                    |          emulate_on_interception
                    |          cr_interception
                    |          handle_exit
                    |          kvm_arch_vcpu_ioctl_run
                    |          kvm_vcpu_ioctl
                    |          do_vfs_ioctl
                    |          sys_ioctl
                    |          system_call_fastpath
                    |          ioctl
                    |          |          
                    |          |--99.48%-- 0x10100000006
                    |          |          
                    |           --0.52%-- 0x10100000002
                    |          
                    |--2.82%-- yield_to
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
                    |          |--94.58%-- 0x10100000006
                    |          |          
                    |           --5.42%-- 0x10100000002
                    |          
                    |--2.00%-- __get_user_pages
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
                    |          |--99.46%-- 0x10100000006
                    |          |          
                    |           --0.54%-- 0x10100000002
                    |          
                    |--1.69%-- free_pcppages_bulk
                    |          |          
                    |          |--77.53%-- drain_pages
                    |          |          |          
                    |          |          |--95.77%-- drain_local_pages
                    |          |          |          |          
                    |          |          |          |--97.90%-- generic_smp_call_function_interrupt
                    |          |          |          |          smp_call_function_interrupt
                    |          |          |          |          call_function_interrupt
                    |          |          |          |          |          
                    |          |          |          |          |--23.37%-- kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          |          
                    |          |          |          |          |          |--97.22%-- 0x10100000006
                    |          |          |          |          |          |          
                    |          |          |          |          |           --2.78%-- 0x10100000002
                    |          |          |          |          |          
                    |          |          |          |          |--17.80%-- __remove_mapping
                    |          |          |          |          |          shrink_page_list
                    |          |          |          |          |          shrink_inactive_list
                    |          |          |          |          |          shrink_lruvec
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          |          
                    |          |          |          |          |          |--93.60%-- 0x10100000006
                    |          |          |          |          |          |          
                    |          |          |          |          |           --6.40%-- 0x10100000002
                    |          |          |          |          |          
                    |          |          |          |          |--8.81%-- do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--5.95%-- __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          |          
                    |          |          |          |          |          |--80.66%-- handle_pte_fault
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
                    |          |          |          |          |          |          0x10100000006
                    |          |          |          |          |          |          
                    |          |          |          |          |           --19.34%-- do_huge_pmd_anonymous_page
                    |          |          |          |          |                     handle_mm_fault
                    |          |          |          |          |                     __get_user_pages
                    |          |          |          |          |                     get_user_page_nowait
                    |          |          |          |          |                     hva_to_pfn.isra.17
                    |          |          |          |          |                     __gfn_to_pfn
                    |          |          |          |          |                     gfn_to_pfn_async
                    |          |          |          |          |                     try_async_pf
                    |          |          |          |          |                     tdp_page_fault
                    |          |          |          |          |                     kvm_mmu_page_fault
                    |          |          |          |          |                     pf_interception
                    |          |          |          |          |                     handle_exit
                    |          |          |          |          |                     kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |                     kvm_vcpu_ioctl
                    |          |          |          |          |                     do_vfs_ioctl
                    |          |          |          |          |                     sys_ioctl
                    |          |          |          |          |                     system_call_fastpath
                    |          |          |          |          |                     ioctl
                    |          |          |          |          |                     0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--4.38%-- try_to_free_buffers
                    |          |          |          |          |          jbd2_journal_try_to_free_buffers
                    |          |          |          |          |          ext4_releasepage
                    |          |          |          |          |          try_to_release_page
                    |          |          |          |          |          shrink_page_list
                    |          |          |          |          |          shrink_inactive_list
                    |          |          |          |          |          shrink_lruvec
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--4.00%-- isolate_migratepages_range
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--3.37%-- shrink_inactive_list
                    |          |          |          |          |          shrink_lruvec
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--3.33%-- free_hot_cold_page_list
                    |          |          |          |          |          shrink_page_list
                    |          |          |          |          |          shrink_inactive_list
                    |          |          |          |          |          shrink_lruvec
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--2.31%-- compaction_alloc
                    |          |          |          |          |          migrate_pages
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--2.22%-- compact_checklock_irqsave
                    |          |          |          |          |          isolate_migratepages_range
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--2.19%-- shrink_page_list
                    |          |          |          |          |          shrink_inactive_list
                    |          |          |          |          |          shrink_lruvec
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--2.02%-- buffer_migrate_page
                    |          |          |          |          |          move_to_new_page
                    |          |          |          |          |          migrate_pages
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          |          
                    |          |          |          |          |          |--55.61%-- 0x10100000002
                    |          |          |          |          |          |          
                    |          |          |          |          |           --44.39%-- 0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.42%-- mmu_set_spte.isra.100
                    |          |          |          |          |          __direct_map.isra.103
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.16%-- on_each_cpu_mask
                    |          |          |          |          |          drain_all_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000002
                    |          |          |          |          |          
                    |          |          |          |          |--1.16%-- compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.15%-- compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.15%-- grab_super_passive
                    |          |          |          |          |          prune_super
                    |          |          |          |          |          shrink_slab
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.15%-- drop_super
                    |          |          |          |          |          prune_super
                    |          |          |          |          |          shrink_slab
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.14%-- finish_task_switch
                    |          |          |          |          |          __schedule
                    |          |          |          |          |          schedule
                    |          |          |          |          |          schedule_preempt_disabled
                    |          |          |          |          |          __mutex_lock_slowpath
                    |          |          |          |          |          mutex_lock
                    |          |          |          |          |          rmap_walk
                    |          |          |          |          |          move_to_new_page
                    |          |          |          |          |          migrate_pages
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.13%-- smp_call_function_many
                    |          |          |          |          |          native_flush_tlb_others
                    |          |          |          |          |          flush_tlb_page
                    |          |          |          |          |          ptep_clear_flush
                    |          |          |          |          |          try_to_unmap_one
                    |          |          |          |          |          try_to_unmap_anon
                    |          |          |          |          |          try_to_unmap
                    |          |          |          |          |          migrate_pages
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.13%-- release_pages
                    |          |          |          |          |          pagevec_lru_move_fn
                    |          |          |          |          |          __pagevec_lru_add
                    |          |          |          |          |          __lru_cache_add
                    |          |          |          |          |          lru_cache_add_lru
                    |          |          |          |          |          putback_lru_page
                    |          |          |          |          |          migrate_pages
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.10%-- move_to_new_page
                    |          |          |          |          |          migrate_pages
                    |          |          |          |          |          compact_zone
                    |          |          |          |          |          compact_zone_order
                    |          |          |          |          |          try_to_compact_pages
                    |          |          |          |          |          __alloc_pages_direct_compact
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--1.09%-- free_hot_cold_page
                    |          |          |          |          |          free_hot_cold_page_list
                    |          |          |          |          |          shrink_page_list
                    |          |          |          |          |          shrink_inactive_list
                    |          |          |          |          |          shrink_lruvec
                    |          |          |          |          |          try_to_free_pages
                    |          |          |          |          |          __alloc_pages_nodemask
                    |          |          |          |          |          alloc_pages_vma
                    |          |          |          |          |          do_huge_pmd_anonymous_page
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17
                    |          |          |          |          |          __gfn_to_pfn
                    |          |          |          |          |          gfn_to_pfn_async
                    |          |          |          |          |          try_async_pf
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--0.98%-- kvm_host_page_size
                    |          |          |          |          |          mapping_level.isra.88
                    |          |          |          |          |          tdp_page_fault
                    |          |          |          |          |          kvm_mmu_page_fault
                    |          |          |          |          |          pf_interception
                    |          |          |          |          |          handle_exit
                    |          |          |          |          |          kvm_arch_vcpu_ioctl_run
                    |          |          |          |          |          kvm_vcpu_ioctl
                    |          |          |          |          |          do_vfs_ioctl
                    |          |          |          |          |          sys_ioctl
                    |          |          |          |          |          system_call_fastpath
                    |          |          |          |          |          ioctl
                    |          |          |          |          |          0x10100000006
                    |          |          |          |          |          
                    |          |          |          |          |--0.94%-- pagevec_lru_move_fn
                    |          |          |          |          |          __pagevec_lru_add
                    |          |          |          |          |          __lru_cache_add
                    |          |          |          |          |          lru_cache_add_lru
                    |          |          |          |          |          page_add_new_anon_rmap
                    |          |          |          |          |          handle_pte_fault
                    |          |          |          |          |          handle_mm_fault
                    |          |          |          |          |          __get_user_pages
                    |          |          |          |          |          get_user_page_nowait
                    |          |          |          |          |          hva_to_pfn.isra.17

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
