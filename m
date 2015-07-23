Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id BDBC39003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 12:30:25 -0400 (EDT)
Received: by qged69 with SMTP id d69so90786798qge.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 09:30:25 -0700 (PDT)
Received: from emvm-gh1-uea09.nsa.gov (emvm-gh1-uea09.nsa.gov. [63.239.67.10])
        by mx.google.com with ESMTP id h52si6492762qgf.43.2015.07.23.09.30.23
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 09:30:24 -0700 (PDT)
From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: [RFC][PATCH] ipc: Use private shmem or hugetlbfs inodes for shm segments.
Date: Thu, 23 Jul 2015 12:28:33 -0400
Message-Id: <1437668913-25446-1-git-send-email-sds@tycho.nsa.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mstevens@fedoraproject.org
Cc: linux-kernel@vger.kernel.org, nyc@holomorphy.com, hughd@google.com, akpm@linux-foundation.org, manfred@colorfullife.com, dave@stgolabs.net, linux-mm@kvack.org, wagi@monom.org, prarit@redhat.com, torvalds@linux-foundation.org, david@fromorbit.com, esandeen@redhat.com, eparis@redhat.com, selinux@tycho.nsa.gov, paul@paul-moore.com, linux-security-module@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>

The shm implementation internally uses shmem or hugetlbfs inodes
for shm segments.  As these inodes are never directly exposed to
userspace and only accessed through the shm operations which are
already hooked by security modules, mark the inodes with the
S_PRIVATE flag so that inode security initialization and permission
checking is skipped.

This was motivated by the following lockdep warning:
===================================================
[ INFO: possible circular locking dependency detected ]
4.2.0-0.rc3.git0.1.fc24.x86_64+debug #1 Tainted: G        W
-------------------------------------------------------
httpd/1597 is trying to acquire lock:
(&ids->rwsem){+++++.}, at: [<ffffffff81385354>] shm_close+0x34/0x130
(&mm->mmap_sem){++++++}, at: [<ffffffff81386bbb>] SyS_shmdt+0x4b/0x180
      [<ffffffff81109a07>] lock_acquire+0xc7/0x270
      [<ffffffff81217baa>] __might_fault+0x7a/0xa0
      [<ffffffff81284a1e>] filldir+0x9e/0x130
      [<ffffffffa019bb08>] xfs_dir2_block_getdents.isra.12+0x198/0x1c0 [xfs]
      [<ffffffffa019c5b4>] xfs_readdir+0x1b4/0x330 [xfs]
      [<ffffffffa019f38b>] xfs_file_readdir+0x2b/0x30 [xfs]
      [<ffffffff812847e7>] iterate_dir+0x97/0x130
      [<ffffffff81284d21>] SyS_getdents+0x91/0x120
      [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
      [<ffffffff81109a07>] lock_acquire+0xc7/0x270
      [<ffffffff81101e97>] down_read_nested+0x57/0xa0
      [<ffffffffa01b0e57>] xfs_ilock+0x167/0x350 [xfs]
      [<ffffffffa01b10b8>] xfs_ilock_attr_map_shared+0x38/0x50 [xfs]
      [<ffffffffa014799d>] xfs_attr_get+0xbd/0x190 [xfs]
      [<ffffffffa01c17ad>] xfs_xattr_get+0x3d/0x70 [xfs]
      [<ffffffff8129962f>] generic_getxattr+0x4f/0x70
      [<ffffffff8139ba52>] inode_doinit_with_dentry+0x162/0x670
      [<ffffffff8139cf69>] sb_finish_set_opts+0xd9/0x230
      [<ffffffff8139d66c>] selinux_set_mnt_opts+0x35c/0x660
      [<ffffffff8139ff97>] superblock_doinit+0x77/0xf0
      [<ffffffff813a0020>] delayed_superblock_init+0x10/0x20
      [<ffffffff81272d23>] iterate_supers+0xb3/0x110
      [<ffffffff813a4e5f>] selinux_complete_init+0x2f/0x40
      [<ffffffff813b47a3>] security_load_policy+0x103/0x600
      [<ffffffff813a6901>] sel_write_load+0xc1/0x750
      [<ffffffff8126e817>] __vfs_write+0x37/0x100
      [<ffffffff8126f229>] vfs_write+0xa9/0x1a0
      [<ffffffff8126ff48>] SyS_write+0x58/0xd0
      [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
      [<ffffffff81109a07>] lock_acquire+0xc7/0x270
      [<ffffffff8186de8f>] mutex_lock_nested+0x7f/0x3e0
      [<ffffffff8139b9a9>] inode_doinit_with_dentry+0xb9/0x670
      [<ffffffff8139bf7c>] selinux_d_instantiate+0x1c/0x20
      [<ffffffff813955f6>] security_d_instantiate+0x36/0x60
      [<ffffffff81287c34>] d_instantiate+0x54/0x70
      [<ffffffff8120111c>] __shmem_file_setup+0xdc/0x240
      [<ffffffff81201290>] shmem_file_setup+0x10/0x20
      [<ffffffff813856e0>] newseg+0x290/0x3a0
      [<ffffffff8137e278>] ipcget+0x208/0x2d0
      [<ffffffff81386074>] SyS_shmget+0x54/0x70
      [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
      [<ffffffff81108df8>] __lock_acquire+0x1a78/0x1d00
      [<ffffffff81109a07>] lock_acquire+0xc7/0x270
      [<ffffffff8186efba>] down_write+0x5a/0xc0
      [<ffffffff81385354>] shm_close+0x34/0x130
      [<ffffffff812203a5>] remove_vma+0x45/0x80
      [<ffffffff81222a30>] do_munmap+0x2b0/0x460
      [<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
      [<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76
Chain exists of:#012  &ids->rwsem --> &xfs_dir_ilock_class --> &mm->mmap_sem
Possible unsafe locking scenario:
      CPU0                    CPU1
      ----                    ----
 lock(&mm->mmap_sem);
 lock(&xfs_dir_ilock_class);
                              lock(&mm->mmap_sem);
 lock(&ids->rwsem);
1 lock held by httpd/1597:
CPU: 7 PID: 1597 Comm: httpd Tainted: G W       4.2.0-0.rc3.git0.1.fc24.x86_64+Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Pla0000000000000000 000000006cb6fe9d ffff88019ff07c58 ffffffff81868175
0000000000000000 ffffffff82aea390 ffff88019ff07ca8 ffffffff81105903
ffff88019ff07c78 ffff88019ff07d08 0000000000000001 ffff8800b75108f0
Call Trace:
[<ffffffff81868175>] dump_stack+0x4c/0x65
[<ffffffff81105903>] print_circular_bug+0x1e3/0x250
[<ffffffff81108df8>] __lock_acquire+0x1a78/0x1d00
[<ffffffff81220c33>] ? unlink_file_vma+0x33/0x60
[<ffffffff81109a07>] lock_acquire+0xc7/0x270
[<ffffffff81385354>] ? shm_close+0x34/0x130
[<ffffffff8186efba>] down_write+0x5a/0xc0
[<ffffffff81385354>] ? shm_close+0x34/0x130
[<ffffffff81385354>] shm_close+0x34/0x130
[<ffffffff812203a5>] remove_vma+0x45/0x80
[<ffffffff81222a30>] do_munmap+0x2b0/0x460
[<ffffffff81386bbb>] ? SyS_shmdt+0x4b/0x180
[<ffffffff81386c25>] SyS_shmdt+0xb5/0x180
[<ffffffff81871d2e>] entry_SYSCALL_64_fastpath+0x12/0x76

Reported-by: Morten Stevens <mstevens@fedoraproject.org>
Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
---
 fs/hugetlbfs/inode.c | 2 ++
 ipc/shm.c            | 2 +-
 mm/shmem.c           | 4 ++--
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 0cf74df..973c24c 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1010,6 +1010,8 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
 	inode = hugetlbfs_get_inode(sb, NULL, S_IFREG | S_IRWXUGO, 0);
 	if (!inode)
 		goto out_dentry;
+	if (creat_flags == HUGETLB_SHMFS_INODE)
+		inode->i_flags |= S_PRIVATE;
 
 	file = ERR_PTR(-ENOMEM);
 	if (hugetlb_reserve_pages(inode, 0,
diff --git a/ipc/shm.c b/ipc/shm.c
index 06e5cf2..4aef24d 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -545,7 +545,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 		if  ((shmflg & SHM_NORESERVE) &&
 				sysctl_overcommit_memory != OVERCOMMIT_NEVER)
 			acctflag = VM_NORESERVE;
-		file = shmem_file_setup(name, size, acctflag);
+		file = shmem_kernel_file_setup(name, size, acctflag);
 	}
 	error = PTR_ERR(file);
 	if (IS_ERR(file))
diff --git a/mm/shmem.c b/mm/shmem.c
index 4caf8ed..dbe0c1e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3363,8 +3363,8 @@ put_path:
  * shmem_kernel_file_setup - get an unlinked file living in tmpfs which must be
  * 	kernel internal.  There will be NO LSM permission checks against the
  * 	underlying inode.  So users of this interface must do LSM checks at a
- * 	higher layer.  The one user is the big_key implementation.  LSM checks
- * 	are provided at the key level rather than the inode level.
+ *	higher layer.  The users are the big_key and shm implementations.  LSM
+ *	checks are provided at the key or shm level rather than the inode.
  * @name: name for dentry (to be seen in /proc/<pid>/maps
  * @size: size to be set for the file
  * @flags: VM_NORESERVE suppresses pre-accounting of the entire object size
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
