Message-ID: <3AB7DF03.8D77D4EC@uow.edu.au>
Date: Tue, 20 Mar 2001 22:51:47 +0000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: 3rd version of R/W mmap_sem patch available
References: <Pine.LNX.4.21.0103201632360.1299-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andi Kleen <ak@muc.de>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Tue, 20 Mar 2001, Andi Kleen wrote:
> > On Tue, Mar 20, 2001 at 05:08:36PM +0100, Linus Torvalds wrote:
> > > > General comment: an expensive part of a pagefault
> > > > is zeroing the new page.  It'd be nice if we could
> > > > drop the page_table_lock while doing the clear_user_page()
> > > > and, if possible, copy_user_page() functions.  Very nice.
> > >
> > > I don't think it's worth it. We should have basically zero contention on
> > > this lock now, and adding complexity to try to release it sounds like a
> > > bad idea when the only way to make contention on it is (a) kswapd (only
> > > when paging stuff out) and (b) multiple threads (only when taking
> > > concurrent page faults).
> >
> > Isn't (b) a rather common case in multi threaded applications ?
> 
> Multiple threads pagefaulting on the SAME page of anonymous
> memory at the same time ?
> 
> I can imagine multiple threads pagefaulting on the same page
> of some mmaped database, but on the same page of anonymous
> memory ??

err...  If we hold mm->page_table_lock for a long time,
that's going to block all faulting threads which use this mm,
regardless of which page (or vma) they're faulting on, no?

I guess I've kind of lost the plot on why this patch exists
in the first place.  Was it simply to prevent vmstat from getting
stuck, or was it because we were seeing significant throughput
degradation for some workload?

If the latter, what workload was it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
