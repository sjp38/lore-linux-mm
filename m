Received: from localhost.localdomain (groudier@ppp-164-20.villette.club-internet.fr [195.36.164.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA17574
	for <linux-mm@kvack.org>; Sat, 5 Dec 1998 05:36:36 -0500
Date: Sat, 5 Dec 1998 11:47:41 +0100 (MET)
From: Gerard Roudier <groudier@club-internet.fr>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <199812041434.OAA04457@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981205113431.805C-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>


On Fri, 4 Dec 1998, Stephen C. Tweedie wrote:

> The idea is to do readahead for all the data you want, *including* the
> bit you are going to need right away.  Once that is done, you just
> wait for the IO to complete on that first item.  In this case, that
> means doing a readahead on pages n to n+15 inclusive, and then after
> that doing the synchronous read_swap_page on page n.  The kernel will
> happily find that page in the swap cache, work out that IO is already
> in progress and wait for that page to become available.
> 
> Even though the buffer IO request layer issues the entire sequential
> IO as one IO to the device drivers, the buffers and pages involved in
> the data transfer still get unlocked one by one as the IO completes.
> After submitting the initial IO you can wait for that first page to
> become unlocked without having to wait for the rest of the readahead
> IO to finish.

I find my previous reply to you mail very unclear. In fact, my idea is 
to implemement something like the following:

Inputs:
-------
- faulted_address
- offset_behind      offset behind the faulted address up to which we want
                     to swap-in data.
- offset_ahead       offset ahead the faulted address ...

Strategy:
---------
- queue reads of all the pages between (faulted_address - offset_behind)
  and (faulted_address + offset_ahead)
- run the tq_disk to actually start the IO.
- wait for the page that contains the faulted_address.

offset_behind and offset_ahead may be constant values or tuned at run-time 
dynamically if some clever heuristic will be found.

Does the above make sense? (Or is it already implemented this way?)


Regards,
   Gerard.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
