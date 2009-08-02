Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C51D6B005D
	for <linux-mm@kvack.org>; Sun,  2 Aug 2009 06:43:27 -0400 (EDT)
Date: Sun, 2 Aug 2009 11:54:13 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: mm/hugetlb: GFP_KERNEL allocation under spinlock?
In-Reply-To: <4A755201.1010200@gmail.com>
Message-ID: <Pine.LNX.4.64.0908021131080.11578@sister.anvils>
References: <4A755201.1010200@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sun, 2 Aug 2009, Jiri Slaby wrote:
> 
> could anybody please confirm this cannot happen?

I'm no authority on hugetlb.c nowadays: you'll have studied this
in more detail than I have, so please don't believe me.  (And I'm
no longer at my old address, but lkml's enjoying a quiet Sunday.)

> 
> hugetlb_fault()
> -> spin_lock()
> -> hugetlb_cow()
>    -> alloc_huge_page()
>       -> vma_needs_reservation()
>          -> region_chg() (either of the 2)
>             -> kmalloc(*, GFP_KERNEL)
> 
> Thanks.

That should be taken care of by the successful vma_needs_reservation()
on the same address in hugetlb_fault(), before taking page_table_lock,
shouldn't it?

It is possible that a hugetlb_vmtruncate() comes in between that
vma_needs_reservation() and taking the page_table_lock, which could
remove the region (or "nrg") needed.

But if that's the case then the pte_same test immediately after taking
page_table_lock should catch it: we're in the part of hugetlb_fault()
dealing with !huge_pte_none, whereas truncation would have made it
huge_pte_none (and it won't get to freeing the reservations before
it's nullified the page tables, holding page_table_lock).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
