Date: Mon, 20 Mar 2000 14:06:47 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] first bit of vm balancing fixes for 2.3.52-1
In-Reply-To: <Pine.LNX.4.10.10003201329470.4818-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10003201350100.4934-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 20 Mar 2000, Linus Torvalds wrote:
> 
> My code expliticly says: ok, walk the list of zones, if any of them have
> plenty of memory free just allocate it.

Ugh. The "plenty" test should take "zone->low_on_memory" into account too.

This should fix that, and get the PF_MEMALLOC case right too.

This way we explicitly try to avoid any zones that are being balanced
(we'll still allocate from such a zone, it's just that we'll go through
the balancing motions first - think of it as a way of saying "we want to
get OUT of the 'low_on_memory' state quicky, not make it worse").

		Linus

-----
--- v2.3.99-pre2/linux/mm/page_alloc.c	Sun Mar 19 18:35:31 2000
+++ linux/mm/page_alloc.c	Mon Mar 20 14:03:34 2000
@@ -271,6 +271,14 @@
 	zone_t **zone = zonelist->zones;
 
 	/*
+	 * If this is a recursive call, we'd better
+	 * do our best to just allocate things without
+	 * further thought.
+	 */
+	if (current->flags & PF_MEMALLOC)
+		goto allocate_ok;
+
+	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
 	 * will sooner or later tripped up by a schedule().)
 	 *
@@ -283,32 +291,22 @@
 			break;
 		if (!z->size)
 			BUG();
-		/*
-		 * If this is a recursive call, we'd better
-		 * do our best to just allocate things without
-		 * further thought.
-		 */
-		if (!(current->flags & PF_MEMALLOC)) {
-			/* Are we low on memory? */
-			if (z->free_pages <= z->pages_low)
-				continue;
-		}
-		/*
-		 * This is an optimization for the 'higher order zone
-		 * is empty' case - it can happen even in well-behaved
-		 * systems, think the page-cache filling up all RAM.
-		 * We skip over empty zones. (this is not exact because
-		 * we do not take the spinlock and it's not exact for
-		 * the higher order case, but will do it for most things.)
-		 */
-		if (z->free_pages) {
+
+		/* Are we low on memory? Don't make it worse.. */
+		if (!z->low_on_memory && z->free_pages > z->pages_low) {
 			struct page *page = rmqueue(z, order);
 			if (page)
 				return page;
 		}
 	}
+
+	/*
+	 * Ok, no obvious zones were available, start
+	 * balancing things a bit..
+	 */
 	if (zone_balance_memory(zonelist)) {
 		zone = zonelist->zones;
+allocate_ok:
 		for (;;) {
 			zone_t *z = *(zone++);
 			if (!z)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
