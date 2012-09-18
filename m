Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 423596B0095
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 13:58:49 -0400 (EDT)
Date: Tue, 18 Sep 2012 18:58:38 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
Message-ID: <20120918175838.GA24232@alpha.arachsys.com>
References: <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
 <20120912164615.GA14173@alpha.arachsys.com>
 <20120913154824.44cc0e28@cuia.bos.redhat.com>
 <20120913155450.7634148f@cuia.bos.redhat.com>
 <20120915155524.GA24182@alpha.arachsys.com>
 <20120917122628.GF11266@suse.de>
 <20120918081455.GA16395@alpha.arachsys.com>
 <20120918112122.GM11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120918112122.GM11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

Mel Gorman wrote:
> Ok, this just means the focus has moved to the zone->lock instead of the
> zone->lru_lock. This was expected to some extent. This is an additional
> patch that defers acquisition of the zone->lock for as long as possible.

And I believe you have now beaten the lock contention - congratulations!

> Incidentally, I checked the efficiency of compaction - i.e. how many
> pages scanned versus how many pages isolated and the efficiency
> completely sucks. It must be addressed but addressing the lock
> contention should happen first.

Yes, compaction is now definitely top.

Interestingly, some boots still seem "slow" and some "fast", even without
any lock contention issues. Here are traces from a few different runs, and I
attach the detailed report for the first of these which was one of the slow
ones.

# grep -F '[k]' report.1 | head -8
    55.86%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
    14.98%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
     2.18%         qemu-kvm  [kernel.kallsyms]     [k] yield_to
     1.67%         qemu-kvm  [kernel.kallsyms]     [k] get_pageblock_flags_group
     1.66%         qemu-kvm  [kernel.kallsyms]     [k] compact_zone
     1.56%             ksmd  [kernel.kallsyms]     [k] memcmp
     1.48%          swapper  [kernel.kallsyms]     [k] default_idle
     1.33%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
#
# grep -F '[k]' report.2 | head -8
    38.28%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
     7.58%         qemu-kvm  [kernel.kallsyms]     [k] get_pageblock_flags_group
     7.03%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
     4.72%         qemu-kvm  [kernel.kallsyms]     [k] isolate_migratepages_range
     4.31%         qemu-kvm  [kernel.kallsyms]     [k] copy_page_c
     4.15%         qemu-kvm  [kernel.kallsyms]     [k] compact_zone
     2.68%         qemu-kvm  [kernel.kallsyms]     [k] __zone_watermark_ok
     2.65%         qemu-kvm  [kernel.kallsyms]     [k] yield_to
#
# grep -F '[k]' report.3 | head -8
    75.18%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
     1.82%          swapper  [kernel.kallsyms]     [k] default_idle
     1.29%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
     1.27%         qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist
     1.20%             ksmd  [kernel.kallsyms]     [k] memcmp
     0.83%         qemu-kvm  [kernel.kallsyms]     [k] free_pages_prepare
     0.78%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
     0.59%         qemu-kvm  [kernel.kallsyms]     [k] prep_compound_page
#
# grep -F '[k]' report.4 | head -8
    41.02%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
    32.20%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
     1.76%         qemu-kvm  [kernel.kallsyms]     [k] yield_to
     1.37%          swapper  [kernel.kallsyms]     [k] default_idle
     1.35%             ksmd  [kernel.kallsyms]     [k] memcmp
     1.27%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
     1.23%         qemu-kvm  [kernel.kallsyms]     [k] get_pageblock_flags_group
     0.88%         qemu-kvm  [kernel.kallsyms]     [k] kvm_vcpu_on_spin
#
# grep -F '[k]' report.5 | head -8
    61.18%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
    14.55%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
     1.75%         qemu-kvm  [kernel.kallsyms]     [k] yield_to
     1.31%             ksmd  [kernel.kallsyms]     [k] memcmp
     1.21%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
     1.20%          swapper  [kernel.kallsyms]     [k] default_idle
     1.14%         qemu-kvm  [kernel.kallsyms]     [k] get_pageblock_flags_group
     0.94%         qemu-kvm  [kernel.kallsyms]     [k] kvm_vcpu_on_spin


Here is the detailed report for the first of these:

# ========
# captured on: Tue Sep 18 17:03:40 2012
# os release : 3.6.0-rc5-elastic+
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
# Samples: 3M of event 'cycles'
# Event count (approx.): 1184064513533
#
# Overhead          Command         Shared Object                                          Symbol
# ........  ...............  ....................  ..............................................
#
    55.86%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block                   
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
                      |          |--88.73%-- 0x10100000006
                      |          |          
                      |           --11.27%-- 0x10100000002
                       --0.01%-- [...]
    14.98%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                              
                   |
                   --- clear_page_c
                      |          
                      |--99.84%-- do_huge_pmd_anonymous_page
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
                      |          |--55.15%-- 0x10100000006
                      |          |          
                      |           --44.85%-- 0x10100000002
                       --0.16%-- [...]
     2.18%         qemu-kvm  [kernel.kallsyms]     [k] yield_to                                  
                   |
                   --- yield_to
                      |          
                      |--99.62%-- kvm_vcpu_yield_to
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
                      |          |--83.34%-- 0x10100000006
                      |          |          
                      |           --16.66%-- 0x10100000002
                       --0.38%-- [...]
     1.67%         qemu-kvm  [kernel.kallsyms]     [k] get_pageblock_flags_group                 
                   |
                   --- get_pageblock_flags_group
                      |          
                      |--57.67%-- isolate_migratepages_range
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
                      |          |--86.10%-- 0x10100000006
                      |          |          
                      |           --13.90%-- 0x10100000002
                      |          
                      |--38.10%-- suitable_migration_target
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
                      |          |--88.50%-- 0x10100000006
                      |          |          
                      |           --11.50%-- 0x10100000002
                      |          
                      |--2.23%-- compact_zone
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
                      |          |--85.85%-- 0x10100000006
                      |          |          
                      |           --14.15%-- 0x10100000002
                      |          
                      |--0.88%-- compaction_alloc
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
                      |          |--87.75%-- 0x10100000006
                      |          |          
                      |           --12.25%-- 0x10100000002
                      |          
                      |--0.75%-- free_hot_cold_page
                      |          |          
                      |          |--74.93%-- free_hot_cold_page_list
                      |          |          |          
                      |          |          |--53.13%-- shrink_page_list
                      |          |          |          shrink_inactive_list
                      |          |          |          shrink_lruvec
                      |          |          |          try_to_free_pages
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
                      |          |          |          |--82.85%-- 0x10100000006
                      |          |          |          |          
                      |          |          |           --17.15%-- 0x10100000002
                      |          |          |          
                      |          |           --46.87%-- release_pages
                      |          |                     pagevec_lru_move_fn
                      |          |                     __pagevec_lru_add
                      |          |                     |          
                      |          |                     |--98.13%-- __lru_cache_add
                      |          |                     |          lru_cache_add_lru
                      |          |                     |          putback_lru_page
                      |          |                     |          |          
                      |          |                     |          |--99.02%-- migrate_pages
                      |          |                     |          |          compact_zone
                      |          |                     |          |          compact_zone_order
                      |          |                     |          |          try_to_compact_pages
                      |          |                     |          |          __alloc_pages_direct_compact
                      |          |                     |          |          __alloc_pages_nodemask
                      |          |                     |          |          alloc_pages_vma
                      |          |                     |          |          do_huge_pmd_anonymous_page
                      |          |                     |          |          handle_mm_fault
                      |          |                     |          |          __get_user_pages
                      |          |                     |          |          get_user_page_nowait
                      |          |                     |          |          hva_to_pfn.isra.17
                      |          |                     |          |          __gfn_to_pfn
                      |          |                     |          |          gfn_to_pfn_async
                      |          |                     |          |          try_async_pf
                      |          |                     |          |          tdp_page_fault
                      |          |                     |          |          kvm_mmu_page_fault
                      |          |                     |          |          pf_interception
                      |          |                     |          |          handle_exit
                      |          |                     |          |          kvm_arch_vcpu_ioctl_run
                      |          |                     |          |          kvm_vcpu_ioctl
                      |          |                     |          |          do_vfs_ioctl
                      |          |                     |          |          sys_ioctl
                      |          |                     |          |          system_call_fastpath
                      |          |                     |          |          ioctl
                      |          |                     |          |          |          
                      |          |                     |          |          |--88.56%-- 0x10100000006
                      |          |                     |          |          |          
                      |          |                     |          |           --11.44%-- 0x10100000002
                      |          |                     |          |          
                      |          |                     |           --0.98%-- putback_lru_pages
                      |          |                     |                     compact_zone
                      |          |                     |                     compact_zone_order
                      |          |                     |                     try_to_compact_pages
                      |          |                     |                     __alloc_pages_direct_compact
                      |          |                     |                     __alloc_pages_nodemask
                      |          |                     |                     alloc_pages_vma
                      |          |                     |                     do_huge_pmd_anonymous_page
                      |          |                     |                     handle_mm_fault
                      |          |                     |                     __get_user_pages
                      |          |                     |                     get_user_page_nowait
                      |          |                     |                     hva_to_pfn.isra.17
                      |          |                     |                     __gfn_to_pfn
                      |          |                     |                     gfn_to_pfn_async
                      |          |                     |                     try_async_pf
                      |          |                     |                     tdp_page_fault
                      |          |                     |                     kvm_mmu_page_fault
                      |          |                     |                     pf_interception
                      |          |                     |                     handle_exit
                      |          |                     |                     kvm_arch_vcpu_ioctl_run
                      |          |                     |                     kvm_vcpu_ioctl
                      |          |                     |                     do_vfs_ioctl
                      |          |                     |                     sys_ioctl
                      |          |                     |                     system_call_fastpath
                      |          |                     |                     ioctl
                      |          |                     |                     0x10100000002
                      |          |                     |          
                      |          |                      --1.87%-- lru_add_drain_cpu
                      |          |                                lru_add_drain
                      |          |                                |          
                      |          |                                |--51.26%-- shrink_inactive_list
                      |          |                                |          shrink_lruvec
                      |          |                                |          try_to_free_pages
                      |          |                                |          __alloc_pages_nodemask
                      |          |                                |          alloc_pages_vma
                      |          |                                |          do_huge_pmd_anonymous_page
                      |          |                                |          handle_mm_fault
                      |          |                                |          __get_user_pages
                      |          |                                |          get_user_page_nowait
                      |          |                                |          hva_to_pfn.isra.17
                      |          |                                |          __gfn_to_pfn
                      |          |                                |          gfn_to_pfn_async
                      |          |                                |          try_async_pf
                      |          |                                |          tdp_page_fault
                      |          |                                |          kvm_mmu_page_fault
                      |          |                                |          pf_interception
                      |          |                                |          handle_exit
                      |          |                                |          kvm_arch_vcpu_ioctl_run
                      |          |                                |          kvm_vcpu_ioctl
                      |          |                                |          do_vfs_ioctl
                      |          |                                |          sys_ioctl
                      |          |                                |          system_call_fastpath
                      |          |                                |          ioctl
                      |          |                                |          0x10100000002
                      |          |                                |          
                      |          |                                 --48.74%-- migrate_prep_local
                      |          |                                           compact_zone
                      |          |                                           compact_zone_order
                      |          |                                           try_to_compact_pages
                      |          |                                           __alloc_pages_direct_compact
                      |          |                                           __alloc_pages_nodemask
                      |          |                                           alloc_pages_vma
                      |          |                                           do_huge_pmd_anonymous_page
                      |          |                                           handle_mm_fault
                      |          |                                           __get_user_pages
                      |          |                                           get_user_page_nowait
                      |          |                                           hva_to_pfn.isra.17
                      |          |                                           __gfn_to_pfn
                      |          |                                           gfn_to_pfn_async
                      |          |                                           try_async_pf
                      |          |                                           tdp_page_fault
                      |          |                                           kvm_mmu_page_fault
                      |          |                                           pf_interception
                      |          |                                           handle_exit
                      |          |                                           kvm_arch_vcpu_ioctl_run
                      |          |                                           kvm_vcpu_ioctl
                      |          |                                           do_vfs_ioctl
                      |          |                                           sys_ioctl
                      |          |                                           system_call_fastpath
                      |          |                                           ioctl
                      |          |                                           0x10100000006
                      |          |          
                      |          |--23.04%-- __free_pages
                      |          |          |          
                      |          |          |--59.57%-- release_freepages
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
                      |          |          |          |--89.08%-- 0x10100000006
                      |          |          |          |          
                      |          |          |           --10.92%-- 0x10100000002
                      |          |          |          
                      |          |          |--30.57%-- do_huge_pmd_anonymous_page
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
                      |          |          |          |--60.91%-- 0x10100000006
                      |          |          |          |          
                      |          |          |           --39.09%-- 0x10100000002
                      |          |          |          
                      |          |           --9.86%-- __free_slab
                      |          |                     discard_slab
                      |          |                     |          
                      |          |                     |--55.43%-- unfreeze_partials
                      |          |                     |          put_cpu_partial
                      |          |                     |          __slab_free
                      |          |                     |          kmem_cache_free
                      |          |                     |          free_buffer_head
                      |          |                     |          try_to_free_buffers
                      |          |                     |          jbd2_journal_try_to_free_buffers
                      |          |                     |          ext4_releasepage
                      |          |                     |          try_to_release_page
                      |          |                     |          shrink_page_list
                      |          |                     |          shrink_inactive_list
                      |          |                     |          shrink_lruvec
                      |          |                     |          try_to_free_pages
                      |          |                     |          __alloc_pages_nodemask
                      |          |                     |          alloc_pages_vma
                      |          |                     |          do_huge_pmd_anonymous_page
                      |          |                     |          handle_mm_fault
                      |          |                     |          __get_user_pages
                      |          |                     |          get_user_page_nowait
                      |          |                     |          hva_to_pfn.isra.17
                      |          |                     |          __gfn_to_pfn
                      |          |                     |          gfn_to_pfn_async
                      |          |                     |          try_async_pf
                      |          |                     |          tdp_page_fault
                      |          |                     |          kvm_mmu_page_fault
                      |          |                     |          pf_interception
                      |          |                     |          handle_exit
                      |          |                     |          kvm_arch_vcpu_ioctl_run
                      |          |                     |          kvm_vcpu_ioctl
                      |          |                     |          do_vfs_ioctl
                      |          |                     |          sys_ioctl
                      |          |                     |          system_call_fastpath
                      |          |                     |          ioctl
                      |          |                     |          0x10100000006
                      |          |                     |          
                      |          |                      --44.57%-- __slab_free
                      |          |                                kmem_cache_free
                      |          |                                free_buffer_head
                      |          |                                try_to_free_buffers
                      |          |                                jbd2_journal_try_to_free_buffers
                      |          |                                ext4_releasepage
                      |          |                                try_to_release_page
                      |          |                                shrink_page_list
                      |          |                                shrink_inactive_list
                      |          |                                shrink_lruvec
                      |          |                                try_to_free_pages
                      |          |                                __alloc_pages_nodemask
                      |          |                                alloc_pages_vma
                      |          |                                do_huge_pmd_anonymous_page
                      |          |                                handle_mm_fault
                      |          |                                __get_user_pages
                      |          |                                get_user_page_nowait
                      |          |                                hva_to_pfn.isra.17
                      |          |                                __gfn_to_pfn
                      |          |                                gfn_to_pfn_async
                      |          |                                try_async_pf
                      |          |                                tdp_page_fault
                      |          |                                kvm_mmu_page_fault
                      |          |                                pf_interception
                      |          |                                handle_exit
                      |          |                                kvm_arch_vcpu_ioctl_run
                      |          |                                kvm_vcpu_ioctl
                      |          |                                do_vfs_ioctl
                      |          |                                sys_ioctl
                      |          |                                system_call_fastpath
                      |          |                                ioctl
                      |          |                                0x10100000006
                      |          |          
                      |           --2.02%-- __put_single_page
                      |                     put_page
                      |                     putback_lru_page
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
                      |                     |--83.36%-- 0x10100000006
                      |                     |          
                      |                      --16.64%-- 0x10100000002
                       --0.37%-- [...]
     1.66%         qemu-kvm  [kernel.kallsyms]     [k] compact_zone                              
                   |
                   --- compact_zone
                      |          
                      |--99.99%-- compact_zone_order
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
                      |          |--85.25%-- 0x10100000006
                      |          |          
                      |           --14.75%-- 0x10100000002
                       --0.01%-- [...]
     1.56%             ksmd  [kernel.kallsyms]     [k] memcmp                                    
                       |
                       --- memcmp
                          |          
                          |--99.67%-- memcmp_pages
                          |          |          
                          |          |--77.39%-- ksm_scan_thread
                          |          |          kthread
                          |          |          kernel_thread_helper
                          |          |          
                          |           --22.61%-- try_to_merge_with_ksm_page
                          |                     ksm_scan_thread
                          |                     kthread
                          |                     kernel_thread_helper
                           --0.33%-- [...]
     1.48%          swapper  [kernel.kallsyms]     [k] default_idle                              
                    |
                    --- default_idle
                       |          
                       |--99.55%-- cpu_idle
                       |          |          
                       |          |--92.95%-- start_secondary
                       |          |          
                       |           --7.05%-- rest_init
                       |                     start_kernel
                       |                     x86_64_start_reservations
                       |                     x86_64_start_kernel
                        --0.45%-- [...]
     1.33%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run                              
                   |
                   --- svm_vcpu_run
                      |          
                      |--99.34%-- kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--77.65%-- 0x10100000006
                      |          |          
                      |           --22.35%-- 0x10100000002
                      |          
                       --0.66%-- kvm_vcpu_ioctl
                                 do_vfs_ioctl
                                 sys_ioctl
                                 system_call_fastpath
                                 ioctl
                                 |          
                                 |--73.97%-- 0x10100000006
                                 |          
                                  --26.03%-- 0x10100000002
     1.08%         qemu-kvm  [kernel.kallsyms]     [k] kvm_vcpu_on_spin                          
                   |
                   --- kvm_vcpu_on_spin
                      |          
                      |--99.27%-- pause_interception
                      |          handle_exit
                      |          kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--83.21%-- 0x10100000006
                      |          |          
                      |           --16.79%-- 0x10100000002
                      |          
                       --0.73%-- handle_exit
                                 kvm_arch_vcpu_ioctl_run
                                 kvm_vcpu_ioctl
                                 do_vfs_ioctl
                                 sys_ioctl
                                 system_call_fastpath
                                 ioctl
                                 |          
                                 |--80.89%-- 0x10100000006
                                 |          
                                  --19.11%-- 0x10100000002
     0.79%         qemu-kvm  qemu-kvm              [.] 0x00000000000ae282                        
                   |          
                   |--1.27%-- 0x4eec6e
                   |          |          
                   |          |--38.48%-- 0x1491280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--32.35%-- 0x3195280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --29.16%-- 0x200c280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--1.24%-- 0x503457
                   |          0x0
                   |          
                   |--1.02%-- 0x4eec20
                   |          |          
                   |          |--46.48%-- 0x200c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--28.52%-- 0x3195280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --24.99%-- 0x1491280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--1.00%-- 0x4eec2a
                   |          |          
                   |          |--77.52%-- 0x200c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--12.67%-- 0x3195280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --9.80%-- 0x1491280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.99%-- 0x4ef092
                   |          
                   |--0.94%-- 0x568f04
                   |          |          
                   |          |--89.85%-- 0x0
                   |          |          
                   |          |--7.89%-- 0x10100000002
                   |          |          
                   |           --2.26%-- 0x10100000006
                   |          
                   |--0.93%-- 0x5afab4
                   |          |          
                   |          |--40.39%-- 0x309a410
                   |          |          0x0
                   |          |          
                   |          |--31.80%-- 0x1f11410
                   |          |          0x0
                   |          |          
                   |          |--20.88%-- 0x1396410
                   |          |          0x0
                   |          |          
                   |          |--4.58%-- 0x0
                   |          |          |          
                   |          |          |--52.36%-- 0x148ea00
                   |          |          |          0x5699c0
                   |          |          |          0x24448948004b4154
                   |          |          |          
                   |          |          |--31.49%-- 0x2009a00
                   |          |          |          0x5699c0
                   |          |          |          0x24448948004b4154
                   |          |          |          
                   |          |           --16.15%-- 0x3192a00
                   |          |                     0x5699c0
                   |          |                     0x24448948004b4154
                   |          |          
                   |          |--1.31%-- 0x1000
                   |          |          
                   |           --1.03%-- 0x6
                   |          
                   |--0.92%-- 0x4eeba0
                   |          |          
                   |          |--35.54%-- 0x3195280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--32.33%-- 0x200c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --32.12%-- 0x1491280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.91%-- 0x652b11
                   |          
                   |--0.83%-- 0x65a102
                   |          
                   |--0.82%-- 0x40a6a9
                   |          
                   |--0.81%-- 0x530421
                   |          |          
                   |          |--94.43%-- 0x0
                   |          |          
                   |           --5.57%-- 0x46b47b
                   |                     |          
                   |                     |--51.32%-- 0xdffec96000a08169
                   |                     |          
                   |                      --48.68%-- 0xdffec90000a08169
                   |          
                   |--0.80%-- 0x569fc4
                   |          |          
                   |          |--41.34%-- 0x1396410
                   |          |          0x0
                   |          |          
                   |          |--29.46%-- 0x1f11410
                   |          |          0x0
                   |          |          
                   |           --29.21%-- 0x309a410
                   |                     0x0
                   |          
                   |--0.73%-- 0x541422
                   |          0x0
                   |          
                   |--0.70%-- 0x56b990
                   |          |          
                   |          |--72.77%-- 0x100000008
                   |          |          
                   |          |--26.00%-- 0xfed00000
                   |          |          |          
                   |          |           --100.00%-- 0x0
                   |          |          
                   |          |--0.73%-- 0x100000004
                   |           --0.50%-- [...]
                   |          
                   |--0.69%-- 0x525261
                   |          0x0
                   |          0x822ee8fff96873e9
                   |          
                   |--0.69%-- 0x6578d7
                   |          |          
                   |           --100.00%-- 0x0
                   |          
                   |--0.67%-- 0x52fb44
                   |          |          
                   |          |--75.44%-- 0x0
                   |          |          
                   |          |--17.16%-- 0x10100000002
                   |          |          
                   |           --7.41%-- 0x10100000006
                   |          
                   |--0.66%-- 0x568e29
                   |          |          
                   |          |--50.87%-- 0x200c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--33.04%-- 0x3195280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--13.60%-- 0x1491280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--1.40%-- 0x1000
                   |          |          
                   |          |--0.65%-- 0x3000
                   |           --0.43%-- [...]
                   |          
                   |--0.65%-- 0x5b4cb4
                   |          0x0
                   |          0x822ee8fff96873e9
                   |          
                   |--0.62%-- 0x55b9ba
                   |          |          
                   |          |--50.14%-- 0x0
                   |          |          
                   |           --49.86%-- 0x2000000
                   |          
                   |--0.61%-- 0x4ff496
                   |          
                   |--0.60%-- 0x672601
                   |          0x1
                   |          
                   |--0.58%-- 0x4eec06
                   |          |          
                   |          |--75.93%-- 0x200c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--15.91%-- 0x3195280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --8.15%-- 0x1491280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.58%-- 0x477a32
                   |          0x0
                   |          
                   |--0.56%-- 0x477b27
                   |          0x0
                   |          
                   |--0.56%-- 0x540e24
                   |          
                   |--0.56%-- 0x40a4f4
                   |          
                   |--0.55%-- 0x659d12
                   |          0x0
                   |          
                   |--0.55%-- 0x4eec22
                   |          |          
                   |          |--44.24%-- 0x200c280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |          |--32.08%-- 0x1491280
                   |          |          0x0
                   |          |          0xa0
                   |          |          0x696368752d62
                   |          |          
                   |           --23.68%-- 0x3195280
                   |                     0x0
                   |                     0xa0
                   |                     0x696368752d62
                   |          
                   |--0.53%-- 0x564394
                   |          |          
                   |          |--69.75%-- 0x0
                   |          |          
                   |          |--23.87%-- 0x10100000002
                   |          |          
                   |           --6.38%-- 0x10100000006
                   |          
                   |--0.52%-- 0x4eeb52
                   |          
                   |--0.51%-- 0x530094
                   |          
                   |--0.50%-- 0x477a9e
                   |          0x0
                    --74.90%-- [...]
     0.77%         qemu-kvm  [kernel.kallsyms]     [k] __srcu_read_lock                          
                   |
                   --- __srcu_read_lock
                      |          
                      |--91.98%-- kvm_arch_vcpu_ioctl_run
                      |          kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--81.72%-- 0x10100000006
                      |          |          
                      |           --18.28%-- 0x10100000002
                      |          
                      |--5.81%-- kvm_vcpu_ioctl
                      |          do_vfs_ioctl
                      |          sys_ioctl
                      |          system_call_fastpath
                      |          ioctl
                      |          |          
                      |          |--78.63%-- 0x10100000006
                      |          |          
                      |           --21.37%-- 0x10100000002
                      |          
                      |--1.06%-- fsnotify
                      |          vfs_write
                      |          |          
                      |          |--98.29%-- sys_write
                      |          |          system_call_fastpath
                      |          |          write
                      |          |          |          
                      |          |           --100.00%-- 0x0
                      |          |          
                      |           --1.71%-- sys_pwrite64
                      |                     system_call_fastpath
                      |                     pwrite64
                      |                     |          
                      |                     |--55.68%-- 0x1f12260
                      |                     |          0x80
                      |                     |          0x480050b9e1058b48
                      |                     |          
                      |                      --44.32%-- 0x309b260
                      |                                0x80
                      |                                0x480050b9e1058b48
                      |          
                      |--0.91%-- kvm_mmu_notifier_invalidate_page
                      |          __mmu_notifier_invalidate_page
                      |          try_to_unmap_one
                      |          |          
                      |          |--98.79%-- try_to_unmap_anon
                      |          |          try_to_unmap
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
