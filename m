Message-ID: <393D8E26.E51525CB@norran.net>
Date: Wed, 07 Jun 2000 01:49:58 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: reduce shrink_mmap rate of failure (initial attempt)
Content-Type: multipart/mixed;
 boundary="------------CB28477015C46C7D1C3F6985"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zlatko Calusic <zlatko@iskon.hr>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------CB28477015C46C7D1C3F6985
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi all,

This is a trivial first attempt to reduce shrink_mmap failures
(leading to swap)

It is against 2.4.0-test1-ac7-riel3 but that is almost what
we have currently - and it is trivial to apply with an editor.

It might be possible to improve this further - but it is a start.
(Time for bed...)

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------CB28477015C46C7D1C3F6985
Content-Type: text/plain; charset=us-ascii;
 name="patch-filemap"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-filemap"

--- /usr/src/linux/mm/filemap.c.orig	Sat Jun  3 19:09:16 2000
+++ /usr/src/linux/mm/filemap.c	Wed Jun  7 01:21:19 2000
@@ -332,6 +332,14 @@
 		if (page->age)
 			goto dispose_continue;
 
+		/*
+		 * Page is from a zone we don't care about.
+		 * Don't drop page cache entries in vain.
+		 * Must be done before count - or do a count++
+		 */
+		if (page->zone->free_pages > page->zone->pages_high)
+			goto dispose_continue;
+
 		count--;
 		/*
 		 * Avoid unscalable SMP locking for pages we can
@@ -367,13 +375,6 @@
 				goto made_buffer_progress;
 			}
 		}
-
-		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto unlock_continue;
 
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its

--------------CB28477015C46C7D1C3F6985--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
