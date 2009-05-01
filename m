Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF27F6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 11:09:30 -0400 (EDT)
Date: Fri, 1 May 2009 16:09:33 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Message-ID: <20090501150933.GE27831@csn.ul.ie>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils> <20090501140015.GA27831@csn.ul.ie> <alpine.DEB.1.10.0905010958090.18324@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0905010958090.18324@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 09:59:35AM -0400, Christoph Lameter wrote:
> On Fri, 1 May 2009, Mel Gorman wrote:
> 
> > > Andrew noticed another oddity: that if it goes the hashdist __vmalloc()
> > > way, it won't be limited by MAX_ORDER.  Makes one wonder whether it
> > > ought to fall back to __vmalloc() if the alloc_pages_exact() fails.
> >
> > I don't believe so. __vmalloc() is only used when hashdist= is used or on IA-64
> > (according to the documentation). It is used in the case that the caller is
> > willing to deal with the vmalloc() overhead (e.g. using base page PTEs) in
> > exchange for the pages being interleaved on different nodes so that access
> > to the hash table has average performance[*]
> >
> > If we automatically fell back to vmalloc(), I bet 2c we'd eventually get
> > a mysterious performance regression report for a workload that depended on
> > the hash tables performance but that there was enough memory for the hash
> > table to be allocated with vmalloc() instead of alloc_pages_exact().
> 
> Can we fall back to a huge page mapped vmalloc? Like what the vmemmap code
> does? Then we also would not have MAX_ORDER limitations.
> 

Potentially yes, although it would appear that it will only help the networking
hash table. Dentry and inode are both using the bootmem allocator to allocate
their tables so can exceed MAX_ORDER limitations.

But IIRC, the vmemmap code depends on architecture-specific help from
vmemmap_populate() to place the map in the right place and it's not universally
available. It's likely that similar would be needed to support large
hash tables. I think the networking guys would need to be fairly sure
the larger table would make a big difference before tackling the
problem.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
