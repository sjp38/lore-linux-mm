Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 27EF56B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 12:08:28 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so280769qwc.44
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 09:08:28 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [RESEND] [PATCH] hugetlbfs: Do not call user_shm_lock() for MAP_HUGETLB fix
Date: Wed, 23 Sep 2009 10:08:22 -0600
Message-Id: <1253722102-22858-1-git-send-email-ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

It seems I may have been having relay problems, I am resending this using
my personal account to make sure everyone that needs a copy gets one.

Andrew,

This patch seems to have slipped through the cracks during the discussion
on the MAP_HUGETLB flag, I am sorry for letting it slip.  Please fold this
into the indicated patch in -mm.

--- Cut here ---

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
index e1a4ac4..0bf9d02 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -931,15 +931,9 @@ static struct file_system_type hugetlbfs_fs_type = {
 
 static struct vfsmount *hugetlbfs_vfsmount;
 
-static int can_do_hugetlb_shm(int creat_flags)
+static int can_do_hugetlb_shm(void)
 {
-	if (creat_flags != HUGETLBFS_SHMFS_INODE)
-		return 0;
-	if (capable(CAP_IPC_LOCK))
-		return 1;
-	if (in_group_p(sysctl_hugetlb_shm_group))
-		return 1;
-	return 0;
+	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
 }
 
 struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
@@ -955,7 +949,7 @@ struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
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
