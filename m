Date: Thu, 23 Sep 2004 16:27:27 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Problem with remap_page_range on IA32 with more than 4GB RAM
Message-ID: <20040923232727.GK9106@holomorphy.com>
References: <41535AAE.6090700@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41535AAE.6090700@yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fusco <fusco_john@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 23, 2004 at 06:22:22PM -0500, John Fusco wrote:
> I have a problem and I would like some comments on how to fix it.
> I have a custom PCI-X device installed in an IA32 system.  The device 
> expects to see a flat contiguous address space on the host, from which 
> it reads and sends its data.  The technique I used is right out of the 
> O'Reilly Device Drivers book, which is to hide memory from the kernel 
> with the 'mem=YYY' boot parameter.  I then provide a mmap method to map 
> the contiguous (hidden) memory into user space via a call to 
> 'remap_page_range'.
> Everything worked great until we decided that we needed to install 6GB 
> in this system.  The problem is that remap_page_range() uses an unsigned 
> long as the parameter for a physical address.  On IA32, an unsigned long 
> is 32-bits, but the IA32 is capable of addressing well over 4GB of RAM.  
> So physical addresses on IA32 must be larger than 32 bits.
> I chose to work around this by patching the kernel.  I changed the 
> unsigned long parameters used for physical address in mm/memory.c to 
> 'dma64_addr_t'.  This seems to work and I don't see any holes in the 
> approach, but I would appreciate any comments (or better solutions).
> I can post the patch here if anyone would like to see it.  It seems that 
> Linux could use a unique typedef for a physical address.  Right now I 
> think dma64_addr_t fits the bill.

I wrote a patch that made it take a pfn at some point. I suppose I
could respin that while renaming the function to remap_pfn_range() or
otherwise fiddle with whatever whoever complained about.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
