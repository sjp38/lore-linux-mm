Date: Fri, 10 Mar 2000 13:46:49 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <Pine.BSO.4.10.10003101619410.26118-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.10.10003101340130.11037-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: James Manning <jmm@computer.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 10 Mar 2000, Chuck Lever wrote:
> 
> i don't understand what you mean here.  you don't think that madvise might
> have different behavior depending on what kind of vma is the target?

That's not what I meant, but no, I don't think it should have different
behaviour depending on the vma anyway.

What I meant is really that the different "advices" are totally different.
MADV_DONTNEED is an operation that probably walks the page tables and just
throws the pages out (or just marks them old and uniniteresting).
Similarly MADV_WILLNEED implies more of a "start doing something now" kind
of thing. Neither would be flags in vma->vm_flags, because neither of them
are really all that much of a "save this state for future behaviour" kind
of thing.

In contrast, MADV_RANDOM is a flag that you'd set in vma->vm_flags, and
would tell the page-in logic to not pre-fetch, because it doesn't pay off.
And MADV_SEQUENTIAL would probably tell the page-in logic to pre-fetch
very aggressively. 

> re-using the mprotect code for sequential, random, and normal behavior is
> much preferred to what the patch does today.

The mprotect() routines that walk the page tables makes sense for
MADV_DONTNEED and MADV_WILLNEED. It makes no sense at all for MADV_RANDOM
and MADV_SEQUENTIAL, other than the actual vma _splitting_ part (as
opposed to the actual page table walking part).

See? I don't think the different advices are really comparable. It's
different cases.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
