Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 868FC6B13F2
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 16:37:15 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 11 Feb 2012 03:07:12 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1ALb8gt4395102
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 03:07:08 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1ALb8a0001554
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 08:37:08 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/6] hugetlbfs: Add usage and max usage files to hugetlb cgroup
Date: Sat, 11 Feb 2012 03:06:42 +0530
Message-Id: <1328909806-15236-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aneesh.kumar@linux.vnet.ibm.com

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/hugetlb_cgroup.c  |   12 ++++++++++++
 include/linux/hugetlb.h        |    2 ++
 include/linux/hugetlb_cgroup.h |    1 +
 mm/hugetlb.c                   |   21 +++++++++++++++++++++
 4 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index f6521ee..f2368ed 100644
--- a/fs/hugetlbfs/hugetlb_cgroup.c
+++ b/fs/hugetlbfs/hugetlb_cgroup.c
@@ -99,6 +99,18 @@ int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
 	return ret;
 }
 
+int hugetlb_cgroup_reset(struct cgroup *cgroup, unsigned int event)
+{
+	int name, idx;
+	struct hugetlb_cgroup *h_cgroup = cgroup_to_hugetlbcgroup(cgroup);
+
+	idx = MEMFILE_TYPE(event);
+	name = MEMFILE_ATTR(event);
+
+	res_counter_reset_max(&h_cgroup->memhuge[idx]);
+	return 0;
+}
+
 static int hugetlbcgroup_can_attach(struct cgroup_subsys *ss,
 				    struct cgroup *new_cgrp,
 				    struct cgroup_taskset *set)
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2b6b231..4392b6a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -228,6 +228,8 @@ struct hstate {
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 	/* cgroup control files */
 	struct cftype cgroup_limit_file;
+	struct cftype cgroup_usage_file;
+	struct cftype cgroup_max_usage_file;
 	char name[HSTATE_NAME_LEN];
 };
 
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 2330dd0..11cd6c4 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -18,4 +18,5 @@
 extern u64 hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft);
 extern int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
 				const char *buffer);
+extern int hugetlb_cgroup_reset(struct cgroup *cgroup, unsigned int event);
 #endif
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f643f72..865b41f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1814,6 +1814,13 @@ int register_hugetlb_cgroup_files(struct cgroup_subsys *ss,
 		ret = cgroup_add_file(cgroup, ss, &h->cgroup_limit_file);
 		if (ret)
 			return ret;
+		ret = cgroup_add_file(cgroup, ss, &h->cgroup_usage_file);
+		if (ret)
+			return ret;
+		ret = cgroup_add_file(cgroup, ss, &h->cgroup_max_usage_file);
+		if (ret)
+			return ret;
+
 	}
 	return ret;
 }
@@ -1845,6 +1852,20 @@ static int hugetlb_cgroup_file_init(struct hstate *h, int idx)
 	cft->read_u64 = hugetlb_cgroup_read;
 	cft->write_string = hugetlb_cgroup_write;
 
+	/* Add the usage file */
+	cft = &h->cgroup_usage_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.usage_in_bytes", buf);
+	cft->private  = MEMFILE_PRIVATE(idx, RES_USAGE);
+	cft->read_u64 = hugetlb_cgroup_read;
+
+	/* Add the MAX usage file */
+	cft = &h->cgroup_max_usage_file;
+	snprintf(cft->name, MAX_CFTYPE_NAME,
+		 "%s.max_usage_in_bytes", buf);
+	cft->private  = MEMFILE_PRIVATE(idx, RES_MAX_USAGE);
+	cft->trigger  = hugetlb_cgroup_reset;
+	cft->read_u64 = hugetlb_cgroup_read;
+
 	return 0;
 }
 #else
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
