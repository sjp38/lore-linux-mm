Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55DD86B0343
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 17:37:58 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id s138so33328857ywg.12
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 14:37:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y129si2106742ywe.458.2017.03.25.14.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Mar 2017 14:37:57 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2] hugetlbfs: initialize shared policy as part of inode allocation
Date: Sat, 25 Mar 2017 14:37:30 -0700
Message-Id: <1490477850-7944-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Any time after inode allocation, destroy_inode can be called.  The
hugetlbfs inode contains a shared_policy structure, and
mpol_free_shared_policy is unconditionally called as part of
hugetlbfs_destroy_inode.  Initialize the policy as part of inode
allocation so that any quick (error path) calls to destroy_inode
will be handed an initialized policy.

syzkaller fuzzer found this bug, that resulted in the following:

BUG: KASAN: user-memory-access in atomic_inc
include/asm-generic/atomic-instrumented.h:87 [inline] at addr
000000131730bd7a
BUG: KASAN: user-memory-access in __lock_acquire+0x21a/0x3a80
kernel/locking/lockdep.c:3239 at addr 000000131730bd7a
Write of size 4 by task syz-executor6/14086
CPU: 3 PID: 14086 Comm: syz-executor6 Not tainted 4.11.0-rc3+ #364
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1b8/0x28d lib/dump_stack.c:52
 kasan_report_error mm/kasan/report.c:291 [inline]
 kasan_report.part.2+0x34a/0x480 mm/kasan/report.c:316
 kasan_report+0x21/0x30 mm/kasan/report.c:303
 check_memory_region_inline mm/kasan/kasan.c:326 [inline]
 check_memory_region+0x137/0x190 mm/kasan/kasan.c:333
 kasan_check_write+0x14/0x20 mm/kasan/kasan.c:344
 atomic_inc include/asm-generic/atomic-instrumented.h:87 [inline]
 __lock_acquire+0x21a/0x3a80 kernel/locking/lockdep.c:3239
 lock_acquire+0x1ee/0x590 kernel/locking/lockdep.c:3762
 __raw_write_lock include/linux/rwlock_api_smp.h:210 [inline]
 _raw_write_lock+0x33/0x50 kernel/locking/spinlock.c:295
 mpol_free_shared_policy+0x43/0xb0 mm/mempolicy.c:2536
 hugetlbfs_destroy_inode+0xca/0x120 fs/hugetlbfs/inode.c:952
 alloc_inode+0x10d/0x180 fs/inode.c:216
 new_inode_pseudo+0x69/0x190 fs/inode.c:889
 new_inode+0x1c/0x40 fs/inode.c:918
 hugetlbfs_get_inode+0x40/0x420 fs/hugetlbfs/inode.c:734
 hugetlb_file_setup+0x329/0x9f0 fs/hugetlbfs/inode.c:1282
 newseg+0x422/0xd30 ipc/shm.c:575
 ipcget_new ipc/util.c:285 [inline]
 ipcget+0x21e/0x580 ipc/util.c:639
 SYSC_shmget ipc/shm.c:673 [inline]
 SyS_shmget+0x158/0x230 ipc/shm.c:657
 entry_SYSCALL_64_fastpath+0x1f/0xc2

Analysis provided by Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
v2: Remove now redundant initialization in hugetlbfs_get_root

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 54de77e..cf3669d 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -695,14 +695,11 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 
 	inode = new_inode(sb);
 	if (inode) {
-		struct hugetlbfs_inode_info *info;
 		inode->i_ino = get_next_ino();
 		inode->i_mode = S_IFDIR | config->mode;
 		inode->i_uid = config->uid;
 		inode->i_gid = config->gid;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
-		info = HUGETLBFS_I(inode);
-		mpol_shared_policy_init(&info->policy, NULL);
 		inode->i_op = &hugetlbfs_dir_inode_operations;
 		inode->i_fop = &simple_dir_operations;
 		/* directory inodes start off with i_nlink == 2 (for "." entry) */
@@ -733,7 +730,6 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 
 	inode = new_inode(sb);
 	if (inode) {
-		struct hugetlbfs_inode_info *info;
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, dir, mode);
 		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
@@ -741,15 +737,6 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
 		inode->i_mapping->private_data = resv_map;
-		info = HUGETLBFS_I(inode);
-		/*
-		 * The policy is initialized here even if we are creating a
-		 * private inode because initialization simply creates an
-		 * an empty rb tree and calls rwlock_init(), later when we
-		 * call mpol_free_shared_policy() it will just return because
-		 * the rb tree will still be empty.
-		 */
-		mpol_shared_policy_init(&info->policy, NULL);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -937,6 +924,18 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 		hugetlbfs_inc_free_inodes(sbinfo);
 		return NULL;
 	}
+
+	/*
+	 * Any time after allocation, hugetlbfs_destroy_inode can be called
+	 * for the inode.  mpol_free_shared_policy is unconditionally called
+	 * as part of hugetlbfs_destroy_inode.  So, initialize policy here
+	 * in case of a quick call to destroy.
+	 *
+	 * Note that the policy is initialized even if we are creating a
+	 * private inode.  This simplifies hugetlbfs_destroy_inode.
+	 */
+	mpol_shared_policy_init(&p->policy, NULL);
+
 	return &p->vfs_inode;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
