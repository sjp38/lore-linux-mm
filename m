Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B12EE6B0092
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:28:35 -0400 (EDT)
Date: Wed, 18 Apr 2012 16:28:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
Message-ID: <20120418152831.GK2359@suse.de>
References: <20120416141423.GD2359@suse.de>
 <alpine.LSU.2.00.1204161332120.1675@eggly.anvils>
 <20120417122202.GF2359@suse.de>
 <alpine.LSU.2.00.1204172023390.1609@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1204172023390.1609@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rik van Riel <riel@redhat.com>, Ken Chen <kenchen@google.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 17, 2012 at 08:52:21PM -0700, Hugh Dickins wrote:
> > > (You do remind me that I meant years ago to switch swapper_space over
> > > to the much simpler __set_page_dirty_no_writeback(), which shmem has
> > > used for ages; but as far as this problem goes, that would probably
> > > be at best a workaround, rather than the proper fix.)
> > 
> > It would be a workaround. If in the future we wanted to treat swapper
> > space more like a normal file inode and writeback dirty pages from
> > the flusher thread then this bug would just pop its head back up.
> 
> It's a no-brainer workaround: patch and more explanation below.  I
> can double-fix it if you prefer, but the one-liner appeals more to me.
> 

Ok, fair enough. While I think swapper space will eventually use the dirty
tag information that day is not today.

> > > Hmm, mm/migrate.c.
> > 
> > Migration moves the page mapping under the tree lock so
> > __set_page_dirty_nobuffers() I don't think that is it.
> 
> Yes, I was worried by the places that set page->mapping = NULL in
> migrate.c (later, not under the tree_lock), but those would not be able
> to generate this issue at all (ptes already replaced by migration entries).
> 

Yes.

> <SNIP>
>
> [PATCH] mm: fix s390 BUG by using __set_page_dirty_no_writeback on swap
> 
> Mel reports a BUG_ON(slot == NULL) in radix_tree_tag_set() on s390 3.0.13:
> called from __set_page_dirty_nobuffers() when page_remove_rmap() tries to
> transfer dirty flag from s390 storage key to struct page and radix_tree.
> 
> That would be because of reclaim's shrink_page_list() calling add_to_swap()
> on this page at the same time: first PageSwapCache is set (causing
> page_mapping(page) to appear as &swapper_space), then page->private set,
> then tree_lock taken, then page inserted into radix_tree - so there's
> an interval before taking the lock when the radix_tree slot is empty.
> 

Yes, makes sense.

> We could fix this by moving __add_to_swap_cache()'s spin_lock_irq up
> before SetPageSwapCache, with error case ClearPageSwapCache moved up
> under tree_lock too.
> 

This can be done if/when swapper_space can make proper use of the dirty
tag information.

> But a better fix is just to do what's five years overdue.  Ken Chen
> added __set_page_dirty_no_writeback() (if !PageDirty TestSetPageDirty)
> for tmpfs to skip all that radix_tree overhead, and swap is just the same:
> it ignores the radix_tree tag, and does not participate in dirty page
> accounting, so should be using __set_page_dirty_no_writeback() too.
> 
> Reported-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

I've sent a kernel based on this patch to the s390 folk that originally
reported the bug. Hopefully they'll test and get back to me in a few
days.

Thanks Hugh.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
