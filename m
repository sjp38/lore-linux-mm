Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF286B4A53
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 15:23:43 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so10653543pgb.7
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:23:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 27sor6853413pfs.60.2018.11.27.12.23.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 12:23:42 -0800 (PST)
Date: Tue, 27 Nov 2018 12:23:32 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 07/10] mm/khugepaged: minor reorderings in
 collapse_shmem()
In-Reply-To: <20181127075945.m5nbflc6nqto6f2i@kshutemo-mobl1>
Message-ID: <alpine.LSU.2.11.1811271121410.4027@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils> <alpine.LSU.2.11.1811261526400.2275@eggly.anvils> <20181127075945.m5nbflc6nqto6f2i@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Tue, 27 Nov 2018, Kirill A. Shutemov wrote:
> On Mon, Nov 26, 2018 at 03:27:52PM -0800, Hugh Dickins wrote:
> > Several cleanups in collapse_shmem(): most of which probably do not
> > really matter, beyond doing things in a more familiar and reassuring
> > order.  Simplify the failure gotos in the main loop, and on success
> > update stats while interrupts still disabled from the last iteration.
> > 
> > Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: stable@vger.kernel.org # 4.8+
> > ---
> >  mm/khugepaged.c | 72 ++++++++++++++++++++++---------------------------
> >  1 file changed, 32 insertions(+), 40 deletions(-)
> > 
> > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > index 1c402d33547e..9d4e9ff1af95 100644
> > --- a/mm/khugepaged.c
> > +++ b/mm/khugepaged.c
> > @@ -1329,10 +1329,10 @@ static void collapse_shmem(struct mm_struct *mm,
> >  		goto out;
> >  	}
> >  
> > +	__SetPageLocked(new_page);
> > +	__SetPageSwapBacked(new_page);
> >  	new_page->index = start;
> >  	new_page->mapping = mapping;
> > -	__SetPageSwapBacked(new_page);
> > -	__SetPageLocked(new_page);
> >  	BUG_ON(!page_ref_freeze(new_page, 1));
> >  
> >  	/*
> > @@ -1366,13 +1366,13 @@ static void collapse_shmem(struct mm_struct *mm,
> >  			if (index == start) {
> >  				if (!xas_next_entry(&xas, end - 1)) {
> >  					result = SCAN_TRUNCATED;
> > -					break;
> > +					goto xa_locked;
> >  				}
> >  				xas_set(&xas, index);
> >  			}
> >  			if (!shmem_charge(mapping->host, 1)) {
> >  				result = SCAN_FAIL;
> > -				break;
> > +				goto xa_locked;
> >  			}
> >  			xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
> >  			nr_none++;
> > @@ -1387,13 +1387,12 @@ static void collapse_shmem(struct mm_struct *mm,
> >  				result = SCAN_FAIL;
> >  				goto xa_unlocked;
> >  			}
> > -			xas_lock_irq(&xas);
> > -			xas_set(&xas, index);
> >  		} else if (trylock_page(page)) {
> >  			get_page(page);
> > +			xas_unlock_irq(&xas);
> >  		} else {
> >  			result = SCAN_PAGE_LOCK;
> > -			break;
> > +			goto xa_locked;
> >  		}
> >  
> >  		/*
> 
> I'm puzzled by locking change here.

The locking change here is to not re-get xas_lock_irq (in shmem_getpage
case) just before we drop it anyway: you point out that it used to cover
		/*
		 * The page must be locked, so we can drop the i_pages lock
		 * without racing with truncate.
		 */
		VM_BUG_ON_PAGE(!PageLocked(page), page);
		VM_BUG_ON_PAGE(!PageUptodate(page), page);
		VM_BUG_ON_PAGE(PageTransCompound(page), page);
		if (page_mapping(page) != mapping) {
but now does not.

But the comment you wrote there originally (ah, git blame shows
that Matthew has made it say i_pages lock instead of tree_lock),
"The page must be locked, so we can drop...", was correct all along,
I'm just following what it says.

It would wrong if the trylock_page came after the xas_unlock_irq,
but it comes before (as before): holding i_pages lock across the
lookup makes sure we look up the right page (no RCU racing) and
trylock_page makes sure that it cannot be truncated or hole-punched
or migrated or whatever from that point on - so can drop i_pages lock.

Actually, I think we could VM_BUG_ON(page_mapping(page) != mapping),
couldn't we? Not that I propose to make such a change at this stage.

> 
> Isn't the change responsible for the bug you are fixing in 09/10?

In which I relaxed the VM_BUG_ON_PAGE(PageTransCompound(page), page)
that appears in the sequence above.

Well, what I was thinking of in 9/10 was a THP being inserted at some
stage between selecting this range for collapse and reaching the last
(usually first) xas_lock_irq(&xas) in the "This will be less messy..."
loop above: I don't see any locking against that possibility.  (And it
has to be that initial xas_lock_irq(&xas), because once the PageLocked
head of new_page is inserted in the i_pages tree, there is no more
chance for truncation and a competing THP to be inserted there.)

So 9/10 would be required anyway; but you're thinking that the page
we looked up under i_pages lock and got trylock_page on, could then
become Compound once i_pages lock is dropped?  I don't think so: pages
don't become Compound after they've left the page allocator, do they?
And if we ever manage to change that, I'm pretty sure it would be with
page locks held and page refcounts frozen.

> 
> IIRC, my intend for the locking scheme was to protect against
> truncate-repopulate race.
> 
> What do I miss?

The stage in between selecting the range for collapse, and getting
the initial i_pages lock?  Pages not becoming Compound underneath
you, with or without page lock, with or without i_pages lock?  Page
lock being sufficient protection against truncation and migration?

> 
> The rest of the patch *looks* okay, but I found it hard to follow.
> Splitting it up would make it easier.

It needs some time, I admit: thanks a lot for persisting with it.
And thanks (to you and to Matthew) for the speedy Acks elsewhere.

Hugh
