Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBLJTqw1450832
	for <linux-mm@kvack.org>; Fri, 21 Dec 2007 19:29:52 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBLJTq0u2896110
	for <linux-mm@kvack.org>; Fri, 21 Dec 2007 20:29:52 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBLJTqQK023308
	for <linux-mm@kvack.org>; Fri, 21 Dec 2007 20:29:52 +0100
In-Reply-To: <20071221104701.GE28484@wotan.suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com>
From: Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
Date: Fri, 21 Dec 2007 20:29:50 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote on 12/21/2007 11:47:01 AM:
> On Fri, Dec 21, 2007 at 11:35:02AM +0100, Carsten Otte wrote:
> > Nick Piggin wrote:
> > >But it doesn't still retain sparsemem sections behind that? Ie. so
that
> > >pfn_valid could be used? (I admittedly don't know enough eabout the
memory
> > >model code).
> > Not as far as I know. But arch/s390/mm/vmem.c has:
> >
> > struct memory_segment {
> >         struct list_head list;
> >         unsigned long start;
> >         unsigned long size;
> > };
> >
> > static LIST_HEAD(mem_segs);
> >
> > This is maintained every time we map a segment/unmap a segment. And we
> > could add a bit to struct memory_segment meaning "refcount this one".
> > This way, we could tell core mm whether or not a pfn should be
refcounted.
>
> Right, this should work.
>
> BTW. having a per-arch function sounds reasonable for a start. I'd just
give
> it a long name, so that people don't start using it for weird things ;)
> mixedmap_refcount_pfn() or something.

Hmm, I would prefer to have a pte bit, it seem much more natural to me.
We know that this is a special pte when it gets mapped, but we "forgot"
that fact when the pte is picked up again in vm_normal_page. To search a
list when a simple bit in the pte get the job done just feels wrong.
By the way, for s390 the lower 8 bits of the pte are OS defined. The lowest
two bits are used in addition to the hardware invalid and the hardware
read-
only bit to define the pte type. For valid ptes the remaining 6 bits are
unused. Pick one, e.g. 2**2 for the bit that says
"don't-refcount-this-pte".

blue skies,
   Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
