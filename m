Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 51C076B0258
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:52:50 -0400 (EDT)
Received: by pasz6 with SMTP id z6so50554367pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:52:50 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id xi10si12211952pab.18.2015.10.21.02.52.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Oct 2015 02:52:49 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 21 Oct 2015 19:52:44 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id DD4BB2BB0052
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 20:52:42 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9L9qYeJ49021076
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 20:52:42 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9L9q9Zw015922
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 20:52:10 +1100
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm/slub: calculate start order with reserved in consideration
Date: Wed, 21 Oct 2015 17:51:06 +0800
Message-Id: <1445421066-10641-4-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

In function slub_order(), the order starts from max(min_order,
get_order(min_objects * size)). When (min_objects * size) has different
order with (min_objects * size + reserved), it will skip this order by the
check in the loop.

This patch optimizes this a little by calculating the start order with
reserved in consideration and remove the check in loop.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 37552f8..62b228e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2808,19 +2808,15 @@ static inline int slab_order(int size, int min_objects,
 	if (order_objects(min_order, size, reserved) > MAX_OBJS_PER_PAGE)
 		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
 
-	for (order = max(min_order, get_order(min_objects * size));
+	for (order = max(min_order, get_order(min_objects * size + reserved));
 			order <= max_order; order++) {
 
 		unsigned long slab_size = PAGE_SIZE << order;
 
-		if (slab_size < min_objects * size + reserved)
-			continue;
-
 		rem = (slab_size - reserved) % size;
 
 		if (rem <= slab_size / fract_leftover)
 			break;
-
 	}
 
 	return order;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
