Date: Fri, 20 Oct 2000 10:18:11 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: oopses in test10-pre4 (was Re: [RFC] atomic pte updates and pae
 changes, take 3)
In-Reply-To: <Pine.LNX.4.21.0010200046480.22300-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.10.10010201012330.1354-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Fri, 20 Oct 2000, Ben LaHaise wrote:
> 
> The primary reason I added the BUG was that if this is valid, it means
> that the pte has to be removed from the page tables first with
> pte_get_and_clear since it can be modified by the other CPU.  Although
> this may be safe for shm, I think it's very ugly and inconsistent.  I'd
> rather make the code transfer the dirty bit to the page struct so that we
> *know* there is no information loss.

Note that we should have done this regardless of the BUG() tests: remember
the PAE case, and the fact that it was illegal to do

	set_pte(page_table, swp_entry_to_pte(entry));

without having atomically cleared the pte first.

So regardless of any dirty/writable issues, that ptep_get_and_clear()
should be above the test for the PageSwapCache. Thanks for the patch.

Now, I agree 100% with you that we should _also_ make sure that we
transfer the dirty bit from the page tables to "struct page". Even if we
don't actually use that information right now. We _could_ use it: in
particular we could probably fairly easily speed up shared memory handling
by using the same kind of optimization that we do for private mappings -
using the dirty bit in the page table to determine whether we need to
write the page out again or not.

This all needs more thought, I suspect. But for now moving the
ptep_get_and_clear() up, and removing the BUG() is sufficient to get us
where we used to be.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
