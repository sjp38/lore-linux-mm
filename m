Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 792676B00E8
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:25 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:14:50 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBMG9j1523956
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:17 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBMFrF020120
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:16 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 7/9] hugetlbfs: Add truncate region functions
Date: Mon, 20 Feb 2012 16:51:40 +0530
Message-Id: <1329736902-26870-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This will later be used by the task migration patches.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/hugetlb_cgroup.c  |   84 ++++++++++++++++++++++++++++++++++++++++
 fs/hugetlbfs/region.c          |   58 +++++++++++++++++++++++++++
 include/linux/hugetlb_cgroup.h |   12 +++++-
 3 files changed, 153 insertions(+), 1 deletions(-)

diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index a4c6786..b8b319b 100644
--- a/fs/hugetlbfs/hugetlb_cgroup.c
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -323,6 +323,90 @@ long hugetlb_truncate_cgroup(struct hstate *h,
 	return chg;
 }
 
+long hugetlb_truncate_cgroup_range(struct hstate *h,
+				   struct list_head *head, long from, long to)
+{
+	long chg = 0, csize;
+	int idx = h - hstates;
+	struct hugetlb_cgroup *h_cg;
+	struct file_region *rg, *trg;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (from <= rg->to)
+			break;
+	if (&rg->link == head)
+		return 0;
+
+	/* If we are in the middle of a region then adjust it. */
+	if (from > rg->from) {
+		if (to < rg->to) {
+			struct file_region *nrg;
+			/* rg->from from to rg->to */
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
+			h_cg = (struct hugetlb_cgroup *)rg->data;
+			if (!hugetlb_cgroup_is_root(h_cg)) {
+				csize = chg * huge_page_size(h);
+				res_counter_uncharge(&h_cg->memhuge[idx],
+						     csize);
+			}
+			return chg;
+		}
+		chg = rg->to - from;
+		rg->to = from;
+		h_cg = (struct hugetlb_cgroup *)rg->data;
+		if (!hugetlb_cgroup_is_root(h_cg)) {
+			csize = chg * huge_page_size(h);
+			res_counter_uncharge(&h_cg->memhuge[idx], csize);
+		}
+		rg = list_entry(rg->link.next, typeof(*rg), link);
+	}
+	/* Drop any remaining regions till to */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (rg->from >= to)
+			break;
+		if (&rg->link == head)
+			break;
+		if (rg->to > to) {
+			/* rg->from to rg->to */
+			chg += to - rg->from;
+			rg->from = to;
+			h_cg = (struct hugetlb_cgroup *)rg->data;
+			if (!hugetlb_cgroup_is_root(h_cg)) {
+				csize = (to - rg->from) * huge_page_size(h);
+				res_counter_uncharge(&h_cg->memhuge[idx],
+						     csize);
+			}
+			return chg;
+		}
+		chg += rg->to - rg->from;
+		h_cg = (struct hugetlb_cgroup *)rg->data;
+		if (!hugetlb_cgroup_is_root(h_cg)) {
+			csize = (rg->to - rg->from) * huge_page_size(h);
+			res_counter_uncharge(&h_cg->memhuge[idx], csize);
+		}
+		list_del(&rg->link);
+		kfree(rg);
+	}
+	return chg;
+}
+
 int hugetlb_priv_page_charge(struct resv_map *map, struct hstate *h, long chg)
 {
 	long csize;
diff --git a/fs/hugetlbfs/region.c b/fs/hugetlbfs/region.c
index d2445fb..8ac63b0 100644
--- a/fs/hugetlbfs/region.c
+++ b/fs/hugetlbfs/region.c
@@ -200,3 +200,61 @@ long region_count(struct list_head *head, long f, long t)
 
 	return chg;
 }
+
+long region_truncate_range(struct list_head *head, long from, long to)
+{
+	long chg = 0;
+	struct file_region *rg, *trg;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (from <= rg->to)
+			break;
+	if (&rg->link == head)
+		return 0;
+
+	/* If we are in the middle of a region then adjust it. */
+	if (from > rg->from) {
+		if (to < rg->to) {
+			struct file_region *nrg;
+			/* rf->from f t rg->to */
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
+		rg = list_entry(rg->link.next, typeof(*rg), link);
+	}
+	/* Drop any remaining regions till to */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (rg->from >= to)
+			break;
+		if (&rg->link == head)
+			break;
+		if (rg->to > to) {
+			chg += to - rg->from;
+			rg->from = to;
+			return chg;
+		}
+		chg += rg->to - rg->from;
+		list_del(&rg->link);
+		kfree(rg);
+	}
+	return chg;
+}
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index eaad86b..68c1d61 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -27,7 +27,7 @@ extern void region_add(struct list_head *head, long f, long t,
 		       unsigned long data);
 extern long region_truncate(struct list_head *head, long end);
 extern long region_count(struct list_head *head, long f, long t);
-
+extern long region_truncate_range(struct list_head *head, long from, long end);
 #ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
 extern u64 hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft);
 extern int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
@@ -40,6 +40,9 @@ extern void hugetlb_page_uncharge(struct list_head *head,
 extern void hugetlb_commit_page_charge(struct list_head *head, long f, long t);
 extern long hugetlb_truncate_cgroup(struct hstate *h,
 				    struct list_head *head, long from);
+extern long  hugetlb_truncate_cgroup_range(struct hstate *h,
+					   struct list_head *head,
+					   long from, long end);
 extern int hugetlb_priv_page_charge(struct resv_map *map,
 				    struct hstate *h, long chg);
 extern void hugetlb_priv_page_uncharge(struct resv_map *map,
@@ -69,6 +72,13 @@ static inline long hugetlb_truncate_cgroup(struct hstate *h,
 	return region_truncate(head, from);
 }
 
+static inline long  hugetlb_truncate_cgroup_range(struct hstate *h,
+						  struct list_head *head,
+						  long from, long end)
+{
+	return region_truncate_range(head, from, end);
+}
+
 static inline int hugetlb_priv_page_charge(struct resv_map *map,
 					   struct hstate *h, long chg)
 {
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
