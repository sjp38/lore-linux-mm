Received: from giganet.com (gn75.giganet.com [208.239.8.75])
	by mail.giganet.com (8.8.7/8.8.7) with ESMTP id SAA04826
	for <linux-mm@kvack.org>; Wed, 19 Apr 2000 18:59:14 -0400
Message-ID: <38FE3B08.9FFB4C4E@giganet.com>
Date: Wed, 19 Apr 2000 19:02:32 -0400
From: Weimin Tchen <wtchen@giganet.com>
MIME-Version: 1.0
Subject: questions on having a driver pin user memory for DMA
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Could you advise a former DEC VMS driver-guy who is a recent Linux
convert with much to learn? I'm working on a driver for a NIC that
support the Virtual Interface Architecture, which allows user processes
to register arbitrary virtual address ranges for DMA network transmit or
receive. The driver locks the user pages against paging and loads the
NIC with the physical addresses of these pages. Thus the user process
can initiate network DMA using its buffers directly (instead of having a
driver copy between a buffer in kernel memory and a user buffer)..

There are at least 3 issues to resolve in registering this user memory
for DMA that I need help on:

1. lock against paging
2. after a fork(), copy-on-write changes the physical address of the
user buffer
3.a memory leak that can hang the system, if a process does: malloc a
memory buffer, register this memory, free the memory, THEN deregister
the memory.

- Issue 1.
Initially our driver locked memory by  incrementing the page count. When
that turned out to be insufficient, I added setting the PG_locked bit
for the page frame. (However this bit is actually for locking during an
IO transfer. Thus I wonder if using PG_locked would cause a problem if
the user memory is also mapped to a file.) Since toggling the PG_locked
bit is not a counted semphore, it also doesn't handle pages that are
registered multiple times. A common case would be 2 adjacent
registrations that end & start on the same page (since the Virtual
Interface Architecture allows buffers to be registered which are NOT
paged aligned). Thus the first deregister will unlock the page even if
it is part of another buffer setup for DMA.

I'm probably misreading this, but it appears that  /mm/memory.c:
map_user_kiobuf() pins user memory by just incrementing the page count.
Will this actually prevent paging or will it only prevent the virtual
address from being deleted from the user address space by a free()? I
see that  /drivers/char/raw.c uses also has an #ifdef'ed call to
lock_kiovec(). This function lock_kiovec() checks the PG_locked flag,
and notes that multiply mapped pages are "Bad news". But our driver
needs to support multiple mappings.

Instead of using flags in the low-level page frame, I tried to use flags
in the vm_area_struct (process memory region) structures. I also hoped
to fix issue II (copy-on-write after fork) by setting VM_SHARED along w/
VM_LOCKED. So I tried adding private function from mlock.c into our
driver, by skipping the resource check and not aligning on page
boundaries and not merging segments. (Hopefully this would allow
adjacent registrations in the same page.)  However after these changes,
the driver could not load since these routines reference others that
handle memory AVL trees (which had appeared to be public but actually
aren't exported):

- insert_vms_struct(),
- make_pages_present(),
- vm_area_cachep().


- Issue 2. (copy-on-write after fork):
A process uses our driver to register memory for DMA by having the
driver convert the process's buffer virtual pages into physical page
adddresses which are then setup in the NIC for DMA. If the process forks
a child, then the Linux kernel appears to avoid overhead by copying the
vm_area_struct's and sharing the actual physical pages. If a write is
done, the child gets the physical pages and the parent gets new physical
pages which are copies. As a result the hardware is not pointing to the
correct physical pages in the parent. I was hoping to prevent this
copy-on-write by making the memory shared (which could have program side
effects) by setting VM_SHARED in the vm_area_struct. (Strangely VM_SHM
doesn't appear to be used much). But as noted above, I can not use
functions handing vm_area_struct's like those in mlock.c.

Instead I have *temporarily* solved problems I & II by setting the
PG_reserved flag in page frame (instead of PG_locked). But I'd much
appreciate any advice on a better approach.


- Issue 3: memory leak:
There is a system memory leak which results from a slight application
programming error, when a user buffer is free()'ed before being
deregistered by our driver. Repeated operations can hang the system.
When memory is registered, our driver increments the page count to 2.
This appears to prevent the free() & deregister (only decrements to 1)
from releasing the memory. This is actually needed to prevent releasing
the memory before unmapping it NIC from DMA. Instead of using the count,
PG_reserved can be used.. However this also prevents the count from
getting decremented and releasing as expected.

I had expected free() to just put the memory back on the heap which
would be cleaned-up at process exit. But glibc-2.1.2\malloc\malloc.c
indicates that with large buffers, free() calls malloc_trim() which
calls sbrk() with a negative argument. PG_reserved appears to prevent
memory cleanup ( /mm/page_alloc.c:__free_pages() checks
if (!PageReserved(page) && atomic_dec_and_test(&page->count)) before
calling free_pages_ok() ). I haven't traced how our earlier use of
PG_locked and incrementing the count, will also prevent free() from
decrementing the count.

When a process exits, the file_operations release function is run if the
NIC device has not been closed. Thus by artifically dropping the page
count in this function and doing __free_pages() , the leak can be
prevented. However the driver would need to be modified to have our
library's function to close_the_NIC()  not do a system close(),  in
order to just use the file_operations release function for final
cleanup. There apear to be other system dependencies involved here, so
I'm not pursuing this further.

I don't understand why process exit code cleans up the virtual address
space before closing remaining devices. ( /kernel/exit.c:do_exit() calls
__exit_mm() and later calls __exit_files() ). I had hoped to cleanup
registered memory  when __exit_files() runs our driver's release
function and let __exit_mm() do the rest.

Thanks for any advice,
-Weimin Tchen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
