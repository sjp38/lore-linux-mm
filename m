Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B79466B0122
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:51:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 08:40:39 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q8i2Jb6488560
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:44:02 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q8paCa023556
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:51:36 +1000
Message-ID: <4FE97816.9000501@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 16:51:34 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH v2 6/9] zcache: optimize zcache_do_preload
References: <4FE97792.9020807@linux.vnet.ibm.com>
In-Reply-To: <4FE97792.9020807@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

zcache_do_preload is called in zcache_put_page where IRQ is disabled, so, need
not care preempt

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 0529b46..57e25fc 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1031,45 +1031,43 @@ static int zcache_do_preload(struct tmem_pool *pool)
 		goto out;
 	if (unlikely(zcache_obj_cache == NULL))
 		goto out;
-	preempt_disable();
+
+	/* IRQ has already been disabled. */
 	kp = &__get_cpu_var(zcache_preloads);
 	while (kp->nr < ARRAY_SIZE(kp->objnodes)) {
-		preempt_enable_no_resched();
 		objnode = kmem_cache_alloc(zcache_objnode_cache,
 				ZCACHE_GFP_MASK);
 		if (unlikely(objnode == NULL)) {
 			zcache_failed_alloc++;
 			goto out;
 		}
-		preempt_disable();
-		kp = &__get_cpu_var(zcache_preloads);
-		if (kp->nr < ARRAY_SIZE(kp->objnodes))
-			kp->objnodes[kp->nr++] = objnode;
-		else
-			kmem_cache_free(zcache_objnode_cache, objnode);
+
+		kp->objnodes[kp->nr++] = objnode;
 	}
-	preempt_enable_no_resched();
+
 	obj = kmem_cache_alloc(zcache_obj_cache, ZCACHE_GFP_MASK);
 	if (unlikely(obj == NULL)) {
 		zcache_failed_alloc++;
 		goto out;
 	}
+
 	page = (void *)__get_free_page(ZCACHE_GFP_MASK);
 	if (unlikely(page == NULL)) {
 		zcache_failed_get_free_pages++;
 		kmem_cache_free(zcache_obj_cache, obj);
 		goto out;
 	}
-	preempt_disable();
-	kp = &__get_cpu_var(zcache_preloads);
+
 	if (kp->obj == NULL)
 		kp->obj = obj;
 	else
 		kmem_cache_free(zcache_obj_cache, obj);
+
 	if (kp->page == NULL)
 		kp->page = page;
 	else
 		free_page((unsigned long)page);
+
 	ret = 0;
 out:
 	return ret;
@@ -1580,7 +1578,6 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 				zcache_failed_pers_puts++;
 		}
 		zcache_put_pool(pool);
-		preempt_enable_no_resched();
 	} else {
 		zcache_put_to_flush++;
 		if (atomic_read(&pool->obj_count) > 0)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
