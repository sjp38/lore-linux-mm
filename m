Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 83B126B0044
	for <linux-mm@kvack.org>; Sat,  5 Dec 2009 07:37:13 -0500 (EST)
Date: Sat, 5 Dec 2009 12:37:00 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] hugetlb: Acquire the i_mmap_lock before walking the
 prio_tree to unmap a page
In-Reply-To: <20091202221947.GB26702@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0912051235001.31181@sister.anvils>
References: <20091202141930.GF1457@csn.ul.ie> <Pine.LNX.4.64.0912022003100.8113@sister.anvils>
 <20091202221602.GA26702@csn.ul.ie> <20091202221947.GB26702@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Mel Gorman wrote:
> On Wed, Dec 02, 2009 at 10:16:02PM +0000, Mel Gorman wrote:
> > On Wed, Dec 02, 2009 at 08:13:39PM +0000, Hugh Dickins wrote:
> > > 
> > > But the comment seems wrong to me: hugetlb_instantiation_mutex
> > > guards against concurrent hugetlb_fault()s; but the structure of
> > > the prio_tree shifts as vmas based on that inode are inserted into
> > > (mmap'ed) and removed from (munmap'ed) that tree (always while
> > > holding i_mmap_lock).  I don't see hugetlb_instantiation_mutex
> > > giving us any protection against this at present.
> > > 
> > 
> > You're right of course. I'll report without that nonsense included.
> > 
> 
> Actually, shouldn't the mmap_sem be protecting against concurrent mmap and
> munmap altering the tree? The comment is still bogus of course.

No, the mmap_sem can only protect against other threads sharing that
same mm: whereas the prio_tree can shift around according to concurrent
mmaps and munmaps of the same file in other mms.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
