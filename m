Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id E01466B012C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:52:04 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 08:30:51 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q8pwba39780518
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:51:58 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q8pwHC024064
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:51:58 +1000
Message-ID: <4FE9782B.1040603@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 16:51:55 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH v2 7/9] zcache: cleanup zcache_do_preload and zcache_put_page
References: <4FE97792.9020807@linux.vnet.ibm.com>
In-Reply-To: <4FE97792.9020807@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

Cleanup the code for zcache_do_preload and zcache_put_page

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   37 ++++++++++++++-------------------
 1 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 57e25fc..fbd9bcf 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1045,29 +1045,24 @@ static int zcache_do_preload(struct tmem_pool *pool)
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
@@ -1577,14 +1572,14 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
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
