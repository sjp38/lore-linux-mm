Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E0E286B006E
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 20:04:39 -0500 (EST)
Received: by pabli10 with SMTP id li10so9551072pab.13
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 17:04:39 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id kn11si9006355pbd.0.2015.03.01.17.04.37
        for <linux-mm@kvack.org>;
        Sun, 01 Mar 2015 17:04:38 -0800 (PST)
Date: Mon, 2 Mar 2015 12:04:13 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: [regression v4.0-rc1] mm: IPIs from TLB flushes causing significant
 performance degradation.
Message-ID: <20150302010413.GP4251@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

Hi folks,

Running one of my usual benchmarks (fsmark to create 50 million zero
length files in a 500TB filesystem, then running xfs_repair on it)
has indicated a significant regression in xfs_repair performance.

config				  3.19		4.0-rc1
defaults			 8m08s		  9m34s
-o ag_stride=-1			 4m04s		  4m38s
-o bhash=101073			 6m04s		 17m43s
-o ag_stride=-1,bhash=101073	 4m54s		  9m58s

The default is for create a number of concurrent threads to progress
AGs in parallel (https://lkml.org/lkml/2014/7/3/15), and this is
running on a 500AG filesystem so lots of parallelism. "-o
ag_stride=-1" turns this off, and just leaves a single prefetch
group working on AGs sequentially. As you can see, turning off the
concurrency halves the runtime.

The concurrency is really there for large spinning disk arrays,
where IO wait time dominates performance. I'm running on SSDs, so
ther eis almost no IO wait time.

The "-o bhash=X" controls the size of the buffer cache. The default
value is 4096, which means xfs_repair is oeprating with a memory
footprint of about 1GB and is small enough to suffer from readahead
thrashing on large filesystems. Setting it to 101073 gives increases that
to around 7-10GB and prevents readahead thrashing, so should run
much faster than the default concurrent config. It does run faster
for 3.19, but for 4.0-rc1 it runs almost twice as slow, and burns a
huge amount of system CPU time doing so.

Across the board the 4.0-rc1 numbers are much slower, and the
degradation is far worse when using the large memory footprint
configs. Perf points straight at the cause - this is from 4.0-rc1
on the "-o bhash=101073" config:

-   56.07%    56.07%  [kernel]            [k] default_send_IPI_mask_sequence_phys
   - default_send_IPI_mask_sequence_phys
      - 99.99% physflat_send_IPI_mask
         - 99.37% native_send_call_func_ipi
              smp_call_function_many
            - native_flush_tlb_others
               - 99.85% flush_tlb_page
                    ptep_clear_flush
                    try_to_unmap_one
                    rmap_walk
                    try_to_unmap
                    migrate_pages
                    migrate_misplaced_page
                  - handle_mm_fault
                     - 99.73% __do_page_fault
                          trace_do_page_fault
                          do_async_page_fault
                        + async_page_fault
           0.63% native_send_call_func_single_ipi
              generic_exec_single
              smp_call_function_single

And the same profile output from 3.19 shows:

-    9.61%     9.61%  [kernel]            [k] default_send_IPI_mask_sequence_phys
   - default_send_IPI_mask_sequence_phys
      - 99.98% physflat_send_IPI_mask
         - 96.26% native_send_call_func_ipi
              smp_call_function_many
            - native_flush_tlb_others
               - 98.44% flush_tlb_page
                    ptep_clear_flush
                    try_to_unmap_one
                    rmap_walk
                    try_to_unmap
                    migrate_pages
                    migrate_misplaced_page
                    handle_mm_fault
               + 1.56% flush_tlb_mm_range
         + 3.74% native_send_call_func_single_ipi

So either there's been a massive increase in the number of IPIs
being sent, or the cost per IPI have greatly increased. Either way,
the result is a pretty significant performance degradatation.

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
