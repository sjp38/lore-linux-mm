Date: Tue, 25 Apr 2006 01:30:44 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page host virtual assist patches.
Message-Id: <20060425013044.19888b02.akpm@osdl.org>
In-Reply-To: <1145952628.5282.8.camel@localhost>
References: <20060424123412.GA15817@skybase>
	<20060424180138.52e54e5c.akpm@osdl.org>
	<1145952628.5282.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
> On Mon, 2006-04-24 at 18:01 -0700, Andrew Morton wrote:
> > Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> > >
> > >  The basic idea of host virtual assist (hva) is to give a host system
> > >  which virtualizes the memory of its guest systems on a per page basis
> > >  usage information for the guest pages. The host can then use this
> > >  information to optimize the management of guest pages, in particular
> > >  the paging. This optimizations can be used for unused (free) guest
> > >  pages, for clean page cache pages, and for clean swap cache pages.
> > 
> > This is pretty significant stuff.  It sounds like something which needs to
> > be worked through with other possible users - UML, Xen, vware, etc.
> > 
> > How come the reclaim has to be done in the host?  I'd have thought that a
> > much simpler approach would be to perform a host->guest upcall saying
> > either "try to free up this many pages" or "free this page" or "free this
> > vector of pages"?
> 
> Because calling into the guest is too slow.

So speed it up ;)

> You need to schedule a cpu,
> the code that does the allocation needs to run, which might need other
> pages, etc. The beauty of the scheme is that the host can immediately
> remove a page that is mark as volatile or unused. No i/o, no scheduling,
> nothing. Consider what that does to the latency of the hosts memory
> allocation. Even if the percentage of discardable pages is small, lets
> say 25% of the guests memory, the host will quickly find reusable
> memory. If the vmscan of the host attempts to evict 100 pages, on
> average it will start i/o for 75 of them, the other 25 are immediately
> free for reuse.

Batching can do wonders.  What's the expected/typical memory footprint of a
guest versus the machine's total physical memory?

And what's the typical total size of a guest?

Because a 100-page chunk sounds an awfully small work unit for a guest, let
alone for the host.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
