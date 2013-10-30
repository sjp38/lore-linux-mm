Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id CEF856B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 06:03:52 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so747020pdj.14
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 03:03:52 -0700 (PDT)
Received: from psmtp.com ([74.125.245.114])
        by mx.google.com with SMTP id yh6si1430992pab.63.2013.10.30.03.03.47
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 03:03:51 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 16/15] slab: fix to calm down kmemleak warning
Date: Wed, 30 Oct 2013 19:04:00 +0900
Message-Id: <1383127441-30563-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

After using struct page as slab management, we should not call
kmemleak_scan_area(), since struct page isn't the tracking object of
kmemleak. Without this patch and if CONFIG_DEBUG_KMEMLEAK is enabled,
so many kmemleak warnings are printed.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index af2db76..a8a9349 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2531,14 +2531,6 @@ static struct freelist *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
-		/*
-		 * If the first object in the slab is leaked (it's allocated
-		 * but no one has a reference to it), we want to make sure
-		 * kmemleak does not treat the ->s_mem pointer as a reference
-		 * to the object. Otherwise we will not report the leak.
-		 */
-		kmemleak_scan_area(&page->lru, sizeof(struct list_head),
-				   local_flags);
 		if (!freelist)
 			return NULL;
 	} else {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
