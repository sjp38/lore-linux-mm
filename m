Date: Mon, 13 Mar 2000 14:56:32 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [PATCH] mincore for i386, against 2.3.51
In-Reply-To: <Pine.LNX.4.10.10003131032290.1257-100000@penguin.transmeta.com>
Message-ID: <Pine.BSO.4.10.10003131438050.12643-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Mar 2000, Linus Torvalds wrote:
> I think that "incore" should be a generic VM function, and be based solely
> on the VMA and the associated address space. 

at one point i tried just walking the page tables, but that really didn't
give the results i wanted -- every page appeared to be "in core".

> So I'd prefer something that does not have the "incore" function at all,
> and if that convinces somebody else to change shm to use the address_space
> stuff to get a working mincore(), all the better. Ok?

hmm.  i created the "incore" method because mincore needs to synchronize
with the swapping method used for each of the different vma types.  this
is different for shm's vs. mapped files -- they both use locking methods
that are independent of one another.  any ideas about how to get around
this without using an "incore" vm_op?  do you think grabbing the mm
semaphor is enough?

i also wanted to check the page_uptodate bit for mapped files, but this
doesn't make sense for shm, for example.  i think the semantics of "page
is in memory" can be different enough for the different types of vmas that
having a separate hook for each is necessary.

btw i think i've ended up in your kill file.  direct mail i send to you
appears to be lost.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
