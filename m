Date: Mon, 15 Jan 2001 10:55:28 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: swapout selection change in pre1
In-Reply-To: <20010115194000.C18795@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.10.10101151047540.6247-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 15 Jan 2001, Jamie Lokier wrote:
> 
> Btw, reverse page mapping resolves this and makes it very simple: no
> vmscanning (*), so no hand waving heuristic.

Ehh.. Try to actually _implement_ reverse mapping, and THEN say that.

Reverse mapping is basically not simple at all. For each page table entry,
you need a

	struct reverse_map {
		/* actual pte pointer is implied by location,
		   if you implement this cleverly, but still
		   needed, of course */
		struct reverse_map *prev, *next;
		struct vm_struct *vma;
	};

thing to be efficient (and yes, you _do_ need the VMA, it's needed for
TLB invalidation when you remove the page table entry: you can't just
silently remove it).

This basically means that your page tables just grew by a factor of 4
(from one word to 1+3 words).

In addition to that, your reverse mapping thing is going to suck raw eggs:
yes, it's easy to remove a mapping (assuming you have the above kind of
thing), but you won't actually see the "accessed" bit until you get to
this point, so you won't really be able to do aging until _after_ you have
done all the work - at which point you may find that you didn't want to
remove it after all.

Finally, your cache footprint is going to suck. The advantage of scanning
the page tables is that it's a nice cache-friendly linear search. The
reverse mapping is going to be quite horrible - not only are the data
structures now four times larger, but they are jumping all over the place.

Trust me: I encourage everybody to try reverse mappings, but the only
reason people _think_ they are a good idea is that they didn't implement
them. It's damn easy to say "oh, if we only could do X, this problem would
go away", without understanding that "X" itself is a major pain in the
ass.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
