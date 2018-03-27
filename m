Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9536B0024
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 07:20:14 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e4so19277658iof.7
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 04:20:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j89si759875ioi.196.2018.03.27.04.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 04:20:12 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: Introduce i_mmap_lock_write_killable().
Date: Tue, 27 Mar 2018 20:19:30 +0900
Message-Id: <1522149570-4517-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>

I found that it is not difficult to hit "oom_reaper: unable to reap pid:"
messages if the victim thread is doing copy_process(). If we check where
the OOM victims are stuck, we can find that they are waiting at
i_mmap_lock_write() in dup_mmap().

----------------------------------------
[  239.804758] Out of memory: Kill process 28909 (a.out) score 0 or sacrifice child
[  239.808597] Killed process 31088 (a.out) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  239.929470] oom_reaper: reaped process 31088 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  240.520586] Out of memory: Kill process 28909 (a.out) score 0 or sacrifice child
[  240.524264] Killed process 29307 (a.out) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  241.568323] oom_reaper: reaped process 29307 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  242.228607] Out of memory: Kill process 28909 (a.out) score 0 or sacrifice child
[  242.232281] Killed process 29323 (a.out) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  242.902598] Out of memory: Kill process 28909 (a.out) score 0 or sacrifice child
[  242.906366] Killed process 31097 (a.out) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  243.240908] oom_reaper: reaped process 31097 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  243.854813] Out of memory: Kill process 28909 (a.out) score 0 or sacrifice child
[  243.858490] Killed process 31100 (a.out) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  244.120162] oom_reaper: reaped process 31100 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  244.750778] Out of memory: Kill process 28909 (a.out) score 0 or sacrifice child
[  244.754505] Killed process 31106 (a.out) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  245.815781] oom_reaper: unable to reap pid:31106 (a.out)
[  245.818786] 
[  245.818786] Showing all locks held in the system:
(...snipped...)
[  245.869500] 1 lock held by kswapd0/79:
[  245.872655]  #0: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  246.565465] 1 lock held by a.out/29307: /* Already reaped OOM victim */
[  246.568926]  #0: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
(...snipped...)
[  250.812088] 3 locks held by a.out/30940:
[  250.815543]  #0: 00000000cd61a8e0 (&mm->mmap_sem){++++}, at: copy_process.part.41+0x10d5/0x1fe0
[  250.820980]  #1: 00000000cf6d4f24 (&mm->mmap_sem/1){+.+.}, at: copy_process.part.41+0x10fe/0x1fe0
[  250.826401]  #2: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  251.233604] 1 lock held by a.out/31088: /* Already reaped OOM victim */
[  251.236953]  #0: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
(...snipped...)
[  251.258144] 1 lock held by a.out/31097: /* Already reaped OOM victim */
[  251.261531]  #0: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
[  251.266789] 1 lock held by a.out/31100: /* Already reaped OOM victim */
[  251.270208]  #0: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
(...snipped...)
[  251.305475] 3 locks held by a.out/31106: /* Unable to reap OOM victim */
[  251.308949]  #0: 00000000b0f753ba (&mm->mmap_sem){++++}, at: copy_process.part.41+0x10d5/0x1fe0
[  251.314283]  #1: 00000000ef64d539 (&mm->mmap_sem/1){+.+.}, at: copy_process.part.41+0x10fe/0x1fe0
[  251.319618]  #2: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: copy_process.part.41+0x12f2/0x1fe0
(...snipped...)
[  259.196415] 1 lock held by a.out/33338:
[  259.199837]  #0: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: unlink_file_vma+0x28/0x50
(...snipped...)
[  264.040902] 3 locks held by a.out/34558:
[  264.044475]  #0: 00000000348405b9 (&mm->mmap_sem){++++}, at: __do_page_fault+0x16f/0x4d0
[  264.049516]  #1: 00000000962671a1 (&(&ip->i_mmaplock)->mr_lock){++++}, at: xfs_ilock+0x10a/0x190 [xfs]
[  264.055108]  #2: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  267.747036] 3 locks held by a.out/35518:
[  267.750545]  #0: 0000000098a5825d (&mm->mmap_sem){++++}, at: copy_process.part.41+0x10d5/0x1fe0
[  267.755955]  #1: 000000002b63c006 (&mm->mmap_sem/1){+.+.}, at: copy_process.part.41+0x10fe/0x1fe0
[  267.761466]  #2: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  295.198803] 1 lock held by a.out/42524:
[  295.202483]  #0: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  295.599000] 2 locks held by a.out/42684:
[  295.602901]  #0: 000000003cd42787 (&mm->mmap_sem){++++}, at: __do_page_fault+0x457/0x4d0
[  295.608495]  #1: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  296.202611] 2 locks held by a.out/42885:
[  296.206546]  #0: 0000000065124e3d (&mm->mmap_sem){++++}, at: __do_page_fault+0x16f/0x4d0
[  296.212185]  #1: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  300.594196] 2 locks held by a.out/44035:
[  300.599942]  #0: 00000000a4e2de40 (&mm->mmap_sem){++++}, at: __do_page_fault+0x457/0x4d0
[  300.605533]  #1: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x205/0x310
(...snipped...)
[  302.278287] 3 locks held by a.out/44420:
[  302.282104]  #0: 00000000f043328f (&mm->mmap_sem){++++}, at: copy_process.part.41+0x10d5/0x1fe0
[  302.287959]  #1: 000000007f312097 (&mm->mmap_sem/1){+.+.}, at: copy_process.part.41+0x10fe/0x1fe0
[  302.293872]  #2: 00000000b41a282e (&mapping->i_mmap_rwsem){++++}, at: copy_process.part.41+0x12f2/0x1fe0
----------------------------------------

In dup_mmap(), we are using down_write_killable() for mm->mmap_sem but
we are not using down_write_killable() for mapping->i_mmap_rwsem. And
what is unfortunate is that processes accessing mapping->i_mmap_rwsem
is more wider than processes accessing the OOM victim's mm->mmap_sem.

If the OOM victim is holding mm->mmap_sem held for write, and if the OOM
victim can interrupt operations which need mm->mmap_sem held for write,
we can downgrade mm->mmap_sem upon SIGKILL and the OOM reaper will be
able to reap the OOM victim's memory.

Therefore, this patch introduces i_mmap_lock_write_killable() and downgrade
upon SIGKILL. Since mm->mmap_sem is still held for read, nobody can acquire
mm->mmap_sem for write. Thus, the only thing we need to be careful is that
whether we can safely interrupt. (But I'm not familiar with mmap. Thus,
please review carefully...)

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/fs.h |  5 +++++
 kernel/fork.c      | 16 +++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index bb45c48..2f11c55 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -468,6 +468,11 @@ static inline void i_mmap_lock_write(struct address_space *mapping)
 	down_write(&mapping->i_mmap_rwsem);
 }
 
+static inline int i_mmap_lock_write_killable(struct address_space *mapping)
+{
+	return down_write_killable(&mapping->i_mmap_rwsem);
+}
+
 static inline void i_mmap_unlock_write(struct address_space *mapping)
 {
 	up_write(&mapping->i_mmap_rwsem);
diff --git a/kernel/fork.c b/kernel/fork.c
index 1e8c9a7..b4384e2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -400,6 +400,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	int retval;
 	unsigned long charge;
 	LIST_HEAD(uf);
+	bool downgraded = false;
 
 	uprobe_start_dup_mmap();
 	if (down_write_killable(&oldmm->mmap_sem)) {
@@ -476,7 +477,11 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-			i_mmap_lock_write(mapping);
+			if (i_mmap_lock_write_killable(mapping)) {
+				downgrade_write(&oldmm->mmap_sem);
+				downgraded = true;
+				i_mmap_lock_write(mapping);
+			}
 			if (tmp->vm_flags & VM_SHARED)
 				atomic_inc(&mapping->i_mmap_writable);
 			flush_dcache_mmap_lock(mapping);
@@ -508,7 +513,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		if (!(tmp->vm_flags & VM_WIPEONFORK))
+		if (downgraded)
+			retval = -EINTR;
+		else if (!(tmp->vm_flags & VM_WIPEONFORK))
 			retval = copy_page_range(mm, oldmm, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
@@ -523,7 +530,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 out:
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	if (!downgraded)
+		up_write(&oldmm->mmap_sem);
+	else
+		up_read(&oldmm->mmap_sem);
 	dup_userfaultfd_complete(&uf);
 fail_uprobe_end:
 	uprobe_end_dup_mmap();
-- 
1.8.3.1
