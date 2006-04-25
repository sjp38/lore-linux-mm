Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3P8ANFe094268
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 08:10:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3P8BSKp115590
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 10:11:28 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3P8ANkC020772
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 10:10:23 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20060424180138.52e54e5c.akpm@osdl.org>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 10:10:27 +0200
Message-Id: <1145952628.5282.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Mon, 2006-04-24 at 18:01 -0700, Andrew Morton wrote:
> Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> >
> >  The basic idea of host virtual assist (hva) is to give a host system
> >  which virtualizes the memory of its guest systems on a per page basis
> >  usage information for the guest pages. The host can then use this
> >  information to optimize the management of guest pages, in particular
> >  the paging. This optimizations can be used for unused (free) guest
> >  pages, for clean page cache pages, and for clean swap cache pages.
> 
> This is pretty significant stuff.  It sounds like something which needs to
> be worked through with other possible users - UML, Xen, vware, etc.
> 
> How come the reclaim has to be done in the host?  I'd have thought that a
> much simpler approach would be to perform a host->guest upcall saying
> either "try to free up this many pages" or "free this page" or "free this
> vector of pages"?

Because calling into the guest is too slow. You need to schedule a cpu,
the code that does the allocation needs to run, which might need other
pages, etc. The beauty of the scheme is that the host can immediately
remove a page that is mark as volatile or unused. No i/o, no scheduling,
nothing. Consider what that does to the latency of the hosts memory
allocation. Even if the percentage of discardable pages is small, lets
say 25% of the guests memory, the host will quickly find reusable
memory. If the vmscan of the host attempts to evict 100 pages, on
average it will start i/o for 75 of them, the other 25 are immediately
free for reuse.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
