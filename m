Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAA06B0254
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 21:06:53 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so193182173pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 18:06:52 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id xt7si32863323pab.187.2015.09.28.18.06.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Sep 2015 18:06:52 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 29 Sep 2015 06:36:48 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BE1E1E0058
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:36:30 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8T16kB536044902
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:36:46 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8T16j81027050
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:36:46 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm/slub: use get_order() instead of fls()
Date: Tue, 29 Sep 2015 09:06:27 +0800
Message-Id: <1443488787-2232-2-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1443488787-2232-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1443488787-2232-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

get_order() is more easy to understand.

This patch just replaces it.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 mm/slub.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index a94b9f4..e309ed1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2912,8 +2912,7 @@ static inline int slab_order(int size, int min_objects,
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
