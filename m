Date: Mon, 6 Oct 2003 19:44:41 +0100
From: Matthew Wilcox <willy@debian.org>
Subject: Re: TLB flush optimization on s/390.
Message-ID: <20031006184441.GC24824@parcelfarce.linux.theplanet.co.uk>
References: <20031006180456.GA14206@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031006180456.GA14206@mschwid3.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: akpm@osdl.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 06, 2003 at 08:04:56PM +0200, Martin Schwidefsky wrote:
>  * ptep_establish: Establish a new mapping. This sets a pte entry to a
>    page table and flushes the tlb of the old entry on all cpus if it
>    exists. This is more or less what establish_pte in mm/memory.c does
>    right now but without the update_mmu_cache call.
> 
>  * ptep_test_and_clear_and_flush_young. Do what ptep_test_and_clear_young
>    does and flush the tlb.
> 
>  * ptep_test_and_clear_and_flush_dirty. Do what ptep_test_and_clear_dirty
>    does and flush the tlb.
> 
>  * ptep_get_and_clear_and_flush: Do what ptep_get_and_clear does and
>    flush the tlb.

could we at least do away with one of the "and"s?

ptep_test_clear_and_flush_young()
ptep_test_clear_and_flush_dirty()
ptep_get_clear_and_flush()

I'm also not quite sure why we need the "get" at all.. ptep_clear()
and ptep_clear_and_flush() would seem sufficient.  Mind you, I've never
been sure why it needed to be ptep_test_and_clear_young() either.
ptep_clear_young() (and hence ptep_clear_young_flush) seems quite a
sufficient name.

Indeed, ptep_test_and_clear_and_flush_young implies that you flush the
young bit rather than being a combination of ptep_test_and_clear_young()
and flush tlb.  So how about:

ptep_clear_young_flush()
ptep_clear_dirty_flush()
ptep_clear_flush()

and commit to renaming the other ptep functions in 2.7?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
