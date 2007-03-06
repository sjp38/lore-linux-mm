Date: Tue, 6 Mar 2007 02:05:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
Message-ID: <20070306010529.GB23845@wotan.suse.de>
References: <20070305161746.GD8128@wotan.suse.de> <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2007 at 10:14:58AM -0800, Christoph Lameter wrote:
> On Mon, 5 Mar 2007, Nick Piggin wrote:
> 
> > - PageMLock explicitly elevates the page's refcount, so PageMLock pages
> >   don't ever get freed (thus requires less awareness in the rest of mm).
> 
> Which breaks page migration for mlocked pages.

Yeah, the simple way to fix migration is to just clear_page_mlock those
pages so they'll lazily be mlocked again. However we could probably do
something fancier like transferring the PG_mlock bit and the mlock_count.

> I think there is still some thinking going on about also removing 
> anonymous pages off the LRU if we are out of swap or have no swap. In 
> that case we may need page->lru to track these pages so that they can be 
> fed back to the LRU when swap is added later.

That's OK: they won't get mlocked if they are not on the LRU (and won't
get taken off the LRU if they are mlocked).

> I was a bit hesitant to use an additional ref counter because we are here 
> overloading a refcounter on a LRU field? I have a bad feeling here. There 

If we ensure !PageLRU then we can use the lru field. I don't see
a problem.

> are possible race conditions and it seems that earlier approaches failed 
> to address those.

What are they?

> 
> > +static void inc_page_mlock(struct page *page)
> > +{
> > +	BUG_ON(!PageLocked(page));
> > +
> > +	if (!PageMLock(page)) {
> > +		if (!isolate_lru_page(page)) {
> > +			SetPageMLock(page);
> > +			get_page(page);
> > +			set_page_mlock_count(page, 1);
> > +		}
> > +	} else if (PageMLock(page)) {
> 
> You already checked for !PageMlock so PageMlock is true.

Thanks.

> > -	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
> > -			(ptep_clear_flush_young(vma, address, pte)))) {
> > -		ret = SWAP_FAIL;
> > -		goto out_unmap;
> > +	if (!migration) {
> > +		if (vma->vm_flags & VM_LOCKED) {
> > +			ret = SWAP_MLOCK;
> > +			goto out_unmap;
> > +		}
> > +		if (ptep_clear_flush_young(vma, address, pte)) {
> > +			ret = SWAP_FAIL;
> > +			goto out_unmap;
> > +		}
> 
> Ok you basically keep the first patch of my set. Maybe include that 
> explicitly ?

It is a bit different. I don't want to break out as soon as it hits
an mlocked vma, in order to be able to count up all mlocked vmas and
set the correct mlock_count.

Actually there is a race here, because a subsequent munlock could
cause the mlock state to be incorrect. I'll have to fix that.

It looks like your patches suffer from the same race?

> >  /*
> > + * This routine is used to map in an anonymous page into an address space:
> > + * needed by execve() for the initial stack and environment pages.
> 
> Could we have some common code that also covers do_anonymous page etc?

That could be possible, yes. I'd like Hugh to ack that sort of thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
