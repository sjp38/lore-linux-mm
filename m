Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7836B005A
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 07:20:54 -0400 (EDT)
Date: Tue, 4 Aug 2009 12:48:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: mm/hugetlb: GFP_KERNEL allocation under spinlock?
Message-ID: <20090804114808.GB6608@csn.ul.ie>
References: <4A755201.1010200@gmail.com> <Pine.LNX.4.64.0908021131080.11578@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908021131080.11578@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 02, 2009 at 11:54:13AM +0100, Hugh Dickins wrote:
> On Sun, 2 Aug 2009, Jiri Slaby wrote:
> > 
> > could anybody please confirm this cannot happen?
> 
> I'm no authority on hugetlb.c nowadays: you'll have studied this
> in more detail than I have, so please don't believe me.  (And I'm
> no longer at my old address, but lkml's enjoying a quiet Sunday.)
> 
> > 
> > hugetlb_fault()
> > -> spin_lock()
> > -> hugetlb_cow()
> >    -> alloc_huge_page()
> >       -> vma_needs_reservation()
> >          -> region_chg() (either of the 2)
> >             -> kmalloc(*, GFP_KERNEL)
> > 
> > Thanks.
> 
> That should be taken care of by the successful vma_needs_reservation()
> on the same address in hugetlb_fault(), before taking page_table_lock,
> shouldn't it?
> 

Yes, any kmalloc() required should be happening outside spinlocks. The
region_chg and region_add acts like a prepare,commit pair except the naming
is diabolical. There was a mistake made at one point where kmalloc() was
called within a spinlock but enabling lock debugging caught it.

> It is possible that a hugetlb_vmtruncate() comes in between that
> vma_needs_reservation() and taking the page_table_lock, which could
> remove the region (or "nrg") needed.
> 
> But if that's the case then the pte_same test immediately after taking
> page_table_lock should catch it: we're in the part of hugetlb_fault()
> dealing with !huge_pte_none, whereas truncation would have made it
> huge_pte_none (and it won't get to freeing the reservations before
> it's nullified the page tables, holding page_table_lock).
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
