Message-ID: <3D27AC81.FC72D08F@zip.com.au>
Date: Sat, 06 Jul 2002 19:50:41 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <Pine.LNX.4.44.0207042237130.7465-100000@home.transmeta.com> <Pine.LNX.4.44.0207042257210.7465-100000@home.transmeta.com> <3D253DC9.545865D4@zip.com.au> <20020705073315.GU1227@dualathlon.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 
> On Thu, Jul 04, 2002 at 11:33:45PM -0700, Andrew Morton wrote:
> > Well.  First locks first.  kmap_lock is a bad one on x86.
> 
> Actually I thought about kmap_lock and the per-process kmaps a bit more
> with Martin (cc'ed) during OLS and there is an easy process-scalable
> solution to drop:

Martin is being bitten by the global invalidate more than by the lock.
He increased the size of the kmap pool just to reduce the invalidate
frequency and saw 40% speedups of some stuff.

Those invalidates don't show up nicely on profiles.

>         the kmap_lock
>         in turn the global pool
>         in turn the global tlb flush
> 
> The only problem is that it's not anymore both atomic *and* persistent,
> it's only persistent. It's also atomic if the mm_count == 1, but the
> kernel cannot rely on it, it has to assume it's a blocking operation
> always (you find it out if it's blocking only at runtime).

I was discussing this with sct a few days back.  iiuc, the proposal
was to create a small per-cpu pool (say, 4-8 pages) which is a
"front-end" to regular old kmap().

Any time you have one of these pages in use, the process gets
pinned onto the current CPU. If we run out of per-cpu kmaps,
just fall back to traditional kmap().

It does mean that this variant of kmap() couldn't just return
a `struct page *' - it would have to return something richer
than that.

> In short the same design of the per-process kmaps will work just fine if
> we add a semaphore to the mm_struct. then before starting using the kmap
> entry we must acquire the semaphore. This way all the global locking and
> global tlb flush goes away completely for normal tasks, but still
> remains the contention of that per-mm semaphore with threads doing
> simutaneous pte manipulation or simultaneous pagecache I/O though.
> Furthmore this I/O will be serialized, threaded benchmark like dbench
> may perform poorly that way I suspect, or we should add a pool of
> userspace pages so more than 1 thread is allowed to go ahead, but still
> we may cacheline-bounce in the synchronization of the pool across
> threads (similar to what we do now in the global pool).
> 
> Then there's the problem the pagecache/FS API should be changed to pass
> the vaddr through the stack because page->virtual would go away, the
> virtual address would be per-process protected by the mm->kmap_sem so we
> couldn't store it in a global, all tasks can kmap the same page at the
> same time at virtual vaddr. This as well will break some common code.
> 
> Last but not the least, I hope in 2.6 production I won't be running
> benchmarks and profiling using a 32bit cpu anymore anyways.
> 
> So I'm not very motivated anymore in doing that change after the comment
> from Linus about the issue with threads.

I believe that IBM have 32gig, 8- or 16-CPU ia32 machines just
coming into production now.  Presumably, they're not the only
ones.  We're stuck with this mess for another few years.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
