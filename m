Date: Thu, 13 Jan 2000 21:13:41 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.10.10001131936040.13454-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001132059590.981-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Rik van Riel wrote:

>Now we'll only want to build something into kswapd
>so that rebalancing the high memory zones is done in
>the background.

You never need to rebance the bigmem between 1g and 64g withing kswapd.
This because bh/irq handlers are not going to use it. So kswapd has to
care only about the memory below the bigmem boundary.

BTW I just noticed currently (2.3.40pre1) kswapd is completly
screwedup. kswapd should still do:

		while (nr_free_pages - nr_free_bigpages < freepages.high)

exactly like in our early 2.3.18 bigmem code because _nothing_ is changed
is the basic MM design since that time.

The fix against 2.3.40pre1 to re-activate kswapd is this:

--- 2.3.40pre1/mm/vmscan.c	Sun Jan  9 20:45:31 2000
+++ /tmp/vmscan.c	Thu Jan 13 21:09:33 2000
@@ -503,7 +503,7 @@
 		do {
 			/* kswapd is critical to provide GFP_ATOMIC
 			   allocations (not GFP_HIGHMEM ones). */
-			if (nr_free_buffer_pages() >= freepages.high)
+			if (nr_free_pages() - nr_free_highpages() >= freepages.high)
 				break;
 			if (!do_try_to_free_pages(GFP_KSWAPD, 0))
 				break;


Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
