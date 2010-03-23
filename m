Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F16586B0071
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:08:59 -0400 (EDT)
Date: Tue, 23 Mar 2010 12:06:59 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
In-Reply-To: <20100322170619.GQ29874@random.random>
Message-ID: <alpine.DEB.2.00.1003231200430.10178@router.home>
References: <patchbomb.1268839142@v2.random> <alpine.DEB.2.00.1003171353240.27268@router.home> <20100318234923.GV29874@random.random> <alpine.DEB.2.00.1003190812560.10759@router.home> <20100319144101.GB29874@random.random> <alpine.DEB.2.00.1003221027590.16606@router.home>
 <20100322170619.GQ29874@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Mar 2010, Andrea Arcangeli wrote:

> > > Problem with O_DIRECT is that I couldn't use mmu notifier to prevent
> > > it to take the pin on the page, because there is no way to interrupt
> > > DMA synchronously before mmu_notifier_invalidate_* returns... So I had
> > > to add compound_lock and keep gup API backwards compatible and have
> > > the proper serialization happen _only_ for PageTail inside put_page.
> >
> > You can take a refcount *before* breaking up a 2M page then you dont have
> > to fear the put_page.
>
> If you take it _before_ it will go into the head page regardless of
> which subpage was returned by gup. We need to know which subpages are
> under DMA. The pin has to go to the tail pages or head page depending
> on the physical address that was requested by gup. To fix this we need
> at the very least to change gup api to ask for hugepages which it
> can't right now because it'd break all drivers.

A 2M page needs to be treated as a single page. Under DMA would mean that
the whole of the page is considered under DMA! Sectioning off the 2M page
causes all sorts of problems. The page state needs to be complete in a
single page struct.

> besides even if we add a error retval, we can't have mprotect/mremap
> fail at most swapout could be deferred because "page cannot be broken
> up" but even that is risky and I've been extra careful not to require
> any memory allocation or sleeping lock in split_huge_page to make it
> ideal to use in swap path without risking any functional regression
> whatsoever.

We can go to sleep in mprotect and mremap and wait for the breaking up to
be successful.

> Allowing it to fail would result in a mess. Obviously I wasn't clear
> enough in the last sentence of my previous mail so I'll have to
> repeate: any effort in handling the failure (which in some case it
> can't be handled as syscalls can't fail just because a page is 2M)
> should instead be spent to _remove_ the split_huge_page call.

Its not advisable to do this. Splitting the huge page may cause surprises
to another kernel function that is operating on the assumption that this
is a 2M page. If you do this then new synchronization methods are
required.

> > We already have 2M pmd handling in the kernel and can consider huge pmd
> > entries while walking the page tables! Go incrementally use what
> > is there.
>
> There's no such thing unless you talk about the hugetlbfs paths. In

Indeed I am.

> Best of all, I had to add zero atomic ops and just 1 branch in already
> hot l1 cache (and no writes to the l1 cache either, just 1 more read)
> in order to add the pagefault slow path for huge pmd. So unless you
> actively take advantage of hugepages, the page_table_lock locking will
> be zero cost and in the future nothing prevents us to add a more
> scalar PMD lock like it exists for the pte (but keep in mind it's much
> 512 times less important for PMD than it is for the PTE).

Its not much use to have fake 2M pages that can splinter below you at any
time. In order to take full advantage of huge pages you need to be able
to do VM operations on them and for that these things need to be treated
as a single unit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
