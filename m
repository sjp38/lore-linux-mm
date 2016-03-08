Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 186116B007E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 17:38:14 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id x1so39477016lbj.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 14:38:14 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 81si2543092lfa.136.2016.03.08.14.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 14:38:12 -0800 (PST)
Date: Tue, 8 Mar 2016 14:37:36 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V4][for-next]mm: add a new vector based madvise syscall
Message-ID: <20160308223733.GA2692356@devbig084.prn1.facebook.com>
References: <d01698140a51cf9b2ce233c7574c2ece9f6fa241.1449791762.git.shli@fb.com>
 <20160216160802.50ceaf10aa16588e18b3d2c5@linux-foundation.org>
 <20160217174654.GA3505386@devbig084.prn1.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160217174654.GA3505386@devbig084.prn1.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Jason Evans <je@fb.com>, Dave Watson <davejwatson@fb.com>

On Wed, Feb 17, 2016 at 09:47:06AM -0800, Shaohua Li wrote:
> On Tue, Feb 16, 2016 at 04:08:02PM -0800, Andrew Morton wrote:
> > On Thu, 10 Dec 2015 16:03:37 -0800 Shaohua Li <shli@fb.com> wrote:
> > 
> > > In jemalloc, a free(3) doesn't immediately free the memory to OS even
> > > the memory is page aligned/size, and hope the memory can be reused soon.
> > > Later the virtual address becomes fragmented, and more and more free
> > > memory are aggregated. If the free memory size is large, jemalloc uses
> > > madvise(DONT_NEED) to actually free the memory back to OS.
> > > 
> > > The madvise has significantly overhead paritcularly because of TLB
> > > flush. jemalloc does madvise for several virtual address space ranges
> > > one time. Instead of calling madvise for each of the ranges, we
> > > introduce a new syscall to purge memory for several ranges one time. In
> > > this way, we can merge several TLB flush for the ranges to one big TLB
> > > flush. This also reduce mmap_sem locking and kernel/userspace switching.
> > > 
> > > I'm running a simple memory allocation benchmark. 32 threads do random
> > > malloc/free/realloc.
> > 
> > CPU count?  (Does that matter much?)
> 
> 32. It does. the tlb flush overhead depends on the cpu count. 
> > > Corresponding jemalloc patch to utilize this API is
> > > attached.
> > 
> > No it isn't ;)
> 
> Sorry, I attached it in first post, but not this one. Attached is the
> one I tested against this patch.
> 
> > Who maintains jemalloc?  Are they signed up to actually apply the
> > patch?  It would be bad to add the patch to the kernel and then find
> > that the jemalloc maintainers choose not to use it!
> 
> Jason Evans (cced) is the author of jemalloc. I talked to him before, he
> is very positive to this new syscall.
> 
> > > Without patch:
> > > real    0m18.923s
> > > user    1m11.819s
> > > sys     7m44.626s
> > > each cpu gets around 3000K/s TLB flush interrupt. Perf shows TLB flush
> > > is hotest functions. mmap_sem read locking (because of page fault) is
> > > also heavy.
> > > 
> > > with patch:
> > > real    0m15.026s
> > > user    0m48.548s
> > > sys     6m41.153s
> > > each cpu gets around 140k/s TLB flush interrupt. TLB flush isn't hot at
> > > all. mmap_sem read locking (still because of page fault) becomes the
> > > sole hot spot.
> > 
> > This is a somewhat underwhelming improvement, given that it's a
> > synthetic microbenchmark.
> 
> Yes, this test does malloc, free, calloc, realloc, so it doesn't only
> benchmark the madvisev.
> > > Another test malloc a bunch of memory in 48 threads, then all threads
> > > free the memory. I measure the time of the memory free.
> > > Without patch: 34.332s
> > > With patch:    17.429s
> > 
> > This is more whelming.
> > 
> > Do we have a feel for how much benefit this patch will have for
> > real-world workloads?  That's pretty important.
> 
> Sure, we'll post some real-world data.

Hi Andrew,

Sorry I can't post real-world data. Our workloads used to suffer from
TLB flush overhead very much, but now looks something is changed, TLB
flush overhead isn't significant in the workloads.

Jemalloc guys (Dave, CCed) also made progress to improve jemalloc, they
can reduce TLB flush without kernel changes.

In the summary, the patch doesn't have benefit as expected in our real
workloads now. Unless somebody has other usage cases, I'd drop this
patch.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
