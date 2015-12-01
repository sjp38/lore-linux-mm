Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id AF04D6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:59:29 -0500 (EST)
Received: by wmww144 with SMTP id w144so35244040wmw.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:59:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id aw7si402333wjc.90.2015.12.01.15.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:59:28 -0800 (PST)
Date: Tue, 1 Dec 2015 15:59:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] mm: add a new vector based madvise syscall
Message-Id: <20151201155926.6291e5e541c49d453079849b@linux-foundation.org>
In-Reply-To: <c25b90749f9212359a085125f6403f4c148dfde0.1447098139.git.shli@fb.com>
References: <c25b90749f9212359a085125f6403f4c148dfde0.1447098139.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, je@fb.com, Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>

On Mon, 9 Nov 2015 11:44:54 -0800 Shaohua Li <shli@fb.com> wrote:

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
> malloc/free/realloc. Corresponding jemalloc patch to utilize this API is
> attached.
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
> 
> Another test malloc a bunch of memory in 48 threads, then all threads
> free the memory. I measure the time of the memory free.
> Without patch: 34.332s
> With patch:    17.429s
> 
> Current implementation only supports MADV_DONTNEED. Should be trival to
> support MADV_FREE if necessary later.

I'd like to see a full description of the proposed userspace interface:
arguments, data structures, return values, etc.  A propotype manpage,
basically.

I'd also like to see an analysis of which other userspace allocators
will benefit from this.  glibc? tcmalloc?

>
> ...
>
> +/*
> + * The vector madvise(). Like madvise except running for a vector of virtual
> + * address ranges
> + */
> +SYSCALL_DEFINE3(madvisev, const struct iovec __user *, uvector,
> +	unsigned long, nr_segs, int, behavior)
> +{
> +	struct iovec iovstack[UIO_FASTIOV];
> +	struct iovec *iov = NULL;
> +	unsigned long start, end = 0;
> +	int unmapped_error = 0;
> +	size_t len;
> +	struct mmu_gather tlb;
> +	int error;
> +	int i;
> +
> +	if (behavior != MADV_DONTNEED)
> +		return -EINVAL;
> +
> +	error = rw_copy_check_uvector(CHECK_IOVEC_ONLY, uvector, nr_segs,
> +			UIO_FASTIOV, iovstack, &iov);
> +	if (error <= 0)
> +		goto out;
> +	/* Make sure address in ascend order */
> +	sort(iov, nr_segs, sizeof(struct iovec), iov_cmp_func, NULL);

Do we really need to sort the addresses?  That's something which can be
done in userspace and we can easily add a check-for-sortedness to the
below loop.

It depends on whether userspace can easily generate a sorted array.  If
basically all userspace will always need to run sort() then it doesn't
matter much whether it's done in the kernel or in userspace.  But if
*some* userspace can naturally generate its array in sorted form then
neither userspace nor the kernel needs to run sort() and we should take
this out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
