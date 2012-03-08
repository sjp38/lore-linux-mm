Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 7BEB36B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 04:16:06 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 8 Mar 2012 09:10:27 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2899uT22617500
	for <linux-mm@kvack.org>; Thu, 8 Mar 2012 20:10:04 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q289Fbvc032009
	for <linux-mm@kvack.org>; Thu, 8 Mar 2012 20:15:37 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] hugetlbfs: lockdep annotate root inode properly
Date: Thu,  8 Mar 2012 14:45:16 +0530
Message-Id: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, davej@redhat.com, jboyer@redhat.com, tyhicks@canonical.com
Cc: linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This fix the below lockdep warning

 ======================================================
 [ INFO: possible circular locking dependency detected ]
 3.3.0-rc4+ #190 Not tainted
 -------------------------------------------------------
 shared/1568 is trying to acquire lock:
  (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff811efa0f>] hugetlbfs_file_mmap+0x7d/0x108

 but task is already holding lock:
  (&mm->mmap_sem){++++++}, at: [<ffffffff810f5589>] sys_mmap_pgoff+0xd4/0x12f

 which lock already depends on the new lock.


 the existing dependency chain (in reverse order) is:

 -> #1 (&mm->mmap_sem){++++++}:
        [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
        [<ffffffff810ee439>] might_fault+0x6d/0x90
        [<ffffffff8111bc12>] filldir+0x6a/0xc2
        [<ffffffff81129942>] dcache_readdir+0x5c/0x222
        [<ffffffff8111be58>] vfs_readdir+0x76/0xac
        [<ffffffff8111bf6a>] sys_getdents+0x79/0xc9
        [<ffffffff816940a2>] system_call_fastpath+0x16/0x1b

 -> #0 (&sb->s_type->i_mutex_key#12){+.+.+.}:
        [<ffffffff8109f40a>] __lock_acquire+0xa6c/0xd60
        [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
        [<ffffffff816916be>] __mutex_lock_common+0x48/0x350
        [<ffffffff81691a85>] mutex_lock_nested+0x2a/0x31
        [<ffffffff811efa0f>] hugetlbfs_file_mmap+0x7d/0x108
        [<ffffffff810f4fd0>] mmap_region+0x26f/0x466
        [<ffffffff810f545b>] do_mmap_pgoff+0x294/0x2ee
        [<ffffffff810f55a9>] sys_mmap_pgoff+0xf4/0x12f
        [<ffffffff8103d1f2>] sys_mmap+0x1d/0x1f
        [<ffffffff816940a2>] system_call_fastpath+0x16/0x1b

 other info that might help us debug this:

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&mm->mmap_sem);
                                lock(&sb->s_type->i_mutex_key#12);
                                lock(&mm->mmap_sem);
   lock(&sb->s_type->i_mutex_key#12);

  *** DEADLOCK ***

 1 lock held by shared/1568:
  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff810f5589>] sys_mmap_pgoff+0xd4/0x12f

 stack backtrace:
 Pid: 1568, comm: shared Not tainted 3.3.0-rc4+ #190
 Call Trace:
  [<ffffffff81688bf9>] print_circular_bug+0x1f8/0x209
  [<ffffffff8109f40a>] __lock_acquire+0xa6c/0xd60
  [<ffffffff8110e7b6>] ? files_lglock_local_lock_cpu+0x61/0x61
  [<ffffffff811efa0f>] ? hugetlbfs_file_mmap+0x7d/0x108
  [<ffffffff8109fb8f>] lock_acquire+0xd5/0xfa
  [<ffffffff811efa0f>] ? hugetlbfs_file_mmap+0x7d/0x108

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/inode.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

NOTE: This patch also require 
http://thread.gmane.org/gmane.linux.file-systems/58795/focus=59565
to remove the lockdep warning

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 3645cd3..ca4fa70 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -459,6 +459,7 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 		inode->i_fop = &simple_dir_operations;
 		/* directory inodes start off with i_nlink == 2 (for "." entry) */
 		inc_nlink(inode);
+		lockdep_annotate_inode_mutex_key(inode);
 	}
 	return inode;
 }
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
