Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id A746A6B00F0
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:51:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 7 Apr 2012 00:21:50 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q36IplSL3944506
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 00:21:47 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q370MFZi008028
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 10:22:16 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 12/14] memcg: move HugeTLB resource count to parent cgroup on memcg removal
Date: Sat,  7 Apr 2012 00:20:58 +0530
Message-Id: <1333738260-1329-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This add support for memcg removal with HugeTLB resource usage.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h    |    8 ++++++
 include/linux/memcontrol.h |   14 +++++++++
 mm/hugetlb.c               |   43 ++++++++++++++++++++++++++++
 mm/memcontrol.c            |   68 +++++++++++++++++++++++++++++++++++++-------
 4 files changed, 123 insertions(+), 10 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6bf6afc..bada0ac 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -327,4 +327,12 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 #define hstate_index(h) 0
 #endif
 
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
+extern int hugetlb_force_memcg_empty(struct cgroup *cgroup);
+#else
+static inline int hugetlb_force_memcg_empty(struct cgroup *cgroup)
+{
+	return 0;
+}
+#endif
 #endif /* _LINUX_HUGETLB_H */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4f17574..70317e5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -460,6 +460,9 @@ extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
 extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
 					      struct mem_cgroup *memcg);
 extern int mem_cgroup_hugetlb_file_init(int idx) __init;
+extern int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
+					  struct page *page);
+extern bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup);
 
 #else
 static inline int
@@ -496,6 +499,17 @@ static inline int mem_cgroup_hugetlb_file_init(int idx)
 	return 0;
 }
 
+static inline int
+mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
+			       struct page *page)
+{
+	return 0;
+}
+
+static inline bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup)
+{
+	return 0;
+}
 #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8a520b5..1d3c8ea9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1909,6 +1909,49 @@ static int __init hugetlb_init(void)
 }
 module_init(hugetlb_init);
 
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
+/*
+ * Force the memcg to empty the hugetlb resources by moving them to
+ * the parent cgroup. We can fail if the parent cgroup's limit prevented
+ * the charging. This should only happen if use_hierarchy is not set.
+ */
+int hugetlb_force_memcg_empty(struct cgroup *cgroup)
+{
+	struct hstate *h;
+	struct page *page;
+	int ret = 0, idx = 0;
+
+	do {
+		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
+			goto out;
+		/*
+		 * If the task doing the cgroup_rmdir got a signal
+		 * we don't really need to loop till the hugetlb resource
+		 * usage become zero.
+		 */
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			goto out;
+		}
+		for_each_hstate(h) {
+			spin_lock(&hugetlb_lock);
+			list_for_each_entry(page, &h->hugepage_activelist, lru) {
+				ret = mem_cgroup_move_hugetlb_parent(idx, cgroup, page);
+				if (ret) {
+					spin_unlock(&hugetlb_lock);
+					goto out;
+				}
+			}
+			spin_unlock(&hugetlb_lock);
+			idx++;
+		}
+		cond_resched();
+	} while (mem_cgroup_have_hugetlb_usage(cgroup));
+out:
+	return ret;
+}
+#endif
+
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_add_hstate(unsigned order)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7d3330e..7b6e79a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3228,9 +3228,11 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 #endif
 
 #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
-static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
+bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup)
 {
 	int idx;
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
+
 	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
 		if ((res_counter_read_u64(&memcg->hugepage[idx], RES_USAGE)) > 0)
 			return 1;
@@ -3328,10 +3330,57 @@ void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
 	res_counter_uncharge(&memcg->hugepage[idx], csize);
 	return;
 }
-#else
-static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
+
+int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
+				   struct page *page)
 {
-	return 0;
+	struct page_cgroup *pc;
+	int csize,  ret = 0;
+	struct res_counter *fail_res;
+	struct cgroup *pcgrp = cgroup->parent;
+	struct mem_cgroup *parent = mem_cgroup_from_cont(pcgrp);
+	struct mem_cgroup *memcg  = mem_cgroup_from_cont(cgroup);
+
+	if (!get_page_unless_zero(page))
+		goto out;
+
+	pc = lookup_page_cgroup(page);
+	lock_page_cgroup(pc);
+	if (!PageCgroupUsed(pc) || pc->mem_cgroup != memcg)
+		goto err_out;
+
+	csize = PAGE_SIZE << compound_order(page);
+	/*
+	 * uncharge from child and charge the parent. If we have
+	 * use_hierarchy set, we can never fail here. In-order to make
+	 * sure we don't get -ENOMEM on parent charge, we first uncharge
+	 * the child and then charge the parent.
+	 */
+	if (parent->use_hierarchy) {
+		res_counter_uncharge(&memcg->hugepage[idx], csize);
+		if (!mem_cgroup_is_root(parent))
+			ret = res_counter_charge(&parent->hugepage[idx],
+						 csize, &fail_res);
+	} else {
+		if (!mem_cgroup_is_root(parent)) {
+			ret = res_counter_charge(&parent->hugepage[idx],
+						 csize, &fail_res);
+			if (ret) {
+				ret = -EBUSY;
+				goto err_out;
+			}
+		}
+		res_counter_uncharge(&memcg->hugepage[idx], csize);
+	}
+	/*
+	 * caller should have done css_get
+	 */
+	pc->mem_cgroup = parent;
+err_out:
+	unlock_page_cgroup(pc);
+	put_page(page);
+out:
+	return ret;
 }
 #endif /* CONFIG_MEM_RES_CTLR_HUGETLB */
 
@@ -3852,6 +3901,11 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
 	/* should free all ? */
 	if (free_all)
 		goto try_to_free;
+
+	/* move the hugetlb charges */
+	ret = hugetlb_force_memcg_empty(cgrp);
+	if (ret)
+		goto out;
 move_account:
 	do {
 		ret = -EBUSY;
@@ -5172,12 +5226,6 @@ free_out:
 static int mem_cgroup_pre_destroy(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	/*
-	 * Don't allow memcg removal if we have HugeTLB resource
-	 * usage.
-	 */
-	if (mem_cgroup_have_hugetlb_usage(memcg))
-		return -EBUSY;
 
 	return mem_cgroup_force_empty(memcg, false);
 }
-- 
1.7.10.rc3.3.g19a6c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
