Subject: [RFC] 0/4 Migration Cache Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 17 Feb 2006 10:36:33 -0500
Message-Id: <1140190593.5219.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Migration Cache "V8" 0/4 -- Overview

Now that Christoph's direct migration work is in Linus' tree, I thought
I'd attempt to restart the Migration Cache discussion with this set
of patches.  They work, to the extent that I've tested them, but are
still a bit rough around the edges.


Background:

Marcello Tosatti introduced the migration cache back in Oct04 to obviate use
of swap space for anon pages during page migration.  He posted the original
migration patch [let's call this V0] to the linux-mm list:

	http://marc.theaimsgroup.com/?l=linux-mm&m=109779128211239&w=4

with an update on 250ct04 [V1]

	http://marc.theaimsgroup.com/?l=linux-mm&m=109874962629347&w=4

Hirokazu Takahashi and Ray Bryant tested and updated the patch in
Nov/Dec04 and through Jan/Feb'05.  Let's call these V2 and V3.

Note:  there was quite a bit of chatter in the mailing lists regarding
the migration cache during this time frame.  I don't mean to slight
anyone by failing to credit them with additional updates.  I just didn't
reread all of the messages in preparing this overview.  But, I'll skip
over V4 in case I forgot someone...

Marcello posted a final [?] updated patch [V5] to the lhms-devel list
in April'05:

	http://marc.theaimsgroup.com/?l=lhms-devel&m=111273117528472&w=4

I started working with the migration cache in August'05 and got it working
with Ray Bryant's "manual page migration" patches layered on the memory
hotplug migration patches.  I posted this version [V6] in a series of 4
patches on 1Sep05:

	http://marc.theaimsgroup.com/?l=lhms-devel&m=112558724708190&w=4

After a brief exchange with Marcello, I reworked the migration cache to
hide it, to the extent possible, behind the existing swap cache APIs.
I posted this work [V7] to lhms-devel on 20Sep05:

	http://marc.theaimsgroup.com/?l=lhms-devel&m=112724852823727&w=4

In mid Oct'05, Christoph Lameter began work on a new memory migration
implementation and the community effectively abandoned the previous
memory hotplug and manual page migration patches.  Now that Christoph's
migration work has been submitted upstream, I have ported the migration
cache patches to work with his direct migration in 2.6.16-rc3-mm1. I'm
calling this "V8".

How it works:

The migration cache is a pseudo-swap device which steals the maximum swap
device id.  It implements the pseudo-swap space using the kernel lib 'idr'
facility.  Anonymous pages that are not already in swap space are moved
to the migration cache during migration.  The ptes referencing the pages
are replaced with migration cache ptes consisting of the migration swap
type and the "offset" into the migration cache. The offset is generated
by "idr_get_new_above()".

After a page is migrated, 'remove_from_swap()' will walk the anon vma
vma list and replace the cache pte entry with a real pte for the new
page.  Because migration cache ptes look like swap cache ptes, this 
"just works".

The migration cache differs from the swap cache in another way:  The
cache itself does not hold a reference on the entry.  Thus, when the
last migration pte is replaced by a real [or swap pte--more on this
below] and the reference held by that pte is removed, the migration
cache entry is removed.  That is, pages do not hang around in the
migration cache when there are no ptes referencing the cache entry
as they can do with the swap cache.

One complication in all of this is when direct migration of an anon
page falls back to swapping out the pages.  If the page had not already
been in the swap cache, it will have been added to the migration 
cache.  To swap the page out, we need to move if from the migration
cache to the swap cache.  Note that this would also be required if
shrink_list() encounters a page in the migration cache.  Both the
page migration code and shrink_list() have been modified to call
a new function "migration_move_to_swap()" in these cases.  Marcello
mentions the need to do this in his first migration cache post linked
above.

Moving a migration cache page to the swap cache involves allocating a
swap entry and replacing all of the migration ptes referencing the entry
with swap ptes.  This works similar to 'remove_from_swap()' mentioned
above and, in fact, uses the same underlying mechanism [the "unuse_vma()..."
stack in mm/swapfile.c] that has been updated for this purpose. 

A word about testing:

I have done some simple sanity testing of these patches against
2.6.16-rc3-mm1.  The test results appear to be the same with and without
the migration cache patches applied.  However, I have not tested any
error paths--specifically, the "fall back to swap" and moving of
migration cache pages to the swap cache.  Much work remains.

The Patches:

migration-cache-01-core-implementation.patch

As the name indicates, this is the core implementation of the
migration cache.  In the V1-V7 patches, the migration cache
resided in mm/mmigrate.c.  That file does not exist in the
new migration implementation, so I've moved the migration cache
to mm/swap_state.c with many of the other swap cache functions.

I have had to do some rework of the basic implementation to
support the move from migration to swap cache, and to be able
to call migration cache functions from swap cache functions with
proper locking.  I have also removed some [not all?] functions
that were used by the previous hotplug/manual migration effort
that are not needed in this implementation.  Some cleanup still
required.

migration-cache-02-add-mm-checks.patch

This patch add the necessary checks for whether a page that
appears to be in the swap cache is really in the migration
cache.  Most of these checks are hidden behind the normal
swap interfaces, and are, thus, limited to the swap sources.
However, a couple of them spill over into mm/memory.c and
vmscan.c.

I could have avoided patching mm/memory.c if swapin_readahead() were
in mm/swap_state.c along with its cousin read_swap_cache_async()
instead of in mm/memory.c.  Anyone know why this is the case?

migration-cache-03-move-to-swap.patch

This patch modifies the swapfile.c "unuse_*" stack to support
moving pages from migration cache to swap cache in case we have
to "fall back to swap".  This also allows vmscan.c:shrink_list()
to move migration cache pages to swap cache when/if it wants to
swap them out.  shrink_list() should only find anon pages in the
migration cache when/if we implement lazy page migration.

Because this path is untested and because it wreaks minor havoc
on the "unuse_*" stack, you should pay special attention to this
patch, if you're paying attention at all...

QUESTION:  what does this mean for tasks that fault on the 
migration cache pte while we're moving the page to the swap
cache?  I think that if they manage to look up the page in the
migration cache and get a reference on it, the current test
in do_swap_page() will work OK.  However, is there a potential
race between the time __handle_mm_fault() fetches the pte from
the page table and when do_swap_page() does the cache lookup?
[in a preemptible kernel?]

migration-cache-04-use-for-direct-migration.patch

This patch hooks the migration cache up to direct page migration.
If a destination page exists, and the old page is not already in the
swap cache, we place it in the migration cache instead.  If we need
to fall back to swap(), we must move the page from the migration
cache to the swap cache.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
