Date: Mon, 6 Nov 2000 16:54:16 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001106165416.A27036@redhat.com>
References: <20001102134021.B1876@redhat.com> <20001103232721.D27034@athlon.random> <20001106150539.A19112@redhat.com> <20001106171204.B22626@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001106171204.B22626@athlon.random>; from andrea@suse.de on Mon, Nov 06, 2000 at 05:12:04PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Nov 06, 2000 at 05:12:04PM +0100, Andrea Arcangeli wrote:
> On Mon, Nov 06, 2000 at 03:05:39PM +0000, Stephen C. Tweedie wrote:
> > Why?
> 
> 	handle_mm_fault()
> 	pte is dirty
> 					pager write it out and make it clean
> 					since it's not pinned on the
> 					physical side yet so it's allowed
> 	grab pagetable lock
> 	follow_page()
> 	pte is writeable but not dirty
> 	pin the page on the physical side to inibith the swapper
> 	unlock the pagetable lock
> 
> 	read from disk and write to memory
> 
> 	now the pte is clean and the page won't be synced back while
> 	closing the file or during msync

No.  Even if the page were dirty before we started the IO, it could be
cleaned during the IO.  The whole problem with the interaction between
the VM and the pages concerned has been that we need to mark the
physical pages dirty at the *end* of the IO, not at the beginning ---
and that we don't necessarily have the same mapping information once
the IO has complete (another thread may have unmapped the vma
entirely).

The patches I sent to Linus dirty the page physically once the write
to memory has completed, completely independently of the ptes.  The
one piece of that missing is the handling of PageDirty() on anonymous
pages --- Rik was going to deal with that.

Checking for page dirty when we create the mapping in the first place
is neither necessary nor sufficient.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
