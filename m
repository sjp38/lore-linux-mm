Date: Thu, 20 Apr 2000 13:27:41 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: questions on having a driver pin user memory for DMA
Message-ID: <20000420132741.C16473@redhat.com>
References: <38FE3B08.9FFB4C4E@giganet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38FE3B08.9FFB4C4E@giganet.com>; from wtchen@giganet.com on Wed, Apr 19, 2000 at 07:02:32PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Weimin Tchen <wtchen@giganet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 19, 2000 at 07:02:32PM -0400, Weimin Tchen wrote:
> 
> Could you advise a former DEC VMS driver-guy who is a recent Linux
> convert with much to learn?

Sure.  I'm a former DEC VMS F11BXQP and Spiralog guy myself. Pleased
to meet you!  :-)

> There are at least 3 issues to resolve in registering this user memory
> for DMA that I need help on:
> 
> 1. lock against paging

Simple enough.  Just a page reference count increment is enough for
this.

> 2. after a fork(), copy-on-write changes the physical address of the
> user buffer

What fork() semantics do you want, though?  VIA is a little ambiguous
about this right now.

> 3.a memory leak that can hang the system, if a process does: malloc a
> memory buffer, register this memory, free the memory, THEN deregister
> the memory.

Shouldn't be a problem if you handle page reference counts correctly.

> - Issue 1.
> Initially our driver locked memory by  incrementing the page count. When
> that turned out to be insufficient,

In what way is it insufficient?  An unlocked page may be removed from
the process's page tables, but as long as the refcount is held on the
physical page it should never actually be destroyed, and the mapping
between VA and physical page should be restored on any subsequent page
fault.

> I added setting the PG_locked bit
> for the page frame. (However this bit is actually for locking during an
> IO transfer. Thus I wonder if using PG_locked would cause a problem if
> the user memory is also mapped to a file.)

It shouldn't do.

> I'm probably misreading this, but it appears that  /mm/memory.c:
> map_user_kiobuf() pins user memory by just incrementing the page count.
> Will this actually prevent paging or will it only prevent the virtual
> address from being deleted from the user address space by a free()?

It prevents the physical page from being destroyed until the corresponding
free_page.  It also prevents the VA-to-physical-page mapping from 
disappearing, unless the user happens to do a new mmap or munmap on
that VA range.  If that happens, the physical page is dissociated from the
VA but remains available to the driver, so nothing bad happens.

> see that  /drivers/char/raw.c uses also has an #ifdef'ed call to
> lock_kiovec(). This function lock_kiovec() checks the PG_locked flag,
> and notes that multiply mapped pages are "Bad news". But our driver
> needs to support multiple mappings.

That's why we don't do a lock_kiovec() by default right now.

> Instead of using flags in the low-level page frame, I tried to use flags
> in the vm_area_struct (process memory region) structures. I also hoped
> to fix issue II (copy-on-write after fork) by setting VM_SHARED along w/
> VM_LOCKED.

We already have a solution to the fork issue and are currently trying 
to persuade Linus to accept it.  Essentially you just have to be able
to force a copy-out instead of deferring COW when you fork on a page 
which has outstanding hardware IO mapped, unless the VMA is VM_SHARED.

> Instead I have *temporarily* solved problems I & II by setting the
> PG_reserved flag in page frame (instead of PG_locked). But I'd much
> appreciate any advice on a better approach.

PG_reserved is actually quite widely used for this sort of thing.  
It is quite legitimate as long as you are very careful about what 
sort of pages you apply it to.  Specifically, you need to have 
cleanup in place for when the area is released, and that implies
that PG_reserved is only really legal if you are using it on pages
which have been explicitly allocated by a driver and mmap()ed into
user space.

> - Issue 3: memory leak:
> There is a system memory leak which results from a slight application
> programming error, when a user buffer is free()'ed before being
> deregistered by our driver. Repeated operations can hang the system.
> When memory is registered, our driver increments the page count to 2.
> This appears to prevent the free() & deregister (only decrements to 1)
> from releasing the memory.

That's correct.  The memory may no longer be in use by the driver, 
but until the application munmap()s it it is still registered as in 
use by the application.

> I had expected free() to just put the memory back on the heap which
> would be cleaned-up at process exit. But glibc-2.1.2\malloc\malloc.c
> indicates that with large buffers, free() calls malloc_trim() which
> calls sbrk() with a negative argument.

As far as the kernel is concerned internally, the unmapping fixup which
happens is the same in both cases.

> PG_reserved appears to prevent
> memory cleanup ( /mm/page_alloc.c:__free_pages() checks
> if (!PageReserved(page) && atomic_dec_and_test(&page->count)) before
> calling free_pages_ok() ).

Correct.  That's why you need to be mmap()ing, not using map_user_kiobuf,
to use PG_reserved.  Either that, or you record which pages the driver
has reserved, and release them manually when some other trigger happens
such as a close of a driver file descriptor.

> I don't understand why process exit code cleans up the virtual address
> space before closing remaining devices. ( /kernel/exit.c:do_exit() calls
> __exit_mm() and later calls __exit_files() ).

Driver-related memory functions are expected to be within driver-specific
mmap()ed areas, so the appropriate driver callback happens in exit_mm, 
not in exit_files.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
