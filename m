From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003270803.AAA14950@google.engr.sgi.com>
Subject: [RFT] balancing patch
Date: Mon, 27 Mar 2000 00:03:43 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

People who are experiencing degraded performance in the latest 2.3
releases due to overactive kswapd can apply the attached patch to 
see whether it helps them. If you try the patch, and see that it
helps, or hinders, your system performance, please let me know. 

Thanks.

Kanoj

--- mm/page_alloc.c	Tue Mar 21 16:29:32 2000
+++ mm/page_alloc.c	Tue Mar 21 18:24:15 2000
@@ -235,19 +235,16 @@
 		zone_t *z = *(zone++);
 		if (!z)
 			break;
-		if (z->free_pages > z->pages_low)
-			continue;
-
-		z->zone_wake_kswapd = 1;
-		wake_up_interruptible(&kswapd_wait);
 
 		/* Are we reaching the critical stage? */
-		if (!z->low_on_memory) {
-			/* Not yet critical, so let kswapd handle it.. */
-			if (z->free_pages > z->pages_min)
-				continue;
+		if (z->free_pages <= z->pages_min)
 			z->low_on_memory = 1;
+		if (z->free_pages <= z->pages_low) {
+			z->zone_wake_kswapd = 1;
+			wake_up_interruptible(&kswapd_wait);
 		}
+		if (!z->low_on_memory)
+			continue;
 		/*
 		 * In the atomic allocation case we only 'kick' the
 		 * state machine, but do not try to free pages
@@ -293,7 +290,7 @@
 			BUG();
 
 		/* Are we supposed to free memory? Don't make it worse.. */
-		if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {
+		if (!z->low_on_memory && z->free_pages > z->pages_min) {
 			struct page *page = rmqueue(z, order);
 			if (page)
 				return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
