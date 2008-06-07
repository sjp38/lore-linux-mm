Message-ID: <484AC779.1070803@goop.org>
Date: Sat, 07 Jun 2008 18:38:01 +0100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [rfc][patch] mm: vmap rewrite
References: <20080605102015.GA11366@wotan.suse.de>
In-Reply-To: <20080605102015.GA11366@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi. RFC.
>
> Rewrite the vmap allocator to use rbtrees and lazy tlb flushing, and provide a
> fast, scalable percpu frontend for small vmaps.
>
> XEN and PAT and such do not like deferred TLB flushing. They just need to call
> vm_unmap_aliases() in order to flush any deferred mappings.  That call is very
> expensive (well, actually not a lot more expensive than a single vunmap under
> the old scheme), however it should be OK if not called too often.
>   

What are the performance characteristics?  Can it be fast-pathed if 
there are no outstanding aliases?

For Xen, I'd need to do the alias unmap each time it allocates a page 
for use in a pagetable.  For initial process construction that could be 
deferred, but creating mappings on a live process could get fairly 
expensive as a result.  The ideal interface for me would be a way of 
testing if a given page has vmap aliases, so that we need only do the 
unmap if really necessary.  I'm guessing that goes into "need a new page 
flag" territory though...

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
