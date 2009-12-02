Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 068566007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 17:19:53 -0500 (EST)
Date: Wed, 2 Dec 2009 22:19:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] hugetlb: Acquire the i_mmap_lock before walking the
	prio_tree to unmap a page
Message-ID: <20091202221947.GB26702@csn.ul.ie>
References: <20091202141930.GF1457@csn.ul.ie> <Pine.LNX.4.64.0912022003100.8113@sister.anvils> <20091202221602.GA26702@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091202221602.GA26702@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 10:16:02PM +0000, Mel Gorman wrote:
> On Wed, Dec 02, 2009 at 08:13:39PM +0000, Hugh Dickins wrote:
> > On Wed, 2 Dec 2009, Mel Gorman wrote:
> > 
> > > When the owner of a mapping fails COW because a child process is holding a
> > > reference and no pages are available, the children VMAs are walked and the
> > > page is unmapped. The i_mmap_lock is taken for the unmapping of the page but
> > > not the walking of the prio_tree. In theory, that tree could be changing
> > > while the lock is released although in practice it is protected by the
> > > hugetlb_instantiation_mutex. This patch takes the i_mmap_lock properly for
> > > the duration of the prio_tree walk in case the hugetlb_instantiation_mutex
> > > ever goes away.
> > > 
> > > [hugh.dickins@tiscali.co.uk: Spotted the problem in the first place]
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > The patch looks good - thanks for taking care of that, Mel.
> > 
> > But the comment seems wrong to me: hugetlb_instantiation_mutex
> > guards against concurrent hugetlb_fault()s; but the structure of
> > the prio_tree shifts as vmas based on that inode are inserted into
> > (mmap'ed) and removed from (munmap'ed) that tree (always while
> > holding i_mmap_lock).  I don't see hugetlb_instantiation_mutex
> > giving us any protection against this at present.
> > 
> 
> You're right of course. I'll report without that nonsense included.
> 

Actually, shouldn't the mmap_sem be protecting against concurrent mmap and
munmap altering the tree? The comment is still bogus of course.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
