Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B63976B0033
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:30:17 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so7543359pab.13
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 17:30:17 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Sep 2013 06:00:11 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id C687D1258056
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:00:16 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8I0WJtZ39125052
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:02:19 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8I0U7Ef011537
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:00:08 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v6 2/2] mm/vmalloc: drop "caller" argument of __vmalloc_area_node()
Date: Wed, 18 Sep 2013 08:30:02 +0800
Message-Id: <1379464202-21104-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379464202-21104-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379464202-21104-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

__vmalloc_area_node() no longer need "caller" argument. It can use area->caller 
instead. This patch drop "caller" argument of __vmalloc_area_node().

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d78d117..f75c2aa 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1546,7 +1546,7 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
 			    int node, const void *caller);
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
-				 pgprot_t prot, int node, const void *caller)
+				 pgprot_t prot, int node)
 {
 	const int order = 0;
 	struct page **pages;
@@ -1560,7 +1560,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
 		pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
-				PAGE_KERNEL, node, caller);
+				PAGE_KERNEL, node, area->caller);
 		area->flags |= VM_VPAGES;
 	} else {
 		pages = kmalloc_node(array_size, nested_gfp, node);
@@ -1633,7 +1633,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	if (!area)
 		goto fail;
 
-	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
+	addr = __vmalloc_area_node(area, gfp_mask, prot, node);
 	if (!addr)
 		goto fail;
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
