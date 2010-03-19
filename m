Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 88ADA6B0047
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 10:52:27 -0400 (EDT)
Date: Fri, 19 Mar 2010 15:41:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
Message-ID: <20100319144101.GB29874@random.random>
References: <patchbomb.1268839142@v2.random>
 <alpine.DEB.2.00.1003171353240.27268@router.home>
 <20100318234923.GV29874@random.random>
 <alpine.DEB.2.00.1003190812560.10759@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003190812560.10759@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 19, 2010 at 08:29:30AM -0500, Christoph Lameter wrote:
> On Fri, 19 Mar 2010, Andrea Arcangeli wrote:
> 
> > There is no change at all to pte management related to this. Please
> > stick to facts.
> 
> Look at the patches. They add synchronization to pte operations.

The whole point is that it's fundamentally unavoidable and not
specific to any of split_huge_page, compound_lock or
get_page/put_page!

Yes I've to sometime take the page_table_lock (only when pmd is huge,
and that is a lockless check, so it's just 1 more branch from a
cacheline guaranteed guaranteed already in l1 hot cache in turn
definitely unmeasurable in microbenchmarks too) but even if we remove
split_huge_page completely you will still have to take a lock, and it
can't be the PT lock. The PT lock is indexed on the pte, and the pte
doesn't exist if the pmd is huge! It's not new locking at all, it's
just that when the pmd is huge we've to serialize the thread
concurrent modifications to it, with something less granular than the
PT lock because it doesn't exist for huge pmd...

Yes sure, we can later add a PMD lock that works like the PT lock does
today (with PT lock I mean the pte_offset_map_lock). When there is no
pte that lock doesn't exist, that's all about it.

It's misleading at the very least, to blame on split_huge_page for the
fact I had to make the pte mandling any more complex. The very same
page_table_lock and pmd_huge checks were there, well before I had to
modify put_page and add the compound_lock. Initially gup was calling
split_huge_page, so there was no need of compound_lock, but we need
O_DIRECT with virtualization, O_DIRECT is an absolute must and we
can't split pages across it.

With mmu notifier users (like KVM page fault), I could trivially avoid
having to introduce compound_lock while still preventing them having
to call split_huge_page in gup, by adding a gup_foll(foll_flags)
without FOLL_GET set, which would avoid them wasting time taking
refcounts on any page. With mmu notifier it's a total waste to pin
pages (well xpmem does some trick to try to avoid flushing secondary
ptes and secondary tlbs synchronously but that has other issues and
it's not what KVM and GRU are doing, so KVM and GRU would definitely
get a microoptimization from a gup_variant that won't get_page at
all!). In addition to avoiding the need of compound_lock.

Problem with O_DIRECT is that I couldn't use mmu notifier to prevent
it to take the pin on the page, because there is no way to interrupt
DMA synchronously before mmu_notifier_invalidate_* returns... So I had
to add compound_lock and keep gup API backwards compatible and have
the proper serialization happen _only_ for PageTail inside put_page.

> > What you're commenting is the "compound_lock" and the change to two
> > functions only: get_page and put_page (put_page has to serialize
> > against split_huge_page_refcount and it uses the "compound_lock"
> > per-head-page bit spinlock to achieve it), and this change only
> > applies to TailPages and won't add any overhead to the fast path for
> > non-compound pages and no change for PageHead pages either.
> 
> These are bloating inline VM primitives and add new twists on
> syncronization of pages. They add useless complexity at a very fundamental
> layer of the VM.

Useless? I think I already explained why compound_lock is _useful_ and
what we gain from it (avoid breaking every gup user out there and/or
avoid removing split_huge_page in turn avoiding breaking every piece
of VM code that walks pagetables out there, in turn making transparent
hugepage self contained and possible to introduce ""_gradually_
starting from anonymous memory"" like you said was good idea at the
end of in previous email).

> > The only thing that tries to run get_page or put_page on a TailPage is
> > gup and gup_fast. Nothing else. And it's mostly needed to avoid
> > altering gup_fast/gup API while still preventing to split hugepages
> > across GUP. The reason why I went to this extra-length to be backwards
> > compatible with gup/gup-fast is to avoid the patch to escalate from
> > <40 patches to maybe >100 or more.
> 
> What is wrong with gup and gup_fast? They mimick the traversal of the page
> tables by the MMU. If you update in the right sequence then there wont be
> an issue.

gup and gup_fast (if we don't split_huge_page during the follow_page
pagtable walk which is what I did initially to start but it's
unacceptable as it makes O_DIRECT with -drive cache=off split guest
NPT hugepages on the I/O memory source/destination) will prevents
split_huge_page to be able to adjust the refcount of the subpages,
unless we serialize put_page against split_huge_page and we keep track
of the individual gup refcounts on the subpages. Which is what
the compound_lock and the get_page/put_page changes achieve in a self
contained manner without spreading all over the drivers and the VM.

> > It's troublesome enough already to merge this right now in this
> > non-intrusive <40 patches fully backwards compatible form, you got to
> > think how I could merge this if I went ahead and break everything in
> > gup.
> 
> Its pretty bold to call this patchset non-intrusive. Not sure why you
> think you have to break gup. Certainly works fine for page migration.

page migration won't convert a compound page to a not compound page in
the page structure in place. this is not page migration, this is about
converting a page structure from PageCompound to not-page
compound. It's all trivial on the pagetable side, what is not trivial
is the refcounting created by GUP. The gup caller, at any later time
will call put_page on a random subpage, so we've to adjust the
refcount for subpages inside __split_huge_page_refcount, depending on
which tailpage was returned by gup.

> This implies that the current page migration approaches are broken? The
> simple solution here is not to convert the page if there is a unresolved
> reference. You are only in this bind because you insists on an "atomic"
> conversion between 2M and 4k pages instead of using the existing code that
> tracks down references to pages etc.

Migration will bail out if gup is running. split_huge_page basic
design is that it can't fail. So it can't bail out. And we don't want
to call split_huge_page during follow_page before gup returns the
page. That would also solve it, I did it initially but it's
unacceptable to split hugepages across GUP.

> Then why introdoce the crap in the first place! Get rid of your
> fixation on atomic splitting of huge pages.

It's not fixation, it's about trying to merge <40 patches compounding
to 5000 lines of code, and being able to verify their correctness for
the reviewers. And later expand in more places, starting from remap
and mprotect. While already getting total benefit in the workload that
benefits most from hugepages!

If you can't see the _huge_ value of it, it's pointless to keep
discussing this. I guess if it was you the 2.0 kernel maintainer,
lock_kernel would have never happened... or maybe you would have
designed a CPU back in 1995 to run at 2ghz on 45nm technology.

Developments of technology happens _gradually_. Pretending an huge
step forward that may take years before it can go productive because
it requires so much manpower to audit and verify its correctness and
nail down the bugs and bisect where the crash comes from, is
unrealistic and it's not how things happens here. Sure if you've to
build a bridge you are forced to go to the final stage immediately
because it can't be changed ever again. But for us it's different and
not taking advantage of being able to edit the code, and using the
same engineering approach you would take while building a bridge,
looks silly to me.

> > But while this suggestion of yours totally misses the point of why
> > split_huge_page, that this to avoid sending a patchset that is hugely
> > bigger in size and much harder to audit and merge without much risk,
> > than what I sent.
> 
> Messing around with the basic refcounting and VM primitives is no risk?

It's definitely zero risk if compared to what you're proposing.

> > > Transparent huge page support better be introduced gradually starting f.e.
> > > with the support of 2M pages for anonymous pages.
> >
> > "introduced gradually starting with the support of 2M pages for
> > anonymous pages" is exactly what my patch does. What you're suggesting
> > in the previous part of the email is the opposite!
> 
> That support is possible without refcounts on tail pages and all the other
> syncronization twiddles.

It's possible only if gup calls split_huge_page or if we change the
gup api (i.e. if we change every single put_page that releases a pin
taken by gup). Just identifying the put_page will be a tremendous
error-prone pain. It's real pity that we didn't:

#define put_gup_page(page) put_page(page)

and require the gup users to use that instead of raw put_page. That
would have allowed to reasonably identify the gup users. In fact I
considered trying to find all put_page that released a gup pin
initially, try that yourself... I recommend to start with direct-io.c.

They tried it to fix the race between fork and O_DIRECT by identifying
the put_page pin release points and that resulted in crashes and no
patch has been merged so far to fix it.

I think that is a race that is much better fixed in the core, as the
locking is more scalar in the core. I still value a lot to identify
all put_page that releases gup pins, so that shall happen regardless
of how we eventually fix the race between fork and O_DIRECT, I'm
saying it here just to proof how not trivial and error prone that task
is. Not remotely comparable to the few liner change to get_page/put_page.

> > Handling hugepages natively everywhere and removing both compound_lock
> > and split_huge_page would then require the swapcache to handle 2M
> > pages. swapcache is sharing 100% of pagecache code so then pagecache
> > would need to handle 2M pages natively too. Hence the moment we remove
> > the split_huge_page and the moment we require swapcache to handle 2M
> > natively without splitting the hugepage first like my patch does, the
> > whole thing escalates way beyond anonymous pages, like you seem to
> > agree that it's a good idea to start with.
> 
> You can convert a 2M page to 4k pages without messing up the
> basic refcounting and synchronization by following the way things are done
> in other parts of the kernel.

No other place of the kernel does anything remotely comparable to
split_huge_page.

> As far as I can tell there is no need for large scale patches as you
> suggest. In fact it seems that the patches would be much smaller if
> you would use the existing code that deals with page movement. Have a look
> at Mel's defragmentation patches?

defrag, migration they all can fail, split_huge_page cannot. The very
simple reason split_huge_page cannot fail is this: if I have to do
anything more than a one liner to make mremap, mprotect and all the
rest, then I prefer to take your non-practical more risky design. The
moment you have to alter some very inner pagetable walking function to
handle a split_huge_page error return, you'll already have to recraft
the code in a big enough way, that you better make it hugepage
aware. Making it hugepage aware is like 10 times more difficult and
error prone and hard to test, than handling a split_huge_page error
retval, but still in 10 files fixed for the error retval, will be
worth 1 file converted not to call split_huge_page at all. That
explains very clearly my decision to make split_huge_page not fail,
and make sure all next efforts will be spent in removing
split_huge_page and not in handling an error retval for a function
that shouldn't have been called in the first place!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
