Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA01592
	for <linux-mm@kvack.org>; Mon, 8 Feb 1999 13:48:44 -0500
Date: Mon, 8 Feb 1999 10:48:06 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Re: swapcache bug?
In-Reply-To: <199902081751.RAA03584@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990208104249.606M-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: masp0008@stud.uni-sb.de, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 8 Feb 1999, Stephen C. Tweedie wrote:
> 
> It does appear to be: we enforce it pretty much everywhere I can see,
> with one possible exception: filemap_nopage(), which assumes
> area->vm_offset is already page-aligned.  I think we can still violate
> that internally if we are mapping a ZMAGIC binary (urgh), but the VM
> breaks anyway if we do that: update_vm_cache cannot deal with such
> pages, for a start.

This was done on purpose: it still works as a mapping, but it isn't
coherent with regards to writes to the file. That's fine, as writing to an
executable while it has been mapped is a losing proposition anyway, and
you can't get access through these non-page-aligned mappings any other way
(the "mmap()" system calls etc will all enforce page-aligned regions,
because coherency just wouldn't be possible otherwise). 

> The assumption that we might have flexible offsets will break
> __find_page massively anyway, because we _always_ lookup the struct page
> by exact match on the offset; __find_page never tries to align things
> itself.

Good point.

> Linus, I know Matti Aarnio has been working on supporting >32bit offsets
> on Intel, and for that we really do need to start using the low bits in
> the page offset for something more useful than MBZ padding. 

Yes. The page offset will become a "sector offset" (I'd actually like to
make it a page number, but then I'd have to break ZMAGIC dynamic loading
due to the fractional page offsets, so it's not worth it for three extra
bits), and that gives you 41 bits of addressing even on a 32-bit machine.
Which is plenty - considering that by the time you need more than that
you'd _really_ better be running on a larger machine anyway. 

Note that some patches I saw (I think by Matti) made "page->offset" a long
long, and that is never going to happen. That's just a stupid waste of
time and memory.

>						 If there is
> a long-term desire to keep those bits in the offset insignificant then
> that will really hurt his work; otherwise, I can't see mixing in the
> low-order bits to the page hash breaking anything new.

Ok, you convinced me. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
