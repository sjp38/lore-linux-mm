Subject: Re: How CPU(x86) resolve kernel address
References: <Pine.GSO.4.10.10204051648440.18364-100000@mailhub.cdac.ernet.in>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 07 Apr 2002 15:00:45 -0600
In-Reply-To: <Pine.GSO.4.10.10204051648440.18364-100000@mailhub.cdac.ernet.in>
Message-ID: <m1u1qnmdfm.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sanket Rathi <sanket.rathi@cdac.ernet.in> writes:

> I read all about the memory management in linux. all thing are clear to me
> like there is 3GB space for user procee and 1GB for kernel and thats why
> kernel address always greater then 0xC0000000. But one thing is not clear
> that is for kernel address there is no page table, actually there is no
> need because this is one to one mapping to physical memory but who resolve
> kernel address to actual physical address how CPU(X86) perform this task
> because when we do DMA we have to give actual physical address by
> virt_to_phys() so what is the mechanism by which CPU translate kernel
> address into physical address ( Somewhere i heard that CPU ignore some of
> the upper bits of address if so then how much bits and why).

Ouch virt_to_phys ouch! ouch! ouch!  Don't do that.

At the very least use virt_to_bus.  And almost certainly use
pci_alloc_consistent.  On x86 the devices and the cpu happen to see
the same addresses for memory.  On other architecture this just
doesn't work.

read:
Documentation/DMA-mapping.txt
Documentation/IO-mapping.txt

As for the page tables yes the kernel uses them.  But because it has
a simple mapping from virtual to physical address it can do a lot of
optimizations that don't normally work.  Like using 4MB pages.

Note that in the vmalloc region we use normal sized pages, and that
vmalloc actually has a smaller address space than normal kernel
memory, and there is a minor performance hit for using it, as the
normal optimization do not apply.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
