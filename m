Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 579776B0071
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 18:00:19 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id v63so18214519oia.13
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 15:00:19 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id eq2si2823237obb.47.2015.02.27.15.00.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 15:00:18 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 3/3] hugetlbfs: accept subpool reserved option and setup accordingly
Date: Fri, 27 Feb 2015 14:58:13 -0800
Message-Id: <1425077893-18366-6-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

Make reserved be an option when mounting a hugetlbfs.  reserved
option is only possible if size option is also specified.  On mount,
reserve size hugepages and note in subpool.  Unreserve pages when
fs is unmounted.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 15 +++++++++++++--
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 15 ++++++++++++++-
 3 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5eba47f..99d0cec 100644
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
+		if (config.reserved && !reserve_hugepage_subpool(sbinfo->spool))
+			goto out_free;
+	} else if (config.reserved)
+		goto out_free;
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
 	sb->s_blocksize = huge_page_size(config.hstate);
 	sb->s_blocksize_bits = huge_page_shift(config.hstate);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 605c648..117e1bd 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -45,6 +45,7 @@ static inline bool subpool_reserved(struct hugepage_subpool *spool)
 	return spool && spool->reserved;
 }
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
+bool reserve_hugepage_subpool(struct hugepage_subpool *spool);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
 int PageHuge(struct page *page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4ef8379..3ae3596 100644
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
 
+bool reserve_hugepage_subpool(struct hugepage_subpool *spool)
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
