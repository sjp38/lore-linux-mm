Date: Mon, 8 Jul 2002 15:14:23 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
In-Reply-To: <9820000.1026149363@flay>
Message-ID: <Pine.LNX.4.44.0207081503530.4650-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 8 Jul 2002, Martin J. Bligh wrote:
>
> OK, here's the data from Keith that I was promising on kmap. This was just
> for a kernel compile. So copy_strings and file_read_actor seem to be the
> main users (for this workload) by an order of magnitude.

Ok, both the top two (by far) users are basically just "copy_to_user()"
and "copy_from_user()".

What we could do is to make a special case for the copy_xx_user() stuff,
and have page faulting fixing those two special cases up (kunmap before
calling handle_mm_fault, and then re-kmap and fixing up the address just
before returning).

It's even easy to check hat to trigger at: if we have a magic "atomic kmap
that handles page faults correctly" thing, such a thing would need to be
preempt safe due to the atomic kmap anyway - so we could trigger the
special case on the faulting code being non-preemptable.

Basically, the only thing it would require would be a slightly magic
"calling convention", where some register holds the page pointer, and
another register holds the "mapped address" pointer, and then we'd have
something like

	do_page_fault(..)
	{
		....

	+	if (current->preempt_count)
	+		kunmap_atomic(ptregs->page_reg);

		switch (handle_mm_fault(mm, vma, address, write)) {
		....
		}

	+	if (current->preempt_count)
	+		ptregs->addr_reg = (ptregs->addr_reg & ~PAGE_MASK) | kmap_atomic(ptregs->page_reg);

		...

which basically allows us to hold "atomic" kmap's over a page fault (and
_only_ over a page fault, it wouldn't help for anything but the user copy
case).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
