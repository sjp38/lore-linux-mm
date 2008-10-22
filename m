Date: Wed, 22 Oct 2008 11:29:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081022092901.GC4359@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810200427270.5543@blonde.site> <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org> <200810211356.13191.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810202024150.3287@nehalem.linux-foundation.org> <20081021043338.GA5694@wotan.suse.de> <48FDFC6C.5080606@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48FDFC6C.5080606@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 10:59:40AM -0500, Christoph Lameter wrote:
> Nick Piggin wrote:
> 
> 
> >  	if (!page_mapped(page))
> >  		goto out;
> >  
> >  	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
> 
> Isnt it possible for the anon_vma to be freed and reallocated for another use
> after this statement and before taking the lock?

Yes.


> >  	spin_lock(&anon_vma->lock);
> 
> Then we may take the spinlock on another anon_vma structure not related to
> this page.

Yes.


> > +
> > +	/*
> > +	 * If the page is no longer mapped, we have no way to keep the anon_vma
> > +	 * stable. It may be freed and even re-allocated for some other set of
> > +	 * anonymous mappings at any point. Technically this should be OK, as
> > +	 * we hold the spinlock, and should be able to tolerate finding
> > +	 * unrelated vmas on our list. However we'd rather nip these in the bud
> > +	 * here, for simplicity.
> > +	 *
> > +	 * If the page is mapped while we have the lock on the anon_vma, then
> > +	 * we know anon_vma_unlink can't run and garbage collect the anon_vma:
> > +	 * unmapping the page and decrementing its mapcount happens before
> > +	 * unlinking the anon_vma; unlinking the anon_vma requires the
> > +	 * anon_vma lock to be held. So this check ensures we have a stable
> > +	 * anon_vma.
> > +	 *
> > +	 * Note: the page can still become unmapped, and the !page_mapped
> > +	 * condition become true at any point. This check is definitely not
> > +	 * preventing any such thing.
> > +	 */
> 
> What is this then? An optimization?

As the comment says, it filters out those unrelated anon_vmas. In doing so
it allows us to guarantee the reference with the lock alone (as-per the next
patch). Also just means we don't have to care about that case (even though
it's not technically wrong).


> 
> > +	if (unlikely(!page_mapped(page))) {
> > +		spin_unlock(&anon_vma->lock);
> > +		goto out;
> > +	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
