Date: Tue, 4 Apr 2000 17:06:42 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004031817420.3672-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.21.0004041647150.921-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Apr 2000, Ben LaHaise wrote:

>The following one-liner is a painful bug present in recent kernels: swap
>cache pages left in the LRU lists and subsequently reclaimed by
>shrink_mmap were resulting in new pages having the PG_swap_entry bit set.  

The patch is obviously wrong and shouldn't be applied. You missed the
semantics of the PG_swap_entry bitflage enterely.

Such bit is meant _only_ to allow the swapping out the same page in the
same swap place across write-pagein faults (to avoid swap fragmentation
upon write-page-faults). If you clear such bit within
remove_from_swap_cache (that gets recalled upon a write swapin fault) you
can as well drop such bitflag completly.

The PG_swap_entry is meant to give persistence to pages in the swap space.

>This leads to invalid swap entries being put into users page tables if the
>page is eventually swapped out.  This was nasty to track down.

That's obviously not the case. If you have that problem you'd better
continue to debug it.

The PG_swap_entry can _only_ deal with performance (not with stability).
You can set modify such bit as you want at any time everywhere and the
system will remains rock solid, only performance can change. You can
trivially verify that. The bitflag is read _only_ in acquire_swap_entry,
and such function will run succesfully an safely despite of the
PG_swap_entry bitflag settings.


Said the above, I obviously agree free pages shouldn't have such bit set,
since they aren't mapped anymore and so it make no sense to provide
persistence on the swap space to not allocated pages :). I seen where we
have a problem in not clearing such bit, but the fix definitely isn't to
clear the bit in the swapin-modify path.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
