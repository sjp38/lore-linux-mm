Message-ID: <380716EA.78714F94@colorfullife.com>
Date: Fri, 15 Oct 1999 13:58:34 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
References: <199910150006.RAA47575@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:
> swapout() currently takes the vma as an input,
> but the vma might be getting deleted (the documentation which is
> part of the patch describes currently how things are protected),
> so it might be prudent to pass individual fields of the vma to the
> swapout() method, rather than a pointer to the structure.

passing the individual fields of the vma is impossible:
only swap_out knows which field of the vma are important, and which
locking is required (eg fget()).

AFAICS, there are only 2 acceptable solutions:
- lock_kernel() as in your patch.
- swap_out() is called with the semaphore held, and it sleeps with the
semaphore. [I prefer this solution: it's the first step towards swapping
without lock_kernel()].

Or: ->swapout() releases the semaphore, or split ->swapout() into 2
parts.


> +               /*
> +                * The lock_kernel interlocks with kswapd try_to_swap_out
> +                * invoking a driver swapout() method, and being able to
> +                * guarantee vma existance.
> +                */
>                 lock_kernel();
>                 if (mpnt->vm_ops && mpnt->vm_ops->unmap)
>                         mpnt->vm_ops->unmap(mpnt, st, size);
> [...]
>         flush_tlb_page(vma, address);
> +       vmlist_access_unlock(vma->vm_mm);
>         swap_duplicate(entry);  /* One for the process, one for the swap cache */
> 
>         /* This will also lock the page */

I thought that the page stealer would call ->swapout() while owning the
vmlist_lock. 
a) there should be no lock-up, because the swapper is never reentered
[PF_MEMALLOC].
b) noone except the swapper is allowed to sleep while owning
vmlist_lock.
c) getting rid of that lock_kernel() call is one of the main aims of the
vmlist_lock.

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
