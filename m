Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B6DD95F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 03:21:01 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n367LGfW004912
	for <linux-mm@kvack.org>; Mon, 6 Apr 2009 07:21:16 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n367LFGB4370548
	for <linux-mm@kvack.org>; Mon, 6 Apr 2009 09:21:15 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n367LFl5007507
	for <linux-mm@kvack.org>; Mon, 6 Apr 2009 09:21:15 +0200
Date: Mon, 6 Apr 2009 09:21:11 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Message-ID: <20090406092111.3b432edd@skybase>
In-Reply-To: <49D6532C.6010804@goop.org>
References: <20090327150905.819861420@de.ibm.com>
	<200903281705.29798.rusty@rustcorp.com.au>
	<20090329162336.7c0700e9@skybase>
	<200904022232.02185.nickpiggin@yahoo.com.au>
	<20090402175249.3c4a6d59@skybase>
	<49D50CB7.2050705@redhat.com>
	<49D518E9.1090001@goop.org>
	<49D51CA9.6090601@redhat.com>
	<49D5215D.6050503@goop.org>
	<20090403104913.29c62082@skybase>
	<49D6532C.6010804@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Rik van Riel <riel@redhat.com>, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, frankeh@watson.ibm.com, virtualization@lists.osdl.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, hugh@veritas.com, Xen-devel <xen-devel@lists.xensource.com>
List-ID: <linux-mm.kvack.org>

On Fri, 03 Apr 2009 11:19:24 -0700
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Martin Schwidefsky wrote:
> > This is the basic idea of guest page hinting. Let the host memory
> > manager make it decision based on the data it has. That includes page
> > age determined with a global LRU list, page age determined with a
> > per-guest LRU list, i/o rates of the guests, all kind of policy which
> > guest should have how much memory.
> 
> Do you look at fault rates?  Refault rates?

That is hidden in the memory management of z/VM. I know some details
how the z/VM page manager works but in the end I don't care as the
guest operating system.

> >  The page hinting comes into play
> > AFTER the decision has been made which page to evict. Only then the host
> > should look at the volatile vs. stable page state and decide what has
> > to be done with the page. If it is volatile the host can throw the page
> > away because the guest can recreate it with LESS effort. That is the
> > optimization.
> >   
> 
> Yes, and its good from that perspective.   Do you really implement it 
> purely that way, or do you bias the LRU to push volatile and free pages 
> down the end of the LRU list in preference to pages which must be 
> preserved?  If you have a small bias then you can prefer to evict easily 
> evictable pages compared to their near-equivalents which require IO.

We though about a bias to prefer volatile pages but in the end decided
against it. We do prefer free pages, if the page manager finds a unused
page it will reuse it immediately.

> > But with page hinting you don't have to even ask. Just take the pages
> > if you need them. The guest already told you that you can have them by
> > setting the unused state.
> >   
> 
> Yes.  But it still depends on the guest.  A very helpful guest could 
> deliberately preswap pages so that it can mark them as volatile, whereas 
> a less helpful one may keep them persistent and defer preswapping them 
> until there's a good reason to do so.  Host swapping and page hinting 
> won't put any apparent memory pressure on the guest, so it has no reason 
> to start preswapping even if the overall system is under pressure.  
> Ballooning will expose each guest to its share of the overall system 
> memory pressure, so they can respond appropriately (one hopes).

Why should the guest want to do preswapping? It is as expensive for
the host to swap a page and get it back as it is for the guest (= one
write + one read). It is a waste of cpu time to call into the guest. You
need something we call PFAULT though: if a guest process hits a page
that is missing in the host page table you don't want to stop the
virtual cpu until the page is back. You notify the guest that the host
page is missing. The process that caused the fault is put to sleep
until the host retrieved the page again. You will find the pfault code
for s390 in arch/s390/mm/fault.c

So to me preswap doesn't make sense. The only thing you can gain by
putting memory pressure on the guest is to free some of the memory that
is used by the kernel for dentries, inodes, etc. 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
