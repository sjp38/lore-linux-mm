Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9E72A6B0062
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 20:02:34 -0400 (EDT)
Subject: Re: [RFC/PATCH] mm: Pass virtual address to
 [__]p{te,ud,md}_free_tlb()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090720103835.GB7070@wotan.suse.de>
References: <20090715074952.A36C7DDDB2@ozlabs.org>
	 <20090715135620.GD7298@wotan.suse.de> <1247709255.27937.5.camel@pasglop>
	 <20090720081054.GH7298@wotan.suse.de> <1248084041.30899.7.camel@pasglop>
	 <20090720103835.GB7070@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 21 Jul 2009 10:02:26 +1000
Message-Id: <1248134546.30899.27.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-20 at 12:38 +0200, Nick Piggin wrote:
> On Mon, Jul 20, 2009 at 08:00:41PM +1000, Benjamin Herrenschmidt wrote:
> > On Mon, 2009-07-20 at 10:10 +0200, Nick Piggin wrote:
> > > 
> > > Maybe I don't understand your description correctly. The TLB contains
> > > PMDs, but you say the HW still logically performs another translation
> > > step using entries in the PMD pages? If I understand that correctly,
> > > then generic mm does not actually care and would logically fit better
> > > if those entries were "linux ptes". 
> > 
> > They are :-)
> > 
> > > The pte invalidation routines
> > > give the virtual address, which you could use to invalidate the TLB.
> > 
> > For PTEs, yes, but not for those PMD entries. IE. I need the virtual
> > address when destroying PMDs so that I can invalidate those "indirect"
> > pages. PTEs are already taken care of by existing mechanisms.
> 
> Hmm, so even after having invalidated all the pte translations
> then you still need to invalidate the empty indirect page? (or
> maybe you don't even invalidate the ptes if they're not cached
> in a TLB).

The PTEs are cached in the TLB (ie, they turn into normal TLB entries). 

We need to invalidate the indirect entries when the PMD value change
(ie, when the PTE page is freed) or the TLB would potentially continue
loading PTEs from a stale PTE page :-)

Hence my patch adding the virtual address to pte_free_tlb() which is the
freeing of a PTE page. I'm adding it to the pmd/pud variants too for
consistency and because I believe there's no cost.

> I believe x86 is also allowed to cache higher level page tables
> in non-cache coherent storage, and I think it just avoids this
> issue by flushing the entire TLB when potentially tearing down
> upper levels. So in theory I think your patch could allow x86 to
> use invlpg more often as well (in practice the flush-all case
> and TLB refills are so fast in comparison with invlpg that it
> probably doesn't gain much especially when talking about
> invalidating upper levels). So making the generic VM more
> flexible like that is no problem for me.

Ah that's good to know. I don't know that much about the x86 way of
doing these things :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
