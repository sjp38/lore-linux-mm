Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 47AD26B00EB
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:40 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:19:03 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBGkm03416114
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:16:46 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBM2od019664
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:03 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 2/9] hugetlbfs: Add usage and max usage files to hugetlb cgroup
Date: Mon, 20 Feb 2012 16:51:35 +0530
Message-Id: <1329736902-26870-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/hugetlb_cgroup.c  |   12 ++++++++++++
 include/linux/hugetlb.h        |    2 ++
 include/linux/hugetlb_cgroup.h |    1 +
 mm/hugetlb.c                   |   21 +++++++++++++++++++++
 4 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgroup.c
index b5b3cb8..75dbdd8 100644
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
