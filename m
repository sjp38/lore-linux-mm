From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910151638.JAA72758@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
Date: Fri, 15 Oct 1999 09:38:45 -0700 (PDT)
In-Reply-To: <380716EA.78714F94@colorfullife.com> from "Manfred Spraul" at Oct 15, 99 01:58:34 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: torvalds@transmeta.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> Kanoj Sarcar wrote:
> > swapout() currently takes the vma as an input,
> > but the vma might be getting deleted (the documentation which is
> > part of the patch describes currently how things are protected),
> > so it might be prudent to pass individual fields of the vma to the
> > swapout() method, rather than a pointer to the structure.
> 
> passing the individual fields of the vma is impossible:
> only swap_out knows which field of the vma are important, and which
> locking is required (eg fget()).
> 

Note that currently, the only swapout() method which does anything is
filemap_swapout, and what it really needs from the vma is vm_file. Yes,
changing a driver interface is not the best solution, but a new 2.X
release is the place to do it. If you wanted to be more careful, you 
could define the swapout prototype as swapout(start, end, flags, file).
That *should* be enough for most future 2.3/2.4 driver. 

There is also a cleaner way to do this. Have a field vm_drvhandle in
the vma, pass that to the swapout routine. Any driver which has a 
swapout() routine will maintain whatever private data it needs to
implement the swapout, tagged with this specific vm_drvhandle value
that it fills in at open/mmap time. 

> AFAICS, there are only 2 acceptable solutions:
> - lock_kernel() as in your patch.

IMO, we can do better.

> - swap_out() is called with the semaphore held, and it sleeps with the
> semaphore. [I prefer this solution: it's the first step towards swapping
> without lock_kernel()].
>

Look below for why this is not safe.
 
> Or: ->swapout() releases the semaphore, or split ->swapout() into 2
> parts.
> 

This works for filemap_swapout, but you can not expect every regular Joe
driver writer to adhere to this rule. What do you mean by splitting 
swapout() into 2 parts?

> 
> > +               /*
> > +                * The lock_kernel interlocks with kswapd try_to_swap_out
> > +                * invoking a driver swapout() method, and being able to
> > +                * guarantee vma existance.
> > +                */
> >                 lock_kernel();
> >                 if (mpnt->vm_ops && mpnt->vm_ops->unmap)
> >                         mpnt->vm_ops->unmap(mpnt, st, size);
> > [...]
> >         flush_tlb_page(vma, address);
> > +       vmlist_access_unlock(vma->vm_mm);
> >         swap_duplicate(entry);  /* One for the process, one for the swap cache */
> > 
> >         /* This will also lock the page */
> 
> I thought that the page stealer would call ->swapout() while owning the
> vmlist_lock. 
> a) there should be no lock-up, because the swapper is never reentered
> [PF_MEMALLOC].
> b) noone except the swapper is allowed to sleep while owning
> vmlist_lock.

How about this. Process A runs short of memory, decides to swap_out its
own mm. It victimizes vma V, whose swapout() routine goes to sleep with
A's vmlist lock, waiting for a sleeping lock L. Meanwhile, lock L is 
held by process B, who runs short of memory, and decides to steal from
A. But, A's vmlist lock is held. Deadlock, right?

If you read the documentation which is part of the patch, this is why
I clearly point out that holding vmlist_lock into driver methods is not 
safe at all.

> c) getting rid of that lock_kernel() call is one of the main aims of the
> vmlist_lock.
> 

Yes, and there's a bunch of ways to achieve that.

And here's one more. Before invoking swapout(), and before loosing the 
vmlist_lock in try_to_swap_out, the vma might be marked with a flag
that indicates that swapout() is looking at the vma. do_munmap will 
look at this flag and put itself to sleep on a synchronization 
variable. After swapout() terminates, the page stealer will wake up 
anyone waiting in do_munmap to continue destroying the vma.

This swapout() cleanup is independent of the patch I have already posted,
so the patch should be integrated into 2.3, while we debate how to tackle
the cleanup.

Thanks.

Kanoj

> --
> 	Manfred
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
