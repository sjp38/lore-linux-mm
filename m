Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRQ6-0002k4-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:42:38 -0700
Date: Wed, 25 Sep 2002 22:42:38 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [4/13] use __GFP_NOKILL in mempool_alloc()
Message-ID: <20020926054238.GK22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is permissible to perform mempool allocations with __GFP_FS.
While no current caller does so, the following prevents pool->alloc()
from invoking the OOM killer when the request is serviceable by just
waiting on the mempool.


diff -urN linux-2.5.33/mm/mempool.c linux-2.5.33-mm5/mm/mempool.c
--- linux-2.5.33/mm/mempool.c	2002-09-04 04:02:00.000000000 -0700
+++ linux-2.5.33-mm5/mm/mempool.c	2002-09-08 19:52:51.000000000 -0700
@@ -186,8 +186,12 @@
 	void *element;
 	unsigned long flags;
 	DEFINE_WAIT(wait);
-	int gfp_nowait = gfp_mask & ~(__GFP_WAIT | __GFP_IO);
+	int gfp_nowait;
 	int pf_flags = current->flags;
+
+	gfp_mask |= __GFP_NOKILL;
+
+	gfp_nowait = gfp_mask & ~(__GFP_WAIT | __GFP_IO | __GFP_NOKILL);
 
 repeat_alloc:
 	current->flags |= PF_NOWARN;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
