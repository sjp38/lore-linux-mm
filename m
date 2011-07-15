Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CB2866B004A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 02:08:57 -0400 (EDT)
Date: Fri, 15 Jul 2011 16:08:52 +1000
From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 1/2] hugepage: Protect region tracking lists with its own
 spinlock
Message-ID: <20110715160852.0d16318a@kryten>
In-Reply-To: <20110715160650.48d61245@kryten>
References: <20110125143226.37532ea2@kryten>
	<20110125143414.1dbb150c@kryten>
	<20110126092428.GR18984@csn.ul.ie>
	<20110715160650.48d61245@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, dwg@au1.ibm.com, akpm@linux-foundation.org, hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


In preparation for creating a hash of spinlocks to replace the global
hugetlb_instantiation_mutex, protect the region tracking code with
its own spinlock.

Signed-off-by: Anton Blanchard <anton@samba.org> 
---

The old code locked it with either:

	down_write(&mm->mmap_sem);
or
	down_read(&mm->mmap_sem);
	mutex_lock(&hugetlb_instantiation_mutex);

I chose to keep things simple and wrap everything with a single lock.
Do we need the parallelism the old code had in the down_write case?


Index: linux-2.6-work/mm/hugetlb.c
===================================================================
--- linux-2.6-work.orig/mm/hugetlb.c	2011-06-06 08:10:13.471407173 +1000
+++ linux-2.6-work/mm/hugetlb.c	2011-06-06 08:10:15.041433948 +1000
@@ -56,16 +56,6 @@ static DEFINE_SPINLOCK(hugetlb_lock);
 /*
  * Region tracking -- allows tracking of reservations and instantiated pages
  *                    across the pages in a mapping.
- *
- * The region data structures are protected by a combination of the mmap_sem
- * and the hugetlb_instantion_mutex.  To access or modify a region the caller
- * must either hold the mmap_sem for write, or the mmap_sem for read and
- * the hugetlb_instantiation mutex:
- *
- * 	down_write(&mm->mmap_sem);
- * or
- * 	down_read(&mm->mmap_sem);
- * 	mutex_lock(&hugetlb_instantiation_mutex);
  */
 struct file_region {
 	struct list_head link;
@@ -73,10 +63,14 @@ struct file_region {
 	long to;
 };
 
+static DEFINE_SPINLOCK(region_lock);
+
 static long region_add(struct list_head *head, long f, long t)
 {
 	struct file_region *rg, *nrg, *trg;
 
+	spin_lock(&region_lock);
+
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
 		if (f <= rg->to)
@@ -106,6 +100,7 @@ static long region_add(struct list_head
 	}
 	nrg->from = f;
 	nrg->to = t;
+	spin_unlock(&region_lock);
 	return 0;
 }
 
@@ -114,6 +109,8 @@ static long region_chg(struct list_head
 	struct file_region *rg, *nrg;
 	long chg = 0;
 
+	spin_lock(&region_lock);
+
 	/* Locate the region we are before or in. */
 	list_for_each_entry(rg, head, link)
 		if (f <= rg->to)
@@ -124,14 +121,17 @@ static long region_chg(struct list_head
 	 * size such that we can guarantee to record the reservation. */
 	if (&rg->link == head || t < rg->from) {
 		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-		if (!nrg)
-			return -ENOMEM;
+		if (!nrg) {
+			chg = -ENOMEM;
+			goto out;
+		}
 		nrg->from = f;
 		nrg->to   = f;
 		INIT_LIST_HEAD(&nrg->link);
 		list_add(&nrg->link, rg->link.prev);
 
-		return t - f;
+		chg = t - f;
+		goto out;
 	}
 
 	/* Round our left edge to the current segment if it encloses us. */
@@ -144,7 +144,7 @@ static long region_chg(struct list_head
 		if (&rg->link == head)
 			break;
 		if (rg->from > t)
-			return chg;
+			goto out;
 
 		/* We overlap with this area, if it extends further than
 		 * us then we must extend ourselves.  Account for its
@@ -155,6 +155,9 @@ static long region_chg(struct list_head
 		}
 		chg -= rg->to - rg->from;
 	}
+out:
+
+	spin_unlock(&region_lock);
 	return chg;
 }
 
@@ -163,12 +166,16 @@ static long region_truncate(struct list_
 	struct file_region *rg, *trg;
 	long chg = 0;
 
+	spin_lock(&region_lock);
+
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
 		if (end <= rg->to)
 			break;
-	if (&rg->link == head)
-		return 0;
+	if (&rg->link == head) {
+		chg = 0;
+		goto out;
+	}
 
 	/* If we are in the middle of a region then adjust it. */
 	if (end > rg->from) {
@@ -185,6 +192,9 @@ static long region_truncate(struct list_
 		list_del(&rg->link);
 		kfree(rg);
 	}
+
+out:
+	spin_unlock(&region_lock);
 	return chg;
 }
 
@@ -193,6 +203,8 @@ static long region_count(struct list_hea
 	struct file_region *rg;
 	long chg = 0;
 
+	spin_lock(&region_lock);
+
 	/* Locate each segment we overlap with, and count that overlap. */
 	list_for_each_entry(rg, head, link) {
 		int seg_from;
@@ -209,6 +221,7 @@ static long region_count(struct list_hea
 		chg += seg_to - seg_from;
 	}
 
+	spin_unlock(&region_lock);
 	return chg;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
