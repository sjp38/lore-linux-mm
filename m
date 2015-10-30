Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id C52D582F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 08:48:37 -0400 (EDT)
Received: by qgeo38 with SMTP id o38so60477759qge.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 05:48:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 198si5694886qhh.41.2015.10.30.05.48.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 05:48:37 -0700 (PDT)
Message-ID: <56336721.2040908@redhat.com>
Date: Fri, 30 Oct 2015 08:48:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: add a new vector based madvise syscall
References: <20151029215516.GA3864685@devbig084.prn1.facebook.com>
In-Reply-To: <20151029215516.GA3864685@devbig084.prn1.facebook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, hannes@cmpxchg.org, aarcange@redhat.com, je@fb.com, Kernel-team@fb.com

On 10/29/2015 05:55 PM, Shaohua Li wrote:
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
> flush. This also reduce mmap_sem locking.
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

Nice. This approach makes a lot of sense to me.

Is it too early to ack the patch? :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
