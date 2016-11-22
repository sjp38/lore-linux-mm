Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF536B0261
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:26:26 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j49so12544862qta.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:26:26 -0800 (PST)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id r63si16805935qkb.179.2016.11.22.08.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:26:25 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH 4/5] mm: migrate: Add copy_page_mt into migrate_pages.
Date: Tue, 22 Nov 2016 11:25:29 -0500
Message-Id: <20161122162530.2370-5-zi.yan@sent.com>
In-Reply-To: <20161122162530.2370-1-zi.yan@sent.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

From: Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <ziy@nvidia.com>

An option is added to move_pages() syscall to use multi-threaded
page migration.

Signed-off-by: Zi Yan <ziy@nvidia.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/migrate_mode.h   |  1 +
 include/uapi/linux/mempolicy.h |  2 ++
 mm/migrate.c                   | 27 +++++++++++++++++++--------
 3 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 0e2deb8..c711e2a 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -11,6 +11,7 @@ enum migrate_mode {
 	MIGRATE_ASYNC		= 1<<0,
 	MIGRATE_SYNC_LIGHT	= 1<<1,
 	MIGRATE_SYNC		= 1<<2,
+	MIGRATE_MT			= 1<<3,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 9cd8b21..5d42dc6 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -54,6 +54,8 @@ enum mpol_rebind_step {
 #define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
 #define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
 
+#define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
+
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
 			 MPOL_MF_MOVE_ALL)
diff --git a/mm/migrate.c b/mm/migrate.c
index 4a4cf48..244ece6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -634,6 +634,7 @@ static void copy_huge_page(struct page *dst, struct page *src,
 {
 	int i;
 	int nr_pages;
+	int rc = -EFAULT;
 
 	if (PageHuge(src)) {
 		/* hugetlbfs page */
@@ -650,10 +651,14 @@ static void copy_huge_page(struct page *dst, struct page *src,
 		nr_pages = hpage_nr_pages(src);
 	}
 
-	for (i = 0; i < nr_pages; i++) {
-		cond_resched();
-		copy_highpage(dst + i, src + i);
-	}
+	if (mode & MIGRATE_MT)
+		rc = copy_page_mt(dst, src, nr_pages);
+
+	if (rc)
+		for (i = 0; i < nr_pages; i++) {
+			cond_resched();
+			copy_highpage(dst + i, src + i);
+		}
 }
 
 /*
@@ -1461,11 +1466,16 @@ static struct page *new_page_node(struct page *p, unsigned long private,
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
 
@@ -1542,7 +1552,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node, NULL,
-				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
+				(unsigned long)pm, mode, MR_SYSCALL);
 		if (err)
 			putback_movable_pages(&pagelist);
 	}
@@ -1619,7 +1629,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 
 		/* Migrate this chunk */
 		err = do_move_page_to_node_array(mm, pm,
-						 flags & MPOL_MF_MOVE_ALL);
+						 flags & MPOL_MF_MOVE_ALL,
+						 flags & MPOL_MF_MOVE_MT);
 		if (err < 0)
 			goto out_pm;
 
@@ -1726,7 +1737,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	nodemask_t task_nodes;
 
 	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
