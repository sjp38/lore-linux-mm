Date: Tue, 3 Mar 1998 18:05:18 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [uPATCH] small kswapd improvement ???
Message-ID: <Pine.LNX.3.91.980303180022.414A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I remember the 1.1 or 1.2 days when Stephen reworked the
swap code and I played around with a small piece of
vmscan.c. Back then a simple bug was encountered and 'fixed'
by always starting the memory scan at adress 0, which gives
a highly unfair and inefficient aging process.

I think I have 'corrected' the code. Not so much made a
large performance increase, but merely a 'correction' for
the sake of correctness and a small improvement.

Patch attached.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

--- linux/mm/vmscan.c.orig	Tue Mar  3 14:57:53 1998
+++ linux/mm/vmscan.c	Tue Mar  3 17:51:22 1998
@@ -333,14 +333,15 @@
 	 * Go through process' page directory.
 	 */
 	address = p->swap_address;
-	p->swap_address = 0;
 
 	/*
 	 * Find the proper vm-area
 	 */
 	vma = find_vma(p->mm, address);
-	if (!vma)
+	if (!vma) {
+		p->swap_address = 0;
 		return 0;
+	}
 	if (address < vma->vm_start)
 		address = vma->vm_start;
 
