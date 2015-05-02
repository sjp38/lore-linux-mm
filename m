Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8676B0032
	for <linux-mm@kvack.org>; Sat,  2 May 2015 10:55:41 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so55949554igb.0
        for <linux-mm@kvack.org>; Sat, 02 May 2015 07:55:41 -0700 (PDT)
Received: from mail-ie0-x243.google.com (mail-ie0-x243.google.com. [2607:f8b0:4001:c03::243])
        by mx.google.com with ESMTPS id d18si1284684igz.55.2015.05.02.07.55.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 May 2015 07:55:40 -0700 (PDT)
Received: by iebtr6 with SMTP id tr6so7205513ieb.0
        for <linux-mm@kvack.org>; Sat, 02 May 2015 07:55:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1429592107-1807-1-git-send-email-namhyung@kernel.org>
References: <1429592107-1807-1-git-send-email-namhyung@kernel.org>
Date: Sat, 2 May 2015 23:55:40 +0900
Message-ID: <CADWwUUbBMUUKxicO86giJk-_RT1DaoJW+Oqm+6YQ_f10HFYRRQ@mail.gmail.com>
Subject: Re: [PATCHSET 0/6] perf kmem: Implement page allocation analysis (v8)
From: Namhyung Kim <namhyung.with.foss@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>, Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Ping!

On Tue, Apr 21, 2015 at 1:55 PM, Namhyung Kim <namhyung@kernel.org> wrote:
> Hello,
>
> Currently perf kmem command only analyzes SLAB memory allocation.  And
> I'd like to introduce page allocation analysis also.  Users can use
>  --slab and/or --page option to select it.  If none of these options
>  are used, it does slab allocation analysis for backward compatibility.
>
>  * changes in v8)
>    - rename 'stat' to 'pstat' due to build error
>    - add Acked-by from Pekka
>
>  * changes in v7)
>    - drop already merged patches
>    - check return value of map__load()  (Arnaldo)
>    - rename to page_stat__findnew_*() functions  (Arnaldo)
>    - show warning when try to run stat before record
>
>  * changes in v6)
>    - add -i option fix  (Jiri)
>    - libtraceevent operator priority fix
>
> * changes in v5)
>    - print migration type and gfp flags in more compact form  (Arnaldo)
>    - add kmem.default config option
>
>  * changes in v4)
>    - use pfn instead of struct page * in tracepoints  (Joonsoo, Ingo)
>    - print gfp flags in human readable string  (Joonsoo, Minchan)
>
> * changes in v3)
>   - add live page statistics
>
>  * changes in v2)
>    - Use thousand grouping for big numbers - i.e. 12345 -> 12,345  (Ingo)
>    - Improve output stat readability  (Ingo)
>    - Remove alloc size column as it can be calculated from hits and order
>
> In this patchset, I used two kmem events: kmem:mm_page_alloc and
> kmem_page_free for analysis as they can track almost all of memory
> allocation/free path AFAIK.  However, unlike slab tracepoint events,
> those page allocation events don't provide callsite info directly.  So
> I recorded callchains and extracted callsites like below:
>
> Normal page allocation callchains look like this:
>
>   360a7e __alloc_pages_nodemask
>   3a711c alloc_pages_current
>   357bc7 __page_cache_alloc   <-- callsite
>   357cf6 pagecache_get_page
>    48b0a prepare_pages
>    494d3 __btrfs_buffered_write
>    49cdf btrfs_file_write_iter
>   3ceb6e new_sync_write
>   3cf447 vfs_write
>   3cff99 sys_write
>   7556e9 system_call
>     f880 __write_nocancel
>    33eb9 cmd_record
>    4b38e cmd_kmem
>    7aa23 run_builtin
>    27a9a main
>    20800 __libc_start_main
>
> But first two are internal page allocation functions so it should be
> skipped.  To determine such allocation functions, I used following regex:
>
>   ^_?_?(alloc|get_free|get_zeroed)_pages?
>
> This gave me a following list of functions (you can see this with -v):
>
>   alloc func: __get_free_pages
>   alloc func: get_zeroed_page
>   alloc func: alloc_pages_exact
>   alloc func: __alloc_pages_direct_compact
>   alloc func: __alloc_pages_nodemask
>   alloc func: alloc_page_interleave
>   alloc func: alloc_pages_current
>   alloc func: alloc_pages_vma
>   alloc func: alloc_page_buffers
>   alloc func: alloc_pages_exact_nid
>
> After skipping those function, it got '__page_cache_alloc'.
>
> Other information such as allocation order, migration type and gfp
> flags are provided by tracepoint events.
>
> Basically the output will be sorted by total allocation bytes, but you
> can change it by using -s/--sort option.  The following sort keys are
> added to support page analysis: page, order, migtype, gfp.  Existing
> 'callsite', 'bytes' and 'hit' sort keys also can be used.
>
> An example follows:
>
>   # perf kmem record --page sleep 5
>   [ perf record: Woken up 2 times to write data ]
>   [ perf record: Captured and wrote 1.065 MB perf.data (2949 samples) ]
>
>   # perf kmem stat --page --caller -s order,hit -l 10
>   #
>   # GFP flags
>   # ---------
>   # 00000010:         NI: GFP_NOIO
>   # 000000d0:          K: GFP_KERNEL
>   # 00000200:        NWR: GFP_NOWARN
>   # 000052d0: K|NWR|NR|C: GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP
>   # 000084d0:      K|R|Z: GFP_KERNEL|GFP_REPEAT|GFP_ZERO
>   # 000200d0:          U: GFP_USER
>   # 000200d2:         HU: GFP_HIGHUSER
>   # 000200da:        HUM: GFP_HIGHUSER_MOVABLE
>   # 000280da:      HUM|Z: GFP_HIGHUSER_MOVABLE|GFP_ZERO
>   # 002084d0:   K|R|Z|NT: GFP_KERNEL|GFP_REPEAT|GFP_ZERO|GFP_NOTRACK
>   # 0102005a:    NF|HW|M: GFP_NOFS|GFP_HARDWALL|GFP_MOVABLE
>
>   ---------------------------------------------------------------------------------------------------------
>    Total alloc (KB) | Hits      | Order | Mig.type | GFP flags  | Callsite
>   ---------------------------------------------------------------------------------------------------------
>                  16 |         1 |     2 | UNMOVABL | K|NWR|NR|C | alloc_skb_with_frags
>                  24 |         3 |     1 | UNMOVABL | K|NWR|NR|C | alloc_skb_with_frags
>               3,876 |       969 |     0 |  MOVABLE | HUM        | shmem_alloc_page
>                 972 |       243 |     0 | UNMOVABL | K          | __pollwait
>                 624 |       156 |     0 |  MOVABLE | NF|HW|M    | __page_cache_alloc
>                 304 |        76 |     0 | UNMOVABL | U          | dma_generic_alloc_coherent
>                 108 |        27 |     0 |  MOVABLE | HUM|Z      | handle_mm_fault
>                  56 |        14 |     0 | UNMOVABL | K|R|Z|NT   | pte_alloc_one
>                  24 |         6 |     0 |  MOVABLE | HUM        | do_wp_page
>                  16 |         4 |     0 | UNMOVABL | NWR        | __tlb_remove_page
>    ...              | ...       | ...   | ...      | ...        | ...
>   ---------------------------------------------------------------------------------------------------------
>
>   SUMMARY (page allocator)
>   ========================
>   Total allocation requests     :            1,518   [            6,096 KB ]
>   Total free requests           :            1,431   [            5,748 KB ]
>
>   Total alloc+freed requests    :            1,330   [            5,344 KB ]
>   Total alloc-only requests     :              188   [              752 KB ]
>   Total free-only requests      :              101   [              404 KB ]
>
>   Total allocation failures     :                0   [                0 KB ]
>
>   Order     Unmovable   Reclaimable       Movable      Reserved  CMA/Isolated
>   -----  ------------  ------------  ------------  ------------  ------------
>       0           351             .         1,163             .             .
>       1             3             .             .             .             .
>       2             1             .             .             .             .
>       3             .             .             .             .             .
>       4             .             .             .             .             .
>       5             .             .             .             .             .
>       6             .             .             .             .             .
>       7             .             .             .             .             .
>       8             .             .             .             .             .
>       9             .             .             .             .             .
>      10             .             .             .             .             .
>
> I have some idea how to improve it.  But I'd also like to hear other
> idea, suggestion, feedback and so on.
>
> This is available at perf/kmem-page-v8 branch on my tree:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/namhyung/linux-perf.git
>
> Thanks,
> Namhyung
>
>
> Namhyung Kim (6):
>   perf kmem: Implement stat --page --caller
>   perf kmem: Support sort keys on page analysis
>   perf kmem: Add --live option for current allocation stat
>   perf kmem: Print gfp flags in human readable string
>   perf kmem: Add kmem.default config option
>   perf kmem: Show warning when trying to run stat without record
>
>  tools/perf/Documentation/perf-kmem.txt |  11 +-
>  tools/perf/builtin-kmem.c              | 995 +++++++++++++++++++++++++++++----
>  2 files changed, 898 insertions(+), 108 deletions(-)
>
> --
> 2.3.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
