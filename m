Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3PAaNFa126294
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 10:36:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3PAbSKp118684
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 12:37:28 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3PAaMYT001729
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 12:36:22 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <444DDD1B.4010202@yahoo.com.au>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org> <1145952628.5282.8.camel@localhost>
	  <444DDD1B.4010202@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 12:36:26 +0200
Message-Id: <1145961386.5282.37.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-25 at 18:26 +1000, Nick Piggin wrote:
> > Because calling into the guest is too slow. You need to schedule a cpu,
> > the code that does the allocation needs to run, which might need other
> > pages, etc. The beauty of the scheme is that the host can immediately
> > remove a page that is mark as volatile or unused. No i/o, no scheduling,
> > nothing. Consider what that does to the latency of the hosts memory
> > allocation. Even if the percentage of discardable pages is small, lets
> > say 25% of the guests memory, the host will quickly find reusable
> > memory. If the vmscan of the host attempts to evict 100 pages, on
> > average it will start i/o for 75 of them, the other 25 are immediately
> > free for reuse.
> > 
> 
> I don't think there is any beauty in this scheme, to be honest.

Beauty lies in the eye of the beholder. From my point of view there is
benefit to the method.

> I don't see why calling into the host is bad - won't it be able to
> make better reclaim decisions? If starting IO is the wrong thing to
> do under a hypervisor, why is it the right thing to do on bare metal?

First some assumptions about the environment. We are talking about a
paging hypervisor that runs several hundreds of guest Linux images. The
memory is overcommited, the sum of the guest memory sizes is larger than
the host memory by a factor of 2-3. Usually a large percentage of the
guests memory is paged out by the hypervisor.

Both the host and the guest follow an LRU strategy. That means that the
host will pick the oldest page from the idlest guest. Almost the same
would happen if you call into the idlest guest to let the guest free its
oldest page. But the catch is that the guest will touch a lot of page
doing its vmscan operation, if that causes a single additional host i/o
because a guest page needs to be retrieved from the host swap device,
you are already in negative territory.

> As for latency of host's memory allocation, it should attempt to
> keep some buffer of memory free.

It does attempt to keep some memory free. But lets say 1000 guest images
generate a lot of memory pressure. You will run out of memory, and
anything that speeds up the host reclaim will improve the situation. And
the method allows to reduce the number of i/o that the host needs to do.
Consider an old, volatile page that is picked for eviction. Without hva
the host will write it to the paging device. If the guest touches the
page again the host has to read it back to memory again. Two host i/o's.
If the host discards the page, the guest will get a discard fault when
it tries to reaccess the page. The guest will read the page from its
backing device. One guest i/o. Seems like a good deal to me..

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
