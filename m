From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003202029.MAA75378@google.engr.sgi.com>
Subject: Re: More VM balancing issues..
Date: Mon, 20 Mar 2000 12:29:17 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003171847170.831-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 17, 2000 06:59:19 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christopher Zimmerman <zim@av.com>, Stephen Tweedie <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Okay, here it comes, you asked for it ... You know most of it anyway, 
but seeing it all together might help.

1. In a theoretical sense, there are _only_ memory classes. DMA class 
memory, direct mapped class memory and the rest. Code will ask for a 
dma, regular or other class memory (proactive balancing is needed for 
intr context allocations or otherwise when page stealing is impossible
or deadlock prone). Hence, theoretically, it makes sense to decide
how many pages in each memory _class_ we want to keep free for such
requests (based on application type, #cpu, memory, devices and fs
activity). Decisions on when pages need to be stolen should really be
_class_ based.

2. Linux uses zones to implement memory classes. The DMA zone represents
DMA class, the DMA+regular zone represents regular class, and the
DMA+regular+himem zone represents other class. Theoretically, that is
why decisions on page stealing need to be cumulative on the zones.
(This explains why I did most of the code that way).

3. Implementation can of course diverge from theory (like using NRU 
in place of LRU). In Documentation/vm/balance, I have tried laying
down the pros and cons of local vs cumulative balancing:

"In 2.3, zone balancing can be done in one of two ways: depending on the
zone size (and possibly of the size of lower class zones), we can decide
at init time how many free pages we should aim for while balancing any
zone. The good part is, while balancing, we do not need to look at sizes
of lower class zones, the bad part is, we might do too frequent balancing
due to ignoring possibly lower usage in the lower class zones. Also,
with a slight change in the allocation routine, it is possible to reduce
the memclass() macro to be a simple equality.

Another possible solution is that we balance only when the free memory
of a zone _and_ all its lower class zones falls below 1/64th of the
total memory in the zone and its lower class zones. This fixes the 2.2
balancing problem, and stays as close to 2.2 behavior as possible. Also,
the balancing algorithm works the same way on the various architectures,
which have different numbers and types of zones. If we wanted to get
fancy, we could assign different weights to free pages in different
zones in the future."

4. In 2.3.50 and pre1, zone_balance_ratio[] is the ratio of each _class_
of memory that you want free, which is intuitive.

5. For true NUMA machines, there will be memory nodes, and each node
will possibly have dma/regular/himem zones. For memory-hole architectures,
ie DISCONTIG machines, there will again be nodes, but there will be a
lot of nodes with only one class of memory (don't know yet, there are 
not too many people working on this).


Coming specifically to the 2.3.99-pre2 code, I see a couple of bugs:
1. __alloc_pages needs to return NULL instead of doing zone_balance_memory
for the PF_MEMALLOC case.

	if (!(current->flags & PF_MEMALLOC))
               	return(NULL);
        if (zone_balance_memory(zonelist)) {

2. The body of zone_balance_memory() should be replaced with the pre1
code, otherwise there are too many differences/problems to enumerate. 
Unless you are also proposing changes in this area.

I attach a patch against 2.3.99-pre2 to fix these.

The other issues are:
1. In the face of races, you probably want to do a loopback in __alloc_pages
after the zone_balance_memory() returns success. Something like
	if (zone_balance_memory(zonelist)) {
		if (retry)
			return(NULL);
		retry++;
		goto tryagain;
	}

2. Due to purely zone-local computation, the pre2 version will more easily
fall back to lower zones while allocating memory (when it is not neccessary). 
Specially interesting will be cases where the regular zone is much smaller 
than the dma zone, or the himem zone is tiny compared to the regular zone. 
So, gone will be the protection that dma and regular zones enjoyed in 
older versions. 

Kanoj


--- mm/page_alloc.c	Mon Mar 20 09:38:48 2000
+++ mm/page_alloc.c	Mon Mar 20 11:48:02 2000
@@ -152,10 +152,10 @@
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	if (zone->free_pages > zone->pages_high) {
+	if (zone->free_pages > zone->pages_low)
 		zone->zone_wake_kswapd = 0;
+	if (zone->free_pages > zone->pages_high)
 		zone->low_on_memory = 0;
-	}
 }
 
 #define MARK_USED(index, order, area) \
@@ -233,21 +233,22 @@
 	zone = zonelist->zones;
 	for (;;) {
 		zone_t *z = *(zone++);
+		unsigned long free;
 		if (!z)
 			break;
-		if (z->free_pages > z->pages_low)
-			continue;
-
-		z->zone_wake_kswapd = 1;
-		wake_up_interruptible(&kswapd_wait);
+		free = z->free_pages;
+		if (free <= z->pages_high) {
+			if (free <= z->pages_low) {
+				z->zone_wake_kswapd = 1;
+				wake_up_interruptible(&kswapd_wait);
+			}
+			if (free <= z->pages_min)
+				z->low_on_memory = 1;
+		}
 
 		/* Are we reaching the critical stage? */
-		if (!z->low_on_memory) {
-			/* Not yet critical, so let kswapd handle it.. */
-			if (z->free_pages > z->pages_min)
-				continue;
-			z->low_on_memory = 1;
-		}
+		if (!z->low_on_memory)
+			continue;
 		/*
 		 * In the atomic allocation case we only 'kick' the
 		 * state machine, but do not try to free pages
@@ -307,6 +308,8 @@
 				return page;
 		}
 	}
+	if (!(current->flags & PF_MEMALLOC))
+		return(NULL);
 	if (zone_balance_memory(zonelist)) {
 		zone = zonelist->zones;
 		for (;;) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
