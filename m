Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 651AD5F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 03:37:22 -0400 (EDT)
Date: Thu, 9 Apr 2009 15:36:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH][0/2]page_fault retry with NOPAGE_RETRY
Message-ID: <20090409073620.GA31527@localhost>
References: <604427e00904081302p7aad170bu5ff0702415455f7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00904081302p7aad170bu5ff0702415455f7@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?utf-8?B?VMO2csO2aw==?= Edwin <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Ying,

//Nitpicks on the changlog..

On Thu, Apr 09, 2009 at 04:02:23AM +0800, Ying Han wrote:
> changelog[v3]:
> - applied fixes and cleanups from Wu Fengguang.
> filemap VM_FAULT_RETRY fixes
> [PATCH 01/14] mm: fix find_lock_page_retry() return value parsing
> [PATCH 02/14] mm: fix major/minor fault accounting on retried fault
> [PATCH 04/14] mm: reduce duplicate page fault code
> [PATCH 05/14] readahead: account mmap_miss for VM_FAULT_RETRY
> 
> - split the patch into two parts. first part includes FAULT_FLAG_RETRY
>   support with no current user change. second part includes individual
>   per-architecture cleanups that enable FAULT_FLAG_RETRY.
>   currently there are mainly two users for handle_mm_fault, we enable
>   FAULT_FLAG_RETRY for actual fault handler and leave get_user_pages
>   unchanged.

The below benchmarks can also go into changelog of patch 01.

Besides, there you should also explain the problem and approach,
the _benefited_ workloads and how/how much they will benefit,
the _hurt_ workloads and how they are impacted and the bound of overheads.

> Benchmarks:
> posted on [V1]:
> case 1. one application has a high count of threads each faulting in
> different pages of a hugefile. Benchmark indicate that this double data
> structure walking in case of major fault results in << 1% performance hit.
> 
> case 2. add another thread in the above application which in a tight loop
> of
> mmap()/munmap(). Here we measure loop count in the new thread while other
> threads doing the same amount of work as case one. we got << 3% performance
> hit on the Complete Time(benchmark value for case one) and 10% performance
> improvement on the mmap()/munmap() counter.
> 
> This patch helps a lot in cases we have writer which is waitting behind all
> readers, so it could execute much faster.
> 
> some new test results from Wufengguang:
> Just tested the sparse-random-read-on-sparse-file case, and found the
> performance impact to be 0.4% (8.706s vs 8.744s). Kind of acceptable.

the 0.4% here should be the worst case overheads.

> without FAULT_FLAG_RETRY:
> iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.28s user
> 5.39s system 99% cpu 8.692 total
> iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.17s user
> 5.54s system 99% cpu 8.742 total
> iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.18s user
> 5.48s system 99% cpu 8.684 total

ugly line wraps

> FAULT_FLAG_RETRY:
> iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.18s user
> 5.63s system 99% cpu 8.825 total
> iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.22s user
> 5.47s system 99% cpu 8.718 total
> iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.13s user
> 5.55s system 99% cpu 8.690 total

ditto

Thanks,
Fengguang

> In the above faked workload, the mmap read page offsets are loaded from
> stride-100 and performed on /mnt/btrfs-ram/sparse, which are created by:
> 
> 	seq 0 100 1000000 > stride-100
> 	dd if=/dev/zero of=/mnt/btrfs-ram/sparse bs=1M count=1 seek=1024000
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> 	       Mike Waychison <mikew@google.com>
> 
>  arch/x86/mm/fault.c |   20 ++++++++++++++
>  include/linux/fs.h  |    2 +-
>  include/linux/mm.h  |    2 +
>  mm/filemap.c        |   72 ++++++++++++++++++++++++++++++++++++++++++++++++--
>  mm/memory.c         |   33 +++++++++++++++++------
>  5 files changed, 116 insertions(+), 13 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
