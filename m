Received: from dax.scot.redhat.com (sct@[195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA06996
	for <linux-mm@kvack.org>; Tue, 8 Dec 1998 18:02:10 -0500
Date: Tue, 8 Dec 1998 22:59:09 GMT
Message-Id: <199812082259.WAA00875@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Tiny one-line fix to swap readahead
Sender: owner-linux-mm@kvack.org
To: Alan Cox <number6@the-village.bc.nu>
Cc: Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org, Rik van Riel <H.H.vanRiel@fys.ruu.nl>
List-ID: <linux-mm.kvack.org>

Hi,

I just noticed this when experimenting with a slightly different swapin
optimisation: swapping in entire 64k aligned blocks rather than doing
strict readahead.  A side effect was that a swapin in the first free
pages of the swap file tried to swapin the swap header, which is marked
SWAP_MAP_BAD.  This breaks.

Now the readahead code in Rik's own patches won't try to do this, but it
_will_ have the same problem if you ever readahead past a bad page in
the swap file.  The trick is to fix the test in mm/page_alloc.c,
function swapin_readahead:

	      if (!swapdev->swap_map[offset] ||
		  swapdev->swap_map[offset] == SWAP_MAP_BAD ||  <<<< new line
		  test_bit(offset, swapdev->swap_lockmap))
		      continue;

Sorry this isn't a diff, but my other changes to this file mean that I
don't have a patch handy against plain ac*.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
