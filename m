Date: Fri, 10 Mar 2000 16:36:12 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <Pine.LNX.4.10.10003101304430.2499-100000@penguin.transmeta.com>
Message-ID: <Pine.BSO.4.10.10003101619410.26118-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: James Manning <jmm@computer.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Mar 2000, Linus Torvalds wrote:
> I don't like exporting the silly user-land "advice" into the
> vma->vm_flags. I like "flags" as flags, and I'd be happy to have bit
> positions saying
> 
> 	if (vma->vm_flags & VM_SEQUENTIAL) {
> 		.. pre-fetch aggressively ..
> 	}

i implemented the vm flags stuff a while ago, just as you asked.  i'm not
sure my e-mail is actually getting delivered to you: i've sent the mincore
and madvise patches several times since then.

> and then the madvise() system call would do somehting like
> 
> 	switch (advice) {
> 	MADV_SEQUENTIAL:
> 		/* This is really more of a "mprotect" thing */
> 		mprotect(start, end, VM_SEQUENTIAL);
> 		break;
> 	MADV_DONTNEED:
> 		/* While this is really a case of msync() */
> 		msync(start, end, MSYNC_THROWAWAY);
> 		break;
> 	...
> 
> instead of just trying to force the madvise() system call into the VM
> structure, where I don't think it makes all that much sense.

i don't understand what you mean here.  you don't think that madvise might
have different behavior depending on what kind of vma is the target?  shm
vma's will have a different implementation than mapped file vma's.  some
types will want to implement the functionality of each MADV_ very
differently or not at all.

re-using the mprotect code for sequential, random, and normal behavior is
much preferred to what the patch does today.

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
