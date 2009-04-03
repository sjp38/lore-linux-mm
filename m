Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A33E6B0047
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:48:33 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.14.3/8.13.8) with ESMTP id n338nGK8229462
	for <linux-mm@kvack.org>; Fri, 3 Apr 2009 08:49:16 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n338nGdQ4063462
	for <linux-mm@kvack.org>; Fri, 3 Apr 2009 10:49:16 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n338nFfF019985
	for <linux-mm@kvack.org>; Fri, 3 Apr 2009 10:49:16 +0200
Date: Fri, 3 Apr 2009 10:49:13 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Message-ID: <20090403104913.29c62082@skybase>
In-Reply-To: <49D5215D.6050503@goop.org>
References: <20090327150905.819861420@de.ibm.com>
	<200903281705.29798.rusty@rustcorp.com.au>
	<20090329162336.7c0700e9@skybase>
	<200904022232.02185.nickpiggin@yahoo.com.au>
	<20090402175249.3c4a6d59@skybase>
	<49D50CB7.2050705@redhat.com>
	<49D518E9.1090001@goop.org>
	<49D51CA9.6090601@redhat.com>
	<49D5215D.6050503@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Rik van Riel <riel@redhat.com>, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, frankeh@watson.ibm.com, virtualization@lists.osdl.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, hugh@veritas.com, Xen-devel <xen-devel@lists.xensource.com>
List-ID: <linux-mm.kvack.org>

On Thu, 02 Apr 2009 13:34:37 -0700
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Rik van Riel wrote:
> > Jeremy Fitzhardinge wrote:
> >> The more complex host policy decisions of how to balance overall 
> >> memory use system-wide are much in the same for both mechanisms.
> > Not at all.  Page hinting is just an optimization to host swapping, where
> > IO can be avoided on many of the pages that hit the end of the LRU.
> >
> > No decisions have to be made at all about balancing memory use
> > between guests, it just happens through regular host LRU aging.
> 
> When the host pages out a page belonging to guest A, then its making a 
> policy decision on how large guest A should be compared to B.  If the 
> policy is a global LRU on all guest pages, then that's still a policy on 
> guest sizes: the target size is a function of its working set, assuming 
> that the working set is well modelled by LRU.  I imagine that if the 
> guest and host are both managing their pages with an LRU-like algorithm 
> you'll get some nasty interactions, which page hinting tries to alleviate.

This is the basic idea of guest page hinting. Let the host memory
manager make it decision based on the data it has. That includes page
age determined with a global LRU list, page age determined with a
per-guest LRU list, i/o rates of the guests, all kind of policy which
guest should have how much memory. The page hinting comes into play
AFTER the decision has been made which page to evict. Only then the host
should look at the volatile vs. stable page state and decide what has
to be done with the page. If it is volatile the host can throw the page
away because the guest can recreate it with LESS effort. That is the
optimization.

> > Automatic ballooning requires that something on the host figures
> > out how much memory each guest needs and sizes the guests
> > appropriately.  All the proposed policies for that which I have
> > seen have some nasty corner cases or are simply very limited
> > in scope.
> 
> Well, you could apply something equivalent to a global LRU: ask for more 
> pages from guests who have the most unused pages.  (I'm not saying that 
> its necessarily a useful policy.)

But with page hinting you don't have to even ask. Just take the pages
if you need them. The guest already told you that you can have them by
setting the unused state.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
