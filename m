Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2310D6B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 13:41:32 -0400 (EDT)
Date: Fri, 21 Oct 2011 19:41:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111021174120.GJ608@redhat.com>
References: <201110122012.33767.pluto@agmk.net>
 <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <alpine.LSU.2.00.1110131629530.1410@sister.anvils>
 <20111016235442.GB25266@redhat.com>
 <CAPQyPG69WePwar+k0nhwfdW7vv7FjqJBYwKfYm7n5qaPwS-WgQ@mail.gmail.com>
 <20111021155632.GD4082@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20111021155632.GD4082@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nai Xia <nai.xia@gmail.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Oct 21, 2011 at 05:56:32PM +0200, Mel Gorman wrote:
> On Thu, Oct 20, 2011 at 05:11:28PM +0800, Nai Xia wrote:
> > On Mon, Oct 17, 2011 at 7:54 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > > On Thu, Oct 13, 2011 at 04:30:09PM -0700, Hugh Dickins wrote:
> > >> mremap's down_write of mmap_sem, together with i_mmap_mutex/lock,
> > >> and pagetable locks, were good enough before page migration (with its
> > >> requirement that every migration entry be found) came in; and enough
> > >> while migration always held mmap_sem.  But not enough nowadays, when
> > >> there's memory hotremove and compaction: anon_vma lock is also needed,
> > >> to make sure a migration entry is not dodging around behind our back.
> > >
> > > For things like migrate and split_huge_page, the anon_vma layer must
> > > guarantee the page is reachable by rmap walk at all times regardless
> > > if it's at the old or new address.
> > >
> > > This shall be guaranteed by the copy_vma called by move_vma well
> > > before move_page_tables/move_ptes can run.
> > >
> > > copy_vma obviously takes the anon_vma lock to insert the new "dst" vma
> > > into the anon_vma chains structures (vma_link does that). That before
> > > any pte can be moved.
> > >
> > > Because we keep two vmas mapped on both src and dst range, with
> > > different vma->vm_pgoff that is valid for the page (the page doesn't
> > > change its page->index) the page should always find _all_ its pte at
> > > any given time.
> > >
> > > There may be other variables at play like the order of insertion in
> > > the anon_vma chain matches our direction of copy and removal of the
> > > old pte. But I think the double locking of the PT lock should make the
> > > order in the anon_vma chain absolutely irrelevant (the rmap_walk
> > > obviously takes the PT lock too), and furthermore likely the
> > > anon_vma_chain insertion is favorable (the dst vma is inserted last
> > > and checked last). But it shouldn't matter.
> > 
> > I happened to be reading these code last week.
> > 
> > And I do think this order matters, the reason is just quite similar why we
> > need i_mmap_lock in move_ptes():
> > If rmap_walk goes dst--->src, then when it first look into dst, ok, the
> 
> You might be right in that the ordering matters. We do link new VMAs at

Yes I also think ordering matters as I mentioned in the previous email
that Nai answered to.

> the end of the list in anon_vma_chain_list so remove_migrate_ptes should
> be walking from src->dst.

Correct. Like I mentioned in that previous email that Nai answered,
that wouldn't be ok only if vma_merge succeeds and I didn't change my mind
about that...

copy_vma is only called by mremap so supposedly that path can
trigger. Looks like I was wrong about vma_merge being able to succeed
in copy_vma, and if it does I still think it's a problem as we have no
ordering guarantee.

The only other place that depends on the anon_vma_chain order is fork,
and there, no vma_merge can happen, so that is safe.

> If remove_migrate_pte finds src first, it will remove the pte and the
> correct version will get copied. If move_ptes runs between when
> remove_migrate_ptes moves from src to dst, then the PTE at dst will
> still be correct.

The problem is rmap_walk will search dst before src. So it will do
nothing on dst. Then mremap moves the pte from src to dst. When rmap
walk then checks "src" it finds nothing again.

> > pte is not there, and it happily skip it and release the PTL.
> > Then just before it look into src, move_ptes() comes in, takes the locks
> > and moves the pte from src to dst. And then when rmap_walk() look
> > into src,  it will find an empty pte again. The pte is still there,
> > but rmap_walk() missed it !
> > 
> 
> I believe the ordering is correct though and protects us in this case.

Normally it is, the only problem is vma_merge succeeding I think.

> > IMO, this can really happen in case of vma_merge() succeeding.
> > Imagine that src vma is lately faulted and in anon_vma_prepare()
> > it got a same anon_vma with an existing vma ( named evil_vma )through
> > find_mergeable_anon_vma().  This can potentially make the vma_merge() in
> > copy_vma() return with evil_vma on some new relocation request. But src_vma
> > is really linked _after_  evil_vma/new_vma/dst_vma.
> > In this way, the ordering protocol  of anon_vma chain is broken.
> > This should be a rare case because I think in most cases
> > if two VMAs can reusable_anon_vma() they were already merged.
> > 
> > How do you think  ?
> > 

I tried to understand the above scenario yesterday but with 12 hour
of travel on me I just couldn't.

Yesterday however I thought of another simpler case:

part of a vma is moved with mremap elsewhere. Then it is moved back to
its original place. So then vma_merge will succeed, and the "src" of
mremap is now queued last in anon_vma_chain, wrong ordering.

Today I read an email from Nai who showed apparently the same scenario
I was thinking, without evil vmas or stuff.

I have an hard time to imagine a vma_merge succeeding on a vma that
isn't going back to its original place. The vm_pgoff + vma->anon_vma
checks should keep some linarity so going back to the original place
sounds the only way vma_merge can succeed in copy_vma. But still it
can happen in that case I think (so not sure how the above scenario
with an evil_vma could ever happen if it has a different anon_vma and
it's not a part of a vma that is going back to its original place like
in the second scenario Nai also posted about).

That me and Nai had same scenario hypothesis indipendentely (second
Nai hypoteisis not the first quoted above), plus copy_vma doing
vma_merge and being only called by mremap, sounds like it can really
happen.

> Despite the comments in anon_vma_compatible(), I would expect that VMAs
> that can share an anon_vma from find_mergeable_anon_vma() will also get
> merged. When the new VMA is created, it will be linked in the usual
> manner and the oldest->newest ordering is what is required. That's not
> that important though.
> 
> What is important is if mremap is moving src to a dst that is adjacent
> to another anon_vma. If src has never been faulted, it's not an issue
> because there are also no migration PTEs. If src has been faulted, then
> is_mergeable_anon_vma() should fail as anon_vma1 != anon_vma2 and they
> are not compatible. The ordering is preserved and we are still ok.

I was thinking along these lines, the only pitfall should be when
something is moved and put back into its original place. When it is
moved, a new vma is created and queued last. When it's put back to its
original location, vma_merge will succeed, and "src" is now the
previous "dst" so queued last and that breaks.

> All that said, while I don't think there is a problem, I can't convince
> myself 100% of it. Andrea, can you spot a flaw?

I think Nai's correct, only second hypothesis though.

We have two options:

1) we remove the vma_merge call from copy_vma and we do the vma_merge
manually after mremap succeed (so then we're as safe as fork is and we
relay on the ordering). No locks but we'll just do 1 more allocation
for one addition temporary vma that will be removed after mremap
completed.

2) Hugh's original fix.

First option probably is faster and prefereable, the vma_merge there
should only trigger when putting things back to origin I suspect, and
never with random mremaps, not sure how common it is to put things
back to origin. If we're in a hurry we can merge Hugh's patch and
optimize it later. We can still retain the migrate fix if we intend to
take way number 1 later. I didn't like too much migrate doing
speculative access on ptes that it can't miss or it'll crash anyway.

Said that the fix merged upstream is 99% certain to fix things in
practice already so I doubt we're in hurry. And if things go wrong
these issues don't go unnoticed and they shouldn't corrupt memory even
if they trigger. 100% certain it can't do damage (other than a BUG_ON)
for split_huge_page as I count the pmds encountered in the rmap_walk
when I set the splitting bit, and I compare that count with
page_mapcount and BUG_ON if they don't match, and later I repeat the
same comparsion in the second rmap_walk that establishes the pte and
downgrades the hugepmd to pmd, and BUG_ON again if they don't match
with the previous rmap_walk count. It may be possible to trigger the
BUG_ON with some malicious activity but it won't be too easy either
because it's not an instant thing, still a race had to trigger and
it's hard to reproduce.

The anon_vma lock is quite a wide lock as it's shared by all parents
anon_vma_chains too, slab allocation from local cpu may actually be
faster in some condition (even when the slab allocation is
superflous). But then I'm not sure. So I'm not against applying Hugh's
fix even for the long run. I wouldn't git revert the migration change,
but then if we go with Hugh's fix probably it'd be safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
