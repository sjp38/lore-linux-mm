Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 14AC06B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 23:52:41 -0400 (EDT)
Received: by iajr24 with SMTP id r24so13572625iaj.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 20:52:40 -0700 (PDT)
Date: Tue, 17 Apr 2012 20:52:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
In-Reply-To: <20120417122202.GF2359@suse.de>
Message-ID: <alpine.LSU.2.00.1204172023390.1609@eggly.anvils>
References: <20120416141423.GD2359@suse.de> <alpine.LSU.2.00.1204161332120.1675@eggly.anvils> <20120417122202.GF2359@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rik van Riel <riel@redhat.com>, Ken Chen <kenchen@google.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 17 Apr 2012, Mel Gorman wrote:
> On Mon, Apr 16, 2012 at 02:14:09PM -0700, Hugh Dickins wrote:
> > On Mon, 16 Apr 2012, Mel Gorman wrote:
> > 
> > > This patch is horribly ugly and there has to be a better way of doing
> > > it. I'm looking for suggestions on what s390 can do here that is not
> > > painful or broken. 
> > > 
> > > The following bug was reported on s390
> > > 
> > > kernel BUG at
> > > /usr/src/packages/BUILD/kernel-default-3.0.13/linux-3.0/lib/radix-tree.c:477!
>... 
> > I'm confused as to whether you see this problem with file pages,
> > or with anon-swap-cache pages, or with both, or not yet determined.
> 
> PageSwapCache pages only.

Oh good, thanks, that narrowed the search space a lot.

> > (You do remind me that I meant years ago to switch swapper_space over
> > to the much simpler __set_page_dirty_no_writeback(), which shmem has
> > used for ages; but as far as this problem goes, that would probably
> > be at best a workaround, rather than the proper fix.)
> 
> It would be a workaround. If in the future we wanted to treat swapper
> space more like a normal file inode and writeback dirty pages from
> the flusher thread then this bug would just pop its head back up.

It's a no-brainer workaround: patch and more explanation below.  I
can double-fix it if you prefer, but the one-liner appeals more to me.

> > Hmm, mm/migrate.c.
> 
> Migration moves the page mapping under the tree lock so
> __set_page_dirty_nobuffers() I don't think that is it.

Yes, I was worried by the places that set page->mapping = NULL in
migrate.c (later, not under the tree_lock), but those would not be able
to generate this issue at all (ptes already replaced by migration entries).

> I think the race is against something like reuse_swap_page() which locks
> the page and removes it from swap cache while page_remove_rmap() looks
> up the same page.

No, __delete_from_swap_cache() is always doing ClearPageSwapCache under
tree_lock (which __set_page_dirty_no_buffers acquires before proceeding).


[PATCH] mm: fix s390 BUG by using __set_page_dirty_no_writeback on swap

Mel reports a BUG_ON(slot == NULL) in radix_tree_tag_set() on s390 3.0.13:
called from __set_page_dirty_nobuffers() when page_remove_rmap() tries to
transfer dirty flag from s390 storage key to struct page and radix_tree.

That would be because of reclaim's shrink_page_list() calling add_to_swap()
on this page at the same time: first PageSwapCache is set (causing
page_mapping(page) to appear as &swapper_space), then page->private set,
then tree_lock taken, then page inserted into radix_tree - so there's
an interval before taking the lock when the radix_tree slot is empty.

We could fix this by moving __add_to_swap_cache()'s spin_lock_irq up
before SetPageSwapCache, with error case ClearPageSwapCache moved up
under tree_lock too.

But a better fix is just to do what's five years overdue.  Ken Chen
added __set_page_dirty_no_writeback() (if !PageDirty TestSetPageDirty)
for tmpfs to skip all that radix_tree overhead, and swap is just the same:
it ignores the radix_tree tag, and does not participate in dirty page
accounting, so should be using __set_page_dirty_no_writeback() too.

Reported-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---

 mm/swap_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.4-rc2/mm/swap_state.c	2012-03-31 17:42:26.949729938 -0700
+++ linux/mm/swap_state.c	2012-04-17 15:34:05.732086663 -0700
@@ -26,7 +26,7 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= __set_page_dirty_no_writeback,
 	.migratepage	= migrate_page,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
