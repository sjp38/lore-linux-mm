Date: Mon, 14 May 2001 11:41:41 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kernel position
Message-ID: <20010514114141.O7594@redhat.com>
References: <20010514092219.55514.qmail@web13202.mail.yahoo.com> <Pine.PTX.3.96.1010514150742.26385A-100000@wipro.wipsys.sequent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.PTX.3.96.1010514150742.26385A-100000@wipro.wipsys.sequent.com>; from kunaal.mahanti@wipro.com on Mon, May 14, 2001 at 03:19:54PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kunaal Mahanti <kunaal.mahanti@wipro.com>
Cc: Any Anderson <any_and@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, May 14, 2001 at 03:19:54PM +0530, Kunaal Mahanti wrote:

> > I wann know where in the physical memory is kernel
> > loaded by the loader (such as lilo) and does this
> > position has any significance in mm system. If that
> 
> The kernel is loaded loaded beyond 0x1000000 (1MB)

Not necessarily.  A zImage kernel is loaded by lilo at 0x10000; only
bzImage is loaded at 0x100000.  The setup part of the kernel is loaded
at 0x90000 in either case.

*After* lilo has done its loading, the kernel setup code may
relocate the kernel image if necessary to its final desired address
in physical memory.

Also look at linux/arch/i386/boot/setup.S, which is the kernel setup
header where the relocation of the kernel image is performed; and
linux/arch/i386/kernel/head.S which is the starting point of the
relocated image, where we finally make the switch to protected mode.

> this is a h/w
> constraint as most DMA devices cannot address beyond that

Not true --- even ISA DMA can access up to 16MB of physical memory,
and all modern PCI or AGP devices can access up to 4GB of physical
memory (except for a few buggy devices which don't wire the high
address lines correctly and which are limited to 2GB or 1GB).  With
PCI64 or PCI DAC (Dual Address Cycle), the full 64GB of physical
memory on an Intel PAE box can be addressed over PCI.

> > location is to be changed which files should be
> > changed. Lets assume we are talking for x86 platform.
> > Thanks in advance for your time.
> 
> I think all we need is to use -Ttext flag while loading the kernel to
> modify the load address.

Be careful: the text address used for the bulk of the kernel is
designed to have an origin in virtual memory (usually 0xc0000000),
which has nothing to do with the physical location of the kernel.  

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
