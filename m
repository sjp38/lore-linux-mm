Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA22134
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 14:10:22 -0500
Date: Sun, 10 Jan 1999 11:08:44 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <3698F4E1.715105C6@netplus.net>
Message-ID: <Pine.LNX.3.95.990110105015.7668E-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Steve Bergman wrote:
> 
> The change seems to have hurt it in both cases.  What I am seeing on pre6 and
> it's derivitives is a *lot* of *swapin* activity.  Pre5 almost exclusively swaps
> *out* during the image test, averaging about 1.25MB/sec (spends a lot of time at
> around 2000k/sec) with very little swapping in.  All the pre6 derivitives swap
> *in* quite heavily during the test.  The 'so' number sometimes drops to 0 for
> seconds at a time.  It also looks like pre6 swaps out slightly more overall
> (~165MB vs 160MB).

This is interesting - the only thing that changed between pre5 and pre6
(apart from the line that I asked you to revert and that made things
worse) was actually the deadlock code. And the only thing _that_ changes,
in turn, is just the fact that when we allocate new buffers we cannot swap
out.

Now, this all actally makes sense: what happens when we limit swap-out
activity is that we limit our choices on what to do a _lot_.. That hurts
performance - we had to avoid a really nice path because of the deadlock
possibility, and due to that we can no longer make the best choice about
what to free up. So performance goes down. 

This shows up mainly on small memory machines, because on large memory
machines we still have a lot of choice about what to free up, so it's not
all that much of a problem.

But basically it seems that the reason pre-5 was so good was simply due to
the bug that allowed it to deadlock. Sad, because there's no way I can
re-introduce that nice behaviour without re-introducing the bug ;(

However, there are other things that we _can_ do. For example, we can
easily make the memory management code less eager to try to free memory if
it doesn't have the __GFP_IO bit set - because when it cannot swap it can
no longer maintain a good balance of pages, so it doesn't make sense for
it to try to free up all that many pages. 

Also, if we cannot swap out, we shouldn't bother looking at the
"trashing_memory" thing - there's just no point in making things worse. 

The logic for that would be something like the attached patch to
page_alloc.c..

		Linus

--- v2.2.0-pre6/linux/mm/page_alloc.c	Fri Jan  8 22:36:25 1999
+++ linux/mm/page_alloc.c	Sun Jan 10 11:04:17 1999
@@ -269,6 +231,9 @@
 				current->trashing_memory = 0;
 				goto ok_to_allocate;
 			}
+			/* If we cannot swap, ignore trashing_memory */
+			if (!(gfp_mask & __GFP_IO))
+				goto ok_to_allocate;
 		}
 		/*
 		 * Low priority (user) allocations must not
@@ -277,9 +242,12 @@
 		 */
 		current->trashing_memory = 1;
 		{
-			int freed;
+			int freed, pages;
+			pages = 16;
+			if (gfp_mask & __GFP_IO)
+				pages = freepages.high - nr_free_pages;
 			current->flags |= PF_MEMALLOC;
-			freed = try_to_free_pages(gfp_mask, freepages.high - nr_free_pages);
+			freed = try_to_free_pages(gfp_mask, pages);
 			current->flags &= ~PF_MEMALLOC;
 			if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 				goto nopage;


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
