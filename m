Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E38616B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:59:39 -0400 (EDT)
Subject: Re: [PATCH] fix/improve generic page table walker
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090312154229.3ee463eb@skybase>
References: <20090311144951.58c6ab60@skybase>
	 <1236792263.3205.45.camel@calx> <20090312093335.6dd67251@skybase>
	 <1236867014.3213.16.camel@calx>  <20090312154229.3ee463eb@skybase>
Content-Type: text/plain
Date: Thu, 12 Mar 2009 10:58:14 -0500
Message-Id: <1236873494.3213.55.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-03-12 at 15:42 +0100, Martin Schwidefsky wrote:
> On Thu, 12 Mar 2009 09:10:14 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > [Nick and Hugh, maybe you can shed some light on this for me]
> > 
> > On Thu, 2009-03-12 at 09:33 +0100, Martin Schwidefsky wrote:
> > > On Wed, 11 Mar 2009 12:24:23 -0500
> > > Matt Mackall <mpm@selenic.com> wrote:
> > > 
> > > > On Wed, 2009-03-11 at 14:49 +0100, Martin Schwidefsky wrote:
> > > > > From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > > > > 
> > > > > On s390 the /proc/pid/pagemap interface is currently broken. This is
> > > > > caused by the unconditional loop over all pgd/pud entries as specified
> > > > > by the address range passed to walk_page_range. The tricky bit here
> > > > > is that the pgd++ in the outer loop may only be done if the page table
> > > > > really has 4 levels. For the pud++ in the second loop the page table needs
> > > > > to have at least 3 levels. With the dynamic page tables on s390 we can have
> > > > > page tables with 2, 3 or 4 levels. Which means that the pgd and/or the
> > > > > pud pointer can get out-of-bounds causing all kinds of mayhem.
> > > > 
> > > > Not sure why this should be a problem without delving into the S390
> > > > code. After all, x86 has 2, 3, or 4 levels as well (at compile time) in
> > > > a way that's transparent to the walker.
> > > 
> > > Its hard to understand without looking at the s390 details. The main
> > > difference between x86 and s390 in that respect is that on s390 the
> > > number of page table levels is determined at runtime on a per process
> > > basis. A compat process uses 2 levels, a 64 bit process starts with 3
> > > levels and can "upgrade" to 4 levels if something gets mapped above
> > > 4TB. Which means that a *pgd can point to a region-second (2**53 bytes),
> > > a region-third (2**42 bytes) or a segment table (2**31 bytes), a *pud
> > > can point to a region-third or a segment table. The page table
> > > primitives know about this semantic, in particular pud_offset and
> > > pmd_offset check the type of the page table pointed to by *pgd and *pud
> > > and do nothing with the pointer if it is a lower level page table.
> > > The only operation I can not "patch" is the pgd++/pud++ operation.
> > 
> > So in short, sometimes a pgd_t isn't really a pgd_t at all. It's another
> > object with different semantics that generic code can trip over.
> 
> Then what exactly is a pgd_t? For me it is the top level page table
> which can have very different meaning for the various architectures.

The important thing is that it's always 3 levels removed from the
bottom, whether or not those 3 levels actually have hardware
manifestations. From your description, it sounds like that's not how
things work in S390 land.

> > Can I get you to explain why this is necessary or even preferable to
> > doing it the generic way where pgd_t has a fixed software meaning
> > regardless of how many hardware levels are in play?
> 
> Well, the hardware can do up to 5 levels of page tables for the full
> 64 bit address space. With the introduction of pud's we wanted to
> extend our address space from 3 levels / 42 bits to 4 levels / 53 bits.
> But this comes at a cost: additional page table levels cost memory and
> performance. In particular for the compat processes which can only
> address a maximum of 2 GB it is a waste to allocate 4 levels. With the
> dynamic page tables we allocate as much as required by each process.

X86 uses 1-entry tables at higher levels to maintain consistency with
fairly minimal overhead. In some of the sillier addressing modes, we may
even use a 4-entry table in some places. I think table size is fixed at
compile time, but I don't think that's essential. Very little code in
the x86 architecture has any notion of how many hardware levels actually
exist.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
