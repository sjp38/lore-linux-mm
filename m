Date: Wed, 4 Apr 2001 13:15:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pte_young/pte_mkold/pte_mkyoung
In-Reply-To: <200104041600.RAA01119@raistlin.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.21.0104041311360.14090-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rmk@arm.linux.org.uk
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2001 rmk@arm.linux.org.uk wrote:

> We currently seem to have:
> 	2 references to pte_mkyoung()
> 	1 reference to pte_mkold()
> 	0 references to pte_young()
> 
> This tells me that we're no longer using the hardware page tables on x86
> for page aging, which leads me nicely on to the following question.

But we are using them, take a look at mm/vmscan.c::try_to_swap_out().

        /* Don't look at this pte if it's been accessed recently. */
        if (ptep_test_and_clear_young(page_table)) {
		....

> Are there currently any plans to use the hardware page aging bits in
> the future, and if there are, would architectures that don't have them
> be required to have them?

No, the hardware bits won't be used. This is because these bits
are per page table entry and we do page aging per physical page
(think shared memory).

> I'm asking this question because for some time (1.3 onwards), the ARM
> architecture has had some code to handle software emulation of the
> young and dirty bits.  If its not required, then I'd like to get rid
> of this software emulation.

They're not strictly required, but removing them will lead to
bad paging performance.

Alternatively, you could just run ARM with a fixed inactive_target
of 1/4th of physical memory, which means that all mapped pages will
be recycled in a pretty random order and the ones which are accessed
a lot can be "salvaged" from the inactive list. However, I doubt this
would be any cheaper than just doing the accessed bit emulation...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
