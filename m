Received: from cs.utexas.edu (root@cs.utexas.edu [128.83.139.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA26540
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 22:39:04 -0500
Received: from feta.cs.utexas.edu (wilson@feta.cs.utexas.edu [128.83.120.125])
	by cs.utexas.edu (8.8.5/8.8.5) with ESMTP id VAA18685
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 21:38:47 -0600 (CST)
Message-Id: <199901110338.VAA19737@feta.cs.utexas.edu>
From: "Paul R. Wilson" <wilson@cs.utexas.edu>
Date: Sun, 10 Jan 1999 21:38:46 -0600
Subject: question about try_to_swap_out()
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

After checking that that a page is present and pageable, try_to_swap_out()
checks to see if the page is reserved or locked or not DMA'able when
where looking for a DMA page.  If any of these three things is
true, it returns 0 without changing anything.

It seems to me that it should go ahead and check the pte age bit,
and update the page frame's PG_referenced bit, before returning 0.

One case I'm concerned about is a non-DMA page whose reference bit
doesn't get reset as usual.  This page will still look recently-touched
at the next clock sweep, and that will make it stay cached longer,
just because we were looking for a DMA'able page when the clock
hand reached it this time.

I'm unclear what the significance is for a locked page. 

Am I off-base here, or should the conditional that checks to see
whether a page is young (and updates the reference bits) be moved
up ahead of the conditional that checks to see whether a page
is (reserved | locked | not-dma-but-we-need-dma)?

Apologies if I'm way off base here.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
