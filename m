Date: Tue, 4 Apr 2000 20:03:40 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004041256250.12374-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.21.0004041915290.1653-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2000, Ben LaHaise wrote:

>try running a swap test under any recent devel kernel -- eventually you
>will see an invalid swap entry show up in someone's pte causing a random

acquire_swap_entry() should be just doing all the safety checking to make
sure the page->index is caching a _valid_ swap entry. If it's garbage
get_swap_page() will be recalled and a valid entry will be allocated (and
if get_swap_page() returns an invalid-entry that's definitely not related
to the PG_swap_entry logic anymore).

Could you explain me how acquire_swap_entry() can return an invalid swap
entry (starting with a random page->index of course)? I can't exclude
there's a bug, but acquire_swap_entry was meant to return only valid
entries despite of the page->index possible garbage and it seems it's
doing that.

>SIGSEGV (it's as if the entry was marked PROT_NONE -- present, but no
>user access).

I'm not saying you are not seeing that, I'm only trying to understand how
can it be related to the PG_swap_entry logic.

>> We're here talking about PG_swap_entry. The only object of that bit is to
>> remains set on anonymous pages that aren't in the swap cache, so next time
>> we'll re-add them to the swap cache we'll try to swap out them in the same
>> swap entry as the page were before.
>
>Which is bogus.  If it's an anonymous page that we want to swap out to the
>same swap entry, leave it in the swap cache.

There's a very basic reason that we can't left it in the swap cache. We
can't left it in the swap cache simply because the swap cache is a read
only entity and if you do a write access you can't left the page in the
swap cache and change it without updating its on-disk counterpart.

So we always remove the anonymous pages from the swap cache upon
swapin-_write_-faults. That's also how 2.2.x works.

Then I noticed it was possible to give persistence on the swap also to the
dirtified pages without making the swap-cache dirty, by adding the
PG_swap_entry bit that tell us if the page->index is currently caching the
last swap entry where the page was allocated on the swap. That does all
the job and we don't need dirty swap cache anymore.

>> >If __delete_from_swap_cache() is called from a wrong code path,
>> >that's something that should be fixed, of course (but that's
>> >orthogonal to this).
>> 
>> __delete_from_swap_cache is called by delete_from_swap_cache_nolock that
>> is called by do_swap_page that does the swapin.
>
>As well as from shrink_mmap.

I would not be complaining your patch if you would put the clear_bit
within shrink_mmap :).

BTW, also the SHM unmap points have to be checked to make sure the
PG_swap_entry gets cleared. Also SHM uses swap cache and shares the
do_swap_page code.

>> >To quote from memory.c::do_swap_page() :
>> >
>> >        if (write_access && !is_page_shared(page)) {
>> >                delete_from_swap_cache_nolock(page);
>> >                UnlockPage(page);
>> >
>> >If you think this is a bug, please fix it here...
>> 
>> The above quoted code is correct.
>
>The code path that this patch really affects is shrink_mmap ->
>__delete_from_swap_cache.  Clearing the bit from shrink_mmap is an option,
>but it doesn't make that much sense to me; if we're removing a page from
					    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>the swap cache, why aren't we clearing the PG_swap_entry bit?  I'd rather
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As just said the whole point of the PG_swap_entry is to be set for
regular anonymous swappable pages, _not_ for the swap cache at all.

So it really make no sense to clear the PG_swap_entry bit while removing a
page from the swap cache and I don't see your arguemnt.

We have instead to cover the points where a swappable page become not a
swappable page anymore. There's also to cover the shrink_mmap case where
we free the page. I'm thinking about it to see if we can skip to cover the
shrink_mmap case changing the point where we set the PG_swap_entry bit. I
think it would be possible if we would avoid the double page fault in the
write_swapin_access+page-is-shared case. But right now I think it's
cleaner to keep the double page fault and to clear the PG_swap_entry
within shrink_mmap while dropping page cache.

>leave the page in the swap cache and set PG_dirty on it that have such
>obscure sematics.

If the page is shared you can't simply set the PG_dirty bit and change the
contents of the page or you'll screwup all other in-core and on-disk users
of the page. You have at least to do a COW and re-add the COWed page to a
new swap cache entry so by definition failing to give persistence to the
page in the swap space.

In general (also for non-shared pages) setting the PG_dirty is inferior
because it would waste swap space by keeping busy on the swap side a swap
entry that it not uptodate and that's really not cache (there's no way
somebody else can fault in the same swap cache page since the user who did
the write-access is now the only user of the page and it has it just
mapped in its pte so it can't fault on it). The reason we keep the page
mapped in the read-only access is to skip a write to disk if we run low on
memory but we can't skip the write to disk in the write-access case...

In the case of multiple users on the swap side (for example when a process
does a fork with some page in the swap) the PG_swap_entry can allow the
two tasks to share the same swap entry if they gets swapped out and
swapped in at different times. A PG_dirty swap cache wouldn't allow that
because of the is-page-shared issue mentioned two paragraphs above.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
