Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 20ACB6B0037
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 02:30:40 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id fn20so13393189lab.28
        for <linux-mm@kvack.org>; Tue, 25 Jun 2013 23:30:38 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH 2/2] super: fix for destroy lrus
Date: Wed, 26 Jun 2013 02:29:41 -0400
Message-Id: <1372228181-18827-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1372228181-18827-1-git-send-email-glommer@openvz.org>
References: <1372228181-18827-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, dchinner@redhat.com, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@openvz.org>

This patch adds the missing call to list_lru_destroy (spotted by Li Zhong)
and moves the deletion to after the shrinker is unregistered, as correctly
spotted by Dave

Signed-off-by: Glauber Costa <glommer@openvz.org>
---
 fs/super.c       | 3 +++
 fs/xfs/xfs_buf.c | 2 +-
 fs/xfs/xfs_qm.c  | 2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index b79e732..09da975 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -328,6 +328,9 @@ void deactivate_locked_super(struct super_block *s)
 
 		/* caches are now gone, we can safely kill the shrinker now */
 		unregister_shrinker(&s->s_shrink);
+		list_lru_destroy(&s->s_dentry_lru);
+		list_lru_destroy(&s->s_inode_lru);
+
 		put_filesystem(fs);
 		put_super(s);
 	} else {
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 6c77431..8b2c5aa 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1591,8 +1591,8 @@ xfs_free_buftarg(
 	struct xfs_mount	*mp,
 	struct xfs_buftarg	*btp)
 {
-	list_lru_destroy(&btp->bt_lru);
 	unregister_shrinker(&btp->bt_shrinker);
+	list_lru_destroy(&btp->bt_lru);
 
 	if (mp->m_flags & XFS_MOUNT_BARRIER)
 		xfs_blkdev_issue_flush(btp);
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index c88cb68..1e3d4ed 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -889,8 +889,8 @@ xfs_qm_destroy_quotainfo(
 	qi = mp->m_quotainfo;
 	ASSERT(qi != NULL);
 
-	list_lru_destroy(&qi->qi_lru);
 	unregister_shrinker(&qi->qi_shrinker);
+	list_lru_destroy(&qi->qi_lru);
 
 	if (qi->qi_uquotaip) {
 		IRELE(qi->qi_uquotaip);
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
