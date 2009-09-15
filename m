Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8430A6B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:49:24 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8FAedwx006881
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:40:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8FAnRC4214458
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:49:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8FAnRY7021185
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:49:27 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH] hugetlbfs: Do not call user_shm_lock() for MAP_HUGETLB fix V2
Date: Tue, 15 Sep 2009 11:49:14 +0100
Message-Id: <1253011754-6672-1-git-send-email-ebmunson@us.ibm.com>
In-Reply-To: <1252487874-9453-1-git-send-email-ebmunson@us.ibm.com>
References: <1252487874-9453-1-git-send-email-ebmunson@us.ibm.com>
References: <20090827152050.GD6323@us.ibm.com>
References: <202cde0e0909132240obd69be6qc86250b09b9aa62e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, akorolex@gmail.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

hugetlbfs: Do not call user_shm_lock() for MAP_HUGETLB fix

The patch
hugetlbfs-allow-the-creation-of-files-suitable-for-map_private-on-the-vfs-internal-mount.patch
alters can_do_hugetlb_shm() to check if a file is being created for shared
memory or mmap(). If this returns false, we then unconditionally call
user_shm_lock() triggering a warning. This block should never be entered
for MAP_HUGETLB. This patch partially reverts the problem and fixes the check.

This patch should be considered a fix to
hugetlbfs-allow-the-creation-of-files-suitable-for-map_private-on-the-vfs-internal-mount.patch.

From: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 fs/hugetlbfs/inode.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5584d55..0d03c41 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -937,15 +937,9 @@ static struct file_system_type hugetlbfs_fs_type = {
 
 static struct vfsmount *hugetlbfs_vfsmount;
 
-static int can_do_hugetlb_shm(int creat_flags)
+static int can_do_hugetlb_shm(void)
 {
-	if (creat_flags != HUGETLB_SHMFS_INODE)
-		return 0;
-	if (capable(CAP_IPC_LOCK))
-		return 1;
-	if (in_group_p(sysctl_hugetlb_shm_group))
-		return 1;
-	return 0;
+	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
 }
 
 struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
@@ -961,7 +955,7 @@ struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
 
-	if (!can_do_hugetlb_shm(creat_flags)) {
+	if (creat_flags == HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
 		*user = current_user();
 		if (user_shm_lock(size, *user)) {
 			WARN_ONCE(1,
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
