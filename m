Message-ID: <3801059B.D9C64189@colorfullife.com>
Date: Sun, 10 Oct 1999 23:31:07 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.GSO.4.10.9910101450250.16317-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> Hold on. In swap_out_mm() you have to protect find_vma() (OK, it doesn't
> block, but we'll have to take care of mm->mmap_cache) _and_ you'll have to
> protect vma from destruction all way down to try_to_swap_out(). And to
> vma->swapout(). Which can sleep, so spinlocks are out of question here.

I found vma->swapout() when I tried to implement it. Sh... 
We could make vma_list_lock a semaphore, but I haven't checked for any
hidden problems yet.

> 
> I still think that just keeping a cyclic list of pages, grabbing from that
> list before taking mmap_sem _if_ we have a chance for blocking
> __get_free_page(), refilling if the list is empty (prior to down()) and
> returning the page into the list if we didn't use it may be the simplest
> way.

I don't like the idea, but it sounds possible.
A problem could be that the page-in functions can allocate memory:
do_nopage() -> filemap_nopage(): it calls i_op->readpage() which would
call get_block(), eg ext2: load the indirect page, this needs memory -->
OOM.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
