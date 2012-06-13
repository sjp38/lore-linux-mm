Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 306C76B0074
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 06:28:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 13 Jun 2012 15:58:17 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5DASD7U46268460
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 15:58:13 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5DFvh0E001124
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:27:46 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V9 12/15] hugetlb/cgroup: Add support for cgroup removal
Date: Wed, 13 Jun 2012 15:57:31 +0530
Message-Id: <1339583254-895-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch add support for cgroup removal. If we don't have parent
cgroup, the charges are moved to root cgroup.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb_cgroup.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 68 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 0f2f6ac..a3a68a4 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -107,10 +107,76 @@ static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
 	kfree(h_cgroup);
 }
 
+
+/*
+ * Should be called with hugetlb_lock held.
+ * Since we are holding hugetlb_lock, pages cannot get moved from
+ * active list or uncharged from the cgroup, So no need to get
+ * page reference and test for page active here. This function
+ * cannot fail.
+ */
+static void hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
+				       struct page *page)
+{
+	int csize;
+	struct res_counter *counter;
+	struct res_counter *fail_res;
+	struct hugetlb_cgroup *page_hcg;
+	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
+	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
+
+	page_hcg = hugetlb_cgroup_from_page(page);
+	/*
+	 * We can have pages in active list without any cgroup
+	 * ie, hugepage with less than 3 pages. We can safely
+	 * ignore those pages.
+	 */
+	if (!page_hcg || page_hcg != h_cg)
+		goto out;
+
+	csize = PAGE_SIZE << compound_order(page);
+	if (!parent) {
+		parent = root_h_cgroup;
+		/* root has no limit */
+		res_counter_charge_nofail(&parent->hugepage[idx],
+					  csize, &fail_res);
+	}
+	counter = &h_cg->hugepage[idx];
+	res_counter_uncharge_until(counter, counter->parent, csize);
+
+	set_hugetlb_cgroup(page, parent);
+out:
+	return;
+}
+
+/*
+ * Force the hugetlb cgroup to empty the hugetlb resources by moving them to
+ * the parent cgroup.
+ */
 static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
 {
-	/* We will add the cgroup removal support in later patches */
-	   return -EBUSY;
+	struct hstate *h;
+	struct page *page;
+	int ret = 0, idx = 0;
+
+	do {
+		if (cgroup_task_count(cgroup) ||
+		    !list_empty(&cgroup->children)) {
+			ret = -EBUSY;
+			goto out;
+		}
+		for_each_hstate(h) {
+			spin_lock(&hugetlb_lock);
+			list_for_each_entry(page, &h->hugepage_activelist, lru)
+				hugetlb_cgroup_move_parent(idx, cgroup, page);
+
+			spin_unlock(&hugetlb_lock);
+			idx++;
+		}
+		cond_resched();
+	} while (hugetlb_cgroup_have_usage(cgroup));
+out:
+	return ret;
 }
 
 int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
