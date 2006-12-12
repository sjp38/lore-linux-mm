Message-ID: <20061212193434.23333.qmail@web38109.mail.mud.yahoo.com>
Date: Tue, 12 Dec 2006 11:34:34 -0800 (PST)
From: Mike DeKoker <mdekoker@yahoo.com>
Subject: Bad page state in process
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Greetings and salutations.

I develop and maintain device drivers for various (DAQ and DSP) PCI-based
cards that my company manufactures. I've run into a problem with later 2.6
kernels that has me confused.

With later kernel versions (I'm using 2.6.18) I've got a problem where the
kernel is vomiting a bunch of "Bad page state in process "events/1"
KERN_EMERG messages shortly after I've unmapped a DMA buffer. The buffer
is allocated from memory unused by the kernel (via the mem= kernel parameter
and Alessandro Rubini's allocator module). Here's the abbreviated buffer
allocation/release code:

// "Allocate" DMA buffer from unused RAM
physAddr = allocator_allocate_dma(len_bytes, GFP_KERNEL);
// Map buffer into kernel space
bufp = ioremap(physAddr, len_bytes);
// This buffer is then mapped into user-space via mmap.
// my_mmap::
remap_pfn_range (,,physAddr >> PAGE_SHIFT,);

// Use buffer. Do DMA transfers, play with data, etc. All is well with this.
// Time to clean up...

// Unmap buffer from kernel space
iounmap(bufp);
// "Free" DMA buffer
allocator_free_dma(phsyAddr)
// User space process unmaps via munmap

The above works fine on 2.4 kernels as well as earlier (at least 2.6.9) 2.6
kernels running on i386 and x86_64 platforms.

I've traced the root of the problem to the free_pages_check function in
mm/page_alloc.c. The first thing this function does is verify the integrity
of the page's state. If the page's PG_reserved bit is set then it's
considered a bad page and the bad_page routine is called which in turn spits
out a bunch of these:

kernel: Bad page state in process 'events/1'
kernel: page:ffff810003646400 flags:0x4000000000000404 
        mapping:0000000000000000 mapcount:0 count:0
kernel: Trying to fix it up, but a reboot is needed
kernel: Backtrace:
kernel: 
kernel: Call Trace:
kernel:  [<ffffffff8020ace7>] dump_stack+0xe/0x10
kernel:  [<ffffffff8024db96>] bad_page+0x4e/0x78
kernel:  [<ffffffff8024ded1>] __free_pages_ok+0x96/0x12e
kernel:  [<ffffffff80264bb7>] kmem_freepages+0xcf/0xf7
kernel:  [<ffff8100aef80000>]
kernel: DWARF2 unwinder stuck at 0xffff8100aef80000
kernel: Leftover inexact backtrace:
kernel:  [<ffffffff80264df6>] slab_destroy+0x7b/0xa2
kernel:  [<ffffffff80265175>] drain_freelist+0x7b/0x91
kernel:  [<ffffffff80266735>] cache_reap+0xd5/0x12a
kernel:  [<ffffffff80238d47>] run_workqueue+0x9a/0xe1
kernel:  [<ffffffff80238d8e>] worker_thread+0x0/0x137
kernel:  [<ffffffff80238e93>] worker_thread+0x105/0x137
kernel:  [<ffffffff80224cf8>] default_wake_function+0x0/0xe
kernel:  [<ffffffff80224cf8>] default_wake_function+0x0/0xe
kernel:  [<ffffffff8023bacf>] kthread+0xc8/0xf1
kernel:  [<ffffffff8020a4a0>] child_rip+0xa/0x12
kernel:  [<ffffffff8023ba07>] kthread+0x0/0xf1
kernel:  [<ffffffff8020a496>] child_rip+0x0/0x12

The thing is, after this page sanity check, the OS code then handles the
reserved page as it should thereafter. I can continue after the error dump,
the system doesn't hang or anything, but these messages are a little
unnerving for our end users. :) 

Am I doing something incorrectly in the driver code? Or is it a bad
assumption that the kernel is making in marking the pages as bad? It seems
that the PG_reserved bit was added to the free_pages_check somewhere between
kernel versions 2.6.10 and 2.6.18. Why?

Thank you for your time.

Mike DeKoker
Signatec, Inc.






--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/







 
____________________________________________________________________________________
Cheap talk?
Check out Yahoo! Messenger's low PC-to-Phone call rates.
http://voice.yahoo.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
