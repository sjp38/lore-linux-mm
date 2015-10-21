Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id DE0016B0258
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:52:35 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so50622173pad.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:52:35 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id aw8si5968039pbd.59.2015.10.21.02.52.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Oct 2015 02:52:35 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 21 Oct 2015 15:22:31 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id C3055E0058
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:22:32 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9L9pisR38207732
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:21:45 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9L9phqK026568
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:21:44 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 2/3] mm/slub: use get_order() instead of fls()
Date: Wed, 21 Oct 2015 17:51:05 +0800
Message-Id: <1445421066-10641-3-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

get_order() is more easy to understand.

This patch just replaces it.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Pekka Enberg <penberg@kernel.org>
---
 mm/slub.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e171b10..37552f8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2808,8 +2808,7 @@ static inline int slab_order(int size, int min_objects,
 	if (order_objects(min_order, size, reserved) > MAX_OBJS_PER_PAGE)
 		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
 
-	for (order = max(min_order,
-				fls(min_objects * size - 1) - PAGE_SHIFT);
+	for (order = max(min_order, get_order(min_objects * size));
 			order <= max_order; order++) {
 
 		unsigned long slab_size = PAGE_SIZE << order;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
