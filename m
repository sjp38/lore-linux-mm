Date: Tue, 21 Mar 2000 11:34:48 +0000
From: "Stephen C. Tweedie" <sct@scot.redhat.com>
Subject: Re: Extensions to mincore
Message-ID: <20000321113448.A6991@dukat.scot.redhat.com>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch> <m1puso1ydn.fsf@flinx.hidden>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1puso1ydn.fsf@flinx.hidden>; from ebiederm+eric@ccr.net on Tue, Mar 21, 2000 at 03:11:16AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Jamie Lokier <jamie.lokier@cern.ch>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Mar 21, 2000 at 03:11:16AM -0600, Eric W. Biederman wrote:
> Jamie Lokier <jamie.lokier@cern.ch> writes:
> 
> > > > [Aside: is there the possibility to have mincore return the "!accessed"
> > > > and "!dirty" bits of each page, perhaps as bits 1 and 2 of the returned
> > > > bytes?  I can imagine a bunch of garbage collection algorithms that
> > > > could make good use of those bits.  Currently some GC systems mprotect()
> > > > regions and unprotect them on SEGV -- simply reading the !dirty status
> > > > would obviously be much simpler and faster.]
> 
> Dirty kernel wise means the page needs to be swapped out. Clean kernel
> wise mean the page is in the swap cache, and hasn't been written
> since it was swapped in.

Worse than that, returning dirty status bits in mincore() just wouldn't 
work for threads.  mincore() is a valid optimisation when you just treat
it as a hint: if a page gets swapped out between calling mincore() and 
using the page, nothing breaks, you just get an extra page fault.  

The same is not true for the sort of garbage collection or distributed
memory mechanisms which use mprotect().  If you find that a page is clean
via mincore() and discard the data based on that, there is nothing to 
stop another thread from dirtying the data after the mincore() and losing
its modification.  mprotect() has the advantage of holding page table
locks so it can do an atomic read-modify-write on the page table entries.
Without that locking, you just can't reliably use dirty/accessed
information.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
