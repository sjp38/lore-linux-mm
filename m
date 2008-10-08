Date: Wed, 8 Oct 2008 19:55:32 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
Message-ID: <20081008185532.GA13304@brain>
References: <1223458431-12640-1-git-send-email-apw@shadowen.org> <1223458431-12640-2-git-send-email-apw@shadowen.org> <48ECDD37.8050506@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48ECDD37.8050506@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 11:17:59AM -0500, Christoph Lameter wrote:
> Andy Whitcroft wrote:
> > When working with hugepages, hugetlbfs assumes that those hugepages
> > are smaller than MAX_ORDER.  Specifically it assumes that the mem_map
> > is contigious and uses that to optimise access to the elements of the
> > mem_map that represent the hugepage.  Gigantic pages (such as 16GB pages
> > on powerpc) by definition are of greater order than MAX_ORDER (larger
> > than MAX_ORDER_NR_PAGES in size).  This means that we can no longer make
> > use of the buddy alloctor guarentees for the contiguity of the mem_map,
> > which ensures that the mem_map is at least contigious for maximmally
> > aligned areas of MAX_ORDER_NR_PAGES pages.
> 
> But the memmap is contiguous in most cases. FLATMEM, VMEMMAP etc. Its only
> some special sparsemem configurations that couldhave the issue because they
> break up the vmemmap. x86_64 uses VMEMMAP by default. Is this for i386?

With SPARSEMEM turned on and VMEMMAP turned off a valid combination,
we will end up scribbling all over memory which is pretty serious so for
that reason we should handle this case.  There are cirtain combinations
of features which require SPARSMEM but preclude VMEMMAP which trigger this.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
