Received: from giganet.com (gn75.giganet.com [208.239.8.75])
	by mail.giganet.com (8.8.7/8.8.7) with ESMTP id TAA27281
	for <linux-mm@kvack.org>; Thu, 20 Apr 2000 19:40:04 -0400
Message-ID: <38FF961B.ACF08696@giganet.com>
Date: Thu, 20 Apr 2000 19:43:23 -0400
From: Weimin Tchen <wtchen@giganet.com>
MIME-Version: 1.0
Subject: Re: questions on having a driver pin user memory for DMA
References: <38FE3B08.9FFB4C4E@giganet.com> <20000420132741.C16473@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:

> On 20 Apr 2000, Eric W. Biederman wrote:
>
> > Your interface sounds like it walks around all of the networking
> > code in the kernel.  How can that be good?
>
> It is not a NIC in the sense that you do TCP/IP over it. These
> NICs with VIA support are used in high speed homogenous networks
> between cluster nodes IIRC.

Yes, I should have explained better. Our NIC allows a user buffer to handle
message transfers & receives with a remote node also fitted our NIC. We have
recently added another driver that fits our software & hardware under the
TCP/IP stack using skb's & netif_rx() etc like the ethernet driver does. But
direct user-level access of the NIC is more efficient with minimal kernel
support.

user-level program with user-level memory
  |         or VI arch library calls
DMA      |
  |         or VI driver
NIC which has an ASIC that can DMA into/from user-level memory
  |
 +--- point-to-point connection to a remote node with our NIC or to our switch
box ---  etc.


For standard Ethernet, the software and hardware contrilbute about equal
overhead to total message latency. With gigabit-speed networks, the hardware
latency is a minor concern in comparison with the much higher software
overhead. The NIC's DMA skips much of the kernel work. One use of our product
is in scientific applications that can be run in parallel on PC's with fast
access to shared data. Our product can be layered underneath MPI Software
Technology 's Message Passing Interface library that is used by the scientific
community.

If you are interested here is more info on VI (Virtual Interface Arch)
    http://www.viarch.org/
    http://www.intel.com/design/servers/vi/
    http://www.mpi-softtech.com/



"Stephen C. Tweedie" wrote:

> Sure.  I'm a former DEC VMS F11BXQP and Spiralog guy myself.

Then Linux internals must seem to be a breeze compared w/ XQP crashes. My hat
is off to people who handled XQP, like Robert Rappaport . DEC did excellent
clustering using its proprietary SCS message protocol over a proprietary CI
bus. But inexpensive hardware and common standards are winning the day.


>
> > 2. after a fork(), copy-on-write changes the physical address of the
> > user buffer
>
> What fork() semantics do you want, though?  VIA is a little ambiguous
> about this right now.
>

The MPI library does a fork() outside of user program control, so this can
steal away the physical pages setup by the parent for DMA, without warning. We
didn't notice this since our library uses pthreads which probably clones to
share the adderss space.


>
> > 3.a memory leak that can hang the system, if a process does: malloc a
> > memory buffer, register this memory, free the memory, THEN deregister
> > the memory.
>
> Shouldn't be a problem if you handle page reference counts correctly.

By checking page count inside our driver, it appears that:

malloc() sets page count = 1
our driver's memory register operation increments count to 2
out-of-order free() does NOT reduce count (even when we were using PG_locked
instead of PG_reserved)
our driver's memory DEregister operation decrements count to 1

As a result, the page does not get released back to the system.



> > 1. lock against paging
>
> Simple enough.  Just a page reference count increment is enough for
> this.

Originally we thought that handling the page count was enough to prevent
paging, but DMA was not occuring into the correct user memory, when there was
heavy memory use by another application. This was fixed by setting PG_locked
on the page. (Now I'm using PG_reserved to also solve the fork() problem.)

> > - Issue 1.
> > Initially our driver locked memory by  incrementing the page count. When
> > that turned out to be insufficient,
>
> In what way is it insufficient?  An unlocked page may be removed from
> the process's page tables, but as long as the refcount is held on the
> physical page it should never actually be destroyed, and the mapping
> between VA and physical page should be restored on any subsequent page
> fault.
>

I imagine that if a CPU instruction references a virtual page that has been
totally paged out to disk, then the kernel will fixup the fault and setup a
NEW physical page with a copy of data from disk. However our NIC just DMA's to
the physical memory without faulting on a virtual address.


> > I added setting the PG_locked bit
> > for the page frame. (However this bit is actually for locking during an
> > IO transfer. Thus I wonder if using PG_locked would cause a problem if
> > the user memory is also mapped to a file.)
>
> It shouldn't do.
>

Thanks. I'm concerned about a user buffer being mapped to a file also. So when
file IO is done, the PG_locked flag would be cleared so the page is no longer
pinned.

>
> > I'm probably misreading this, but it appears that  /mm/memory.c:
> > map_user_kiobuf() pins user memory by just incrementing the page count.
> > Will this actually prevent paging or will it only prevent the virtual
> > address from being deleted from the user address space by a free()?
>
> It prevents the physical page from being destroyed until the corresponding
> free_page.  It also prevents the VA-to-physical-page mapping from
> disappearing,

I'm unclear: does a page count > 0
- only reserve the page frame structure so that new physical memory can be
setup when paging-in
- or does it actually keep the physical memory allocated for that user memory
virtual address ?


>  I also hoped
> > to fix issue II (copy-on-write after fork) by setting VM_SHARED along w/
> > VM_LOCKED.
>
> We already have a solution to the fork issue and are currently trying
> to persuade Linus to accept it.  Essentially you just have to be able
> to force a copy-out instead of deferring COW when you fork on a page
> which has outstanding hardware IO mapped, unless the VMA is VM_SHARED.
>

Is sounds great. Did you run into similar problems w/ fork()? We saw this even
if the child very little so probably did not touch the registered pages (which
seems to be contrary to COW operation).

>
> PG_reserved is actually quite widely used for this sort of thing.
> It is quite legitimate as long as you are very careful about what
> sort of pages you apply it to.  Specifically, you need to have
> cleanup in place for when the area is released, and that implies
> that PG_reserved is only really legal if you are using it on pages
> which have been explicitly allocated by a driver and mmap()ed into
> user space.
>

Yes I saw PG_reserved used in many drivers, but I'm concerned that this is a
kludge that has side effects. Rubini's book recommended not using it. Our
driver uses it in both a memory registration ioctl() and in a mmap operaton.
Our driver cleans-up in a DEregister ioctl() by using our driver's structures
that record the locked pages. This cleanup also gets run by the drivers's
release operations if the program aborts.



>
> > PG_reserved appears to prevent
> > memory cleanup

> Correct.  That's why you need to be mmap()ing, not using map_user_kiobuf,
> to use PG_reserved.  Either that, or you record which pages the driver
> has reserved, and release them manually when some other trigger happens
> such as a close of a driver file descriptor.
>

Yes our driver does that.

Thanks to all of you for your advice,
-Weimin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
