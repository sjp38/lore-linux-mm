Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA02138
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 09:15:16 -0500
Date: Thu, 26 Mar 1998 15:08:12 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: [PATCH] linux-2.1.91-pre2 crash fixed
Message-ID: <Pine.LNX.3.91.980326150617.566A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I've found a small typo in mm/filemap.c, which prevented
proper operation of the VM subsystem and, in effect, threw
kswapd in a loop.

In effect, it refused to free buffer memory when it was
_above_ the minimum percentage :)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+

--- linux/mm/filemap.c.pre91-2	Thu Mar 26 15:03:44 1998
+++ linux/mm/filemap.c	Thu Mar 26 15:04:25 1998
@@ -152,7 +152,7 @@
 			} while (tmp != bh);
 
 			/* Refuse to swap out all buffer pages */
-			if ((buffermem >> PAGE_SHIFT) * 100 > (buffer_mem.min_percent * num_physpages))
+			if ((buffermem >> PAGE_SHIFT) * 100 < (buffer_mem.min_percent * num_physpages))
 				goto next;
 		}
 
