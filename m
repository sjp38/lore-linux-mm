Date: Mon, 8 Jan 2001 18:10:28 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Subtle MM bug
Message-ID: <20010108181028.F9321@redhat.com>
References: <20010108135700.O9321@redhat.com> <Pine.LNX.4.10.10101080916180.3750-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10101080916180.3750-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Jan 08, 2001 at 09:29:15AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 08, 2001 at 09:29:15AM -0800, Linus Torvalds wrote:
> On Mon, 8 Jan 2001, Stephen C. Tweedie wrote:

> If you have a well-behaving application that doesn't even have memory
> pressure, but fills up >50% of memory in its VM, nothing will actually
> happen in the steady state. It can have 99% of available memory, and not a
> single soft page fault.

Agreed, but that's not how I read your statement about scanning the VM
regularly.  The problem happens if you are working happily with enough
free memory and you suddenly need a large amount of allocation: having
some relatively uptodate page age information may give you a _much_
better idea of what to page out.

Rik was going to experiment with this --- Rik, do you have any hard
numbers for the benefit of maintaining a background page aging task?

> But think about what happens if you now start up another application? And
> think about what SHOULD happen. The 50% ruls is perfectly fine: 

Right, I interpreted your 50% as a steady-state limit.

> Stephen: have you tried the behaviour of a working set that is dirty in
> the VM's and slightly larger than available ram? Not pretty. 

Yes, and this is something that Marcelo's swap clustering code ought
to be ideal for.

> _really_ well on many loads, but this one we do badly on. And from what
> I've been able to see so far, it's because we're just too damn good at
> waiting on page_launder() and doing refill_inactive_scan().

do_try_to_free_pages() is trying to

	/*
	 * If needed, we move pages from the active list
	 * to the inactive list. We also "eat" pages from
	 * the inode and dentry cache whenever we do this.
	 */
	if (free_shortage() || inactive_shortage()) {
		shrink_dcache_memory(6, gfp_mask);
		shrink_icache_memory(6, gfp_mask);
		ret += refill_inactive(gfp_mask, user);
	} else {

So we're refilling the inactive list regardless of its current size
whenever free_shortage() is true.  In the situation you describe,
there's no point refilling the inactive list too far beyond the
ability of the swapper to launder it, regardless of whether
free_shortage() is set.

refill_inactive contains exactly the opposite logic: it breaks out if

		/*
		 * If we either have enough free memory, or if
		 * page_launder() will be able to make enough
		 * free memory, then stop.
		 */
		if (!inactive_shortage() || !free_shortage())
			goto done;

but that still means that we're doing unnecessary inactive list
refilling whenever free_shortage() is true: this test only occurs
after we've tried at least one swap_out().  We're calling
refill_inactive if either condition is true, but we're staying inside
it only if both conditions are true.

Shouldn't we really just be making the refill_inactive() here depend
on inactive_shortage() alone, not free_shortage()?  By refilling the
inactive list too agressively we actually end up discarding aging
information which might be of use to us.

Rik, any thoughts?  This looks as if it's destroying any hope of
maintaining the intended inactive_shortage() targets.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
