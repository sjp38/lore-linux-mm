Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRPu-0002jb-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:42:26 -0700
Date: Wed, 25 Sep 2002 22:42:26 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [2/13] honor __GFP_NOKILL
Message-ID: <20020926054226.GI22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In order to honor __GFP_NOKILL, the OOM killer should not be invoked
when the __GFP_NOKILL flag is set. try_to_free_pages() is the sole
caller of out_of_memory().


diff -urN linux-2.5.33/mm/vmscan.c linux-2.5.33-mm5/mm/vmscan.c
--- linux-2.5.33/mm/vmscan.c	2002-09-04 04:02:00.000000000 -0700
+++ linux-2.5.33-mm5/mm/vmscan.c	2002-09-08 19:57:30.000000000 -0700
@@ -688,7 +688,7 @@
 		blk_congestion_wait(WRITE, HZ/4);
 		shrink_slab(total_scanned, gfp_mask);
 	}
-	if (gfp_mask & __GFP_FS)
+	if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NOKILL))
 		out_of_memory();
 	return 0;
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
