Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EBB9D6007D3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:26:16 -0500 (EST)
From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: [RFC,PATCH 1/2] dmapool: Don't warn when allowed to retry allocation.
Date: Wed, 2 Dec 2009 15:20:12 +0200
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi>
In-Reply-To: <200912021518.35877.roger.oksanen@cs.helsinki.fi>
MIME-Version: 1.0
Message-Id: <200912021520.12419.roger.oksanen@cs.helsinki.fi>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Roger Oksanen <roger.oksanen@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

dmapool: Don't warn when allowed to retry allocation.

dmapool uses it's own wait logic, so allocations failing may be retried
if the called specified a waiting GFP_*. Unnecessary warnings only cause
confusion.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
---
 mm/dmapool.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 3df0637..e270f7f 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -310,6 +310,8 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 	struct dma_page *page;
 	size_t offset;
 	void *retval;
+	int tries = 0;
+	const gfp_t can_wait = mem_flags & __GFP_WAIT;
 
 	spin_lock_irqsave(&pool->lock, flags);
  restart:
@@ -317,9 +321,11 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 		if (page->offset < pool->allocation)
 			goto ready;
 	}
-	page = pool_alloc_page(pool, GFP_ATOMIC);
+	tries++;
+	page = pool_alloc_page(pool, GFP_ATOMIC | (can_wait && tries % 10
+						  ? __GFP_NOWARN : 0));
 	if (!page) {
-		if (mem_flags & __GFP_WAIT) {
+		if (can_wait) {
 			DECLARE_WAITQUEUE(wait, current);
 
 			__set_current_state(TASK_INTERRUPTIBLE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
