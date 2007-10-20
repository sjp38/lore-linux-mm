Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id l9KIIRI8015415
	for <linux-mm@kvack.org>; Sat, 20 Oct 2007 11:18:27 -0700
Received: from rv-out-0910.google.com (rvbk20.prod.google.com [10.140.87.20])
	by zps18.corp.google.com with ESMTP id l9KIIQaB013830
	for <linux-mm@kvack.org>; Sat, 20 Oct 2007 11:18:27 -0700
Received: by rv-out-0910.google.com with SMTP id k20so854507rvb
        for <linux-mm@kvack.org>; Sat, 20 Oct 2007 11:18:26 -0700 (PDT)
Message-ID: <b040c32a0710201118g5abb6608me57d7b9057f86919@mail.gmail.com>
Date: Sat, 20 Oct 2007 11:18:26 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] hugetlb: fix i_blocks accounting
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

For administrative purpose, we want to query actual block usage for
hugetlbfs file via fstat.  Currently, hugetlbfs always return 0.  Fix
that up since kernel already has all the information to track it
properly.


Signed-off-by: Ken Chen <kenchen@google.com>


diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 12aca8e..ed6def0 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -862,7 +862,8 @@ out_free:
 int hugetlb_get_quota(struct address_space *mapping)
 {
 	int ret = 0;
-	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(mapping->host->i_sb);
+	struct inode *inode = mapping->host;
+	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(inode->i_sb);

 	if (sbinfo->free_blocks > -1) {
 		spin_lock(&sbinfo->stat_lock);
@@ -873,13 +874,17 @@ int hugetlb_get_quota(struct address_space *mapping)
 		spin_unlock(&sbinfo->stat_lock);
 	}

+	if (!ret)
+		inode->i_blocks += BLOCKS_PER_HUGEPAGE;
 	return ret;
 }

 void hugetlb_put_quota(struct address_space *mapping)
 {
-	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(mapping->host->i_sb);
+	struct inode *inode = mapping->host;
+	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(inode->i_sb);

+	inode->i_blocks -= BLOCKS_PER_HUGEPAGE;
 	if (sbinfo->free_blocks > -1) {
 		spin_lock(&sbinfo->stat_lock);
 		sbinfo->free_blocks++;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index ea0f50b..694cf8b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -168,6 +168,8 @@ struct file *hugetlb_file_setup(const char *name, size_t);
 int hugetlb_get_quota(struct address_space *mapping);
 void hugetlb_put_quota(struct address_space *mapping);

+#define BLOCKS_PER_HUGEPAGE	(HPAGE_SIZE / 512)
+
 static inline int is_file_hugepages(struct file *file)
 {
 	if (file->f_op == &hugetlbfs_file_operations)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
