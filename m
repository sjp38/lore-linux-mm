Subject: Re: questions on having a driver pin user memory for DMA
References: <38FE3B08.9FFB4C4E@giganet.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 20 Apr 2000 01:39:53 -0500
In-Reply-To: Weimin Tchen's message of "Wed, 19 Apr 2000 19:02:32 -0400"
Message-ID: <m1g0shi8cm.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Weimin Tchen <wtchen@giganet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Weimin Tchen <wtchen@giganet.com> writes:

The rules of thumb on this issue are:
1) Don't pin user memory let user space mmap driver memory.

   This appears to be what you are trying to achieve, with 
   your current implementation.  Think user getting direct
   access to kernel buffer, instead of kernel getting direct
   access to user buffer.  Same number of copies but
   the management is simpler...

2) If you must have access to user memory use the evolving kiobuf
   interface.  But that is mostly useful for the single shot
   read/write case.  
   
I'm a little dense, with all of the headers and trailers
that are put on packets how can it be efficient to DMA to/from
user memory?  You have to look at everything to compute checksums
etc.  

Your interface sounds like it walks around all of the networking
code in the kernel.  How can that be good?

> Hello,
> 
> Could you advise a former DEC VMS driver-guy who is a recent Linux
> convert with much to learn? I'm working on a driver for a NIC that
> support the Virtual Interface Architecture, which allows user processes
> to register arbitrary virtual address ranges for DMA network transmit or
> receive. The driver locks the user pages against paging and loads the
> NIC with the physical addresses of these pages. Thus the user process
> can initiate network DMA using its buffers directly (instead of having a
> driver copy between a buffer in kernel memory and a user buffer)..
> 
> There are at least 3 issues to resolve in registering this user memory
> for DMA that I need help on:
> 
> 1. lock against paging
> 2. after a fork(), copy-on-write changes the physical address of the
> user buffer

Only if written to.  It doesn't make sense to support writes
that happen a device while it is doing DMA.  Your only
resposibility to protect users from them selves is to prevent
kernel crashes.

> 3.a memory leak that can hang the system, if a process does: malloc a
> memory buffer, register this memory, free the memory, THEN deregister
> the memory.

Wrong interface. Using kiobufs or mmap clears this up.

> 
> - Issue 1.
> Initially our driver locked memory by  incrementing the page count. 

Which keeps the page from being freed.  Which garantees the
page won't be reused by another kernel proces.

> When
> that turned out to be insufficient, I added setting the PG_locked bit
> for the page frame. (However this bit is actually for locking during an
> IO transfer.
Well during a transfer in 2.3.x user space reads & writes also synchronize
with the page lock.

>  Thus I wonder if using PG_locked would cause a problem if
> the user memory is also mapped to a file.) Since toggling the PG_locked
> bit is not a counted semphore, it also doesn't handle pages that are
> registered multiple times. A common case would be 2 adjacent
> registrations that end & start on the same page (since the Virtual
> Interface Architecture allows buffers to be registered which are NOT
> paged aligned). Thus the first deregister will unlock the page even if
> it is part of another buffer setup for DMA.
> 
> I'm probably misreading this, but it appears that  /mm/memory.c:
> map_user_kiobuf() pins user memory by just incrementing the page count.

Yep.

> Will this actually prevent paging 

Paging is orthogonal it just gets a reference to the page, and keeps
the page from being reused by another kernel process until it is done.
The current users can still play with it...

> or will it only prevent the virtual
> address from being deleted from the user address space by a free()? 
It doesn't do that at all.

> I
> see that  /drivers/char/raw.c uses also has an #ifdef'ed call to
> lock_kiovec(). This function lock_kiovec() checks the PG_locked flag,
> and notes that multiply mapped pages are "Bad news". But our driver
> needs to support multiple mappings.

Right.  You can't have the same user page used for 2 different
positions in a single transaction.  It's just too confusing..

It's questionable if anyone will need lock_kiovec though...

> 
> Instead of using flags in the low-level page frame, I tried to use flags
> in the vm_area_struct (process memory region) structures. I also hoped
> to fix issue II (copy-on-write after fork) by setting VM_SHARED along w/
> VM_LOCKED.

No. You are getting farther, and farther from something maintainable.
Playing with the VM_AREA struct is silly.  It controls the user
view of memory.  If you need that implement an mmap operation.
If you are just borrowing the pages, use map_user_kiobuf... 

> So I tried adding private function from mlock.c into our
> driver, by skipping the resource check and not aligning on page
> boundaries and not merging segments. (Hopefully this would allow
> adjacent registrations in the same page.)  However after these changes,
> the driver could not load since these routines reference others that
> handle memory AVL trees (which had appeared to be public but actually
> aren't exported):
> 
> - insert_vms_struct(),
> - make_pages_present(),
> - vm_area_cachep().

Generally the call with this kind of this is to just add the
need functions to the exported list.  However for this
case you appear to be barking up the wrong tree.

> 
> 
> - Issue 2. (copy-on-write after fork):

Don't think register/deregister.  
Think read/write  -- kiobufs (1 shot deal)
or mmap/munmap   -- always there until the process dies, or the mumap.

> A process uses our driver to register memory for DMA by having the
> driver convert the process's buffer virtual pages into physical page
> adddresses which are then setup in the NIC for DMA. If the process forks
> a child, then the Linux kernel appears to avoid overhead by copying the
> vm_area_struct's and sharing the actual physical pages. 
Yep.

> If a write is
> done, the child gets the physical pages and the parent gets new physical
> pages which are copies. 

The first writer gets the copy, which could be parent or child.

> As a result the hardware is not pointing to the
> correct physical pages in the parent. 
Yep shure is you were just expecting something different.

> I was hoping to prevent this
> copy-on-write by making the memory shared (which could have program side
> effects) by setting VM_SHARED in the vm_area_struct. (Strangely VM_SHM
> doesn't appear to be used much). But as noted above, I can not use
> functions handing vm_area_struct's like those in mlock.c.

If you need that mmap.

> 
> Instead I have *temporarily* solved problems I & II by setting the
> PG_reserved flag in page frame (instead of PG_locked). But I'd much
> appreciate any advice on a better approach.
> 
> 
> - Issue 3: memory leak:
> There is a system memory leak which results from a slight application
> programming error, when a user buffer is free()'ed before being
> deregistered by our driver. 

If you go down the kernel primitives sbrk, and mmap & mumap I
can follow.  With malloc/free you aren't garanteed page alignment
or anything, so I can't tell what is happening at a kernel level.

> Repeated operations can hang the system.
> When memory is registered, our driver increments the page count to 2.
> This appears to prevent the free() & deregister (only decrements to 1)
> from releasing the memory. This is actually needed to prevent releasing
> the memory before unmapping it NIC from DMA. Instead of using the count,
> PG_reserved can be used.. However this also prevents the count from
> getting decremented and releasing as expected.

It looks like here you are trying to implement a weird form of mmap.
To do this right.  Let your driver call get_free_pages behind the
scenes of a mmap call, and then release those pages when a mapping
comes to an end.  This sounds like what you are struggling to implement.

> 
> I had expected free() to just put the memory back on the heap which
> would be cleaned-up at process exit. But glibc-2.1.2\malloc\malloc.c
> indicates that with large buffers, free() calls malloc_trim() which
> calls sbrk() with a negative argument. PG_reserved appears to prevent
> memory cleanup ( /mm/page_alloc.c:__free_pages() checks
> if (!PageReserved(page) && atomic_dec_and_test(&page->count)) before
> calling free_pages_ok() ). I haven't traced how our earlier use of
> PG_locked and incrementing the count, will also prevent free() from
> decrementing the count.

Playing with PG_reserved is just bad.  It's only usefull in special
cases.

> 
> When a process exits, the file_operations release function is run if the
> NIC device has not been closed. Thus by artifically dropping the page
> count in this function and doing __free_pages() , the leak can be
> prevented. However the driver would need to be modified to have our
> library's function to close_the_NIC()  not do a system close(),  in
> order to just use the file_operations release function for final
> cleanup. There apear to be other system dependencies involved here, so
> I'm not pursuing this further.
> 
> I don't understand why process exit code cleans up the virtual address
> space before closing remaining devices. ( /kernel/exit.c:do_exit() calls
> __exit_mm() and later calls __exit_files() ). I had hoped to cleanup
> registered memory  when __exit_files() runs our driver's release
> function and let __exit_mm() do the rest.

Well you still could.  exit_mm tears down the address space it doesn't
play with the except decreasing their count by one. If the count
is still elevated you can go back and do something to them...


Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
