Date: Mon, 15 Jan 2001 22:44:17 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: swapout selection change in pre1
Message-ID: <20010115224417.A19042@pcep-jamie.cern.ch>
References: <20010115194000.C18795@pcep-jamie.cern.ch> <Pine.LNX.4.10.10101151047540.6247-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10101151047540.6247-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Jan 15, 2001 at 10:55:28AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> Ehh.. Try to actually _implement_ reverse mapping, and THEN say that.
> 
> Reverse mapping is basically not simple at all. For each page table entry,
> you need a
> 
> 	struct reverse_map {
> 		/* actual pte pointer is implied by location,
> 		   if you implement this cleverly, but still
> 		   needed, of course */
> 		struct reverse_map *prev, *next;
> 		struct vm_struct *vma;
> 	};

No, that's the point, you _don't_ need a structure per page table entry.

We have the page cache, and VMAs naturally divide the space into regions
where you can scan the list of VMAs per page in the page cache.

Anonymous pages, including private modified pages, require a bit of
structure on top of VMAs but not much.  Dave Miller basically got the
idea and provided the code.  You yourself alluded to this a few years
back.  Dave's code has a few difficulties but they are fixable.  I've
already explained how.

> thing to be efficient (and yes, you _do_ need the VMA, it's needed for
> TLB invalidation when you remove the page table entry: you can't just
> silently remove it).
> 
> This basically means that your page tables just grew by a factor of 4
> (from one word to 1+3 words).

Read my lips (*): the page tables are not mirrored.  The reverse mapping
is implicit, not explicit.  It takes virtually no space, and is still fast.

(*) By copying the Linus expression, I am expecting to be roasted now :)

> In addition to that, your reverse mapping thing is going to suck raw eggs:
> yes, it's easy to remove a mapping (assuming you have the above kind of
> thing), but you won't actually see the "accessed" bit until you get to
> this point, so you won't really be able to do aging until _after_ you have
> done all the work - at which point you may find that you didn't want to
> remove it after all.

Of course you can scan the physical pages directly.  For each physical
page, look at the "accessed" bit of all ptes pointing to that page.  If
any are set, the page is considered accessed.

I'm not saying it's a good idea to scan physical pages directly, but you
can certainly do it and you will get page aging.

> Finally, your cache footprint is going to suck. The advantage of scanning
> the page tables is that it's a nice cache-friendly linear search. The
> reverse mapping is going to be quite horrible - not only are the data
> structures now four times larger, but they are jumping all over the
> place.

These two reasons are why vmscanning is still very good.

Physical scanning and vmscanning are really quite similar.  The
statistics may come out a little in favour of physical scanning, simply
because after finding an available page it's really available _right
now_.  Whereas with vmscanning you've got to free a page at different
times in different VMs, and hope for the coincidence that the page count
reaches zero before any of the VMs faults it back.

(If you're really desparate, you can even free a very active physical
page, and there is the possibility of moving unlocked pages, in order to
defragment).

> Trust me: I encourage everybody to try reverse mappings, but the only
> reason people _think_ they are a good idea is that they didn't implement
> them. It's damn easy to say "oh, if we only could do X, this problem would
> go away", without understanding that "X" itself is a major pain in the
> ass.

I agree.  It would be a good to implement the bulky (but easy) style of
reverse mapping just to see if Rik et al. can get better paging
behaviour out of it.  If they can't, we abandon the experiment.  If they
can, then we can think about an implicit representation that doesn't use
any memory but would require bigger changes.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
