Date: Mon, 11 Oct 1999 11:52:16 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <14338.1300.124586.764594@dukat.scot.redhat.com>
Message-ID: <Pine.GSO.4.10.9910111148050.18777-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 11 Oct 1999, Stephen C. Tweedie wrote:

> The swapper has very strict requirements: to avoid blocking it requires
> the big lock and the page table spinlocks, so that it can survive
> without the mm semaphore.  Adding the mm semaphore to the swapout loop
> is not really an option.  That means that you need the kernel lock when
> modifying vma lists.

Ouch...

> We can, however, improve things by using a per-mm spinlock instead of
> using the kernel lock to provide that guarantee.

->swapout() may block. We have three areas here:
1. vma accesses in swapper.
2. vma list reads outside of swapper.
3. vma modifications/destruction.

Looks like we need exclusion between 1 and 3 (on per-mm basis, that is).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
