Date: Mon, 11 Oct 1999 18:31:37 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <14338.25285.780802.755159@dukat.scot.redhat.com>
Message-ID: <Pine.GSO.4.10.9910111823320.18777-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 11 Oct 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Mon, 11 Oct 1999 17:40:52 -0400 (EDT), Alexander Viro
> <viro@math.psu.edu> said:
> 
> > Agreed, but the big lock does not (and IMHO should not) cover the vma list
> > modifications.
> 
> Fine, but as I've said you need _something_.  It doesn't matter what,
> but the fact that the kernel lock is no longer being held for vma
> updates has introduced swapper races.  We can't fix those without either
> restoring or replacing the big lock.

And spinlock being released in the ->swapout() is outright ugly. OK, so
we are adding to mm_struct a new semaphore (vma_sem) and getting it around
the places where the list is modified + in the swapper (for scanning). In
normal situation it will never give us contention - everyone except
swapper uses it with mmap_sem already held. Are there any objections
against it? If it's OK I'll go ahead and do it. Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
