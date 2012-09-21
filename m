Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 7D7E96B005D
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:18:22 -0400 (EDT)
Date: Fri, 21 Sep 2012 10:18:14 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [PATCH 0/6] Reduce compaction scanning and lock contention
Message-ID: <20120921091814.GD32081@alpha.arachsys.com>
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
...
> # grep -F '[k]' report | head -8
>     61.29%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
>      4.52%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave
>      2.64%       qemu-kvm  [kernel.kallsyms]     [k] copy_page_c
>      1.61%        swapper  [kernel.kallsyms]     [k] default_idle
>      1.57%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock
>      1.18%       qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist
>      1.18%       qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
>      1.11%       qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run

# ========
# captured on: Fri Sep 21 08:40:48 2012
# os release : 3.6.0-rc5-elastic+
# perf version : 3.5.2
# arch : x86_64
# nrcpus online : 16
# nrcpus avail : 16
# cpudesc : AMD Opteron(tm) Processor 6128
# cpuid : AuthenticAMD,16,9,1
# total memory : 131973276 kB
# cmdline : /home/root/bin/perf record -g -a 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# HEADER_NUMA_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 914K of event 'cycles'
# Event count (approx.): 328377288871
#
# Overhead        Command         Shared Object                                          Symbol
# ........  .............  ....................  ..............................................
#
    61.29%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                              
                 |
                 --- clear_page_c
                    |          
                    |--98.26%-- do_huge_pmd_anonymous_page
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
                    |          |--67.45%-- 0x10100000006
                    |          |          
                    |           --32.55%-- 0x10100000002
                    |          
                     --1.74%-- __alloc_pages_nodemask
                               |          
                               |--91.69%-- alloc_pages_vma
                               |          handle_pte_fault
                               |          |          
                               |          |--99.76%-- handle_mm_fault
                               |          |          |          
                               |          |          |--99.78%-- __get_user_pages
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
                               |          |          |          |--98.56%-- 0x10100000006
                               |          |          |          |          
                               |          |          |           --1.44%-- 0x10100000002
                               |          |           --0.22%-- [...]
                               |           --0.24%-- [...]
                               |          
                                --8.31%-- alloc_pages_current
                                          |          
                                          |--99.43%-- pte_alloc_one
                                          |          |          
                                          |          |--97.72%-- do_huge_pmd_anonymous_page
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
                                          |          |          |--56.04%-- 0x10100000006
                                          |          |          |          
                                          |          |           --43.96%-- 0x10100000002
                                          |          |          
                                          |           --2.28%-- __pte_alloc
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
                                           --0.57%-- [...]
     4.52%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave                    
                 |
                 --- _raw_spin_lock_irqsave
                    |          
                    |--90.15%-- compact_checklock_irqsave
                    |          |          
                    |          |--99.77%-- isolate_migratepages_range
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
                    |          |          |--94.58%-- 0x10100000006
                    |          |          |          
                    |          |           --5.42%-- 0x10100000002
                    |           --0.23%-- [...]
                    |          
                    |--3.60%-- isolate_migratepages_range
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
                    |          |--91.30%-- 0x10100000006
                    |          |          
                    |           --8.70%-- 0x10100000002
                    |          
                    |--2.26%-- pagevec_lru_move_fn
                    |          __pagevec_lru_add
                    |          |          
                    |          |--96.55%-- __lru_cache_add
                    |          |          lru_cache_add_lru
                    |          |          |          
                    |          |          |--96.23%-- putback_lru_page
                    |          |          |          |          
                    |          |          |          |--98.46%-- migrate_pages
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
                    |          |          |          |          |--91.70%-- 0x10100000006
                    |          |          |          |          |          
                    |          |          |          |           --8.30%-- 0x10100000002
                    |          |          |          |          
                    |          |          |           --1.54%-- putback_lru_pages
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
                    |          |           --3.77%-- page_add_new_anon_rmap
                    |          |                     handle_pte_fault
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
                    |          |                     |--97.54%-- 0x10100000006
                    |          |                     |          
                    |          |                      --2.46%-- 0x10100000002
                    |          |          
                    |           --3.45%-- lru_add_drain_cpu
                    |                     lru_add_drain
                    |                     migrate_prep_local
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
                    |                     0x10100000006
                    |          
                    |--1.58%-- release_pages
                    |          pagevec_lru_move_fn
                    |          __pagevec_lru_add
                    |          |          
                    |          |--98.25%-- __lru_cache_add
                    |          |          lru_cache_add_lru
                    |          |          putback_lru_page
                    |          |          |          
                    |          |          |--99.42%-- migrate_pages
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
                    |          |          |          |--95.23%-- 0x10100000006
                    |          |          |          |          
                    |          |          |           --4.77%-- 0x10100000002
                    |          |          |          
                    |          |           --0.58%-- putback_lru_pages
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
                    |           --1.75%-- lru_add_drain_cpu
                    |                     lru_add_drain
                    |                     migrate_prep_local
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
                    |                     |--80.09%-- 0x10100000006
                    |                     |          
                    |                      --19.91%-- 0x10100000002
                    |          
                    |--0.99%-- __page_cache_release.part.11
                    |          __put_single_page
                    |          put_page
                    |          putback_lru_page
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
                    |          |--92.20%-- 0x10100000006
                    |          |          
                    |           --7.80%-- 0x10100000002
                     --1.42%-- [...]
     2.64%       qemu-kvm  [kernel.kallsyms]     [k] copy_page_c                               
                 |
                 --- copy_page_c
                    |          
                    |--75.79%-- buffer_migrate_page
                    |          move_to_new_page
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
                    |          |--98.86%-- 0x10100000006
                    |          |          
                    |           --1.14%-- 0x10100000002
                    |          
                    |--24.08%-- migrate_page
                    |          |          
                    |          |--82.12%-- buffer_migrate_page
                    |          |          move_to_new_page
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
                    |          |          |--98.08%-- 0x10100000006
                    |          |          |          
                    |          |           --1.92%-- 0x10100000002
                    |          |          
                    |           --17.88%-- move_to_new_page
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
                    |                     |--99.21%-- 0x10100000006
                    |                     |          
                    |                      --0.79%-- 0x10100000002
                     --0.13%-- [...]
     1.61%        swapper  [kernel.kallsyms]     [k] default_idle                              
                  |
                  --- default_idle
                     |          
                     |--99.76%-- cpu_idle
                     |          |          
                     |          |--77.77%-- start_secondary
                     |          |          
                     |           --22.23%-- rest_init
                     |                     start_kernel
                     |                     x86_64_start_reservations
                     |                     x86_64_start_kernel
                      --0.24%-- [...]
     1.57%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock                            
                 |
                 --- _raw_spin_lock
                    |          
                    |--37.29%-- tdp_page_fault
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
                    |          |--89.54%-- 0x10100000006
                    |          |          
                    |           --10.46%-- 0x10100000002
                    |          
                    |--9.09%-- kvm_mmu_load
                    |          kvm_arch_vcpu_ioctl_run
                    |          kvm_vcpu_ioctl
                    |          do_vfs_ioctl
                    |          sys_ioctl
                    |          system_call_fastpath
                    |          ioctl
                    |          |          
                    |          |--59.75%-- 0x10100000006
                    |          |          
                    |           --40.25%-- 0x10100000002
                    |          
                    |--8.00%-- follow_page
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
                    |          |--98.39%-- 0x10100000006
                    |          |          
                    |           --1.61%-- 0x10100000002
                    |          
                    |--7.17%-- kvm_mmu_page_fault
                    |          pf_interception
                    |          handle_exit
                    |          kvm_arch_vcpu_ioctl_run
                    |          kvm_vcpu_ioctl
                    |          do_vfs_ioctl
                    |          sys_ioctl
                    |          system_call_fastpath
                    |          ioctl
                    |          |          
                    |          |--94.45%-- 0x10100000006
                    |          |          
                    |           --5.55%-- 0x10100000002
                    |          
                    |--5.65%-- mmu_free_roots
                    |          |          
                    |          |--76.51%-- nonpaging_free
                    |          |          kvm_mmu_reset_context
                    |          |          kvm_set_cr4
                    |          |          emulator_set_cr
                    |          |          em_cr_write
                    |          |          x86_emulate_insn
                    |          |          x86_emulate_instruction
                    |          |          emulate_on_interception
                    |          |          cr_interception
                    |          |          handle_exit
                    |          |          kvm_arch_vcpu_ioctl_run
                    |          |          kvm_vcpu_ioctl
                    |          |          do_vfs_ioctl
                    |          |          sys_ioctl
                    |          |          system_call_fastpath
                    |          |          ioctl
                    |          |          |          
                    |          |          |--64.15%-- 0x10100000006
                    |          |          |          
                    |          |           --35.85%-- 0x10100000002
                    |          |          
                    |           --23.49%-- kvm_mmu_unload
                    |                     kvm_arch_vcpu_ioctl_run
                    |                     kvm_vcpu_ioctl
                    |                     do_vfs_ioctl
                    |                     sys_ioctl
                    |                     system_call_fastpath
                    |                     ioctl
                    |                     |          
                    |                     |--73.65%-- 0x10100000006
                    |                     |          
                    |                      --26.35%-- 0x10100000002
                    |          
                    |--4.61%-- put_super
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
                    |          |--93.31%-- 0x10100000006
                    |          |          
                    |           --6.69%-- 0x10100000002
                    |          
                    |--4.60%-- grab_super_passive
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
                    |          |--95.07%-- 0x10100000006
                    |          |          
                    |           --4.93%-- 0x10100000002
                    |          
                    |--3.94%-- yield_to
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
                    |          |--86.93%-- 0x10100000006
                    |          |          
                    |           --13.07%-- 0x10100000002
                    |          
                    |--3.08%-- free_pcppages_bulk
                    |          |          
                    |          |--89.90%-- drain_pages
                    |          |          |          
                    |          |          |--95.03%-- drain_local_pages
                    |          |          |          generic_smp_call_function_interrupt
                    |          |          |          smp_call_function_interrupt
                    |          |          |          call_function_interrupt
                    |          |          |          |          
                    |          |          |          |--29.99%-- buffer_migrate_page
                    |          |          |          |          move_to_new_page
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
                    |          |          |          |          0x10100000006
                    |          |          |          |          
                    |          |          |          |--13.18%-- kvm_vcpu_ioctl
                    |          |          |          |          do_vfs_ioctl
                    |          |          |          |          sys_ioctl
                    |          |          |          |          system_call_fastpath
                    |          |          |          |          ioctl
                    |          |          |          |          |          
                    |          |          |          |          |--98.30%-- 0x10100000006
                    |          |          |          |          |          
                    |          |          |          |           --1.70%-- 0x10100000002
                    |          |          |          |          
                    |          |          |          |--8.86%-- compact_checklock_irqsave
                    |          |          |          |          |          
                    |          |          |          |          |--65.32%-- isolate_migratepages_range
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
                    |          |          |          |          |          |--94.13%-- 0x10100000006
                    |          |          |          |          |          |          
                    |          |          |          |          |           --5.87%-- 0x10100000002
                    |          |          |          |          |          
                    |          |          |          |           --34.68%-- isolate_freepages_block
                    |          |          |          |                     compaction_alloc
                    |          |          |          |                     migrate_pages
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
                    |          |          |          |--8.21%-- migrate_page
                    |          |          |          |          |          
                    |          |          |          |          |--91.65%-- buffer_migrate_page
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
                    |          |          |          |           --8.35%-- move_to_new_page
                    |          |          |          |                     migrate_pages
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
                    |          |          |          |--6.16%-- do_huge_pmd_anonymous_page
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
                    |          |          |          |          0x10100000006
                    |          |          |          |          
                    |          |          |          |--5.39%-- isolate_migratepages_range
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
                    |          |          |          |          0x10100000006
                    |          |          |          |          
                    |          |          |          |--3.59%-- compaction_alloc
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
                    |          |          |          |          0x10100000006
                    |          |          |          |          
                    |          |          |          |--3.19%-- migrate_page_move_mapping.part.16
                    |          |          |          |          |          
                    |          |          |          |          |--89.86%-- buffer_migrate_page
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
