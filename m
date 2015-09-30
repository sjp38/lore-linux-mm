Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 02B6E6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:31:45 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so24113331pac.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 19:31:44 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id cc1si41892332pad.49.2015.09.29.19.31.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Sep 2015 19:31:44 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 30 Sep 2015 12:31:40 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id DF40F2BB004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:31:38 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8U2VU0m24444970
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:31:38 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8U2V6Ai013202
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:31:06 +1000
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] mm/slub: calculate start order with reserved in consideration
Date: Wed, 30 Sep 2015 10:30:02 +0800
Message-Id: <1443580202-4311-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

In function slub_order(), the order starts from max(min_order,
get_order(min_objects * size)). When (min_objects * size) has different
order with (min_objects * size + reserved), it will skip this order by the
check in the loop.

This patch optimizes this a little by calculating the start order with
reserved in consideration and remove the check in loop.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

---
This patch is based on the previous one "mm/slub: use get_order() instead of
fls()", so may not apply on current tree.

---
 mm/slub.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e309ed1..e1bb147 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2912,19 +2912,15 @@ static inline int slab_order(int size, int min_objects,
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
