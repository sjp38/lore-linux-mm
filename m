Received: from smtp3.akamai.com (vwall3.sanmateo.corp.akamai.com [172.23.1.73])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j1FJfK6O012210
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 11:41:21 -0800 (PST)
From: pmeda@akamai.com
Date: Tue, 15 Feb 2005 11:47:43 -0800
Message-Id: <200502151947.LAA20729@allur.sanmateo.akamai.com>
Subject: [PATCH] mempool: protect buffer overflow in mempool_resize
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


 1. Race in mempool_resize: memcpy can copy at the end of the kmalloced elements.
 2. when new_min_nr is same as min_nr, instead of reallocate and copy, just return,
    changed '<' to '<='.
 3. Changed while condition to the same sense of if condition from '>' to '<'; it is
    easy to think with only one of the left and right brains at a time.
  
Signed-off-by: Prasanna Meda <pmeda@akamai.com>


--- Linux/mm/mempool.c	Mon Feb 14 23:03:00 2005
+++ linux/mm/mempool.c	Mon Feb 14 23:03:04 2005
@@ -114,8 +114,8 @@
 	BUG_ON(new_min_nr <= 0);
 
 	spin_lock_irqsave(&pool->lock, flags);
-	if (new_min_nr < pool->min_nr) {
-		while (pool->curr_nr > new_min_nr) {
+	if (new_min_nr <= pool->min_nr) {
+		while (new_min_nr < pool->curr_nr) {
 			element = remove_element(pool);
 			spin_unlock_irqrestore(&pool->lock, flags);
 			pool->free(element, pool->pool_data);
@@ -132,6 +132,12 @@
 		return -ENOMEM;
 
 	spin_lock_irqsave(&pool->lock, flags);
+	if (unlikely(new_min_nr <= pool->min_nr)) {
+		/* Raced, other resize will do our work */
+		spin_unlock_irqrestore(&pool->lock, flags);
+		kfree(new_elements);
+		goto out;
+	}
 	memcpy(new_elements, pool->elements,
 			pool->curr_nr * sizeof(*new_elements));
 	kfree(pool->elements);
@@ -149,7 +155,7 @@
 		} else {
 			spin_unlock_irqrestore(&pool->lock, flags);
 			pool->free(element, pool->pool_data);	/* Raced */
-			spin_lock_irqsave(&pool->lock, flags);
+			goto out;
 		}
 	}
 out_unlock:
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
