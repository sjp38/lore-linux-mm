Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B7A2A6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 08:13:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 May 2012 17:20:56 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4MBhMxw51380460
	for <linux-mm@kvack.org>; Tue, 22 May 2012 17:13:23 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4MHD8gr002409
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:13:08 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] memcg/hugetlb: Add failcnt support for hugetlb extension
Date: Tue, 22 May 2012 17:13:11 +0530
Message-Id: <1337686991-26418-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, akpm@linux-foundation.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Expose the failcnt details to userspace similar to memory and memsw.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |    2 +-
 mm/memcontrol.c         |   40 ++++++++++++++++++++++++++--------------
 2 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index ee80bc8..cfe3cf5c 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -219,7 +219,7 @@ struct hstate {
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
 	/* mem cgroup control files */
-	struct cftype mem_cgroup_files[4];
+	struct cftype mem_cgroup_files[5];
 #endif
 	char name[HSTATE_NAME_LEN];
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f142ea9..bacb0df 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4189,7 +4189,7 @@ out:
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
-	int type, name;
+	int type, name, idx;
 
 	type = MEMFILE_TYPE(event);
 	name = MEMFILE_ATTR(event);
@@ -4197,24 +4197,29 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 	if (!do_swap_account && type == _MEMSWAP)
 		return -EOPNOTSUPP;
 
-	switch (name) {
-	case RES_MAX_USAGE:
-		if (type == _MEM)
+	switch (type) {
+	case _MEM:
+		if (name == RES_MAX_USAGE)
 			res_counter_reset_max(&memcg->res);
-		else if (type == _MEMHUGETLB) {
-			int idx = MEMFILE_IDX(event);
-			res_counter_reset_max(&memcg->hugepage[idx]);
-		} else
-			res_counter_reset_max(&memcg->memsw);
-		break;
-	case RES_FAILCNT:
-		if (type == _MEM)
+		else
 			res_counter_reset_failcnt(&memcg->res);
+		break;
+	case _MEMSWAP:
+		if (name == RES_MAX_USAGE)
+			res_counter_reset_max(&memcg->memsw);
 		else
 			res_counter_reset_failcnt(&memcg->memsw);
 		break;
+	case _MEMHUGETLB:
+		idx = MEMFILE_IDX(event);
+		if (name == RES_MAX_USAGE)
+			res_counter_reset_max(&memcg->hugepage[idx]);
+		else
+			res_counter_reset_failcnt(&memcg->hugepage[idx]);
+		break;
+	default:
+		BUG();
 	}
-
 	return 0;
 }
 
@@ -5299,8 +5304,15 @@ int __init mem_cgroup_hugetlb_file_init(int idx)
 	cft->trigger  = mem_cgroup_reset;
 	cft->read = mem_cgroup_read;
 
-	/* NULL terminate the last cft */
+	/* Add the failcntfile */
 	cft = &h->mem_cgroup_files[3];
+	snprintf(cft->name, MAX_CFTYPE_NAME, "hugetlb.%s.failcnt", buf);
+	cft->private  = __MEMFILE_PRIVATE(idx, _MEMHUGETLB, RES_FAILCNT);
+	cft->trigger  = mem_cgroup_reset;
+	cft->read = mem_cgroup_read;
+
+	/* NULL terminate the last cft */
+	cft = &h->mem_cgroup_files[4];
 	memset(cft, 0, sizeof(*cft));
 
 	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys, h->mem_cgroup_files));
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
