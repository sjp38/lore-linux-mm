Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C9FF982F66
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 15:00:11 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so37770935pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 12:00:11 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id u12si4202514pbs.191.2015.11.04.12.00.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 12:00:08 -0800 (PST)
Received: by pasz6 with SMTP id z6so63925919pas.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 12:00:08 -0800 (PST)
Date: Wed, 4 Nov 2015 12:00:06 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Message-ID: <20151104200006.GA46783@kernel.org>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446600367-7976-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, bmaurer@fb.com

On Wed, Nov 04, 2015 at 10:25:55AM +0900, Minchan Kim wrote:
> Linux doesn't have an ability to free pages lazy while other OS already
> have been supported that named by madvise(MADV_FREE).
> 
> The gain is clear that kernel can discard freed pages rather than swapping
> out or OOM if memory pressure happens.
> 
> Without memory pressure, freed pages would be reused by userspace without
> another additional overhead(ex, page fault + allocation + zeroing).
> 
> Jason Evans said:
> 
> : Facebook has been using MAP_UNINITIALIZED
> : (https://lkml.org/lkml/2012/1/18/308) in some of its applications for
> : several years, but there are operational costs to maintaining this
> : out-of-tree in our kernel and in jemalloc, and we are anxious to retire it
> : in favor of MADV_FREE.  When we first enabled MAP_UNINITIALIZED it
> : increased throughput for much of our workload by ~5%, and although the
> : benefit has decreased using newer hardware and kernels, there is still
> : enough benefit that we cannot reasonably retire it without a replacement.
> :
> : Aside from Facebook operations, there are numerous broadly used
> : applications that would benefit from MADV_FREE.  The ones that immediately
> : come to mind are redis, varnish, and MariaDB.  I don't have much insight
> : into Android internals and development process, but I would hope to see
> : MADV_FREE support eventually end up there as well to benefit applications
> : linked with the integrated jemalloc.
> :
> : jemalloc will use MADV_FREE once it becomes available in the Linux kernel.
> : In fact, jemalloc already uses MADV_FREE or equivalent everywhere it's
> : available: *BSD, OS X, Windows, and Solaris -- every platform except Linux
> : (and AIX, but I'm not sure it even compiles on AIX).  The lack of
> : MADV_FREE on Linux forced me down a long series of increasingly
> : sophisticated heuristics for madvise() volume reduction, and even so this
> : remains a common performance issue for people using jemalloc on Linux.
> : Please integrate MADV_FREE; many people will benefit substantially.
> 
> How it works:
> 
> When madvise syscall is called, VM clears dirty bit of ptes of the range.
> If memory pressure happens, VM checks dirty bit of page table and if it
> found still "clean", it means it's a "lazyfree pages" so VM could discard
> the page instead of swapping out.  Once there was store operation for the
> page before VM peek a page to reclaim, dirty bit is set so VM can swap out
> the page instead of discarding.
> 
> Firstly, heavy users would be general allocators(ex, jemalloc, tcmalloc
> and hope glibc supports it) and jemalloc/tcmalloc already have supported
> the feature for other OS(ex, FreeBSD)
> 
> barrios@blaptop:~/benchmark/ebizzy$ lscpu
> Architecture:          x86_64
> CPU op-mode(s):        32-bit, 64-bit
> Byte Order:            Little Endian
> CPU(s):                12
> On-line CPU(s) list:   0-11
> Thread(s) per core:    1
> Core(s) per socket:    1
> Socket(s):             12
> NUMA node(s):          1
> Vendor ID:             GenuineIntel
> CPU family:            6
> Model:                 2
> Stepping:              3
> CPU MHz:               3200.185
> BogoMIPS:              6400.53
> Virtualization:        VT-x
> Hypervisor vendor:     KVM
> Virtualization type:   full
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              4096K
> NUMA node0 CPU(s):     0-11
> ebizzy benchmark(./ebizzy -S 10 -n 512)
> 
> Higher avg is better.
> 
>  vanilla-jemalloc		MADV_free-jemalloc
> 
> 1 thread
> records: 10			    records: 10
> avg:	2961.90			    avg:   12069.70
> std:	  71.96(2.43%)		    std:     186.68(1.55%)
> max:	3070.00			    max:   12385.00
> min:	2796.00			    min:   11746.00
> 
> 2 thread
> records: 10			    records: 10
> avg:	5020.00			    avg:   17827.00
> std:	 264.87(5.28%)		    std:     358.52(2.01%)
> max:	5244.00			    max:   18760.00
> min:	4251.00			    min:   17382.00
> 
> 4 thread
> records: 10			    records: 10
> avg:	8988.80			    avg:   27930.80
> std:	1175.33(13.08%)		    std:    3317.33(11.88%)
> max:	9508.00			    max:   30879.00
> min:	5477.00			    min:   21024.00
> 
> 8 thread
> records: 10			    records: 10
> avg:   13036.50			    avg:   33739.40
> std:	 170.67(1.31%)		    std:    5146.22(15.25%)
> max:   13371.00			    max:   40572.00
> min:   12785.00			    min:   24088.00
> 
> 16 thread
> records: 10			    records: 10
> avg:   11092.40			    avg:   31424.20
> std:	 710.60(6.41%)		    std:    3763.89(11.98%)
> max:   12446.00			    max:   36635.00
> min:	9949.00			    min:   25669.00
> 
> 32 thread
> records: 10			    records: 10
> avg:   11067.00			    avg:   34495.80
> std:	 971.06(8.77%)		    std:    2721.36(7.89%)
> max:   12010.00			    max:   38598.00
> min:	9002.00			    min:   30636.00
> 
> In summary, MADV_FREE is about much faster than MADV_DONTNEED.

The MADV_FREE is discussed for a while, it probably is too late to propose
something new, but we had the new idea (from Ben Maurer, CCed) recently and
think it's better. Our target is still jemalloc.

Compared to MADV_DONTNEED, MADV_FREE's lazy memory free is a huge win to reduce
page fault. But there is one issue remaining, the TLB flush. Both MADV_DONTNEED
and MADV_FREE do TLB flush. TLB flush overhead is quite big in contemporary
multi-thread applications. In our production workload, we observed 80% CPU
spending on TLB flush triggered by jemalloc madvise(MADV_DONTNEED) sometimes.
We haven't tested MADV_FREE yet, but the result should be similar. It's hard to
avoid the TLB flush issue with MADV_FREE, because it helps avoid data
corruption.

The new proposal tries to fix the TLB issue. We introduce two madvise verbs:

MARK_FREE. Userspace notifies kernel the memory range can be discarded. Kernel
just records the range in current stage. Should memory pressure happen, page
reclaim can free the memory directly regardless the pte state.

MARK_NOFREE. Userspace notifies kernel the memory range will be reused soon.
Kernel deletes the record and prevents page reclaim discards the memory. If the
memory isn't reclaimed, userspace will access the old memory, otherwise do
normal page fault handling.

The point is to let userspace notify kernel if memory can be discarded, instead
of depending on pte dirty bit used by MADV_FREE. With these, no TLB flush is
required till page reclaim actually frees the memory (page reclaim need do the
TLB flush for MADV_FREE too). It still preserves the lazy memory free merit of
MADV_FREE.

Compared to MADV_FREE, reusing memory with the new proposal isn't transparent,
eg must call MARK_NOFREE. But it's easy to utilize the new API in jemalloc.

We don't have code to backup this yet, sorry. We'd like to discuss it if it
makes sense.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
