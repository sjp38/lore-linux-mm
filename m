Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5153D6B005A
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 10:54:25 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9SEkO37026717
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 10:46:24 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9SEsIJt075854
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 10:54:19 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9SEtnWr004299
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 08:55:49 -0600
Subject: Re: RFC: Transparent Hugepage support
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20091028141803.GQ7744@basil.fritz.box>
References: <20091026185130.GC4868@random.random>
	 <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random>
	 <20091028042805.GJ7744@basil.fritz.box>
	 <20091028120050.GD9640@random.random>
	 <20091028141803.GQ7744@basil.fritz.box>
Content-Type: text/plain
Date: Wed, 28 Oct 2009 09:54:16 -0500
Message-Id: <1256741656.5613.15.camel@aglitke>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-10-28 at 15:18 +0100, Andi Kleen wrote:
> > My worry are the archs like powerpc where a hugepage doesn't fit in a
> > pmd_trans_huge. I think x86 will fit the pmd/pud_trans_huge approach
> > in my patch even of 1G pages in the long run, so there is no actual
> > long term limitation with regard to x86. The fact is that the generic
> > pagetable code is tuned for x86 so no problem there.
> > 
> > What I am unsure about and worries me more are those archs that don't
> > use a pmd to map hugepages and to create hugetlb. I am unsure if those
> > archs will be able to take advantage of my patch with minor changes to
> > it given it is wired to pmd_trans_huge availability.
> 
> I see. Some archs (like IA64 or POWER?) require special VA address
>  ranges for huge pages, for those doing it fully transparent without 
> a mmap time flag is likely hard.

PowerPC does not require specific virtual addresses for huge pages, but
does require that a consistent page size be used for each slice of the
virtual address space.  Slices are 256M in size from 0 to 4G and 1TB in
size above 1TB while huge pages are 64k, 16M, or 16G.  Unless the PPC
guys can work some more magic with their mmu, split_huge_page() in its
current form just plain won't work on PowerPC.  That doesn't even take
into account the (already discussed) page table layout differences
between x86 and ppc: http://linux-mm.org/PageTableStructure .

-- 
Thanks,
Adam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
