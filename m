Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3PAhBDi068318
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 10:43:11 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3PAiGKp123744
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 12:44:16 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3PAhB8C008503
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 12:43:11 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20060425013044.19888b02.akpm@osdl.org>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org> <1145952628.5282.8.camel@localhost>
	 <20060425013044.19888b02.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 12:43:15 +0200
Message-Id: <1145961796.5282.44.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-25 at 01:30 -0700, Andrew Morton wrote:
> > > This is pretty significant stuff.  It sounds like something which needs to
> > > be worked through with other possible users - UML, Xen, vware, etc.
> > > 
> > > How come the reclaim has to be done in the host?  I'd have thought that a
> > > much simpler approach would be to perform a host->guest upcall saying
> > > either "try to free up this many pages" or "free this page" or "free this
> > > vector of pages"?
> > 
> > Because calling into the guest is too slow.
> 
> So speed it up ;)

We did.. the other way round by adding the ESSA :-)

> > You need to schedule a cpu,
> > the code that does the allocation needs to run, which might need other
> > pages, etc. The beauty of the scheme is that the host can immediately
> > remove a page that is mark as volatile or unused. No i/o, no scheduling,
> > nothing. Consider what that does to the latency of the hosts memory
> > allocation. Even if the percentage of discardable pages is small, lets
> > say 25% of the guests memory, the host will quickly find reusable
> > memory. If the vmscan of the host attempts to evict 100 pages, on
> > average it will start i/o for 75 of them, the other 25 are immediately
> > free for reuse.
> 
> Batching can do wonders.  What's the expected/typical memory footprint of a
> guest versus the machine's total physical memory?

Yes, batching will speed up the calls for one particular guest. Trouble
is that we are not talking about freeing 1000 pages from 1 guest. We
have the problem to free 1 page from 1000 guests.

> And what's the typical total size of a guest?
> 
> Because a 100-page chunk sounds an awfully small work unit for a guest, let
> alone for the host.

The typical memory size of the guests depends on the workload it runs. A
typical memory size would be something like 256MB. The real catch is the
amount of memory overcommitment. And 100 pages sound about right if you
have 1000 guests.

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
