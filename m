Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA10185
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 13:45:35 -0500
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.3.95.990112095401.17705A-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 12 Jan 1999 19:44:45 +0100
In-Reply-To: Linus Torvalds's message of "Tue, 12 Jan 1999 09:54:50 -0800 (PST)"
Message-ID: <87d84kl49u.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On Tue, 12 Jan 1999, Stephen C. Tweedie wrote:
> > 
> > On 11 Jan 1999 00:04:11 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
> > said:
> > 
> > > Oh, and just as a side note we are currently unfairly penalizing
> > > threaded programs by doing for_each_task instead of for_each_mm in the
> > > swapout code...
> > 
> > I know, on my TODO list...
> 
> Actually, this one is _really_ easy to fix.
> 
> The truly trivial fix is to just move "swap_cnt" into the mm structure,
> and you're all done. You'd still walk the list with for_each_task(), but
> it no longer matters.
> 
> 		Linus
> 

Not related to this, but I (hopefully correctly) observed that SHM
swap I/O is done synchronously.

Could somebody spare a minute to explain why is that so, and what
needs to be done to make SHM swapping asynchronous?


Also, while we're at MM fixes, I'm appending below a small patch that
will improve interactive feel.

After number of async pages gets bigger than pager_daemon.swap_cluster
(= SWAP_CLUSTER_MAX), swapin readahead becomes synchronous, and that
hurts performance. It is better to skip readahead in such situations,
and that is also more fair to swapout. Andrea came to exactly the same
conclusion, independent of me (on the same day :)).

diff -urN linux-pre-7/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-pre-7/mm/page_alloc.c	Tue Jan 11 07:28:06 1999
+++ linux/mm/page_alloc.c	Tue Jan 11 07:29:44 1999
@@ -358,6 +358,8 @@
 	for (i = 1 << page_cluster; i > 0; i--) {
 	      if (offset >= swapdev->max)
 		      return;
+	      if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
+		      return;
 	      if (!swapdev->swap_map[offset] ||
 		  swapdev->swap_map[offset] == SWAP_MAP_BAD ||
 		  test_bit(offset, swapdev->swap_lockmap))

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
