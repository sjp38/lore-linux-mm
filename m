Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 52C616B00E9
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:17:16 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:00:58 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219HAfK1450218
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:17:10 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219H81g004631
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:17:10 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 8/9] hugetlbfs: Add memcg control files for hugetlbfs
Date: Thu,  1 Mar 2012 14:46:19 +0530
Message-Id: <1330593380-1361-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This add control files for hugetlbfs in memcg

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |    5 ++++
 mm/hugetlb.c            |   39 ++++++++++++++++++++++++++++++++++++-
 mm/memcontrol.c         |   49 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 92 insertions(+), 1 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index d9d6c86..8498fa8 100644
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
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2d99d0a..9229715 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -23,6 +23,7 @@
 #include <linux/swapops.h>
 #include <linux/region.h>
 #include <linux/memcontrol.h>
+#include <linux/res_counter.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -1761,6 +1762,42 @@ static int __init hugetlb_init(void)
 }
 module_init(hugetlb_init);
 
+#ifdef CONFIG_MEM_RES_CTLR_NORECLAIM
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
+/* mm/memcontrol.c because mem_cgroup is not availabel outside */
+int hugetlb_memcg_file_init(struct hstate *h, int idx);
+#else
+int register_hugetlb_memcg_files(struct cgroup *cgroup,
+				  struct cgroup_subsys *ss)
+{
+	return 0;
+}
+
+static int hugetlb_memcg_file_init(struct hstate *h, int idx)
+{
+	return 0;
+}
+#endif
+
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_add_hstate(unsigned order)
 {
@@ -1784,7 +1821,7 @@ void __init hugetlb_add_hstate(unsigned order)
 	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
 					huge_page_size(h)/1024);
-
+	hugetlb_memcg_file_init(h, max_hstate - 1);
 	parsed_hstate = h;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 25bc5f7..410d53d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5012,6 +5012,52 @@ static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 	mem_cgroup_put(memcg);
 }
 
+#if defined(CONFIG_MEM_RES_CTLR_NORECLAIM) && defined(CONFIG_HUGETLBFS)
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
+int hugetlb_memcg_file_init(struct hstate *h, int idx)
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
+	cft->private = __MEMFILE_PRIVATE(idx, _MEMNORCL, RES_LIMIT);
+	cft->read_u64 = mem_cgroup_read;
+	cft->write_string = mem_cgroup_write;
+
+	/* Add the usage file */
+	cft = &h->cgroup_usage_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.usage_in_bytes", buf);
+	cft->private  = __MEMFILE_PRIVATE(idx, _MEMNORCL, RES_USAGE);
+	cft->read_u64 = mem_cgroup_read;
+
+	/* Add the MAX usage file */
+	cft = &h->cgroup_max_usage_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.max_usage_in_bytes", buf);
+	cft->private  = __MEMFILE_PRIVATE(idx, _MEMNORCL, RES_MAX_USAGE);
+	cft->trigger  = mem_cgroup_reset;
+	cft->read_u64 = mem_cgroup_read;
+
+	return 0;
+}
+#endif
+
+int register_hugetlb_memcg_files(struct cgroup *cgroup,
+				  struct cgroup_subsys *ss);
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
@@ -5026,6 +5072,9 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
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
