Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA30960
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 15:17:13 -0500
Date: Thu, 7 Jan 1999 20:40:11 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
In-Reply-To: <87iueiudml.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.990107202921.564C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, Steve Bergman <steve@netplus.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On 7 Jan 1999, Zlatko Calusic wrote:

> 2) In pre-5, under heavy load, free memory is hovering around
> freepages.min instead of being somewhere between freepages.low &
> freepages.max. This could make trouble for bursts of atomic
> allocations (networking!).

Agreed and I just fixed that with my updates to the memory trashing
heuristic (see also the second patch in one of my last emails). 

A new minimal patch against 2.2.0-pre5 is this:

Index: page_alloc.c
===================================================================
RCS file: /var/cvs/linux/mm/page_alloc.c,v
retrieving revision 1.1.1.6
diff -u -2 -r1.1.1.6 page_alloc.c
--- page_alloc.c	1999/01/07 11:21:35	1.1.1.6
+++ linux/mm/page_alloc.c	1999/01/07 19:34:58
@@ -4,4 +4,5 @@
  *  Copyright (C) 1991, 1992, 1993, 1994  Linus Torvalds
  *  Swap reorganised 29.12.95, Stephen Tweedie
+ *  trashing_memory heuristic. Copyright (C) 1999  Andrea Arcangeli
  */
 
@@ -259,7 +260,4 @@
 		 * to free things up until things are better.
 		 *
-		 * Normally we shouldn't ever have to do this, with
-		 * kswapd doing this in the background.
-		 *
 		 * Most notably, this puts most of the onus of
 		 * freeing up memory on the processes that _use_
@@ -269,8 +267,9 @@
 			if (!current->trashing_memory)
 				goto ok_to_allocate;
-			if (nr_free_pages > freepages.low) {
+			if (nr_free_pages > freepages.high) {
 				current->trashing_memory = 0;
 				goto ok_to_allocate;
-			}
+			} else if (nr_free_pages > freepages.low)
+				goto ok_to_allocate;
 		}
 		/*



The problem is that I don't know if it's going to hurt performances... If
somebody would try it out would be helpful... I don't think it can 
hurt but...

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
