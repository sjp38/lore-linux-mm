Date: Sun, 10 Oct 1999 15:03:45 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <3800DE17.935ADF8D@colorfullife.com>
Message-ID: <Pine.GSO.4.10.9910101450250.16317-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 10 Oct 1999, Manfred Spraul wrote:

> Alexander Viro wrote:
> > I'm not sure that it will work (we scan the thing in many places and
> > quite a few may be blocking ;-/), unless you propose to protect individual
> > steps of the scan, which will give you lots of overhead.
> 
> The overhead should be low, we could keep the "double synchronization",
> ie
> * either down(&mm->mmap_sem) or spin_lock(&mm->vma_list_lock) for read
> * both locks for write.
> 
> I think that 3 to 5 spin_lock() calls are required.

Hold on. In swap_out_mm() you have to protect find_vma() (OK, it doesn't
block, but we'll have to take care of mm->mmap_cache) _and_ you'll have to
protect vma from destruction all way down to try_to_swap_out(). And to
vma->swapout(). Which can sleep, so spinlocks are out of question here.

I still think that just keeping a cyclic list of pages, grabbing from that
list before taking mmap_sem _if_ we have a chance for blocking
__get_free_page(), refilling if the list is empty (prior to down()) and
returning the page into the list if we didn't use it may be the simplest
way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
