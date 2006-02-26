Date: Sun, 26 Feb 2006 04:42:52 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Feb 2006, Hugh Dickins wrote:
> On Fri, 24 Feb 2006, Christoph Lameter wrote:
> 
> > Any reason that this function is checking for a mapped page? There could
> > be references through a swap pte to the page. The looping in
> > remove_from_swap, page_referenced_anon and try_to_unmap anon would 
> > work even if the check for a mapped page would be removed.
> > 
> > I have sent the patch below today to Hugh Dickins but did not receive an 
> > answer. Probaby requires some discussion.
> 
> Good question, and I was on the point of answering that it's just a
> racy micro-optimization that you could eliminate.  But now I think
> that answer is wrong.  It's actually an essential part of the tricky
> business of getting from the struct page to the anon_vma lock, when
> there's a danger that the anon_vma and even its slab may be recycled
> at any instant (remember that we have to leave the anon page->mapping
> set even after the last page_remove_rmap, with comment there on that).
> If the page is not found mapped under the rcu_read_lock, then there's
> no guarantee that the anon_vma memory hasn't already been freed and
> its slab page destroyed, and recycled for other purposes completely.
> 
> I'll have to come back to this, and think it through more carefully: I
> might arrive at the opposite conclusion with more thought this evening.

I still believe the page_mapped test is essential for the correctness
of the original page_referenced_anon and try_to_unmap_anon cases (but
please don't ask me to reproduce the case it's guarding against!).
But disastrous for the remove_from_swap case you've added -
how does that work at all with the page_mapped test in?

I'm not sure whether testing page_mapcount+page_swapcount (as used by
can_share_swap_page) would help remove_from_swap; certainly it would
be pointless and better avoided by page_referenced and try_to_unmap.

But I think you can avoid it.  It looks to me like the mmap_sem of
an mm containing the pages is held across migrate_pages?  That should
be enough to guarantee that the anon_vmas involved cannot be freed
behind your back (whereas page_referenced and try_to_unmap are called
without any mmap_sem held).  So you'd want to add a new flag to
page_lock_anon_vma, to condition whether page_mapped is checked.

Though I'm not yet certain that that won't have races of its own:
please examine it sceptically.  And is it actually guaranteed that
a relevant mmap_sem is held here?  Why on earth does vmscan.c contain
EXPORT_SYMBOLs of migrate_page_remove_references, migrate_page_copy,
migrate_page?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
