Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id BBEF76B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 07:49:43 -0500 (EST)
Date: Fri, 4 Jan 2013 13:49:37 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: 3.8-rc2: lockdep is complaining about mm_take_all_locks()
Message-ID: <alpine.LNX.2.00.1301041317150.9143@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is almost certainly because

commit 5a505085f043e8380f83610f79642853c051e2f1
Author: Ingo Molnar <mingo@kernel.org>
Date:   Sun Dec 2 19:56:46 2012 +0000

    mm/rmap: Convert the struct anon_vma::mutex to an rwsem

did this to mm_take_all_locks():

	-               mutex_lock_nest_lock(&anon_vma->root->mutex, &mm->mmap_sem);
	+               down_write(&anon_vma->root->rwsem);

killing the lockdep annotation that has been there since 

commit 454ed842d55740160334efc9ad56cfef54ed37bc
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Mon Aug 11 09:30:25 2008 +0200

    lockdep: annotate mm_take_all_locks()

The locking is obviously correct due to mmap_sem being held throughout the 
whole operation, but I am not completely sure how to annotate this 
properly for lockdep in down_write() case though. Ingo, please?



 =============================================
 [ INFO: possible recursive locking detected ]
 3.8.0-rc2-00036-g5f73896 #171 Not tainted
 ---------------------------------------------
 qemu-kvm/2315 is trying to acquire lock:
  (&anon_vma->rwsem){+.+...}, at: [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
 
 but task is already holding lock:
  (&anon_vma->rwsem){+.+...}, at: [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
 
 other info that might help us debug this:
  Possible unsafe locking scenario:
 
        CPU0
        ----
   lock(&anon_vma->rwsem);
   lock(&anon_vma->rwsem);
 
  *** DEADLOCK ***
 
  May be due to missing lock nesting notation
 
 4 locks held by qemu-kvm/2315:
  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81177f1c>] do_mmu_notifier_register+0xfc/0x170
  #1:  (mm_all_locks_mutex){+.+...}, at: [<ffffffff8115d436>] mm_take_all_locks+0x36/0x1b0
  #2:  (&mapping->i_mmap_mutex){+.+...}, at: [<ffffffff8115d4c9>] mm_take_all_locks+0xc9/0x1b0
  #3:  (&anon_vma->rwsem){+.+...}, at: [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
 
 stack backtrace:
 Pid: 2315, comm: qemu-kvm Not tainted 3.8.0-rc2-00036-g5f73896 #171
 Call Trace:
  [<ffffffff810afea2>] print_deadlock_bug+0xf2/0x100
  [<ffffffff810b1a76>] validate_chain+0x4f6/0x720
  [<ffffffff810b1ff9>] __lock_acquire+0x359/0x580
  [<ffffffff810b0e7d>] ? trace_hardirqs_on_caller+0x12d/0x1b0
  [<ffffffff810b2341>] lock_acquire+0x121/0x190
  [<ffffffff8115d549>] ? mm_take_all_locks+0x149/0x1b0
  [<ffffffff815a12bf>] down_write+0x3f/0x70
  [<ffffffff8115d549>] ? mm_take_all_locks+0x149/0x1b0
  [<ffffffff8115d549>] mm_take_all_locks+0x149/0x1b0
  [<ffffffff81177e88>] do_mmu_notifier_register+0x68/0x170
  [<ffffffff81177fae>] mmu_notifier_register+0xe/0x10
  [<ffffffffa04bd6ab>] kvm_create_vm+0x22b/0x330 [kvm]
  [<ffffffffa04bd8a8>] kvm_dev_ioctl+0xf8/0x1a0 [kvm]
  [<ffffffff811a45bd>] do_vfs_ioctl+0x9d/0x350
  [<ffffffff815ad215>] ? sysret_check+0x22/0x5d
  [<ffffffff811a4901>] sys_ioctl+0x91/0xb0
  [<ffffffff815ad1e9>] system_call_fastpath+0x16/0x1b

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
