From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.1300.124586.764594@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 16:41:08 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910101202240.16317-100000@weyl.math.psu.edu>
References: <3800B629.209B7A22@colorfullife.com>
	<Pine.GSO.4.10.9910101202240.16317-100000@weyl.math.psu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Oct 1999 12:07:38 -0400 (EDT), Alexander Viro
<viro@math.psu.edu> said:

>> eg. sys_mprotect calls merge_segments without lock_kernel().

> Manfred, Andrea - please stop it. Yes, it does and yes, it should.
> Plonking the big lock around every access to VM is _not_ a solution. If
> swapper doesn't use mmap_sem - _swapper_ should be fixed. How the hell
> does lock_kernel() have smaller deadlock potential than
> down(&mm->mmap_sem)?

The swapout code cannot claim the mmap semaphore.  There are just too
many deadlock possibilities.  For example, the whole VM assumes that it
is safe to try to allocate memory while holding the mmap semaphore.  How
are you going to make that work if we are short of immediately free
pages and the allocation request recurses into the swapper?

The swapper has very strict requirements: to avoid blocking it requires
the big lock and the page table spinlocks, so that it can survive
without the mm semaphore.  Adding the mm semaphore to the swapout loop
is not really an option.  That means that you need the kernel lock when
modifying vma lists.

We can, however, improve things by using a per-mm spinlock instead of
using the kernel lock to provide that guarantee.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
