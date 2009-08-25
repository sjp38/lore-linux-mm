Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E14E66B00AC
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:31:19 -0400 (EDT)
Date: Tue, 25 Aug 2009 11:53:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
Message-ID: <20090825105341.GB21335@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org> <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com> <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com> <20090819100553.GE24809@csn.ul.ie> <202cde0e0908232314j4b90aa61pb4bcd0223ffbc087@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0908232314j4b90aa61pb4bcd0223ffbc087@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 06:14:30PM +1200, Alexey Korolev wrote:
> Mel,
> 
> > How about;
> >
> >        o Extend Eric's helper slightly to take a GFP mask that is
> >          associated with the inode and used for allocations from
> >          outside the hugepage pool
> >        o A helper that returns the page at a given offset within
> >          a hugetlbfs file for population before the page has been
> >          faulted.
> >
> > I know this is a bit hand-wavy, but it would allow significant sharing
> > of the existing code and remove much of the hugetlbfs-awareness from
> > your current driver.
> >
> 
> I'm trying to write the solution you have described. The question I
> have is about extension of hugetlb_file_setup function.
> Is it supposed to allocate memory in hugetlb_file_setup function? Or
> it is supposed to have reservation only.

It indirectly allocates. If there are sufficient hugepages in the static pool,
then it's reservation-only. If dynamic hugepage pool resizing is enabled,
it will allocate more hugepages if necessary and then reserve them.

> If reservation only, then it is necessary to keep a gfp_mask for a
> file somewhere. Would it be Ok to keep a gfp_mask for a file in
> file->private_data?
> 

I'm not seeing where this gfp mask is coming out of if you don't have zone
limitations. GFP masks don't help you get contiguity beyond the hugepage
boundary.

If you did need the GFP mask, you could store it in hugetlbfs_inode_info
as you'd expect all users of that inode to have the same GFP
requirements, right?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
