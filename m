Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3825A6B003A
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:54:11 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so8014262pbb.31
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:54:10 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ty3si13551493pbc.167.2013.12.17.22.54.07
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 22:54:08 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 03/14] mm, hugetlb: protect region tracking via newly introduced resv_map lock
Date: Wed, 18 Dec 2013 15:53:49 +0900
Message-Id: <1387349640-8071-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a race condition if we map a same file on different processes.
Region tracking is protected by mmap_sem and hugetlb_instantiation_mutex.
When we do mmap, we don't grab a hugetlb_instantiation_mutex, but,
grab a mmap_sem. This doesn't prevent other process to modify region
structure, so it can be modified by two processes concurrently.

To solve this, I introduce a lock to resv_map and make region manipulation
function grab a lock before they do actual work. This makes region
tracking safe.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 317b0a6..ee304d1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -26,6 +26,7 @@ struct hugepage_subpool {
 
 struct resv_map {
 	struct kref refs;
+	spinlock_t lock;
 	struct list_head regions;
 };
 extern struct resv_map *resv_map_alloc(void);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3e7a44b..cf0eaff 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -135,15 +135,8 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
  * Region tracking -- allows tracking of reservations and instantiated pages
  *                    across the pages in a mapping.
  *
- * The region data structures are protected by a combination of the mmap_sem
- * and the hugetlb_instantiation_mutex.  To access or modify a region the caller
- * must either hold the mmap_sem for write, or the mmap_sem for read and
- * the hugetlb_instantiation_mutex:
- *
- *	down_write(&mm->mmap_sem);
- * or
- *	down_read(&mm->mmap_sem);
- *	mutex_lock(&hugetlb_instantiation_mutex);
+ * The region data structures are embedded into a resv_map and
+ * protected by a resv_map's lock
  */
 struct file_region {
 	struct list_head link;
@@ -156,6 +149,7 @@ static long region_add(struct resv_map *resv, long f, long t)
 	struct list_head *head = &resv->regions;
 	struct file_region *rg, *nrg, *trg;
 
+	spin_lock(&resv->lock);
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
 		if (f <= rg->to)
@@ -185,15 +179,18 @@ static long region_add(struct resv_map *resv, long f, long t)
 	}
 	nrg->from = f;
 	nrg->to = t;
+	spin_unlock(&resv->lock);
 	return 0;
 }
 
 static long region_chg(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
-	struct file_region *rg, *nrg;
+	struct file_region *rg, *nrg = NULL;
 	long chg = 0;
 
+retry:
+	spin_lock(&resv->lock);
 	/* Locate the region we are before or in. */
 	list_for_each_entry(rg, head, link)
 		if (f <= rg->to)
@@ -203,15 +200,23 @@ static long region_chg(struct resv_map *resv, long f, long t)
 	 * Subtle, allocate a new region at the position but make it zero
 	 * size such that we can guarantee to record the reservation. */
 	if (&rg->link == head || t < rg->from) {
-		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-		if (!nrg)
-			return -ENOMEM;
+		if (!nrg) {
+			spin_unlock(&resv->lock);
+			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+			if (!nrg)
+				return -ENOMEM;
+
+			goto retry;
+		}
+
 		nrg->from = f;
 		nrg->to   = f;
 		INIT_LIST_HEAD(&nrg->link);
 		list_add(&nrg->link, rg->link.prev);
+		nrg = NULL;
 
-		return t - f;
+		chg = t - f;
+		goto out_locked;
 	}
 
 	/* Round our left edge to the current segment if it encloses us. */
@@ -224,7 +229,7 @@ static long region_chg(struct resv_map *resv, long f, long t)
 		if (&rg->link == head)
 			break;
 		if (rg->from > t)
-			return chg;
+			goto out_locked;
 
 		/* We overlap with this area, if it extends further than
 		 * us then we must extend ourselves.  Account for its
@@ -235,6 +240,10 @@ static long region_chg(struct resv_map *resv, long f, long t)
 		}
 		chg -= rg->to - rg->from;
 	}
+
+out_locked:
+	spin_unlock(&resv->lock);
+	kfree(nrg);
 	return chg;
 }
 
@@ -244,12 +253,13 @@ static long region_truncate(struct resv_map *resv, long end)
 	struct file_region *rg, *trg;
 	long chg = 0;
 
+	spin_lock(&resv->lock);
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
 		if (end <= rg->to)
 			break;
 	if (&rg->link == head)
-		return 0;
+		goto out;
 
 	/* If we are in the middle of a region then adjust it. */
 	if (end > rg->from) {
@@ -266,6 +276,9 @@ static long region_truncate(struct resv_map *resv, long end)
 		list_del(&rg->link);
 		kfree(rg);
 	}
+
+out:
+	spin_unlock(&resv->lock);
 	return chg;
 }
 
@@ -275,6 +288,7 @@ static long region_count(struct resv_map *resv, long f, long t)
 	struct file_region *rg;
 	long chg = 0;
 
+	spin_lock(&resv->lock);
 	/* Locate each segment we overlap with, and count that overlap. */
 	list_for_each_entry(rg, head, link) {
 		long seg_from;
@@ -290,6 +304,7 @@ static long region_count(struct resv_map *resv, long f, long t)
 
 		chg += seg_to - seg_from;
 	}
+	spin_unlock(&resv->lock);
 
 	return chg;
 }
@@ -387,6 +402,7 @@ struct resv_map *resv_map_alloc(void)
 		return NULL;
 
 	kref_init(&resv_map->refs);
+	spin_lock_init(&resv_map->lock);
 	INIT_LIST_HEAD(&resv_map->regions);
 
 	return resv_map;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
