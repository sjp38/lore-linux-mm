Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 09F776B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:53:40 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id b13so3454365wgh.0
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:53:40 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id y5si1480558wij.107.2014.10.22.04.53.39
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 04:53:39 -0700 (PDT)
Date: Wed, 22 Oct 2014 14:53:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH 3/6] mm: VMA sequence count
Message-ID: <20141022115304.GA31486@node.dhcp.inet.fi>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.361741939@infradead.org>
 <20141022112657.GG30588@node.dhcp.inet.fi>
 <20141022113951.GB21513@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022113951.GB21513@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 22, 2014 at 01:39:51PM +0200, Peter Zijlstra wrote:
> On Wed, Oct 22, 2014 at 02:26:57PM +0300, Kirill A. Shutemov wrote:
> > On Mon, Oct 20, 2014 at 11:56:36PM +0200, Peter Zijlstra wrote:
> > > Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
> > > counts such that we can easily test if a VMA is changed.
> > > 
> > > The unmap_page_range() one allows us to make assumptions about
> > > page-tables; when we find the seqcount hasn't changed we can assume
> > > page-tables are still valid.
> > > 
> > > The flip side is that we cannot distinguish between a vma_adjust() and
> > > the unmap_page_range() -- where with the former we could have
> > > re-checked the vma bounds against the address.
> > 
> > You only took care about changing size of VMA or unmap. What about other
> > aspects of VMA. How would you care about race with mprotect(2)?
> > 
> > 		CPU0						CPU1
> >  mprotect()
> >    mprotect_fixup()
> >      vma_merge()
> >        [ maybe update vm_sequence ]
> >     						[ page fault kicks in ]
> > 						  do_anonymous_page()
> > 						    entry = mk_pte(page, fe->vma->vm_page_prot);
> >      vma_set_page_prot(vma)
> >        [ update vma->vm_page_prot ]
> >      change_protection()
> > 						    pte_map_lock()
> > 						      [ vm_sequence is ok ]
> > 						    set_pte_at(entry) // With old vm_page_prot!!!
> > 
> 
> This won't happen, this is be serialized by the PTL and the fault
> validates that the PTE is the 'same' it started out with after acquiring
> the PTL.

Em, no. In this case change_protection() will not touch the pte, since
it's pte_none() and the pte_same() check will pass just fine.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
