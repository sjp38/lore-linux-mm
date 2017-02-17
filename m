Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 866D84405FA
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:17 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h56so38566308qtc.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:17 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id x7si7655138qkd.52.2017.02.17.07.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:10 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 13/14] mm: migrate: Add copy_page_dma into migrate_page_copy.
Date: Fri, 17 Feb 2017 10:05:50 -0500
Message-Id: <20170217150551.117028-14-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

Fallback to copy_highpage when it fails.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/migrate_mode.h   |  1 +
 include/uapi/linux/mempolicy.h |  1 +
 mm/migrate.c                   | 27 +++++++++++++++++++--------
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 2bd849d89122..798737d0a0bc 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -14,6 +14,7 @@ enum migrate_mode {
 	MIGRATE_ST		= 1<<3,
 	MIGRATE_MT		= 1<<4,
 	MIGRATE_CONCUR		= 1<<5,
+	MIGRATE_DMA			= 1<<6,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 6d9758a32053..bf40534cc93a 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -55,6 +55,7 @@ enum mpol_rebind_step {
 #define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
 #define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
 #define MPOL_MF_MOVE_CONCUR  (1<<7)	/* Migrate a list of pages concurrently */
+#define MPOL_MF_MOVE_DMA (1<<8)	/* Use DMA based page copy routine */
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
diff --git a/mm/migrate.c b/mm/migrate.c
index a35e6fd43a50..464bc9ba8083 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -634,6 +634,9 @@ static void copy_huge_page(struct page *dst, struct page *src,
 	if (mode & MIGRATE_MT)
 		rc = copy_pages_mthread(dst, src, nr_pages);
 
+	if (rc && (mode & MIGRATE_DMA))
+		rc = copy_page_dma(dst, src, nr_pages);
+
 	if (rc)
 		for (i = 0; i < nr_pages; i++) {
 			cond_resched();
@@ -648,16 +651,18 @@ void migrate_page_copy(struct page *newpage, struct page *page,
 					   enum migrate_mode mode)
 {
 	int cpupid;
+	int rc = -EFAULT;
 
 	if (PageHuge(page) || PageTransHuge(page)) {
 		copy_huge_page(newpage, page, mode);
 	} else {
-		if (mode & MIGRATE_MT) {
-			if (copy_pages_mthread(newpage, page, 1))
-				copy_highpage(newpage, page);
-		} else {
+		if (mode & MIGRATE_DMA)
+			rc = copy_page_dma(newpage, page, 1);
+		else if (mode & MIGRATE_MT)
+			rc = copy_pages_mthread(newpage, page, 1);
+
+		if (rc)
 			copy_highpage(newpage, page);
-		}
 	}
 
 	if (PageError(page))
@@ -1926,7 +1931,8 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 				      struct page_to_node *pm,
 				      int migrate_all,
 					  int migrate_use_mt,
-					  int migrate_concur)
+					  int migrate_concur,
+					  int migrate_use_dma)
 {
 	int err;
 	struct page_to_node *pp;
@@ -1936,6 +1942,9 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	if (migrate_use_mt)
 		mode |= MIGRATE_MT;
 
+	if (migrate_use_dma)
+		mode |= MIGRATE_DMA;
+
 	down_read(&mm->mmap_sem);
 
 	/*
@@ -2098,7 +2107,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		err = do_move_page_to_node_array(mm, pm,
 						 flags & MPOL_MF_MOVE_ALL,
 						 flags & MPOL_MF_MOVE_MT,
-						 flags & MPOL_MF_MOVE_CONCUR);
+						 flags & MPOL_MF_MOVE_CONCUR,
+						 flags & MPOL_MF_MOVE_DMA);
 		if (err < 0)
 			goto out_pm;
 
@@ -2207,7 +2217,8 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	/* Check flags */
 	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|
 				  MPOL_MF_MOVE_MT|
-				  MPOL_MF_MOVE_CONCUR))
+				  MPOL_MF_MOVE_CONCUR|
+				  MPOL_MF_MOVE_DMA))
 		return -EINVAL;
 
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
