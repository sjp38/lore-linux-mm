Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 1DD6A6B00E7
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:21 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:17:24 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBM1PG1249316
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:01 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBM0fl019596
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:00 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 1/9] hugetlbfs: Add new HugeTLB cgroup
Date: Mon, 20 Feb 2012 16:51:34 +0530
Message-Id: <1329736902-26870-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

hugetlb controller helps in controlling the number of hugepages a cgroup
can allocate. We enforce the limit during mmap time and NOT during fault
time. The behaviour is similar to hugetlb quota support but quota enforce
the limit per hugetlb mount point.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/Makefile          |    1 +
 fs/hugetlbfs/hugetlb_cgroup.c  |  196 ++++++++++++++++++++++++++++++++++++++++
 include/linux/cgroup_subsys.h  |    6 ++
 include/linux/hugetlb.h        |   12 ++-
 include/linux/hugetlb_cgroup.h |   21 +++++
 init/Kconfig                   |   10 ++
 mm/hugetlb.c                   |   58 ++++++++++++-
 7 files changed, 301 insertions(+), 3 deletions(-)
 create mode 100644 fs/hugetlbfs/hugetlb_cgroup.c
 create mode 100644 include/linux/hugetlb_cgroup.h

diff --git a/fs/hugetlbfs/Makefile b/fs/hugetlbfs/Makefile
index 6adf870..986c778 100644
--- a/fs/hugetlbfs/Makefile
+++ b/fs/hugetlbfs/Makefile
@@ -5,3 +5,4 @@
 obj-$(CONFIG_HUGETLBFS) += hugetlbfs.o
 
 hugetlbfs-objs := inode.o
+hugetlbfs-$(CONFIG_CGROUP_HUGETLB_RES_CTLR) += hugetlb_cgroup.o
diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
new file mode 100644
index 0000000..b5b3cb8
--- /dev/null
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -0,0 +1,196 @@
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
+#include <linux/res_counter.h>
+
+/* lifted from mem control */
+#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
+#define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
+#define MEMFILE_ATTR(val)	((val) & 0xffff)
+
+struct hugetlb_cgroup {
+	struct cgroup_subsys_state css;
+	/*
+	 * the counter to account for hugepages from hugetlb.
+	 */
+	struct res_counter memhuge[HUGE_MAX_HSTATE];
+};
+
+struct cgroup_subsys hugetlb_subsys __read_mostly;
+struct hugetlb_cgroup *root_h_cgroup __read_mostly;
+
+static inline
+struct hugetlb_cgroup *css_to_hugetlbcgroup(struct cgroup_subsys_state *s)
+{
+	return container_of(s, struct hugetlb_cgroup, css);
+}
+
+static inline
+struct hugetlb_cgroup *cgroup_to_hugetlbcgroup(struct cgroup *cgroup)
+{
+	return css_to_hugetlbcgroup(cgroup_subsys_state(cgroup,
+							hugetlb_subsys_id));
+}
+
+static inline
+struct hugetlb_cgroup *task_hugetlbcgroup(struct task_struct *task)
+{
+	return css_to_hugetlbcgroup(task_subsys_state(task, hugetlb_subsys_id));
+}
+
+static inline int hugetlb_cgroup_is_root(struct hugetlb_cgroup *h_cg)
+{
+	return (h_cg == root_h_cgroup);
+}
+
+u64 hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft)
+{
+	int name, idx;
+	unsigned long long val;
+	struct hugetlb_cgroup *h_cgroup = cgroup_to_hugetlbcgroup(cgroup);
+
+	idx = MEMFILE_TYPE(cft->private);
+	name = MEMFILE_ATTR(cft->private);
+
+	val = res_counter_read_u64(&h_cgroup->memhuge[idx], name);
+	return val;
+}
+
+int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
+			 const char *buffer)
+{
+	int name, ret, idx;
+	unsigned long long val;
+	struct hugetlb_cgroup *h_cgroup = cgroup_to_hugetlbcgroup(cgroup);
+
+	/* This function does all necessary parse...reuse it */
+	ret = res_counter_memparse_write_strategy(buffer, &val);
+	if (ret)
+		return ret;
+
+	idx = MEMFILE_TYPE(cft->private);
+	name = MEMFILE_ATTR(cft->private);
+
+	switch (name) {
+	case RES_LIMIT:
+		ret = res_counter_set_limit(&h_cgroup->memhuge[idx], val);
+		break;
+
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int hugetlbcgroup_can_attach(struct cgroup_subsys *ss,
+				    struct cgroup *new_cgrp,
+				    struct cgroup_taskset *set)
+{
+	struct hugetlb_cgroup *h_cg;
+	struct task_struct *task = cgroup_taskset_first(set);
+	/*
+	 * Make sure all the task in the set are in root cgroup
+	 * We only allow move from root cgroup to other cgroup.
+	 */
+	while (task != NULL) {
+		rcu_read_lock();
+		h_cg = task_hugetlbcgroup(task);
+		if (!hugetlb_cgroup_is_root(h_cg)) {
+			rcu_read_unlock();
+			return -EOPNOTSUPP;
+		}
+		rcu_read_unlock();
+		task = cgroup_taskset_next(set);
+	}
+	return 0;
+}
+
+/*
+ * called from kernel/cgroup.c with cgroup_lock() held.
+ */
+static struct cgroup_subsys_state *
+hugetlbcgroup_create(struct cgroup_subsys *ss, struct cgroup *cgroup)
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
+		parent_h_cgroup = cgroup_to_hugetlbcgroup(parent_cgroup);
+		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
+			res_counter_init(&h_cgroup->memhuge[idx],
+					 &parent_h_cgroup->memhuge[idx]);
+	} else {
+		root_h_cgroup = h_cgroup;
+		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
+			res_counter_init(&h_cgroup->memhuge[idx], NULL);
+	}
+	return &h_cgroup->css;
+}
+
+static int hugetlbcgroup_pre_destroy(struct cgroup_subsys *ss,
+				     struct cgroup *cgroup)
+{
+	u64 val;
+	int idx;
+	struct hugetlb_cgroup *h_cgroup;
+
+	h_cgroup = cgroup_to_hugetlbcgroup(cgroup);
+	/*
+	 * We don't allow a cgroup deletion if it have some
+	 * resource charged against it.
+	 */
+	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
+		val = res_counter_read_u64(&h_cgroup->memhuge[idx], RES_USAGE);
+		if (val)
+			return -EBUSY;
+	}
+	return 0;
+}
+
+static void hugetlbcgroup_destroy(struct cgroup_subsys *ss,
+				  struct cgroup *cgroup)
+{
+	struct hugetlb_cgroup *h_cgroup;
+
+	h_cgroup = cgroup_to_hugetlbcgroup(cgroup);
+	kfree(h_cgroup);
+}
+
+static int hugetlbcgroup_populate(struct cgroup_subsys *ss,
+				  struct cgroup *cgroup)
+{
+	return register_hugetlb_cgroup_files(ss, cgroup);
+}
+
+struct cgroup_subsys hugetlb_subsys = {
+	.name = "hugetlb",
+	.can_attach = hugetlbcgroup_can_attach,
+	.create     = hugetlbcgroup_create,
+	.pre_destroy = hugetlbcgroup_pre_destroy,
+	.destroy    = hugetlbcgroup_destroy,
+	.populate   = hugetlbcgroup_populate,
+	.subsys_id  = hugetlb_subsys_id,
+};
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
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index d9d6c86..2b6b231 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -4,6 +4,7 @@
 #include <linux/mm_types.h>
 #include <linux/fs.h>
 #include <linux/hugetlb_inline.h>
+#include <linux/cgroup.h>
 
 struct ctl_table;
 struct user_struct;
@@ -68,7 +69,8 @@ int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
 void hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
-
+int register_hugetlb_cgroup_files(struct cgroup_subsys *ss,
+				  struct cgroup *cgroup);
 #else /* !CONFIG_HUGETLB_PAGE */
 
 static inline int PageHuge(struct page *page)
@@ -109,7 +111,11 @@ static inline void copy_huge_page(struct page *dst, struct page *src)
 }
 
 #define hugetlb_change_protection(vma, address, end, newprot)
-
+static inline int register_huge_cgroup_files(struct cgroup_subsys *ss,
+					 struct cgroup *cgroup);
+{
+	return 0;
+}
 #endif /* !CONFIG_HUGETLB_PAGE */
 
 #define HUGETLB_ANON_FILE "anon_hugepage"
@@ -220,6 +226,8 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	/* cgroup control files */
+	struct cftype cgroup_limit_file;
 	char name[HSTATE_NAME_LEN];
 };
 
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
new file mode 100644
index 0000000..2330dd0
--- /dev/null
+++ b/include/linux/hugetlb_cgroup.h
@@ -0,0 +1,21 @@
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
+extern u64 hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft);
+extern int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
+				const char *buffer);
+#endif
diff --git a/init/Kconfig b/init/Kconfig
index 3f42cd6..78d4961 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -673,6 +673,16 @@ config CGROUP_MEM_RES_CTLR
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.
 
+config CGROUP_HUGETLB_RES_CTLR
+	bool "HugeTLB Resource Controller for Control Groups"
+	depends on RESOURCE_COUNTERS && HUGETLBFS
+	help
+	  Provides a simple cgroup Resource Controller for HugeTLB pages.
+	  The controller limit is enforced during mmap(2) time, so that
+	  application can fall back to allocation using smaller page size
+	  if the cgroup resource limit prevented them from allocating HugeTLB
+	  pages.
+
 config CGROUP_MEM_RES_CTLR_SWAP
 	bool "Memory Resource Controller Swap Extension"
 	depends on CGROUP_MEM_RES_CTLR && SWAP
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f34bd8..f643f72 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -28,6 +28,11 @@
 
 #include <linux/hugetlb.h>
 #include <linux/node.h>
+#include <linux/cgroup.h>
+#include <linux/hugetlb_cgroup.h>
+#include <linux/res_counter.h>
+#include <linux/page_cgroup.h>
+
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
@@ -1798,6 +1803,57 @@ static int __init hugetlb_init(void)
 }
 module_init(hugetlb_init);
 
+#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
+int register_hugetlb_cgroup_files(struct cgroup_subsys *ss,
+				  struct cgroup *cgroup)
+{
+	int ret = 0;
+	struct hstate *h;
+
+	for_each_hstate(h) {
+		ret = cgroup_add_file(cgroup, ss, &h->cgroup_limit_file);
+		if (ret)
+			return ret;
+	}
+	return ret;
+}
+
+#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
+static char *mem_fmt(char *buf, unsigned long n)
+{
+	if (n >= (1UL << 30))
+		sprintf(buf, "%luGB", n >> 30);
+	else if (n >= (1UL << 20))
+		sprintf(buf, "%luMB", n >> 20);
+	else
+		sprintf(buf, "%luKB", n >> 10);
+	return buf;
+}
+
+static int hugetlb_cgroup_file_init(struct hstate *h, int idx)
+{
+	char buf[32];
+	struct cftype *cft;
+
+	/* format the size */
+	mem_fmt(buf, huge_page_size(h));
+
+	/* Add the limit file */
+	cft = &h->cgroup_limit_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.limit_in_bytes", buf);
+	cft->private = MEMFILE_PRIVATE(idx, RES_LIMIT);
+	cft->read_u64 = hugetlb_cgroup_read;
+	cft->write_string = hugetlb_cgroup_write;
+
+	return 0;
+}
+#else
+static int hugetlb_cgroup_file_init(struct hstate *h, int idx)
+{
+	return 0;
+}
+#endif
+
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_add_hstate(unsigned order)
 {
@@ -1821,7 +1877,7 @@ void __init hugetlb_add_hstate(unsigned order)
 	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
 					huge_page_size(h)/1024);
-
+	hugetlb_cgroup_file_init(h, max_hstate - 1);
 	parsed_hstate = h;
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
