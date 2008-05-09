Date: Fri, 9 May 2008 14:30:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3] Guarantee faults for processes that call mmap(MAP_PRIVATE) on hugetlbfs v2
Message-ID: <20080509133016.GA18317@csn.ul.ie>
References: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie> <20080508014822.GE5156@yookeroo.seuss> <20080508111408.GB30870@shadowen.org> <20080509000249.GA8552@yookeroo.seuss>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080509000249.GA8552@yookeroo.seuss>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <dwg@au1.ibm.com>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, andi@firstfloor.org, kenchen@google.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On (09/05/08 10:02), David Gibson didst pronounce:
> > > <SNIP>
> > > 
> > > I don't think patch 3 is a good idea.  It's a fair bit of code to
> > > implement a pretty bizarre semantic that I really don't think is all
> > > that useful.  Patches 1-2 are already sufficient to cover the
> > > fork()/exec() case and a fair proportion of fork()/minor
> > > frobbing/exit() cases.  If the child also needs to write the hugepage
> > > area, chances are it's doing real work and we care about its
> > > reliability too.
> > 
> > Without patch 3 the parent is still vunerable during the period the
> > child exists.  Even if that child does nothing with the pages not even
> > referencing them, and then execs immediatly.  As soon as we fork any
> > reference from the parent will trigger a COW, at which point there may
> > be no pages available and the parent will have to be killed.  That is
> > regardless of the fact the child is not going to reference the page and
> > leave the address space shortly.  With patch 3 on COW if we find no memory
> > available the page may be stolen for the parent saving it, and the _risk_
> > of reference death moves to the child; the child is killed only should it
> > then re-reference the page.
> 
> Yes, thinko, sorry.  Forgot that a COW would be triggered even if the
> child never wrote the pages.  I see the point of patch 3 now.  Damn,
> but it's still a weird semantic to be implementing though.
> 

The current semantics without the patches are already pretty weird. I
still believe having reliable behaviour for the mapper and moving the
death-by-reference problem to the children when the pool is too small is an
improvement over what currently exists.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
