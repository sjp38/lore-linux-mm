Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C95B66B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:41:09 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9CJPgT4029166
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:25:42 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9CJf7x3118758
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:41:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9CJf6ME007495
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:41:07 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] staging: zcache: remove zcache_direct_reclaim_lock
Date: Wed, 12 Oct 2011 14:41:00 -0500
Message-Id: <1318448460-5930-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: cascardo@holoscopio.com, dan.magenheimer@oracle.com, rdunlap@xenotime.net, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rcj@linux.vnet.ibm.com, brking@linux.vnet.ibm.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

zcache_do_preload() currently does a spin_trylock() on the
zcache_direct_reclaim_lock. Holding this lock intends to prevent
shrink_zcache_memory() from evicting zbud pages as a result
of a preload.

However, it also prevents two threads from
executing zcache_do_preload() at the same time.  The first
thread will obtain the lock and the second thread's spin_trylock()
will fail (an aborted preload) causing the page to be either lost
(cleancache) or pushed out to the swap device (frontswap). It
also doesn't ensure that the call to shrink_zcache_memory() is
on the same thread as the call to zcache_do_preload().

Additional, there is no need for this mechanism because all
zcache_do_preload() calls that come down from cleancache already
have PF_MEMALLOC set in the process flags which prevents
direct reclaim in the memory manager. If the zcache_do_preload()
call is done from the frontswap path, we _want_ reclaim to be
done (which it isn't right now).

This patch removes the zcache_direct_reclaim_lock and related
statistics in zcache.

Based on v3.1-rc8

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   31 ++++---------------------------
 1 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 462fbc2..a61b267 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -962,15 +962,6 @@ out:
 static unsigned long zcache_failed_get_free_pages;
 static unsigned long zcache_failed_alloc;
 static unsigned long zcache_put_to_flush;
-static unsigned long zcache_aborted_preload;
-static unsigned long zcache_aborted_shrink;
-
-/*
- * Ensure that memory allocation requests in zcache don't result
- * in direct reclaim requests via the shrinker, which would cause
- * an infinite loop.  Maybe a GFP flag would be better?
- */
-static DEFINE_SPINLOCK(zcache_direct_reclaim_lock);
 
 /*
  * for now, used named slabs so can easily track usage; later can
@@ -1009,10 +1000,6 @@ static int zcache_do_preload(struct tmem_pool *pool)
 		goto out;
 	if (unlikely(zcache_obj_cache == NULL))
 		goto out;
-	if (!spin_trylock(&zcache_direct_reclaim_lock)) {
-		zcache_aborted_preload++;
-		goto out;
-	}
 	preempt_disable();
 	kp = &__get_cpu_var(zcache_preloads);
 	while (kp->nr < ARRAY_SIZE(kp->objnodes)) {
@@ -1021,7 +1008,7 @@ static int zcache_do_preload(struct tmem_pool *pool)
 				ZCACHE_GFP_MASK);
 		if (unlikely(objnode == NULL)) {
 			zcache_failed_alloc++;
-			goto unlock_out;
+			goto out;
 		}
 		preempt_disable();
 		kp = &__get_cpu_var(zcache_preloads);
@@ -1034,13 +1021,13 @@ static int zcache_do_preload(struct tmem_pool *pool)
 	obj = kmem_cache_alloc(zcache_obj_cache, ZCACHE_GFP_MASK);
 	if (unlikely(obj == NULL)) {
 		zcache_failed_alloc++;
-		goto unlock_out;
+		goto out;
 	}
 	page = (void *)__get_free_page(ZCACHE_GFP_MASK);
 	if (unlikely(page == NULL)) {
 		zcache_failed_get_free_pages++;
 		kmem_cache_free(zcache_obj_cache, obj);
-		goto unlock_out;
+		goto out;
 	}
 	preempt_disable();
 	kp = &__get_cpu_var(zcache_preloads);
@@ -1053,8 +1040,6 @@ static int zcache_do_preload(struct tmem_pool *pool)
 	else
 		free_page((unsigned long)page);
 	ret = 0;
-unlock_out:
-	spin_unlock(&zcache_direct_reclaim_lock);
 out:
 	return ret;
 }
@@ -1423,8 +1408,6 @@ ZCACHE_SYSFS_RO(evicted_buddied_pages);
 ZCACHE_SYSFS_RO(failed_get_free_pages);
 ZCACHE_SYSFS_RO(failed_alloc);
 ZCACHE_SYSFS_RO(put_to_flush);
-ZCACHE_SYSFS_RO(aborted_preload);
-ZCACHE_SYSFS_RO(aborted_shrink);
 ZCACHE_SYSFS_RO(compress_poor);
 ZCACHE_SYSFS_RO(mean_compress_poor);
 ZCACHE_SYSFS_RO_ATOMIC(zbud_curr_raw_pages);
@@ -1466,8 +1449,6 @@ static struct attribute *zcache_attrs[] = {
 	&zcache_failed_get_free_pages_attr.attr,
 	&zcache_failed_alloc_attr.attr,
 	&zcache_put_to_flush_attr.attr,
-	&zcache_aborted_preload_attr.attr,
-	&zcache_aborted_shrink_attr.attr,
 	&zcache_zbud_unbuddied_list_counts_attr.attr,
 	&zcache_zbud_cumul_chunk_counts_attr.attr,
 	&zcache_zv_curr_dist_counts_attr.attr,
@@ -1507,11 +1488,7 @@ static int shrink_zcache_memory(struct shrinker *shrink,
 		if (!(gfp_mask & __GFP_FS))
 			/* does this case really need to be skipped? */
 			goto out;
-		if (spin_trylock(&zcache_direct_reclaim_lock)) {
-			zbud_evict_pages(nr);
-			spin_unlock(&zcache_direct_reclaim_lock);
-		} else
-			zcache_aborted_shrink++;
+		zbud_evict_pages(nr);
 	}
 	ret = (int)atomic_read(&zcache_zbud_curr_raw_pages);
 out:
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
