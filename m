Date: Thu, 19 Oct 2000 08:31:57 -0400 (EDT)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: Re: Page allocation (get_free_pages)
In-Reply-To: <001b01c0393f$bc79ddc0$c958fc3e@brain>
Message-ID: <Pine.BSF.4.10.10010190826390.2771-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "p.hamshere" <p.hamshere@ntlworld.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> I'm wondering why get_free_pages allocates contiguous pages for non-DMA transfers and why the kernel identity (ish) maps the whole (up to 1GB) of physical memory to its address space...
> Surely only DMA requires physically contiguous memory, and everything else (such as kernel stack) could be allocated via a 'vmalloc' like function. If this could be done cleverly, contiguous blocks could be held for DMA and the rest would be allocated from the random free pages left throughout the system. 
> Also, the kernel only *needs* to identity map its code and data, and all other free pages can be mapped anywhere at will - surely?
> Given the large blocks may be more 'permanent' than single page allocation / deallocation (on the assumption they are needed to be present for DMA), then also the allocation could be slower and perhaps work on a best-fit algorithm. This then might remove the 'power of two' alignment dependency in the get_free_page allocation.

The lower 1GB is mapped into the kernel address space for convenience--
unlike *BSD, Linux has access to kernel memory without mapping it
below 1GB all the time, and only needs to create temporary
mappings for accessing high memory.  I'm not sure about non x86
differences since I am just beginning to play with those ports now.

> I know I'm missing something (extra overhead of remapping physical memory in the kernel page tables, lack of identity mapping and the fact the kernel assumes this, tracking of physical memory, my Intel-centric view of the world misses the MIPS architecture  -something)...but what is it?
> Reading some books on page allocation it seems that some oses do not allocate contiguous page ever, including NT by the looks of it - do they just fudge the DMA into smaller chunks - anyone know?
> Paul

Creating mappings and destroying them is inefficient, mostly because
of TLB flushes (which are _very_ expensive on 4+way CPU boxen).
You'll find that the highmem code for Intel boxes use an LRU set
of mappings to avoid TLB flushes unless absolutely necessary --
it waits until a map absolutely must be flushed to avoid corruption
before doing it.  If the rest of memory were not mapped and
contiguous, this inefficiency would be propagated to code beyond
the highmem case.  If you really WANT virtual memory, you CAN
get it with vmalloc().  However as noted >95% of all normal kernel
allocations are for < PAGE_SIZE anyway.

--
Eric Lowe
Software Engineer, Systran Corporation
elowe@systran.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
