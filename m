Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA09411
	for <linux-mm@kvack.org>; Thu, 5 Mar 1998 18:01:16 -0500
Date: Thu, 5 Mar 1998 22:49:19 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: swapout frenzy solution
In-Reply-To: <Pine.LNX.3.91.980305221552.448A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.91.980305224225.1206A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Mar 1998, Rik van Riel wrote:

> I've just come up with a simple 'solution' for the swapout
> frenzy experienced by the recent free_memory_available()
> test in kswapd.

Hate to follow up to my own posts, but here it goes:
Once my system reached a state where it needed to
free a _large_ (MAX_ORDER) area, nr_free_pages kept
lingering around free_pages_high * 4 :-(
This means that this scheme doesn't really work...

Then I've got another possible solution. In try_to_swap_out,
we:
- test what page-order this page is holding up
- change the following:
  if (page->age)
- into:
  if (page->age - order_block(page))

This means that a page blocking an order-5 area will
be heavily penalized for this, so this page will be
freed earlier than other pages (which don't occupy
'critical' regions.

Of course, reserving 1/16th of memory for exclusive
use by the page and buffer cache (which we can already
clean on a page-by-page basis) will be far superior
to this...

I don't have time to code this up before the weekend,
so you've got all the time to decide which solution
you'd like to see implemented...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
