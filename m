Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4950F6B0082
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 05:17:56 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n899C6Vi003283
	for <linux-mm@kvack.org>; Wed, 9 Sep 2009 03:12:06 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n899HwP9236962
	for <linux-mm@kvack.org>; Wed, 9 Sep 2009 03:17:58 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n899Hwgt027413
	for <linux-mm@kvack.org>; Wed, 9 Sep 2009 03:17:58 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH] hugetlbfs: Do not call user_shm_lock() for MAP_HUGETLB fix
Date: Wed,  9 Sep 2009 10:17:54 +0100
Message-Id: <1252487874-9453-1-git-send-email-ebmunson@us.ibm.com>
References: <20090827152050.GD6323@us.ibm.com>
In-Reply-To: <20090827152050.GD6323@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, mel@cs.ul.ie, Eric B Munson <ebmunson@us.ibm.com>
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
+static int can_do_hugetlb_shm()
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
