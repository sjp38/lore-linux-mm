Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id CB2876B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 03:09:15 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 13 Mar 2012 12:39:12 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2D78k2p475346
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 12:38:46 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2DCcWiA009189
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 18:08:33 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 5/8] hugetlbfs: Add memcg control files for hugetlbfs
Date: Tue, 13 Mar 2012 12:37:09 +0530
Message-Id: <1331622432-24683-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This add control files for hugetlbfs in memcg

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |   15 +++++++++++++++
 mm/hugetlb.c            |   32 +++++++++++++++++++++++++++++++-
 mm/memcontrol.c         |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 93 insertions(+), 1 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 5ed0ad7..8c1e855 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -4,6 +4,7 @@
 #include <linux/mm_types.h>
 #include <linux/fs.h>
 #include <linux/hugetlb_inline.h>
+#include <linux/cgroup.h>
 
 struct ctl_table;
 struct user_struct;
@@ -220,6 +221,10 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	/* cgroup control files */
+	struct cftype cgroup_limit_file;
+	struct cftype cgroup_usage_file;
+	struct cftype cgroup_max_usage_file;
 	char name[HSTATE_NAME_LEN];
 };
 
@@ -332,4 +337,14 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 #define hstate_index_to_shift(index) 0
 #endif
 
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
+extern int register_hugetlb_memcg_files(struct cgroup *cgroup,
+					struct cgroup_subsys *ss);
+#else
+static inline int register_hugetlb_memcg_files(struct cgroup *cgroup,
+					       struct cgroup_subsys *ss)
+{
+	return 0;
+}
+#endif
 #endif /* _LINUX_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b7152d1..30f66f1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1817,6 +1817,36 @@ static int __init hugetlb_init(void)
 }
 module_init(hugetlb_init);
 
+#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
+int register_hugetlb_memcg_files(struct cgroup *cgroup,
+				 struct cgroup_subsys *ss)
+{
+	int ret = 0;
+	struct hstate *h;
+
+	for_each_hstate(h) {
+		ret = cgroup_add_file(cgroup, ss, &h->cgroup_limit_file);
+		if (ret)
+			return ret;
+		ret = cgroup_add_file(cgroup, ss, &h->cgroup_usage_file);
+		if (ret)
+			return ret;
+		ret = cgroup_add_file(cgroup, ss, &h->cgroup_max_usage_file);
+		if (ret)
+			return ret;
+
+	}
+	return ret;
+}
+/* mm/memcontrol.c because mem_cgroup_read/write is not availabel outside */
+int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);
+#else
+static int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
+{
+	return 0;
+}
+#endif
+
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_add_hstate(unsigned order)
 {
@@ -1840,7 +1870,7 @@ void __init hugetlb_add_hstate(unsigned order)
 	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
 					huge_page_size(h)/1024);
-
+	mem_cgroup_hugetlb_file_init(h, hugetlb_max_hstate - 1);
 	parsed_hstate = h;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7ac8489..405e17d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5123,6 +5123,50 @@ static void mem_cgroup_destroy(struct cgroup_subsys *ss,
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
+int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
+{
+	char buf[32];
+	struct cftype *cft;
+
+	/* format the size */
+	mem_fmt(buf, huge_page_size(h));
+
+	/* Add the limit file */
+	cft = &h->cgroup_limit_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.limit_in_bytes", buf);
+	cft->private = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_LIMIT);
+	cft->read_u64 = mem_cgroup_read;
+	cft->write_string = mem_cgroup_write;
+
+	/* Add the usage file */
+	cft = &h->cgroup_usage_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.usage_in_bytes", buf);
+	cft->private  = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_USAGE);
+	cft->read_u64 = mem_cgroup_read;
+
+	/* Add the MAX usage file */
+	cft = &h->cgroup_max_usage_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.max_usage_in_bytes", buf);
+	cft->private  = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_MAX_USAGE);
+	cft->trigger  = mem_cgroup_reset;
+	cft->read_u64 = mem_cgroup_read;
+
+	return 0;
+}
+#endif
+
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
@@ -5137,6 +5181,9 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 	if (!ret)
 		ret = register_kmem_files(cont, ss);
 
+	if (!ret)
+		ret = register_hugetlb_memcg_files(cont, ss);
+
 	return ret;
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
