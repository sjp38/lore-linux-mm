Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9DEDC6B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 03:08:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 13 Mar 2012 12:38:08 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2D7859Z3043410
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 12:38:06 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2DCbp70007157
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 18:07:51 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 2/8] memcg: Add HugeTLB extension
Date: Tue, 13 Mar 2012 12:37:06 +0530
Message-Id: <1331622432-24683-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch implements a memcg extension that allows us to control
HugeTLB allocations via memory controller.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h    |    1 +
 include/linux/memcontrol.h |   42 +++++++++++++
 init/Kconfig               |    8 +++
 mm/hugetlb.c               |    2 +-
 mm/memcontrol.c            |  138 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 190 insertions(+), 1 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index d9d6c86..5ed0ad7 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -243,6 +243,7 @@ struct hstate *size_to_hstate(unsigned long size);
 #define HUGE_MAX_HSTATE 1
 #endif
 
+extern int hugetlb_max_hstate;
 extern struct hstate hstates[HUGE_MAX_HSTATE];
 extern unsigned int default_hstate_idx;
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4d34356..320dbad 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -429,5 +429,47 @@ static inline void sock_release_memcg(struct sock *sk)
 {
 }
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
+
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
+extern int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
+					  struct mem_cgroup **ptr);
+extern void mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
+					     struct mem_cgroup *memcg,
+					     struct page *page);
+extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
+					     struct page *page);
+extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
+					      struct mem_cgroup *memcg);
+
+#else
+static inline int
+mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
+						 struct mem_cgroup **ptr)
+{
+	return 0;
+}
+
+static inline void
+mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
+				 struct mem_cgroup *memcg,
+				 struct page *page)
+{
+	return;
+}
+
+static inline void
+mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
+				 struct page *page)
+{
+	return;
+}
+
+static inline void
+mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
+				  struct mem_cgroup *memcg)
+{
+	return;
+}
+#endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/init/Kconfig b/init/Kconfig
index 3f42cd6..f0eb8aa 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -725,6 +725,14 @@ config CGROUP_PERF
 
 	  Say N if unsure.
 
+config MEM_RES_CTLR_HUGETLB
+	bool "Memory Resource Controller HugeTLB Extension (EXPERIMENTAL)"
+	depends on CGROUP_MEM_RES_CTLR && HUGETLB_PAGE && EXPERIMENTAL
+	default n
+	help
+	  Add HugeTLB management to memory resource controller. When you
+	  enable this, you can put a per cgroup limit on HugeTLB usage.
+
 menuconfig CGROUP_SCHED
 	bool "Group CPU scheduler"
 	default n
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d623e71..fe7aefd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -34,7 +34,7 @@ const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-static int hugetlb_max_hstate;
+int hugetlb_max_hstate;
 unsigned int default_hstate_idx;
 struct hstate hstates[HUGE_MAX_HSTATE];
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6728a7a..8cac77b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -235,6 +235,10 @@ struct mem_cgroup {
 	 */
 	struct res_counter memsw;
 	/*
+	 * the counter to account for hugepages from hugetlb.
+	 */
+	struct res_counter hugepage[HUGE_MAX_HSTATE];
+	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
 	 */
@@ -3156,6 +3160,128 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #endif
 
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
+static int mem_cgroup_hugetlb_usage(struct mem_cgroup *memcg)
+{
+	int idx;
+	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
+		if (memcg->hugepage[idx].usage > 0)
+			return memcg->hugepage[idx].usage;
+	}
+	return 0;
+}
+
+int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
+				   struct mem_cgroup **ptr)
+{
+	int ret = 0;
+	struct mem_cgroup *memcg;
+	struct res_counter *fail_res;
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	if (mem_cgroup_disabled())
+		return 0;
+again:
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	if (!memcg)
+		memcg = root_mem_cgroup;
+	if (mem_cgroup_is_root(memcg)) {
+		rcu_read_unlock();
+		goto done;
+	}
+	if (!css_tryget(&memcg->css)) {
+		rcu_read_unlock();
+		goto again;
+	}
+	rcu_read_unlock();
+
+	ret = res_counter_charge(&memcg->hugepage[idx], csize, &fail_res);
+	css_put(&memcg->css);
+done:
+	*ptr = memcg;
+	return ret;
+}
+
+void mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
+				      struct mem_cgroup *memcg,
+				      struct page *page)
+{
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	pc = lookup_page_cgroup(page);
+	lock_page_cgroup(pc);
+	if (unlikely(PageCgroupUsed(pc))) {
+		unlock_page_cgroup(pc);
+		mem_cgroup_hugetlb_uncharge_memcg(idx, nr_pages, memcg);
+		return;
+	}
+	pc->mem_cgroup = memcg;
+	/*
+	 * We access a page_cgroup asynchronously without lock_page_cgroup().
+	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
+	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
+	 * before USED bit, we need memory barrier here.
+	 * See mem_cgroup_add_lru_list(), etc.
+	 */
+	smp_wmb();
+	SetPageCgroupUsed(pc);
+
+	unlock_page_cgroup(pc);
+	return;
+}
+
+void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
+				      struct page *page)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *memcg;
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!PageCgroupUsed(pc)))
+		return;
+
+	lock_page_cgroup(pc);
+	if (!PageCgroupUsed(pc)) {
+		unlock_page_cgroup(pc);
+		return;
+	}
+	memcg = pc->mem_cgroup;
+	pc->mem_cgroup = root_mem_cgroup;
+	ClearPageCgroupUsed(pc);
+	unlock_page_cgroup(pc);
+
+	if (!mem_cgroup_is_root(memcg))
+		res_counter_uncharge(&memcg->hugepage[idx], csize);
+	return;
+}
+
+void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
+				       struct mem_cgroup *memcg)
+{
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	if (!mem_cgroup_is_root(memcg))
+		res_counter_uncharge(&memcg->hugepage[idx], csize);
+	return;
+}
+#else
+static int mem_cgroup_hugetlb_usage(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+#endif /* CONFIG_MEM_RES_CTLR_HUGETLB */
+
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
@@ -4887,6 +5013,7 @@ err_cleanup:
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
+	int idx;
 	struct mem_cgroup *memcg, *parent;
 	long error = -ENOMEM;
 	int node;
@@ -4929,9 +5056,14 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		 * mem_cgroup(see mem_cgroup_put).
 		 */
 		mem_cgroup_get(parent);
+		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
+			res_counter_init(&memcg->hugepage[idx],
+					 &parent->hugepage[idx]);
 	} else {
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
+		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
+			res_counter_init(&memcg->hugepage[idx], NULL);
 	}
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
@@ -4951,6 +5083,12 @@ static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 					struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	/*
+	 * Don't allow memcg removal if we have HugeTLB resource
+	 * usage.
+	 */
+	if (mem_cgroup_hugetlb_usage(memcg) > 0)
+		return -EBUSY;
 
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
