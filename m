Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6A9CB6B007B
	for <linux-mm@kvack.org>; Wed, 30 May 2012 10:39:57 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 30 May 2012 20:09:55 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4UEdqT835651828
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:09:52 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4UK97IO027359
	for <linux-mm@kvack.org>; Thu, 31 May 2012 06:09:08 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 10/14] hugetlbfs: Add new HugeTLB cgroup
Date: Wed, 30 May 2012 20:08:55 +0530
Message-Id: <1338388739-22919-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch implements a new controller that allows us to control HugeTLB
allocations. The extension allows to limit the HugeTLB usage per control
group and enforces the controller limit during page fault.  Since HugeTLB
doesn't support page reclaim, enforcing the limit at page fault time implies
that, the application will get SIGBUS signal if it tries to access HugeTLB
pages beyond its limit. This requires the application to know beforehand
how much HugeTLB pages it would require for its use.

The charge/uncharge calls will be added to HugeTLB code in later patch.
Support for cgroup removal will be added in later patches.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/cgroup_subsys.h  |    6 +
 include/linux/hugetlb_cgroup.h |   79 ++++++++++++
 init/Kconfig                   |   14 ++
 mm/Makefile                    |    1 +
 mm/hugetlb_cgroup.c            |  280 ++++++++++++++++++++++++++++++++++++++++
 mm/page_cgroup.c               |    5 +-
 6 files changed, 383 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/hugetlb_cgroup.h
 create mode 100644 mm/hugetlb_cgroup.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 0bd390c..895923a 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -72,3 +72,9 @@ SUBSYS(net_prio)
 #endif
 
 /* */
+
+#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
+SUBSYS(hugetlb)
+#endif
+
+/* */
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
new file mode 100644
index 0000000..5794be4
--- /dev/null
+++ b/include/linux/hugetlb_cgroup.h
@@ -0,0 +1,79 @@
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
+#ifndef _LINUX_HUGETLB_CGROUP_H
+#define _LINUX_HUGETLB_CGROUP_H
+
+#include <linux/res_counter.h>
+
+struct hugetlb_cgroup {
+	struct cgroup_subsys_state css;
+	/*
+	 * the counter to account for hugepages from hugetlb.
+	 */
+	struct res_counter hugepage[HUGE_MAX_HSTATE];
+};
+
+#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
+static inline bool hugetlb_cgroup_disabled(void)
+{
+	if (hugetlb_subsys.disabled)
+		return true;
+	return false;
+}
+
+extern int hugetlb_cgroup_charge_page(int idx, unsigned long nr_pages,
+				      struct hugetlb_cgroup **ptr);
+extern void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
+					 struct hugetlb_cgroup *h_cg,
+					 struct page *page);
+extern void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
+					 struct page *page);
+extern void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
+					   struct hugetlb_cgroup *h_cg);
+#else
+static inline bool hugetlb_cgroup_disabled(void)
+{
+	return true;
+}
+
+static inline int
+hugetlb_cgroup_charge_page(int idx, unsigned long nr_pages,
+			   struct hugetlb_cgroup **ptr)
+{
+	return 0;
+}
+
+static inline void
+hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
+			     struct hugetlb_cgroup *h_cg,
+			     struct page *page)
+{
+	return;
+}
+
+static inline void
+hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages, struct page *page)
+{
+	return;
+}
+
+static inline void
+hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
+			       struct hugetlb_cgroup *h_cg)
+{
+	return;
+}
+#endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
+#endif
diff --git a/init/Kconfig b/init/Kconfig
index 1363203..73b14b0 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -714,6 +714,20 @@ config CGROUP_MEM_RES_CTLR
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.
 
+config CGROUP_HUGETLB_RES_CTLR
+	bool "HugeTLB Resource Controller for Control Groups"
+	depends on RESOURCE_COUNTERS && HUGETLB_PAGE && EXPERIMENTAL
+	select PAGE_CGROUP
+	default n
+	help
+	  Provides a simple cgroup Resource Controller for HugeTLB pages.
+	  When you enable this, you can put a per cgroup limit on HugeTLB usage.
+	  The limit is enforced during page fault. Since HugeTLB doesn't
+	  support page reclaim, enforcing the limit at page fault time implies
+	  that, the application will get SIGBUS signal if it tries to access
+	  HugeTLB pages beyond its limit. This requires the application to know
+	  beforehand how much HugeTLB pages it would require for its use.
+
 config CGROUP_MEM_RES_CTLR_SWAP
 	bool "Memory Resource Controller Swap Extension"
 	depends on CGROUP_MEM_RES_CTLR && SWAP
diff --git a/mm/Makefile b/mm/Makefile
index a70f9a9..bed4944 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -48,6 +48,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_HUGETLB_RES_CTLR) += hugetlb_cgroup.o
 obj-$(CONFIG_PAGE_CGROUP) += page_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
new file mode 100644
index 0000000..3a288f7
--- /dev/null
+++ b/mm/hugetlb_cgroup.c
@@ -0,0 +1,280 @@
+/*
+ *
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
+#include <linux/page_cgroup.h>
+#include <linux/hugetlb_cgroup.h>
+
+struct cgroup_subsys hugetlb_subsys __read_mostly;
+struct hugetlb_cgroup *root_h_cgroup __read_mostly;
+
+static inline
+struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
+{
+	return container_of(s, struct hugetlb_cgroup, css);
+}
+
+static inline
+struct hugetlb_cgroup *hugetlb_cgroup_from_cgroup(struct cgroup *cgroup)
+{
+	if (!cgroup)
+		return NULL;
+	return hugetlb_cgroup_from_css(cgroup_subsys_state(cgroup,
+							   hugetlb_subsys_id));
+}
+
+static inline
+struct hugetlb_cgroup *hugetlb_cgroup_from_task(struct task_struct *task)
+{
+	return hugetlb_cgroup_from_css(task_subsys_state(task,
+							 hugetlb_subsys_id));
+}
+
+static inline bool hugetlb_cgroup_is_root(struct hugetlb_cgroup *h_cg)
+{
+	return (h_cg == root_h_cgroup);
+}
+
+static struct hugetlb_cgroup *parent_hugetlb_cgroup(struct cgroup *cg)
+{
+	if (!cg->parent)
+		return NULL;
+	return hugetlb_cgroup_from_cgroup(cg->parent);
+}
+
+static inline bool hugetlb_cgroup_have_usage(struct cgroup *cg)
+{
+	int idx;
+	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cg);
+
+	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
+		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
+			return 1;
+	}
+	return 0;
+}
+
+static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
+{
+	int idx;
+	struct cgroup *parent_cgroup;
+	struct hugetlb_cgroup *h_cgroup, *parent_h_cgroup;
+
+	h_cgroup = kzalloc(sizeof(*h_cgroup), GFP_KERNEL);
+	if (!h_cgroup)
+		return ERR_PTR(-ENOMEM);
+
+	parent_cgroup = cgroup->parent;
+	if (parent_cgroup) {
+		parent_h_cgroup = hugetlb_cgroup_from_cgroup(parent_cgroup);
+		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
+			res_counter_init(&h_cgroup->hugepage[idx],
+					 &parent_h_cgroup->hugepage[idx]);
+	} else {
+		root_h_cgroup = h_cgroup;
+		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
+			res_counter_init(&h_cgroup->hugepage[idx], NULL);
+	}
+	return &h_cgroup->css;
+}
+
+static int hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
+				      struct page *page)
+{
+	int csize,  ret = 0;
+	struct page_cgroup *pc;
+	struct res_counter *counter;
+	struct res_counter *fail_res;
+	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
+	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
+
+	if (!get_page_unless_zero(page))
+		goto out;
+
+	pc = lookup_page_cgroup(page);
+	lock_page_cgroup(pc);
+	if (!PageCgroupUsed(pc) || pc->cgroup != cgroup)
+		goto err_out;
+
+	csize = PAGE_SIZE << compound_order(page);
+	/* If use_hierarchy == 0, we need to charge root */
+	if (!parent) {
+		parent = root_h_cgroup;
+		/* root has no limit */
+		res_counter_charge_nofail(&parent->hugepage[idx],
+					  csize, &fail_res);
+	}
+	counter = &h_cg->hugepage[idx];
+	res_counter_uncharge_until(counter, counter->parent, csize);
+
+	pc->cgroup = cgroup->parent;
+err_out:
+	unlock_page_cgroup(pc);
+	put_page(page);
+out:
+	return ret;
+}
+
+/*
+ * Force the hugetlb cgroup to empty the hugetlb resources by moving them to
+ * the parent cgroup.
+ */
+static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
+{
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
+				ret = hugetlb_cgroup_move_parent(idx, cgroup, page);
+				if (ret) {
+					spin_unlock(&hugetlb_lock);
+					goto out;
+				}
+			}
+			spin_unlock(&hugetlb_lock);
+			idx++;
+		}
+		cond_resched();
+	} while (hugetlb_cgroup_have_usage(cgroup));
+out:
+	return ret;
+}
+
+static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
+{
+	struct hugetlb_cgroup *h_cgroup;
+
+	h_cgroup = hugetlb_cgroup_from_cgroup(cgroup);
+	kfree(h_cgroup);
+}
+
+int hugetlb_cgroup_charge_page(int idx, unsigned long nr_pages,
+			       struct hugetlb_cgroup **ptr)
+{
+	int ret = 0;
+	struct res_counter *fail_res;
+	struct hugetlb_cgroup *h_cg = NULL;
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	if (hugetlb_cgroup_disabled())
+		goto done;
+again:
+	rcu_read_lock();
+	h_cg = hugetlb_cgroup_from_task(current);
+	if (!h_cg)
+		h_cg = root_h_cgroup;
+
+	if (!css_tryget(&h_cg->css)) {
+		rcu_read_unlock();
+		goto again;
+	}
+	rcu_read_unlock();
+
+	ret = res_counter_charge(&h_cg->hugepage[idx], csize, &fail_res);
+	css_put(&h_cg->css);
+done:
+	*ptr = h_cg;
+	return ret;
+}
+
+void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
+				  struct hugetlb_cgroup *h_cg,
+				  struct page *page)
+{
+	struct page_cgroup *pc;
+
+	if (hugetlb_cgroup_disabled())
+		return;
+
+	pc = lookup_page_cgroup(page);
+	lock_page_cgroup(pc);
+	if (unlikely(PageCgroupUsed(pc))) {
+		unlock_page_cgroup(pc);
+		hugetlb_cgroup_uncharge_cgroup(idx, nr_pages, h_cg);
+		return;
+	}
+	pc->cgroup = h_cg->css.cgroup;
+	SetPageCgroupUsed(pc);
+	unlock_page_cgroup(pc);
+	return;
+}
+
+void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
+				  struct page *page)
+{
+	struct page_cgroup *pc;
+	struct hugetlb_cgroup *h_cg;
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	if (hugetlb_cgroup_disabled())
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
+	h_cg = hugetlb_cgroup_from_cgroup(pc->cgroup);
+	pc->cgroup = root_h_cgroup->css.cgroup;
+	ClearPageCgroupUsed(pc);
+	unlock_page_cgroup(pc);
+
+	res_counter_uncharge(&h_cg->hugepage[idx], csize);
+	return;
+}
+
+void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
+				    struct hugetlb_cgroup *h_cg)
+{
+	unsigned long csize = nr_pages * PAGE_SIZE;
+
+	if (hugetlb_cgroup_disabled())
+		return;
+
+	res_counter_uncharge(&h_cg->hugepage[idx], csize);
+	return;
+}
+
+struct cgroup_subsys hugetlb_subsys = {
+	.name = "hugetlb",
+	.create     = hugetlb_cgroup_create,
+	.pre_destroy = hugetlb_cgroup_pre_destroy,
+	.destroy    = hugetlb_cgroup_destroy,
+	.subsys_id  = hugetlb_subsys_id,
+};
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 1ccbd71..26271b7 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -10,6 +10,7 @@
 #include <linux/cgroup.h>
 #include <linux/swapops.h>
 #include <linux/kmemleak.h>
+#include <linux/hugetlb_cgroup.h>
 
 static unsigned long total_usage;
 
@@ -68,7 +69,7 @@ void __init page_cgroup_init_flatmem(void)
 
 	int nid, fail;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && hugetlb_cgroup_disabled())
 		return;
 
 	for_each_online_node(nid)  {
@@ -268,7 +269,7 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int nid;
 
-	if (mem_cgroup_disabled())
+	if (mem_cgroup_disabled() && hugetlb_cgroup_disabled())
 		return;
 
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
