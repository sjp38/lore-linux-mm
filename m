Date: Tue, 25 May 2004 23:20:40 -0700
From: Keith M Wesolowski <wesolows@foobazco.org>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <20040526062040.GA12302@foobazco.org>
References: <20040525114437.GC29154@parcelfarce.linux.theplanet.co.uk> <Pine.LNX.4.58.0405250726000.9951@ppc970.osdl.org> <20040525153501.GA19465@foobazco.org> <Pine.LNX.4.58.0405250841280.9951@ppc970.osdl.org> <20040525102547.35207879.davem@redhat.com> <Pine.LNX.4.58.0405251034040.9951@ppc970.osdl.org> <20040525105442.2ebdc355.davem@redhat.com> <Pine.LNX.4.58.0405251056520.9951@ppc970.osdl.org> <20040525133543.753fc5a5.davem@redhat.com> <Pine.LNX.4.58.0405251340160.9951@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405251340160.9951@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: "David S. Miller" <davem@redhat.com>, willy@debian.org, andrea@suse.de, benh@kernel.crashing.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, bcrl@kvack.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2004 at 01:49:57PM -0700, Linus Torvalds wrote:

> Ok. Still, that doesn't sound too bad. I assume that the pte write has to 
> be atomic anyway (ie it doesn't walk the page tables, but it clearly _has_ 
> to do an atomic "read-modify-update" or just the _hardware_ updates might 
> race against each other and one CPU loses the dirty bit when another CPU 
> writes back the accessed bit).

Correct, we don't have to worry about that.  The various chips either
(a) lock the bus during the entire tablewalk, or (b) set the accessed
bit atomically and use a normal write when setting both bits.

> So I really think it should be safe to just do a regular write when you 
> update both bits, because you know that no other CPU will at least _clear_ 
> any bits. Hmm?

Yes, and this is how our hardware at least works.

> So it sounds like the SWAP loop basically ends up being just something 
> like
> 
> 	val = pte_value(entry);
> 	for (;;) {
> 		oldval = SWAP(ptep, val);
> 		/*
> 		 * If we wrote a value that had the same or more bits set 
> 		 * than the old value, we're ok...
> 		 */
> 		if (!(oldval & ~val))
> 			break;
> 		/*
> 		 * ..otherwise we need to write the "or" of all bits and
> 		 * try again.
> 		 */
> 		val |= oldval;
> 	}
> 
> Right? Note that the reason we can do the "dirty and accessed bit both 
> set" case with a simple write is exactly because that's already the 
> "maximal" bits anybody can write to the thing, so we don't need to loop, 
> we can just write it directly.

The documentation actually provides a more general implementation for
any kind of pte update.  In this case it would logically reduce to
your outline above.  The actual outline in the manual is:

	val = pte_val(entry);
	for(;;) {
		/* Set the pte to 0 to discourage others */
		oldval = 0;
		SWAP(ptep, oldval);
		/* Flush this entry from all MMUs */
		flush_tlb_entry(ptep);
		/* Gather the existing bits */
		val |= oldval;
		/* Did another MMU monkey with it since? */
		if (!*ptep)
			break;
	}
	set_pte(ptep, entry);

which seems far more complicated than necessary just to set these 1 or
2 bits.

-- 
Keith M Wesolowski
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
