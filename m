Received: from mailhost.uni-koblenz.de (mailhost.uni-koblenz.de [141.26.64.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA31600
	for <linux-mm@kvack.org>; Fri, 2 Apr 1999 08:08:18 -0500
Received: from lappi.waldorf-gmbh.de (cacc-14.uni-koblenz.de [141.26.131.14])
	by mailhost.uni-koblenz.de (8.9.1/8.9.1) with ESMTP id PAA27760
	for <linux-mm@kvack.org>; Fri, 2 Apr 1999 15:08:11 +0200 (MET DST)
Message-ID: <19990402113555.F9584@uni-koblenz.de>
Date: Fri, 2 Apr 1999 11:35:55 +0200
From: ralf@uni-koblenz.de
Subject: Re: Somw questions [ MAYBE OFFTOPIC ]
References: <Pine.BSI.3.96.990401041607.28014A-100000@m-net.arbornet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSI.3.96.990401041607.28014A-100000@m-net.arbornet.org>; from Amol Mohite on Thu, Apr 01, 1999 at 04:16:51AM -0500
Sender: owner-linux-mm@kvack.org
To: Amol Mohite <amol@m-net.arbornet.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 01, 1999 at 04:16:51AM -0500, Amol Mohite wrote:

> 1) How does the processor notify the OS of a pagefault ? or a null pointer
> exception ?
> Now null pointer exception I know, is done using the expand down
> attribute in descriptor. However, when the processor gp faults, how does
> it know it is a null pointer exception ?

A NULL pointer is just yet another invalid address.  There is no special
test for a NULL pointer.  Most probably for example (char *)0x12345678 will
be invalid as a pointer as well and treated the same.  The CPU detects this
when the TLB doesn't have a translation valid for the access being attempted.

> Where does it store the program counter ?

On the stack.

> 2) How are the following exceptions handled ;
> 	TLB Refill
> 	TLB Invalid
> 	TLB Modify ?

Not all architectures do provide these exceptions at all.  MIPS for
example does:

 - TLB Refill will just reload the entry from the page table into the TLB.
 - TLB Invalid checks if reading is allowed, then marks the entry in the
   page tables and TLB accessed.  If the access is not allowed the
   do_page_fault() is being called to do whatever is necessary.
 - TLB Invalid checks if writing is allowed, then marks the entry in the
   page tables and TLB accessed/dirty.  If the access is not allowed the
   do_page_fault() is being called to do whatever is necessary.

Some architectures like m68k or Intel do most of this in hardware.

> 3) How does the processor differentiate between entries (PTE) in the TLB
> belonging to different processes ? Is it a bit in this ?

Again that's architecture specific.  The simplemost way to deal with this
problem is to just flush the entire TLB on context switch.  More advanced
TLB architectures additionally can tag each TLB entry with an Address Space
ID (ASID) or Process ID (PID).  A search in the TLB only hits if the current
process has the same ASID/PID as the searched TLB entry.  Using this
architectural feature the number of TLB flushes can be greatly reduced.

> 4) Why is the vm_area_structs maintained as a circular list, AVL tree and
> as a doubly linked list ?
> Why an AVL tree ? Any specific reason ?

Certain applications like debugging with Electric Fence result in a large
number of exceptions that is searches in the vm_area_structs.  Not using
efficient data structures results in a dramatic slowdown of these.  It
makes little difference for the average case.

The list structures are also available since for certain cases the kernel
has to iterate through all the VMAs.

> 5) What is the difference between SIGSEGV and a SIGBUS ? 

SIGSEGV is being sent for accesses to memory using bad addresses, that is
for example where nothing has been mapped.  SIGBUS is for cases like
using an address outside of the allowable address range, that is for
example kernel addresses, when the hardware signals trouble with a physical
address, there is no more physical memory available to handle a fault or
similar.

> 6) How does the processor signal memory access inan illegal way (i.e.
> trying write access to memory when this is not allowed )

See above.

> 7) How does linux handle malloc function ?

Not at all.  Malloc(3) is part of libc.  It's implemented using brk(2)
and mmap(2) of /dev/zero.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
