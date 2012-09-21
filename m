Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 68AFB6B002B
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:55:53 -0400 (EDT)
Date: Fri, 21 Sep 2012 10:55:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] Reduce compaction scanning and lock contention
Message-ID: <20120921095548.GT11266@suse.de>
References: <1348149875-29678-1-git-send-email-mgorman@suse.de>
 <20120921091333.GA32081@alpha.arachsys.com>
 <20120921091701.GC32081@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120921091701.GC32081@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 10:17:01AM +0100, Richard Davies wrote:
> Richard Davies wrote:
> > I did manage to get a couple which were slightly worse, but nothing like as
> > bad as before. Here are the results:
> > 
> > # grep -F '[k]' report | head -8
> >     45.60%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
> >     11.26%       qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
> >      3.21%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock
> >      2.27%           ksmd  [kernel.kallsyms]     [k] memcmp
> >      2.02%        swapper  [kernel.kallsyms]     [k] default_idle
> >      1.58%       qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
> >      1.30%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave
> >      1.09%       qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist
> 
> # ========
> # captured on: Fri Sep 21 08:17:52 2012
> # os release : 3.6.0-rc5-elastic+
> # perf version : 3.5.2
> # arch : x86_64
> # nrcpus online : 16
> # nrcpus avail : 16
> # cpudesc : AMD Opteron(tm) Processor 6128
> # cpuid : AuthenticAMD,16,9,1
> # total memory : 131973276 kB
> # cmdline : /home/root/bin/perf record -g -a 
> # event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }
> # HEADER_CPU_TOPOLOGY info available, use -I to display
> # HEADER_NUMA_TOPOLOGY info available, use -I to display
> # ========
> #
> # Samples: 283K of event 'cycles'
> # Event count (approx.): 109057976176
> #
> # Overhead        Command         Shared Object                                          Symbol
> # ........  .............  ....................  ..............................................
> #
>     45.60%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c                              
>                  |
>                  --- clear_page_c
>                     |          
>                     |--93.35%-- do_huge_pmd_anonymous_page

This is unavoidable. If THP was disabled, the cost would still be
incurred, just on base pages instead of huge pages.

> <SNIP>
>     11.26%       qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block                   
>                  |
>                  --- isolate_freepages_block
>                      compaction_alloc
>                      migrate_pages
>                      compact_zone
>                      compact_zone_order
>                      try_to_compact_pages
>                      __alloc_pages_direct_compact
>                      __alloc_pages_nodemask
>                      alloc_pages_vma
>                      do_huge_pmd_anonymous_page

And this is showing that we're still spending a lot of time scanning
for free pages to isolate. I do not have a great idea on how this can be
reduced further without interfering with the page allocator.

One ok idea I considered in the past was using the buddy lists to find
free pages quickly but there is first the problem that the buddy lists
themselves may need to be searched and now that the zone lock is not held
during the scan it would be particularly difficult. The harder problem is
deciding when compaction "finishes". I'll put more thought into it over
the weekend and see if something falls out but I'm not going to hold up
this series waiting for inspiration.

>      3.21%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock                            
>                  |
>                  --- _raw_spin_lock
>                     |          
>                     |--39.96%-- tdp_page_fault

Nothing very interesting here until...

>                     |--1.69%-- free_pcppages_bulk
>                     |          |          
>                     |          |--77.53%-- drain_pages
>                     |          |          |          
>                     |          |          |--95.77%-- drain_local_pages
>                     |          |          |          |          
>                     |          |          |          |--97.90%-- generic_smp_call_function_interrupt
>                     |          |          |          |          smp_call_function_interrupt
>                     |          |          |          |          call_function_interrupt
>                     |          |          |          |          |          
>                     |          |          |          |          |--23.37%-- kvm_vcpu_ioctl
>                     |          |          |          |          |          do_vfs_ioctl
>                     |          |          |          |          |          sys_ioctl
>                     |          |          |          |          |          system_call_fastpath
>                     |          |          |          |          |          ioctl
>                     |          |          |          |          |          |          
>                     |          |          |          |          |          |--97.22%-- 0x10100000006
>                     |          |          |          |          |          |          
>                     |          |          |          |          |           --2.78%-- 0x10100000002
>                     |          |          |          |          |          
>                     |          |          |          |          |--17.80%-- __remove_mapping
>                     |          |          |          |          |          shrink_page_list
>                     |          |          |          |          |          shrink_inactive_list
>                     |          |          |          |          |          shrink_lruvec
>                     |          |          |          |          |          try_to_free_pages
>                     |          |          |          |          |          __alloc_pages_nodemask
>                     |          |          |          |          |          alloc_pages_vma
>                     |          |          |          |          |          do_huge_pmd_anonymous_page

This whole section is interesting simply because it shows the per-cpu
draining cost. It's low enough that I'm not going to put much thought
into it but it's not often the per-cpu allocator sticks out like this.

Thanks Richard.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
