Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAE0681034
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:25 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gh4so7861840wjb.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:26:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v53si12993083wrb.38.2017.02.17.03.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 03:26:24 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1HBNuXt032096
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:23 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28nwc7eyad-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:22 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 17 Feb 2017 21:26:19 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 79D0B2CE8057
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:18 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1HBQAOY12845070
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:26:18 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1HBPjXS025612
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:46 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 5/6] mm/migrate: Add new migration flag MPOL_MF_MOVE_MT for syscalls
Date: Fri, 17 Feb 2017 16:54:52 +0530
In-Reply-To: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170217112453.307-6-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

This change adds a new mode flag MPOL_MF_MOVE_MT for migration system
calls like move_pages() and mbind() which indicates request for using
the multi threaded copy method.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/uapi/linux/mempolicy.h |  4 +++-
 mm/mempolicy.c                 |  7 ++++++-
 mm/migrate.c                   | 14 ++++++++++----
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 9cd8b21..8f1db2e 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -53,10 +53,12 @@ enum mpol_rebind_step {
 #define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
 #define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
 #define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
+#define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
-			 MPOL_MF_MOVE_ALL)
+			 MPOL_MF_MOVE_ALL |	\
+			 MPOL_MF_MOVE_MT)
 
 /*
  * Internal flags that share the struct mempolicy flags word with
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1e7873e..ef7c586 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1244,9 +1244,14 @@ static long do_mbind(unsigned long start, unsigned long len,
 		int nr_failed = 0;
 
 		if (!list_empty(&pagelist)) {
+			enum migrate_mode mode = MIGRATE_SYNC;
+
+			if (flags & MPOL_MF_MOVE_MT)
+				mode |= MIGRATE_MT;
+
 			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
 			nr_failed = migrate_pages(&pagelist, new_page, NULL,
-				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
+					start, mode, MR_MEMPOLICY_MBIND);
 			if (nr_failed)
 				putback_movable_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 6ac3572..660c4b2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1429,11 +1429,16 @@ static struct page *new_page_node(struct page *p, unsigned long private,
  */
 static int do_move_page_to_node_array(struct mm_struct *mm,
 				      struct page_to_node *pm,
-				      int migrate_all)
+				      int migrate_all,
+					  int migrate_use_mt)
 {
 	int err;
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
+	enum migrate_mode mode = MIGRATE_SYNC;
+
+	if (migrate_use_mt)
+		mode |= MIGRATE_MT;
 
 	down_read(&mm->mmap_sem);
 
@@ -1501,7 +1506,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node, NULL,
-				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
+				(unsigned long)pm, mode, MR_SYSCALL);
 		if (err)
 			putback_movable_pages(&pagelist);
 	}
@@ -1578,7 +1583,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 
 		/* Migrate this chunk */
 		err = do_move_page_to_node_array(mm, pm,
-						 flags & MPOL_MF_MOVE_ALL);
+						 flags & MPOL_MF_MOVE_ALL,
+						 flags & MPOL_MF_MOVE_MT);
 		if (err < 0)
 			goto out_pm;
 
@@ -1685,7 +1691,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
