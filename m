Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C1E7C6B01F0
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 11:54:30 -0400 (EDT)
Date: Sat, 28 Aug 2010 17:54:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
Message-ID: <20100828155418.GN6803@random.random>
References: <AANLkTikvB1fN42A91ZdEHyEXnz2bGw9Q21dJcfa3PBP0@mail.gmail.com>
 <alpine.DEB.2.00.1008271159160.18495@router.home>
 <AANLkTi=FeHnLu4_6M5N6yUL==4YyxVXXxsccsE2kNUbm@mail.gmail.com>
 <alpine.DEB.2.00.1008271420400.18495@router.home>
 <AANLkTinLpDnpwr40dtU5UFq53avODSKxTA4=xnZwmJFX@mail.gmail.com>
 <alpine.DEB.2.00.1008271547200.22988@router.home>
 <AANLkTim16oT13keYK_oz=7kmDmdG=ADfkGXMKp3_dEw_@mail.gmail.com>
 <AANLkTikML=HghpOVK0WZ0t6CRaNOKvu=57ebojZ+YCNS@mail.gmail.com>
 <alpine.DEB.2.00.1008271801080.25115@router.home>
 <AANLkTindjNiJXbfsWbFexXBQVB174aprhSbBLFosBvC=@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTindjNiJXbfsWbFexXBQVB174aprhSbBLFosBvC=@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Lameter <cl@linux.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 06:07:23PM -0700, Hugh Dickins wrote:
> __page_set_anon_rmap() looks like it might have changed anon
> page->mapping in 2.6.35, but Andrea has fixed that with PageAnon tests
> in 2.6.36-rc.  Ah, but what if "exclusive" and non-exclusive calls to
> __page_set_anon_rmap() are racing?  Not clear, it may be that Andrea

__page_set_anon_rmap doesn't require the PG_lock only if it's a newly
allocated page and it is called from page_add_new_anon_rmap. So there
cannot be concurrent __page_set_anon_rmap running on the same page. If
there could be concurrent __page_set_anon_rmap running on the same
page, the page_lock_anon_vma running on a changing page->mapping would
be the last worry, as page_add_new_anon_rmap would overwrite _mapcount
with 0 while do_page_add_anon_rmap runs, so corrupting the mapcount
information leading to immediate crash during page freeing....

So definitely it must not happen and not only because of
page_lock_anon_vma... and it's unlikely to go unnoticed.

I think we're safe on that respect.

> has only narrowed a window not closed it (and I've not yet looked up
> the commit to see his intent); or it may be okay, that there cannot be
> a conflict of anon_vma in that case.  Need to dig deeper.

That change is to avoid altering the page->mapping for anon
pages. It's only an optimization. No need to set the page->mapping
back to the anon_vma->root for AnonPages (that in turn have already
their page->mapping set) if we've already more finegrained information
into the page->mapping. If we've already information in page->mapping
(page is Anon) then setting to anon_vma->root can only be a coarser
setting losing anon_vma child granularity. We must set to the root
anon vma however when the page is swapcache but not anon yet... and if
it's not exclusive we've to use the anon_vma->root, otherwise if it's
being taken over by the local process we can use the local
vma->anon_vma. This should explain the logic in __set_page_anon_rmap.

> __hugepage_set_anon_rmap() appears to copy the 2.6.35
> __page_set_anon_rmap(), and probably needs to add in Andrea's fix, or
> whatever else is needed there.

I think it's actually safe in anon_vma terms, setting the
page->mapping to the anon_vma->root _always_ safe, but it should use
anon_vma->root instead of list_entry (should still lead to the same
result) and it can probably also optimize it if it's already an
AnonPage like I did for the not-hugetlbfs case (which also includes
transparent hugepages as they share the core VM paths).

The lack of BUG_ON(!PageLocked(page)) in the hugetlb_add_anon_rmap is
worth fixing...

hugepage_add_new_anon_rmap runs lock_page before so most certainly is
ok (maybe lock_page not needed if it's a new page?).

hugepage_add_anon_rmap seems to run on a local new page too (just
cowed) so I'm unsure why it's not using hugepage_add_new_anon_rmap too
and maybe it's safe without the PG_lock too, but it should use
hugepage_add_new_anon_rmap so we keep the same logic of the core VM.

I didn't spend too much on this hugetlbfs code, this is just a short
review.

> switch of anon_vma beneath us there.   Plus a
> VM_BUG_ON(PageLocked(page)) going into page_lock_anon_vma().

!PageLocked

Ok I think the concurrent writers of page->mapping needs the PG_lock
(unless they're working on the newly allocated page like
page_add_new_anon_rmap) but I really like page_lock_anon_vma to be
safe without PG_lock and to rely only on RCU and the anon_vma lock. Do
you think there's a window there? I think as long as the page is
mapped it doesn't matter... any change that can happen from under us
in page_lock_anon_vma, is still going to point to a valid anon_vma, if
it is reused it can be reused regardless if it's the root or the local
one and we've your fix to take care of that complexity of slab RCU
freeing behavior.

I need to think again and more deeply about page_lock_anon_vma running
on a page not locked, but I was convinced it was safe and that only
the writers needed the PG_lock (and even for the writers case, I think
it is mostly needed for other reasons, notably to keep the mapcount
coherent!). Yeah the write to page->mapping has to be atomic of course
(I actually checked every page->mapping writer in mm/rmap.c to verify
the gcc output to verify it is atomic, like we also relay on gcc to
write 64bit atomic for the pte/spte writes... I worried a little about
the |=1 but gcc is smart enough to do it in registers before writing
to memory, again not so different from the pte updates ;).

My reasoning is that any anon_vma we pick in page_lock_anon_vma is ok
(the root or intermediate one can't go away until the local one goes
away, if it's the local one it can't go away as long as the page is
mapped). So as long as the page->mapping writer writes atomic, and we
check page_mapped after taking the lock like your patch does, we
should be ok without PG_lock in page_lock_anon_vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
