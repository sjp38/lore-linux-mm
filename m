Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E712D6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 23:22:26 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so592020pab.20
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:22:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id tr4si2454268pab.121.2014.01.14.20.22.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 20:22:25 -0800 (PST)
Message-ID: <52D60CF9.3010609@oracle.com>
Date: Wed, 15 Jan 2014 12:22:17 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] mm/zbud: use list_last_entry in zbud_reclaim_page() directly
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@linux.vnet.ibm.com

From: Jie Liu <jeff.liu@oracle.com>

Get rid of the self defined list_tail_entry() helper and
use list_last_entry() in zbud_reclaim_page() directly.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 mm/zbud.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 9451361..8ac1e97 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -360,9 +360,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	spin_unlock(&pool->lock);
 }
 
-#define list_tail_entry(ptr, type, member) \
-	list_entry((ptr)->prev, type, member)
-
 /**
  * zbud_reclaim_page() - evicts allocations from a pool page and frees it
  * @pool:	pool from which a page will attempt to be evicted
@@ -411,7 +408,7 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 		return -EINVAL;
 	}
 	for (i = 0; i < retries; i++) {
-		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
+		zhdr = list_last_entry(&pool->lru, struct zbud_header, lru);
 		list_del(&zhdr->lru);
 		list_del(&zhdr->buddy);
 		/* Protect zbud page against free */
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
