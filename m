Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AD69A6B01B5
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 13:08:16 -0400 (EDT)
Date: Mon, 22 Mar 2010 18:06:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
Message-ID: <20100322170619.GQ29874@random.random>
References: <patchbomb.1268839142@v2.random>
 <alpine.DEB.2.00.1003171353240.27268@router.home>
 <20100318234923.GV29874@random.random>
 <alpine.DEB.2.00.1003190812560.10759@router.home>
 <20100319144101.GB29874@random.random>
 <alpine.DEB.2.00.1003221027590.16606@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003221027590.16606@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 10:38:23AM -0500, Christoph Lameter wrote:
> On Fri, 19 Mar 2010, Andrea Arcangeli wrote:
> 
> > > Look at the patches. They add synchronization to pte operations.
> >
> > The whole point is that it's fundamentally unavoidable and not
> > specific to any of split_huge_page, compound_lock or
> > get_page/put_page!
> 
> Really? Why did no one else run into this before?

Of course we run into this before too, and the locking in fact already
exists and you probably added it yourself when introducing the more
scalare PT lock for the pte.

For the pmd we always used the page_table_lock and I kept using
it. Except that before it was only necessary in __pte_alloc (see
mainline), now it's needed in more places because the pmd can be
modified as it points to actual pages that can go away, and not only
to ptes.

> > Problem with O_DIRECT is that I couldn't use mmu notifier to prevent
> > it to take the pin on the page, because there is no way to interrupt
> > DMA synchronously before mmu_notifier_invalidate_* returns... So I had
> > to add compound_lock and keep gup API backwards compatible and have
> > the proper serialization happen _only_ for PageTail inside put_page.
> 
> You can take a refcount *before* breaking up a 2M page then you dont have
> to fear the put_page.

If you take it _before_ it will go into the head page regardless of
which subpage was returned by gup. We need to know which subpages are
under DMA. The pin has to go to the tail pages or head page depending
on the physical address that was requested by gup. To fix this we need
at the very least to change gup api to ask for hugepages which it
can't right now because it'd break all drivers.

> Keep a reference count in the head page and a pointer to the subpage? Page
> can only be broken up if all page references of the 2M page can be
> accounted for. This implies no "atomic" breakup but this way it does not
> require changes to synchronization.

"can only broken up". See my last sentence of my previous reply to
figure out exactly why we're not ok if "page cannot be broken up".

besides even if we add a error retval, we can't have mprotect/mremap
fail at most swapout could be deferred because "page cannot be broken
up" but even that is risky and I've been extra careful not to require
any memory allocation or sleeping lock in split_huge_page to make it
ideal to use in swap path without risking any functional regression
whatsoever.

> That is the basic crux here. Do not require that it cannot fail. Its a bad
> move and results in a mess.

Allowing it to fail would result in a mess. Obviously I wasn't clear
enough in the last sentence of my previous mail so I'll have to
repeate: any effort in handling the failure (which in some case it
can't be handled as syscalls can't fail just because a page is 2M)
should instead be spent to _remove_ the split_huge_page call.

> No its not. I am proposing to *keep* the existing syncronization methods.
> Use what is there. Do not invent new synchronization.

You don't see the huge value of the invention. When you go around
implementing your own split_huge_page that will fail, you might see
it (or we can compare the size of the two patches then, knowing that
I add 1 line to mremap and you add hundreds or maybe you can't use
your split_huge_page there at all forcing you to handle 2M pages
immediately from the start). And mremap is not the big deal, it's that
if you can't use it in mremap you practically won't be able to use it
anywhere except in swap, where you will introduce a nasty unknown and
potential livelock or deadlock.

> We already have 2M pmd handling in the kernel and can consider huge pmd
> entries while walking the page tables! Go incrementally use what
> is there.

There's no such thing unless you talk about the hugetlbfs paths. In
the core paths that the only thing I care about in transparent
hugepage, pmd is only checked to be present. If it's present it can't
go away. This is not true anymore as it can point to user pages and
not ptes. I am definitely reusing the same synchronization for ptes
that already is used by __pte_alloc which is the only bit that
requires synchronization right now, to atomically check if the pmd is
still not present, before overwriting it.

Best of all, I had to add zero atomic ops and just 1 branch in already
hot l1 cache (and no writes to the l1 cache either, just 1 more read)
in order to add the pagefault slow path for huge pmd. So unless you
actively take advantage of hugepages, the page_table_lock locking will
be zero cost and in the future nothing prevents us to add a more
scalar PMD lock like it exists for the pte (but keep in mind it's much
512 times less important for PMD than it is for the PTE).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
