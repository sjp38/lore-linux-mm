Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA06632
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 15:26:58 -0500
Date: Mon, 18 Jan 1999 21:26:05 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Removing swap lockmap...
In-Reply-To: <87iue47gy4.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.990118203741.9904A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On 18 Jan 1999, Zlatko Calusic wrote:

> I removed swap lockmap all together and, to my surprise, I can't
> produce any ill behaviour on my system, not even under very heavy
> swapping (in low memory condition).

Looking at your patch (and so looking at the swap_lockmap code) I found a
potential deadlock in the current swap_lockmap handling: 

	task A				task B
	----------			-------------
	rw_swap_page_base()
	
	...if (test_and_set_bit(lockmap))
		... run_task_queue()
					swap_after_unlock_page()
						... clear_bit(lockmap)
						.... wakeup(&lock_queue)
		...sleep_on(&lock_queue);
		deadlocked

I think it will not harm too much because the window is not too big (but
not small) and because usually one of the process not yet deadlocked will
generate IO and will wakeup also the deadlocked process at I/O
completation time. A very lazy ;) but at the same time obviosly right
(that should not harm performances at all) fix could be to replace the
sleep_on() with a sleep_on_timeout(..., 1).

Index: page_io.c
===================================================================
RCS file: /var/cvs/linux/mm/page_io.c,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 page_io.c
--- page_io.c	1999/01/18 01:32:53	1.1.2.1
+++ linux/mm/page_io.c	1999/01/18 20:21:41
@@ -88,7 +88,7 @@
 		/* Make sure we are the only process doing I/O with this swap page. */
 		while (test_and_set_bit(offset,p->swap_lockmap)) {
 			run_task_queue(&tq_disk);
-			sleep_on(&lock_queue);
+			sleep_on_timeout(&lock_queue, 1);
 		}
 
 		/* 


I think we need the swap_lockmap in the shm case because without swap
cache a swapin could happen at the same time of the swapout because
find_in_swap_cache() won't work there. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
