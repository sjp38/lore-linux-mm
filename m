Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 74FF26B0073
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 04:36:56 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 14:06:53 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5J8aofS11010368
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:06:50 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JE6beB021353
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 00:06:37 +1000
Message-ID: <4FE03A1E.5070400@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 16:36:46 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 08/10] zcache: cleanup zcache_do_preload and zcache_put_page
References: <4FE0392E.3090300@linux.vnet.ibm.com>
In-Reply-To: <4FE0392E.3090300@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Cleanup the code for zcache_do_preload and zcache_put_page

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   37 ++++++++++++++-------------------
 1 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 386906d..2ee55c4 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1040,29 +1040,24 @@ static int zcache_do_preload(struct tmem_pool *pool)
 		kp->objnodes[kp->nr++] = objnode;
 	}

-	obj = kmem_cache_alloc(zcache_obj_cache, ZCACHE_GFP_MASK);
-	if (unlikely(obj == NULL)) {
-		zcache_failed_alloc++;
-		goto out;
+	if (!kp->obj) {
+		obj = kmem_cache_alloc(zcache_obj_cache, ZCACHE_GFP_MASK);
+		if (unlikely(obj == NULL)) {
+			zcache_failed_alloc++;
+			goto out;
+		}
+		kp->obj = obj;
 	}

-	page = (void *)__get_free_page(ZCACHE_GFP_MASK);
-	if (unlikely(page == NULL)) {
-		zcache_failed_get_free_pages++;
-		kmem_cache_free(zcache_obj_cache, obj);
-		goto out;
+	if (!kp->page) {
+		page = (void *)__get_free_page(ZCACHE_GFP_MASK);
+		if (unlikely(page == NULL)) {
+			zcache_failed_get_free_pages++;
+			goto out;
+		}
+		kp->page =  page;
 	}

-	if (kp->obj == NULL)
-		kp->obj = obj;
-	else
-		kmem_cache_free(zcache_obj_cache, obj);
-
-	if (kp->page == NULL)
-		kp->page = page;
-	else
-		free_page((unsigned long)page);
-
 	ret = 0;
 out:
 	return ret;
@@ -1572,14 +1567,14 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 			else
 				zcache_failed_pers_puts++;
 		}
-		zcache_put_pool(pool);
 	} else {
 		zcache_put_to_flush++;
 		if (atomic_read(&pool->obj_count) > 0)
 			/* the put fails whether the flush succeeds or not */
 			(void)tmem_flush_page(pool, oidp, index);
-		zcache_put_pool(pool);
 	}
+
+	zcache_put_pool(pool);
 out:
 	return ret;
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
