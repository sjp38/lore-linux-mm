Message-ID: <3BCA26AC.98F5747C@earthlink.net>
Date: Sun, 14 Oct 2001 23:58:36 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: VM question: side effect of not scanning Active pages?
References: <3BCA2015.5080306@ucla.edu> <3BC9DFA3.D9699230@earthlink.net> <3BCA6F25.2000807@ucla.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin Redelings I wrote:
> 
> Hi Joe,
>         Thanks for the answer.
> 
> > Well, you will never unmap active page. Essentially,
> > that means that once a page gets onto the active
> > list, it is effectively pinned in memory until all processes
> > using the page exit.
> 
>         I'm not sure why this would be true.  Shouldn't any pages on the Active
> list be moved to the Inactive list eventually if they are not used?  In
> refill_inactive (vmscan.c), there is a loop over the active list with
> this code:
> 
>                  if (PageTestandClearReferenced(page)) {
>                          list_del(&page->lru);
>                          list_add(&page->lru, &active_list);
>                          continue;
>                  }
> 
>                  del_page_from_active_list(page);
>                  add_page_to_inactive_list(page);
> 
>         So, if the page is referenced, then it gets moved to the head of the
> active list, and the referenced bit cleared.  But if it is NOT marked
> referenced (which is what should happen for unused system daemons), then
> it should get added to the inactive list, right?
>         Please, let me know if I'm missing something :)

Well, that's what I get for reading 2.4.5 code :-) The active
list scanning used to check that a page was unreferenced by any
process PTEs before deactivating. Now that's unnecessary, since
it appears all the complicated machinery to support direct
reclaim of clean pages from the LRU has gone away, and
shrink_cache() nee page_launder() just directly frees
pages back into the free pool. Cool! So there's nothing
preventing mapped pages from being deactivated, which means
my previous assertion was just silly.

OK, here's what's happening, I think.  Bailing out of
try_to_swap_out() when a page is active simply prevents
active pages (eg, glibc pages) from being evicted from
a process's memory map. So even if the process isn't
using a page, any -other- process that's using it will
prevent it from being evicted from the VM of all the
other procs that have it mapped, whether they are using
the page or not. Presumably, RSS reflects the number
of pages a process has mapped, so you see your daemons
with big RSS because some other process is using their
pages. I don't know if that will cause problems at present
or not. I think accurate RSS figures would be necessary
for global kinds of VM balancing and control.

Cheers,

-- Joe
# "You know how many remote castles there are along the
#  gorges? You can't MOVE for remote castles!" - Lu Tze re. Uberwald
# Linux MM docs:
http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
