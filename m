Date: Thu, 11 Jan 2001 01:30:18 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.10.10101091618110.2815-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101110116370.8924-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jan 2001, Linus Torvalds wrote:

> So one "conditional aging" algorithm might just be something as simple as

I've done a very easy conditional aging patch (I dont think doing new
functions to scan the active list and the pte's is necessary)

kswapd is not perfectly obeing the counter: if the counter reaches 0, we
keep doing a previously (when counter > 0) called swap_out().

But since swap_out() is only scanning a small part of a mm I dont think
the "non perfect" scanning is a big issue.

Comments? 


diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/include/linux/swap.h linux/include/linux/swap.h
--- linux.orig/include/linux/swap.h	Thu Jan 11 00:27:46 2001
+++ linux/include/linux/swap.h	Thu Jan 11 02:45:04 2001
@@ -101,6 +101,8 @@
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
+extern int bg_page_aging;
+
 extern struct page * reclaim_page(zone_t *);
 extern wait_queue_head_t kswapd_wait;
 extern wait_queue_head_t kreclaimd_wait;
diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/swap.c linux/mm/swap.c
--- linux.orig/mm/swap.c	Thu Jan 11 00:27:45 2001
+++ linux/mm/swap.c	Thu Jan 11 02:12:01 2001
@@ -214,6 +214,8 @@
 	/* Make sure the page gets a fair chance at staying active. */
 	if (page->age < PAGE_AGE_START)
 		page->age = PAGE_AGE_START;
+
+	bg_page_aging++;
 }
 
 void activate_page(struct page * page)
diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/vmscan.c linux/mm/vmscan.c
--- linux.orig/mm/vmscan.c	Thu Jan 11 00:27:45 2001
+++ linux/mm/vmscan.c	Thu Jan 11 02:53:40 2001
@@ -24,6 +24,8 @@
 
 #include <asm/pgalloc.h>
 
+int bg_page_aging = 0;
+
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -60,9 +62,12 @@
 		age_page_up(page);
 		goto out_failed;
 	}
-	if (!onlist)
+	if (!onlist) {
 		/* The page is still mapped, so it can't be freeable... */
+		if(bg_page_aging)
+			bg_page_aging--;
 		age_page_down_ageonly(page);
+	}
 
 	/*
 	 * If the page is in active use by us, or if the page
@@ -650,11 +655,12 @@
  * This function will scan a portion of the active list to find
  * unused pages, those pages will then be moved to the inactive list.
  */
-int refill_inactive_scan(unsigned int priority, int oneshot)
+int refill_inactive_scan(unsigned int priority, int background)
 {
 	struct list_head * page_lru;
 	struct page * page;
-	int maxscan, page_active = 0;
+	int maxscan, page_active;
+	int deactivate = 1;
 	int ret = 0;
 
 	/* Take the lock while messing with the list... */
@@ -674,8 +680,21 @@
 		/* Do aging on the pages. */
 		if (PageTestandClearReferenced(page)) {
 			age_page_up_nolock(page);
-			page_active = 1;
-		} else {
+		} else if (deactivate) {
+
+			/* 
+			 * We're aging down a page. 
+			 * Decrement the counter if it has not reached zero
+			 * yet. If it reached zero, and we are doing background 
+			 * scan and the counter reached 0, stop deactivating pages.
+			 */
+			if (bg_page_aging)
+				bg_page_aging--;
+			else if (background) {
+				deactivate = 0;	
+				continue;
+			}
+
 			age_page_down_ageonly(page);
 			/*
 			 * Since we don't hold a reference on the page
@@ -691,8 +710,6 @@
 						(page->buffers ? 2 : 1)) {
 				deactivate_page_nolock(page);
 				page_active = 0;
-			} else {
-				page_active = 1;
 			}
 		}
 		/*
@@ -705,7 +722,8 @@
 			list_add(page_lru, &active_list);
 		} else {
 			ret = 1;
-			if (oneshot)
+			/* Stop scanning if we're not doing background scan */
+			if (!background)
 				break;
 		}
 	}
@@ -818,7 +836,7 @@
 			schedule();
 		}
 
-		while (refill_inactive_scan(priority, 1)) {
+		while (refill_inactive_scan(priority, 0)) {
 			if (--count <= 0)
 				goto done;
 		}
@@ -921,13 +939,19 @@
 		if (inactive_shortage() || free_shortage()) 
 			do_try_to_free_pages(GFP_KSWAPD, 0);
 
+
+		/* Do some (very minimal) background scanning. */
+
 		/*
-		 * Do some (very minimal) background scanning. This
-		 * will scan all pages on the active list once
+		 * This will scan all pages on the active list once
 		 * every minute. This clears old referenced bits
 		 * and moves unused pages to the inactive list.
 		 */
-		refill_inactive_scan(6, 0);
+		refill_inactive_scan(6, 1);
+	
+		/* This will scan the pte's. */
+		if(bg_page_aging)
+			swap_out(6, 0);
 
 		/* Once a second, recalculate some VM stats. */
 		if (time_after(jiffies, recalc + HZ)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
