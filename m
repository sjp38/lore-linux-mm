Message-ID: <4527C46F.5050505@garzik.org>
Date: Sat, 07 Oct 2006 11:14:55 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
References: <20061007105758.14024.70048.sendpatchset@linux.site> <20061007105853.14024.95383.sendpatchset@linux.site>
In-Reply-To: <20061007105853.14024.95383.sendpatchset@linux.site>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Nonlinear mappings are (AFAIKS) simply a virtual memory concept that
> encodes the virtual address -> file offset differently from linear
> mappings.
> 
> I can't see why the filesystem/pagecache code should need to know anything
> about it, except for the fact that the ->nopage handler didn't quite pass
> down enough information (ie. pgoff). But it is more logical to pass pgoff
> rather than have the ->nopage function calculate it itself anyway. And
> having the nopage handler install the pte itself is sort of nasty.
> 
> This patch introduces a new fault handler that replaces ->nopage and ->populate
> and (hopefully) ->page_mkwrite. Most of the old mechanism is still in place
> so there is a lot of duplication and nice cleanups that can be removed if
> everyone switches over.
> 
> The rationale for doing this in the first place is that nonlinear mappings
> are subject to the pagefault vs invalidate/truncate race too, and it seemed
> stupid to duplicate the synchronisation logic rather than just consolidate
> the two.
> 
> Comments?

That's pretty nice.

Back when I was writing [the now slated for death] 
sound/oss/via82xxx_audio.c driver, Linus suggested that I implement 
->nopage() for accessing the mmap'able DMA'd audio buffers, rather than 
using remap_pfn_range().  It worked out very nicely, because it allowed 
the sound driver to retrieve $N pages for the mmap'able buffer (passed 
as an s/g list to the hardware) rather than requiring a single humongous 
buffer returned by pci_alloc_consistent().

And although probably not your primary motivation, your change does IMO 
improve this area of the kernel.

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
