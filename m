Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id CF1466B002B
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:15:25 -0400 (EDT)
Date: Fri, 21 Sep 2012 10:15:19 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [PATCH 0/6] Reduce compaction scanning and lock contention
Message-ID: <20120921091519.GB32081@alpha.arachsys.com>
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
> Here is a typical test with these patches:
> 
> # grep -F '[k]' report | head -8
>     65.20%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
>      2.18%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
>      1.56%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock
>      1.40%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
>      1.38%          swapper  [kernel.kallsyms]     [k] default_idle
>      1.35%         qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist
>      0.74%             ksmd  [kernel.kallsyms]     [k] memcmp
>      0.72%         qemu-kvm  [kernel.kallsyms]     [k] free_pages_prepare

# ========
# captured on: Fri Sep 21 08:29:36 2012
# os release : 3.6.0-rc5-elastic+
# perf version : 3.5.2
# arch : x86_64
# nrcpus online : 16
# nrcpus avail : 16
# cpudesc : AMD Opteron(tm) Processor 6128
# cpuid : AuthenticAMD,16,9,1
# total memory : 131973276 kB
# cmdline : /home/root/bin/perf record -g -a 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# HEADER_NUMA_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 837K of event 'cycles'
# Event count (approx.): 290328521160
#
# Overhead          Command         Shared Object                                      Symbol
# ........  ...............  ....................  ..........................................
#
    65.20%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                          
                   |
                   --- clear_page_c
                      |          
                      |--98.02%-- do_huge_pmd_anonymous_page
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
                      |          |--56.65%-- 0x10100000002
                      |          |          
                      |          |--43.35%-- 0x10100000006
                      |           --0.00%-- [...]
                      |          
                       --1.98%-- __alloc_pages_nodemask
                                 |          
                                 |--91.16%-- alloc_pages_vma
                                 |          handle_pte_fault
                                 |          |          
                                 |          |--99.74%-- handle_mm_fault
                                 |          |          |          
                                 |          |          |--99.93%-- __get_user_pages
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
                                 |          |          |          |--86.42%-- 0x10100000006
                                 |          |          |          |          
                                 |          |          |           --13.58%-- 0x10100000002
                                 |          |           --0.07%-- [...]
                                 |           --0.26%-- [...]
                                 |          
                                  --8.84%-- alloc_pages_current
                                            |          
                                            |--99.73%-- pte_alloc_one
                                            |          |          
                                            |          |--97.60%-- do_huge_pmd_anonymous_page
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
                                            |          |          |--60.84%-- 0x10100000002
                                            |          |          |          
                                            |          |           --39.16%-- 0x10100000006
                                            |          |          
                                            |           --2.40%-- __pte_alloc
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
                                             --0.27%-- [...]
     2.18%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block               
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
                      |--92.03%-- 0x10100000006
                      |          
                       --7.97%-- 0x10100000002
     1.58%         qemu-kvm  qemu-kvm              [.] 0x000000000015b95b                    
                   |          
                   |--2.54%-- 0x652b11
                   |          
                   |--2.19%-- 0x55b9ba
                   |          |          
                   |           --100.00%-- 0x0
                   |          
                   |--2.04%-- 0x56b990
                   |          |          
                   |          |--71.82%-- 0x100000008
                   |          |          
                   |          |--25.52%-- 0xfed00000
                   |          |          |          
                   |          |           --100.00%-- 0x0
                   |          |          
                   |          |--2.11%-- 0xfee00000
                   |          |          
                   |           --0.55%-- 0x100000009
                   |          
                   |--0.95%-- 0x5ac46a
                   |          |          
                   |          |--89.44%-- 0x10100000002
                   |          |          
                   |           --10.56%-- 0x10100000006
                   |          
                   |--0.75%-- 0x5ad00b
                   |          |          
                   |          |--93.06%-- 0x10100000002
                   |          |          
                   |           --6.94%-- 0x10100000006
                   |          
                   |--0.73%-- 0x56b999
                   |          |          
                   |          |--68.98%-- 0x100000008
                   |          |          
                   |          |--29.58%-- 0xfed00000
                   |          |          |          
                   |          |           --100.00%-- 0x0
                   |          |          
                   |           --1.43%-- 0xfee00000
                   |          
                   |--0.73%-- 0x664a8f
                   |          0x6e6f6d
                   |          
                   |--0.70%-- 0x5acf38
                   |          |          
                   |          |--78.42%-- 0x10100000002
                   |          |          
                   |          |--20.00%-- 0x10100000006
                   |          |          
                   |           --1.58%-- 0x0
                   |          
                   |--0.65%-- 0x458de4
                   |          |          
                   |          |--33.45%-- 0x2f1a310
                   |          |          0x0
                   |          |          
                   |          |--27.60%-- 0x3014310
                   |          |          0x0
                   |          |          
                   |          |--23.23%-- 0x2b1b310
                   |          |          0x0
                   |          |          
                   |          |--5.04%-- 0x0
                   |          |          
                   |          |--2.08%-- 0x840f01fa8338578b
                   |          |          
                   |          |--1.68%-- 0x2f1f450
                   |          |          0x0
                   |          |          
                   |          |--1.27%-- 0x80d504c748000000
                   |          |          
                   |          |--1.12%-- 0x78840ff685450040
                   |          |          
                   |          |--1.05%-- 0x48ffef5b8ae8c031
                   |          |          
                   |          |--0.92%-- 0x3cd5cc05c70000
                   |          |          
                   |          |--0.88%-- 0x200bd7e0f05
                   |          |          
                   |          |--0.88%-- 0x1dc0be00791856ba
                   |          |          
                   |           --0.79%-- 0x485390fff4d921e8
                   |          
                   |--0.63%-- 0x664a82
                   |          |          
                   |          |--95.74%-- 0x6e6f6d
                   |          |          
                   |           --4.26%-- 0x2540627568006563
                   |          
                   |--0.63%-- 0x664a85
                   |          0x6e6f6d
                   |          
                   |--0.51%-- 0x594ce4
                   |          |          
                   |          |--45.13%-- 0x2b1b310
                   |          |          0x0
                   |          |          
                   |          |--24.91%-- 0x3014310
                   |          |          0x0
                   |          |          
                   |          |--24.18%-- 0x2f1a310
                   |          |          0x0
                   |          |          
                   |          |--1.73%-- 0x0
                   |          |          
                   |          |--1.64%-- 0x7000000
                   |          |          0x2a1e3c0
                   |          |          
                   |          |--1.43%-- 0x75005a6a2f053348
                   |          |          
                   |           --0.97%-- 0x440f4c1045894908
                   |          
                   |--0.51%-- 0x52fb44
                   |          |          
                   |          |--56.61%-- 0x10100000002
                   |          |          
                   |          |--34.56%-- 0x0
                   |          |          |          
                   |          |           --100.00%-- 0x2f3e590
                   |          |          
                   |           --8.83%-- 0x10100000006
                    --86.43%-- [...]
     1.56%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock                        
                   |
                   --- _raw_spin_lock
                      |          
                      |--41.47%-- tdp_page_fault
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
                      |          |--76.14%-- 0x10100000006
                      |          |          
                      |           --23.86%-- 0x10100000002
                      |          
                      |--11.06%-- kvm_mmu_load
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--53.21%-- 0x10100000002
                      |          |          
                      |           --46.79%-- 0x10100000006
                      |          
                      |--7.91%-- follow_page
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
                      |          |--86.50%-- 0x10100000006
                      |          |          
                      |           --13.50%-- 0x10100000002
                      |          
                      |--6.97%-- mmu_free_roots
                      |          |          
                      |          |--76.89%-- nonpaging_free
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
                      |          |          |--50.62%-- 0x10100000006
                      |          |          |          
                      |          |           --49.38%-- 0x10100000002
                      |          |          
                      |           --23.11%-- kvm_mmu_unload
                      |                     kvm_arch_vcpu_ioctl_run
                      |                     kvm_vcpu_ioctl
                      |                     do_vfs_ioctl
                      |                     sys_ioctl
                      |                     system_call_fastpath
                      |                     ioctl
                      |                     |          
                      |                     |--52.88%-- 0x10100000002
                      |                     |          
                      |                      --47.12%-- 0x10100000006
                      |          
                      |--6.91%-- kvm_mmu_page_fault
                      |          pf_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--82.74%-- 0x10100000006
                      |          |          
                      |           --17.26%-- 0x10100000002
                      |          
                      |--3.62%-- yield_to
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
                      |          |--54.40%-- 0x10100000006
                      |          |          
                      |           --45.60%-- 0x10100000002
                      |          
                      |--2.15%-- kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--61.48%-- 0x10100000002
                      |          |          
                      |           --38.52%-- 0x10100000006
                      |          
                      |--1.99%-- grab_super_passive
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
                      |          |--86.97%-- 0x10100000006
                      |          |          
                      |           --13.03%-- 0x10100000002
                      |          
                      |--1.95%-- put_super
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
                      |          |--86.46%-- 0x10100000006
                      |          |          
                      |           --13.54%-- 0x10100000002
                      |          
                      |--1.93%-- __get_user_pages
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
                      |          |--84.17%-- 0x10100000006
                      |          |          
                      |           --15.83%-- 0x10100000002
                      |          
                      |--1.78%-- handle_pte_fault
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
                      |          |--83.19%-- 0x10100000006
                      |          |          
                      |           --16.81%-- 0x10100000002
                      |          
                      |--1.33%-- free_pcppages_bulk
                      |          |          
                      |          |--83.72%-- drain_pages
                      |          |          |          
                      |          |          |--99.41%-- drain_local_pages
                      |          |          |          generic_smp_call_function_interrupt
                      |          |          |          smp_call_function_interrupt
                      |          |          |          call_function_interrupt
                      |          |          |          |          
                      |          |          |          |--42.28%-- kvm_vcpu_ioctl
                      |          |          |          |          do_vfs_ioctl
                      |          |          |          |          sys_ioctl
                      |          |          |          |          system_call_fastpath
                      |          |          |          |          ioctl
                      |          |          |          |          |          
                      |          |          |          |          |--83.98%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --16.02%-- 0x10100000002
                      |          |          |          |          
                      |          |          |          |--8.49%-- __alloc_pages_nodemask
                      |          |          |          |          alloc_pages_vma
                      |          |          |          |          handle_pte_fault
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
                      |          |          |          |          |--80.36%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --19.64%-- 0x10100000002
                      |          |          |          |          
                      |          |          |          |--6.53%-- __remove_mapping
                      |          |          |          |          shrink_page_list
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
                      |          |          |          |          0x10100000006
                      |          |          |          |          
                      |          |          |          |--6.20%-- buffer_migrate_page
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
                      |          |          |          |          |          
                      |          |          |          |          |--83.97%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --16.03%-- 0x10100000002
                      |          |          |          |          
                      |          |          |          |--5.34%-- __get_user_pages
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
                      |          |          |          |          |--79.01%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --20.99%-- 0x10100000002
                      |          |          |          |          
                      |          |          |          |--3.98%-- compact_checklock_irqsave
                      |          |          |          |          isolate_freepages_block
                      |          |          |          |          compaction_alloc
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
                      |          |          |          |--3.48%-- do_huge_pmd_anonymous_page
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
                      |          |          |          |          |--83.45%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --16.55%-- 0x10100000002
                      |          |          |          |          
                      |          |          |          |--2.91%-- hva_to_pfn.isra.17
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
                      |          |          |          |          |--79.66%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --20.34%-- 0x10100000002
                      |          |          |          |          
                      |          |          |          |--2.85%-- tdp_page_fault
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
                      |          |          |          |--2.45%-- compaction_alloc
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
                      |          |          |          |          |--59.53%-- 0x10100000006
                      |          |          |          |          |          
                      |          |          |          |           --40.47%-- 0x10100000002
                      |          |          |          |          
                      |          |          |          |--2.14%-- kvm_vcpu_yield_to
                      |          |          |          |          kvm_vcpu_on_spin
                      |          |          |          |          pause_interception
                      |          |          |          |          handle_exit
                      |          |          |          |          kvm_arch_vcpu_ioctl_run
                      |          |          |          |          kvm_vcpu_ioctl
                      |          |          |          |          do_vfs_ioctl
                      |          |          |          |          sys_ioctl
                      |          |          |          |          system_call_fastpath
                      |          |          |          |          ioctl
                      |          |          |          |          0x10100000006
                      |          |          |          |          
                      |          |          |          |--1.15%-- handle_mm_fault
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
                      |          |          |          |--0.99%-- putback_lru_page
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
                      |          |          |          |--0.98%-- timer_gettime
                      |          |          |          |          
                      |          |          |          |--0.97%-- native_flush_tlb_others
                      |          |          |          |          flush_tlb_page
                      |          |          |          |          ptep_clear_flush_young
                      |          |          |          |          page_referenced_one
                      |          |          |          |          page_referenced
                      |          |          |          |          shrink_active_list
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
                      |          |          |          |          0x10100000006
                      |          |          |          |          
                      |          |          |          |--0.97%-- try_to_free_buffers
                      |          |          |          |          jbd2_journal_try_to_free_buffers
                      |          |          |          |          ext4_releasepage
                      |          |          |          |          try_to_release_page
                      |          |          |          |          shrink_page_list
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
                      |          |          |          |          0x10100000006
                      |          |          |          |          
                      |          |          |          |--0.86%-- shrink_inactive_list
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
                      |          |          |          |          0x10100000006
                      |          |          |          |          
                      |          |          |          |--0.86%-- __mutex_lock_slowpath
                      |          |          |          |          mutex_lock
                      |          |          |          |          page_lock_anon_vma
                      |          |          |          |          page_referenced
                      |          |          |          |          shrink_active_list
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
                      |          |          |          |          0x10100000002
                      |          |          |          |          
                      |          |          |          |--0.83%-- kvm_arch_vcpu_ioctl_run
                      |          |          |          |          kvm_vcpu_ioctl
                      |          |          |          |          do_vfs_ioctl
                      |          |          |          |          sys_ioctl
                      |          |          |          |          system_call_fastpath
                      |          |          |          |          ioctl
                      |          |          |          |          0x10100000006
                      |          |          |          |          
                      |          |          |          |--0.62%-- __direct_map.isra.103
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
                      |          |          |          |--0.61%-- gfn_to_hva
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
                      |          |          |          |--0.60%-- mmu_set_spte.isra.100
                      |          |          |          |          __direct_map.isra.103
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
                      |          |          |          |--0.59%-- mmu_spte_update
                      |          |          |          |          set_spte
                      |          |          |          |          mmu_set_spte.isra.100
                      |          |          |          |          __direct_map.isra.103
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
                      |          |          |          |--0.59%-- kvm_vcpu_on_spin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
