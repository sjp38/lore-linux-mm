Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 32DD66B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:08:06 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id b205so133100318wmb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:08:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g67si674473wmi.14.2016.02.16.16.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 16:08:05 -0800 (PST)
Date: Tue, 16 Feb 2016 16:08:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4][for-next]mm: add a new vector based madvise syscall
Message-Id: <20160216160802.50ceaf10aa16588e18b3d2c5@linux-foundation.org>
In-Reply-To: <d01698140a51cf9b2ce233c7574c2ece9f6fa241.1449791762.git.shli@fb.com>
References: <d01698140a51cf9b2ce233c7574c2ece9f6fa241.1449791762.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Arnd Bergmann <arnd@arndb.de>

On Thu, 10 Dec 2015 16:03:37 -0800 Shaohua Li <shli@fb.com> wrote:

> In jemalloc, a free(3) doesn't immediately free the memory to OS even
> the memory is page aligned/size, and hope the memory can be reused soon.
> Later the virtual address becomes fragmented, and more and more free
> memory are aggregated. If the free memory size is large, jemalloc uses
> madvise(DONT_NEED) to actually free the memory back to OS.
> 
> The madvise has significantly overhead paritcularly because of TLB
> flush. jemalloc does madvise for several virtual address space ranges
> one time. Instead of calling madvise for each of the ranges, we
> introduce a new syscall to purge memory for several ranges one time. In
> this way, we can merge several TLB flush for the ranges to one big TLB
> flush. This also reduce mmap_sem locking and kernel/userspace switching.
> 
> I'm running a simple memory allocation benchmark. 32 threads do random
> malloc/free/realloc.

CPU count?  (Does that matter much?)

> Corresponding jemalloc patch to utilize this API is
> attached.

No it isn't ;)

Who maintains jemalloc?  Are they signed up to actually apply the
patch?  It would be bad to add the patch to the kernel and then find
that the jemalloc maintainers choose not to use it!

> Without patch:
> real    0m18.923s
> user    1m11.819s
> sys     7m44.626s
> each cpu gets around 3000K/s TLB flush interrupt. Perf shows TLB flush
> is hotest functions. mmap_sem read locking (because of page fault) is
> also heavy.
> 
> with patch:
> real    0m15.026s
> user    0m48.548s
> sys     6m41.153s
> each cpu gets around 140k/s TLB flush interrupt. TLB flush isn't hot at
> all. mmap_sem read locking (still because of page fault) becomes the
> sole hot spot.

This is a somewhat underwhelming improvement, given that it's a
synthetic microbenchmark.

> Another test malloc a bunch of memory in 48 threads, then all threads
> free the memory. I measure the time of the memory free.
> Without patch: 34.332s
> With patch:    17.429s

This is more whelming.

Do we have a feel for how much benefit this patch will have for
real-world workloads?  That's pretty important.

> MADV_FREE does the same TLB flush as MADV_NEED, this also applies to

I'll do s/MADV_NEED/MADV_DONTNEED/

> MADV_FREE. Other madvise type can have small benefits too, like reduce
> syscalls/mmap_sem locking.

Could we please get a testcase for the syscall(s) into
tools/testing/selftests/vm?  For long-term maintenance reasons and as a
service to arch maintainers - make it easy for them to check the
functionality without having to roll their own (possibly incomplete)
test app.

I'm not sure *how* we'd develop a test case.  Use mincore()?

> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -21,7 +21,10 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/mmu_notifier.h>
> -
> +#include <linux/uio.h>
> +#ifdef CONFIG_COMPAT
> +#include <linux/compat.h>
> +#endif

I'll nuke the ifdefs - compat.h already does that.


It would be good for us to have a look at the manpage before going too
far with the patch - this helps reviewers to think about the proposed
interface and behaviour.

I'll queue this up for a bit of testing, although it won't get tested
much.  The syscall fuzzers will presumably hit on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
