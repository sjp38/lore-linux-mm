Date: Mon, 18 Mar 2002 14:44:56 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] oom killer fix ???
Message-ID: <Pine.LNX.4.44L.0203181443060.2181-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, arjan@fenrus.demon.nl, dwmw2@infradead.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi,

the patch below is another attempt at fixing the OOM killer,
it works by:

1) making sure userland allocations can always allocate
   right down to zone->pages_min, albeit slowly

2) not OOM killing if any zone has more than zone->pages_min
   in freeable pages

I'd appreciate it if the CONFIG_DISCONTIGMEM people could give
this patch a try.

thank you,

Rik
-- 
<insert bitkeeper endorsement here>

http://www.surriel.com/		http://distro.conectiva.com/


===== mm/vmscan.c 1.97 vs edited =====
--- 1.97/mm/vmscan.c	Thu Feb 28 20:38:19 2002
+++ edited/mm/vmscan.c	Mon Mar 18 14:38:06 2002
@@ -605,7 +605,7 @@
 	 * Hmm.. Cache shrink failed - time to kill something?
 	 * Mhwahahhaha! This is the part I really like. Giggle.
 	 */
-	if (!ret && free_low(ANY_ZONE) > 0)
+	if (!ret && free_min(ANY_ZONE) > 0)
 		out_of_memory();

 	return ret;
@@ -751,23 +751,19 @@
 {
 	DECLARE_WAITQUEUE(wait, current);

-	/* Enough free RAM, we can easily keep up with memory demand. */
 	add_wait_queue(&kswapd_wait, &wait);
 	set_current_state(TASK_INTERRUPTIBLE);

+	/* Don't let the processes waiting on memory get stuck, ever. */
+	wake_up(&kswapd_done);
+
+	/* Enough free RAM, we can easily keep up with memory demand. */
 	if (free_high(ALL_ZONES) <= 0) {
-		wake_up(&kswapd_done);
 		schedule_timeout(HZ);
 		remove_wait_queue(&kswapd_wait, &wait);
 		return;
 	}
 	remove_wait_queue(&kswapd_wait, &wait);
-
-	/*
-	 * kswapd is going to sleep for a long time. Wake up the waiters to
-	 * prevent them to get stuck while waiting for us.
-	 */
-	wake_up(&kswapd_done);

 	/* OK, the VM is very loaded. Sleep instead of using all CPU. */
 	set_current_state(TASK_UNINTERRUPTIBLE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
