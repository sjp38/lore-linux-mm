Date: Thu, 27 Nov 2008 09:55:54 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20081127085554.GD28285@wotan.suse.de>
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com> <20081123091843.GK30453@elte.hu> <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <492DAA24.8040100@google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Waychison <mikew@google.com>
Cc: Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 26, 2008 at 11:57:24AM -0800, Mike Waychison wrote:
> Nick Piggin wrote:
> >On Tue, Nov 25, 2008 at 10:42:47AM -0800, Ying Han wrote:
> >>>>The patch flags current->flags to PF_FAULT_MAYRETRY as identify that
> >>>>the caller can tolerate the retry in the filemap_fault call patch.
> >>>>
> >>>>Benchmark is done by mmap in huge file and spaw 64 thread each
> >>>>faulting in pages in reverse order, the the result shows 8%
> >>>>porformance hit with the patch.
> >>>I suspect we also want to see the cases where this change helps?
> >>i am working on more benchmark to show performance improvement.
> >
> >Can't you share the actual improvement you see inside Google?
> >
> >Google must be doing something funky with threads, because both
> >this patch and their new malloc allocator apparently were due to
> >mmap_sem contention problems, right?
> 
> One of the big improvements we see with this patch is the ability to 
> read out files in /proc/pid much faster.  Consider the following events:
> 
> - an application has a high count of threads sleeping with 
> read_lock(mmap_sem) held in the fault path (on the order of hundreds).
> - one of the threads in the application then blocks in 
> write_lock(mmap_sem) in the mmap()/munmap() paths
> - now our monitoring software tries to read some of the /proc/pid files 
> and blocks behind the waiting writer due to the fairness of the rwsems. 
>  This basically has to wait for all faults ahead of the reader to 
> terminate (and let go of the reader lock) and then the writer to have a 
> go at mmap_sem.   This can take an extremely long time.
> 
> This patch helps a lot in this case as it keeps the writer from waiting 
> behind all the waiting readers, so it executes much faster.

Hmm. How quantifiable is the benefit? Does it actually matter that you
can read the proc file much faster? (this is for some automated workload
management daemon or something, right?)

Would it be possible to reduce mmap()/munmap() activity? eg. if it is
due to a heap memory allocator, then perhaps do more batching or set
some hysteresis.


> >That was before the kernel and glibc got together to fix the stupid
> >mmap_sem problem in malloc (shown up in that FreeBSD MySQL thread);
> >and before private futexes. I would be interested to know if Google
> >still has problems that require this patch...
> >
> 
> I'm not very familiar with the 'malloc' problem in glibc.  Was this just 
> overhead in heap growth/shrinkage causing problems?

As far as I understand, glibc does actually seperate notions of allocated
virtual memory and allocated pages. By that I mean that it is very careful to
return pages back to the system when they are unused, but it does try to
batch up changes to the virtual address space. Unfortunately, it used to
return pages by doing a mmap call with PROT_NONE, then to start using
that virtual memory again, it would mmap with PROT_READ|PROT_WRITE.

This meant that a malloc/touch/free would look like this:
mmap <- down_write(mmap_sem)
page fault  <- down_read(mmap_sem)
mmap <- down_write(mmap_sem)

What we did was to make it use madvise(MADV_DONTNEED) to throw the pages
away. Then the kernel was changed to implement MADV_DONTNEED using only
down_read. Then the same sequence is just this:

page fault <- down_read(mmap_sem)
madvise <- down_read(mmap_sem)

(because changes to virtual memory allocation are batched).

I thought google's malloc was primarily written to fix this bad behaviour,
because with the new behaviour, glibc's malloc seems to beat google's
malloc on the performance and scalability tests I was running at the time,
as well as being more memory footprint friendly.

OTOH, it would be possible that hysteresis watermarks in glibc are not big
enough for a given application, which could introduce virtual address
activity back into the workload. These can be tuned, however.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
