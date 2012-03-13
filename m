Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0E2BD6B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 03:09:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 13 Mar 2012 12:39:16 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2D79DCv3522784
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 12:39:13 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2DCcxuZ010603
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 18:08:59 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 7/8] memcg: move HugeTLB resource count to parent cgroup on memcg removal
Date: Tue, 13 Mar 2012 12:37:11 +0530
Message-Id: <1331622432-24683-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This add support for memcg removal with HugeTLB resource usage.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h    |    6 ++++
 include/linux/memcontrol.h |   15 ++++++++++++
 mm/hugetlb.c               |   32 +++++++++++++++++++++++++
 mm/memcontrol.c            |   55 ++++++++++++++++++++++++++++++++++++--------
 4 files changed, 98 insertions(+), 10 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index e62eee7..f98b29e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -341,11 +341,17 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
 extern int register_hugetlb_memcg_files(struct cgroup *cgroup,
 					struct cgroup_subsys *ss);
+extern int hugetlb_force_memcg_empty(struct cgroup *cgroup);
 #else
 static inline int register_hugetlb_memcg_files(struct cgroup *cgroup,
 					       struct cgroup_subsys *ss)
 {
 	return 0;
 }
+
+static inline int hugetlb_force_memcg_empty(struct cgroup *cgroup)
+{
+	return 0;
+}
 #endif
 #endif /* _LINUX_HUGETLB_H */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 320dbad..cf837de 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -440,6 +440,9 @@ extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
 					     struct page *page);
 extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
 					      struct mem_cgroup *memcg);
+extern int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
+					  struct page *page);
+extern int mem_cgroup_hugetlb_usage(struct cgroup *cgroup);
 
 #else
 static inline int
@@ -470,6 +473,18 @@ mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
 {
 	return;
 }
+static inline int
+mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
+			       struct page *page)
+{
+	return 0;
+}
+
+static inline int
+mem_cgroup_hugetlb_usage(struct cgroup *cgroup)
+{
+	return 0;
+}
 #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e038fdc..c7a1046 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1840,6 +1840,38 @@ int register_hugetlb_memcg_files(struct cgroup *cgroup,
 	}
 	return ret;
 }
+
+int hugetlb_force_memcg_empty(struct cgroup *cgroup)
+{
+	struct hstate *h;
+	struct page *page;
+	int ret = 0, idx = 0;
+
+	do {
+		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
+			goto out;
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
+	} while (mem_cgroup_hugetlb_usage(cgroup) > 0);
+out:
+	return ret;
+}
+
 /* mm/memcontrol.c because mem_cgroup_read/write is not availabel outside */
 int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);
 #else
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 405e17d..b77e0bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3171,9 +3171,11 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 #endif
 
 #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
-static int mem_cgroup_hugetlb_usage(struct mem_cgroup *memcg)
+int mem_cgroup_hugetlb_usage(struct cgroup *cgroup)
 {
 	int idx;
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
+
 	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
 		if (memcg->hugepage[idx].usage > 0)
 			return memcg->hugepage[idx].usage;
@@ -3285,10 +3287,44 @@ void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
 		res_counter_uncharge(&memcg->hugepage[idx], csize);
 	return;
 }
-#else
-static int mem_cgroup_hugetlb_usage(struct mem_cgroup *memcg)
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
+	 * uncharge from child and charge parent
+	 */
+	if (!mem_cgroup_is_root(parent)) {
+		ret = res_counter_charge(&parent->hugepage[idx], csize, &fail_res);
+		if (ret)
+			goto err_out;
+	}
+	res_counter_uncharge(&memcg->hugepage[idx], csize);
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
 
@@ -3806,6 +3842,11 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
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
@@ -5103,12 +5144,6 @@ static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 					struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	/*
-	 * Don't allow memcg removal if we have HugeTLB resource
-	 * usage.
-	 */
-	if (mem_cgroup_hugetlb_usage(memcg) > 0)
-		return -EBUSY;
 
 	return mem_cgroup_force_empty(memcg, false);
 }
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
