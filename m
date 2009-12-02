Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 82D796007D3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:26:17 -0500 (EST)
From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: [RFC,PATCH 2/2] dmapool: Honor GFP_* flags.
Date: Wed, 2 Dec 2009 15:23:39 +0200
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi>
In-Reply-To: <200912021518.35877.roger.oksanen@cs.helsinki.fi>
MIME-Version: 1.0
Message-Id: <200912021523.39696.roger.oksanen@cs.helsinki.fi>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Roger Oksanen <roger.oksanen@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

dmapool: Honor GFP_* flags.

dmapool silently discarded GFP flags and was always allowed to use the 
emergency pool.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
---
 mm/dmapool.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 2fdd7a1..e270f7f 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -312,6 +312,8 @@
 	void *retval;
 	int tries = 0;
 	const gfp_t can_wait = mem_flags & __GFP_WAIT;
+	/* dma_pool_alloc uses its own wait logic */
+	mem_flags &= ~__GFP_WAIT;
 
 	spin_lock_irqsave(&pool->lock, flags);
  restart:
@@ -320,7 +322,7 @@
 			goto ready;
 	}
 	tries++;
-	page = pool_alloc_page(pool, GFP_ATOMIC | (can_wait && tries % 10
+	page = pool_alloc_page(pool, mem_flags | (can_wait && tries % 10
 						  ? __GFP_NOWARN : 0));
 	if (!page) {
 		if (can_wait) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
