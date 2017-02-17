Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4304405F7
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:09 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id c25so38731162qtg.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:09 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id o1si5408387qkc.228.2017.02.17.07.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:08 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 05/14] mm/migrate: Add new migration flag MPOL_MF_MOVE_MT for syscalls
Date: Fri, 17 Feb 2017 10:05:42 -0500
Message-Id: <20170217150551.117028-6-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

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
index 9cd8b21dddbe..8f1db2e2d677 100644
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
index 435bb7bec0a5..fc714840538e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1300,9 +1300,14 @@ static long do_mbind(unsigned long start, unsigned long len,
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
index 21307219428d..2e58aad7c96f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1446,11 +1446,16 @@ static struct page *new_page_node(struct page *p, unsigned long private,
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
 
@@ -1527,7 +1532,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node, NULL,
-				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
+				(unsigned long)pm, mode, MR_SYSCALL);
 		if (err)
 			putback_movable_pages(&pagelist);
 	}
@@ -1604,7 +1609,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 
 		/* Migrate this chunk */
 		err = do_move_page_to_node_array(mm, pm,
-						 flags & MPOL_MF_MOVE_ALL);
+						 flags & MPOL_MF_MOVE_ALL,
+						 flags & MPOL_MF_MOVE_MT);
 		if (err < 0)
 			goto out_pm;
 
@@ -1711,7 +1717,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
