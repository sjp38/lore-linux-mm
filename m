From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc][patch] mm: dirty page accounting hole
Date: Tue, 12 Aug 2008 21:53:45 +1000
References: <200808121558.40130.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0808121210250.31744@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0808121210250.31744@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808122153.46144.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 12 August 2008 21:15, Hugh Dickins wrote:
> On Tue, 12 Aug 2008, Nick Piggin wrote:
> > I think I'm running into a hole in dirty page accounting...
> >
> > What seems to be happening is that a page gets written to via a
> > VM_SHARED vma. We then set the pte dirty, then mark the page dirty.
> > Next, mprotect changes the vma so it is no longer writeable so it
> > is no longer VM_SHARED. The pte is still dirty.
>
> I don't think you've got that right yet.
>
> mprotect can of course change vma->vm_flags to take VM_WRITE off,
> making vma no longer writeable; but it shouldn't be touching
> VM_SHARED.  And a quick check with debugger confirms that.

Drat, yes, I must have been thinking of VM_WRITE vs VM_MAYWRITE.


> It's precisely because of mprotect that page_mkclean_one tests
> VM_SHARED not VM_WRITE.  Changing that to VM_MAYSHARE, as in your
> patch below, should make no difference to correctness; but would
> potentially make its loop less efficient (it would also go off to
> check MAP_SHARED, PROT_READ, fd readonly mappings unnecessarily).
>
> Perhaps there's somewhere else that clears VM_SHARED by mistake?
> Or another path through mprotect which does so?  I haven't checked
> further, hoping this will jolt you into a different realization.

Will have to dig further... Thanks for the tip.

> > Then clear_page_dirty_for_io is called and leaves that pte dirty
> > and cleans the page. It never gets cleaned until munmap, so msync
> > and writeout accounting are broken.
> >
> > I have a fix which just scans VM_SHARED to VM_MAYSHARE. The other
> > way I tried is to clear the dirty and write bits and set the page
> > dirty in mprotect. The problem with that for me is that I'm trying
> > to rework the vm/fs layer so we never have to allocate data to
> > write out dirty pages (using page_mkwrite and dirty accounting),
> > and so this still leaves me with a window where the vma flags are
> > changed but before the pte is marked clean, in which time the page
> > is still dirty but it may have its metadata freed because it
> > doesn't look dirty.
>
> While I disagree with the patch itself, and don't understand the
> details of what you're working on there, I certainly agree that it's
> better for mprotect not to set the pages dirty: at present (on some
> arches, in most cases? it changes from time to time) change_pte_range
> is an operation on ptes which doesn't have to mess with struct pages.

Right. For me, it gets a bit messy because we'd really like to hold the
page lock there (like clear_page_dirty_for_io) in order to be able to get
reasonable synchronization between page faults and pte cleaning...


> > There are several other problems I've also run into, including a
> > fundamentally indadequate page_mkwrite locking scheme, which was
> > naturally ignored when I brought it up during reviewing those
> > patches. I digress...
>
> Unsatisfactory, yes, sorry about that;
> but no, you're not "naturally ignored".
>
> > Anyway, here's a patch to fix this first particular issue...
>
> Could you please go back to inlining your patches?

OK I'll try.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
