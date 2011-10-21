Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 54A716B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 11:56:43 -0400 (EDT)
Date: Fri, 21 Oct 2011 17:56:32 +0200
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111021155632.GD4082@suse.de>
References: <201110122012.33767.pluto@agmk.net>
 <alpine.LSU.2.00.1110131547550.1346@sister.anvils>
 <alpine.LSU.2.00.1110131629530.1410@sister.anvils>
 <20111016235442.GB25266@redhat.com>
 <CAPQyPG69WePwar+k0nhwfdW7vv7FjqJBYwKfYm7n5qaPwS-WgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPQyPG69WePwar+k0nhwfdW7vv7FjqJBYwKfYm7n5qaPwS-WgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Thu, Oct 20, 2011 at 05:11:28PM +0800, Nai Xia wrote:
> On Mon, Oct 17, 2011 at 7:54 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > On Thu, Oct 13, 2011 at 04:30:09PM -0700, Hugh Dickins wrote:
> >> mremap's down_write of mmap_sem, together with i_mmap_mutex/lock,
> >> and pagetable locks, were good enough before page migration (with its
> >> requirement that every migration entry be found) came in; and enough
> >> while migration always held mmap_sem.  But not enough nowadays, when
> >> there's memory hotremove and compaction: anon_vma lock is also needed,
> >> to make sure a migration entry is not dodging around behind our back.
> >
> > For things like migrate and split_huge_page, the anon_vma layer must
> > guarantee the page is reachable by rmap walk at all times regardless
> > if it's at the old or new address.
> >
> > This shall be guaranteed by the copy_vma called by move_vma well
> > before move_page_tables/move_ptes can run.
> >
> > copy_vma obviously takes the anon_vma lock to insert the new "dst" vma
> > into the anon_vma chains structures (vma_link does that). That before
> > any pte can be moved.
> >
> > Because we keep two vmas mapped on both src and dst range, with
> > different vma->vm_pgoff that is valid for the page (the page doesn't
> > change its page->index) the page should always find _all_ its pte at
> > any given time.
> >
> > There may be other variables at play like the order of insertion in
> > the anon_vma chain matches our direction of copy and removal of the
> > old pte. But I think the double locking of the PT lock should make the
> > order in the anon_vma chain absolutely irrelevant (the rmap_walk
> > obviously takes the PT lock too), and furthermore likely the
> > anon_vma_chain insertion is favorable (the dst vma is inserted last
> > and checked last). But it shouldn't matter.
> 
> I happened to be reading these code last week.
> 
> And I do think this order matters, the reason is just quite similar why we
> need i_mmap_lock in move_ptes():
> If rmap_walk goes dst--->src, then when it first look into dst, ok, the

You might be right in that the ordering matters. We do link new VMAs at
the end of the list in anon_vma_chain_list so remove_migrate_ptes should
be walking from src->dst.

If remove_migrate_pte finds src first, it will remove the pte and the
correct version will get copied. If move_ptes runs between when
remove_migrate_ptes moves from src to dst, then the PTE at dst will
still be correct.

> pte is not there, and it happily skip it and release the PTL.
> Then just before it look into src, move_ptes() comes in, takes the locks
> and moves the pte from src to dst. And then when rmap_walk() look
> into src,  it will find an empty pte again. The pte is still there,
> but rmap_walk() missed it !
> 

I believe the ordering is correct though and protects us in this case.

> IMO, this can really happen in case of vma_merge() succeeding.
> Imagine that src vma is lately faulted and in anon_vma_prepare()
> it got a same anon_vma with an existing vma ( named evil_vma )through
> find_mergeable_anon_vma().  This can potentially make the vma_merge() in
> copy_vma() return with evil_vma on some new relocation request. But src_vma
> is really linked _after_  evil_vma/new_vma/dst_vma.
> In this way, the ordering protocol  of anon_vma chain is broken.
> This should be a rare case because I think in most cases
> if two VMAs can reusable_anon_vma() they were already merged.
> 
> How do you think  ?
> 

Despite the comments in anon_vma_compatible(), I would expect that VMAs
that can share an anon_vma from find_mergeable_anon_vma() will also get
merged. When the new VMA is created, it will be linked in the usual
manner and the oldest->newest ordering is what is required. That's not
that important though.

What is important is if mremap is moving src to a dst that is adjacent
to another anon_vma. If src has never been faulted, it's not an issue
because there are also no migration PTEs. If src has been faulted, then
is_mergeable_anon_vma() should fail as anon_vma1 != anon_vma2 and they
are not compatible. The ordering is preserved and we are still ok.

All that said, while I don't think there is a problem, I can't convince
myself 100% of it. Andrea, can you spot a flaw?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
