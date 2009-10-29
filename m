Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 151706B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:56:16 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 087AE82CE08
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 11:02:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gLC3ppssfrRm for <linux-mm@kvack.org>;
	Thu, 29 Oct 2009 11:02:08 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A814282CDEA
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 11:01:41 -0400 (EDT)
Date: Thu, 29 Oct 2009 14:55:08 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: RFC: Transparent Hugepage support
In-Reply-To: <20091027182109.GA5753@random.random>
Message-ID: <alpine.DEB.1.10.0910291451240.18197@V090114053VZO-1>
References: <20091026185130.GC4868@random.random> <alpine.DEB.1.10.0910271630540.20363@V090114053VZO-1> <20091027182109.GA5753@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009, Andrea Arcangeli wrote:

> Agreed, migration is important on numa systems as much as swapping is
> important on regular hosts, and this patch allows both in the very
> same way with a few liner addition (that is a noop and doesn't modify
> the kernel binary when CONFIG_TRANSPARENT_HUGEPAGE=N). The hugepages
> in this patch should already relocatable just fine with move_pages (I
> say "should" because I didn't test move_pages yet ;).

Another NUMA issue is how MPOL_INTERLEAVE would work with this.
MPOL_INTERLEAVE would cause the spreading of a sequence of pages over a
series of nodes. If you coalesce to one huge page then that cannot be done
anymore.


> > Wont you be running into issues with page dirtying on that level?
>
> Not sure I follow what the problem should be. At the moment when
> pmd_trans_huge is true, the dirty bit is meaningless (hugepages at the
> moment are splitted in place into regular pages before they can be
> converted to swapcache, only after an hugepage becomes swapcache its
> dirty bit on the pte becomes meaningful to handle the case of an
> exclusive swapcache mapped writeable into a single pte and marked
> clean to be able to swap it out at zerocost if memory pressure returns
> and to avoid a cow if the page is written to before it is paged out
> again), but the accessed bit is already handled just fine at the pmd
> level.

May not be a problem as long as you dont allow fs operations with these
pages.

> > Those also had fall back logic to 4k. Does this scheme also allow I/O with
>
> Well maybe I remember your patches wrong, or I might have not followed
> later developments but I was quite sure to remember when we discussed
> it, the reason of the -EIO failure was the fs had softblocksize bigger
> than 4k... and in general fs can't handle blocksize bigger than the
> PAGE_CACHE_SIZE... In effect the core trouble wasnt' the large
> pagecache but the fact the fs wanted a blocksize larger than
> PAGE_SIZE, despite not being able to handle it, if the block was
> splitted in multiple 4k not contiguous areas.

The patches modified the page cache logic to determine the page size from
the page structs.

> > I dont get the point of this. What do you mean by "an operation that
> > cannot fail"? Atomic section?
>
> In short I mean it cannot return -ENOMEM (and an additional bonus is
> that I managed it not to require scheduling or blocking
> operations). The idea is that you can plug it anywhere with a one
> liner and your code becomes hugepage compatible (sure it would run
> faster if you were to teach to your code to handle pmd_trans_huge
> natively but we can't do it all at once :).

We need to know some more detail about the conversion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
