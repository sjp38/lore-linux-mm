Date: Wed, 25 May 2005 10:42:34 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] small valid_swaphandles() optimization
Message-ID: <20050525134234.GA16054@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew, Hugh,

The following patch, relative to valid_swaphandles(), moves the EOF 
check outside validity check loop, saving a few instructions. 

--- a/mm/swapfile.c.orig	2005-05-25 15:45:18.000000000 -0300
+++ b/mm/swapfile.c	2005-05-25 16:20:45.000000000 -0300
@@ -1713,11 +1713,12 @@
 		toff++, i--;
 	*offset = toff;
 
+	/* Don't read-ahead past the end of the swap area */
+	if (toff+i >= swapdev->max)
+		i = swapdev->max - toff - 1;
+
 	swap_device_lock(swapdev);
 	do {
-		/* Don't read-ahead past the end of the swap area */
-		if (toff >= swapdev->max)
-			break;
 		/* Don't read in free or bad pages */
 		if (!swapdev->swap_map[toff])
 			break;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
