Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m77HU3OL024141
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 13:30:03 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m77HTrWZ215946
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 13:29:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m77HTqKJ025111
	for <linux-mm@kvack.org>; Thu, 7 Aug 2008 13:29:53 -0400
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080807160605.GA9200@csn.ul.ie>
References: <20080730193010.GB14138@csn.ul.ie>
	 <20080730130709.eb541475.akpm@linux-foundation.org>
	 <20080731103137.GD1704@csn.ul.ie> <1217884211.20260.144.camel@nimitz>
	 <20080805111147.GD20243@csn.ul.ie> <1217952748.10907.18.camel@nimitz>
	 <20080805162800.GJ20243@csn.ul.ie> <1217958805.10907.45.camel@nimitz>
	 <20080806090222.GD21190@csn.ul.ie> <1218052249.10907.125.camel@nimitz>
	 <20080807160605.GA9200@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8
Date: Thu, 07 Aug 2008 10:29:50 -0700
Message-Id: <1218130190.10907.188.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-08-07 at 17:06 +0100, Mel Gorman wrote:
> On (06/08/08 12:50), Dave Hansen didst pronounce:
> > The main thing this set of patches does that I care about is take an
> > anonymous VMA and replace it with a hugetlb VMA.  It does this on a
> > special cue, but does it nonetheless.
> 
> This is not actually a new thing. For a long time now, it has been possible to
> back  malloc() with hugepages at a userspace level using the morecore glibc
> hook. That is replacing anonymous memory with a file-backed VMA. It happens
> in a different place but it's just as deliberate as backing stack and the
> end result is very similar. As the file is ram-based, it doesn't have the
> same types of consequences like dirty page syncing that you'd ordinarily
> watch for when moving from anonymous to file-backed memory.

Yes, it has already been done in userspace.  That's fine.  It isn't
adding any complexity to the kernel.  This is adding behavior that the
kernel has to support as well as complexity.

> > This patch has crossed a line in that it is really the first
> > *replacement* of a normal VMA with a hugetlb VMA instead of the creation
> > of the VMAs at the user's request. 
> 
> We crossed that line with morecore, it's back there somewhere. We're just
> doing in kernel this time because backing stacks with hugepages in userspace
> turned out to be a hairy endevour.
> 
> Properly supporting anonymous hugepages would either require larger
> changes to the core or reimplementing yet more of mm/ in mm/hugetlb.c.
> Neither is a particularly appealing approach, nor is it likely to be a
> very popular one.

I agree.  It is always much harder to write code that can work
genericallyi>>? (and get it accepted) than just write the smallest possible
hack and stick it in fs/exec.c.

Could this patch at least get fixed up to look like it could be used
more generically?  Some code to look up and replace anonymous VMAs with
hugetlb-backed ones.
i>>?
> > Because of the limitations like its inability to grow the VMA, I can't
> > imagine that this would be a generic mechanism that we can use
> > elsewhere.
> 
> What other than a stack even cares about VM_GROWSDOWN working? Besides,
> VM_GROWSDOWN could be supported in a hugetlbfs file by mapping the end of
> the file and moving the offset backwards (yeah ok, it ain't the prettiest
> but it's less churn than introducing significantly different codepaths). It's
> just not something that needs to be supported at first cut.
> 
> brk() if you wanted to back hugepages with it conceivably needs a resizing
> VMA but in that case it's growing up in which case just extend the end of
> the VMA and increase the size of the file.

I'm more worried about a small huge page size (say 64k) and not being
able to merge the VMAs.  I guess it could start in the *middle* of a
file and map both directions.

I guess you could always just have a single (very sparse) hugetlb file
per mm to do all of this 'anonymous' hugetlb memory memory stuff, and
just map its offsets 1:1 on to the process's virtual address space.
That would make sure you could always merge VMAs, no matter how they
grew together.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
