Message-ID: <3A6F45F4.8020004@valinux.com>
Date: Wed, 24 Jan 2001 14:15:32 -0700
From: Jeff Hartmann <jhartmann@valinux.com>
MIME-Version: 1.0
Subject: Re: Page Attribute Table (PAT) support?
References: <20010124174824Z129401-18594+948@vger.kernel.org> <20010124203012Z129444-18594+1042@vger.kernel.org> <20010124204811Z129375-18594+1059@vger.kernel.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:

> ** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Wed, 24 Jan
> 2001 13:41:41 -0700
> 
> 
>> When you mark a page UCWC, you better 
>> have removed all cached mappings or your asking for REAL trouble.
> 
> 
> What exactly do you mean by "removed all cached mappings"?  Does that mean that
> if one virtual address is a UCWC mapping of a physical page, then ALL virtual
> addresses mapped to that page must also be UCWC?
> 
> In my driver, I use ioremap_nocache() on physical memory (real RAM) to create
> an uncached "alias" (a virtual address) to a physical page of RAM.  When I
> access the memory via this virtual address, the memory access is not cached.
> What I reall need is to be able to also have that virtual address as Write
> Combined.

	Pages with multiple mappings aren't really supported by the Intel ia32 
architecture.  The trick you do above works, but is strongly discouraged 
by the Intel documentation.  The documentation says that if you do this 
with UCWC memory, it won't work (and will result in undefined processor 
behavior.)  My experiments with the PAT seem to agree with the 
documentation.

> 
> Since all physical RAM is mapped as cached via the kernel (on a 1-to-1 basis),
> and since there can be several other virtual addresses that point to that memory
> (e.g. user virtual address), I can't see how these virtual addresses can be
> removed.

	We have to remove the kernel page table mappings.  (Convert the 4MB pages 
to individual pte's, then change the individual pte so its pgprot value 
is correct.)

	When you allocate memory in the kernel, you OWN it.  Its not mapped into 
a user space process unless you put it there.  I have to point out that 
this interface requires the user to insure these pages are never ever 
swapped, or mapped cached.  This isn't a huge restriction, since we 
aren't providing a user land interface.  If we try to handle all/some of 
these cases in the kernel, it becomes a very large problem.  We would 
have to add arch specific bits for special cache handling, Do smp cache 
flushes all over the place, etc.  Its really not worth it.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
