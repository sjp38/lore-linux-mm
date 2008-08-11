Date: Mon, 11 Aug 2008 09:04:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080811080449.GB17452@csn.ul.ie>
References: <20080731103137.GD1704@csn.ul.ie> <1217884211.20260.144.camel@nimitz> <20080805111147.GD20243@csn.ul.ie> <1217952748.10907.18.camel@nimitz> <20080805162800.GJ20243@csn.ul.ie> <1217958805.10907.45.camel@nimitz> <20080806090222.GD21190@csn.ul.ie> <1218052249.10907.125.camel@nimitz> <20080807160605.GA9200@csn.ul.ie> <1218130190.10907.188.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1218130190.10907.188.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On (07/08/08 10:29), Dave Hansen didst pronounce:
> On Thu, 2008-08-07 at 17:06 +0100, Mel Gorman wrote:
> > On (06/08/08 12:50), Dave Hansen didst pronounce:
> > > The main thing this set of patches does that I care about is take an
> > > anonymous VMA and replace it with a hugetlb VMA.  It does this on a
> > > special cue, but does it nonetheless.
> > 
> > This is not actually a new thing. For a long time now, it has been possible to
> > back  malloc() with hugepages at a userspace level using the morecore glibc
> > hook. That is replacing anonymous memory with a file-backed VMA. It happens
> > in a different place but it's just as deliberate as backing stack and the
> > end result is very similar. As the file is ram-based, it doesn't have the
> > same types of consequences like dirty page syncing that you'd ordinarily
> > watch for when moving from anonymous to file-backed memory.
> 
> Yes, it has already been done in userspace.  That's fine.  It isn't
> adding any complexity to the kernel.  This is adding behavior that the
> kernel has to support as well as complexity.
> 

The complexity is minimal and the progression logical.
hugetlb_file_setup() is the API shmem was using to create a file on an
internal mount suitable for MAP_SHARED. This patchset adds support for
MAP_PRIVATE and the additional complexity is a lot less than supporting
direct pagetable inserts.

> > > This patch has crossed a line in that it is really the first
> > > *replacement* of a normal VMA with a hugetlb VMA instead of the creation
> > > of the VMAs at the user's request. 
> > 
> > We crossed that line with morecore, it's back there somewhere. We're just
> > doing in kernel this time because backing stacks with hugepages in userspace
> > turned out to be a hairy endevour.
> > 
> > Properly supporting anonymous hugepages would either require larger
> > changes to the core or reimplementing yet more of mm/ in mm/hugetlb.c.
> > Neither is a particularly appealing approach, nor is it likely to be a
> > very popular one.
> 
> I agree.  It is always much harder to write code that can work
> generically??? (and get it accepted) than just write the smallest possible
> hack and stick it in fs/exec.c.
> 
> Could this patch at least get fixed up to look like it could be used
> more generically?  Some code to look up and replace anonymous VMAs with
> hugetlb-backed ones???

Ok, this latter point can be looked into at least although the
underlying principal may still be using hugetlb_file_setup() rather than
direct pagetable insertions.

> > > Because of the limitations like its inability to grow the VMA, I can't
> > > imagine that this would be a generic mechanism that we can use
> > > elsewhere.
> > 
> > What other than a stack even cares about VM_GROWSDOWN working? Besides,
> > VM_GROWSDOWN could be supported in a hugetlbfs file by mapping the end of
> > the file and moving the offset backwards (yeah ok, it ain't the prettiest
> > but it's less churn than introducing significantly different codepaths). It's
> > just not something that needs to be supported at first cut.
> > 
> > brk() if you wanted to back hugepages with it conceivably needs a resizing
> > VMA but in that case it's growing up in which case just extend the end of
> > the VMA and increase the size of the file.
> 
> I'm more worried about a small huge page size (say 64k) and not being
> able to merge the VMAs.  I guess it could start in the *middle* of a
> file and map both directions.
> 
> I guess you could always just have a single (very sparse) hugetlb file
> per mm to do all of this 'anonymous' hugetlb memory memory stuff, and
> just map its offsets 1:1 on to the process's virtual address space.
> That would make sure you could always merge VMAs, no matter how they
> grew together.
> 

That's an interesting idea. It isn't as straight-forward as it sounds
due to reservation tracking but at the face of it, I can't see why it
couldn't be made work.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
