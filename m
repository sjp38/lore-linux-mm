Date: Mon, 8 Jan 2001 09:43:28 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101081101430.5599-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101080938270.3750-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 8 Jan 2001, Marcelo Tosatti wrote:
> 
> On Sun, 7 Jan 2001, Linus Torvalds wrote:
> 
> > and just get rid of all the logic to try to "find the best mm". It's bogus
> > anyway: we should get perfectly fair access patterns by just doing
> > everything in round-robin, and each "swap_out_mm(mm)" would just try to
> > walk some fixed percentage of the RSS size (say, something like
> > 
> > 	count = (mm->rss >> 4)
> > 
> > and be done with it.
> 
> I have the impression that a fixed percentage of the RSS will be a problem
> when you have a memory hog (or hogs) running.

Nothing but testing can prove it, but I don't think that's really an
issue.

Remember: we're not actually swapping stuff out any more in VM scanning.
We're just saying "we're low on memory, let's evict the page tables so
that we _could_ swap stuff out if necessary". We're going to have to evict
_something_, and walking the page tables really gives us a lot better
knowledge of WHAT to evict.

The cost of scanning the VM is (a) the cost of scanning itself and (b) the
cost of soft-faults and CPU TLB invalidate cross-calls for the scanning.
Both of which might be noticeable - but I have this fairly strong feeling
that neither of them is big enough to offset the cost of paging out the
wrong page. Which we definitely do now - I've got some simple
test-programs that have a VM footprint that is not _that_ much more than
the available memory, and they _really_ show problems.

(The "lots of dirty pages" case is not the common case under most loads,
so the fact that 2.4.0 has some performance problems with it was not a
show-stopper for me - during my testing with low memory most loads were
very nice indeed).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
