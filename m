Date: Fri, 10 Mar 2000 13:13:42 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <20000310152650.A14388@nina.pagesz.net>
Message-ID: <Pine.LNX.4.10.10003101304430.2499-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Manning <jmm@computer.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 10 Mar 2000, James Manning wrote:
> 
> I'm certainly sure there's all kinds of other areas where mincore() and
> madvise() are very helpful.

I agree especially for madvice, but I haven't liked the patches that I've
seen so far.

I don't like exporting the silly user-land "advice" into the
vma->vm_flags. I like "flags" as flags, and I'd be happy to have bit
positions saying

	if (vma->vm_flags & VM_SEQUENTIAL) {
		.. pre-fetch aggressively ..
	}


and then the madvise() system call would do somehting like

	switch (advice) {
	MADV_SEQUENTIAL:
		/* This is really more of a "mprotect" thing */
		mprotect(start, end, VM_SEQUENTIAL);
		break;
	MADV_DONTNEED:
		/* While this is really a case of msync() */
		msync(start, end, MSYNC_THROWAWAY);
		break;
	...

instead of just trying to force the madvise() system call into the VM
structure, where I don't think it makes all that much sense.

MADV_DONTNEED really is NOT a vma flag at all. It really is what Linux
tends to call MS_INVALIDATE for msync() (which is probably wrong, I don't
know how anybody else does this).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
