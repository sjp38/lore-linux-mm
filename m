Date: Sat, 9 Jun 2001 00:55:15 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM tuning patch, take 2
In-Reply-To: <Pine.LNX.4.21.0106082248320.3343-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0106090050240.10415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Jonathan Morton <chromi@cyberspace.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2001, Marcelo Tosatti wrote:
> On Sat, 9 Jun 2001, Rik van Riel wrote:
> 
> <snip>
> 
> > I have a similar patch which makes processes wait on IO completion
> > when they find too many dirty pages on the inactive_dirty list ;)
> 
> If we ever want to make that PageLaunder thing reality (well, if we realy
> want a decent VM we _need_ that) we need to make the accouting on a
> buffer_head basis and decrease the amount of data being written out to
> disk at end_buffer_io_sync(). 
> 
> The reason is write() --- its impossible to account for pages written
> via write(). 
> 
> :( 

This doesn't seem to be a big issue in my patch at all ...
See below for the patch, I'll port it to a newer kernel RSN.

The reasons why it's not a big issue with the patch:

1) we scan only part of the inactive list in the first
   scanning round, when we don't encounter freeable pages
   there, we go into the launder_loop, asynchronously write
   pages to disk and SCAN TWICE THE AMOUNT we scanned in the
   first loop ... here we can encounter clean, freeable pages

2) the inactive_list doesn't get re-ordered, if we write out
   a page we'll see it again as soon as it unlocks, instead of
   us waiting until the whole inactive_dirty list has "rolled
   over" and we've submitted all pages for IO

3) if, in the launder_loop, we failed to free pages, we leave
   a reminder for other tasks to sleep synchronously on the last
   piece of IO they submit, this way we:
	3a) don't waste CPU spinning on page_launder()
	3b) get freeable pages with less IO than we used to

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)



--- linux-2.4.5-ac2/mm/vmscan.c.orig	Fri Jun  1 22:31:48 2001
+++ linux-2.4.5-ac2/mm/vmscan.c	Mon Jun  4 11:27:33 2001
@@ -430,11 +430,19 @@
 #define MAX_LAUNDER 		(4 * (1 << page_cluster))
 int page_launder(int gfp_mask, int sync)
 {
+	static int cannot_free_pages;
 	int launder_loop, maxscan, cleaned_pages, maxlaunder;
 	int can_get_io_locks;
-	struct list_head * page_lru;
+	struct list_head * page_lru, * marker_lru;
 	struct page * page;
 
+	/* Our bookmark of where we are in the inactive_dirty list. */
+	struct page marker_page_struct = {
+		flags: (1<<PG_marker),
+		lru: { NULL, NULL },
+	};
+	marker_lru = &marker_page_struct.lru;
+
 	/*
 	 * We can only grab the IO locks (eg. for flushing dirty
 	 * buffers to disk) if __GFP_IO is set.
@@ -447,10 +455,36 @@
 
 dirty_page_rescan:
 	spin_lock(&pagemap_lru_lock);
-	maxscan = nr_inactive_dirty_pages;
-	while ((page_lru = inactive_dirty_list.prev) != &inactive_dirty_list &&
-				maxscan-- > 0) {
+	/*
+	 * By not scanning all inactive dirty pages we'll write out
+	 * really old dirty pages before evicting newer clean pages.
+	 * This should cause some LRU behaviour if we have a large
+	 * amount of inactive pages (due to eg. drop behind).
+	 *
+	 * It also makes us accumulate dirty pages until we have enough
+	 * to be worth writing to disk without causing excessive disk
+	 * seeks and eliminates the infinite penalty clean pages incurred
+	 * vs. dirty pages.
+	 */
+	maxscan = nr_inactive_dirty_pages / 4;
+	if (launder_loop)
+		maxscan *= 2;
+	list_add_tail(marker_lru, &inactive_dirty_list);
+	while ((page_lru = marker_lru->prev) != &inactive_dirty_list &&
+			maxscan-- > 0 && free_shortage()) {
 		page = list_entry(page_lru, struct page, lru);
+		/* We move the bookmark forward by flipping the page ;) */
+		list_del(page_lru);
+		list_add(page_lru, marker_lru);
+
+		/* Don't waste CPU if chances are we cannot free anything. */
+		if (launder_loop && maxlaunder < 0 && cannot_free_pages)
+			break;
+	
+		/* Skip other people's marker pages. */
+		if (PageMarker(page)) {
+			continue;
+		}
 
 		/* Wrong page on list?! (list corruption, should not happen) */
 		if (!PageInactiveDirty(page)) {
@@ -472,11 +506,9 @@
 
 		/*
 		 * The page is locked. IO in progress?
-		 * Move it to the back of the list.
+		 * Skip the page, we'll take a look when it unlocks.
 		 */
 		if (TryLockPage(page)) {
-			list_del(page_lru);
-			list_add(page_lru, &inactive_dirty_list);
 			continue;
 		}
 
@@ -490,10 +522,8 @@
 			if (!writepage)
 				goto page_active;
 
-			/* First time through? Move it to the back of the list */
+			/* First time through? Skip the page. */
 			if (!launder_loop) {
-				list_del(page_lru);
-				list_add(page_lru, &inactive_dirty_list);
 				UnlockPage(page);
 				continue;
 			}
@@ -552,7 +582,7 @@
 
 			/* The buffers were not freed. */
 			if (!clearedbuf) {
-				add_page_to_inactive_dirty_list(page);
+				add_page_to_inactive_dirty_list_marker(page);
 
 			/* The page was only in the buffer cache. */
 			} else if (!page->mapping) {
@@ -608,6 +638,8 @@
 			UnlockPage(page);
 		}
 	}
+	/* Remove our marker. */
+	list_del(marker_lru);
 	spin_unlock(&pagemap_lru_lock);
 
 	/*
@@ -626,12 +658,22 @@
 		/* If we cleaned pages, never do synchronous IO. */
 		if (cleaned_pages)
 			sync = 0;
+		/* If we cannot free pages, always sleep on IO. */
+		else if (cannot_free_pages)
+			sync = 1;
 		/* We only do a few "out of order" flushes. */
 		maxlaunder = MAX_LAUNDER;
-		/* Kflushd takes care of the rest. */
+		/* Let bdflush take care of the rest. */
 		wakeup_bdflush(0);
 		goto dirty_page_rescan;
 	}
+
+	/*
+	 * If we failed to free pages (because all pages are dirty)
+	 * we remember this for the next time. This will prevent us
+	 * from wasting too much CPU here.
+	 */
+	cannot_free_pages = !cleaned_pages;
 
 	/* Return the number of pages moved to the inactive_clean list. */
 	return cleaned_pages;
--- linux-2.4.5-ac2/include/linux/mm.h.orig	Fri Jun  1 22:33:26 2001
+++ linux-2.4.5-ac2/include/linux/mm.h	Mon Jun  4 09:49:52 2001
@@ -282,6 +282,7 @@
 #define PG_skip			10
 #define PG_inactive_clean	11
 #define PG_highmem		12
+#define PG_marker		13
 				/* bits 21-29 unused */
 #define PG_arch_1		30
 #define PG_reserved		31
@@ -353,6 +354,9 @@
 #define PageInactiveClean(page)	test_bit(PG_inactive_clean, &(page)->flags)
 #define SetPageInactiveClean(page)	set_bit(PG_inactive_clean, &(page)->flags)
 #define ClearPageInactiveClean(page)	clear_bit(PG_inactive_clean, &(page)->flags)
+
+#define PageMarker(page)	test_bit(PG_marker, &(page)->flags)
+#define SetPageMarker(page)	set_bit(PG_marker, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)		test_bit(PG_highmem, &(page)->flags)
--- linux-2.4.5-ac2/include/linux/fs.h.orig	Mon Jun  4 09:41:21 2001
+++ linux-2.4.5-ac2/include/linux/fs.h	Mon Jun  4 09:49:39 2001
@@ -1309,7 +1309,6 @@
 extern void set_blocksize(kdev_t, int);
 extern struct buffer_head * bread(kdev_t, int, int);
 extern void wakeup_bdflush(int wait);
-extern int flush_dirty_buffers(int);
 
 extern int brw_page(int, struct page *, kdev_t, int [], int);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
