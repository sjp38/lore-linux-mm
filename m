Message-ID: <39AA5E0F.FB164766@augan.com>
Date: Mon, 28 Aug 2000 14:41:51 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: How does the kernel map physical to virtual addresses?
References: <20000825233718Z131190-247+15@kanga.kvack.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

> When my driver wants to map virtual to physical (and vice versa) addresses, it
> calls virt_to_phys and phys_to_virt. All these macros do is add or subtract a
> constant (PAGE_OFFSET) to one address to get the other address.
> 
> How does the kernel configure the CPU (x86) to use this mapping?  I was under
> the impression that the kernel creates a series of 4MB pages, using the x86's
> 4MB page feature.  For example, in a 64MB machine, there would be 16 PTEs (PGDs?
> PMDs?), each one mapping a consecutive 4MB block of physical memory.  Is this
> correct?  Somehow I believe that this is overly simplistic.

Do you want it overly complex? :-) As long as you don't have high memory
(usally more than 1GB) all available memory is mapped in one virtual
mapping, so virt_to_phys/phys_to_virt can simply use an offset.

> The reason I ask is that I'm confused as to what happens when a user process or
> tries to allocate memory.  I assume that the VM uses 4KB pages for this
> allocatation.  So do we end up with two virtual addresses pointing the same
> physical memory?

You shouldn't mix kernel virtual mapping and user virtual mapping and
yes, a page can be in both mappings, but the kernel can't access the
user mapping directly, it has to use copy_(to|from)_user for this.

> What happens if I use ioremap_nocache() on normal memory?  Is that memory
> cached or uncached?  If I use the pointer obtained via phys_to_virt(), the
> memory is cached.  But if I use the pointer returned from ioremap_nocache(), the
> memory is uncached.  My understanding of x86 is that caching is based on
> physical, not virtual addresses.  If so, it's not possible for a physical
> address to be both cached and uncached at the same.

The cache is accessed with physical address, that's correct (at least on
most architectures). But before the cache is accessed a virtual to
physical translation is done and cached seperatly. During this
translation you don't get only the physical address but also some
properties on how it should be accessed, like read/write attributes, but
also cachable/noncachable information. Only after the cpu got this
information, it knows where _and_ how to access the memory and that
might happen through the cache or not.
BTW you might also want to look at __vmalloc() (in 2.4), it has a
protection argument so you can easily create a vmalloc_nocache().
Afterwards you only have to look up the pages that were mapped.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
