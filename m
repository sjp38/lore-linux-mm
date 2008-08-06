Date: Wed, 6 Aug 2008 10:02:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080806090222.GD21190@csn.ul.ie>
References: <20080730172317.GA14138@csn.ul.ie> <20080730103407.b110afc2.akpm@linux-foundation.org> <20080730193010.GB14138@csn.ul.ie> <20080730130709.eb541475.akpm@linux-foundation.org> <20080731103137.GD1704@csn.ul.ie> <1217884211.20260.144.camel@nimitz> <20080805111147.GD20243@csn.ul.ie> <1217952748.10907.18.camel@nimitz> <20080805162800.GJ20243@csn.ul.ie> <1217958805.10907.45.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1217958805.10907.45.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On (05/08/08 10:53), Dave Hansen didst pronounce:
> On Tue, 2008-08-05 at 17:28 +0100, Mel Gorman wrote:
> > Ok sure, you could do direct inserts for MAP_PRIVATE as conceptually it
> > suits this patch.  However, I don't see what you gain. By reusing hugetlbfs,
> > we get things like proper reservations which we can do for MAP_PRIVATE these
> > days. Again, we could call that sort of thing directly if the reservation
> > layer was split out separate from hugetlbfs but I still don't see the gain
> > for all that churn.
> > 
> > What am I missing?
> 
> This is good for getting us incremental functionality.  It is probably
> the smallest amount of code to get it functional.
> 

I'm not keen on the idea of introducing another specialised path just for
stacks. Testing coverage is tricky enough as it is and problems still slip
through occasionally. Maybe going through hugetlbfs is less than ideal,
but at least it is a shared path.

> My concern is that we're going down a path that all large page usage
> should be through the one and only filesystem.  Once we establish that
> dependency, it is going to be awfully hard to undo it;

Not much harder than it is to write any alternative in the first place
:/

> just think of all
> of the inherent behavior in hugetlbfs.  So, we better be sure that the
> filesystem really is the way to go, especially if we're going to start
> having other areas of the kernel depend on it internally.
> 

So far, it is working out as a decent model. It is able to track reservations
and deal with the differences between SHARED and PRIVATE without massive
difficulties. While we could add another specialised path to directly insert
the pages into pagetables for private mappings, I find it hard to justify
adding more test coverage problems. There might be minimal gains to be had
in lock granularity but that's about it.

> That said, this particular patch doesn't appear *too* bound to hugetlb
> itself.  But, some of its limitations *do* come from the filesystem,
> like its inability to handle VM_GROWS...  
> 

The lack of VM_GROWSX is an issue, but on its own it does not justify
the amount of churn necessary to support direct pagetable insertions for
MAP_ANONYMOUS|MAP_PRIVATE. I think we'd need another case or two that would
really benefit from direct insertions to pagetables instead of hugetlbfs so
that the path would get adequately tested.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
