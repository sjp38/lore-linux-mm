Date: Thu, 20 Jul 2000 13:06:21 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: phys-to-virt kernel mapping and ioremap()
Message-Id: <20000720182643Z131167-4584+4@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

I'm studying the code for __ioremap and I'm confused by something.

The phys_to_virt and virt_to_phys macros are very simple.  Basically, in kernel
space, the virtual address is an offset of the physical address, so it's very
simple.

__ioremap is supposed to take high PCI memory and map it to kernel space. 
However, __ioremap() calls get_vm_area() which then calls kmalloc(), which
allocates some memory from the heap.  Then remap_area_pages() is called, and
that uses the three-level page tables to map the memory allocated by kmalloc to
the PCI memory.

And that's where I'm confused.  Particularly:

1) Doesn't this mapping break the phys_to_virt and virt_to_phys macros?

2) kmalloc takes real physical memory from the kernel heap.  But then the
virtual addresses are remapped to other physical memory.  What happens to the
physical memory that kmalloc allocated?  Why isn't it freed?	


--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
