Date: Fri, 13 May 2005 11:50:54 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: mempool - only init waitqueue in slow path
Message-ID: <20050513155054.GB4750@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Here's a small patch to improve the performance of mempool_alloc by only 
initializing the wait queue when we're about to wait.

		-ben
-- 
"Time is what keeps everything from happening all at once." -- John Wheeler

Signed-off-by: Benjamin LaHaise <benjamin.c.lahaise@intel.com>
diff -purN v2.6.12-rc4/mm/mempool.c mempool-rc4/mm/mempool.c
--- v2.6.12-rc4/mm/mempool.c	2005-05-09 15:47:01.000000000 -0400
+++ mempool-rc4/mm/mempool.c	2005-05-13 10:04:54.000000000 -0400
@@ -197,7 +197,7 @@ void * mempool_alloc(mempool_t *pool, un
 {
 	void *element;
 	unsigned long flags;
-	DEFINE_WAIT(wait);
+	wait_queue_t wait;
 	int gfp_temp;
 
 	might_sleep_if(gfp_mask & __GFP_WAIT);
@@ -228,6 +228,7 @@ repeat_alloc:
 
 	/* Now start performing page reclaim */
 	gfp_temp = gfp_mask;
+	init_wait(&wait);
 	prepare_to_wait(&pool->wait, &wait, TASK_UNINTERRUPTIBLE);
 	smp_mb();
 	if (!pool->curr_nr)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
