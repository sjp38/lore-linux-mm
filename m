Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA16790
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 08:45:09 -0500
Date: Wed, 13 Jan 1999 14:45:09 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.4.03.9901122245090.4656-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.990113144203.284C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@humbolt.geo.uu.nl>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 1999, Rik van Riel wrote:

> IIRC this facility was in the original swapin readahead
> implementation. That only leaves the question who removed
> it and why :))

There's another thing I completly disagree and that I just removed here. 
It's the alignment of the offset field. I see no one point in going back
instead of only doing real read_ahead_. 

Maybe I am missing something?

Index: page_alloc.c
===================================================================
RCS file: /var/cvs/linux/mm/page_alloc.c,v
retrieving revision 1.1.1.8
retrieving revision 1.1.1.1.2.29
diff -u -r1.1.1.8 -r1.1.1.1.2.29
--- page_alloc.c	1999/01/11 21:24:23	1.1.1.8
+++ linux/mm/page_alloc.c	1999/01/12 23:00:04	1.1.1.1.2.29
@@ -353,10 +352,10 @@
 	unsigned long offset = SWP_OFFSET(entry);
 	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
 	
-	offset = (offset >> page_cluster) << page_cluster;
-	
 	for (i = 1 << page_cluster; i > 0; i--) {
-	      if (offset >= swapdev->max)
+	      if (offset >= swapdev->max ||
+		  /* don't block on I/O for doing readahead -arca */
+		  atomic_read(&nr_async_pages) > pager_daemon.max_async_pages)
 		      return;
 	      if (!swapdev->swap_map[offset] ||
 		  swapdev->swap_map[offset] == SWAP_MAP_BAD ||



Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
