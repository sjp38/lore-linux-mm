Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7DD6B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 08:50:39 -0400 (EDT)
Date: Thu, 27 Aug 2009 13:50:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
Message-ID: <20090827125043.GD21183@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org> <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com> <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com> <20090819100553.GE24809@csn.ul.ie> <202cde0e0908232314j4b90aa61pb4bcd0223ffbc087@mail.gmail.com> <20090825105341.GB21335@csn.ul.ie> <202cde0e0908270502p3ea403ddr516945084372ffc4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0908270502p3ea403ddr516945084372ffc4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 12:02:05AM +1200, Alexey Korolev wrote:
> > > If reservation only, then it is necessary to keep a gfp_mask for a
> > > file somewhere. Would it be Ok to keep a gfp_mask for a file in
> > > file->private_data?
> > >
> >
> > I'm not seeing where this gfp mask is coming out of if you don't have zone
> > limitations. GFP masks don't help you get contiguity beyond the hugepage
> > boundary.
>
> Contiguity is different.

Ok, then contiguity is independant of any GFP mask considerations. Why
do you need a GFP mask?

> It is not related to GFP mask.
> Requirement to have large contigous buffer is dictated by h/w. Since
> this is very specific case it will need very specific solution. So if
> providing this, affects on usability of kernel interfaces it's better
> to left interfaces good.

You are in a bit of a bind with regards to contiguous allocations that are
larger than a huge page. Neither the huge page pools nor the buddy allocator
helps you much in this regard. I think it would be worth considering contiguous
allocations larger than a huge page size as a separate follow-on problem to
huge pages being available to a driver.

> But large DMA buffers with large amount of sg regions is more common.
> DMA engine often requires 32 address space. Plus memory must be non
> movable.
> That raises another question: would it be correct assumiing that
> setting sysctl hugepages_treat_as_movable won't make huge pages
> movable?

Correct, treating them as movable allows them to be allocated from
ZONE_MOVABLE. It's unlikely that swap support will be implemented for
huge pages. It's more likely that migration support would be implemented
at some point but AFAIK, there is little or not demand for that feature.

> > If you did need the GFP mask, you could store it in hugetlbfs_inode_info
> > as you'd expect all users of that inode to have the same GFP
> > requirements, right?
>
> Correct. The same GFP per inode is quite enough.
> So that way works. I made a bit raw implementation, more testing and
> tuning and I'll send out another version.
> 

Ok, but please keep the exposure of hugetlbfs internals to a minimum or
at least have a strong justification. As it is, I'm not understanding why
expanding Eric's helper for MAP_HUGETLB slightly and maintaining a mapping
between your driver file and the underlying hugetlbfs file does not cover
most of the problem.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
