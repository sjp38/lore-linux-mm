Received: from [192.168.1.50] (CPE-65-30-168-158.wi.rr.com [65.30.168.158])
	by ms-smtp-02.rdc-kc.rr.com (8.12.10/8.12.7) with ESMTP id i8NNMF9W001455
	for <linux-mm@kvack.org>; Thu, 23 Sep 2004 18:22:15 -0500 (CDT)
Message-ID: <41535AAE.6090700@yahoo.com>
Date: Thu, 23 Sep 2004 18:22:22 -0500
From: John Fusco <fusco_john@yahoo.com>
MIME-Version: 1.0
Subject: Problem with remap_page_range on IA32 with more than 4GB RAM
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a problem and I would like some comments on how to fix it.

I have a custom PCI-X device installed in an IA32 system.  The device 
expects to see a flat contiguous address space on the host, from which 
it reads and sends its data.  The technique I used is right out of the 
O'Reilly Device Drivers book, which is to hide memory from the kernel 
with the 'mem=YYY' boot parameter.  I then provide a mmap method to map 
the contiguous (hidden) memory into user space via a call to 
'remap_page_range'.

Everything worked great until we decided that we needed to install 6GB 
in this system.  The problem is that remap_page_range() uses an unsigned 
long as the parameter for a physical address.  On IA32, an unsigned long 
is 32-bits, but the IA32 is capable of addressing well over 4GB of RAM.  
So physical addresses on IA32 must be larger than 32 bits.

I chose to work around this by patching the kernel.  I changed the 
unsigned long parameters used for physical address in mm/memory.c to 
'dma64_addr_t'.  This seems to work and I don't see any holes in the 
approach, but I would appreciate any comments (or better solutions).

I can post the patch here if anyone would like to see it.  It seems that 
Linux could use a unique typedef for a physical address.  Right now I 
think dma64_addr_t fits the bill.

Thanks,
John
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
