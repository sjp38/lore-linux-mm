Date: Wed, 28 Mar 2001 23:59:58 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: [PATCH] Reclaim orphaned swap pages
Message-ID: <20010328235958.A1724@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Rik, the patch below tries to reclaim orphaned swap pages after
swapped processes exit.  I've only given it basic testing but I want
to get feedback on it sooner rather than later --- we need to do
_something_ about this problem!

The patch works completely differently to the release-on-exit diffs:
this one works in refill_inactive(), so has zero impact on the hot
paths.  It also works by looking for such orphaned pages in the swap
cache, not by examining swap entries --- it is much cheaper to find
a swap entry for a given page than to find the swap cache page for a
given swap entry.

The patch should be fairly non-intrusive --- all it does is to clear
the age, referenced bit and dirty bit on pages which are swap cached
and which have page count and swap count == 1.  The normal reclaim
path will then recycle these pages rapidly.

We can also extend this to do the swap reclaim that we want.
Currently the recycling only happens if the page count is one, but in
theory we can also do this for pages with higher refcounts if we are
low on swap --- as long as the swap ref is one on a swap cached page,
we know that the swap cache is the only reference to the swap entry
and no ptes can possibly point to that location on disk, so it's safe
to reclaim the swap cache at that point.

Cheers,
 Stephen

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.2-swapreclaim.patch"

--- linux-2.4.2-0.1.42/mm/vmscan.c.~1~	Wed Mar 28 18:07:20 2001
+++ linux-2.4.2-0.1.42/mm/vmscan.c	Wed Mar 28 19:34:35 2001
@@ -704,6 +704,32 @@
 	return freed_pages + flushed_pages;
 }
 
+/* Check to see if a given page is a swap cache page with no further
+ * references to the swap entry nor to the page in memory.  Clear all of
+ * the aging information for such pages to force them immediately onto
+ * the inactive_clean list for page reclamation. */
+
+static void check_orphaned_swap(struct page *page)
+{
+	spinlock_t *pg_lock = PAGECACHE_LOCK(page);
+
+	if (spin_trylock(pg_lock)) {
+		/* Re-test the page state under protection of the proper
+		 * spinlock */
+		if (PageSwapCache(page) && atomic_read(&page->count) == 1) {
+			if (!TryLockPage(page)) {
+				if (swap_count(page) == 1) {
+					ClearPageDirty(page);
+					ClearPageReferenced(page);
+					page->age = 0;
+				}
+				UnlockPage(page);
+			}
+		}
+		spin_unlock(pg_lock);
+	}
+}
+
 /**
  * refill_inactive_scan - scan the active list and find pages to deactivate
  * @priority: the priority at which to scan
@@ -728,6 +754,12 @@
 		/* Wrong page on list?! (list corruption, should not happen) */
 		if (!PageActive(page))
 			BUG();
+
+		/* Special case: orphaned swap cache pages should be
+		 * reclaimed as quickly as possible, regardless of their
+		 * age or whether they are dirty or not. */
+		if (PageSwapCache(page) && atomic_read(&page->count) == 1)
+			check_orphaned_swap(page);
 
 		/* Do aging on the pages. */
 		if (PageTestandClearReferenced(page)) {

--fdj2RfSjLxBAspz7--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
