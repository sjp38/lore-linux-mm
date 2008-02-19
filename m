Date: Tue, 19 Feb 2008 02:42:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: scalable vmaps
Message-ID: <20080219014203.GB21165@wotan.suse.de>
References: <20080218082219.GA2018@wotan.suse.de> <47B94FF7.3030200@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47B94FF7.3030200@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andi Kleen <ak@suse.de>, David Chinner <dgc@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2008 at 08:29:27PM +1100, Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> >One thing that will be common to any high performance vmap implementation,
> >however, will be the use of lazy TLB flushing. So I'm mainly interested
> >in comments about this. AFAIK, Xen must be able to eliminate these aliases
> >on demand,
> 
> Yep.
> 
> > and CPA also doesn't want aliases around even if they don't
> >get explicitly referenced by software (because the hardware may do a
> >random speculative operation through the TLB).
> >  
> 
> Yes, but presumably the page is in a "normal" state before CPA changes 
> its cache attributes; it can shoot down aliases before doing that.

Oh yeah sure, it is easy to do, but it just can seem a little strange,
because we _never_ subsequently access the page through its alias anyway.
But yeah it is no problem to shoot it down before changing attributes.

 
> >So I just wonder if it is enough to provide a (quite heavyweight) function
> >to flush aliases? (vm_unmap_aliases)
> >  
> 
> Assuming that aliased pages are relatively rare, then its OK for this 
> function to be heavyweight if it can exit quickly in the non-aliased 
> case (or there's some other cheap way to tell if a page has aliases).  
> Hm, even then, Xen would only need to call this on pages being turned 
> into parts of a pagetable, so probably not all that often.  So, if its 
> easy to avoid vm_unmap_aliases we would do so, but it's probably worth 
> profiling before going to heroic efforts.

There is no easy way to tell if a page is aliased. We can't really use a
page bit, because we don't own the page, so we can't manipulate flags.
We could store an rmap somehow, but I'd really prefer not to add such
overhead if it is at all possible to minimise vm_unmap_aliases to the
point where it doesn't matter.

Are we using quicklists in x86? Then we'd only have to call this when
new pages are allocated to the quicklist, presumably? Anyway let's wait
and see if it hurts. (at the worst case, it is not going to be much
more expensive than the existing vmalloc, but I guess you might start
noticing if we start using vmaps more).

 
> >Also, what consequences will this have for non-paravirtualized Xen? If
> >any, do we care? (IMO no) I'm not going to take references on these
> >lazy flush pages, because that will increase VM pressure by a great deal.
> >  
> 
> Not sure what you mean here.  Unparavirtualized Xen would just use 
> shadow pagetables, and be effectively the same as kvm as far as the 
> kernel is concerned (unless there's some subtle difference I'm missing).

Oh, that's fine then (I don't know much about this topic). I had just
assumed that the hypervisor would try the same trick so long as the
guest did not try to insert pagetables with aliases.

Thanks for the input.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
