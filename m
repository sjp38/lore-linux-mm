Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0779B6B0070
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:53:55 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so72136949pdb.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 16:53:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id og4si18695953pdb.24.2015.03.16.16.53.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 16:53:54 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V2 3/4] hugetlbfs: accept subpool min_size mount option and setup accordingly
Date: Mon, 16 Mar 2015 16:53:28 -0700
Message-Id: <cfcd697cffc0f3500ecdb3371350a2613ee22f2e.1426549011.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426549010.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426549010.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

Make 'min_size=' be an option when mounting a hugetlbfs.  This option
takes the same value as the 'size' option.  min_size can be specified
with specifying size.  If both are specified, min_size must be less
that or equal to size else the mount will fail.  If min_size is
specified, then at mount time an attempt is made to reserve min_size
pages.  If the reservation fails, the mount fails.  At umount time,
the reserved pages are released.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 75 ++++++++++++++++++++++++++++++++++++++-----------
 include/linux/hugetlb.h |  3 +-
 mm/hugetlb.c            | 26 +++++++++++++----
 3 files changed, 80 insertions(+), 24 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5eba47f..7a20a1b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -50,6 +50,7 @@ struct hugetlbfs_config {
 	long	nr_blocks;
 	long	nr_inodes;
 	struct hstate *hstate;
+	long    min_size;
 };
 
 struct hugetlbfs_inode_info {
@@ -73,7 +74,7 @@ int sysctl_hugetlb_shm_group;
 enum {
 	Opt_size, Opt_nr_inodes,
 	Opt_mode, Opt_uid, Opt_gid,
-	Opt_pagesize,
+	Opt_pagesize, Opt_min_size,
 	Opt_err,
 };
 
@@ -84,6 +85,7 @@ static const match_table_t tokens = {
 	{Opt_uid,	"uid=%u"},
 	{Opt_gid,	"gid=%u"},
 	{Opt_pagesize,	"pagesize=%s"},
+	{Opt_min_size,	"min_size=%s"},
 	{Opt_err,	NULL},
 };
 
@@ -761,14 +763,32 @@ static const struct super_operations hugetlbfs_ops = {
 	.show_options	= generic_show_options,
 };
 
+enum { NO_SIZE, SIZE_STD, SIZE_PERCENT };
+
+static bool
+hugetlbfs_options_setsize(struct hstate *h, long long *size, int setsize)
+{
+	if (setsize == NO_SIZE)
+		return false;
+
+	if (setsize == SIZE_PERCENT) {
+		*size <<= huge_page_shift(h);
+		*size *= h->max_huge_pages;
+		do_div(*size, 100);
+	}
+
+	*size >>= huge_page_shift(h);
+	return true;
+}
+
 static int
 hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 {
 	char *p, *rest;
 	substring_t args[MAX_OPT_ARGS];
 	int option;
-	unsigned long long size = 0;
-	enum { NO_SIZE, SIZE_STD, SIZE_PERCENT } setsize = NO_SIZE;
+	unsigned long long max_size = 0, min_size = 0;
+	int max_setsize = NO_SIZE, min_setsize = NO_SIZE;
 
 	if (!options)
 		return 0;
@@ -806,10 +826,10 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 			/* memparse() will accept a K/M/G without a digit */
 			if (!isdigit(*args[0].from))
 				goto bad_val;
-			size = memparse(args[0].from, &rest);
-			setsize = SIZE_STD;
+			max_size = memparse(args[0].from, &rest);
+			max_setsize = SIZE_STD;
 			if (*rest == '%')
-				setsize = SIZE_PERCENT;
+				max_setsize = SIZE_PERCENT;
 			break;
 		}
 
@@ -832,6 +852,17 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 			break;
 		}
 
+		case Opt_min_size: {
+			/* memparse() will accept a K/M/G without a digit */
+			if (!isdigit(*args[0].from))
+				goto bad_val;
+			min_size = memparse(args[0].from, &rest);
+			min_setsize = SIZE_STD;
+			if (*rest == '%')
+				min_setsize = SIZE_PERCENT;
+			break;
+		}
+
 		default:
 			pr_err("Bad mount option: \"%s\"\n", p);
 			return -EINVAL;
@@ -839,15 +870,17 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 		}
 	}
 
-	/* Do size after hstate is set up */
-	if (setsize > NO_SIZE) {
-		struct hstate *h = pconfig->hstate;
-		if (setsize == SIZE_PERCENT) {
-			size <<= huge_page_shift(h);
-			size *= h->max_huge_pages;
-			do_div(size, 100);
-		}
-		pconfig->nr_blocks = (size >> huge_page_shift(h));
+	/* Calculate number of huge pages based on hstate */
+	if (hugetlbfs_options_setsize(pconfig->hstate, &max_size, max_setsize))
+		pconfig->nr_blocks = max_size;
+	if (hugetlbfs_options_setsize(pconfig->hstate, &min_size, min_setsize))
+		pconfig->min_size = min_size;
+
+	/* If max_size specified, then min_size must be smaller */
+	if (max_setsize > NO_SIZE && min_setsize > NO_SIZE &&
+	    pconfig->min_size > pconfig->nr_blocks) {
+		pr_err("minimum size can not be greater than maximum size\n");
+		return -EINVAL;
 	}
 
 	return 0;
@@ -872,6 +905,7 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
 	config.gid = current_fsgid();
 	config.mode = 0755;
 	config.hstate = &default_hstate;
+	config.min_size = 0; /* No default minimum size */
 	ret = hugetlbfs_parse_options(data, &config);
 	if (ret)
 		return ret;
@@ -885,8 +919,15 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
 	sbinfo->max_inodes = config.nr_inodes;
 	sbinfo->free_inodes = config.nr_inodes;
 	sbinfo->spool = NULL;
-	if (config.nr_blocks != -1) {
-		sbinfo->spool = hugepage_new_subpool(config.nr_blocks);
+	/*
+	 * Allocate and initialize subpool if maximum or minimum size is
+	 * specified.  Any needed reservations (for minimim size) are taken
+	 * taken when the subpool is created.
+	 */
+	if (config.nr_blocks != -1 || config.min_size != 0) {
+		sbinfo->spool = hugepage_new_subpool(config.hstate,
+							config.nr_blocks,
+							config.min_size);
 		if (!sbinfo->spool)
 			goto out_free;
 	}
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index cfe13fd..6883fca 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -40,7 +40,8 @@ extern int hugetlb_max_hstate __read_mostly;
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
 
-struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
+struct hugepage_subpool *hugepage_new_subpool(struct hstate *h, long nr_blocks,
+						long min_size);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
 int PageHuge(struct page *page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ab2ea1e..7d4be33 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -61,6 +61,9 @@ DEFINE_SPINLOCK(hugetlb_lock);
 static int num_fault_mutexes;
 static struct mutex *htlb_fault_mutex_table ____cacheline_aligned_in_smp;
 
+/* Forward declaration */
+static int hugetlb_acct_memory(struct hstate *h, long delta);
+
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
 	bool free = (spool->count == 0) && (spool->used_hpages == 0);
@@ -68,12 +71,18 @@ static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 	spin_unlock(&spool->lock);
 
 	/* If no pages are used, and no other handles to the subpool
-	 * remain, free the subpool the subpool remain */
-	if (free)
+	 * remain, give up any reservations mased on minimum size and
+	 * free the subpool */
+	if (free) {
+		if (spool->min_hpages)
+			hugetlb_acct_memory(spool->hstate,
+						-spool->min_hpages);
 		kfree(spool);
+	}
 }
 
-struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
+struct hugepage_subpool *hugepage_new_subpool(struct hstate *h, long nr_blocks,
+						long min_size)
 {
 	struct hugepage_subpool *spool;
 
@@ -85,9 +94,14 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
 	spool->count = 1;
 	spool->max_hpages = nr_blocks;
 	spool->used_hpages = 0;
-	spool->hstate = NULL;
-	spool->min_hpages = 0;
-	spool->rsv_hpages = 0;
+	spool->hstate = h;
+	spool->min_hpages = min_size;
+
+	if (min_size && hugetlb_acct_memory(h, min_size)) {
+		kfree(spool);
+		return NULL;
+	}
+	spool->rsv_hpages = min_size;
 
 	return spool;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
