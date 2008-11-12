Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
	one page into another
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20081112173258.GX10818@random.random>
References: <1226409701-14831-3-git-send-email-ieidus@redhat.com>
	 <20081111114555.eb808843.akpm@linux-foundation.org>
	 <20081111210655.GG10818@random.random>
	 <Pine.LNX.4.64.0811111522150.27767@quilx.com>
	 <20081111221753.GK10818@random.random>
	 <Pine.LNX.4.64.0811111626520.29222@quilx.com>
	 <20081111231722.GR10818@random.random>
	 <Pine.LNX.4.64.0811111823030.31625@quilx.com>
	 <20081112022701.GT10818@random.random>
	 <Pine.LNX.4.64.0811112109390.10501@quilx.com>
	 <20081112173258.GX10818@random.random>
Content-Type: text/plain
Date: Wed, 12 Nov 2008 15:08:07 -0500
Message-Id: <1226520487.7560.65.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-11-12 at 18:32 +0100, Andrea Arcangeli wrote:
> On Tue, Nov 11, 2008 at 09:10:45PM -0600, Christoph Lameter wrote:
> > get_user_pages() cannot get to it since the pagetables have already been
> > modified. If get_user_pages runs then the fault handling will occur
> > which will block the thread until migration is complete.
> 
> migrate.c does nothing for ptes pointing to swap entries and
> do_swap_page won't wait for them either. Assume follow_page in
> migrate.c returns a swapcache not mapped but with a pte pointing to
> it. That means page_count 1 (+1 after you isolate it from the lru),
> page_mapcount 0, page_mapped 0, page_mapping = swap address space,
> swap_count = 2 (1 swapcache, 1 the pte with the swapentry). Now assume
> one thread does o_direct read from disk that triggers a minor fault in
> do_swap_cache called by get_user_pages. The other cpu is running
> sys_move_pages and the expected count will match the page count in
> migrate_page_move_mapping. Page is still in swapcache. So after the
> expected count matches in the migrate.c thread, the other thread
> continues in do_swap_page and runs lookup_swap_cache that succeeds
> (the page wasn't removed from swapcache yet as migrate.c needs to bail
> out if the expected count doesn't match, so it can't mess with the
> oldpage until it's sure it can migrate it). After that do_swap_page
> gets a reference on the swapcache (at that point migrate.c continues
> despite the expected count isn't 2 anymore! just a second after having
> verified that it was 2). lock_page blocks do_swap_page until migration
> is complete but pte_same in do_swap_page won't fail because the pte is
> still pointing to the same swapentry (it's just the swapcache inode
> radix tree that points to a different page, the swapentry is still the
> same as before the migration - is_swap_pte will succeed but
> is_migration_entry failed when restoring the pte). 

Ah.  try_to_unmap_one() won't replace the pte entry with a
migration_pte() if the [anon] page is already in the swap cache.  When
migration completes, we won't modify the page tables with the newpage
pte--we'll just let any subsequent swap page [minor] fault handle that.

That suggests a possible fix:  instead of replacing the pte with a
duplicate swap entry in try_to_unmap_one(), go ahead and replace the pte
with a migration pte.  Then back in try_to_unmap_anon(), after unmapping
all references, free the swap cache entry, so as not to leak it
[assuming we're in a lock state that allows that--I haven't checked that
far].  Then, the page table WILL have been modified by the time
migration unlocks the page.

Might want/need to check for migration entry in do_swap_page() and loop
back to migration_entry_wait() call when the changed pte is detected
rather than returning an error to the caller.

Does that sound reasonable?

> Finally the pte is
> overwritten with the old page and any data written to the new page in
> between is lost.

And wouldn't the new page potentially be leaked?  That is, could it end
up on the lru with page_count == page_mapcount() >= 1, but no page table
reference to ever be unmapped to release the count?  

> 
> However it's not exactly the same bug as the one in fork, I was
> talking about before, it's also not o_direct specific. Still
> page_wrprotect + replace_page is orders of magnitude simpler logic
> than migrate.c and it has no bugs or at least it's certainly much
> simpler to proof as correct. Furthermore we never 'stall' any userland
> task while we do our work. We only mark the pte wrprotected, the task
> can cow or takeover it if refcount allows anytime, and later we'll
> bailout during replace_page if something has happened in between
> page_wrprotect and replace_page. So our logic is simpler and tuned for
> max performance and fewer interference with userland runtime. Not
> really sure if it worth for us to call into migrate.c.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
