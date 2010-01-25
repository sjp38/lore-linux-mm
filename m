Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4EBC36B009A
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 17:27:49 -0500 (EST)
Date: Mon, 25 Jan 2010 15:50:31 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
In-Reply-To: <20100123175847.GC6494@random.random>
Message-ID: <alpine.DEB.2.00.1001251529070.5379@router.home>
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 23 Jan 2010, Andrea Arcangeli wrote:

> > > hugepages. khugepaged only collapse pages into hugepages if there are
> > > no references at all (no gup no nothing) so again no issue DMA-wise.
> >
> > Reclaim cannot kick out page size pieces of the huge page?
>
> Before the VM can kick out any hugepage it has to split it, then each
> page-sized-piece will be considered individually, so reclaim only
> kicks out page-sized-pieces of the hugepage.

So yes.... Sigh.

> > > have irq disabled so the ipi of collapse_huge_page will wait. It's all
> > > handled transparently by the patch, you won't notice you're dealing
> > > with hugepage if you're gup user (unless you use gup to migrate pages
> > > in which case calling split_huge_page is enough like in patch ;).
> >
> > What if I want to use hugepages for some purpose and I dont want to use
> > 512 pointers to keep track of the individual pieces?
>
> If you use hugepages and there's no VM activity or other activity that
> triggers split_huge_page, there are no 512 pointers, but just 1
> pointer in the pmd to the hugepage, and no other link at all. There is

There is always VM activity, so we need 512 pointers sigh.

So its not possible to use these "huge" pages in a useful way inside of
the kernel. They are volatile and temporary.

In short they cannot be treated as 2M entities unless we add some logic to
prevent splitting.

Frankly this seems to be adding splitting that cannot be used if one
really wants to use large pages for something.

I still think we should get transparent huge page support straight up
first without complicated fallback schemes that makes huge pages difficult
to use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
