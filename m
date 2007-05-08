Message-ID: <464014B0.7060308@yahoo.com.au>
Date: Tue, 08 May 2007 16:12:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B598B.80200@redhat.com> <463BC62C.3060605@yahoo.com.au> <463E5A00.6070708@redhat.com>
In-Reply-To: <463E5A00.6070708@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
> 
>> OK, sure. I think we need more numbers though.
> 
> 
> Thinking about the issue some more, I think I know just the
> number we might want to know.
> 
> It is pretty obvious that the kernel needs to do less work
> with the MADV_FREE code present.  However, it is possible
> that userspace needs to do more work, by accessing pages
> that are not in the CPU cache, or in another CPU's cache.
> 
> In the test cases where you see similar performance on the
> workload with and without the MADV_FREE code, are you by any
> chance seeing lower system time and higher user time?

I didn't actually check system and user times for the mysql
benchmark, but that's exactly what I had in mind when I
mentioned the poor cache behaviour this patch could cause. I
definitely did see user times go up in benchmarks where I
measured.

We have percpu and cache affine page allocators, so when
userspace just frees a page, it is likely to be cache hot, so
we want to free it up so it can be reused by this CPU ASAP.
Likewise, when we newly allocate a page, we want it to be one
that is cache hot on this CPU.


> I think that maybe for 2.6.22 we should just alias MADV_FREE
> to run with the MADV_DONTNEED functionality, so that the glibc
> people can make the change on their side while we figure out
> what will be the best thing to do on the kernel side.
> 
> I'll send in a patch that does that once Linus has committed
> your most recent flood of patches.  What do you think?

I'll let you and Ulrich decide on that. Keep in mind that older
kernels (without the mmap_sem patch for MADV_DONTNEED) still
seem to get a pretty decent improvement from using MADV_DONTNEED,
so it is possible glibc will want to start using that anyway.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
