Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 176ZSb-0004xF-00
	for <linux-mm@kvack.org>; Sat, 11 May 2002 09:11:05 -0700
Date: Sat, 11 May 2002 09:11:05 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [miltonm@realtime.net: lock_kiobuf page locking]
Message-ID: <20020511161104.GZ15756@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This looks good to me; thought I'd toss it out here for review.

Cheers,
Bill

----- Forwarded message from "Milton D. Miller II" <miltonm@realtime.net> -----

Envelope-to: wli@holomorphy.com
Delivery-date: Mon, 06 May 2002 21:44:36 -0700
Date: Mon, 6 May 2002 23:45:47 -0500 (CDT)
From: "Milton D. Miller II" <miltonm@realtime.net>
To: wli@holomorphy.com
Subject: lock_kiobuf page locking


Just noticed this with the wait_page to wait_page_locked diff ...

===== memory.c 1.61 vs edited =====
--- 1.61/mm/memory.c	Sat May  4 18:07:03 2002
+++ edited/memory.c	Mon May  6 18:18:19 2002
@@ -693,8 +693,8 @@
 {
 	struct kiobuf *iobuf;
 	int i, j;
-	struct page *page, **ppage;
-	int doublepage = 0;
+	struct page *page, **ppage, *dpage = NULL;
+	int doublepage;
 	int repeat = 0;
 	
  repeat:
@@ -747,9 +747,14 @@
 		 * but if it happens more than once, chances
 		 * are we have a double-mapped page. 
 		 */
-		if (++doublepage >= 3) 
-			return -EINVAL;
+		if (dpage != page) {
+			dpage = page;
+			doublepage = 0;
+		} else {
+			if (++doublepage >= 3)
+				return -EINVAL;
 		
+	} else {
 		/* Try again...  */
 		wait_on_page_locked(page);
 	}

----- End forwarded message -----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
