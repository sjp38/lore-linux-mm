From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc][patch] mm: dirty page accounting hole
Date: Tue, 12 Aug 2008 17:06:26 +1000
References: <200808121558.40130.nickpiggin@yahoo.com.au> <1218523840.10800.129.camel@twins>
In-Reply-To: <1218523840.10800.129.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808121706.26686.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, "Dickins, Hugh" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 12 August 2008 16:50, Peter Zijlstra wrote:
> On Tue, 2008-08-12 at 15:58 +1000, Nick Piggin wrote:
> > Hi,
> >
> > I think I'm running into a hole in dirty page accounting...
> >
> > What seems to be happening is that a page gets written to via a
> > VM_SHARED vma. We then set the pte dirty, then mark the page dirty.
> > Next, mprotect changes the vma so it is no longer writeable so it
> > is no longer VM_SHARED. The pte is still dirty.
> >
> > Then clear_page_dirty_for_io is called and leaves that pte dirty
> > and cleans the page. It never gets cleaned until munmap, so msync
> > and writeout accounting are broken.
> >
> > I have a fix which just scans VM_SHARED to VM_MAYSHARE. The other
> > way I tried is to clear the dirty and write bits and set the page
> > dirty in mprotect. The problem with that for me is that I'm trying
> > to rework the vm/fs layer so we never have to allocate data to
> > write out dirty pages (using page_mkwrite and dirty accounting),
>
> Ooh, nice!

Thanks for confirming.


> > and so this still leaves me with a window where the vma flags are
> > changed but before the pte is marked clean, in which time the page
> > is still dirty but it may have its metadata freed because it
> > doesn't look dirty.
> >
> > There are several other problems I've also run into, including a
> > fundamentally indadequate page_mkwrite locking scheme, which was
> > naturally ignored when I brought it up during reviewing those
> > patches. I digress...
>
> Yes, I remember you bringing that up, and later too when you did those
> fault patches. I assumed you were 'working' on it.

Oh that wasn't aimed at you, sorry ;) It is our general... "process"
of development. I mean, there is apparently some impending apocolypse
due to our scarcity of review bandwidth, so ignoring any review is
by definition insignificant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
