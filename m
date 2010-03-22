Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A76496B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 11:40:25 -0400 (EDT)
Date: Mon, 22 Mar 2010 10:38:23 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
In-Reply-To: <20100319144101.GB29874@random.random>
Message-ID: <alpine.DEB.2.00.1003221027590.16606@router.home>
References: <patchbomb.1268839142@v2.random> <alpine.DEB.2.00.1003171353240.27268@router.home> <20100318234923.GV29874@random.random> <alpine.DEB.2.00.1003190812560.10759@router.home> <20100319144101.GB29874@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010, Andrea Arcangeli wrote:

> > Look at the patches. They add synchronization to pte operations.
>
> The whole point is that it's fundamentally unavoidable and not
> specific to any of split_huge_page, compound_lock or
> get_page/put_page!

Really? Why did no one else run into this before?

> Problem with O_DIRECT is that I couldn't use mmu notifier to prevent
> it to take the pin on the page, because there is no way to interrupt
> DMA synchronously before mmu_notifier_invalidate_* returns... So I had
> to add compound_lock and keep gup API backwards compatible and have
> the proper serialization happen _only_ for PageTail inside put_page.

You can take a refcount *before* breaking up a 2M page then you dont have
to fear the put_page.

> > What is wrong with gup and gup_fast? They mimick the traversal of the page
> > tables by the MMU. If you update in the right sequence then there wont be
> > an issue.
>
> gup and gup_fast (if we don't split_huge_page during the follow_page
> pagtable walk which is what I did initially to start but it's
> unacceptable as it makes O_DIRECT with -drive cache=off split guest
> NPT hugepages on the I/O memory source/destination) will prevents
> split_huge_page to be able to adjust the refcount of the subpages,
> unless we serialize put_page against split_huge_page and we keep track
> of the individual gup refcounts on the subpages. Which is what
> the compound_lock and the get_page/put_page changes achieve in a self
> contained manner without spreading all over the drivers and the VM.

Keep a reference count in the head page and a pointer to the subpage? Page
can only be broken up if all page references of the 2M page can be
accounted for. This implies no "atomic" breakup but this way it does not
require changes to synchronization.

> > Its pretty bold to call this patchset non-intrusive. Not sure why you
> > think you have to break gup. Certainly works fine for page migration.
>
> page migration won't convert a compound page to a not compound page in
> the page structure in place. this is not page migration, this is about
> converting a page structure from PageCompound to not-page
> compound. It's all trivial on the pagetable side, what is not trivial
> is the refcounting created by GUP. The gup caller, at any later time
> will call put_page on a random subpage, so we've to adjust the
> refcount for subpages inside __split_huge_page_refcount, depending on
> which tailpage was returned by gup.

Its the same principle: Account for all the references, stop new
references from being established and then replace the page / convert
references.

> Migration will bail out if gup is running. split_huge_page basic
> design is that it can't fail. So it can't bail out. And we don't want
> to call split_huge_page during follow_page before gup returns the
> page. That would also solve it, I did it initially but it's
> unacceptable to split hugepages across GUP.

That is the basic crux here. Do not require that it cannot fail. Its a bad
move and results in a mess.

> It's definitely zero risk if compared to what you're proposing.

No its not. I am proposing to *keep* the existing syncronization methods.
Use what is there. Do not invent new synchronization.

> > You can convert a 2M page to 4k pages without messing up the
> > basic refcounting and synchronization by following the way things are done
> > in other parts of the kernel.
>
> No other place of the kernel does anything remotely comparable to
> split_huge_page.

Page migration does a comparable thing.

> defrag, migration they all can fail, split_huge_page cannot. The very
> simple reason split_huge_page cannot fail is this: if I have to do
> anything more than a one liner to make mremap, mprotect and all the
> rest, then I prefer to take your non-practical more risky design. The
> moment you have to alter some very inner pagetable walking function to
> handle a split_huge_page error return, you'll already have to recraft
> the code in a big enough way, that you better make it hugepage
> aware. Making it hugepage aware is like 10 times more difficult and
> error prone and hard to test, than handling a split_huge_page error
> retval, but still in 10 files fixed for the error retval, will be
> worth 1 file converted not to call split_huge_page at all. That
> explains very clearly my decision to make split_huge_page not fail,
> and make sure all next efforts will be spent in removing
> split_huge_page and not in handling an error retval for a function
> that shouldn't have been called in the first place!

We already have 2M pmd handling in the kernel and can consider huge pmd
entries while walking the page tables! Go incrementally use what
is there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
