Date: Thu, 3 Aug 2000 19:33:38 -0700
From: David Gould <dg@suse.com>
Subject: Re: RFC: design for new VM
Message-ID: <20000803193335.A31816@archimedes.suse.com>
References: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Thu, Aug 03, 2000 at 11:05:47AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, Aug 03, 2000 at 11:05:47AM -0700, Linus Torvalds wrote:
... 
> As far as I can tell, the above is _exactly_ equivalent to having one
> single list, and multiple "scan-points" on that list. 
> 
> A "scan-point" is actually very easy to implement: anybody at all who
> needs to scan the list can just include his own "anchor-page": a "struct
> page_struct" that is purely local to that particular scanner, and that
> nobody else will touch because it has an artificially elevated usage count
> (and because there is actually no real page associated with that virtual
> "struct page" the page count will obviosly never decrease ;).

I have seen this done in other contexts, where there was a single more or
less LRU list, with different regions, mainly, a "wash" region which
cleaned dirty pages. Regions were just pointers into the list.

Bad ascii art concept drawing:
   'U' is used, 'D' is dirty',
   'W' is washing, 'C' is clean
 
  [new]->U-U-U-U-D-U-D-U-U-D-U-U-D-D-U-*-W-W-W-W-W-W-W-W-*-C-C-C-C-C->[old]
                                       ^                ^
                 ... active ...        | ... wash ....  |  ... free ...
                                                        |
                                       <- size of wash->\washptr

Basically when a page aged into the "wash" section of the list, it would be
cleaned and moved on to the clean section. This was done either on demand
by tasks trying to find free pages, or by a pagecleaner task. Tunables were
the size of the wash, the size goals for the free section, i/o rate, how
on demand tasks would scan after finding a page, how agressive the pagecleaner
etc.

It seemed to work ok, and the code was not too horrible.

> etc.. Basically, you can have any number of virtual "clocks" on a single
> list.

Yes.
 
>    For example, imagine a common problem with floppies: we have a timeout
>    for the floppy motor because it's costly to start them up again. And
>    they are removable. A perfect floppy driver would notice when it is
>    idle, and instead of turning off the motor it might decide to scan for
>    dirty pages for the floppy on the (correct) assumption that it would be
>    nice to have them all written back instead of turning off the motor and
>    making the floppy look idle.

This would be a big win for laptops. Instead of turning off flushing, or
flushing too often, just piggy back all the flushing onto time when the
drive was already spun up anyway. Happy result, less power and noise, and
more safety.


-dg

-- 
David Gould                                                 dg@suse.com
SuSE, Inc.,  580 2cd St. #210,  Oakland, CA 94607          510.628.3380
"I sense a disturbance in the source"  -- Alan Cox
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
