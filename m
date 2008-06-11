Date: Tue, 10 Jun 2008 21:00:38 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Message-ID: <20080610210038.334c0ad6@bree.surriel.com>
In-Reply-To: <20080606180746.6c2b5288.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.522708682@redhat.com>
	<20080606180746.6c2b5288.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jun 2008 18:07:46 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 06 Jun 2008 16:28:55 -0400
> Rik van Riel <riel@redhat.com> wrote:
> > Originally
> > From: Nick Piggin <npiggin@suse.de>
> > 
> > Against:  2.6.26-rc2-mm1
> > 
> > This patch:
> > 
> > 1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
> >    stub version of the mlock/noreclaim APIs when it's
> >    not configured.  Depends on [CONFIG_]NORECLAIM_LRU.
> 
> Oh sob.

OK, I just removed CONFIG_NORECLAIM_MLOCK.

> > 2) add yet another page flag--PG_mlocked--to indicate that
> >    the page is locked for efficient testing in vmscan and,
> >    optionally, fault path.  This allows early culling of
> >    nonreclaimable pages, preventing them from getting to
> >    page_referenced()/try_to_unmap().  Also allows separate
> >    accounting of mlock'd pages, as Nick's original patch
> >    did.
> > 
> >    Note:  Nick's original mlock patch used a PG_mlocked
> >    flag.  I had removed this in favor of the PG_noreclaim
> >    flag + an mlock_count [new page struct member].  I
> >    restored the PG_mlocked flag to eliminate the new
> >    count field.  
> 
> How many page flags are left? 

Depends on what CONFIG_ZONE_SHIFT and CONFIG_NODE_SHIFT
are set to.

I suspect we'll be able to get rid of the PG_mlocked page
flag in the future, since mlock is just one reason for
the page being PG_noreclaim.

> > +/*
> > + * mlock all pages in this vma range.  For mmap()/mremap()/...
> > + */
> > +extern int mlock_vma_pages_range(struct vm_area_struct *vma,
> > +			unsigned long start, unsigned long end);
> > +
> > +/*
> > + * munlock all pages in vma.   For munmap() and exit().
> > + */
> > +extern void munlock_vma_pages_all(struct vm_area_struct *vma);
> 
> I don't think it's desirable that interfaces be documented in two
> places.  The documentation which you have at the definition site is
> more complete than this, and is at the place where people will expect
> to find it.

I removed these comments.
 
> > +	if (!isolate_lru_page(page)) {
> > +		putback_lru_page(page);
> > +	} else {
> > +		/*
> > +		 * Try hard not to leak this page ...
> > +		 */
> > +		lru_add_drain_all();
> > +		if (!isolate_lru_page(page))
> > +			putback_lru_page(page);
> > +	}
> > +}
> 
> When I review code I often come across stuff which I don't understand
> (at least, which I don't understand sufficiently easily).  So I'll ask
> questions, and I do think the best way in which those questions should
> be answered is by adding a code comment to fix the problem for ever.

        if (!isolate_lru_page(page)) {
                putback_lru_page(page);
        } else {
                /*
                 * Page not on the LRU yet.  Flush all pagevecs and retry.
                 */
                lru_add_drain_all();
                if (!isolate_lru_page(page))
                        putback_lru_page(page);
        }

> If I _am_ right, and if the isolate_lru_page() _did_ fail (and under
> what circumstances?) then...  what?  We now have a page which is on an
> inappropriate LRU?  Why is this OK?  Do we handle it elsewhere?  How?

It is OK because we will run into the page later on in the pageout
code, detect that the page is unevictable and move it to the
unevictable LRU.

> > +/*
> > + * called from munlock()/munmap() path with page supposedly on the LRU.
> > + *
> > + * Note:  unlike mlock_vma_page(), we can't just clear the PageMlocked
> > + * [in try_to_unlock()] and then attempt to isolate the page.  We must
> > + * isolate the page() to keep others from messing with its noreclaim
> 
> page()?

Fixed.

> > + * and mlocked state while trying to unlock.  However, we pre-clear the
> 
> "unlock"?  (See exhasperated comment against try_to_unlock(), below)

Renamed that one to try_to_munlock() and adjusted all the callers and
comments.

> > +static int __mlock_vma_pages_range(struct vm_area_struct *vma,
> > +			unsigned long start, unsigned long end)
> > +{

> > +		ret = get_user_pages(current, mm, addr,
> > +				min_t(int, nr_pages, ARRAY_SIZE(pages)),
> > +				write, 0, pages, NULL);
> 
> Doesn't mlock already do a make_pages_present(), or did that get
> removed and moved to here?

make_pages_present does not work right for PROT_NONE and does
not add pages to the unevictable LRU.  Now that we have a
separate function for unlocking, we may be able to just add
a few lines to make_pages_present and use that again.

Also, make_pages_present works on some other types of VMAs
that this code does not work on.  I do not know whether
merging this with make_pages_present would make things
cleaner or uglier.

Lee?  Kosaki-san?  Either of you interested in investigating 
this after Andrew has the patches merged with the fast cleanups
that I'm doing now?
 
> > +	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
> > +			is_vm_hugetlb_page(vma) ||
> > +			vma == get_gate_vma(current))
> > +		goto make_present;
> > +
> > +	return __mlock_vma_pages_range(vma, start, end);
> 
> Invert the `if' expression, remove the goto?

Done, thanks.
 
> > +/**
> > + * try_to_unlock - Check page's rmap for other vma's holding page locked.
> > + * @page: the page to be unlocked.   will be returned with PG_mlocked
> > + * cleared if no vmas are VM_LOCKED.
> 
> I think kerneldoc will barf over the newline in @page's description.

Cleaned this up.
 
> > + * Return values are:
> > + *
> > + * SWAP_SUCCESS	- no vma's holding page locked.
> > + * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
> > + * SWAP_MLOCK	- page is now mlocked.
> > + */
> > +int try_to_unlock(struct page *page)
> > +{
> > +	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
> > +
> > +	if (PageAnon(page))
> > +		return try_to_unmap_anon(page, 1, 0);
> > +	else
> > +		return try_to_unmap_file(page, 1, 0);
> > +}
> > +#endif
> 
> OK, this function is clear as mud.  My first reaction was "what's wrong
> with just doing unlock_page()?".  The term "unlock" is waaaaaaaaaaay
> overloaded in this context and its use here was an awful decision.
> 
> Can we please come up with a more specific name and add some comments
> which give the reader some chance of working out what it is that is
> actually being unlocked?

try_to_munlock - I have fixed the documentation for this function too

> > ...
> >
> > @@ -652,7 +652,6 @@ again:			remove_next = 1 + (end > next->
> >   * If the vma has a ->close operation then the driver probably needs to release
> >   * per-vma resources, so we don't attempt to merge those.
> >   */
> > -#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
> >  
> >  static inline int is_mergeable_vma(struct vm_area_struct *vma,
> >  			struct file *file, unsigned long vm_flags)
> 
> hm, so the old definition of VM_SPECIAL managed to wedge itself between
> is_mergeable_vma() and is_mergeable_vma()'s comment.  Had me confused
> there.
> 
> pls remove the blank line between the comment and the start of
> is_mergeable_vma() so people don't go sticking more things in there.

Done.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
