Date: Mon, 11 Oct 1999 01:28:36 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910101759340.17820-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.10.9910110120590.2621-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Oct 1999, Alexander Viro wrote:

>mm - no list modifications, no vma removal, etc. We could introduce a new
>semaphore (spinlocks are not going to work - ->swapout gets vma as

We could add a reference count to each vma protected by a per-mm spinlock.
Then we could drop the spinlock in swap_out_mm as soon as we incremented
the refcount of the vma. I am talking by memory, I am not sure if it can
be really done and if it's the right thing to do this time. (I'll check
the code ASAP).

>argument and it can sleep. The question being: where can we trigger
>__get_free_pages() with __GFP_WAIT if the mmap_sem is held? And another

All userspace allocations do exactly that.

>one - where do we modify ->mmap? If they can be easily separated -

We modify mmap in the mmap.c and infact we hold the semaphore there too.

The reason they are not separated is that during all the page fault path
you can't have _your_ vmas to change under you if another thread is
running munmap in parallel.

>eat the fs on the testbox ;-), but I'ld be really grateful if some of VM
>people would check the results.

I can check them of course ;).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
