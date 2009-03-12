Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 46BA96B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:36:44 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2C8acZp103566
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 08:36:38 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C8acNi3039392
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:36:38 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2C8acHl014297
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:36:38 +0100
Date: Thu, 12 Mar 2009 09:33:35 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] fix/improve generic page table walker
Message-ID: <20090312093335.6dd67251@skybase>
In-Reply-To: <1236792263.3205.45.camel@calx>
References: <20090311144951.58c6ab60@skybase>
	<1236792263.3205.45.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Mar 2009 12:24:23 -0500
Matt Mackall <mpm@selenic.com> wrote:

> On Wed, 2009-03-11 at 14:49 +0100, Martin Schwidefsky wrote:
> > From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > 
> > On s390 the /proc/pid/pagemap interface is currently broken. This is
> > caused by the unconditional loop over all pgd/pud entries as specified
> > by the address range passed to walk_page_range. The tricky bit here
> > is that the pgd++ in the outer loop may only be done if the page table
> > really has 4 levels. For the pud++ in the second loop the page table needs
> > to have at least 3 levels. With the dynamic page tables on s390 we can have
> > page tables with 2, 3 or 4 levels. Which means that the pgd and/or the
> > pud pointer can get out-of-bounds causing all kinds of mayhem.
> 
> Not sure why this should be a problem without delving into the S390
> code. After all, x86 has 2, 3, or 4 levels as well (at compile time) in
> a way that's transparent to the walker.

Its hard to understand without looking at the s390 details. The main
difference between x86 and s390 in that respect is that on s390 the
number of page table levels is determined at runtime on a per process
basis. A compat process uses 2 levels, a 64 bit process starts with 3
levels and can "upgrade" to 4 levels if something gets mapped above
4TB. Which means that a *pgd can point to a region-second (2**53 bytes),
a region-third (2**42 bytes) or a segment table (2**31 bytes), a *pud
can point to a region-third or a segment table. The page table
primitives know about this semantic, in particular pud_offset and
pmd_offset check the type of the page table pointed to by *pgd and *pud
and do nothing with the pointer if it is a lower level page table.
The only operation I can not "patch" is the pgd++/pud++ operation.
The current implementation requires that the address bits of the
non-existent higher order page tables in the page table walkers are
zero. This is where the vmas come into play. If there is a vma then is
it guaranteed that all the levels to cover the addresses in the vma are
allocated.

> > The proposed solution is to fast-forward over the hole between the start
> > address and the first vma and the hole between the last vma and the end
> > address. The pgd/pud/pmd/pte loops are used only for the address range
> > between the first and last vma. This guarantees that the page table
> > pointers stay in range for s390. For the other architectures this is
> > a small optimization.
> 
> I've gone to lengths to keep VMAs out of the equation, so I can't say
> I'm excited about this solution.

The minimum fix is to add the mmap_sem. If a vma is unmapped while you
walk the page tables, they can get freed. You do have a dependency on
the vma list. All the other page table walkers in mm/ start with the
vma, then do the four loops. It would be consistent if the generic page
table walker would do the same.

Having thought about the problem again, I think I found a way how to
deal with the problem in the s390 page table primitives. The fix is not
exactly nice but it will work. With it s390 will be able to walk
addresses outside of the vma address range.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
