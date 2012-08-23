Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 2DAD16B0068
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:33:53 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 23 Aug 2012 11:33:51 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6F3096E8044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:33:18 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NFXIkx121988
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:33:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NFXH1v004822
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:33:18 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/2] Revert "staging: zcache: optimize zcache_do_preload"
Date: Thu, 23 Aug 2012 10:33:11 -0500
Message-Id: <1345735991-6995-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This reverts commit 79c0d92c5b6175c1462fbe38bf44180f325aa478.

This commit is resulting  memory corruption in the cleancache case

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Reported-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/zcache/zcache-main.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 8a335b9..4f92d87 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1034,43 +1034,45 @@ static int zcache_do_preload(struct tmem_pool *pool)
 		goto out;
 	if (unlikely(zcache_obj_cache == NULL))
 		goto out;
-
-	/* IRQ has already been disabled. */
+	preempt_disable();
 	kp = &__get_cpu_var(zcache_preloads);
 	while (kp->nr < ARRAY_SIZE(kp->objnodes)) {
+		preempt_enable_no_resched();
 		objnode = kmem_cache_alloc(zcache_objnode_cache,
 				ZCACHE_GFP_MASK);
 		if (unlikely(objnode == NULL)) {
 			zcache_failed_alloc++;
 			goto out;
 		}
-
-		kp->objnodes[kp->nr++] = objnode;
+		preempt_disable();
+		kp = &__get_cpu_var(zcache_preloads);
+		if (kp->nr < ARRAY_SIZE(kp->objnodes))
+			kp->objnodes[kp->nr++] = objnode;
+		else
+			kmem_cache_free(zcache_objnode_cache, objnode);
 	}
-
+	preempt_enable_no_resched();
 	obj = kmem_cache_alloc(zcache_obj_cache, ZCACHE_GFP_MASK);
 	if (unlikely(obj == NULL)) {
 		zcache_failed_alloc++;
 		goto out;
 	}
-
 	page = (void *)__get_free_page(ZCACHE_GFP_MASK);
 	if (unlikely(page == NULL)) {
 		zcache_failed_get_free_pages++;
 		kmem_cache_free(zcache_obj_cache, obj);
 		goto out;
 	}
-
+	preempt_disable();
+	kp = &__get_cpu_var(zcache_preloads);
 	if (kp->obj == NULL)
 		kp->obj = obj;
 	else
 		kmem_cache_free(zcache_obj_cache, obj);
-
 	if (kp->page == NULL)
 		kp->page = page;
 	else
 		free_page((unsigned long)page);
-
 	ret = 0;
 out:
 	return ret;
@@ -1581,6 +1583,7 @@ static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 				zcache_failed_pers_puts++;
 		}
 		zcache_put_pool(pool);
+		preempt_enable_no_resched();
 	} else {
 		zcache_put_to_flush++;
 		if (atomic_read(&pool->obj_count) > 0)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
