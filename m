Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 8F70E6B0083
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 16:29:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 20:24:29 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3GKMMp0913414
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 06:22:22 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3GKSus5027475
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 06:28:56 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] hugetlbfs: lockdep annotate root inode properly
Date: Tue, 17 Apr 2012 01:58:46 +0530
Message-Id: <1334608126-17295-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, davej@redhat.com, linux-kernel@vger.kernel.or, viro@ZenIV.linux.org.uk, jwboyer@redhat.com
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This fix the below reported false lockdep warning. e096d0c7e2e4e5893792db865dd065ac73cf1f00
did a similar annotation for every other inode in hugetlbfs but missed the root
inode because it was allocated by a separate function.

For HugeTLB fs we allow taking i_mutex in mmap. HugeTLB fs doesn't support file
write and its file read callback is modified in a05b0855fd15504972dba2358e5faa172a1e50ba
to not take i_mutex. Hence for HugeTLB fs with regular files we really don't take
i_mutex with mmap_sem held.

 ======================================================
 [ INFO: possible circular locking dependency detected ]
 3.4.0-rc1+ #322 Not tainted
 -------------------------------------------------------
 bash/1572 is trying to acquire lock:
  (&mm->mmap_sem){++++++}, at: [<ffffffff810f1618>] might_fault+0x40/0x90

 but task is already holding lock:
  (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff81125f88>] vfs_readdir+0x56/0xa8

 which lock already depends on the new lock.


 the existing dependency chain (in reverse order) is:

 -> #1 (&sb->s_type->i_mutex_key#12){+.+.+.}:
        [<ffffffff810a09e5>] lock_acquire+0xd5/0xfa
        [<ffffffff816a2f5e>] __mutex_lock_common+0x48/0x350
        [<ffffffff816a3325>] mutex_lock_nested+0x2a/0x31
        [<ffffffff811fb8e1>] hugetlbfs_file_mmap+0x7d/0x104
        [<ffffffff810f859a>] mmap_region+0x272/0x47d
        [<ffffffff810f8a39>] do_mmap_pgoff+0x294/0x2ee
        [<ffffffff810f8b65>] sys_mmap_pgoff+0xd2/0x10e
        [<ffffffff8103d19e>] sys_mmap+0x1d/0x1f
        [<ffffffff816a5922>] system_call_fastpath+0x16/0x1b

 -> #0 (&mm->mmap_sem){++++++}:
        [<ffffffff810a0256>] __lock_acquire+0xa81/0xd75
        [<ffffffff810a09e5>] lock_acquire+0xd5/0xfa
        [<ffffffff810f1645>] might_fault+0x6d/0x90
        [<ffffffff81125d62>] filldir+0x6a/0xc2
        [<ffffffff81133a83>] dcache_readdir+0x5c/0x222
        [<ffffffff81125fa8>] vfs_readdir+0x76/0xa8
        [<ffffffff811260b6>] sys_getdents+0x79/0xc9
        [<ffffffff816a5922>] system_call_fastpath+0x16/0x1b

 other info that might help us debug this:

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&sb->s_type->i_mutex_key#12);
                                lock(&mm->mmap_sem);
                                lock(&sb->s_type->i_mutex_key#12);
   lock(&mm->mmap_sem);

  *** DEADLOCK ***

 1 lock held by bash/1572:
  #0:  (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff81125f88>] vfs_readdir+0x56/0xa8

 stack backtrace:
 Pid: 1572, comm: bash Not tainted 3.4.0-rc1+ #322
 Call Trace:
  [<ffffffff81699a3c>] print_circular_bug+0x1f8/0x209
  [<ffffffff810a0256>] __lock_acquire+0xa81/0xd75
  [<ffffffff810f38aa>] ? handle_pte_fault+0x5ff/0x614
  [<ffffffff8109e622>] ? mark_lock+0x2d/0x258
  [<ffffffff810f1618>] ? might_fault+0x40/0x90
  [<ffffffff810a09e5>] lock_acquire+0xd5/0xfa
  [<ffffffff810f1618>] ? might_fault+0x40/0x90
  [<ffffffff816a3249>] ? __mutex_lock_common+0x333/0x350
  [<ffffffff810f1645>] might_fault+0x6d/0x90
  [<ffffffff810f1618>] ? might_fault+0x40/0x90
  [<ffffffff81125d62>] filldir+0x6a/0xc2
  [<ffffffff81133a83>] dcache_readdir+0x5c/0x222
  [<ffffffff81125cf8>] ? sys_ioctl+0x74/0x74
  [<ffffffff81125cf8>] ? sys_ioctl+0x74/0x74
  [<ffffffff81125cf8>] ? sys_ioctl+0x74/0x74
  [<ffffffff81125fa8>] vfs_readdir+0x76/0xa8
  [<ffffffff811260b6>] sys_getdents+0x79/0xc9
  [<ffffffff816a5922>] system_call_fastpath+0x16/0x1b

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/inode.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 92f75aa..d8899e1 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -485,6 +485,7 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 		inode->i_fop = &simple_dir_operations;
 		/* directory inodes start off with i_nlink == 2 (for "." entry) */
 		inc_nlink(inode);
+		lockdep_annotate_inode_mutex_key(inode);
 	}
 	return inode;
 }
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
