Message-ID: <386153A8.C8366F70@starnet.gov.sg>
Date: Thu, 23 Dec 1999 06:41:44 +0800
From: Tan Pong Heng <pongheng@starnet.gov.sg>
MIME-Version: 1.0
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
References: <Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
		<Pine.LNX.3.96.991221200955.16115B-100000@kanga.kvack.org> <14433.20097.10335.102803@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Andrea Arcangeli <andrea@suse.de>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> Hi,
>
> On Tue, 21 Dec 1999 20:21:05 -0500 (EST), "Benjamin C.R. LaHaise"
> <blah@kvack.org> said:
>
> > The buffer dirty lists are the wrong place to be dealing with this.  We
> > need a lightweight, fast way of monitoring the system's dirty buffer/page
> > thresholds -- one that can be called for every write to a page or on the
> > write faults for cow pages.
>
> Precisely.  The only thing that the core VM needs to export is an atomic
> counter for such pages, a wait queue so that processes can wait for
> pages to be cleaned, and a function to be called to try to reclaim such
> pages.
>
> Remember, though, that we have three different types of page we need to
> deal with.  There are simple used pages, which we need to reclaim in a
> component-independent manner when we are using too much memory; then
> there are dirty pages which can be flushed to disk at any time; then
> there are reserved pages which cannot be flushed to disk without some
> extra work.
>
> The first case is simple: we already have the wait queues and reclaim
> functions in place, and all we need is an address_space callback to
> allow filesystem-specific caches to return pages when shrink_mmap()
> wants them.
>
> In the second case (dirty pages), bdflush already does some of the work,
> but we need a more generic solution of we want to support dirty data
> which is not stored in buffer_heads in a portable manner.
>
> The third case (reserved pages) is the case which doesn't affect any
> current code but which will become really important for journaled or
> deferred-allocation filesystems.
>
> --Stephen

Sorry for intruding, I have been monitoring this thread with interest.

I was thinking that, unless you want to have FS specific buffer/page cache,
there is alway a gain for a unified cache for all fs. I think the one piece
of functionality missing from the 2.3 implementation is the dependency
between the various pages. If you could specify a tree relations between
the various subset of the buffer/page and the reclaim machanism honor
that everything should be fine. For FS that does not care about ordering,
they could simply ignore this capability and the machanism could assume
that everything is in one big set and could be reclaimed in any order.

I have note been giving the complexity of implementing such functionality
a thought yet. But it seem to be feasible - since you would need to do that
any way for your FS....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
