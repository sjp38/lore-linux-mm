Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD756B009D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:08:03 -0400 (EDT)
Date: Tue, 2 Jun 2009 16:07:59 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602140759.GB26982@wotan.suse.de>
References: <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org> <20090602123720.GF1392@wotan.suse.de> <20090602133019.GC20462@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602133019.GC20462@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 09:30:19PM +0800, Wu Fengguang wrote:
> > No I mean the difference between the case of dirty page unable to
> > be written to backing sotre, and the case of dirty page becoming
> > corrupted.
> 
> legacy EIO:   may success on (do something then) retry?

Legacy EIO yes, I imagine most programs are assuming that the
cache is still the most recent (and valid) copy of the data.


> hwpoison EIO: a permanent unrecoverable error
>
> > They would presumably exit or do some default thing, which I
> > think would be fine. Actually if your code catches them in the
> > act of manipulating a corrupted page (ie. if it is mmapped),
> > then it gets a SIGBUS.
> 
> That's OK.  filemap_fault() returns VM_FAULT_SIGBUS for legacy EIO,
> while hwpoison pages will return VM_FAULT_HWPOISON. Both kills the
> application I guess?

Yes I was just using it to illustrate the difference. filemap_fault
does SIGBUS for read failures, sure, but if you msync and get an
EIO (legacy EIO), then it is not going to SIGBUS to all procs mapping
the page.

 
> read()/write() are the more interesting cases.

Yes.

 
> With read IO interception, the read() call will succeed.
> 
> The write() call have to be failed. But interestingly writes are
> mostly delayed ones, and we have only one AS_EIO bit for the entire
> file, which will be cleared after the EIO reporting. And the poisoned
> page will be isolated (if succeed) and later read()/write() calls
> won't even notice there was a poisoned page!
> 
> How are we going to fix this mess? EIO errors seem to be fuzzy and
> temporary by nature at least in the current implementation, and hard

Well that is a problem too. It is questionable how long to keep
legacy EIO reporting around (I'm of the opinion that we really
need to keep them around forever and wait for either truncate or
add a new syscall to discard them). But this is another discussion
because we already have these existing semantics, so little point
to quickly change them :) 


> to be improved to be exact and/or permanent in both implementation and
> interface:
> - can/shall we remember the exact EIO page? maybe not.

If you add a new bit in the mapping, you could then call to the
error recovery code to do slowpath checking for overlapping page
offsets. It gets tricky if you want to allow the inode to be
reclaimed and still remember the errors ;)

> - can EIO reporting be permanent? sounds like a horrible user interface..

[Let's describe the ideal world:
 We'd have EBADMEM that everyone knows about, and we have a syscall
 that can clear these errors/bad pages. Maybe even another syscall
 which can read back the contents of this memory without being SIGBUSed
 or EBADMEMed.]

Now I have been of the the opinion that our current (legacy) EIO should
be permanent (unless the pages end up being able to be written back),
and we should have another syscall to clear this condition.

Unaware applications may have some difficulties, but a cmd line utility
can clear these so it could easily be recovered...

I think this might work for hwpoison as well (whether it ends up using
EIO or something else).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
