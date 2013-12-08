Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 449336B0035
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 16:52:20 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so4153728pbc.7
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 13:52:19 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id iz5si5171678pbd.332.2013.12.08.13.52.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 08 Dec 2013 13:52:19 -0800 (PST)
Message-ID: <52A4E9C2.2040405@oracle.com>
Date: Sun, 08 Dec 2013 16:50:58 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: ksm: lockdep spew on unmerge
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, mgorman@suse.de
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

The following spew seems to occur when passing KSM_RUN_UNMERGE to the 'run' sysfs file.

As far as I can tell, this looks like a valid possibility of a deadlock, although I can't
figure out how to deal with it without adding an extra layer of locks.

[  116.570745] ======================================================
[  116.571884] [ INFO: possible circular locking dependency detected ]
[  116.572880] 3.13.0-rc2-next-20131206-sasha-00005-g8be2375-dirty #4052 Not tainted
[  116.574142] -------------------------------------------------------
[  116.575449] ksmd/3929 is trying to acquire lock:

[  116.576378]  (&mm->mmap_sem){++++++}, at: [<ffffffff812a887a>] scan_get_next_rmap_item+0x13a/0x4d0
[  116.578354]
[  116.578354] but task is already holding lock:
[  116.579238]  (ksm_thread_mutex){+.+...}, at: [<ffffffff812a948e>] ksm_scan_thread+0x5e/0x270
[  116.580669]
[  116.580669] which lock already depends on the new lock.
[  116.580669]
[  116.580669]
[  116.580669] the existing dependency chain (in reverse order) is:
[  116.580669]
-> #2 (ksm_thread_mutex){+.+...}:
[  116.580669]        [<ffffffff81194833>] validate_chain+0x6c3/0x7b0
[  116.580669]        [<ffffffff81194dcd>] __lock_acquire+0x4ad/0x580
[  116.580669]        [<ffffffff81195022>] lock_acquire+0x182/0x1d0
[  116.580669]        [<ffffffff8439825f>] mutex_lock_nested+0x6f/0x520
[  116.580669]        [<ffffffff812a85cb>] run_store+0x5b/0x100
[  116.580669]        [<ffffffff81ab2547>] kobj_attr_store+0x17/0x20
[  116.580669]        [<ffffffff8136014f>] sysfs_kf_write+0x4f/0x70
[  116.580669]        [<ffffffff81363fbb>] kernfs_file_write+0xdb/0x140
[  116.580669]        [<ffffffff812d7463>] vfs_write+0xf3/0x1e0
[  116.580669]        [<ffffffff812d7652>] SyS_write+0x62/0xa0
[  116.580669]        [<ffffffff843a6810>] tracesys+0xdd/0xe2
[  116.580669]
-> #1 (&of->mutex){+.+.+.}:
[  116.580669]        [<ffffffff81194833>] validate_chain+0x6c3/0x7b0
[  116.580669]        [<ffffffff81194dcd>] __lock_acquire+0x4ad/0x580
[  116.580669]        [<ffffffff81195022>] lock_acquire+0x182/0x1d0
[  116.580669]        [<ffffffff8439825f>] mutex_lock_nested+0x6f/0x520
[  116.580669]        [<ffffffff813639e9>] kernfs_file_mmap+0x49/0x120
[  116.580669]        [<ffffffff81286d70>] mmap_region+0x310/0x5c0
[  116.580669]        [<ffffffff812873be>] do_mmap_pgoff+0x39e/0x440
[  116.580669]        [<ffffffff8126d054>] vm_mmap_pgoff+0x94/0xe0
[  116.580669]        [<ffffffff81284078>] SyS_mmap_pgoff+0x1b8/0x210
[  116.580669]        [<ffffffff810725a2>] SyS_mmap+0x22/0x30
[  116.580669]        [<ffffffff843a6810>] tracesys+0xdd/0xe2
[  116.580669]
-> #0 (&mm->mmap_sem){++++++}:
[  116.580669]        [<ffffffff81193d5f>] check_prev_add+0x13f/0x550
[  116.580669]        [<ffffffff81194833>] validate_chain+0x6c3/0x7b0
[  116.580669]        [<ffffffff81194dcd>] __lock_acquire+0x4ad/0x580
[  116.580669]        [<ffffffff81195022>] lock_acquire+0x182/0x1d0
[  116.580669]        [<ffffffff8439ae4c>] down_read+0x4c/0xa0
[  116.580669]        [<ffffffff812a887a>] scan_get_next_rmap_item+0x13a/0x4d0
[  116.580669]        [<ffffffff812a93e0>] ksm_do_scan+0x50/0xa0
[  116.580669]        [<ffffffff812a94b4>] ksm_scan_thread+0x84/0x270
[  116.580669]        [<ffffffff8115da15>] kthread+0x105/0x110
[  116.580669]        [<ffffffff843a653c>] ret_from_fork+0x7c/0xb0
[  116.580669]
[  116.580669] other info that might help us debug this:
[  116.580669]
[  116.580669] Chain exists of:
   &mm->mmap_sem --> &of->mutex --> ksm_thread_mutex

[  116.580669]  Possible unsafe locking scenario:
[  116.580669]
[  116.580669]        CPU0                    CPU1
[  116.580669]        ----                    ----
[  116.580669]   lock(ksm_thread_mutex);
[  116.580669]                                lock(&of->mutex);
[  116.580669]                                lock(ksm_thread_mutex);
[  116.580669]   lock(&mm->mmap_sem);
[  116.580669]
[  116.580669]  *** DEADLOCK ***
[  116.580669]
[  116.580669] 1 lock held by ksmd/3929:
[  116.580669]  #0:  (ksm_thread_mutex){+.+...}, at: [<ffffffff812a948e>] ksm_scan_thread+0x5e/0x270
[  116.580669]
[  116.580669] stack backtrace:
[  116.580669] CPU: 3 PID: 3929 Comm: ksmd Not tainted 
3.13.0-rc2-next-20131206-sasha-00005-g8be2375-dirty #4052
[  116.580669]  0000000000000000 ffff880fc5d9ba98 ffffffff843956f7 0000000000000000
[  116.580669]  0000000000000000 ffff880fc5d9bae8 ffffffff81191909 ffff880fc5d9bb08
[  116.580669]  ffffffff87667f80 ffff880fc5d9bae8 ffff880fcb37bbd8 ffff880fcb37bc10
[  116.580669] Call Trace:
[  116.580669]  [<ffffffff843956f7>] dump_stack+0x52/0x7f
[  116.580669]  [<ffffffff81191909>] print_circular_bug+0x129/0x160
[  116.580669]  [<ffffffff81193d5f>] check_prev_add+0x13f/0x550
[  116.580669]  [<ffffffff81194833>] validate_chain+0x6c3/0x7b0
[  116.580669]  [<ffffffff811755b8>] ? sched_clock_cpu+0x108/0x120
[  116.580669]  [<ffffffff81194dcd>] __lock_acquire+0x4ad/0x580
[  116.580669]  [<ffffffff81195022>] lock_acquire+0x182/0x1d0
[  116.580669]  [<ffffffff812a887a>] ? scan_get_next_rmap_item+0x13a/0x4d0
[  116.580669]  [<ffffffff8439ae4c>] down_read+0x4c/0xa0
[  116.580669]  [<ffffffff812a887a>] ? scan_get_next_rmap_item+0x13a/0x4d0
[  116.580669]  [<ffffffff8439d085>] ? _raw_spin_unlock+0x35/0x60
[  116.580669]  [<ffffffff812a887a>] scan_get_next_rmap_item+0x13a/0x4d0
[  116.580669]  [<ffffffff812a93e0>] ksm_do_scan+0x50/0xa0
[  116.580669]  [<ffffffff812a94b4>] ksm_scan_thread+0x84/0x270
[  116.580669]  [<ffffffff81185990>] ? bit_waitqueue+0xc0/0xc0
[  116.580669]  [<ffffffff812a9430>] ? ksm_do_scan+0xa0/0xa0
[  116.580669]  [<ffffffff8115da15>] kthread+0x105/0x110
[  116.580669]  [<ffffffff8115d910>] ? set_kthreadd_affinity+0x30/0x30
[  116.580669]  [<ffffffff843a653c>] ret_from_fork+0x7c/0xb0
[  116.580669]  [<ffffffff8115d910>] ? set_kthreadd_affinity+0x30/0x30


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
