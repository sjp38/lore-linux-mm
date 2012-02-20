Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 678FF6B007E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:20 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 12:13:28 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBGu7O3252434
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:16:56 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBMDM8020028
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:13 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 6/9] hugetlbfs: Switch to new region APIs
Date: Mon, 20 Feb 2012 16:51:39 +0530
Message-Id: <1329736902-26870-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Remove the old code which is not used

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/Makefile          |    2 +-
 fs/hugetlbfs/hugetlb_cgroup.c  |  135 +--------------------------
 fs/hugetlbfs/region.c          |  202 ++++++++++++++++++++++++++++++++++++++++
 include/linux/hugetlb_cgroup.h |   17 +++-
 mm/hugetlb.c                   |  163 +--------------------------------
 5 files changed, 222 insertions(+), 297 deletions(-)
 create mode 100644 fs/hugetlbfs/region.c

diff --git a/fs/hugetlbfs/Makefile b/fs/hugetlbfs/Makefile
index 986c778..3c544fe 100644
--- a/fs/hugetlbfs/Makefile
+++ b/fs/hugetlbfs/Makefile
@@ -4,5 +4,5 @@
 
 obj-$(CONFIG_HUGETLBFS) += hugetlbfs.o
 
-hugetlbfs-objs := inode.o
+hugetlbfs-objs := inode.o region.o
 hugetlbfs-$(CONFIG_CGROUP_HUGETLB_RES_CTLR) += hugetlb_cgroup.o
diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index a75661d..a4c6786 100644
--- a/fs/hugetlbfs/hugetlb_cgroup.c
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -18,6 +18,8 @@
 #include <linux/hugetlb.h>
 #include <linux/res_counter.h>
 #include <linux/list.h>
+#include <linux/hugetlb_cgroup.h>
+
 
 /* lifted from mem control */
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
@@ -32,136 +34,9 @@ struct hugetlb_cgroup {
 	struct res_counter memhuge[HUGE_MAX_HSTATE];
 };
 
-struct file_region_with_data {
-	struct list_head link;
-	long from;
-	long to;
-	unsigned long data;
-};
-
 struct cgroup_subsys hugetlb_subsys __read_mostly;
 struct hugetlb_cgroup *root_h_cgroup __read_mostly;
 
-/*
- * A vairant of region_add that only merges regions only if data
- * match.
- */
-static long region_chg_with_same(struct list_head *head,
-				 long f, long t, unsigned long data)
-{
-	long chg = 0;
-	struct file_region_with_data *rg, *nrg, *trg;
-
-	/* Locate the region we are before or in. */
-	list_for_each_entry(rg, head, link)
-		if (f <= rg->to)
-			break;
-	/*
-	 * If we are below the current region then a new region is required.
-	 * Subtle, allocate a new region at the position but make it zero
-	 * size such that we can guarantee to record the reservation.
-	 */
-	if (&rg->link == head || t < rg->from) {
-		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-		if (!nrg)
-			return -ENOMEM;
-		nrg->from = f;
-		nrg->to = f;
-		nrg->data = data;
-		INIT_LIST_HEAD(&nrg->link);
-		list_add(&nrg->link, rg->link.prev);
-		return t - f;
-	}
-	/*
-	 * f rg->from t rg->to
-	 */
-	if (f < rg->from && data != rg->data) {
-		/* we need to allocate a new region */
-		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-		if (!nrg)
-			return -ENOMEM;
-		nrg->from = f;
-		nrg->to = f;
-		nrg->data = data;
-		INIT_LIST_HEAD(&nrg->link);
-		list_add(&nrg->link, rg->link.prev);
-	}
-
-	/* Round our left edge to the current segment if it encloses us. */
-	if (f > rg->from)
-		f = rg->from;
-	chg = t - f;
-
-	/* Check for and consume any regions we now overlap with. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > t)
-			return chg;
-		/*
-		 * rg->from f rg->to t
-		 */
-		if (t > rg->to && data != rg->data) {
-			/* we need to allocate a new region */
-			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-			if (!nrg)
-				return -ENOMEM;
-			nrg->from = rg->to;
-			nrg->to  = rg->to;
-			nrg->data = data;
-			INIT_LIST_HEAD(&nrg->link);
-			list_add(&nrg->link, &rg->link);
-		}
-		/*
-		 * update charge
-		 */
-		if (rg->to > t) {
-			chg += rg->to - t;
-			t = rg->to;
-		}
-		chg -= rg->to - rg->from;
-	}
-	return chg;
-}
-
-static void region_add_with_same(struct list_head *head,
-				 long f, long t, unsigned long data)
-{
-	struct file_region_with_data *rg, *nrg, *trg;
-
-	/* Locate the region we are before or in. */
-	list_for_each_entry(rg, head, link)
-		if (f <= rg->to)
-			break;
-
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-
-		if (rg->from > t)
-			return;
-		if (&rg->link == head)
-			return;
-
-		/*FIXME!! this can possibly delete few regions */
-		/* We need to worry only if we match data */
-		if (rg->data == data) {
-			if (f < rg->from)
-				rg->from = f;
-			if (t > rg->to) {
-				/* if we are the last entry */
-				if (rg->link.next == head) {
-					rg->to = t;
-					break;
-				} else {
-					nrg = list_entry(rg->link.next,
-							 typeof(*nrg), link);
-					rg->to = nrg->from;
-				}
-			}
-		}
-		f = rg->to;
-	}
-}
-
 static inline
 struct hugetlb_cgroup *css_to_hugetlbcgroup(struct cgroup_subsys_state *s)
 {
@@ -355,7 +230,7 @@ long hugetlb_page_charge(struct list_head *head,
 	css_get(&h_cg->css);
 	rcu_read_unlock();
 
-	chg = region_chg_with_same(head, f, t, (unsigned long)h_cg);
+	chg = region_chg(head, f, t, (unsigned long)h_cg);
 	if (chg < 0)
 		goto err_out;
 
@@ -400,7 +275,7 @@ void hugetlb_commit_page_charge(struct list_head *head, long f, long t)
 
 	rcu_read_lock();
 	h_cg = task_hugetlbcgroup(current);
-	region_add_with_same(head, f, t, (unsigned long)h_cg);
+	region_add(head, f, t, (unsigned long)h_cg);
 	rcu_read_unlock();
 	return;
 }
@@ -411,7 +286,7 @@ long hugetlb_truncate_cgroup(struct hstate *h,
 	long chg = 0, csize;
 	int idx = h - hstates;
 	struct hugetlb_cgroup *h_cg;
-	struct file_region_with_data *rg, *trg;
+	struct file_region *rg, *trg;
 
 	/* Locate the region we are either in or before. */
 	list_for_each_entry(rg, head, link)
diff --git a/fs/hugetlbfs/region.c b/fs/hugetlbfs/region.c
new file mode 100644
index 0000000..d2445fb
--- /dev/null
+++ b/fs/hugetlbfs/region.c
@@ -0,0 +1,202 @@
+/*
+ * Copyright IBM Corporation, 2012
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#include <linux/cgroup.h>
+#include <linux/slab.h>
+#include <linux/hugetlb.h>
+#include <linux/list.h>
+#include <linux/hugetlb_cgroup.h>
+
+/*
+ * Region tracking -- allows tracking of reservations and instantiated pages
+ *                    across the pages in a mapping.
+ *
+ * The region data structures are protected by a combination of the mmap_sem
+ * and the hugetlb_instantion_mutex.  To access or modify a region the caller
+ * must either hold the mmap_sem for write, or the mmap_sem for read and
+ * the hugetlb_instantiation mutex:
+ *
+ *	down_write(&mm->mmap_sem);
+ * or
+ *	down_read(&mm->mmap_sem);
+ *	mutex_lock(&hugetlb_instantiation_mutex);
+ */
+
+long region_chg(struct list_head *head, long f, long t, unsigned long data)
+{
+	long chg = 0;
+	struct file_region *rg, *nrg, *trg;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (f <= rg->to)
+			break;
+	/*
+	 * If we are below the current region then a new region is required.
+	 * Subtle, allocate a new region at the position but make it zero
+	 * size such that we can guarantee to record the reservation.
+	 */
+	if (&rg->link == head || t < rg->from) {
+		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+		if (!nrg)
+			return -ENOMEM;
+		nrg->from = f;
+		nrg->to = f;
+		nrg->data = data;
+		INIT_LIST_HEAD(&nrg->link);
+		list_add(&nrg->link, rg->link.prev);
+		return t - f;
+	}
+	/*
+	 * f rg->from t rg->to
+	 */
+	if (f < rg->from && data != rg->data) {
+		/* we need to allocate a new region */
+		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+		if (!nrg)
+			return -ENOMEM;
+		nrg->from = f;
+		nrg->to = f;
+		nrg->data = data;
+		INIT_LIST_HEAD(&nrg->link);
+		list_add(&nrg->link, rg->link.prev);
+	}
+
+	/* Round our left edge to the current segment if it encloses us. */
+	if (f > rg->from)
+		f = rg->from;
+	chg = t - f;
+
+	/* Check for and consume any regions we now overlap with. */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > t)
+			return chg;
+		/*
+		 * rg->from f rg->to t
+		 */
+		if (t > rg->to && data != rg->data) {
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
+		if (rg->to > t) {
+			chg += rg->to - t;
+			t = rg->to;
+		}
+		chg -= rg->to - rg->from;
+	}
+	return chg;
+}
+
+void region_add(struct list_head *head, long f, long t, unsigned long data)
+{
+	struct file_region *rg, *nrg, *trg;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (f <= rg->to)
+			break;
+
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+
+		if (rg->from > t)
+			return;
+		if (&rg->link == head)
+			return;
+
+		/*FIXME!! this can possibly delete few regions */
+		/* We need to worry only if we match data */
+		if (rg->data == data) {
+			if (f < rg->from)
+				rg->from = f;
+			if (t > rg->to) {
+				/* if we are the last entry */
+				if (rg->link.next == head) {
+					rg->to = t;
+					break;
+				} else {
+					nrg = list_entry(rg->link.next,
+							 typeof(*nrg), link);
+					rg->to = nrg->from;
+				}
+			}
+		}
+		f = rg->to;
+	}
+}
+
+long region_truncate(struct list_head *head, long end)
+{
+	struct file_region *rg, *trg;
+	long chg = 0;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (end <= rg->to)
+			break;
+	if (&rg->link == head)
+		return 0;
+
+	/* If we are in the middle of a region then adjust it. */
+	if (end > rg->from) {
+		chg = rg->to - end;
+		rg->to = end;
+		rg = list_entry(rg->link.next, typeof(*rg), link);
+	}
+
+	/* Drop any remaining regions. */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		chg += rg->to - rg->from;
+		list_del(&rg->link);
+		kfree(rg);
+	}
+	return chg;
+}
+
+long region_count(struct list_head *head, long f, long t)
+{
+	struct file_region *rg;
+	long chg = 0;
+
+	/* Locate each segment we overlap with, and count that overlap. */
+	list_for_each_entry(rg, head, link) {
+		int seg_from;
+		int seg_to;
+
+		if (rg->to <= f)
+			continue;
+		if (rg->from >= t)
+			break;
+
+		seg_from = max(rg->from, f);
+		seg_to = min(rg->to, t);
+
+		chg += seg_to - seg_from;
+	}
+
+	return chg;
+}
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 1af9dd8..eaad86b 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -15,8 +15,16 @@
 #ifndef _LINUX_HUGETLB_CGROUP_H
 #define _LINUX_HUGETLB_CGROUP_H
 
-extern long region_add(struct list_head *head, long f, long t);
-extern long region_chg(struct list_head *head, long f, long t);
+struct file_region {
+	long from, to;
+	unsigned long data;
+	struct list_head link;
+};
+
+extern long region_chg(struct list_head *head, long f, long t,
+		       unsigned long data);
+extern void region_add(struct list_head *head, long f, long t,
+		       unsigned long data);
 extern long region_truncate(struct list_head *head, long end);
 extern long region_count(struct list_head *head, long f, long t);
 
@@ -40,7 +48,7 @@ extern void hugetlb_priv_page_uncharge(struct resv_map *map,
 static inline long hugetlb_page_charge(struct list_head *head,
 				       struct hstate *h, long f, long t)
 {
-	return region_chg(head, f, t);
+	return region_chg(head, f, t, 0);
 }
 
 static inline void hugetlb_page_uncharge(struct list_head *head,
@@ -52,8 +60,7 @@ static inline void hugetlb_page_uncharge(struct list_head *head,
 static inline void hugetlb_commit_page_charge(struct list_head *head,
 					      long f, long t)
 {
-	region_add(head, f, t);
-	return;
+	return region_add(head, f, t, 0);
 }
 
 static inline long hugetlb_truncate_cgroup(struct hstate *h,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e1a0328..08555c6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -59,165 +59,6 @@ static unsigned long __initdata default_hstate_size;
 static DEFINE_SPINLOCK(hugetlb_lock);
 
 /*
- * Region tracking -- allows tracking of reservations and instantiated pages
- *                    across the pages in a mapping.
- *
- * The region data structures are protected by a combination of the mmap_sem
- * and the hugetlb_instantion_mutex.  To access or modify a region the caller
- * must either hold the mmap_sem for write, or the mmap_sem for read and
- * the hugetlb_instantiation mutex:
- *
- *	down_write(&mm->mmap_sem);
- * or
- *	down_read(&mm->mmap_sem);
- *	mutex_lock(&hugetlb_instantiation_mutex);
- */
-struct file_region {
-	struct list_head link;
-	long from;
-	long to;
-};
-
-long region_add(struct list_head *head, long f, long t)
-{
-	struct file_region *rg, *nrg, *trg;
-
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (f <= rg->to)
-			break;
-
-	/* Round our left edge to the current segment if it encloses us. */
-	if (f > rg->from)
-		f = rg->from;
-
-	/* Check for and consume any regions we now overlap with. */
-	nrg = rg;
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > t)
-			break;
-
-		/* If this area reaches higher then extend our area to
-		 * include it completely.  If this is not the first area
-		 * which we intend to reuse, free it. */
-		if (rg->to > t)
-			t = rg->to;
-		if (rg != nrg) {
-			list_del(&rg->link);
-			kfree(rg);
-		}
-	}
-	nrg->from = f;
-	nrg->to = t;
-	return 0;
-}
-
-long region_chg(struct list_head *head, long f, long t)
-{
-	struct file_region *rg, *nrg;
-	long chg = 0;
-
-	/* Locate the region we are before or in. */
-	list_for_each_entry(rg, head, link)
-		if (f <= rg->to)
-			break;
-
-	/* If we are below the current region then a new region is required.
-	 * Subtle, allocate a new region at the position but make it zero
-	 * size such that we can guarantee to record the reservation. */
-	if (&rg->link == head || t < rg->from) {
-		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
-		if (!nrg)
-			return -ENOMEM;
-		nrg->from = f;
-		nrg->to   = f;
-		INIT_LIST_HEAD(&nrg->link);
-		list_add(&nrg->link, rg->link.prev);
-
-		return t - f;
-	}
-
-	/* Round our left edge to the current segment if it encloses us. */
-	if (f > rg->from)
-		f = rg->from;
-	chg = t - f;
-
-	/* Check for and consume any regions we now overlap with. */
-	list_for_each_entry(rg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > t)
-			return chg;
-
-		/* We overlap with this area, if it extends further than
-		 * us then we must extend ourselves.  Account for its
-		 * existing reservation. */
-		if (rg->to > t) {
-			chg += rg->to - t;
-			t = rg->to;
-		}
-		chg -= rg->to - rg->from;
-	}
-	return chg;
-}
-
-long region_truncate(struct list_head *head, long end)
-{
-	struct file_region *rg, *trg;
-	long chg = 0;
-
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (end <= rg->to)
-			break;
-	if (&rg->link == head)
-		return 0;
-
-	/* If we are in the middle of a region then adjust it. */
-	if (end > rg->from) {
-		chg = rg->to - end;
-		rg->to = end;
-		rg = list_entry(rg->link.next, typeof(*rg), link);
-	}
-
-	/* Drop any remaining regions. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		chg += rg->to - rg->from;
-		list_del(&rg->link);
-		kfree(rg);
-	}
-	return chg;
-}
-
-long region_count(struct list_head *head, long f, long t)
-{
-	struct file_region *rg;
-	long chg = 0;
-
-	/* Locate each segment we overlap with, and count that overlap. */
-	list_for_each_entry(rg, head, link) {
-		int seg_from;
-		int seg_to;
-
-		if (rg->to <= f)
-			continue;
-		if (rg->from >= t)
-			break;
-
-		seg_from = max(rg->from, f);
-		seg_to = min(rg->to, t);
-
-		chg += seg_to - seg_from;
-	}
-
-	return chg;
-}
-
-/*
  * Convert the address within this vma to the page offset within
  * the mapping, in pagecache page units; huge pages here.
  */
@@ -1008,7 +849,7 @@ static long vma_needs_reservation(struct hstate *h,
 		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
 		struct resv_map *reservations = vma_resv_map(vma);
 
-		err = region_chg(&reservations->regions, idx, idx + 1);
+		err = region_chg(&reservations->regions, idx, idx + 1, 0);
 		if (err < 0)
 			return err;
 		return 0;
@@ -1052,7 +893,7 @@ static void vma_commit_reservation(struct hstate *h,
 		struct resv_map *reservations = vma_resv_map(vma);
 
 		/* Mark this page used in the map. */
-		region_add(&reservations->regions, idx, idx + 1);
+		region_add(&reservations->regions, idx, idx + 1, 0);
 	}
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
