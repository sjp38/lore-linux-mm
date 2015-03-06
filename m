Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 752C16B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 22:59:22 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so48200113pdb.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 19:59:22 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id vl6si12345563pbc.191.2015.03.05.19.59.20
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 19:59:21 -0800 (PST)
Date: Fri, 6 Mar 2015 14:59:16 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] mm: numa: Do not clear PTEs or PMDs for NUMA hinting
 faults
Message-ID: <20150306035916.GD4251@dastard>
References: <1425599692-32445-1-git-send-email-mgorman@suse.de>
 <1425599692-32445-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425599692-32445-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org

On Thu, Mar 05, 2015 at 11:54:52PM +0000, Mel Gorman wrote:
> Dave Chinner reported the following on https://lkml.org/lkml/2015/3/1/226
> 
>    Across the board the 4.0-rc1 numbers are much slower, and the
>    degradation is far worse when using the large memory footprint
>    configs. Perf points straight at the cause - this is from 4.0-rc1
>    on the "-o bhash=101073" config:
> 
>    -   56.07%    56.07%  [kernel]            [k] default_send_IPI_mask_sequence_phys
>       - default_send_IPI_mask_sequence_phys
>          - 99.99% physflat_send_IPI_mask
>             - 99.37% native_send_call_func_ipi
>                  smp_call_function_many
>                - native_flush_tlb_others
>                   - 99.85% flush_tlb_page
>                        ptep_clear_flush
>                        try_to_unmap_one
>                        rmap_walk
>                        try_to_unmap
>                        migrate_pages
>                        migrate_misplaced_page
>                      - handle_mm_fault
>                         - 99.73% __do_page_fault
>                              trace_do_page_fault
>                              do_async_page_fault
>                            + async_page_fault
>               0.63% native_send_call_func_single_ipi
>                  generic_exec_single
>                  smp_call_function_single
> 
> This was bisected to commit 4d9424669946 ("mm: convert p[te|md]_mknonnuma
> and remaining page table manipulations") which clears PTEs and PMDs to make
> them PROT_NONE. This is tidy but tests on some benchmarks indicate that
> there are many more hinting faults trapped resulting in excessive migration.
> This is the result for the old autonuma benchmark for example.

[snip]

Doesn't fix the problem. Runtime is slightly improved (16m45s vs 17m35)
but it's still much slower that 3.19 (6m5s).

Stats and profiles still roughly the same:

	360,228      migrate:mm_migrate_pages     ( +-  4.28% )

-   52.69%    52.69%  [kernel]            [k] default_send_IPI_mask_sequence_phys
     default_send_IPI_mask_sequence_phys
   - physflat_send_IPI_mask
      - 97.28% native_send_call_func_ipi
           smp_call_function_many
           native_flush_tlb_others
           flush_tlb_page
           ptep_clear_flush
           try_to_unmap_one
           rmap_walk
           try_to_unmap
           migrate_pages
           migrate_misplaced_page
         - handle_mm_fault
            - 99.59% __do_page_fault
                 trace_do_page_fault
                 do_async_page_fault
               + async_page_fault
      + 2.72% native_send_call_func_single_ipi

numa_hit 36678767
numa_miss 905234
numa_foreign 905234
numa_interleave 14802
numa_local 36656791
numa_other 927210
numa_pte_updates 92168450
numa_huge_pte_updates 0
numa_hint_faults 87573926
numa_hint_faults_local 29730293
numa_pages_migrated 30195890
pgmigrate_success 30195890
pgmigrate_fail 0

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
