From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003172223.OAA37594@google.engr.sgi.com>
Subject: Re: More VM balancing issues..
Date: Fri, 17 Mar 2000 14:23:27 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003171330050.987-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 17, 2000 02:07:09 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christopher Zimmerman <zim@av.com>, Stephen Tweedie <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

And while you are at it, could you try this patch too. This "fixes"
the issues I pointed out earlier in the recent balancing patch. This
is against 2.3.99-pre1.

Thanks.

Kanoj

--- mm/page_alloc.c	Wed Mar 15 09:30:24 2000
+++ mm/page_alloc.c	Fri Mar 17 14:19:26 2000
@@ -148,8 +148,10 @@
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	if (classfree(zone) > zone->pages_high)
+	if (classfree(zone) > zone->pages_high) {
 		zone->zone_wake_kswapd = 0;
+		zone->low_on_memory = 0;
+	}
 }
 
 #define MARK_USED(index, order, area) \
@@ -269,8 +271,11 @@
 			{
 				extern wait_queue_head_t kswapd_wait;
 
-				z->zone_wake_kswapd = 1;
-				wake_up_interruptible(&kswapd_wait);
+				if (free <= z->pages_low) {
+					z->zone_wake_kswapd = 1;
+					wake_up_interruptible(&kswapd_wait);
+				} else
+					z->zone_wake_kswapd = 0;
 
 				if (free <= z->pages_min)
 					z->low_on_memory = 1;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
