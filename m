Date: Fri, 5 Jul 2002 09:33:15 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: vm lock contention reduction
Message-ID: <20020705073315.GU1227@dualathlon.random>
References: <Pine.LNX.4.44.0207042237130.7465-100000@home.transmeta.com> <Pine.LNX.4.44.0207042257210.7465-100000@home.transmeta.com> <3D253DC9.545865D4@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D253DC9.545865D4@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2002 at 11:33:45PM -0700, Andrew Morton wrote:
> Well.  First locks first.  kmap_lock is a bad one on x86.

Actually I thought about kmap_lock and the per-process kmaps a bit more
with Martin (cc'ed) during OLS and there is an easy process-scalable
solution to drop:

	the kmap_lock
	in turn the global pool
	in turn the global tlb flush

The only problem is that it's not anymore both atomic *and* persistent,
it's only persistent. It's also atomic if the mm_count == 1, but the
kernel cannot rely on it, it has to assume it's a blocking operation
always (you find it out if it's blocking only at runtime).

In short the same design of the per-process kmaps will work just fine if
we add a semaphore to the mm_struct. then before starting using the kmap
entry we must acquire the semaphore. This way all the global locking and
global tlb flush goes away completely for normal tasks, but still
remains the contention of that per-mm semaphore with threads doing
simutaneous pte manipulation or simultaneous pagecache I/O though.
Furthmore this I/O will be serialized, threaded benchmark like dbench
may perform poorly that way I suspect, or we should add a pool of
userspace pages so more than 1 thread is allowed to go ahead, but still
we may cacheline-bounce in the synchronization of the pool across
threads (similar to what we do now in the global pool).

Then there's the problem the pagecache/FS API should be changed to pass
the vaddr through the stack because page->virtual would go away, the
virtual address would be per-process protected by the mm->kmap_sem so we
couldn't store it in a global, all tasks can kmap the same page at the
same time at virtual vaddr. This as well will break some common code.

Last but not the least, I hope in 2.6 production I won't be running
benchmarks and profiling using a 32bit cpu anymore anyways.

So I'm not very motivated anymore in doing that change after the comment
from Linus about the issue with threads.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
