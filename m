Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7FE426B007E
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:16:56 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:14:33 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219BI0F2605132
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:11:18 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219GmoF003990
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:16:49 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 2/9] mm: Update region function to take new data arg
Date: Thu,  1 Mar 2012 14:46:13 +0530
Message-Id: <1330593380-1361-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch adds a new data arg to region tracking functions.
region_chg function will merge regions only if data arg match
otherwise it will create a new region to map the range.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/region.h |   20 ++++--
 mm/region.c            |  177 ++++++++++++++++++++++++++++++++----------------
 2 files changed, 132 insertions(+), 65 deletions(-)

diff --git a/include/linux/region.h b/include/linux/region.h
index a8a5b46..609e24c 100644
--- a/include/linux/region.h
+++ b/include/linux/region.h
@@ -16,13 +16,21 @@
 #define _LINUX_REGION_H
 
 struct file_region {
+	unsigned long from, to;
+	unsigned long data;
 	struct list_head link;
-	long from;
-	long to;
 };
 
-extern long region_add(struct list_head *head, long from, long to);
-extern long region_chg(struct list_head *head, long from, long to);
-extern long region_truncate(struct list_head *head, long end);
-extern long region_count(struct list_head *head, long from, long to);
+extern long region_chg(struct list_head *head, unsigned long from,
+		       unsigned long to, unsigned long data);
+extern void region_add(struct list_head *head, unsigned long from,
+		       unsigned long to, unsigned long data);
+extern long region_truncate_range(struct list_head *head, unsigned long from,
+				  unsigned long end);
+static inline long region_truncate(struct list_head *head, unsigned long from)
+{
+	return region_truncate_range(head, from, ULONG_MAX);
+}
+extern long region_count(struct list_head *head, unsigned long from,
+			 unsigned long to);
 #endif
diff --git a/mm/region.c b/mm/region.c
index ab59fe7..e547631 100644
--- a/mm/region.c
+++ b/mm/region.c
@@ -18,66 +18,46 @@
 #include <linux/list.h>
 #include <linux/region.h>
 
-long region_add(struct list_head *head, long from, long to)
+long region_chg(struct list_head *head, unsigned long from,
+		unsigned long to, unsigned long data)
 {
-	struct file_region *rg, *nrg, *trg;
-
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (from <= rg->to)
-			break;
-
-	/* Round our left edge to the current segment if it encloses us. */
-	if (from > rg->from)
-		from = rg->from;
-
-	/* Check for and consume any regions we now overlap with. */
-	nrg = rg;
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > to)
-			break;
-
-		/* If this area reaches higher then extend our area to
-		 * include it completely.  If this is not the first area
-		 * which we intend to reuse, free it. */
-		if (rg->to > to)
-			to = rg->to;
-		if (rg != nrg) {
-			list_del(&rg->link);
-			kfree(rg);
-		}
-	}
-	nrg->from = from;
-	nrg->to = to;
-	return 0;
-}
-
-long region_chg(struct list_head *head, long from, long to)
-{
-	struct file_region *rg, *nrg;
 	long chg = 0;
+	struct file_region *rg, *nrg, *trg;
 
 	/* Locate the region we are before or in. */
 	list_for_each_entry(rg, head, link)
 		if (from <= rg->to)
 			break;
-
-	/* If we are below the current region then a new region is required.
+	/*
+	 * If we are below the current region then a new region is required.
 	 * Subtle, allocate a new region at the position but make it zero
-	 * size such that we can guarantee to record the reservation. */
+	 * size such that we can guarantee to record the reservation.
+	 */
 	if (&rg->link == head || to < rg->from) {
 		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
 		if (!nrg)
 			return -ENOMEM;
 		nrg->from = from;
-		nrg->to   = from;
+		nrg->to = from;
+		nrg->data = data;
 		INIT_LIST_HEAD(&nrg->link);
 		list_add(&nrg->link, rg->link.prev);
-
 		return to - from;
 	}
+	/*
+	 * from rg->from to rg->to
+	 */
+	if (from < rg->from && data != rg->data) {
+		/* we need to allocate a new region */
+		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+		if (!nrg)
+			return -ENOMEM;
+		nrg->from = from;
+		nrg->to = from;
+		nrg->data = data;
+		INIT_LIST_HEAD(&nrg->link);
+		list_add(&nrg->link, rg->link.prev);
+	}
 
 	/* Round our left edge to the current segment if it encloses us. */
 	if (from > rg->from)
@@ -85,15 +65,28 @@ long region_chg(struct list_head *head, long from, long to)
 	chg = to - from;
 
 	/* Check for and consume any regions we now overlap with. */
-	list_for_each_entry(rg, rg->link.prev, link) {
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
 		if (&rg->link == head)
 			break;
 		if (rg->from > to)
 			return chg;
-
-		/* We overlap with this area, if it extends further than
-		 * us then we must extend ourselves.  Account for its
-		 * existing reservation. */
+		/*
+		 * rg->from from rg->to to
+		 */
+		if (to > rg->to && data != rg->data) {
+			/* we need to allocate a new region */
+			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+			if (!nrg)
+				return -ENOMEM;
+			nrg->from = rg->to;
+			nrg->to  = rg->to;
+			nrg->data = data;
+			INIT_LIST_HEAD(&nrg->link);
+			list_add(&nrg->link, &rg->link);
+		}
+		/*
+		 * update charge
+		 */
 		if (rg->to > to) {
 			chg += rg->to - to;
 			to = rg->to;
@@ -103,29 +96,96 @@ long region_chg(struct list_head *head, long from, long to)
 	return chg;
 }
 
-long region_truncate(struct list_head *head, long end)
+void region_add(struct list_head *head, unsigned long from,
+		unsigned long to, unsigned long data)
+{
+	struct file_region *rg, *nrg, *trg;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (from <= rg->to)
+			break;
+
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+
+		if (rg->from > to)
+			return;
+		if (&rg->link == head)
+			return;
+
+		/*FIXME!! this can possibly delete few regions */
+		/* We need to worry only if we match data */
+		if (rg->data == data) {
+			if (from < rg->from)
+				rg->from = from;
+			if (to > rg->to) {
+				/* if we are the last entry */
+				if (rg->link.next == head) {
+					rg->to = to;
+					break;
+				} else {
+					nrg = list_entry(rg->link.next,
+							 typeof(*nrg), link);
+					rg->to = nrg->from;
+				}
+			}
+		}
+		from = rg->to;
+	}
+}
+
+long region_truncate_range(struct list_head *head, unsigned long from,
+			   unsigned long to)
 {
-	struct file_region *rg, *trg;
 	long chg = 0;
+	struct file_region *rg, *trg;
 
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
-		if (end <= rg->to)
+		if (from <= rg->to)
 			break;
 	if (&rg->link == head)
 		return 0;
 
 	/* If we are in the middle of a region then adjust it. */
-	if (end > rg->from) {
-		chg = rg->to - end;
-		rg->to = end;
+	if (from > rg->from) {
+		if (to < rg->to) {
+			struct file_region *nrg;
+			/* rf->from from to rg->to */
+			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+			/*
+			 * If we fail to allocate we return the
+			 * with the 0 charge . Later a complete
+			 * truncate will reclaim the left over space
+			 */
+			if (!nrg)
+				return 0;
+			nrg->from = to;
+			nrg->to = rg->to;
+			nrg->data = rg->data;
+			INIT_LIST_HEAD(&nrg->link);
+			list_add(&nrg->link, &rg->link);
+
+			/* Adjust the rg entry */
+			rg->to = from;
+			chg = to - from;
+			return chg;
+		}
+		chg = rg->to - from;
+		rg->to = from;
 		rg = list_entry(rg->link.next, typeof(*rg), link);
 	}
-
-	/* Drop any remaining regions. */
+	/* Drop any remaining regions till to */
 	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (rg->from >= to)
+			break;
 		if (&rg->link == head)
 			break;
+		if (rg->to > to) {
+			chg += to - rg->from;
+			rg->from = to;
+			return chg;
+		}
 		chg += rg->to - rg->from;
 		list_del(&rg->link);
 		kfree(rg);
@@ -133,10 +193,10 @@ long region_truncate(struct list_head *head, long end)
 	return chg;
 }
 
-long region_count(struct list_head *head, long from, long to)
+long region_count(struct list_head *head, unsigned long from, unsigned long to)
 {
-	struct file_region *rg;
 	long chg = 0;
+	struct file_region *rg;
 
 	/* Locate each segment we overlap with, and count that overlap. */
 	list_for_each_entry(rg, head, link) {
@@ -153,6 +213,5 @@ long region_count(struct list_head *head, long from, long to)
 
 		chg += seg_to - seg_from;
 	}
-
 	return chg;
 }
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
