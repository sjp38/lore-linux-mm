Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 58FC36B00ED
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:51:47 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 7 Apr 2012 00:21:45 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q36IpgTE4419586
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 00:21:42 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q370MAnN007886
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 10:22:11 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 10/14] hugetlbfs: Add memcg control files for hugetlbfs
Date: Sat,  7 Apr 2012 00:20:56 +0530
Message-Id: <1333738260-1329-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This add control files for hugetlbfs in memcg

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h    |    5 +++++
 include/linux/memcontrol.h |    7 ++++++
 mm/hugetlb.c               |    2 +-
 mm/memcontrol.c            |   51 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 64 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 995c238..d008342 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -4,6 +4,7 @@
 #include <linux/mm_types.h>
 #include <linux/fs.h>
 #include <linux/hugetlb_inline.h>
+#include <linux/cgroup.h>
 
 struct ctl_table;
 struct user_struct;
@@ -203,6 +204,10 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
+	/* mem cgroup control files */
+	struct cftype mem_cgroup_files[4];
+#endif
 	char name[HSTATE_NAME_LEN];
 };
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1d07e14..4f17574 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -459,6 +459,7 @@ extern void mem_cgroup_hugetlb_uncharge_page(int idx, unsigned long nr_pages,
 					     struct page *page);
 extern void mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
 					      struct mem_cgroup *memcg);
+extern int mem_cgroup_hugetlb_file_init(int idx) __init;
 
 #else
 static inline int
@@ -489,6 +490,12 @@ mem_cgroup_hugetlb_uncharge_memcg(int idx, unsigned long nr_pages,
 {
 	return;
 }
+
+static inline int mem_cgroup_hugetlb_file_init(int idx)
+{
+	return 0;
+}
+
 #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dd00087..340e575 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1931,7 +1931,7 @@ void __init hugetlb_add_hstate(unsigned order)
 	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
 					huge_page_size(h)/1024);
-
+	mem_cgroup_hugetlb_file_init(hugetlb_max_hstate - 1);
 	parsed_hstate = h;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3bb3b42..7d3330e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5191,6 +5191,57 @@ static void mem_cgroup_destroy(struct cgroup *cont)
 	mem_cgroup_put(memcg);
 }
 
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
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
+int __init mem_cgroup_hugetlb_file_init(int idx)
+{
+	char buf[32];
+	struct cftype *cft;
+	struct hstate *h = &hstates[idx];
+
+	/* format the size */
+	mem_fmt(buf, huge_page_size(h));
+
+	/* Add the limit file */
+	cft = &h->mem_cgroup_files[0];
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.limit_in_bytes", buf);
+	cft->private = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_LIMIT);
+	cft->read = mem_cgroup_read;
+	cft->write_string = mem_cgroup_write;
+
+	/* Add the usage file */
+	cft = &h->mem_cgroup_files[1];
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.usage_in_bytes", buf);
+	cft->private  = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_USAGE);
+	cft->read = mem_cgroup_read;
+
+	/* Add the MAX usage file */
+	cft = &h->mem_cgroup_files[2];
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.max_usage_in_bytes", buf);
+	cft->private  = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_MAX_USAGE);
+	cft->trigger  = mem_cgroup_reset;
+	cft->read = mem_cgroup_read;
+
+	/* NULL terminate the last cft */
+	cft = &h->mem_cgroup_files[3];
+	memset(cft, 0, sizeof(*cft));
+
+	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys, h->mem_cgroup_files));
+
+	return 0;
+}
+#endif
+
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-- 
1.7.10.rc3.3.g19a6c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
