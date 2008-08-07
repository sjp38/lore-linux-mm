Date: Thu, 7 Aug 2008 17:06:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080807160605.GA9200@csn.ul.ie>
References: <20080730193010.GB14138@csn.ul.ie> <20080730130709.eb541475.akpm@linux-foundation.org> <20080731103137.GD1704@csn.ul.ie> <1217884211.20260.144.camel@nimitz> <20080805111147.GD20243@csn.ul.ie> <1217952748.10907.18.camel@nimitz> <20080805162800.GJ20243@csn.ul.ie> <1217958805.10907.45.camel@nimitz> <20080806090222.GD21190@csn.ul.ie> <1218052249.10907.125.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1218052249.10907.125.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On (06/08/08 12:50), Dave Hansen didst pronounce:
> On Wed, 2008-08-06 at 10:02 +0100, Mel Gorman wrote:
> > > That said, this particular patch doesn't appear *too* bound to hugetlb
> > > itself.  But, some of its limitations *do* come from the filesystem,
> > > like its inability to handle VM_GROWS...  
> > 
> > The lack of VM_GROWSX is an issue, but on its own it does not justify
> > the amount of churn necessary to support direct pagetable insertions for
> > MAP_ANONYMOUS|MAP_PRIVATE. I think we'd need another case or two that would
> > really benefit from direct insertions to pagetables instead of hugetlbfs so
> > that the path would get adequately tested.
> 
> I'm jumping around here a bit, but I'm trying to get to the core of what
> my problem with these patches is.  I'll see if I can close the loop
> here.
> 
> The main thing this set of patches does that I care about is take an
> anonymous VMA and replace it with a hugetlb VMA.  It does this on a
> special cue, but does it nonetheless.
> 

This is not actually a new thing. For a long time now, it has been possible to
back  malloc() with hugepages at a userspace level using the morecore glibc
hook. That is replacing anonymous memory with a file-backed VMA. It happens
in a different place but it's just as deliberate as backing stack and the
end result is very similar. As the file is ram-based, it doesn't have the
same types of consequences like dirty page syncing that you'd ordinarily
watch for when moving from anonymous to file-backed memory.

> This patch has crossed a line in that it is really the first
> *replacement* of a normal VMA with a hugetlb VMA instead of the creation
> of the VMAs at the user's request. 

We crossed that line with morecore, it's back there somewhere. We're just
doing in kernel this time because backing stacks with hugepages in userspace
turned out to be a hairy endevour.

Properly supporting anonymous hugepages would either require larger
changes to the core or reimplementing yet more of mm/ in mm/hugetlb.c.
Neither is a particularly appealing approach, nor is it likely to be a
very popular one.

> I'm really curious what the plan is
> to follow up on this.  Will this stack stuff turn out to be one-off
> code, or is this *the* route for getting transparent large pages in the
> future?
> 

Conceivably, we could also implement MAP_LARGEPAGE for MAP_ANONYMOUS
which would use the same hugetlb_file_setup() as for shmem and stacks
with this patch. It would be a reliavely straight-forward patch if reusing
hugetlb_file_setup() as the flags can be passed through almost verbatim. In
that case, hugetlbfs still makes a good fit without making direct pagetable
insertions necessary.

> Because of the limitations like its inability to grow the VMA, I can't
> imagine that this would be a generic mechanism that we can use
> elsewhere.
> 

What other than a stack even cares about VM_GROWSDOWN working? Besides,
VM_GROWSDOWN could be supported in a hugetlbfs file by mapping the end of
the file and moving the offset backwards (yeah ok, it ain't the prettiest
but it's less churn than introducing significantly different codepaths). It's
just not something that needs to be supported at first cut.

brk() if you wanted to back hugepages with it conceivably needs a resizing
VMA but in that case it's growing up in which case just extend the end of
the VMA and increase the size of the file.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
