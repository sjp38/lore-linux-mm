Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A51BC6B0072
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:22:19 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so1942055pdb.2
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 17:22:19 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q15si2801845pdl.247.2015.03.03.17.22.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 17:22:18 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/4] hugetlbfs: accept subpool reserved option and setup accordingly
Date: Tue,  3 Mar 2015 17:21:45 -0800
Message-Id: <1425432106-17214-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

Make reserved be an option when mounting a hugetlbfs.  reserved
option is only possible if size option is also specified, otherwise
the mount will fail.  On mount, reserve size hugepages from the
global pool and note in subpool.  Unreserve hugepages when fs
is unmounted.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 15 +++++++++++++--
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 15 ++++++++++++++-
 3 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5eba47f..10443c3 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -50,6 +50,7 @@ struct hugetlbfs_config {
 	long	nr_blocks;
 	long	nr_inodes;
 	struct hstate *hstate;
+	bool	reserved;
 };
 
 struct hugetlbfs_inode_info {
@@ -73,7 +74,7 @@ int sysctl_hugetlb_shm_group;
 enum {
 	Opt_size, Opt_nr_inodes,
 	Opt_mode, Opt_uid, Opt_gid,
-	Opt_pagesize,
+	Opt_pagesize, Opt_reserved,
 	Opt_err,
 };
 
@@ -84,6 +85,7 @@ static const match_table_t tokens = {
 	{Opt_uid,	"uid=%u"},
 	{Opt_gid,	"gid=%u"},
 	{Opt_pagesize,	"pagesize=%s"},
+	{Opt_reserved,	"reserved"},
 	{Opt_err,	NULL},
 };
 
@@ -832,6 +834,10 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 			break;
 		}
 
+		case Opt_reserved:
+			pconfig->reserved = true;
+			break;
+
 		default:
 			pr_err("Bad mount option: \"%s\"\n", p);
 			return -EINVAL;
@@ -872,6 +878,7 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
 	config.gid = current_fsgid();
 	config.mode = 0755;
 	config.hstate = &default_hstate;
+	config.reserved = false;
 	ret = hugetlbfs_parse_options(data, &config);
 	if (ret)
 		return ret;
@@ -889,7 +896,11 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
 		sbinfo->spool = hugepage_new_subpool(config.nr_blocks);
 		if (!sbinfo->spool)
 			goto out_free;
-	}
+		sbinfo->spool->hstate = config.hstate;
+		if (config.reserved && !hugepage_reserve_subpool(sbinfo->spool))
+			goto out_free;
+	} else if (config.reserved)
+		goto out_free;	/* error if reserved and no size specified */
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
 	sb->s_blocksize = huge_page_size(config.hstate);
 	sb->s_blocksize_bits = huge_page_shift(config.hstate);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 12fbd5d..74cffa4 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -45,6 +45,7 @@ static inline bool hugepage_subpool_reserved(struct hugepage_subpool *spool)
 	return spool && spool->reserved;
 }
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
+bool hugepage_reserve_subpool(struct hugepage_subpool *spool);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
 int PageHuge(struct page *page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 394bd8f..941c726 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -61,6 +61,8 @@ DEFINE_SPINLOCK(hugetlb_lock);
 static int num_fault_mutexes;
 static struct mutex *htlb_fault_mutex_table ____cacheline_aligned_in_smp;
 
+/* Forward declaration */
+static int hugetlb_acct_memory(struct hstate *h, long delta);
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
 	bool free = (spool->count == 0) && (spool->used_hpages == 0);
@@ -69,8 +71,11 @@ static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 
 	/* If no pages are used, and no other handles to the subpool
 	 * remain, free the subpool the subpool remain */
-	if (free)
+	if (free) {
+		if (spool->reserved)
+			hugetlb_acct_memory(spool->hstate, -spool->max_hpages);
 		kfree(spool);
+	}
 }
 
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
@@ -91,6 +96,14 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
 	return spool;
 }
 
+bool hugepage_reserve_subpool(struct hugepage_subpool *spool)
+{
+	if (hugetlb_acct_memory(spool->hstate, spool->max_hpages))
+		return false;
+	spool->reserved = true;
+	return true;
+}
+
 void hugepage_put_subpool(struct hugepage_subpool *spool)
 {
 	spin_lock(&spool->lock);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
