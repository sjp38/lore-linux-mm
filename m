Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0N9EeJ8035132
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 09:14:40 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0N9Eewk958678
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 10:14:40 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0N9EdqH025744
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 10:14:40 +0100
Subject: Re: [patch] #ifdef very expensive debug check in page fault path
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <Pine.LNX.4.64.0801222226350.28823@blonde.site>
References: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com>
	 <20080116234540.GB29823@wotan.suse.de>
	 <20080116161021.c9a52c0f.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0801182023350.5249@blonde.site>
	 <479469A4.6090607@de.ibm.com>
	 <Pine.LNX.4.64.0801222226350.28823@blonde.site>
Content-Type: text/plain
Date: Wed, 23 Jan 2008 10:14:39 +0100
Message-Id: <1201079679.7084.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: carsteno@de.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, Holger Wolf <holger.wolf@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-22 at 22:35 +0000, Hugh Dickins wrote:
> On Mon, 21 Jan 2008, Carsten Otte wrote:
> > Hugh Dickins wrote:
> > > 
> > > Well: that patch still gets my Nack, but I guess I'm too late.  If
> > > s390 pagetables are better protected than x86 ones, add an s390 ifdef?
> > 
> > The alternative would be to just make
> > #define pfn_valid(pfn) (1)
> > on s390. That would also get _us_ rid of the check while others do benefit. We
> > would trap access to mem_map beyond its limits because we don't have a kernel
> > mapping there. For us, it would not silently corrupt things but crash proper.
> 
> Whilst I quite like the sound of that, I wonder whether it's safe to
> change s390's pfn_valid (rather surprisingly) for all its users.  And
> note that nobody but me has voiced any regret at the loss of the check.
> My guess is we let it rest for now, and reconsider if a case comes up
> later which would have got caught by the check (but the problem is that
> such a case is much harder to identify than it was).

Nick has said that pfn_valid as a primitive is supposed to return
whether a pfn has a struct page behind it or not. If you follow the
principle of least surprise it is not really an option to define
pfn_valid as (1).

So far the s390 method of using the kernel address space mapping to
implement pfn_valid has been correct. The new code that allows to have
memory areas without struct page changes things. All memory has to be
added to the kernel address space to be able to do user copy. pfn_valid
returns incorrect results for struct page less memory now. We are
searching for a fast way to implement a correct pfn_valid, it should not
use lists, it should not required a lock and it should not waste vast
amounts of memory. To make things worse there is not really a limit to
the maximum address, the full 64 bit address space can be used. That
makes 2**52 pages.
The best I could come up so far is a page table like scheme that uses 3
indirection levels and a bitfield at the end. Ugly, ugly..

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
