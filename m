Date: Mon, 25 Sep 2000 15:56:50 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925155650.F22882@athlon.random>
References: <20000925145856.A13011@athlon.random> <Pine.LNX.4.21.0009251504220.6224-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251504220.6224-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 03:10:51PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 03:10:51PM +0200, Ingo Molnar wrote:
> yep. But i dont understand why this makes any difference - the waitqueue

It makes a difference because your sleeping reads won't get the wakeup
even while they could queue their reserved read request (they have
to wait the FIFO to roll or some write to complete).

> wakeup is FIFO, so any other request will eventually arrive. Could you
> explain this bug a bit better?

Well it may not explain an infinite hang because as you say the write that got
the suprious wakeup will unplug the queue and after some time the reads will be
wakenup. So maybe that wasn't the reason of your hangs because I remeber your
problem looked more like an infinite hang that was only solved by kflushd
writing some more stuff and unplugging the queue as side effect (however I'm
not sure since I never experienced those myself). 

But I hope if it wasn't that one it's the below fix that will help:

Index: mm/filemap.c
===================================================================
RCS file: /home/andrea/cvs/linux/mm/filemap.c,v
retrieving revision 1.1.1.5.2.3
retrieving revision 1.1.1.5.2.4
diff -u -r1.1.1.5.2.3 -r1.1.1.5.2.4
--- mm/filemap.c	2000/09/21 03:11:53	1.1.1.5.2.3
+++ mm/filemap.c	2000/09/25 03:33:31	1.1.1.5.2.4
@@ -622,8 +622,8 @@
 
 	add_wait_queue(&page->wait, &wait);
 	do {
-		sync_page(page);
 		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
+		sync_page(page);
 		if (!PageLocked(page))
 			break;
 		schedule();
Index: fs/buffer.c
===================================================================
RCS file: /home/andrea/cvs/linux/fs/buffer.c,v
retrieving revision 1.1.1.5.2.1
retrieving revision 1.1.1.5.2.2
diff -u -r1.1.1.5.2.1 -r1.1.1.5.2.2
--- fs/buffer.c	2000/09/06 19:57:51	1.1.1.5.2.1
+++ fs/buffer.c	2000/09/25 03:33:30	1.1.1.5.2.2
@@ -147,8 +147,8 @@
 	atomic_inc(&bh->b_count);
 	add_wait_queue(&bh->b_wait, &wait);
 	do {
-		run_task_queue(&tq_disk);
 		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
+		run_task_queue(&tq_disk);
 		if (!buffer_locked(bh))
 			break;
 		schedule();


Think if the buffer returns locked between set_task_state(tsk,
TASK_UNINTERRUPTIBLE) and if (!buffer_locked(bh)). The window is very small but
it looks a genuine window for a deadlock. (and this one could sure explain
infinite hangs in read... even if it looks even less realistic than the
EXCLUSIVE task thing)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
