Message-ID: <3B244C60.8C27AC83@earthlink.net>
Date: Sun, 10 Jun 2001 22:43:12 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
References: <l03130308b7439bb9f187@[192.168.239.105]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jonathan,

Jonathan Morton wrote:
> 
> Interesting observation.  Something else though, which kswapd is guilty of
> as well: consider a page shared among many processes, eg. part of a
> library.  As kswapd scans, the page is aged down for each process that uses
> it.  So glibc gets aged down many times more quickly than a non-shared
> page, precisely the opposite of what we really want to happen.  With
> exponential-decay aging, and multiple processes doing the aging in this
> manner, highly important things like glibc get muscled out in very short
> order...

Are you sure about this? The only place pages are
aged down is in refill_inactive_scan(), which scans
the active_list, not process PTEs. Aging *up*, OTOH,
is done on a per-mapping basis, in try_to_swap_out()
(as well as linearly in refill_inactive_scan(), go
figure). This seems to be the rationale for making
age-down a division, and age-up an increment. Of course,
when memory is tight a lot of processes are going to
be waking up kswapd, so all pages are going to age more
quickly in that case, but we're never aging a page down
proportional to the number of processes that have it
mapped.

> Maybe aging up/down needs to be done on a linear page scan, rather than a
> per-process scan, and reserve the per-process scan for choosing process
> pages to move into the swap arena.

It would seem to make sense to do aging up and down
consistently. The (or a) way to do that is to make
try_to_swap_out() set PG_referenced, rather than age
the page up itself. Then no matter how many times the
page is touched, it will be aged up only once, next
time refill_inactive_scan() sees it.

On the other hand, what makes sense on a cursory
inspection may not be at all good in practice. I think
the way it works now is intuitively pretty reasonable:
a global downward decay of page->age for all pages,
which processes can counteract by referencing the page
frequently. When age is <3, the exponential decay is
coincidentally linear, so a page mapped by one process
can be kept active by being referenced (and noticed
by try_to_swap_out()) at least once during each of
refill_inactive_scan's trips through the active_list.
A page mapped by two processes has to be referenced
half as often by each, on average, to stay active
(assuming that the swap_out() scan visits all process
PTEs in approximately the same interval that
refill_inactive_scan() visits all the active pages).

-- Joe

-- Joseph A. Knapka
"You know how many remote castles there are along the gorges? You
 can't MOVE for remote castles!" -- Lu Tze re. Uberwald
// Linux MM Documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
