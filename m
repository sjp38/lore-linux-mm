Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id BEC436B0037
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 10:27:53 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 1/2] hugepage: protect file regions with rwsem
Date: Fri, 26 Jul 2013 07:27:24 -0700
Message-Id: <1374848845-1429-2-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1374848845-1429-1-git-send-email-davidlohr.bueso@hp.com>
References: <1374848845-1429-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Gibson <david@gibson.dropbear.id.au>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

The next patch will introduce parallel hugepage fault paths, replacing
the global hugetbl_instantiation_mutex with a table of hashed mutexes.
In order to prevent races, introduce a rw-semaphore that exclusively
serializes access to file region tracking structure.

Thanks to Konstantin Khlebnikov and Joonsoo Kim for pointing this issue out.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 mm/hugetlb.c | 47 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 33 insertions(+), 14 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 83aff0a..4c3f4f0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -134,16 +134,12 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
  * Region tracking -- allows tracking of reservations and instantiated pages
  *                    across the pages in a mapping.
  *
- * The region data structures are protected by a combination of the mmap_sem
- * and the hugetlb_instantion_mutex.  To access or modify a region the caller
- * must either hold the mmap_sem for write, or the mmap_sem for read and
- * the hugetlb_instantiation mutex:
- *
- *	down_write(&mm->mmap_sem);
- * or
- *	down_read(&mm->mmap_sem);
- *	mutex_lock(&hugetlb_instantiation_mutex);
+ * With the parallelization of the hugepage fault path, the region_rwsem replaces
+ * the original hugetlb_instantiation_mutex, serializing access to the chains of
+ * file regions.
  */
+DECLARE_RWSEM(region_rwsem);
+
 struct file_region {
 	struct list_head link;
 	long from;
@@ -154,6 +150,8 @@ static long region_add(struct list_head *head, long f, long t)
 {
 	struct file_region *rg, *nrg, *trg;
 
+	down_write(&region_rwsem);
+
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
 		if (f <= rg->to)
@@ -183,6 +181,8 @@ static long region_add(struct list_head *head, long f, long t)
 	}
 	nrg->from = f;
 	nrg->to = t;
+
+	up_write(&region_rwsem);
 	return 0;
 }
 
@@ -191,6 +191,8 @@ static long region_chg(struct list_head *head, long f, long t)
 	struct file_region *rg, *nrg;
 	long chg = 0;
 
+	down_write(&region_rwsem);
+
 	/* Locate the region we are before or in. */
 	list_for_each_entry(rg, head, link)
 		if (f <= rg->to)
@@ -201,17 +203,21 @@ static long region_chg(struct list_head *head, long f, long t)
 	 * size such that we can guarantee to record the reservation. */
 	if (&rg->link == head || t < rg->from) {
 		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-		if (!nrg)
-			return -ENOMEM;
+		if (!nrg) {
+			chg = -ENOMEM;
+			goto done_write;
+		}
 		nrg->from = f;
 		nrg->to   = f;
 		INIT_LIST_HEAD(&nrg->link);
 		list_add(&nrg->link, rg->link.prev);
 
-		return t - f;
+		chg = t - f;
+		goto done_write;
 	}
 
 	/* Round our left edge to the current segment if it encloses us. */
+	downgrade_write(&region_rwsem);
 	if (f > rg->from)
 		f = rg->from;
 	chg = t - f;
@@ -221,7 +227,7 @@ static long region_chg(struct list_head *head, long f, long t)
 		if (&rg->link == head)
 			break;
 		if (rg->from > t)
-			return chg;
+			break;
 
 		/* We overlap with this area, if it extends further than
 		 * us then we must extend ourselves.  Account for its
@@ -232,6 +238,11 @@ static long region_chg(struct list_head *head, long f, long t)
 		}
 		chg -= rg->to - rg->from;
 	}
+
+	up_read(&region_rwsem);
+	return chg;
+done_write:
+	up_write(&region_rwsem);
 	return chg;
 }
 
@@ -240,12 +251,14 @@ static long region_truncate(struct list_head *head, long end)
 	struct file_region *rg, *trg;
 	long chg = 0;
 
+	down_write(&region_rwsem);
+
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
 		if (end <= rg->to)
 			break;
 	if (&rg->link == head)
-		return 0;
+		goto done;
 
 	/* If we are in the middle of a region then adjust it. */
 	if (end > rg->from) {
@@ -262,6 +275,9 @@ static long region_truncate(struct list_head *head, long end)
 		list_del(&rg->link);
 		kfree(rg);
 	}
+
+done:
+	up_write(&region_rwsem);
 	return chg;
 }
 
@@ -270,6 +286,8 @@ static long region_count(struct list_head *head, long f, long t)
 	struct file_region *rg;
 	long chg = 0;
 
+	down_read(&region_rwsem);
+
 	/* Locate each segment we overlap with, and count that overlap. */
 	list_for_each_entry(rg, head, link) {
 		long seg_from;
@@ -286,6 +304,7 @@ static long region_count(struct list_head *head, long f, long t)
 		chg += seg_to - seg_from;
 	}
 
+	up_read(&region_rwsem);
 	return chg;
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
