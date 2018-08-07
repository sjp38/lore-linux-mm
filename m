Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11C386B027F
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:39:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v65-v6so16806855qka.23
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:39:16 -0700 (PDT)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80137.outbound.protection.outlook.com. [40.107.8.137])
        by mx.google.com with ESMTPS id a125-v6si1575984qkb.47.2018.08.07.08.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:39:15 -0700 (PDT)
Subject: [PATCH RFC 08/10] xfs: Introduce xfs_fs_destroy_super()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:39:05 +0300
Message-ID: <153365634503.19074.14972123229522734895.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

xfs_fs_nr_cached_objects() touches sb->s_fs_info,
and this patch makes it to be destructed later.

After this patch xfs_fs_nr_cached_objects() is safe
for splitting unregister_shrinker(): mp->m_perag_tree
is stable till destroy_super_work(), while iteration
over it is already RCU-protected by internal XFS
business.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/xfs/xfs_super.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 9e2ce4cd98e1..c1e00dd06893 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1774,11 +1774,20 @@ xfs_fs_put_super(
 	xfs_destroy_mount_workqueues(mp);
 	xfs_close_devices(mp);
 
-	sb->s_fs_info = NULL;
 	xfs_free_fsname(mp);
-	kfree(mp);
 }
 
+STATIC void
+xfs_fs_destroy_super(
+	struct super_block	*sb)
+{
+	if (sb->s_fs_info) {
+		kfree(sb->s_fs_info);
+		sb->s_fs_info = NULL;
+	}
+}
+
+
 STATIC struct dentry *
 xfs_fs_mount(
 	struct file_system_type	*fs_type,
@@ -1816,6 +1825,7 @@ static const struct super_operations xfs_super_operations = {
 	.dirty_inode		= xfs_fs_dirty_inode,
 	.drop_inode		= xfs_fs_drop_inode,
 	.put_super		= xfs_fs_put_super,
+	.destroy_super		= xfs_fs_destroy_super,
 	.sync_fs		= xfs_fs_sync_fs,
 	.freeze_fs		= xfs_fs_freeze,
 	.unfreeze_fs		= xfs_fs_unfreeze,
