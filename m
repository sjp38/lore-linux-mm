Date: Fri, 4 Aug 2000 10:49:24 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <200008041541.IAA88364@apollo.backplane.com>
Message-ID: <Pine.LNX.4.10.10008041033230.813-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Chris Wedgwood <cw@f00f.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 4 Aug 2000, Matthew Dillon wrote:
> 
>   							  The second eyesore
>     is the lack of physically shared page table segments for 'standard'
>     processes.  At the moment, it's an all (rfork/RFMEM/clone) or nothing
>     (fork) deal.  Physical segment sharing outside of clone is something
>     Linux could use to, I don't think it does it either.  It's not easy to
>     do right.

It's probably impossible to do right. Basically, if you do it, you do it
wrong.

As far as I can tell, you basically screw yourself on the TLB and locking
if you ever try to implement this. And frankly I don't see how you could
avoid getting screwed.

There are architecture-specific special cases, of course. On ia64, the
page table is not really one page table, it's a number of pretty much
independent page tables, and it would be possible to extend the notion of
fork vs clone to be a per-page-table thing (ie the single-bit thing would
become a multi-bit thing, and the single "struct mm_struct" would become
an array of independent mm's).

You could do similar tricks on x86 by virtually splitting up the page
directory into independent (fixed-size) pieces - this is similar to what
the PAE stuff does in hardware, after all. So you could have (for example)
each process be quartered up into four address spaces with the top two
address bits being the address space sub-ID.

Quite frankly, it tends to be a nightmare to do that. It's also
unportable: it works on architectures that either support it natively
(like the ia64 that has the split page tables because of how it covers
large VM areas) or by "faking" the split on regular page tables. But it
does _not_ work very well at all on CPU's where the native page table is
actually a hash (old sparc, ppc, and the "other mode" in IA64). Unless the
hash happens to have some of the high bits map into a VM ID (which is
common, but not really something you can depend on).

And even when it "works" by emulation, you can't share the TLB contents
anyway. Again, it can be possible on a per-architecture basis (if the
different regions can have different ASI's - ia64 again does this, and I
think it originally comes from the 64-bit PA-RISC VM stuff). But it's one
of those bad ideas that if people start depending on it, it simply won't
work that well on some architectures. And one of the beauties of UNIX is
that it truly is fairly architecture-neutral.

And that's just the page table handling. The SMP locking for all this
looks even worse - you can't share a per-mm lock like with the clone()
thing, so you have to create some other locking mechanism. 

I'd be interested to hear if you have some great idea (ie "oh, if you look
at it _this_ way all your concerns go away"), but I suspect you have only
looked at it from 10,000 feet and thought "that would be a cool thing".
And I suspect it ends up being anything _but_ cool once actually
implemented.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
