From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910152139.OAA57321@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
Date: Fri, 15 Oct 1999 14:39:03 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9910151417360.852-100000@penguin.transmeta.com> from "Linus Torvalds" at Oct 15, 99 02:24:18 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: manfreds@colorfullife.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> 
> On Fri, 15 Oct 1999, Kanoj Sarcar wrote:
> > 
> > The reason I am not very keen on this solution either is if you 
> > consider process A holding vmlist_access_lock of B, going into swapout(),
> > where it tries to get a (sleeping) driver lock. Meanwhile, process B
> > has the driver lock, and is trying to grab the vmlist_update_lock on
> > itself, ie B, maybe to add/delete the vma. I do not think there is
> > such a driver currently though.
> 
> I am convinced that all these games are unnecessary, and that the problem
> is fundamentally different. Not fixing up the current code, but just
> looking at the problem differently - making the deadlock go away by virtue
> of avoiding the critical regions.
> 
> I think the suggestion to change the semantics of "swapout" is a good one.
> Now we have the mm layer passing down the vma to the IO layer, and hat
> makes everything more complex. I would certainly agree with just changing
> that semantic detail, and changing swapout to something like
> 
> 	.. hold a spinlock - we can probably just reuse the
> 	   page_table_lock for this to avoid multiple levels of locking
> 	   here..
> 
> 	file = fget(vma->vm_file);
> 	offset = file->f_offset + (address - vma->vm_start);
> 	flush_tlb_page(vma, address);
> 	spin_unlock(&vma->vm_mm->page_table_lock);
> 
> 	error = file->f_ops->swapout(file, offset, page);
> 	fput(file);
> 
> 	...
> 
> and then the other requirement would be that whenever the vma chain is
> physically modified, you also have to hold the page_table_lock. 
> 
> And finally, we rename the "page_table_lock" to the "page_stealer_lock",
> and we're all done.
> 
> Does anybody see anything fundamentally wrong here? It looks like it
> should fix the problem without introducing any new locks, and without
> holding any locks across the actual physical swapout activity.
>

Linus,

This basically means that you are overloading the page_table_lock to do 
the work of the vmlist_lock in my patch. Thus vmlist_modify_lock/
vmlist_access_lock in my patch could be changed in mm.h to grab the 
page_table_lock. As I mentioned before, moving to a spinlock to 
protect the vma chain will need some changes to the vmscan.c code.

The reason I think most people suggested a different lock, namely vmlist_lock,
is to reduce contention on the page_table_lock, so that all the other
paths like mprotect/mlock/mmap/munmap do not end up grabbing the
page_table_lock which is grabbed in the fault path. Grabbing the
page_table_lock while doing things like merge_segments/insert_vm_struct
would seem to increase the hold time of the spinlock. Pte protection
and vma chain protection are quite distinct things too.

Let me know how you want me to rework the patch. Imo, we should keep
the macros vmlist_modify_lock/vmlist_access_lock, even if we do
decide to overload the page table lock.

Once we have put the (modified?) patch in, I can look at the swapout()
interface cleanup.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
