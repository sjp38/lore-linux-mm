Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA07485
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 18:20:46 -0500
Date: Tue, 3 Mar 1998 00:10:18 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH] free_memory_available() fix
Message-ID: <Pine.LNX.3.91.980303000549.3788A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi there,

Here's the patch to free_memory_available() in mm/page_alloc.c.

The comment above the source code should give you enough
info to get started on my algoritm...

Please verify it, I've only compiled it :-(, but it
should be correct nevertheless... (just remember to
read it first).

The patch is against 2.1.89-pre2, but judging from the
posts to linux-kernel, it should apply to newer versions
without a hitch.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

-----------------------> cut here <------------------------------

--- page_alloc.pre89-2	Mon Mar  2 23:32:16 1998
+++ page_alloc.c	Tue Mar  3 00:03:48 1998
@@ -108,22 +108,51 @@
  * but this had better return false if any reasonable "get_free_page()"
  * allocation could currently fail..
  *
- * Right now we just require that the highest memory order should
- * have at least two entries. Whether this makes sense or not
- * under real load is to be tested, but it also gives us some
- * guarantee about memory fragmentation (essentially, it means
- * that there should be at least two large areas available).
+ * Currently we approve of the following situations:
+ * - the highest memory order has two entries
+ * - the highest memory order has one free entry and:
+ *	- the next-highest memory order has two free entries
+ * - the highest memory order has one free entry and:
+ *	- the next-highest memory order has one free entry
+ *	- the next-next-highest memory order has two free entries
+ *
+ * [previously, there had to be two entries of the highest memory
+ *  order, but this lead to problems on large-memory machines.]
  */
 int free_memory_available(void)
 {
-	int retval;
+	int retval = 0;
 	unsigned long flags;
-	struct free_area_struct * last = free_area + NR_MEM_LISTS - 1;
+	struct free_area_struct * biggest = free_area + NR_MEM_LISTS - 1;
+	struct free_area_struct * bigger = free_area + NR_MEM_LISTS - 2;
+	struct free_area_struct * big = free_area + NR_MEM_LISTS - 3;
 
 	spin_lock_irqsave(&page_alloc_lock, flags);
-	retval =  (last->next != memory_head(last)) && (last->next->next != memory_head(last));
+	if (biggest->next != memory_head(biggest)) {
+		retval = 4;
+		if (biggest->next->next != memory_head(biggest))
+			retval += 4;
+	} else {
+	/* we want at least one free area of the 'biggest' size */
+		goto out;
+	}
+	if (bigger->next != memory_head(bigger)) {
+		retval += 2;
+		if (bigger->next->next != memory_head(bigger))
+			retval += 2;
+	} else {
+	/* if we have only one free area of the 'biggest' size, we also
+	 * want one of the 'bigger' size */
+		goto out;
+	}
+	if (big->next != memory_head(big)) {
+		retval += 1;
+		if (big->next->next != memory_head(big))
+			retval += 1;
+	}
+out:
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
-	return retval;
+	return retval > 7;
 }
 
 static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
