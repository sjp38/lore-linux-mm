Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2EAFB6B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 01:37:17 -0400 (EDT)
Received: by pddn5 with SMTP id n5so34205340pdd.2
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:16 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id xq5si5028767pab.85.2015.04.05.22.37.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Apr 2015 22:37:15 -0700 (PDT)
Received: by pdea3 with SMTP id a3so34210903pde.3
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:15 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCHSET 0/9] perf kmem: Implement page allocation analysis (v6)
Date: Mon,  6 Apr 2015 14:36:07 +0900
Message-Id: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Hello,

Currently perf kmem command only analyzes SLAB memory allocation.  And
I'd like to introduce page allocation analysis also.  Users can use
 --slab and/or --page option to select it.  If none of these options
 are used, it does slab allocation analysis for backward compatibility.

 * changes in v6)
   - add -i option fix  (Jiri)
   - libtraceevent operator priority fix

* changes in v5)
   - print migration type and gfp flags in more compact form  (Arnaldo)
   - add kmem.default config option

 * changes in v4)
   - use pfn instead of struct page * in tracepoints  (Joonsoo, Ingo)
   - print gfp flags in human readable string  (Joonsoo, Minchan)

* changes in v3)
  - add live page statistics

 * changes in v2)
   - Use thousand grouping for big numbers - i.e. 12345 -> 12,345  (Ingo)
   - Improve output stat readability  (Ingo)
   - Remove alloc size column as it can be calculated from hits and order

Patch 1 is to convert tracepoint to save pfn instead of struct page *.
Patch 2 implements basic support for page allocation analysis, patch 3
deals with the callsite and patch 4 implements sorting.  Patch 5
introduces live page analysis which is to focus on currently allocated
pages only.  Finally patch 6 prints gfp flags in human readable string.

In this patchset, I used two kmem events: kmem:mm_page_alloc and
kmem_page_free for analysis as they can track almost all of memory
allocation/free path AFAIK.  However, unlike slab tracepoint events,
those page allocation events don't provide callsite info directly.  So
I recorded callchains and extracted callsites like below:

Normal page allocation callchains look like this:

  360a7e __alloc_pages_nodemask
  3a711c alloc_pages_current
  357bc7 __page_cache_alloc   <-- callsite
  357cf6 pagecache_get_page
   48b0a prepare_pages
   494d3 __btrfs_buffered_write
   49cdf btrfs_file_write_iter
  3ceb6e new_sync_write
  3cf447 vfs_write
  3cff99 sys_write
  7556e9 system_call
    f880 __write_nocancel
   33eb9 cmd_record
   4b38e cmd_kmem
   7aa23 run_builtin
   27a9a main
   20800 __libc_start_main

But first two are internal page allocation functions so it should be
skipped.  To determine such allocation functions, I used following regex:

  ^_?_?(alloc|get_free|get_zeroed)_pages?

This gave me a following list of functions (you can see this with -v):

  alloc func: __get_free_pages
  alloc func: get_zeroed_page
  alloc func: alloc_pages_exact
  alloc func: __alloc_pages_direct_compact
  alloc func: __alloc_pages_nodemask
  alloc func: alloc_page_interleave
  alloc func: alloc_pages_current
  alloc func: alloc_pages_vma
  alloc func: alloc_page_buffers
  alloc func: alloc_pages_exact_nid

After skipping those function, it got '__page_cache_alloc'.

Other information such as allocation order, migration type and gfp
flags are provided by tracepoint events.

Basically the output will be sorted by total allocation bytes, but you
can change it by using -s/--sort option.  The following sort keys are
added to support page analysis: page, order, mtype, gfp.  Existing
'callsite', 'bytes' and 'hit' sort keys also can be used.

An example follows:

  # perf kmem record --page sleep 5
  [ perf record: Woken up 2 times to write data ]
  [ perf record: Captured and wrote 1.065 MB perf.data (2949 samples) ]

  # perf kmem stat --page --caller -l 10
  # GFP flags
  # ---------
  # 00000010: GFP_NOIO
  # 000000d0: GFP_KERNEL
  # 00000200: GFP_NOWARN
  # 000052d0: GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP
  # 000084d0: GFP_KERNEL|GFP_REPEAT|GFP_ZERO
  # 000200d0: GFP_USER
  # 000200d2: GFP_HIGHUSER
  # 000200da: GFP_HIGHUSER_MOVABLE
  # 000280da: GFP_HIGHUSER_MOVABLE|GFP_ZERO
  # 002084d0: GFP_KERNEL|GFP_REPEAT|GFP_ZERO|GFP_NOTRACK
  # 0102005a: GFP_NOFS|GFP_HARDWALL|GFP_MOVABLE
  ---------------------------------------------------------------------------------------------------------
   Total alloc (KB) | Hits      | Order | Migration type | GFP flags | Callsite
  ---------------------------------------------------------------------------------------------------------
                 16 |         1 |     2 |      UNMOVABLE |  000052d0 | alloc_skb_with_frags
                 24 |         3 |     1 |      UNMOVABLE |  000052d0 | alloc_skb_with_frags
              3,876 |       969 |     0 |        MOVABLE |  000200da | shmem_alloc_page
                972 |       243 |     0 |      UNMOVABLE |  000000d0 | __pollwait
                624 |       156 |     0 |        MOVABLE |  0102005a | __page_cache_alloc
                304 |        76 |     0 |      UNMOVABLE |  000200d0 | dma_generic_alloc_coherent
                108 |        27 |     0 |        MOVABLE |  000280da | handle_mm_fault
                 56 |        14 |     0 |      UNMOVABLE |  002084d0 | pte_alloc_one
                 24 |         6 |     0 |        MOVABLE |  000200da | do_wp_page
                 16 |         4 |     0 |      UNMOVABLE |  00000200 | __tlb_remove_page
   ...              | ...       | ...   | ...            | ...       | ...
  ---------------------------------------------------------------------------------------------------------

  SUMMARY (page allocator)
  ========================
  Total allocation requests     :            1,518   [            6,096 KB ]
  Total free requests           :            1,431   [            5,748 KB ]

  Total alloc+freed requests    :            1,330   [            5,344 KB ]
  Total alloc-only requests     :              188   [              752 KB ]
  Total free-only requests      :              101   [              404 KB ]

  Total allocation failures     :                0   [                0 KB ]

  Order     Unmovable   Reclaimable       Movable      Reserved  CMA/Isolated
  -----  ------------  ------------  ------------  ------------  ------------
      0           351             .         1,163             .             .
      1             3             .             .             .             .
      2             1             .             .             .             .
      3             .             .             .             .             .
      4             .             .             .             .             .
      5             .             .             .             .             .
      6             .             .             .             .             .
      7             .             .             .             .             .
      8             .             .             .             .             .
      9             .             .             .             .             .
     10             .             .             .             .             .

I have some idea how to improve it.  But I'd also like to hear other
idea, suggestion, feedback and so on.

This is available at perf/kmem-page-v6 branch on my tree:

  git://git.kernel.org/pub/scm/linux/kernel/git/namhyung/linux-perf.git

Thanks,
Namhyung


Jiri Olsa (1):
  perf kmem: Respect -i option

Namhyung Kim (8):
  tracing, mm: Record pfn instead of pointer to struct page
  perf kmem: Analyze page allocator events also
  perf kmem: Implement stat --page --caller
  perf kmem: Support sort keys on page analysis
  perf kmem: Add --live option for current allocation stat
  perf kmem: Print gfp flags in human readable string
  perf kmem: Add kmem.default config option
  tools lib traceevent: Honor operator priority

 include/trace/events/filemap.h         |    8 +-
 include/trace/events/kmem.h            |   42 +-
 include/trace/events/vmscan.h          |    8 +-
 tools/lib/traceevent/event-parse.c     |   17 +-
 tools/perf/Documentation/perf-kmem.txt |   19 +-
 tools/perf/builtin-kmem.c              | 1302 ++++++++++++++++++++++++++++++--
 6 files changed, 1307 insertions(+), 89 deletions(-)

-- 
2.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
