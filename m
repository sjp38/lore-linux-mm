Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8BF1A6B0068
	for <linux-mm@kvack.org>; Mon, 31 Dec 2012 12:56:09 -0500 (EST)
Message-ID: <50E1D192.1020308@oracle.com>
Date: Mon, 31 Dec 2012 12:55:30 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: lockup on mmap_sem
Content-Type: multipart/mixed;
 boundary="------------060907080706000407010207"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------060907080706000407010207
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi all,

While fuzzing with trinity inside a KVM tools guest, running latest -next kernel,
I've stumbled on the following hang:

[ 7204.030178] INFO: task khugepaged:3257 blocked for more than 120 seconds.
[ 7204.031043] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 7204.032056] khugepaged      D 00000000001d6dc0  5144  3257      2 0x00000000
[ 7204.032969]  ffff8800be8bdc00 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 7204.033959]  ffff8800bf9cb000 ffff8800be8b3000 ffff8800be8bdc00 00000000001d6dc0
[ 7204.034994]  ffff8800be8b3000 ffff8800be8bdfd8 00000000001d6dc0 00000000001d6dc0
[ 7204.036057] Call Trace:
[ 7204.036388]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 7204.037090]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 7204.037711]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 7204.038511]  [<ffffffff83ce4ca5>] rwsem_down_read_failed+0x15/0x17
[ 7204.039292]  [<ffffffff81a139a4>] call_rwsem_down_read_failed+0x14/0x30
[ 7204.040207]  [<ffffffff83ce3349>] ? down_read+0x79/0x8e
[ 7204.040895]  [<ffffffff81276147>] ? khugepaged_scan_mm_slot+0xa7/0x2b0
[ 7204.041689]  [<ffffffff83ce55b0>] ? _raw_spin_unlock+0x30/0x60
[ 7204.042482]  [<ffffffff81276147>] khugepaged_scan_mm_slot+0xa7/0x2b0
[ 7204.043299]  [<ffffffff8127644d>] khugepaged_do_scan+0xfd/0x1a0
[ 7204.044105]  [<ffffffff812764f0>] ? khugepaged_do_scan+0x1a0/0x1a0
[ 7204.044874]  [<ffffffff81276515>] khugepaged+0x25/0x70
[ 7204.045527]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 7204.046129]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 7204.046905]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 7204.047609]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 7204.048524] 1 lock held by khugepaged/3257:
[ 7204.049046]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81276147>] khugepaged_scan_mm_slot+0xa7/0x2b0
[ 7204.050449] INFO: task trinity-child22:15461 blocked for more than 120 seconds.
[ 7204.051355] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 7204.052390] trinity-child22 D ffff88000c00e4c0  4920 15461   6883 0x00000004
[ 7204.053347]  ffff88002fba9bc0 0000000000000002 ffff88000b6c2000 ffff88000b6c2000
[ 7204.054387]  ffff880008003000 ffff880007898000 ffff88002fba9bc0 00000000001d6dc0
[ 7204.055373]  ffff880007898000 ffff88002fba9fd8 00000000001d6dc0 00000000001d6dc0
[ 7204.056396] Call Trace:
[ 7204.056703]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 7204.057402]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 7204.058036]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 7204.058826]  [<ffffffff83ce4ca5>] rwsem_down_read_failed+0x15/0x17
[ 7204.059588]  [<ffffffff81a139a4>] call_rwsem_down_read_failed+0x14/0x30
[ 7204.060502]  [<ffffffff83ce3349>] ? down_read+0x79/0x8e
[ 7204.061188]  [<ffffffff8125fa16>] ? do_migrate_pages+0x56/0x2b0
[ 7204.061906]  [<ffffffff81220d50>] ? lru_add_drain_all+0x10/0x20
[ 7204.062648]  [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0
[ 7204.063418]  [<ffffffff81a26ef8>] ? do_raw_spin_unlock+0xc8/0xe0
[ 7204.064240]  [<ffffffff8194e573>] ? security_capable+0x13/0x20
[ 7204.064865]  [<ffffffff8111d8c0>] ? ns_capable+0x50/0x80
[ 7204.065443]  [<ffffffff812601c2>] sys_migrate_pages+0x4e2/0x550
[ 7204.065964]  [<ffffffff8125fd98>] ? sys_migrate_pages+0xb8/0x550
[ 7204.066513]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 7204.067011] 1 lock held by trinity-child22/15461:
[ 7204.067452]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0
[ 7204.068489] INFO: task trinity-child16:15829 blocked for more than 120 seconds.
[ 7204.069224] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 7204.070057] trinity-child16 D ffff880008ba74c0  5128 15829   6883 0x00000004
[ 7204.070732]  ffff88000c791bc0 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 7204.071550]  ffff88000c083000 ffff88000d808000 ffff88000c791bc0 00000000001d6dc0
[ 7204.072380]  ffff88000d808000 ffff88000c791fd8 00000000001d6dc0 00000000001d6dc0
[ 7204.073323] Call Trace:
[ 7204.073614]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 7204.074179]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 7204.074619]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 7204.075285]  [<ffffffff83ce4ca5>] rwsem_down_read_failed+0x15/0x17
[ 7204.075839]  [<ffffffff81a139a4>] call_rwsem_down_read_failed+0x14/0x30
[ 7204.076435]  [<ffffffff83ce3349>] ? down_read+0x79/0x8e
[ 7204.076900]  [<ffffffff8125fa16>] ? do_migrate_pages+0x56/0x2b0
[ 7204.077623]  [<ffffffff81220d50>] ? lru_add_drain_all+0x10/0x20
[ 7204.078360]  [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0
[ 7204.079063]  [<ffffffff81a26ef8>] ? do_raw_spin_unlock+0xc8/0xe0
[ 7204.079622]  [<ffffffff8194e573>] ? security_capable+0x13/0x20
[ 7204.080329]  [<ffffffff8111d8c0>] ? ns_capable+0x50/0x80
[ 7204.080938]  [<ffffffff812601c2>] sys_migrate_pages+0x4e2/0x550
[ 7204.081692]  [<ffffffff8125fd98>] ? sys_migrate_pages+0xb8/0x550
[ 7204.082241]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 7204.082735] 1 lock held by trinity-child16/15829:
[ 7204.083401]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0

I'm not quite sure how it happened, but I've attached a full sysrq-t which could possibly
help with figuring it out.


Thanks,
Sasha

--------------060907080706000407010207
Content-Type: text/plain; charset=UTF-8;
 name="mm_sysrq.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mm_sysrq.txt"

[ 8513.880125] SysRq : Show State
[ 8513.880586]   task                        PC stack   pid father
[ 8513.881316] init            S 00000000001d6dc0  2560     1      0 0x00000000
[ 8513.882034]  ffff8800bf903de8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8513.882764]  ffffffff8542f440 ffff8800bf908000 00000000001d6dc0 00000000001d6dc0
[ 8513.883577]  ffff8800bf908000 ffff8800bf903fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.884785] Call Trace:
[ 8513.885252]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.886184]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.886900]  [<ffffffff81115615>] do_wait+0x2b5/0x3b0
[ 8513.887932]  [<ffffffff8111682b>] sys_wait4+0xbb/0xe0
[ 8513.889123]  [<ffffffff81113590>] ? put_task_struct+0x20/0x20
[ 8513.890025]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8513.890025] kthreadd        S 00000000001d6dc0  5480     2      0 0x00000000
[ 8513.890025]  ffff8800bf905df8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bfad0000 ffff8800bf90b000 ffff8800bf905df8 00000000001d6dc0
[ 8513.890025]  ffff8800bf90b000 ffff8800bf905fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8113f7b1>] kthreadd+0xd1/0x170
[ 8513.890025]  [<ffffffff8113f6e0>] ? kthread_create_on_cpu+0x80/0x80
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f6e0>] ? kthread_create_on_cpu+0x80/0x80
[ 8513.890025] ksoftirqd/0     S 00000000001d6dc0  5520     3      2 0x00000000
[ 8513.890025]  ffff8800bf907d58 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfadb000 ffff8800bf918000 ffff8800bf907d58 00000000001d6dc0
[ 8513.890025]  ffff8800bf918000 ffff8800bf907fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/0:0     S 00000000001d6dc0  5800     4      2 0x00000000
[ 8513.890025]  ffff8800bf921d48 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfacb000 ffff8800bf91b000 ffff8800bf921d48 00000000001d6dc0
[ 8513.890025]  ffff8800bf91b000 ffff8800bf921fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/0:0H    S 00000000001d6dc0  5800     5      2 0x00000000
[ 8513.890025]  ffff8800bf923d48 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8513.890025]  ffff8800be4b0000 ffff8800bf928000 ffff8800bf923d48 00000000001d6dc0
[ 8513.890025]  ffff8800bf928000 ffff8800bf923fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/u:0     S 00000000001d6dc0  4880     6      2 0x00000000
[ 8513.890025]  ffff8800bf925d48 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff880007ba8000 ffff8800bf92b000 ffff8800bf925d48 00000000001d6dc0
[ 8513.890025]  ffff8800bf92b000 ffff8800bf925fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/u:0H    S 00000000001d6dc0  6376     7      2 0x00000000
[ 8513.890025]  ffff8800bf927d48 0000000000000006 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf933000 ffff8800bf930000 ffff8800bf927d48 00000000001d6dc0
[ 8513.890025]  ffff8800bf930000 ffff8800bf927fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] migration/0     S 00000000001d6dc0  5896     8      2 0x00000000
[ 8513.890025]  ffff8800bf939cd8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800be890000 ffff8800bf933000 ffff8800bf939cd8 00000000001d6dc0
[ 8513.890025]  ffff8800bf933000 ffff8800bf939fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff81153c10>] ? __migrate_task+0x200/0x200
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811aeadd>] cpu_stopper_thread+0x1ad/0x1f0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff811ae930>] ? cpu_stop_signal_done+0x30/0x30
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcuc/0          S 00000000001d6dc0  5400     9      2 0x00000000
[ 8513.890025]  ffff8800bf93bd58 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf918000 ffff8800bf940000 ffff8800bf93bd58 00000000001d6dc0
[ 8513.890025]  ffff8800bf940000 ffff8800bf93bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcub/0          S 00000000001d6dc0  5728    10      2 0x00000000
[ 8513.890025]  ffff8800bf93dd48 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfbc0000 ffff8800bf943000 ffff8800bf93dd48 00000000001d6dc0
[ 8513.890025]  ffff8800bf943000 ffff8800bf93dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811d531f>] rcu_boost_kthread+0x17f/0x600
[ 8513.890025]  [<ffffffff811d51a0>] ? trace_rcu_utilization+0x100/0x100
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_preempt     S 00000000001d6dc0  5280    11      2 0x00000000
[ 8513.890025]  ffff8800bf93fd18 0000000000000002 00000000001d6dc0 ffff8800bf948048
[ 8513.890025]  ffff8800bf96b000 ffff8800bf948000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bf948000 ffff8800bf93ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811db85b>] rcu_gp_kthread+0x9b/0x2d0
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff811db7c0>] ? rcu_gp_fqs+0x80/0x80
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_bh          S 00000000001d6dc0  6424    12      2 0x00000000
[ 8513.890025]  ffff8800bf955d18 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf908000 ffff8800bf94b000 ffff8800bf955d18 00000000001d6dc0
[ 8513.890025]  ffff8800bf94b000 ffff8800bf955fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff811db7c0>] ? rcu_gp_fqs+0x80/0x80
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811db85b>] rcu_gp_kthread+0x9b/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff811db7c0>] ? rcu_gp_fqs+0x80/0x80
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_sched       S 00000000001d6dc0  6424    13      2 0x00000000
[ 8513.890025]  ffff8800bf957d18 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf94b000 ffff8800bf958000 ffff8800bf957d18 00000000001d6dc0
[ 8513.890025]  ffff8800bf958000 ffff8800bf957fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff811db7c0>] ? rcu_gp_fqs+0x80/0x80
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811db85b>] rcu_gp_kthread+0x9b/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff811db7c0>] ? rcu_gp_fqs+0x80/0x80
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] watchdog/0      S 00000000001d6dc0  6024    14      2 0x00000000
[ 8513.890025]  ffff8800bf967d58 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800be5c8000 ffff8800bf95b000 ffff8800bf967d58 00000000001d6dc0
[ 8513.890025]  ffff8800bf95b000 ffff8800bf967fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] watchdog/1      S 00000000001d6dc0  6024    15      2 0x00000000
[ 8513.890025]  ffff880007839d58 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bf9fb000 ffff880007830000 ffff880007839d58 00000000001d6dc0
[ 8513.890025]  ffff880007830000 ffff880007839fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcuc/1          S 00000000001d6dc0  5400    16      2 0x00000000
[ 8513.890025]  ffff88000783bd58 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bf948000 ffff880007833000 ffff88000783bd58 00000000001d6dc0
[ 8513.890025]  ffff880007833000 ffff88000783bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] ksoftirqd/1     S 00000000001d6dc0  5704    17      2 0x00000000
[ 8513.890025]  ffff88000783dd58 0000000000000002 00000000001d6dc0 ffff880007840048
[ 8513.890025]  ffff8800bf968000 ffff880007840000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff880007840000 ffff88000783dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] migration/1     S 00000000001d6dc0  5896    18      2 0x00000000
[ 8513.890025]  ffff88000783fcd8 0000000000000002 ffff880007dd6dc0 ffff8800934378c0
[ 8513.890025]  ffff8800bf968000 ffff880007843000 ffff88000783fcd8 00000000001d6dc0
[ 8513.890025]  ffff880007843000 ffff88000783ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff81153c10>] ? __migrate_task+0x200/0x200
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811aeadd>] cpu_stopper_thread+0x1ad/0x1f0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff811ae930>] ? cpu_stop_signal_done+0x30/0x30
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/1:0     S 00000000001d6dc0  5424    19      2 0x00000000
[ 8513.890025]  ffff880007851d48 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff880007653000 ffff880007848000 ffff880007851d48 00000000001d6dc0
[ 8513.890025]  ffff880007848000 ffff880007851fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/1:0H    S 00000000001d6dc0  6248    20      2 0x00000000
[ 8513.890025]  ffff880007853d48 0000000000000002 00000000001d6dc0 ffff88000784b048
[ 8513.890025]  ffff8800bf968000 ffff88000784b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88000784b000 ffff880007853fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] watchdog/2      S 00000000001d6dc0  6024    21      2 0x00000000
[ 8513.890025]  ffff88000b427d58 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8513.890025]  ffff88000ad0b000 ffff88000b430000 ffff88000b427d58 00000000001d6dc0
[ 8513.890025]  ffff88000b430000 ffff88000b427fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcuc/2          S 00000000001d6dc0  5400    22      2 0x00000000
[ 8513.890025]  ffff88000b439d58 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8513.890025]  ffff88000b440000 ffff88000b433000 ffff88000b439d58 00000000001d6dc0
[ 8513.890025]  ffff88000b433000 ffff88000b439fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] ksoftirqd/2     S 00000000001d6dc0  4936    23      2 0x00000000
[ 8513.890025]  ffff88000b43bd58 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8513.890025]  ffff8800be893000 ffff88000b440000 ffff88000b43bd58 00000000001d6dc0
[ 8513.890025]  ffff88000b440000 ffff88000b43bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] migration/2     S 00000000001d6dc0  5896    24      2 0x00000000
[ 8513.890025]  ffff88000b43dcd8 0000000000000002 ffff88000bdd6dc0 ffff8800bf989cc0
[ 8513.890025]  ffff8800bf96b000 ffff88000b443000 ffff88000b43dcd8 00000000001d6dc0
[ 8513.890025]  ffff88000b443000 ffff88000b43dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff81153c10>] ? __migrate_task+0x200/0x200
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811aeadd>] cpu_stopper_thread+0x1ad/0x1f0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff811ae930>] ? cpu_stop_signal_done+0x30/0x30
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/2:0H    S 00000000001d6dc0  6248    26      2 0x00000000
[ 8513.890025]  ffff88000b451d48 0000000000000002 00000000001d6dc0 ffff88000b44b048
[ 8513.890025]  ffff8800bf96b000 ffff88000b44b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88000b44b000 ffff88000b451fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce5624>] ? _raw_spin_unlock_irq+0x44/0x80
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] watchdog/3      S 00000000001d6dc0  6024    27      2 0x00000000
[ 8513.890025]  ffff88000f827d58 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfad8000 ffff88000f830000 ffff88000f827d58 00000000001d6dc0
[ 8513.890025]  ffff88000f830000 ffff88000f827fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcuc/3          S 00000000001d6dc0  5400    28      2 0x00000000
[ 8513.890025]  ffff88000f839d58 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff88000f840000 ffff88000f833000 ffff88000f839d58 00000000001d6dc0
[ 8513.890025]  ffff88000f833000 ffff88000f839fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] ksoftirqd/3     S 00000000001d6dc0  5704    29      2 0x00000000
[ 8513.890025]  ffff88000f83bd58 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff88000f998000 ffff88000f840000 ffff88000f83bd58 00000000001d6dc0
[ 8513.890025]  ffff88000f840000 ffff88000f83bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] migration/3     S 00000000001d6dc0  5896    30      2 0x00000000
[ 8513.890025]  ffff88000f83dcd8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfbc3000 ffff88000f843000 ffff88000f83dcd8 00000000001d6dc0
[ 8513.890025]  ffff88000f843000 ffff88000f83dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff81153c10>] ? __migrate_task+0x200/0x200
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811aeadd>] cpu_stopper_thread+0x1ad/0x1f0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff811ae930>] ? cpu_stop_signal_done+0x30/0x30
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/3:0     S 00000000001d6dc0  5592    31      2 0x00000000
[ 8513.890025]  ffff88000f83fd48 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff88000b5e8000 ffff88000f848000 ffff88000f83fd48 00000000001d6dc0
[ 8513.890025]  ffff88000f848000 ffff88000f83ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/3:0H    S 00000000001d6dc0  6248    32      2 0x00000000
[ 8513.890025]  ffff88000f851d48 0000000000000002 00000000001d6dc0 ffff88000f84b048
[ 8513.890025]  ffff8800bf978000 ffff88000f84b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88000f84b000 ffff88000f851fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] watchdog/4      S 00000000001d6dc0  6024    33      2 0x00000000
[ 8513.890025]  ffff880013433d58 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff880012c80000 ffff880013438000 ffff880013433d58 00000000001d6dc0
[ 8513.890025]  ffff880013438000 ffff880013433fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcuc/4          S 00000000001d6dc0  5448    34      2 0x00000000
[ 8513.890025]  ffff880013435d58 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff880013440000 ffff88001343b000 ffff880013435d58 00000000001d6dc0
[ 8513.890025]  ffff88001343b000 ffff880013435fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] ksoftirqd/4     S ffff8800be6db4c0  5632    35      2 0x00000000
[ 8513.890025]  ffff880013437d58 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8513.890025]  ffff880013580000 ffff880013440000 ffff880013437d58 00000000001d6dc0
[ 8513.890025]  ffff880013440000 ffff880013437fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8114a575>] smpboot_thread_fn+0x265/0x2c0
[ 8513.890025]  [<ffffffff8114a310>] ? smpboot_register_percpu_thread+0xd0/0xd0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff83ce36e6>] ? wait_for_common+0x106/0x170
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] migration/4     S ffff88000c00c4c0  5896    36      2 0x00000000
[ 8513.890025]  ffff880013449cd8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8513.890025]  ffff88000c083000 ffff880013443000 ffff880013449cd8 00000000001d6dc0
[ 8513.890025]  ffff880013443000 ffff880013449fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff81153c10>] ? __migrate_task+0x200/0x200
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811aeadd>] cpu_stopper_thread+0x1ad/0x1f0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff811ae930>] ? cpu_stop_signal_done+0x30/0x30
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/4:0H    S 00000000001d6dc0  6248    38      2 0x00000000
[ 8513.890025]  ffff88001344dd48 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff880013450000 ffff880013453000 ffff88001344dd48 00000000001d6dc0
[ 8513.890025]  ffff880013453000 ffff88001344dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] cpuset          S 00000000001d6dc0  6000    39      2 0x00000000
[ 8513.890025]  ffff8800bf99fd28 0000000000000002 00000000001d6dc0 ffff8800bf9a0048
[ 8513.890025]  ffff8800bf968000 ffff8800bf9a0000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bf9a0000 ffff8800bf99ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] khelper         S 00000000001d6dc0  6392    40      2 0x00000000
[ 8513.890025]  ffff8800bf9a9d28 0000000000000002 00000000001d6dc0 ffff8800bf9a3048
[ 8513.890025]  ffff8800bf968000 ffff8800bf9a3000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bf9a3000 ffff8800bf9a9fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kdevtmpfs       S 00000000001d6dc0  4256    41      2 0x00000000
[ 8513.890025]  ffff8800bf9add68 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf908000 ffff8800bf9b8000 ffff8800bf9add68 00000000001d6dc0
[ 8513.890025]  ffff8800bf9b8000 ffff8800bf9adfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81eef1d4>] devtmpfsd+0x144/0x180
[ 8513.890025]  [<ffffffff81eef090>] ? handle_create.isra.2+0x100/0x100
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] netns           S 00000000001d6dc0  6464    42      2 0x00000000
[ 8513.890025]  ffff8800bf9afd28 0000000000000002 00000000001d6dc0 ffff8800bf9bb048
[ 8513.890025]  ffff8800bf968000 ffff8800bf9bb000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bf9bb000 ffff8800bf9affd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/u:1     S 00000000001d6dc0  4848    43      2 0x00000000
[ 8513.890025]  ffff8800bf9d1d48 0000000000000006 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff88000f998000 ffff8800bf9c8000 ffff8800bf9d1d48 00000000001d6dc0
[ 8513.890025]  ffff8800bf9c8000 ffff8800bf9d1fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/3:1     S 00000000001d6dc0  3520   309      2 0x00000000
[ 8513.890025]  ffff88000f881d48 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff88000f998000 ffff88000f878000 ffff88000f881d48 00000000001d6dc0
[ 8513.890025]  ffff88000f878000 ffff88000f881fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/2:1     S 00000000001d6dc0  4240   312      2 0x00000000
[ 8513.890025]  ffff88000b467d48 0000000000000002 00000000001d6dc0 ffff88000b52b048
[ 8513.890025]  ffff8800bf96b000 ffff88000b52b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88000b52b000 ffff88000b467fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/0:1     S 00000000001d6dc0  5552   496      2 0x00000000
[ 8513.890025]  ffff8800bf9d5d48 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfad0000 ffff8800bfacb000 ffff8800bf9d5d48 00000000001d6dc0
[ 8513.890025]  ffff8800bfacb000 ffff8800bf9d5fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/4:1     S 00000000001d6dc0  4992  1159      2 0x00000000
[ 8513.890025]  ffff8800135d5d48 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfad3000 ffff880013583000 ffff8800135d5d48 00000000001d6dc0
[ 8513.890025]  ffff880013583000 ffff8800135d5fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] bdi-default     S 00000000001d6dc0  5784  2695      2 0x00000000
[ 8513.890025]  ffff8800be827c38 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bfb38000 ffff8800bfbeb000 ffff8800be827c38 00000000001d6dc0
[ 8513.890025]  ffff8800bfbeb000 ffff8800be827fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff81233ca9>] bdi_forker_thread+0x3c9/0x440
[ 8513.890025]  [<ffffffff812338e0>] ? bdi_clear_pending+0x20/0x20
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kintegrityd     S 00000000001d6dc0  6648  2696      2 0x00000000
[ 8513.890025]  ffff8800bfa71d28 0000000000000002 00000000001d6dc0 ffff8800bfbe8048
[ 8513.890025]  ffff8800bf968000 ffff8800bfbe8000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bfbe8000 ffff8800bfa71fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kblockd         S 00000000001d6dc0  6648  2697      2 0x00000000
[ 8513.890025]  ffff8800bfa73d28 0000000000000002 00000000001d6dc0 ffff880013473048
[ 8513.890025]  ffff8800bf968000 ffff880013473000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff880013473000 ffff8800bfa73fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] tifm            S 00000000001d6dc0  6496  2761      2 0x00000000
[ 8513.890025]  ffff8800bfaedd28 0000000000000002 00000000001d6dc0 ffff8800be878048
[ 8513.890025]  ffff8800bf968000 ffff8800be878000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800be878000 ffff8800bfaedfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] ata_sff         S 00000000001d6dc0  6496  2814      2 0x00000000
[ 8513.890025]  ffff8800bfa45d28 0000000000000002 00000000001d6dc0 ffff8800be87b048
[ 8513.890025]  ffff8800bf968000 ffff8800be87b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800be87b000 ffff8800bfa45fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] khubd           S 00000000001d6dc0  2848  2825      2 0x00000000
[ 8513.890025]  ffff8800bfa47d48 0000000000000002 ffff88000fbf2000 ffff88000fbf2000
[ 8513.890025]  ffff880007f0b000 ffff880013630000 ffff8800bfa47d48 00000000001d6dc0
[ 8513.890025]  ffff880013630000 ffff8800bfa47fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff82ca136d>] hub_thread+0xfd/0x1e0
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff82ca1270>] ? hub_events+0x6f0/0x6f0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] md              S 00000000001d6dc0  6496  2844      2 0x00000000
[ 8513.890025]  ffff8800be885d28 0000000000000002 00000000001d6dc0 ffff880013633048
[ 8513.890025]  ffff8800bf968000 ffff880013633000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff880013633000 ffff8800be885fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] devfreq_wq      S 00000000001d6dc0  6496  2850      2 0x00000000
[ 8513.890025]  ffff8800be887d28 0000000000000002 00000000001d6dc0 ffff88001355b048
[ 8513.890025]  ffff8800bf968000 ffff88001355b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88001355b000 ffff8800be887fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kworker/4:2     S 00000000001d6dc0  5216  2868      2 0x00000000
[ 8513.890025]  ffff88001368dd48 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff880013583000 ffff880013558000 ffff88001368dd48 00000000001d6dc0
[ 8513.890025]  ffff880013558000 ffff88001368dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8513.890025]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] cfg80211        S 00000000001d6dc0  6152  2869      2 0x00000000
[ 8513.890025]  ffff8800bfaf9d28 0000000000000002 00000000001d6dc0 ffff88001363b048
[ 8513.890025]  ffff8800bf96b000 ffff88001363b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88001363b000 ffff8800bfaf9fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rpciod          S 00000000001d6dc0  6248  2967      2 0x00000000
[ 8513.890025]  ffff8800bfa0bd28 0000000000000002 00000000001d6dc0 ffff880013638048
[ 8513.890025]  ffff8800bf968000 ffff880013638000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff880013638000 ffff8800bfa0bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kvm-irqfd-clean S 00000000001d6dc0  6248  2968      2 0x00000000
[ 8513.890025]  ffff8800bfb57d28 0000000000000002 00000000001d6dc0 ffff88000b573048
[ 8513.890025]  ffff8800bf968000 ffff88000b573000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88000b573000 ffff8800bfb57fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8513.890025]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8513.890025]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] pageattr-test   S ffff88001005a4c0  5376  2985      2 0x00000000
[ 8513.890025]  ffff8800bfa99cb8 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8513.890025]  ffff88000ac73000 ffff88000b570000 ffff8800bfa99cb8 00000000001d6dc0
[ 8513.890025]  ffff88000b570000 ffff8800bfa99fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff810af640>] ? pageattr_test+0x4a0/0x4a0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff810af65a>] do_pageattr_test+0x1a/0x50
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-0       S 00000000001d6dc0  6520  3086      2 0x00000000
[ 8513.890025]  ffff8800bfa37d78 0000000000000002 00000000001d6dc0 ffff88000b600048
[ 8513.890025]  ffff8800bf968000 ffff88000b600000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88000b600000 ffff8800bfa37fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-1       S 00000000001d6dc0  6520  3088      2 0x00000000
[ 8513.890025]  ffff8800bfbd1d78 0000000000000002 00000000001d6dc0 ffff8800135db048
[ 8513.890025]  ffff8800bf968000 ffff8800135db000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800135db000 ffff8800bfbd1fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-2       S 00000000001d6dc0  6520  3090      2 0x00000000
[ 8513.890025]  ffff8800bfbd3d78 0000000000000002 00000000001d6dc0 ffff8800135d8048
[ 8513.890025]  ffff8800bf968000 ffff8800135d8000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800135d8000 ffff8800bfbd3fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-3       S 00000000001d6dc0  6520  3092      2 0x00000000
[ 8513.890025]  ffff8800bfb49d78 0000000000000002 00000000001d6dc0 ffff88001350b048
[ 8513.890025]  ffff8800bf968000 ffff88001350b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff88001350b000 ffff8800bfb49fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-4       S 00000000001d6dc0  6376  3094      2 0x00000000
[ 8513.890025]  ffff8800bfa9dd78 0000000000000002 00000000001d6dc0 ffff880013508048
[ 8513.890025]  ffff8800bf96b000 ffff880013508000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff880013508000 ffff8800bfa9dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-5       S 00000000001d6dc0  6376  3096      2 0x00000000
[ 8513.890025]  ffff8800bfa9fd78 0000000000000002 00000000001d6dc0 ffff8800bf9f3048
[ 8513.890025]  ffff8800bf96b000 ffff8800bf9f3000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bf9f3000 ffff8800bfa9ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-6       S 00000000001d6dc0  6520  3098      2 0x00000000
[ 8513.890025]  ffff8800bfa9bd78 0000000000000002 00000000001d6dc0 ffff8800bf9f0048
[ 8513.890025]  ffff8800bf968000 ffff8800bf9f0000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bf9f0000 ffff8800bfa9bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rt-test-7       S 00000000001d6dc0  6520  3100      2 0x00000000
[ 8513.890025]  ffff8800bfb4bd78 0000000000000002 00000000001d6dc0 ffff8800be89b048
[ 8513.890025]  ffff8800bf968000 ffff8800be89b000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800be89b000 ffff8800bfb4bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff811924c0>] test_func+0xa0/0x110
[ 8513.890025]  [<ffffffff81192420>] ? handle_op+0x280/0x280
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] khungtaskd      S 00000000001d6dc0  5568  3102      2 0x00000000
[ 8513.890025]  ffff8800bfa35ca8 0000000000000002 ffff880007e1c000 ffff880007e1c000
[ 8513.890025]  ffff880010078000 ffff8800be898000 ffff8800bfa35ca8 00000000001d6dc0
[ 8513.890025]  ffff8800be898000 ffff8800bfa35fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81a127dd>] ? delay_tsc+0xdd/0x110
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811c7170>] ? check_hung_uninterruptible_tasks+0x390/0x390
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811c71b7>] watchdog+0x47/0x60
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_wri S 00000000001d6dc0  5760  3103      2 0x00000000
[ 8513.890025]  ffff8800bfa31c78 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf9fb000 ffff8800bfb38000 ffff8800bfa31c78 00000000001d6dc0
[ 8513.890025]  ffff8800bfb38000 ffff8800bfa31fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff811d07b0>] ? rcu_torture_free+0x50/0x50
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d14ad>] rcu_torture_writer+0x1cd/0x240
[ 8513.890025]  [<ffffffff811d12e0>] ? srcu_torture_stats+0x120/0x120
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_fak S 00000000001d6dc0  5512  3104      2 0x00000000
[ 8513.890025]  ffff8800bfa33c78 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bfb30000 ffff8800bfb3b000 ffff8800bfa33c78 00000000001d6dc0
[ 8513.890025]  ffff8800bfb3b000 ffff8800bfa33fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81a29b41>] ? debug_object_free+0x121/0x150
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811d0e20>] ? rcu_torture_barrier_cbs+0x1f0/0x1f0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d0f0f>] rcu_torture_fakewriter+0xef/0x160
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_fak S 00000000001d6dc0  5312  3105      2 0x00000000
[ 8513.890025]  ffff8800bfb4dc78 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bf9cb000 ffff8800bfadb000 ffff8800bfb4dc78 00000000001d6dc0
[ 8513.890025]  ffff8800bfadb000 ffff8800bfb4dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81a29b41>] ? debug_object_free+0x121/0x150
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811d0e20>] ? rcu_torture_barrier_cbs+0x1f0/0x1f0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d0f0f>] rcu_torture_fakewriter+0xef/0x160
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_fak S 00000000001d6dc0  5512  3106      2 0x00000000
[ 8513.890025]  ffff8800bfb4fc78 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfbc0000 ffff8800bfad8000 ffff8800bfb4fc78 00000000001d6dc0
[ 8513.890025]  ffff8800bfad8000 ffff8800bfb4ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81a29b41>] ? debug_object_free+0x121/0x150
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811d0e20>] ? rcu_torture_barrier_cbs+0x1f0/0x1f0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d0f0f>] rcu_torture_fakewriter+0xef/0x160
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_fak S 00000000001d6dc0  5512  3107      2 0x00000000
[ 8513.890025]  ffff8800bfb41c78 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfad8000 ffff8800bfad3000 ffff8800bfb41c78 00000000001d6dc0
[ 8513.890025]  ffff8800bfad3000 ffff8800bfb41fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81a29b41>] ? debug_object_free+0x121/0x150
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811d0e20>] ? rcu_torture_barrier_cbs+0x1f0/0x1f0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d0f0f>] rcu_torture_fakewriter+0xef/0x160
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S ffff8800002d94c0  5624  3108      2 0x00000000
[ 8513.890025]  ffff8800bfb43bc8 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8513.890025]  ffff8800be4b0000 ffff8800bfad0000 ffff8800bfb43bc8 00000000001d6dc0
[ 8513.890025]  ffff8800bfad0000 ffff8800bfb43fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3109      2 0x00000000
[ 8513.890025]  ffff8800bfb45bc8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bfac8000 ffff8800bf9f8000 ffff8800bfb45bc8 00000000001d6dc0
[ 8513.890025]  ffff8800bf9f8000 ffff8800bfb45fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3110      2 0x00000000
[ 8513.890025]  ffff8800bfb47bc8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfad0000 ffff8800bf9fb000 ffff8800bfb47bc8 00000000001d6dc0
[ 8513.890025]  ffff8800bf9fb000 ffff8800bfb47fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3111      2 0x00000000
[ 8513.890025]  ffff8800be829bc8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bf9f8000 ffff8800bf9cb000 ffff8800be829bc8 00000000001d6dc0
[ 8513.890025]  ffff8800bf9cb000 ffff8800be829fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3112      2 0x00000000
[ 8513.890025]  ffff8800be82bbc8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfad3000 ffff8800bfbc0000 ffff8800be82bbc8 00000000001d6dc0
[ 8513.890025]  ffff8800bfbc0000 ffff8800be82bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3113      2 0x00000000
[ 8513.890025]  ffff8800be82dbc8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfadb000 ffff8800bfbc3000 ffff8800be82dbc8 00000000001d6dc0
[ 8513.890025]  ffff8800bfbc3000 ffff8800be82dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3114      2 0x00000000
[ 8513.890025]  ffff8800be82fbc8 0000000000000002 00000000001d6dc0 ffff8800bfac8048
[ 8513.890025]  ffff8800bf968000 ffff8800bfac8000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bfac8000 ffff8800be82ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3115      2 0x00000000
[ 8513.890025]  ffff8800bfaf1bc8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfbc0000 ffff8800be890000 ffff8800bfaf1bc8 00000000001d6dc0
[ 8513.890025]  ffff8800be890000 ffff8800bfaf1fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3116      2 0x00000000
[ 8513.890025]  ffff8800bfaf3bc8 0000000000000002 00000000001d6dc0 ffff8800be893048
[ 8513.890025]  ffff8800bf97b000 ffff8800be893000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800be893000 ffff8800bfaf3fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_rea S 00000000001d6dc0  5624  3117      2 0x00000000
[ 8513.890025]  ffff8800bfaf5bc8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bfadb000 ffff8800bfb30000 ffff8800bfaf5bc8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb30000 ffff8800bfaf5fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d00f6>] rcu_stutter_wait+0x26/0x70
[ 8513.890025]  [<ffffffff811d2cce>] rcu_torture_reader+0x33e/0x430
[ 8513.890025]  [<ffffffff811d2dc0>] ? rcu_torture_reader+0x430/0x430
[ 8513.890025]  [<ffffffff811d2990>] ? rcutorture_trace_dump+0x40/0x40
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_sta S ffff8800100604c0  5864  3118      2 0x00000000
[ 8513.890025]  ffff8800bfaf7cb8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8513.890025]  ffff8800be4b0000 ffff8800bfb33000 ffff8800bfaf7cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb33000 ffff8800bfaf7fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811d1a60>] ? rcu_torture_stats_print+0x20/0x20
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d1a9e>] rcu_torture_stats+0x3e/0x90
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_shu S 00000000001d6dc0  5384  3119      2 0x00000000
[ 8513.890025]  ffff8800bfa11cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800be893000 ffff8800bfb10000 ffff8800bfa11cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb10000 ffff8800bfa11fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811d28c0>] ? rcu_torture_shuffle_tasks+0x220/0x220
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d2900>] rcu_torture_shuffle+0x40/0x90
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] rcu_torture_stu S 00000000001d6dc0  5864  3120      2 0x00000000
[ 8513.890025]  ffff8800bfa13cb8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff880012c80000 ffff8800bfb13000 ffff8800bfa13cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb13000 ffff8800bfa13fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8513.890025]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8513.890025]  [<ffffffff811d0020>] ? rcu_torture_deferred_free+0x20/0x20
[ 8513.890025]  [<ffffffff83ce2259>] schedule_timeout_interruptible+0x19/0x20
[ 8513.890025]  [<ffffffff811d0087>] rcu_torture_stutter+0x67/0xb0
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd0         S 00000000001d6dc0  4136  3125      2 0x00000000
[ 8513.890025]  ffff8800bfa15cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800be860000 ffff8800bfb08000 ffff8800bfa15cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb08000 ffff8800bfa15fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd1         S 00000000001d6dc0  4136  3126      2 0x00000000
[ 8513.890025]  ffff8800bfa17cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800be868000 ffff8800bfb0b000 ffff8800bfa17cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb0b000 ffff8800bfa17fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd2         S 00000000001d6dc0  4048  3127      2 0x00000000
[ 8513.890025]  ffff8800bfa89cb8 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8513.890025]  ffff8800bfad8000 ffff8800bfa48000 ffff8800bfa89cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa48000 ffff8800bfa89fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd3         S 00000000001d6dc0  4136  3128      2 0x00000000
[ 8513.890025]  ffff8800bfa8bcb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bf948000 ffff8800bfa4b000 ffff8800bfa8bcb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa4b000 ffff8800bfa8bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd4         S 00000000001d6dc0  4136  3129      2 0x00000000
[ 8513.890025]  ffff8800bfa8dcb8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfad0000 ffff8800be840000 ffff8800bfa8dcb8 00000000001d6dc0
[ 8513.890025]  ffff8800be840000 ffff8800bfa8dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd5         S 00000000001d6dc0  3824  3130      2 0x00000000
[ 8513.890025]  ffff8800bfa8fcb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bfa7b000 ffff8800be843000 ffff8800bfa8fcb8 00000000001d6dc0
[ 8513.890025]  ffff8800be843000 ffff8800bfa8ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd6         S 00000000001d6dc0  3584  3131      2 0x00000000
[ 8513.890025]  ffff8800bfbf1cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800be860000 ffff8800bfa78000 ffff8800bfbf1cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa78000 ffff8800bfbf1fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd7         S 00000000001d6dc0  4136  3132      2 0x00000000
[ 8513.890025]  ffff8800bfbf3cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bf9f8000 ffff8800bfa7b000 ffff8800bfbf3cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa7b000 ffff8800bfbf3fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd8         S 00000000001d6dc0  4136  3133      2 0x00000000
[ 8513.890025]  ffff8800bfbf5cb8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfbc0000 ffff8800bfb20000 ffff8800bfbf5cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb20000 ffff8800bfbf5fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd9         S 00000000001d6dc0  4136  3134      2 0x00000000
[ 8513.890025]  ffff8800bfbf7cb8 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8513.890025]  ffff8800bfbc3000 ffff8800bfb23000 ffff8800bfbf7cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb23000 ffff8800bfbf7fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd10        S 00000000001d6dc0  4136  3135      2 0x00000000
[ 8513.890025]  ffff8800bfab1cb8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800be893000 ffff8800bfb28000 ffff8800bfab1cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb28000 ffff8800bfab1fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd11        S 00000000001d6dc0  4136  3136      2 0x00000000
[ 8513.890025]  ffff8800bfab3cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf948000 ffff8800bfb2b000 ffff8800bfab3cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb2b000 ffff8800bfab3fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd12        S 00000000001d6dc0  4136  3137      2 0x00000000
[ 8513.890025]  ffff8800bfab5cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bf9f8000 ffff8800bfab8000 ffff8800bfab5cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfab8000 ffff8800bfab5fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd13        S 00000000001d6dc0  3712  3138      2 0x00000000
[ 8513.890025]  ffff8800bfab7cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfad0000 ffff8800bfabb000 ffff8800bfab7cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfabb000 ffff8800bfab7fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd14        S 00000000001d6dc0  4136  3139      2 0x00000000
[ 8513.890025]  ffff8800be859cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfad0000 ffff8800be850000 ffff8800be859cb8 00000000001d6dc0
[ 8513.890025]  ffff8800be850000 ffff8800be859fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd15        S 00000000001d6dc0  4136  3140      2 0x00000000
[ 8513.890025]  ffff8800be85bcb8 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8513.890025]  ffff8800bfbc3000 ffff8800be853000 ffff8800be85bcb8 00000000001d6dc0
[ 8513.890025]  ffff8800be853000 ffff8800be85bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd16        S ffff88001c0224c0  4136  3141      2 0x00000000
[ 8513.890025]  ffff8800be85dcb8 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8513.890025]  ffff8800be030000 ffff8800be860000 ffff8800be85dcb8 00000000001d6dc0
[ 8513.890025]  ffff8800be860000 ffff8800be85dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd17        S 00000000001d6dc0  3840  3142      2 0x00000000
[ 8513.890025]  ffff8800be85fcb8 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8513.890025]  ffff8800bfb38000 ffff8800be863000 ffff8800be85fcb8 00000000001d6dc0
[ 8513.890025]  ffff8800be863000 ffff8800be85ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd18        S 00000000001d6dc0  4136  3143      2 0x00000000
[ 8513.890025]  ffff8800bf9e1cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8513.890025]  ffff8800bfad3000 ffff8800be868000 ffff8800bf9e1cb8 00000000001d6dc0
[ 8513.890025]  ffff8800be868000 ffff8800bf9e1fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd19        S 00000000001d6dc0  4136  3144      2 0x00000000
[ 8513.890025]  ffff8800bf9e3cb8 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8513.890025]  ffff8800bfb38000 ffff8800be86b000 ffff8800bf9e3cb8 00000000001d6dc0
[ 8513.890025]  ffff8800be86b000 ffff8800bf9e3fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd20        S 00000000001d6dc0  4496  3145      2 0x00000000
[ 8513.890025]  ffff8800bf9e5cb8 0000000000000002 00000000001d6dc0 ffff8800bf9e8048
[ 8513.890025]  ffff8800bf96b000 ffff8800bf9e8000 00000000001d6dc0 00000000001d6dc0
[ 8513.890025]  ffff8800bf9e8000 ffff8800bf9e5fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd21        S 00000000001d6dc0  5864  3146      2 0x00000000
[ 8513.890025]  ffff8800bf9e7cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfa6b000 ffff8800bf9eb000 ffff8800bf9e7cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bf9eb000 ffff8800bf9e7fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd22        S 00000000001d6dc0  5864  3147      2 0x00000000
[ 8513.890025]  ffff8800bfa51cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800be86b000 ffff8800bfa68000 ffff8800bfa51cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa68000 ffff8800bfa51fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd23        S 00000000001d6dc0  5864  3148      2 0x00000000
[ 8513.890025]  ffff8800bfa53cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfa5b000 ffff8800bfa6b000 ffff8800bfa53cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa6b000 ffff8800bfa53fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd24        S 00000000001d6dc0  5864  3149      2 0x00000000
[ 8513.890025]  ffff8800bfa55cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfa20000 ffff8800bfa58000 ffff8800bfa55cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa58000 ffff8800bfa55fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd25        S 00000000001d6dc0  5864  3150      2 0x00000000
[ 8513.890025]  ffff8800bfa57cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfbb0000 ffff8800bfa5b000 ffff8800bfa57cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa5b000 ffff8800bfa57fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd26        S 00000000001d6dc0  5864  3151      2 0x00000000
[ 8513.890025]  ffff8800bfa29cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfbb3000 ffff8800bfa20000 ffff8800bfa29cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa20000 ffff8800bfa29fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd27        S 00000000001d6dc0  5864  3152      2 0x00000000
[ 8513.890025]  ffff8800bfa2bcb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bf9e8000 ffff8800bfa23000 ffff8800bfa2bcb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfa23000 ffff8800bfa2bfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd28        S 00000000001d6dc0  5864  3153      2 0x00000000
[ 8513.890025]  ffff8800bfa2dcb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfbb8000 ffff8800bfbb0000 ffff8800bfa2dcb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfbb0000 ffff8800bfa2dfd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd29        S 00000000001d6dc0  5864  3154      2 0x00000000
[ 8513.890025]  ffff8800bfa2fcb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfbbb000 ffff8800bfbb3000 ffff8800bfa2fcb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfbb3000 ffff8800bfa2ffd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd30        S 00000000001d6dc0  5864  3155      2 0x00000000
[ 8513.890025]  ffff8800be831cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800be83b000 ffff8800bfbb8000 ffff8800be831cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfbb8000 ffff8800be831fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd31        S 00000000001d6dc0  5864  3156      2 0x00000000
[ 8513.890025]  ffff8800be833cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfb60000 ffff8800bfbbb000 ffff8800be833cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfbbb000 ffff8800be833fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd32        S 00000000001d6dc0  5864  3157      2 0x00000000
[ 8513.890025]  ffff8800be835cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfa68000 ffff8800be838000 ffff8800be835cb8 00000000001d6dc0
[ 8513.890025]  ffff8800be838000 ffff8800be835fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd33        S 00000000001d6dc0  5864  3158      2 0x00000000
[ 8513.890025]  ffff8800be837cb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8513.890025]  ffff8800bfb63000 ffff8800be83b000 ffff8800be837cb8 00000000001d6dc0
[ 8513.890025]  ffff8800be83b000 ffff8800be837fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8513.890025] kswapd34        S 00000000001d6dc0  5864  3159      2 0x00000000
[ 8513.890025]  ffff8800bfb69cb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8513.890025]  ffff8800bfb78000 ffff8800bfb60000 ffff8800bfb69cb8 00000000001d6dc0
[ 8513.890025]  ffff8800bfb60000 ffff8800bfb69fd8 00000000001d6dc0 00000000001d6dc0
[ 8513.890025] Call Trace:
[ 8513.890025]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8513.890025]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8513.890025]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8513.890025]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8513.890025]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8513.890025]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8513.890025]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8513.890025]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd35        S 00000000001d6dc0  5864  3160      2 0x00000000
[ 8515.610064]  ffff8800bfb6bcb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8515.610064]  ffff8800bfb7b000 ffff8800bfb63000 ffff8800bfb6bcb8 00000000001d6dc0
[ 8515.610064]  ffff8800bfb63000 ffff8800bfb6bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd36        S 00000000001d6dc0  5864  3161      2 0x00000000
[ 8515.610064]  ffff8800bfb6dcb8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8515.610064]  ffff8800be838000 ffff8800bfb78000 ffff8800bfb6dcb8 00000000001d6dc0
[ 8515.610064]  ffff8800bfb78000 ffff8800bfb6dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd37        S 00000000001d6dc0  5864  3162      2 0x00000000
[ 8515.610064]  ffff8800bfb6fcb8 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8515.610064]  ffff8800bfa23000 ffff8800bfb7b000 ffff8800bfb6fcb8 00000000001d6dc0
[ 8515.610064]  ffff8800bfb7b000 ffff8800bfb6ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd38        S 00000000001d6dc0  6104  3163      2 0x00000000
[ 8515.610064]  ffff8800be809cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be803000 ffff8800be800000 ffff8800be809cb8 00000000001d6dc0
[ 8515.610064]  ffff8800be800000 ffff8800be809fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd39        S 00000000001d6dc0  6104  3164      2 0x00000000
[ 8515.610064]  ffff8800be80bcb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be810000 ffff8800be803000 ffff8800be80bcb8 00000000001d6dc0
[ 8515.610064]  ffff8800be803000 ffff8800be80bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd40        S 00000000001d6dc0  6104  3165      2 0x00000000
[ 8515.610064]  ffff8800be80dcb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be813000 ffff8800be810000 ffff8800be80dcb8 00000000001d6dc0
[ 8515.610064]  ffff8800be810000 ffff8800be80dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd41        S 00000000001d6dc0  6104  3166      2 0x00000000
[ 8515.610064]  ffff8800be80fcb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be818000 ffff8800be813000 ffff8800be80fcb8 00000000001d6dc0
[ 8515.610064]  ffff8800be813000 ffff8800be80ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd42        S 00000000001d6dc0  6104  3167      2 0x00000000
[ 8515.610064]  ffff8800bfb81cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be81b000 ffff8800be818000 ffff8800bfb81cb8 00000000001d6dc0
[ 8515.610064]  ffff8800be818000 ffff8800bfb81fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd43        S 00000000001d6dc0  6104  3168      2 0x00000000
[ 8515.610064]  ffff8800bfb83cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800bfb88000 ffff8800be81b000 ffff8800bfb83cb8 00000000001d6dc0
[ 8515.610064]  ffff8800be81b000 ffff8800bfb83fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd44        S 00000000001d6dc0  6104  3169      2 0x00000000
[ 8515.610064]  ffff8800bfb85cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800bfb8b000 ffff8800bfb88000 ffff8800bfb85cb8 00000000001d6dc0
[ 8515.610064]  ffff8800bfb88000 ffff8800bfb85fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd45        S 00000000001d6dc0  6104  3170      2 0x00000000
[ 8515.610064]  ffff8800bfb87cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800bfb90000 ffff8800bfb8b000 ffff8800bfb87cb8 00000000001d6dc0
[ 8515.610064]  ffff8800bfb8b000 ffff8800bfb87fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd46        S 00000000001d6dc0  6104  3171      2 0x00000000
[ 8515.610064]  ffff8800bfb99cb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800bfb93000 ffff8800bfb90000 ffff8800bfb99cb8 00000000001d6dc0
[ 8515.610064]  ffff8800bfb90000 ffff8800bfb99fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd47        S 00000000001d6dc0  6104  3172      2 0x00000000
[ 8515.610064]  ffff8800bfb9bcb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be8a0000 ffff8800bfb93000 ffff8800bfb9bcb8 00000000001d6dc0
[ 8515.610064]  ffff8800bfb93000 ffff8800bfb9bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd48        S 00000000001d6dc0  6104  3173      2 0x00000000
[ 8515.610064]  ffff8800bfb9dcb8 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be8a3000 ffff8800be8a0000 ffff8800bfb9dcb8 00000000001d6dc0
[ 8515.610064]  ffff8800be8a0000 ffff8800bfb9dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kswapd49        S 00000000001d6dc0  6104  3174      2 0x00000000
[ 8515.610064]  ffff8800bfb9fcb8 0000000000000002 00000000001d6dc0 ffff8800be8a3048
[ 8515.610064]  ffff8800bf968000 ffff8800be8a3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be8a3000 ffff8800bfb9ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8122589d>] kswapd_try_to_sleep+0x26d/0x320
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8122980b>] kswapd+0xfb/0x320
[ 8515.610064]  [<ffffffff81229710>] ? balance_pgdat+0x670/0x670
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ksmd            D 00000000001d6dc0  4880  3175      2 0x00000000
[ 8515.610064]  ffff8800be8b9b70 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff880008010000 ffff8800be8b0000 ffff8800be8b9b70 00000000001d6dc0
[ 8515.610064]  ffff8800be8b0000 ffff8800be8b9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4ca5>] rwsem_down_read_failed+0x15/0x17
[ 8515.610064]  [<ffffffff81a139a4>] call_rwsem_down_read_failed+0x14/0x30
[ 8515.610064]  [<ffffffff83ce3349>] ? down_read+0x79/0x8e
[ 8515.610064]  [<ffffffff81263fda>] ? unstable_tree_search_insert+0x6a/0x1e0
[ 8515.610064]  [<ffffffff81263fda>] unstable_tree_search_insert+0x6a/0x1e0
[ 8515.610064]  [<ffffffff812654f7>] cmp_and_merge_page+0xe7/0x1e0
[ 8515.610064]  [<ffffffff81265655>] ksm_do_scan+0x65/0xa0
[ 8515.610064]  [<ffffffff812656ff>] ksm_scan_thread+0x6f/0x2d0
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff81265690>] ? ksm_do_scan+0xa0/0xa0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] khugepaged      S 00000000001d6dc0  5144  3257      2 0x00000000
[ 8515.610064]  ffff8800be8bdc48 0000000000000002 00000000001d6dc0 ffff8800be8b3048
[ 8515.610064]  ffff8800bf96b000 ffff8800be8b3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be8b3000 ffff8800be8bdfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8515.610064]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8515.610064]  [<ffffffff812751e5>] khugepaged_wait_work+0x145/0x330
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff812764f0>] ? khugepaged_do_scan+0x1a0/0x1a0
[ 8515.610064]  [<ffffffff8127651a>] khugepaged+0x2a/0x70
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fsnotify_mark   S 00000000001d6dc0  6432  3259      2 0x00000000
[ 8515.610064]  ffff8800be8bfd28 0000000000000002 00000000001d6dc0 ffff8800136eb048
[ 8515.610064]  ffff8800bf968000 ffff8800136eb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800136eb000 ffff8800be8bffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff812d1874>] fsnotify_mark_destroy+0x164/0x190
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff812d1710>] ? fsnotify_put_mark+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ecryptfs-kthrea S 00000000001d6dc0  6456  3301      2 0x00000000
[ 8515.610064]  ffff8800be8c7d38 0000000000000002 00000000001d6dc0 ffff8800136e8048
[ 8515.610064]  ffff8800bf968000 ffff8800136e8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800136e8000 ffff8800be8c7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff8144aae0>] ? ecryptfs_destroy_ecryptfs_miscdev+0x20/0x20
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8144abd5>] ecryptfs_threadfn+0xf5/0x220
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8144aae0>] ? ecryptfs_destroy_ecryptfs_miscdev+0x20/0x20
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] nfsiod          S 00000000001d6dc0  6424  3304      2 0x00000000
[ 8515.610064]  ffff8800be8c9d28 0000000000000002 00000000001d6dc0 ffff880013700048
[ 8515.610064]  ffff8800bf968000 ffff880013700000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013700000 ffff8800be8c9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] cifsiod         S 00000000001d6dc0  6248  3312      2 0x00000000
[ 8515.610064]  ffff8800be8cbd28 0000000000000002 00000000001d6dc0 ffff880013703048
[ 8515.610064]  ffff8800bf968000 ffff880013703000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013703000 ffff8800be8cbfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] jfsIO           S 00000000001d6dc0  6392  3338      2 0x00000000
[ 8515.610064]  ffff8800be8f5d78 0000000000000002 00000000001d6dc0 ffff880013618048
[ 8515.610064]  ffff8800bf968000 ffff880013618000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013618000 ffff8800be8f5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff816120b8>] jfsIOWait+0xe8/0x130
[ 8515.610064]  [<ffffffff81611fd0>] ? lmLogClose+0x160/0x160
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] jfsCommit       S 00000000001d6dc0  6320  3339      2 0x00000000
[ 8515.610064]  ffff8800be8f7d48 0000000000000002 00000000001d6dc0 ffff880013793048
[ 8515.610064]  ffff8800bf96b000 ffff880013793000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013793000 ffff8800be8f7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81615e7f>] jfs_lazycommit+0x19f/0x220
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] jfsCommit       S 00000000001d6dc0  6472  3340      2 0x00000000
[ 8515.610064]  ffff8800be8f9d48 0000000000000002 00000000001d6dc0 ffff880013790048
[ 8515.610064]  ffff8800bf968000 ffff880013790000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013790000 ffff8800be8f9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81615e7f>] jfs_lazycommit+0x19f/0x220
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] jfsCommit       S 00000000001d6dc0  6472  3341      2 0x00000000
[ 8515.610064]  ffff8800be8fbd48 0000000000000002 00000000001d6dc0 ffff8800135a8048
[ 8515.610064]  ffff8800bf968000 ffff8800135a8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800135a8000 ffff8800be8fbfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81615e7f>] jfs_lazycommit+0x19f/0x220
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] jfsCommit       S 00000000001d6dc0  6472  3342      2 0x00000000
[ 8515.610064]  ffff8800be8fdd48 0000000000000002 00000000001d6dc0 ffff8800135ab048
[ 8515.610064]  ffff8800bf968000 ffff8800135ab000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800135ab000 ffff8800be8fdfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81615e7f>] jfs_lazycommit+0x19f/0x220
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] jfsCommit       S 00000000001d6dc0  6472  3343      2 0x00000000
[ 8515.610064]  ffff8800be8ffd48 0000000000000002 00000000001d6dc0 ffff88000b578048
[ 8515.610064]  ffff8800bf968000 ffff88000b578000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b578000 ffff8800be8fffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81615e7f>] jfs_lazycommit+0x19f/0x220
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff81615ce0>] ? txCommit+0x390/0x390
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] jfsSync         S 00000000001d6dc0  6520  3344      2 0x00000000
[ 8515.610064]  ffff8800be901d78 0000000000000002 00000000001d6dc0 ffff88000b57b048
[ 8515.610064]  ffff8800bf968000 ffff88000b57b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b57b000 ffff8800be901fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81616319>] jfs_sync+0x209/0x250
[ 8515.610064]  [<ffffffff81616110>] ? txResume+0x30/0x30
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] xfsalloc        S 00000000001d6dc0  6248  3353      2 0x00000000
[ 8515.610064]  ffff8800be905d28 0000000000000002 00000000001d6dc0 ffff88000b500048
[ 8515.610064]  ffff8800bf968000 ffff88000b500000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b500000 ffff8800be905fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] xfs_mru_cache   S 00000000001d6dc0  6248  3354      2 0x00000000
[ 8515.610064]  ffff8800be907d28 0000000000000002 00000000001d6dc0 ffff88000b503048
[ 8515.610064]  ffff8800bf968000 ffff88000b503000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b503000 ffff8800be907fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] xfslogd         S 00000000001d6dc0  6424  3355      2 0x00000000
[ 8515.610064]  ffff8800be911d28 0000000000000002 00000000001d6dc0 ffff88000b613048
[ 8515.610064]  ffff8800bf968000 ffff88000b613000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b613000 ffff8800be911fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ocfs2_wq        S 00000000001d6dc0  6424  3364      2 0x00000000
[ 8515.610064]  ffff8800be913d28 0000000000000002 00000000001d6dc0 ffff88000b610048
[ 8515.610064]  ffff8800bf968000 ffff88000b610000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b610000 ffff8800be913fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] user_dlm        S 00000000001d6dc0  6424  3367      2 0x00000000
[ 8515.610064]  ffff8800be915d28 0000000000000002 00000000001d6dc0 ffff8800135cb048
[ 8515.610064]  ffff8800bf968000 ffff8800135cb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800135cb000 ffff8800be915fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] glock_workqueue S 00000000001d6dc0  6424  3379      2 0x00000000
[ 8515.610064]  ffff8800be91bd28 0000000000000002 00000000001d6dc0 ffff8800135c8048
[ 8515.610064]  ffff8800bf968000 ffff8800135c8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800135c8000 ffff8800be91bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] delete_workqueu S 00000000001d6dc0  6248  3380      2 0x00000000
[ 8515.610064]  ffff8800be91dd28 0000000000000002 00000000001d6dc0 ffff88001359b048
[ 8515.610064]  ffff8800bf968000 ffff88001359b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88001359b000 ffff8800be91dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] gfs_recovery    S 00000000001d6dc0  6424  3388      2 0x00000000
[ 8515.610064]  ffff8800be91fd28 0000000000000002 00000000001d6dc0 ffff880013598048
[ 8515.610064]  ffff8800bf968000 ffff880013598000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013598000 ffff8800be91ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] crypto          S 00000000001d6dc0  6424  3395      2 0x00000000
[ 8515.610064]  ffff8800be923d28 0000000000000002 00000000001d6dc0 ffff8800136d3048
[ 8515.610064]  ffff8800bf968000 ffff8800136d3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800136d3000 ffff8800be923fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] pencrypt        S 00000000001d6dc0  6424  3417      2 0x00000000
[ 8515.610064]  ffff8800be967d28 0000000000000002 00000000001d6dc0 ffff8800be970048
[ 8515.610064]  ffff8800bf968000 ffff8800be970000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be970000 ffff8800be967fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] pdecrypt        S 00000000001d6dc0  6424  3419      2 0x00000000
[ 8515.610064]  ffff8800be979d28 0000000000000002 00000000001d6dc0 ffff8800be973048
[ 8515.610064]  ffff8800bf968000 ffff8800be973000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be973000 ffff8800be979fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kthrotld        S 00000000001d6dc0  6120  3451      2 0x00000000
[ 8515.610064]  ffff8800be9f5d28 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800bfb38000 ffff8800be9f8000 ffff8800be9f5d28 00000000001d6dc0
[ 8515.610064]  ffff8800be9f8000 ffff8800be9f5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] vballoon        S 00000000001d6dc0  6376  3579      2 0x00000000
[ 8515.610064]  ffff8800be97bd28 0000000000000002 00000000001d6dc0 ffff8800be9fb048
[ 8515.610064]  ffff8800bf97b000 ffff8800be9fb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be9fb000 ffff8800be97bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81bea619>] balloon+0x189/0x290
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff81bea490>] ? virtballoon_migratepage+0x150/0x150
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] cciss_scan      S 00000000001d6dc0  6520  4486      2 0x00000000
[ 8515.610064]  ffff8800be963d78 0000000000000002 00000000001d6dc0 ffff880007998048
[ 8515.610064]  ffff8800bf968000 ffff880007998000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007998000 ffff8800be963fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff81f209a0>] ? cciss_init_one+0x840/0x840
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81f209dd>] scan_thread+0x3d/0xf0
[ 8515.610064]  [<ffffffff81f209a0>] ? cciss_init_one+0x840/0x840
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] nvme            S 00000000001d6dc0  5800  4492      2 0x00000000
[ 8515.610064]  ffff8800be97dc78 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8515.610064]  ffff8800bfad3000 ffff88000799b000 ffff8800be97dc78 00000000001d6dc0
[ 8515.610064]  ffff88000799b000 ffff8800be97dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8515.610064]  [<ffffffff81f34b1e>] nvme_kthread+0xfe/0x120
[ 8515.610064]  [<ffffffff81f34a20>] ? nvme_resubmit_bios+0xd0/0xd0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] drbd-reissue    S 00000000001d6dc0  6424  4532      2 0x00000000
[ 8515.610064]  ffff8800bea93d28 0000000000000002 00000000001d6dc0 ffff88000f8bb048
[ 8515.610064]  ffff8800bf968000 ffff88000f8bb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000f8bb000 ffff8800bea93fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_eh        S 00000000001d6dc0  6424  4619      2 0x00000000
[ 8515.610064]  ffff8800beaa3d28 0000000000000002 00000000001d6dc0 ffff8800bea13048
[ 8515.610064]  ffff8800bf968000 ffff8800bea13000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800bea13000 ffff8800beaa3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kmpath_rdacd    S 00000000001d6dc0  6424  4628      2 0x00000000
[ 8515.610064]  ffff8800bea99d28 0000000000000002 00000000001d6dc0 ffff8800beab3048
[ 8515.610064]  ffff8800bf968000 ffff8800beab3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beab3000 ffff8800bea99fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fc_exch_workque S 00000000001d6dc0  6424  4629      2 0x00000000
[ 8515.610064]  ffff8800bea95d28 0000000000000002 00000000001d6dc0 ffff880007a70048
[ 8515.610064]  ffff8800bf968000 ffff880007a70000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007a70000 ffff8800bea95fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fc_rport_eq     S 00000000001d6dc0  6424  4630      2 0x00000000
[ 8515.610064]  ffff8800bea97d28 0000000000000002 00000000001d6dc0 ffff880007a73048
[ 8515.610064]  ffff8800bf968000 ffff880007a73000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007a73000 ffff8800bea97fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fcoethread/0    S 00000000001d6dc0  6392  4631      2 0x00000000
[ 8515.610064]  ffff8800bead1d08 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8515.610064]  ffff8800bf908000 ffff8800beac8000 ffff8800bead1d08 00000000001d6dc0
[ 8515.610064]  ffff8800beac8000 ffff8800bead1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82047057>] fcoe_percpu_receive_thread+0x117/0x1d0
[ 8515.610064]  [<ffffffff82046f40>] ? fcoe_recv_frame+0x3d0/0x3d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fcoethread/1    S 00000000001d6dc0  6392  4632      2 0x00000000
[ 8515.610064]  ffff880007b09d08 0000000000000002 00000000001d6dc0 ffff880007b23048
[ 8515.610064]  ffff8800bf968000 ffff880007b23000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007b23000 ffff880007b09fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82047057>] fcoe_percpu_receive_thread+0x117/0x1d0
[ 8515.610064]  [<ffffffff82046f40>] ? fcoe_recv_frame+0x3d0/0x3d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fcoethread/2    S 00000000001d6dc0  6216  4633      2 0x00000000
[ 8515.610064]  ffff88000b68fd08 0000000000000002 00000000001d6dc0 ffff88000b563048
[ 8515.610064]  ffff8800bf96b000 ffff88000b563000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b563000 ffff88000b68ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82047057>] fcoe_percpu_receive_thread+0x117/0x1d0
[ 8515.610064]  [<ffffffff82046f40>] ? fcoe_recv_frame+0x3d0/0x3d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fcoethread/3    S 00000000001d6dc0  6376  4634      2 0x00000000
[ 8515.610064]  ffff88000fa6bd08 0000000000000002 00000000001d6dc0 ffff88000f8b8048
[ 8515.610064]  ffff8800bf978000 ffff88000f8b8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000f8b8000 ffff88000fa6bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82047057>] fcoe_percpu_receive_thread+0x117/0x1d0
[ 8515.610064]  [<ffffffff82046f40>] ? fcoe_recv_frame+0x3d0/0x3d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fcoethread/4    S 00000000001d6dc0  6392  4635      2 0x00000000
[ 8515.610064]  ffff880012c61d08 0000000000000002 00000000001d6dc0 ffff880013720048
[ 8515.610064]  ffff8800bf97b000 ffff880013720000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013720000 ffff880012c61fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82047057>] fcoe_percpu_receive_thread+0x117/0x1d0
[ 8515.610064]  [<ffffffff82046f40>] ? fcoe_recv_frame+0x3d0/0x3d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] fnic_event_wq   S 00000000001d6dc0  6424  4638      2 0x00000000
[ 8515.610064]  ffff8800bead3d28 0000000000000002 00000000001d6dc0 ffff8800beae3048
[ 8515.610064]  ffff8800bf968000 ffff8800beae3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beae3000 ffff8800bead3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2fc_l2_threa S 00000000001d6dc0  6488  4640      2 0x00000000
[ 8515.610064]  ffff8800bead7d68 0000000000000002 00000000001d6dc0 ffff8800beaeb048
[ 8515.610064]  ffff8800bf968000 ffff8800beaeb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beaeb000 ffff8800bead7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8205df25>] bnx2fc_l2_rcv_thread+0x55/0xf0
[ 8515.610064]  [<ffffffff8205ded0>] ? bnx2fc_recv_frame+0x330/0x330
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2fc_thread/0 S 00000000001d6dc0  6440  4641      2 0x00000000
[ 8515.610064]  ffff8800beaf9d38 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8515.610064]  ffff8800bf908000 ffff8800beaf0000 ffff8800beaf9d38 00000000001d6dc0
[ 8515.610064]  ffff8800beaf0000 ffff8800beaf9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8205d8c3>] bnx2fc_percpu_io_thread+0x63/0x170
[ 8515.610064]  [<ffffffff8205d860>] ? bnx2fc_cpu_callback+0x90/0x90
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2fc_thread/1 S 00000000001d6dc0  6440  4642      2 0x00000000
[ 8515.610064]  ffff880007b29d38 0000000000000002 00000000001d6dc0 ffff880007b20048
[ 8515.610064]  ffff8800bf968000 ffff880007b20000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007b20000 ffff880007b29fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8205d8c3>] bnx2fc_percpu_io_thread+0x63/0x170
[ 8515.610064]  [<ffffffff8205d860>] ? bnx2fc_cpu_callback+0x90/0x90
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2fc_thread/2 S 00000000001d6dc0  6264  4643      2 0x00000000
[ 8515.610064]  ffff88000b71dd38 0000000000000002 00000000001d6dc0 ffff88000b560048
[ 8515.610064]  ffff8800bf96b000 ffff88000b560000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b560000 ffff88000b71dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8205d8c3>] bnx2fc_percpu_io_thread+0x63/0x170
[ 8515.610064]  [<ffffffff8205d860>] ? bnx2fc_cpu_callback+0x90/0x90
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2fc_thread/3 S 00000000001d6dc0  6264  4644      2 0x00000000
[ 8515.610064]  ffff88000fa6dd38 0000000000000002 00000000001d6dc0 ffff88000f8a8048
[ 8515.610064]  ffff8800bf978000 ffff88000f8a8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000f8a8000 ffff88000fa6dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8205d8c3>] bnx2fc_percpu_io_thread+0x63/0x170
[ 8515.610064]  [<ffffffff8205d860>] ? bnx2fc_cpu_callback+0x90/0x90
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2fc_thread/4 S 00000000001d6dc0  6440  4645      2 0x00000000
[ 8515.610064]  ffff880012c63d38 0000000000000002 00000000001d6dc0 ffff880013723048
[ 8515.610064]  ffff8800bf97b000 ffff880013723000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013723000 ffff880012c63fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8205d8c3>] bnx2fc_percpu_io_thread+0x63/0x170
[ 8515.610064]  [<ffffffff8205d860>] ? bnx2fc_cpu_callback+0x90/0x90
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] tcm_qla2xxx_fre S 00000000001d6dc0  6424  4659      2 0x00000000
[ 8515.610064]  ffff8800bead5d28 0000000000000002 00000000001d6dc0 ffff8800beaf3048
[ 8515.610064]  ffff8800bf968000 ffff8800beaf3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beaf3000 ffff8800bead5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2i_thread/0  S 00000000001d6dc0  6440  4691      2 0x00000000
[ 8515.610064]  ffff8800beaabd38 0000000000000002 00000000001d6dc0 ffff8800be9db048
[ 8515.610064]  ffffffff8542f440 ffff8800be9db000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be9db000 ffff8800beaabfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff822bd854>] bnx2i_percpu_io_thread+0x134/0x170
[ 8515.610064]  [<ffffffff822bd720>] ? bnx2i_indicate_kcqe+0x310/0x310
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2i_thread/1  S 00000000001d6dc0  6440  4692      2 0x00000000
[ 8515.610064]  ffff880007a29d38 0000000000000002 00000000001d6dc0 ffff880007bf3048
[ 8515.610064]  ffff8800bf968000 ffff880007bf3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007bf3000 ffff880007a29fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff822bd854>] bnx2i_percpu_io_thread+0x134/0x170
[ 8515.610064]  [<ffffffff822bd720>] ? bnx2i_indicate_kcqe+0x310/0x310
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2i_thread/2  S 00000000001d6dc0  6440  4693      2 0x00000000
[ 8515.610064]  ffff88000b71fd38 0000000000000002 00000000001d6dc0 ffff88000b528048
[ 8515.610064]  ffff8800bf96b000 ffff88000b528000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b528000 ffff88000b71ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff822bd854>] bnx2i_percpu_io_thread+0x134/0x170
[ 8515.610064]  [<ffffffff822bd720>] ? bnx2i_indicate_kcqe+0x310/0x310
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2i_thread/3  S 00000000001d6dc0  6120  4694      2 0x00000000
[ 8515.610064]  ffff88000fa73d38 0000000000000002 00000000001d6dc0 ffff88000f8ab048
[ 8515.610064]  ffff8800bf978000 ffff88000f8ab000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000f8ab000 ffff88000fa73fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff822bd854>] bnx2i_percpu_io_thread+0x134/0x170
[ 8515.610064]  [<ffffffff822bd720>] ? bnx2i_indicate_kcqe+0x310/0x310
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2i_thread/4  S 00000000001d6dc0  6392  4695      2 0x00000000
[ 8515.610064]  ffff880012c65d38 0000000000000002 00000000001d6dc0 ffff880012c98048
[ 8515.610064]  ffff8800bf97b000 ffff880012c98000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880012c98000 ffff880012c65fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff822bd854>] bnx2i_percpu_io_thread+0x134/0x170
[ 8515.610064]  [<ffffffff822bd720>] ? bnx2i_indicate_kcqe+0x310/0x310
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] scsi_eh_0       S 00000000001d6dc0  6520  4718      2 0x00000000
[ 8515.610064]  ffff8800beaffd78 0000000000000002 00000000001d6dc0 ffff8800be993048
[ 8515.610064]  ffff8800bf968000 ffff8800be993000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be993000 ffff8800beafffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82002195>] scsi_error_handler+0x85/0x1b0
[ 8515.610064]  [<ffffffff82002110>] ? scsi_unjam_host+0x1d0/0x1d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] scsi_eh_1       S 00000000001d6dc0  5368  4801      2 0x00000000
[ 8515.610064]  ffff8800beac1d78 0000000000000002 00000000001d6dc0 ffff8800be990048
[ 8515.610064]  ffff8800bf968000 ffff8800be990000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be990000 ffff8800beac1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82002195>] scsi_error_handler+0x85/0x1b0
[ 8515.610064]  [<ffffffff82002110>] ? scsi_unjam_host+0x1d0/0x1d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] scsi_eh_2       S 00000000001d6dc0  5368  4818      2 0x00000000
[ 8515.610064]  ffff8800bea9fd78 0000000000000002 00000000001d6dc0 ffff8800beab8048
[ 8515.610064]  ffff8800bf968000 ffff8800beab8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beab8000 ffff8800bea9ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82002195>] scsi_error_handler+0x85/0x1b0
[ 8515.610064]  [<ffffffff82002110>] ? scsi_unjam_host+0x1d0/0x1d0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] target_completi S 00000000001d6dc0  6376  4828      2 0x00000000
[ 8515.610064]  ffff8800beac3d28 0000000000000002 00000000001d6dc0 ffff8800beabb048
[ 8515.610064]  ffff8800bf968000 ffff8800beabb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beabb000 ffff8800beac3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] tmr-rd_mcp      S 00000000001d6dc0  5976  4829      2 0x00000000
[ 8515.610064]  ffff8800beac5d28 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800bfbc3000 ffff8800be998000 ffff8800beac5d28 00000000001d6dc0
[ 8515.610064]  ffff8800be998000 ffff8800beac5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_ttx       S 00000000001d6dc0  6040  4832      2 0x00000000
[ 8515.610064]  ffff8800beac7b98 0000000000000002 00000000001d6dc0 ffff8800beacb048
[ 8515.610064]  ffff8800bf96b000 ffff8800beacb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beacb000 ffff8800beac7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bccd>] iscsi_tx_thread_pre_handler+0xbd/0x150
[ 8515.610064]  [<ffffffff82391870>] iscsi_target_tx_thread+0x40/0x160
[ 8515.610064]  [<ffffffff82391830>] ? handle_response_queue+0x2e0/0x2e0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_trx       S 00000000001d6dc0  6008  4833      2 0x00000000
[ 8515.610064]  ffff8800beb1db78 0000000000000002 00000000001d6dc0 ffff8800be988048
[ 8515.610064]  ffff8800bf968000 ffff8800be988000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be988000 ffff8800beb1dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bba5>] iscsi_rx_thread_pre_handler+0xb5/0x120
[ 8515.610064]  [<ffffffff823904cc>] iscsi_target_rx_thread+0x5c/0x470
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff82390470>] ? iscsit_thread_get_cpumask+0x180/0x180
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_ttx       S 00000000001d6dc0  6040  4834      2 0x00000000
[ 8515.610064]  ffff8800beb1fb98 0000000000000002 00000000001d6dc0 ffff8800be98b048
[ 8515.610064]  ffff8800bf968000 ffff8800be98b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be98b000 ffff8800beb1ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bccd>] iscsi_tx_thread_pre_handler+0xbd/0x150
[ 8515.610064]  [<ffffffff82391870>] iscsi_target_tx_thread+0x40/0x160
[ 8515.610064]  [<ffffffff82391830>] ? handle_response_queue+0x2e0/0x2e0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_trx       S 00000000001d6dc0  6008  4835      2 0x00000000
[ 8515.610064]  ffff8800beb11b78 0000000000000002 00000000001d6dc0 ffff8800bea10048
[ 8515.610064]  ffff8800bf968000 ffff8800bea10000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800bea10000 ffff8800beb11fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bba5>] iscsi_rx_thread_pre_handler+0xb5/0x120
[ 8515.610064]  [<ffffffff823904cc>] iscsi_target_rx_thread+0x5c/0x470
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff82390470>] ? iscsit_thread_get_cpumask+0x180/0x180
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_ttx       S 00000000001d6dc0  6040  4836      2 0x00000000
[ 8515.610064]  ffff8800beb13b98 0000000000000002 00000000001d6dc0 ffff8800beae0048
[ 8515.610064]  ffff8800bf968000 ffff8800beae0000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beae0000 ffff8800beb13fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bccd>] iscsi_tx_thread_pre_handler+0xbd/0x150
[ 8515.610064]  [<ffffffff82391870>] iscsi_target_tx_thread+0x40/0x160
[ 8515.610064]  [<ffffffff82391830>] ? handle_response_queue+0x2e0/0x2e0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_trx       S 00000000001d6dc0  6008  4837      2 0x00000000
[ 8515.610064]  ffff8800be981b78 0000000000000002 00000000001d6dc0 ffff8800beae8048
[ 8515.610064]  ffff8800bf968000 ffff8800beae8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beae8000 ffff8800be981fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bba5>] iscsi_rx_thread_pre_handler+0xb5/0x120
[ 8515.610064]  [<ffffffff823904cc>] iscsi_target_rx_thread+0x5c/0x470
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff82390470>] ? iscsit_thread_get_cpumask+0x180/0x180
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_ttx       S 00000000001d6dc0  6040  4838      2 0x00000000
[ 8515.610064]  ffff8800be983b98 0000000000000002 00000000001d6dc0 ffff8800beab0048
[ 8515.610064]  ffff8800bf968000 ffff8800beab0000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800beab0000 ffff8800be983fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bccd>] iscsi_tx_thread_pre_handler+0xbd/0x150
[ 8515.610064]  [<ffffffff82391870>] iscsi_target_tx_thread+0x40/0x160
[ 8515.610064]  [<ffffffff82391830>] ? handle_response_queue+0x2e0/0x2e0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iscsi_trx       S 00000000001d6dc0  6008  4839      2 0x00000000
[ 8515.610064]  ffff8800be985b78 0000000000000002 00000000001d6dc0 ffff8800be9d8048
[ 8515.610064]  ffff8800bf968000 ffff8800be9d8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be9d8000 ffff8800be985fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce37b8>] wait_for_completion_interruptible+0x18/0x30
[ 8515.610064]  [<ffffffff8237bba5>] iscsi_rx_thread_pre_handler+0xb5/0x120
[ 8515.610064]  [<ffffffff823904cc>] iscsi_target_rx_thread+0x5c/0x470
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff82390470>] ? iscsit_thread_get_cpumask+0x180/0x180
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] smflush         S 00000000001d6dc0  6424  4845      2 0x00000000
[ 8515.610064]  ffff8800be987d28 0000000000000002 00000000001d6dc0 ffff880012c9b048
[ 8515.610064]  ffff8800bf968000 ffff880012c9b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880012c9b000 ffff8800be987fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bond0           S 00000000001d6dc0  6392  4900      2 0x00000000
[ 8515.610064]  ffff8800beba1d28 0000000000000006 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff880007bab000 ffff880012cbb000 ffff8800beba1d28 00000000001d6dc0
[ 8515.610064]  ffff880012cbb000 ffff8800beba1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] cnic_wq         S 00000000001d6dc0  6248  5062      2 0x00000000
[ 8515.610064]  ffff8800be40bd28 0000000000000002 00000000001d6dc0 ffff880012cb8048
[ 8515.610064]  ffff8800bf96b000 ffff880012cb8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880012cb8000 ffff8800be40bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bnx2x           S 00000000001d6dc0  6376  5063      2 0x00000000
[ 8515.610064]  ffff8800be40dd28 0000000000000002 00000000001d6dc0 ffff880013470048
[ 8515.610064]  ffff8800bf96b000 ffff880013470000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013470000 ffff8800be40dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] cxgb4           S 00000000001d6dc0  6376  5070      2 0x00000000
[ 8515.610064]  ffff8800be40fd28 0000000000000002 00000000001d6dc0 ffff88001379b048
[ 8515.610064]  ffff8800bf96b000 ffff88001379b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88001379b000 ffff8800be40ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] mlx4            S 00000000001d6dc0  6248  5102      2 0x00000000
[ 8515.610064]  ffff8800be411d28 0000000000000002 00000000001d6dc0 ffff880013798048
[ 8515.610064]  ffff8800bf968000 ffff880013798000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880013798000 ffff8800be411fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] qlcnic          S 00000000001d6dc0  6392  5119      2 0x00000000
[ 8515.610064]  ffff8800be413d28 0000000000000006 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff880007bb3000 ffff8800136d0000 ffff8800be413d28 00000000001d6dc0
[ 8515.610064]  ffff8800136d0000 ffff8800be413fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] sfc_vfdi        S 00000000001d6dc0  6248  5130      2 0x00000000
[ 8515.610064]  ffff8800be415d28 0000000000000002 00000000001d6dc0 ffff8800be418048
[ 8515.610064]  ffff8800bf968000 ffff8800be418000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be418000 ffff8800be415fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] sfc_reset       S 00000000001d6dc0  6248  5131      2 0x00000000
[ 8515.610064]  ffff8800be417d28 0000000000000002 00000000001d6dc0 ffff8800be41b048
[ 8515.610064]  ffff8800bf968000 ffff8800be41b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be41b000 ffff8800be417fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] irda_sir_wq     S 00000000001d6dc0  6392  5202      2 0x00000000
[ 8515.610064]  ffff88000795dd28 0000000000000006 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff8800076c3000 ffff880007738000 ffff88000795dd28 00000000001d6dc0
[ 8515.610064]  ffff880007738000 ffff88000795dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] zd1211rw        S 00000000001d6dc0  6392  5237      2 0x00000000
[ 8515.610064]  ffff8800079f3d28 0000000000000006 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff8800076fb000 ffff8800076f8000 ffff8800079f3d28 00000000001d6dc0
[ 8515.610064]  ffff8800076f8000 ffff8800079f3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] libertastf      S 00000000001d6dc0  5976  5254      2 0x00000000
[ 8515.610064]  ffff8800076e7d28 0000000000000006 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff88000776b000 ffff880007650000 ffff8800076e7d28 00000000001d6dc0
[ 8515.610064]  ffff880007650000 ffff8800076e7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] wpan-phy1       S 00000000001d6dc0  6504  5311      2 0x00000000
[ 8515.610064]  ffff8800077b7d28 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8515.610064]  ffff8800be893000 ffff88000765b000 ffff8800077b7d28 00000000001d6dc0
[ 8515.610064]  ffff88000765b000 ffff8800077b7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] exec-osm        S 00000000001d6dc0  6376  5358      2 0x00000000
[ 8515.610064]  ffff8800079f1d28 0000000000000002 00000000001d6dc0 ffff8800078c0048
[ 8515.610064]  ffff8800bf96b000 ffff8800078c0000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800078c0000 ffff8800079f1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] block-osm       S 00000000001d6dc0  6248  5365      2 0x00000000
[ 8515.610064]  ffff8800077d3d28 0000000000000002 00000000001d6dc0 ffff88000770b048
[ 8515.610064]  ffff8800bf96b000 ffff88000770b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000770b000 ffff8800077d3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] firewire        S 00000000001d6dc0  6376  5373      2 0x00000000
[ 8515.610064]  ffff880007769d28 0000000000000002 00000000001d6dc0 ffff880007758048
[ 8515.610064]  ffff8800bf96b000 ffff880007758000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007758000 ffff880007769fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] vfio-irqfd-clea S 00000000001d6dc0  6376  5392      2 0x00000000
[ 8515.610064]  ffff880007747d28 0000000000000002 00000000001d6dc0 ffff8800076e8048
[ 8515.610064]  ffff8800bf96b000 ffff8800076e8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800076e8000 ffff880007747fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] aoe_tx          S 00000000001d6dc0  5504  5403      2 0x00000000
[ 8515.610064]  ffff8800076c7d68 0000000000000002 00000000001d6dc0 ffff8800076cb048
[ 8515.610064]  ffff8800bf96b000 ffff8800076cb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800076cb000 ffff8800076c7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff82c88750>] ? bio_pageinc+0x80/0x80
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82c887e9>] kthread+0x99/0xf0
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] aoe_ktio        S 00000000001d6dc0  6296  5404      2 0x00000000
[ 8515.610064]  ffff880007779d68 0000000000000002 00000000001d6dc0 ffff880007770048
[ 8515.610064]  ffff8800bf96b000 ffff880007770000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007770000 ffff880007779fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff82c88750>] ? bio_pageinc+0x80/0x80
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82c887e9>] kthread+0x99/0xf0
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] u132            S 00000000001d6dc0  6376  5433      2 0x00000000
[ 8515.610064]  ffff8800077d5d28 0000000000000002 00000000001d6dc0 ffff880007658048
[ 8515.610064]  ffff8800bf96b000 ffff880007658000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007658000 ffff8800077d5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] wusbd           S 00000000001d6dc0  6376  5441      2 0x00000000
[ 8515.610064]  ffff8800076c5d28 0000000000000002 00000000001d6dc0 ffff8800076fb048
[ 8515.610064]  ffff8800bf96b000 ffff8800076fb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800076fb000 ffff8800076c5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] appledisplay    S 00000000001d6dc0  6248  5586      2 0x00000000
[ 8515.610064]  ffff8800076c1d28 0000000000000002 00000000001d6dc0 ffff880007773048
[ 8515.610064]  ffff8800bf968000 ffff880007773000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007773000 ffff8800076c1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ftdi-status-con S 00000000001d6dc0  6376  5592      2 0x00000000
[ 8515.610064]  ffff88000769fd28 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff8800be890000 ffff88000778b000 ffff88000769fd28 00000000001d6dc0
[ 8515.610064]  ffff88000778b000 ffff88000769ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ftdi-command-en S 00000000001d6dc0  5976  5593      2 0x00000000
[ 8515.610064]  ffff88000777bd28 0000000000000006 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff88000b603000 ffff880007700000 ffff88000777bd28 00000000001d6dc0
[ 8515.610064]  ffff880007700000 ffff88000777bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ftdi-respond-en S 00000000001d6dc0  6248  5594      2 0x00000000
[ 8515.610064]  ffff880007727d28 0000000000000002 00000000001d6dc0 ffff88000b603048
[ 8515.610064]  ffff8800bf968000 ffff88000b603000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b603000 ffff880007727fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kworker/2:2     S 00000000001d6dc0  6392  5664      2 0x00000000
[ 8515.610064]  ffff88000acc5d48 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff88000b52b000 ffff88000ac8b000 ffff88000acc5d48 00000000001d6dc0
[ 8515.610064]  ffff88000ac8b000 ffff88000acc5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8515.610064]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kpsmoused       S 00000000001d6dc0  6248  5684      2 0x00000000
[ 8515.610064]  ffff880007745d28 0000000000000002 00000000001d6dc0 ffff88000ac88048
[ 8515.610064]  ffff8800bf968000 ffff88000ac88000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000ac88000 ffff880007745fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] rc0             S 00000000001d6dc0  6392  5905      2 0x00000000
[ 8515.610064]  ffff880007695d58 0000000000000006 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff88000ac70000 ffff88000acb0000 ffff880007695d58 00000000001d6dc0
[ 8515.610064]  ffff88000acb0000 ffff880007695fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff82f87519>] ir_raw_event_thread+0x89/0x130
[ 8515.610064]  [<ffffffff82f87490>] ? ir_raw_handler_register+0x90/0x90
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] pvrusb2-context S 00000000001d6dc0  6488  6010      2 0x00000000
[ 8515.610064]  ffff8800077b1d58 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff8800be890000 ffff88000acb3000 ffff8800077b1d58 00000000001d6dc0
[ 8515.610064]  ffff88000acb3000 ffff8800077b1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83079375>] pvr2_context_thread_func+0xd5/0x240
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff830792a0>] ? pvr2_context_check+0x120/0x120
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kworker/1:2     S 00000000001d6dc0  5536  6044      2 0x00000000
[ 8515.610064]  ffff88000776bd48 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800be893000 ffff880007653000 ffff88000776bd48 00000000001d6dc0
[ 8515.610064]  ffff880007653000 ffff88000776bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8515.610064]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] dm_bufio_cache  S 00000000001d6dc0  6248  6185      2 0x00000000
[ 8515.610064]  ffff8800077d1d28 0000000000000002 00000000001d6dc0 ffff8800077eb048
[ 8515.610064]  ffff8800bf968000 ffff8800077eb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800077eb000 ffff8800077d1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kdelayd         S 00000000001d6dc0  6424  6186      2 0x00000000
[ 8515.610064]  ffff8800077b3d28 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff8800be890000 ffff8800077e8000 ffff8800077b3d28 00000000001d6dc0
[ 8515.610064]  ffff8800077e8000 ffff8800077b3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kmpathd         S 00000000001d6dc0  6248  6187      2 0x00000000
[ 8515.610064]  ffff8800077abd28 0000000000000002 00000000001d6dc0 ffff88000ac70048
[ 8515.610064]  ffff8800bf968000 ffff88000ac70000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000ac70000 ffff8800077abfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kmpath_handlerd S 00000000001d6dc0  6424  6188      2 0x00000000
[ 8515.610064]  ffff880007711d28 0000000000000002 ffff88000bdd6e78 ffff88000bdd6e78
[ 8515.610064]  ffff8800be890000 ffff88000ad08000 ffff880007711d28 00000000001d6dc0
[ 8515.610064]  ffff88000ad08000 ffff880007711fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] edac-poller     S 00000000001d6dc0  6424  6297      2 0x00000000
[ 8515.610064]  ffff880007959d28 0000000000000002 00000000001d6dc0 ffff88000772b048
[ 8515.610064]  ffff8800bf96b000 ffff88000772b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000772b000 ffff880007959fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kvub300c        S 00000000001d6dc0  6424  6326      2 0x00000000
[ 8515.610064]  ffff88000795bd28 0000000000000002 00000000001d6dc0 ffff880007728048
[ 8515.610064]  ffff8800bf96b000 ffff880007728000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007728000 ffff88000795bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kvub300p        S 00000000001d6dc0  6424  6327      2 0x00000000
[ 8515.610064]  ffff880007735d28 0000000000000002 00000000001d6dc0 ffff88000f8c3048
[ 8515.610064]  ffff8800bf96b000 ffff88000f8c3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000f8c3000 ffff880007735fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kvub300d        S 00000000001d6dc0  6424  6328      2 0x00000000
[ 8515.610064]  ffff880007737d28 0000000000000002 00000000001d6dc0 ffff88000f8c0048
[ 8515.610064]  ffff8800bf96b000 ffff88000f8c0000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000f8c0000 ffff880007737fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kmemstick       S 00000000001d6dc0  6424  6332      2 0x00000000
[ 8515.610064]  ffff880007bb1d28 0000000000000002 00000000001d6dc0 ffff8800be458048
[ 8515.610064]  ffff8800bf96b000 ffff8800be458000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be458000 ffff880007bb1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ib_mcast        S 00000000001d6dc0  6248  6361      2 0x00000000
[ 8515.610064]  ffff880007bb3d28 0000000000000002 00000000001d6dc0 ffff8800be45b048
[ 8515.610064]  ffff8800bf96b000 ffff8800be45b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be45b000 ffff880007bb3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ib_cm           S 00000000001d6dc0  6376  6363      2 0x00000000
[ 8515.610064]  ffff88000776dd28 0000000000000002 00000000001d6dc0 ffff8800078c3048
[ 8515.610064]  ffff8800bf96b000 ffff8800078c3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800078c3000 ffff88000776dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iw_cm_wq        S 00000000001d6dc0  6376  6364      2 0x00000000
[ 8515.610064]  ffff88000776fd28 0000000000000002 00000000001d6dc0 ffff88000771b048
[ 8515.610064]  ffff8800bf96b000 ffff88000771b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000771b000 ffff88000776ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ib_addr         S 00000000001d6dc0  6376  6365      2 0x00000000
[ 8515.610064]  ffff8800079f5d28 0000000000000002 00000000001d6dc0 ffff880007718048
[ 8515.610064]  ffff8800bf96b000 ffff880007718000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007718000 ffff8800079f5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] rdma_cm         S 00000000001d6dc0  6376  6366      2 0x00000000
[ 8515.610064]  ffff8800079f7d28 0000000000000002 00000000001d6dc0 ffff88000773b048
[ 8515.610064]  ffff8800bf96b000 ffff88000773b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000773b000 ffff8800079f7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] mthca_catas     S 00000000001d6dc0  6376  6369      2 0x00000000
[ 8515.610064]  ffff880007791d28 0000000000000002 00000000001d6dc0 ffff880007788048
[ 8515.610064]  ffff8800bf96b000 ffff880007788000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007788000 ffff880007791fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] qib_cq          S 00000000001d6dc0  6376  6373      2 0x00000000
[ 8515.610064]  ffff880007793d28 0000000000000002 00000000001d6dc0 ffff880007708048
[ 8515.610064]  ffff8800bf96b000 ffff880007708000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007708000 ffff880007793fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iw_cxgb3        S 00000000001d6dc0  6376  6376      2 0x00000000
[ 8515.610064]  ffff880007795d28 0000000000000002 00000000001d6dc0 ffff8800076c8048
[ 8515.610064]  ffff8800bf96b000 ffff8800076c8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800076c8000 ffff880007795fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] iw_cxgb4        S 00000000001d6dc0  6376  6377      2 0x00000000
[ 8515.610064]  ffff880007797d28 0000000000000002 00000000001d6dc0 ffff88000775b048
[ 8515.610064]  ffff8800bf96b000 ffff88000775b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000775b000 ffff880007797fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] mlx4_ib         S 00000000001d6dc0  6376  6378      2 0x00000000
[ 8515.610064]  ffff880007681d28 0000000000000002 00000000001d6dc0 ffff880007bf0048
[ 8515.610064]  ffff8800bf96b000 ffff880007bf0000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007bf0000 ffff880007681fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] mlx4_ib_mcg     S 00000000001d6dc0  6376  6379      2 0x00000000
[ 8515.610064]  ffff880007683d28 0000000000000002 00000000001d6dc0 ffff880007703048
[ 8515.610064]  ffff8800bf96b000 ffff880007703000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007703000 ffff880007683fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] nesewq          S 00000000001d6dc0  6376  6380      2 0x00000000
[ 8515.610064]  ffff880007685d28 0000000000000002 00000000001d6dc0 ffff8800be498048
[ 8515.610064]  ffff8800bf96b000 ffff8800be498000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be498000 ffff880007685fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] nesdwq          S 00000000001d6dc0  6376  6381      2 0x00000000
[ 8515.610064]  ffff880007687d28 0000000000000002 00000000001d6dc0 ffff8800be49b048
[ 8515.610064]  ffff8800bf96b000 ffff8800be49b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be49b000 ffff880007687fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] ipoib           S 00000000001d6dc0  6376  6383      2 0x00000000
[ 8515.610064]  ffff880007af1d28 0000000000000002 00000000001d6dc0 ffff8800076eb048
[ 8515.610064]  ffff8800bf96b000 ffff8800076eb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800076eb000 ffff880007af1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] speakup         S 00000000001d6dc0  6272  6569      2 0x00000000
[ 8515.610064]  ffff880007bbdd38 0000000000000002 00000000001d6dc0 ffff88000789b048
[ 8515.610064]  ffff8800bf96b000 ffff88000789b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000789b000 ffff880007bbdfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff8360f7a8>] speakup_thread+0x198/0x1b0
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8360f610>] ? synth_init+0xe0/0xe0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] binder          S 00000000001d6dc0  6424  6572      2 0x00000000
[ 8515.610064]  ffff880007bbfd28 0000000000000002 00000000001d6dc0 ffff8800be50b048
[ 8515.610064]  ffff8800bf96b000 ffff8800be50b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be50b000 ffff880007bbffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] k_mode_wimax    S 00000000001d6dc0  6168  6589      2 0x00000000
[ 8515.610064]  ffff8800076f7c18 0000000000000002 00000000001d6dc0 ffff8800be508048
[ 8515.610064]  ffff8800bf96b000 ffff8800be508000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be508000 ffff8800076f7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff8118972a>] ? lock_release_nested+0xaa/0xe0
[ 8515.610064]  [<ffffffff83ce351d>] ? sleep_on_common+0x5d/0xa0
[ 8515.610064]  [<ffffffff81189841>] ? __lock_release+0xe1/0x100
[ 8515.610064]  [<ffffffff83ce351d>] ? sleep_on_common+0x5d/0xa0
[ 8515.610064]  [<ffffffff83ce3525>] sleep_on_common+0x65/0xa0
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff8362c030>] ? do_pm_control+0x100/0x100
[ 8515.610064]  [<ffffffff83ce35d8>] interruptible_sleep_on+0x18/0x20
[ 8515.610064]  [<ffffffff8362c1b8>] k_mode_thread+0x188/0x1b0
[ 8515.610064]  [<ffffffff8362c030>] ? do_pm_control+0x100/0x100
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kpktgend_0      S 00000000001d6dc0  5704  6663      2 0x00000000
[ 8515.610064]  ffff8800be5fbc18 0000000000000002 ffff8800bfdd6e78 ffff8800bfdd6e78
[ 8515.610064]  ffff8800bf9fb000 ffff8800be5c8000 ffff8800be5fbc18 00000000001d6dc0
[ 8515.610064]  ffff8800be5c8000 ffff8800be5fbfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8515.610064]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8515.610064]  [<ffffffff83736d6a>] pktgen_thread_worker+0x1fa/0x550
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff83736b70>] ? pktgen_run+0x1b0/0x1b0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kpktgend_1      S 00000000001d6dc0  5704  6664      2 0x00000000
[ 8515.610064]  ffff880007ba5c18 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
[ 8515.610064]  ffff8800bf9f8000 ffff880007ba8000 ffff880007ba5c18 00000000001d6dc0
[ 8515.610064]  ffff880007ba8000 ffff880007ba5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8515.610064]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8515.610064]  [<ffffffff83736d6a>] pktgen_thread_worker+0x1fa/0x550
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff83736b70>] ? pktgen_run+0x1b0/0x1b0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kpktgend_2      S 00000000001d6dc0  5704  6665      2 0x00000000
[ 8515.610064]  ffff88000ad07c18 0000000000000002 00000000001d6dc0 ffff88000ad0b048
[ 8515.610064]  ffff8800bf96b000 ffff88000ad0b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000ad0b000 ffff88000ad07fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8515.610064]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8515.610064]  [<ffffffff83736d6a>] pktgen_thread_worker+0x1fa/0x550
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff83736b70>] ? pktgen_run+0x1b0/0x1b0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kpktgend_3      S 00000000001d6dc0  5704  6666      2 0x00000000
[ 8515.610064]  ffff88000f073c18 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8515.610064]  ffff8800be893000 ffff88000f998000 ffff88000f073c18 00000000001d6dc0
[ 8515.610064]  ffff88000f998000 ffff88000f073fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8515.610064]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8515.610064]  [<ffffffff83736d6a>] pktgen_thread_worker+0x1fa/0x550
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff83736b70>] ? pktgen_run+0x1b0/0x1b0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kpktgend_4      S 00000000001d6dc0  5704  6667      2 0x00000000
[ 8515.610064]  ffff880012d9bc18 0000000000000002 ffff880013dd6e78 ffff880013dd6e78
[ 8515.610064]  ffff8800bfbc0000 ffff880012c80000 ffff880012d9bc18 00000000001d6dc0
[ 8515.610064]  ffff880012c80000 ffff880012d9bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce214e>] schedule_timeout+0x2be/0x370
[ 8515.610064]  [<ffffffff81121550>] ? cascade+0xa0/0xa0
[ 8515.610064]  [<ffffffff83736d6a>] pktgen_thread_worker+0x1fa/0x550
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff8113f980>] ? wake_up_bit+0x40/0x40
[ 8515.610064]  [<ffffffff83736b70>] ? pktgen_run+0x1b0/0x1b0
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] krdsd           S 00000000001d6dc0  6424  6792      2 0x00000000
[ 8515.610064]  ffff8800077f3d28 0000000000000002 00000000001d6dc0 ffff880007e78048
[ 8515.610064]  ffff8800bf96b000 ffff880007e78000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e78000 ffff8800077f3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] bat_events      S 00000000001d6dc0  6376  6795      2 0x00000000
[ 8515.610064]  ffff880007f75d28 0000000000000002 00000000001d6dc0 ffff880007e7b048
[ 8515.610064]  ffff8800bf97b000 ffff880007e7b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e7b000 ffff880007f75fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kafs_vlupdated  S 00000000001d6dc0  6376  6807      2 0x00000000
[ 8515.610064]  ffff880007f73d28 0000000000000002 00000000001d6dc0 ffff880007bab048
[ 8515.610064]  ffff8800bf96b000 ffff880007bab000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007bab000 ffff880007f73fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kafs_callbackd  S 00000000001d6dc0  6376  6808      2 0x00000000
[ 8515.610064]  ffff8800077f5d28 0000000000000002 00000000001d6dc0 ffff880007e43048
[ 8515.610064]  ffff8800bf96b000 ffff880007e43000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e43000 ffff8800077f5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] kafsd           S 00000000001d6dc0  6376  6809      2 0x00000000
[ 8515.610064]  ffff8800077f7d28 0000000000000002 00000000001d6dc0 ffff880007e40048
[ 8515.610064]  ffff8800bf96b000 ffff880007e40000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e40000 ffff8800077f7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] deferwq         S 00000000001d6dc0  6376  6830      2 0x00000000
[ 8515.610064]  ffff880007f41d28 0000000000000002 00000000001d6dc0 ffff880007e4b048
[ 8515.610064]  ffff8800bf96b000 ffff880007e4b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e4b000 ffff880007f41fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] charger_manager S 00000000001d6dc0  6376  6836      2 0x00000000
[ 8515.610064]  ffff880007f43d28 0000000000000002 00000000001d6dc0 ffff880007e48048
[ 8515.610064]  ffff8800bf96b000 ffff880007e48000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e48000 ffff880007f43fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff811347ca>] rescuer_thread+0x2aa/0x2d0
[ 8515.610064]  [<ffffffff83ce3b55>] ? __schedule+0x355/0x3b0
[ 8515.610064]  [<ffffffff81134520>] ? process_scheduled_works+0x40/0x40
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] sh              S 00000000001d6dc0  3880  6842      1 0x00000000
[ 8515.610064]  ffff8800be44fde8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800be64b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be64b000 ffff8800be44ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81115615>] do_wait+0x2b5/0x3b0
[ 8515.610064]  [<ffffffff8111682b>] sys_wait4+0xbb/0xe0
[ 8515.610064]  [<ffffffff81113590>] ? put_task_struct+0x20/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] runtrin.sh      S 00000000001d6dc0  4376  6843   6842 0x00000000
[ 8515.610064]  ffff8800be43bde8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800be648000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be648000 ffff8800be43bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81115615>] do_wait+0x2b5/0x3b0
[ 8515.610064]  [<ffffffff8111682b>] sys_wait4+0xbb/0xe0
[ 8515.610064]  [<ffffffff81113590>] ? put_task_struct+0x20/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] irqbalance      S 00000000001d6dc0  4312  6845      1 0x00000000
[ 8515.610064]  ffff8800be487de8 0000000000000002 ffff88000fdd6e78 ffff88000fdd6e78
[ 8515.610064]  ffff8800bfb30000 ffff8800be4b3000 ffff8800be487de8 00000000001d6dc0
[ 8515.610064]  ffff8800be4b3000 ffff8800be487fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce2fac>] do_nanosleep+0x7c/0xd0
[ 8515.610064]  [<ffffffff8123b9fe>] ? might_fault+0x4e/0xa0
[ 8515.610064]  [<ffffffff811451a7>] hrtimer_nanosleep+0xd7/0x180
[ 8515.610064]  [<ffffffff811435d0>] ? update_rmtp+0x70/0x70
[ 8515.610064]  [<ffffffff81144acf>] ? hrtimer_start_range_ns+0xf/0x20
[ 8515.610064]  [<ffffffff811452be>] sys_nanosleep+0x6e/0x80
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] kworker/0:1H    S 00000000001d6dc0  6392  6847      2 0x00000000
[ 8515.610064]  ffff8800be533d48 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff8800be4b0000 ffff8800be628000 ffff8800be533d48 00000000001d6dc0
[ 8515.610064]  ffff8800be628000 ffff8800be533fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81135005>] worker_thread+0x385/0x3b0
[ 8515.610064]  [<ffffffff81134c80>] ? manage_workers+0x110/0x110
[ 8515.610064]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
[ 8515.610064]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
[ 8515.610064] rngd            D ffff8800a37434c0  4024  6849   6843 0x00000000
[ 8515.610064]  ffff8800be5a5c38 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff8800be4b0000 ffff8800be620000 ffff8800be5a5c38 00000000001d6dc0
[ 8515.610064]  ffff8800be620000 ffff8800be5a5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff811868d9>] ? mark_held_locks+0xf9/0x130
[ 8515.610064]  [<ffffffff83ce36d3>] ? wait_for_common+0xf3/0x170
[ 8515.610064]  [<ffffffff83ce560b>] ? _raw_spin_unlock_irq+0x2b/0x80
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff83ce36db>] wait_for_common+0xfb/0x170
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff83ce3778>] wait_for_completion_killable+0x18/0x30
[ 8515.610064]  [<ffffffff81ca2556>] virtio_read+0xa6/0xd0
[ 8515.610064]  [<ffffffff81ca185b>] rng_dev_read+0x9b/0x200
[ 8515.610064]  [<ffffffff8128ad65>] vfs_read+0xb5/0x180
[ 8515.610064]  [<ffffffff8128ae80>] sys_read+0x50/0xa0
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] runtrin.sh      S ffff8800be66b4c0  4312  6877   6843 0x00000000
[ 8515.610064]  ffff8800be577de8 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff88000802b000 ffff8800be4bb000 ffff8800be577de8 00000000001d6dc0
[ 8515.610064]  ffff8800be4bb000 ffff8800be577fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81115615>] do_wait+0x2b5/0x3b0
[ 8515.610064]  [<ffffffff8111682b>] sys_wait4+0xbb/0xe0
[ 8515.610064]  [<ffffffff81113590>] ? put_task_struct+0x20/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] runtrin.sh      S 00000000001d6dc0  5472  6878   6843 0x00000000
[ 8515.610064]  ffff8800be681de8 0000000000000002 00000000001d6dc0 ffff88000b6c2200
[ 8515.610064]  ffff8800bf96b000 ffff8800be62b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be62b000 ffff8800be681fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81115615>] do_wait+0x2b5/0x3b0
[ 8515.610064]  [<ffffffff8111682b>] sys_wait4+0xbb/0xe0
[ 8515.610064]  [<ffffffff81113590>] ? put_task_struct+0x20/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] sh              S 00000000001d6dc0  4592  6879   6843 0x00000000
[ 8515.610064]  ffff8800bed27c48 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800be4b8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be4b8000 ffff8800bed27fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce1eca>] schedule_timeout+0x3a/0x370
[ 8515.610064]  [<ffffffff83ce5a55>] ? _raw_spin_unlock_irqrestore+0x55/0xa0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff81186bdd>] ? trace_hardirqs_on+0xd/0x10
[ 8515.610064]  [<ffffffff83ce5a7c>] ? _raw_spin_unlock_irqrestore+0x7c/0xa0
[ 8515.610064]  [<ffffffff81c224f1>] n_tty_read+0x431/0x840
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff81c1e5b4>] tty_read+0x94/0xf0
[ 8515.610064]  [<ffffffff8128ad65>] vfs_read+0xb5/0x180
[ 8515.610064]  [<ffffffff8128ae80>] sys_read+0x50/0xa0
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity         S 00000000001d6dc0  3920  6880   6878 0x00000000
[ 8515.610064]  ffff88000b6c5de8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff88000aca3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000aca3000 ffff88000b6c5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81115615>] do_wait+0x2b5/0x3b0
[ 8515.610064]  [<ffffffff8111682b>] sys_wait4+0xbb/0xe0
[ 8515.610064]  [<ffffffff81113590>] ? put_task_struct+0x20/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-watchdo S 0000000000000282  5528  6882   6880 0x00080000
[ 8515.610064]  ffff88000ac9c400 ffff8800be4b0000 0000000000000000 ffff8800be4b0000
[ 8515.610064]  ffffffff811567d0 ffff88000ac9c448 ffff88000ac9c448 0000000000000000
[ 8515.610064]  ffff880000093df8 ffff88000ac9c000 00007f20b3cdc000 0000000000000034
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff811567d0>] ? try_to_wake_up+0x290/0x290
[ 8515.610064]  [<ffffffff81c1e824>] ? do_tty_write+0x144/0x1f0
[ 8515.610064]  [<ffffffff81c21a40>] ? n_tty_ioctl+0xf0/0xf0
[ 8515.610064]  [<ffffffff81c1e98f>] ? tty_write+0xbf/0xf0
[ 8515.610064]  [<ffffffff81a26ef8>] ? do_raw_spin_unlock+0xc8/0xe0
[ 8515.610064]  [<ffffffff81c1ea55>] ? redirected_tty_write+0x95/0xc0
[ 8515.610064]  [<ffffffff8128abe8>] ? vfs_write+0xb8/0x180
[ 8515.610064]  [<ffffffff8128af20>] ? sys_write+0x50/0xa0
[ 8515.610064]  [<ffffffff83ce6bd8>] ? tracesys+0xe1/0xe6
[ 8515.610064] trinity-main    S ffff8800bed414c0  4560  6883   6880 0x00000000
[ 8515.610064]  ffff880000029de8 0000000000000002 ffff88000fbf2000 ffff88000fbf2000
[ 8515.610064]  ffff880000f70000 ffff8800be510000 ffff880000029de8 00000000001d6dc0
[ 8515.610064]  ffff8800be510000 ffff880000029fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff81115615>] do_wait+0x2b5/0x3b0
[ 8515.610064]  [<ffffffff8111682b>] sys_wait4+0xbb/0xe0
[ 8515.610064]  [<ffffffff81113590>] ? put_task_struct+0x20/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child9  D 00000000001d6dc0  4680 16356   6883 0x00000000
[ 8515.610064]  ffff88005401db78 0000000000000002 00000000001d6dc0 ffff880012dd6200
[ 8515.610064]  ffff8800bf97b000 ffff880012423000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880012423000 ffff88005401dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child30 D 00000000001d6dc0  4616 16364   6883 0x00000000
[ 8515.610064]  ffff880019c37b78 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800be790000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be790000 ffff880019c37fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child26 D 00000000001d6dc0  4920 16735   6883 0x00000000
[ 8515.610064]  ffff8800224a5b78 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800075a3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800075a3000 ffff8800224a5fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child51 D 00000000001d6dc0  4856 16861   6883 0x00000000
[ 8515.610064]  ffff880047b6bd18 0000000000000002 00000000001d6dc0 ffff88000b6c2200
[ 8515.610064]  ffff8800bf96b000 ffff880045f78000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880045f78000 ffff880047b6bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child41 D 00000000001d6dc0  4680 16881   6883 0x00000000
[ 8515.610064]  ffff88000ac95b78 0000000000000002 00000000001d6dc0 ffff88000fbf2200
[ 8515.610064]  ffff8800bf978000 ffff880008003000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880008003000 ffff88000ac95fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child16 D 00000000001d6dc0  4712 16892   6883 0x00000000
[ 8515.610064]  ffff880047ac9b78 0000000000000002 00000000001d6dc0 ffff88000b6c2200
[ 8515.610064]  ffff8800bf96b000 ffff88000750b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000750b000 ffff880047ac9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child18 D ffff8800080724c0  5080 16939   6883 0x00000000
[ 8515.610064]  ffff880012ee9d18 0000000000000002 ffff88000fbf2000 ffff88000fbf2000
[ 8515.610064]  ffff880008003000 ffff880010098000 ffff880012ee9d18 00000000001d6dc0
[ 8515.610064]  ffff880010098000 ffff880012ee9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child43 D 00000000001d6dc0  4984 16943   6883 0x00000000
[ 8515.610064]  ffff880047b75c28 0000000000000002 00000000001d6dc0 ffff88000fbf2200
[ 8515.610064]  ffff8800bf978000 ffff880007e38000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e38000 ffff880047b75fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff8126df74>] ? kmem_cache_alloc+0x1a4/0x350
[ 8515.610064]  [<ffffffff8124605a>] __split_vma.isra.25+0x17a/0x210
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff81246f89>] do_munmap+0x149/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child17 D ffff8800080264c0  4888 17017   6883 0x00000000
[ 8515.610064]  ffff88000a5f1b78 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff88000f87b000 ffff88000804b000 ffff88000a5f1b78 00000000001d6dc0
[ 8515.610064]  ffff88000804b000 ffff88000a5f1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child15 D 00000000001d6dc0  4968 17105   6883 0x00000000
[ 8515.610064]  ffff88000d851b78 0000000000000002 00000000001d6dc0 ffff88000fbf2200
[ 8515.610064]  ffff8800bf978000 ffff88000751b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000751b000 ffff88000d851fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child25 D 00000000001d6dc0  5128 17109   6883 0x00000000
[ 8515.610064]  ffff88000dda9d18 0000000000000002 00000000001d6dc0 ffff88000fbf2200
[ 8515.610064]  ffff8800bf978000 ffff88000c6a8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000c6a8000 ffff88000dda9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child1  D ffff88001251f4c0  5080 17153   6883 0x00000000
[ 8515.610064]  ffff88005411db78 0000000000000002 ffff880007e1c000 ffff880007e1c000
[ 8515.610064]  ffff8800be513000 ffff88001361b000 ffff88005411db78 00000000001d6dc0
[ 8515.610064]  ffff88001361b000 ffff88005411dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child5  D 00000000001d6dc0  5224 17183   6883 0x00000000
[ 8515.610064]  ffff88000a293b78 0000000000000002 00000000001d6dc0 ffff880012dd6200
[ 8515.610064]  ffff8800bf97b000 ffff88000a490000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000a490000 ffff88000a293fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child36 D ffff88000c00c4c0  5224 17191   6883 0x00000000
[ 8515.610064]  ffff880009f49d18 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff8800be028000 ffff8800080f3000 ffff880009f49d18 00000000001d6dc0
[ 8515.610064]  ffff8800080f3000 ffff880009f49fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child11 D ffff88001005c4c0  5256 17234   6883 0x00000000
[ 8515.610064]  ffff88000a5c9d18 0000000000000002 ffff88000b6c2000 ffff88000b6c2000
[ 8515.610064]  ffff88000c0b3000 ffff88000ac73000 ffff88000a5c9d18 00000000001d6dc0
[ 8515.610064]  ffff88000ac73000 ffff88000a5c9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child3  D 00000000001d6dc0  5144 17264   6883 0x00000000
[ 8515.610064]  ffff88000e605b78 0000000000000002 00000000001d6dc0 ffff88000fbf2200
[ 8515.610064]  ffff8800bf978000 ffff88000c0c8000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000c0c8000 ffff88000e605fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child20 D ffff8800080214c0  4888 17301   6883 0x00000000
[ 8515.610064]  ffff88003fbf9d18 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff880000f70000 ffff8800be023000 ffff88003fbf9d18 00000000001d6dc0
[ 8515.610064]  ffff8800be023000 ffff88003fbf9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child35 D ffff8800080244c0  5240 17310   6883 0x00000000
[ 8515.610064]  ffff88005b7a9c28 0000000000000002 ffff880007e1c000 ffff880007e1c000
[ 8515.610064]  ffff88000c083000 ffff8800be4db000 ffff88005b7a9c28 00000000001d6dc0
[ 8515.610064]  ffff8800be4db000 ffff88005b7a9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff8126df74>] ? kmem_cache_alloc+0x1a4/0x350
[ 8515.610064]  [<ffffffff8124605a>] __split_vma.isra.25+0x17a/0x210
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff81246f89>] do_munmap+0x149/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child39 D ffff88001251a4c0  5224 17328   6883 0x00000000
[ 8515.610064]  ffff8800126d1d18 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff8800be790000 ffff880010080000 ffff8800126d1d18 00000000001d6dc0
[ 8515.610064]  ffff880010080000 ffff8800126d1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child0  D 00000000001d6dc0  5128 17334   6883 0x00000000
[ 8515.610064]  ffff8800bfe21d18 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800bf793000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800bf793000 ffff8800bfe21fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child6  D ffff88001005d4c0  5224 17339   6883 0x00000000
[ 8515.610064]  ffff880047ab9b78 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff880013580000 ffff880000f70000 ffff880047ab9b78 00000000001d6dc0
[ 8515.610064]  ffff880000f70000 ffff880047ab9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child45 D 00000000001d6dc0  4616 17342   6883 0x00000000
[ 8515.610064]  ffff88000a413d18 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff880008060000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880008060000 ffff88000a413fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child29 D 00000000001d6dc0  5048 17367   6883 0x00000000
[ 8515.610064]  ffff880030405ab8 0000000000000002 00000000001d6dc0 ffff88000b6c2200
[ 8515.610064]  ffff8800bf96b000 ffff88000c0b3000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000c0b3000 ffff880030405fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff812463d6>] vma_merge+0x2e6/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff812478c0>] mmap_region+0x220/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child42 D ffff880037bb64c0  5048 17368   6883 0x00000000
[ 8515.610064]  ffff88005372fd18 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff8800be023000 ffff880007518000 ffff88005372fd18 00000000001d6dc0
[ 8515.610064]  ffff880007518000 ffff88005372ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff812470e0>] do_munmap+0x2a0/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child33 D 00000000001d6dc0  5240 17369   6883 0x00000000
[ 8515.610064]  ffff88005b74dab8 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff880007f08000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007f08000 ffff88005b74dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff811837ed>] ? trace_hardirqs_off+0xd/0x10
[ 8515.610064]  [<ffffffff812478c0>] mmap_region+0x220/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child32 D ffff880007f314c0  5144 17370   6883 0x00000000
[ 8515.610064]  ffff88000d80bc28 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff88001004b000 ffff88000c0b0000 ffff88000d80bc28 00000000001d6dc0
[ 8515.610064]  ffff88000c0b0000 ffff88000d80bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff8126df74>] ? kmem_cache_alloc+0x1a4/0x350
[ 8515.610064]  [<ffffffff8124605a>] __split_vma.isra.25+0x17a/0x210
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff81246f89>] do_munmap+0x149/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child47 D ffff880007f354c0  5256 17372   6883 0x00000000
[ 8515.610064]  ffff88000c665b78 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff8800080f3000 ffff88000c0cb000 ffff88000c665b78 00000000001d6dc0
[ 8515.610064]  ffff88000c0cb000 ffff88000c665fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff8124572c>] vma_link+0xcc/0xf0
[ 8515.610064]  [<ffffffff81247adc>] mmap_region+0x43c/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child10 D ffff8800080414c0  5224 17374   6883 0x00000000
[ 8515.610064]  ffff88000a3e7ba8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff880008028000 ffff880008013000 ffff88000a3e7ba8 00000000001d6dc0
[ 8515.610064]  ffff880008013000 ffff88000a3e7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child37 D ffff8800080434c0  5056 17378   6883 0x00000000
[ 8515.610064]  ffff88000a335ba8 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff8800075a3000 ffff880008010000 ffff88000a335ba8 00000000001d6dc0
[ 8515.610064]  ffff880008010000 ffff88000a335fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child31 D ffff88001251b4c0  5224 17384   6883 0x00000000
[ 8515.610064]  ffff880012fc9ab8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff88000c0cb000 ffff88001007b000 ffff880012fc9ab8 00000000001d6dc0
[ 8515.610064]  ffff88001007b000 ffff880012fc9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff811837ed>] ? trace_hardirqs_off+0xd/0x10
[ 8515.610064]  [<ffffffff812478c0>] mmap_region+0x220/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child28 D 00000000001d6dc0  5152 17385   6883 0x00000000
[ 8515.610064]  ffff880013827ab8 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff880010090000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880010090000 ffff880013827fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff811837ed>] ? trace_hardirqs_off+0xd/0x10
[ 8515.610064]  [<ffffffff812478c0>] mmap_region+0x220/0x5e0
[ 8515.610064]  [<ffffffff81247f2b>] do_mmap_pgoff+0x2ab/0x310
[ 8515.610064]  [<ffffffff812313bc>] ? vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  [<ffffffff812313d4>] vm_mmap_pgoff+0x84/0xb0
[ 8515.610064]  [<ffffffff81246763>] sys_mmap_pgoff+0x193/0x1a0
[ 8515.610064]  [<ffffffff81186b98>] ? trace_hardirqs_on_caller+0x128/0x160
[ 8515.610064]  [<ffffffff8107490d>] sys_mmap+0x1d/0x20
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child49 D 00000000001d6dc0  5224 17392   6883 0x00000000
[ 8515.610064]  ffff88000c7b3b98 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff88000c083000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000c083000 ffff88000c7b3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff8124605a>] __split_vma.isra.25+0x17a/0x210
[ 8515.610064]  [<ffffffff8123b9a2>] ? sys_madvise+0x272/0x280
[ 8515.610064]  [<ffffffff81246e34>] split_vma+0x24/0x30
[ 8515.610064]  [<ffffffff8123b5a5>] madvise_behavior+0x1f5/0x250
[ 8515.610064]  [<ffffffff8123b9a2>] ? sys_madvise+0x272/0x280
[ 8515.610064]  [<ffffffff8123b720>] madvise_vma+0x120/0x130
[ 8515.610064]  [<ffffffff8123b9a2>] ? sys_madvise+0x272/0x280
[ 8515.610064]  [<ffffffff81246b42>] ? find_vma_prev+0x12/0x60
[ 8515.610064]  [<ffffffff8123b8a1>] sys_madvise+0x171/0x280
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child2  D 00000000001d6dc0  5256 17394   6883 0x00000000
[ 8515.610064]  ffff88000a539ba8 0000000000000002 00000000001d6dc0 ffff88000b6c2200
[ 8515.610064]  ffff8800bf96b000 ffff880008063000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880008063000 ffff88000a539fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child48 D ffff88001005e4c0  5224 17396   6883 0x00000000
[ 8515.610064]  ffff88005404dc28 0000000000000002 ffff8800be5f9600 ffff8800be5f9600
[ 8515.610064]  ffff880010080000 ffff8800be793000 ffff88005404dc28 00000000001d6dc0
[ 8515.610064]  ffff8800be793000 ffff88005404dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff8126df74>] ? kmem_cache_alloc+0x1a4/0x350
[ 8515.610064]  [<ffffffff8124605a>] __split_vma.isra.25+0x17a/0x210
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff81246f89>] do_munmap+0x149/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124713e>] ? vm_munmap+0x3e/0x70
[ 8515.610064]  [<ffffffff8124714c>] vm_munmap+0x4c/0x70
[ 8515.610064]  [<ffffffff81247fb6>] sys_munmap+0x26/0x40
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child8  D 00000000001d6dc0  5224 17399   6883 0x00000000
[ 8515.610064]  ffff8800112e1ba8 0000000000000002 00000000001d6dc0 ffff880012dd6200
[ 8515.610064]  ffff8800bf97b000 ffff880010093000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880010093000 ffff8800112e1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child12 D 00000000001d6dc0  4920 17400   6883 0x00000000
[ 8515.610064]  ffff8800386e1ba8 0000000000000002 00000000001d6dc0 ffff88000b6c2200
[ 8515.610064]  ffff8800bf96b000 ffff880007e13000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e13000 ffff8800386e1fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child27 D 00000000001d6dc0  5048 17403   6883 0x00000000
[ 8515.610064]  ffff88000f38fba8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff88000f87b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000f87b000 ffff88000f38ffd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child13 D ffff8800100584c0  5128 17421   6883 0x00000000
[ 8515.610064]  ffff880037b87ba8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff8800be020000 ffff8800be028000 ffff880037b87ba8 00000000001d6dc0
[ 8515.610064]  ffff8800be028000 ffff880037b87fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child23 D 00000000001d6dc0  5296 17432   6883 0x00000000
[ 8515.610064]  ffff880037b5bba8 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff880007e10000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007e10000 ffff880037b5bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child50 D 00000000001d6dc0  4968 17433   6883 0x00000000
[ 8515.610064]  ffff88000a42dba8 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff88000b448000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000b448000 ffff88000a42dfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child7  D 00000000001d6dc0  5080 17439   6883 0x00000000
[ 8515.610064]  ffff88002fb29ba8 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff88000802b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000802b000 ffff88002fb29fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child38 D ffff8800100624c0  5448 17440   6883 0x00000000
[ 8515.610064]  ffff88000e917ba8 0000000000000002 ffff880007e1c000 ffff880007e1c000
[ 8515.610064]  ffff88000802b000 ffff88000c040000 ffff88000e917ba8 00000000001d6dc0
[ 8515.610064]  ffff88000c040000 ffff88000e917fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child40 D ffff8800100634c0  5224 17441   6883 0x00000000
[ 8515.610064]  ffff88000ca97ba8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff880007518000 ffff88000c043000 ffff88000ca97ba8 00000000001d6dc0
[ 8515.610064]  ffff88000c043000 ffff88000ca97fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child44 D ffff88001005f4c0  5296 17442   6883 0x00000000
[ 8515.610064]  ffff880053737ba8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff88000a490000 ffff8800be020000 ffff880053737ba8 00000000001d6dc0
[ 8515.610064]  ffff8800be020000 ffff880053737fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child24 D 00000000001d6dc0  5240 17446   6883 0x00000000
[ 8515.610064]  ffff8800437d7ba8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff880007898000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880007898000 ffff8800437d7fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child22 D 00000000001d6dc0  5016 17449   6883 0x00000000
[ 8515.610064]  ffff88004b77bbd8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff88001004b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88001004b000 ffff88004b77bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245a60>] ? vma_adjust+0x270/0x6f0
[ 8515.610064]  [<ffffffff81245a60>] vma_adjust+0x270/0x6f0
[ 8515.610064]  [<ffffffff811454c2>] ? up_write+0x32/0x40
[ 8515.610064]  [<ffffffff81246037>] __split_vma.isra.25+0x157/0x210
[ 8515.610064]  [<ffffffff8123b9a2>] ? sys_madvise+0x272/0x280
[ 8515.610064]  [<ffffffff81246e34>] split_vma+0x24/0x30
[ 8515.610064]  [<ffffffff8123b58b>] madvise_behavior+0x1db/0x250
[ 8515.610064]  [<ffffffff8123b9a2>] ? sys_madvise+0x272/0x280
[ 8515.610064]  [<ffffffff8123b720>] madvise_vma+0x120/0x130
[ 8515.610064]  [<ffffffff8123b9a2>] ? sys_madvise+0x272/0x280
[ 8515.610064]  [<ffffffff81246b42>] ? find_vma_prev+0x12/0x60
[ 8515.610064]  [<ffffffff8123b8a1>] sys_madvise+0x171/0x280
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child19 D 00000000001d6dc0  5240 17453   6883 0x00000000
[ 8515.610064]  ffff8800bf6e3ba8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800be5cb000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be5cb000 ffff8800bf6e3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81249276>] mprotect_fixup+0xf6/0x240
[ 8515.610064]  [<ffffffff8124949e>] ? sys_mprotect+0xde/0x260
[ 8515.610064]  [<ffffffff81249571>] sys_mprotect+0x1b1/0x260
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child46 D 00000000001d6dc0  5128 17457   6883 0x00000000
[ 8515.610064]  ffff88000acc9bd8 0000000000000002 00000000001d6dc0 ffff880012dd6200
[ 8515.610064]  ffff8800bf97b000 ffff880008028000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880008028000 ffff88000acc9fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81247396>] do_brk+0x226/0x370
[ 8515.610064]  [<ffffffff8124757e>] ? sys_brk+0x3e/0x160
[ 8515.610064]  [<ffffffff8124765a>] sys_brk+0x11a/0x160
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child34 D 00000000001d6dc0  5008 17460   6883 0x00000000
[ 8515.610064]  ffff880027b09bc8 0000000000000002 00000000001d6dc0 ffff880007e1c200
[ 8515.610064]  ffff8800bf968000 ffff8800be513000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be513000 ffff880027b09fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff812463d6>] vma_merge+0x2e6/0x340
[ 8515.610064]  [<ffffffff81220d30>] ? __pagevec_release+0x30/0x30
[ 8515.610064]  [<ffffffff8124416f>] ? sys_mlock+0x4f/0x130
[ 8515.610064]  [<ffffffff81243ebb>] mlock_fixup+0xbb/0x190
[ 8515.610064]  [<ffffffff812440e7>] do_mlock+0xc7/0x100
[ 8515.610064]  [<ffffffff8124416f>] ? sys_mlock+0x4f/0x130
[ 8515.610064]  [<ffffffff812441d7>] sys_mlock+0xb7/0x130
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] sleep           S 00000000001d6dc0  4024 17461   6877 0x00000000
[ 8515.610064]  ffff880037b51de8 0000000000000002 00000000001d6dc0 ffff8800be5f9400
[ 8515.610064]  ffffffff8542f440 ffff8800be030000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff8800be030000 ffff880037b51fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce2fac>] do_nanosleep+0x7c/0xd0
[ 8515.610064]  [<ffffffff8123b9fe>] ? might_fault+0x4e/0xa0
[ 8515.610064]  [<ffffffff811451a7>] hrtimer_nanosleep+0xd7/0x180
[ 8515.610064]  [<ffffffff811435d0>] ? update_rmtp+0x70/0x70
[ 8515.610064]  [<ffffffff81144acf>] ? hrtimer_start_range_ns+0xf/0x20
[ 8515.610064]  [<ffffffff811452be>] sys_nanosleep+0x6e/0x80
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child4  D ffff8800be6d94c0  5224 17464   6883 0x00000000
[ 8515.610064]  ffff880012e97bd8 0000000000000002 ffff880012dd6000 ffff880012dd6000
[ 8515.610064]  ffff880008013000 ffff880013580000 ffff880012e97bd8 00000000001d6dc0
[ 8515.610064]  ffff880013580000 ffff880012e97fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81247396>] do_brk+0x226/0x370
[ 8515.610064]  [<ffffffff8124757e>] ? sys_brk+0x3e/0x160
[ 8515.610064]  [<ffffffff8124765a>] sys_brk+0x11a/0x160
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child14 D 00000000001d6dc0  5160 17465   6883 0x00000000
[ 8515.610064]  ffff88001141bc08 0000000000000002 00000000001d6dc0 ffff880012dd6200
[ 8515.610064]  ffff8800bf97b000 ffff880010078000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff880010078000 ffff88001141bfd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246037>] __split_vma.isra.25+0x157/0x210
[ 8515.610064]  [<ffffffff8124a361>] ? sys_mremap+0x51/0x300
[ 8515.610064]  [<ffffffff81246fb9>] do_munmap+0x179/0x2c0
[ 8515.610064]  [<ffffffff83ce328f>] ? down_write+0x6f/0xb0
[ 8515.610064]  [<ffffffff8124a361>] ? sys_mremap+0x51/0x300
[ 8515.610064]  [<ffffffff8124a3e7>] sys_mremap+0xd7/0x300
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] trinity-child21 W 00000000001d6dc0  5240 17466   6883 0x00000000
[ 8515.610064]  ffff88000cad3bd8 0000000000000002 00000000001d6dc0 ffff88000b6c2200
[ 8515.610064]  ffff8800bf96b000 ffff88000c09b000 00000000001d6dc0 00000000001d6dc0
[ 8515.610064]  ffff88000c09b000 ffff88000cad3fd8 00000000001d6dc0 00000000001d6dc0
[ 8515.610064] Call Trace:
[ 8515.610064]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
[ 8515.610064]  [<ffffffff83ce3d15>] schedule+0x55/0x60
[ 8515.610064]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
[ 8515.610064]  [<ffffffff83ce4c83>] rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff81a139d3>] call_rwsem_down_write_failed+0x13/0x20
[ 8515.610064]  [<ffffffff83ce32c1>] ? down_write+0xa1/0xb0
[ 8515.610064]  [<ffffffff81245480>] ? validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064]  [<ffffffff81245ebd>] vma_adjust+0x6cd/0x6f0
[ 8515.610064]  [<ffffffff81246305>] vma_merge+0x215/0x340
[ 8515.610064]  [<ffffffff8124532c>] ? __vm_enough_memory+0xdc/0x180
[ 8515.610064]  [<ffffffff81247396>] do_brk+0x226/0x370
[ 8515.610064]  [<ffffffff8124757e>] ? sys_brk+0x3e/0x160
[ 8515.610064]  [<ffffffff8124765a>] sys_brk+0x11a/0x160
[ 8515.610064]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
[ 8515.610064] Sched Debug Version: v0.10, 3.8.0-rc1-next-20121224-sasha-00023-gec55a36 #244
[ 8515.610064] ktime                                   : 8519984.644923
[ 8515.610064] sched_clk                               : 234910314.659487
[ 8515.610064] cpu_clk                                 : 8515610.064698
[ 8515.610064] jiffies                                 : 4295789294
[ 8515.610064] sched_clock_stable                      : 0
[ 8515.610064] 
[ 8515.610064] sysctl_sched
[ 8515.610064]   .sysctl_sched_latency                    : 18.000000
[ 8515.610064]   .sysctl_sched_min_granularity            : 2.250000
[ 8515.610064]   .sysctl_sched_wakeup_granularity         : 3.000000
[ 8515.610064]   .sysctl_sched_child_runs_first           : 0
[ 8515.610064]   .sysctl_sched_features                   : 89723
[ 8515.610064]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[ 8515.610064] 
[ 8515.610064] cpu#0, 2492.186 MHz
[ 8515.610064]   .nr_running                    : 2
[ 8515.610064]   .load                          : 1672
[ 8515.610064]   .nr_switches                   : 95373088
[ 8515.610064]   .nr_load_updates               : 839762
[ 8515.610064]   .nr_uninterruptible            : 8574
[ 8515.610064]   .next_balance                  : 4295.788778
[ 8515.610064]   .curr->pid                     : 6882
[ 8515.610064]   .clock                         : 8518513.059962
[ 8515.610064]   .cpu_load[0]                   : 0
[ 8515.610064]   .cpu_load[1]                   : 0
[ 8515.610064]   .cpu_load[2]                   : 0
[ 8515.610064]   .cpu_load[3]                   : 0
[ 8515.610064]   .cpu_load[4]                   : 0
[ 8515.610064]   .yld_count                     : 0
[ 8515.610064]   .sched_count                   : 129399698
[ 8515.610064]   .sched_goidle                  : 5174385
[ 8515.610064]   .avg_idle                      : 1000000
[ 8515.610064]   .ttwu_count                    : 12037981
[ 8515.610064]   .ttwu_local                    : 5276827
[ 8515.610064] 
[ 8515.610064] cfs_rq[0]:/autogroup-1
[ 8515.610064]   .exec_clock                    : 1539668.683605
[ 8515.610064]   .MIN_vruntime                  : 0.000001
[ 8515.610064]   .min_vruntime                  : 339249.870208
[ 8515.610064]   .max_vruntime                  : 0.000001
[ 8515.610064]   .spread                        : 0.000000
[ 8515.610064]   .spread0                       : -108590997.781885
[ 8515.610064]   .nr_spread_over                : 2626
[ 8515.610064]   .nr_running                    : 1
[ 8515.610064]   .load                          : 1024
[ 8515.610064]   .runnable_load_avg             : 0
[ 8515.610064]   .blocked_load_avg              : 0
[ 8515.610064]   .tg_load_avg                   : 529
[ 8515.610064]   .tg_load_contrib               : 0
[ 8515.610064]   .tg_runnable_contrib           : 0
[ 8515.610064]   .tg->runnable_avg              : 239
[ 8515.610064]   .se->exec_start                : 8061238.462426
[ 8515.610064]   .se->vruntime                  : 108930247.652093
[ 8515.610064]   .se->sum_exec_runtime          : 1543081.309777
[ 8515.610064]   .se->statistics.wait_start     : 0.000000
[ 8515.610064]   .se->statistics.sleep_start    : 0.000000
[ 8515.610064]   .se->statistics.block_start    : 0.000000
[ 8515.610064]   .se->statistics.sleep_max      : 0.000000
[ 8515.610064]   .se->statistics.block_max      : 0.000000
[ 8515.610064]   .se->statistics.exec_max       : 10.007709
[ 8515.610064]   .se->statistics.slice_max      : 20.503942
[ 8515.610064]   .se->statistics.wait_max       : 107.133112
[ 8515.610064]   .se->statistics.wait_sum       : 168878.378244
[ 8515.610064]   .se->statistics.wait_count     : 10357254
[ 8515.610064]   .se->load.weight               : 648
[ 8515.610064]   .se->avg.runnable_avg_sum      : 62
[ 8515.610064]   .se->avg.runnable_avg_period   : 47574
[ 8515.610064]   .se->avg.load_avg_contrib      : 0
[ 8515.610064]   .se->avg.decay_count           : 0
[ 8515.610064] 
[ 8515.610064] cfs_rq[0]:/
[ 8515.610064]   .exec_clock                    : 4842310.938451
[ 8515.610064]   .MIN_vruntime                  : 108930234.395583
[ 8515.610064]   .min_vruntime                  : 108930247.652093
[ 8515.610064]   .max_vruntime                  : 108930234.395583
[ 8515.610064]   .spread                        : 0.000000
[ 8515.610064]   .spread0                       : 0.000000
[ 8515.610064]   .nr_spread_over                : 248383
[ 8515.610064]   .nr_running                    : 2
[ 8515.610064]   .load                          : 1672
[ 8515.610064]   .runnable_load_avg             : 0
[ 8515.610064]   .blocked_load_avg              : 0
[ 8515.610064]   .tg_load_avg                   : 385
[ 8515.610064]   .tg_load_contrib               : 0
[ 8515.610064]   .tg_runnable_contrib           : 240
[ 8515.610064]   .tg->runnable_avg              : 3534
[ 8515.610064]   .avg->runnable_avg_sum         : 11065
[ 8515.610064]   .avg->runnable_avg_period      : 47128
[ 8515.610064] 
[ 8515.610064] rt_rq[0]:/
[ 8515.610064]   .rt_nr_running                 : 0
[ 8515.610064]   .rt_throttled                  : 0
[ 8515.610064]   .rt_time                       : 0.000000
[ 8515.610064]   .rt_runtime                    : 950.000000
[ 8515.610064] 
[ 8515.610064] runnable tasks:
[ 8515.610064]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8515.610064] ----------------------------------------------------------------------------------------------------------
[ 8515.610064]  rcu_torture_shu  3119 108930234.395583      8004   120 108930234.395583      2207.553431   8509135.205160 /
[ 8515.610064] Rtrinity-watchdo  6882    339240.870208      8895   120    339240.870208     10324.971289   8479646.283169 /autogroup-1
[ 8515.610064] 
[ 8515.610064] cpu#1, 2492.186 MHz
[ 8515.610064]   .nr_running                    : 3
[ 8515.610064]   .load                          : 45
[ 8515.610064]   .nr_switches                   : 86343869
[ 8515.610064]   .nr_load_updates               : 841405
[ 8515.610064]   .nr_uninterruptible            : -18229
[ 8515.610064]   .next_balance                  : 4295.789319
[ 8515.610064]   .curr->pid                     : 3113
[ 8515.610064]   .clock                         : 8520079.809667
[ 8515.610064]   .cpu_load[0]                   : 45
[ 8515.610064]   .cpu_load[1]                   : 45
[ 8515.610064]   .cpu_load[2]                   : 45
[ 8515.610064]   .cpu_load[3]                   : 45
[ 8515.610064]   .cpu_load[4]                   : 45
[ 8515.610064]   .yld_count                     : 0
[ 8515.610064]   .sched_count                   : 131551023
[ 8515.610064]   .sched_goidle                  : 5028843
[ 8515.610064]   .avg_idle                      : 1000000
[ 8515.610064]   .ttwu_count                    : 11700894
[ 8515.610064]   .ttwu_local                    : 4904254
[ 8515.610064] 
[ 8515.610064] cfs_rq[1]:/
[ 8515.610064]   .exec_clock                    : 4831849.341388
[ 8515.610064]   .MIN_vruntime                  : 128648600.572126
[ 8515.610064]   .min_vruntime                  : 128648600.089481
[ 8515.610064]   .max_vruntime                  : 128648868.106555
[ 8515.610064]   .spread                        : 267.534429
[ 8515.610064]   .spread0                       : 19718352.437388
[ 8515.610064]   .nr_spread_over                : 147422
[ 8515.610064]   .nr_running                    : 3
[ 8515.610064]   .load                          : 45
[ 8515.610064]   .runnable_load_avg             : 42
[ 8515.610064]   .blocked_load_avg              : 0
[ 8515.610064]   .tg_load_avg                   : 385
[ 8515.610064]   .tg_load_contrib               : 42
[ 8515.610064]   .tg_runnable_contrib           : 1010
[ 8515.610064]   .tg->runnable_avg              : 3534
[ 8515.610064]   .avg->runnable_avg_sum         : 46807
[ 8515.610064]   .avg->runnable_avg_period      : 46368
[ 8515.610064] 
[ 8515.610064] rt_rq[1]:/
[ 8515.610064]   .rt_nr_running                 : 0
[ 8515.610064]   .rt_throttled                  : 0
[ 8515.610064]   .rt_time                       : 0.000000
[ 8515.610064]   .rt_runtime                    : 950.000000
[ 8515.610064] 
[ 8515.610064] runnable tasks:
[ 8515.610064]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8515.610064] ----------------------------------------------------------------------------------------------------------
[ 8515.610064]  rcu_torture_rea  3109 128649299.680228  33967401   139 128649299.680228   1617678.787754   4157201.190937 /
[ 8515.610064]  rcu_torture_rea  3113 128649195.995764  34547978   139 128649195.995764   1590308.697505   4156977.777908 /
[ 8515.610064]  rcu_torture_rea  3117 128649402.081569  34794866   139 128649402.081569   1545961.163798   4156757.885677 /
[ 8515.610064] 
[ 8515.610064] cpu#2, 2492.186 MHz
[ 8515.610064]   .nr_running                    : 0
[ 8515.610064]   .load                          : 0
[ 8515.610064]   .nr_switches                   : 80579501
[ 8515.610064]   .nr_load_updates               : 869662
[ 8515.610064]   .nr_uninterruptible            : 8100
[ 8515.610064]   .next_balance                  : 4295.788683
[ 8515.610064]   .curr->pid                     : 0
[ 8515.610064]   .clock                         : 8513880.025731
[ 8515.610064]   .cpu_load[0]                   : 0
[ 8515.610064]   .cpu_load[1]                   : 357
[ 8515.610064]   .cpu_load[2]                   : 330
[ 8515.610064]   .cpu_load[3]                   : 287
[ 8515.610064]   .cpu_load[4]                   : 254
[ 8515.610064]   .yld_count                     : 0
[ 8515.610064]   .sched_count                   : 132638170
[ 8515.610064]   .sched_goidle                  : 4933099
[ 8515.610064]   .avg_idle                      : 1000000
[ 8515.610064]   .ttwu_count                    : 11529712
[ 8515.610064]   .ttwu_local                    : 4832148
[ 8515.610064] 
[ 8515.610064] cfs_rq[2]:/autogroup-1
[ 8515.610064]   .exec_clock                    : 1502135.094960
[ 8515.610064]   .MIN_vruntime                  : 0.000001
[ 8515.610064]   .min_vruntime                  : 332762.127858
[ 8515.610064]   .max_vruntime                  : 0.000001
[ 8515.610064]   .spread                        : 0.000000
[ 8515.610064]   .spread0                       : -108597485.524235
[ 8515.610064]   .nr_spread_over                : 1827
[ 8515.610064]   .nr_running                    : 0
[ 8515.610064]   .load                          : 0
[ 8515.610064]   .runnable_load_avg             : 0
[ 8515.610064]   .blocked_load_avg              : 529
[ 8515.610064]   .tg_load_avg                   : 529
[ 8515.610064]   .tg_load_contrib               : 529
[ 8515.610064]   .tg_runnable_contrib           : 239
[ 8515.610064]   .tg->runnable_avg              : 239
[ 8515.610064]   .se->exec_start                : 8092091.320177
[ 8515.610064]   .se->vruntime                  : 136875916.031029
[ 8515.610064]   .se->sum_exec_runtime          : 1505026.567608
[ 8515.610064]   .se->statistics.wait_start     : 0.000000
[ 8515.610064]   .se->statistics.sleep_start    : 0.000000
[ 8515.610064]   .se->statistics.block_start    : 0.000000
[ 8515.610064]   .se->statistics.sleep_max      : 0.000000
[ 8515.610064]   .se->statistics.block_max      : 0.000000
[ 8515.610064]   .se->statistics.exec_max       : 9.998656
[ 8515.610064]   .se->statistics.slice_max      : 12.542209
[ 8515.610064]   .se->statistics.wait_max       : 90.023080
[ 8515.610064]   .se->statistics.wait_sum       : 152778.157656
[ 8515.610064]   .se->statistics.wait_count     : 10007712
[ 8515.610064]   .se->load.weight               : 2
[ 8515.610064]   .se->avg.runnable_avg_sum      : 10912
[ 8515.610064]   .se->avg.runnable_avg_period   : 46501
[ 8515.610064]   .se->avg.load_avg_contrib      : 273
[ 8515.610064]   .se->avg.decay_count           : 7717220
[ 8515.610064] 
[ 8515.610064] cfs_rq[2]:/
[ 8515.610064]   .exec_clock                    : 4833488.275350
[ 8515.610064]   .MIN_vruntime                  : 0.000001
[ 8515.610064]   .min_vruntime                  : 136875916.031029
[ 8515.610064]   .max_vruntime                  : 0.000001
[ 8515.610064]   .spread                        : 0.000000
[ 8515.610064]   .spread0                       : 27945668.378936
[ 8515.610064]   .nr_spread_over                : 183548
[ 8515.610064]   .nr_running                    : 0
[ 8515.610064]   .load                          : 0
[ 8515.610064]   .runnable_load_avg             : 0
[ 8515.610064]   .blocked_load_avg              : 273
[ 8515.610064]   .tg_load_avg                   : 385
[ 8515.610064]   .tg_load_contrib               : 273
[ 8515.610064]   .tg_runnable_contrib           : 266
[ 8515.610064]   .tg->runnable_avg              : 3534
[ 8515.610064]   .avg->runnable_avg_sum         : 12257
[ 8515.610064]   .avg->runnable_avg_period      : 46912
[ 8515.610064] 
[ 8515.610064] rt_rq[2]:/
[ 8515.610064]   .rt_nr_running                 : 0
[ 8515.610064]   .rt_throttled                  : 0
[ 8515.610064]   .rt_time                       : 0.000000
[ 8515.610064]   .rt_runtime                    : 950.000000
[ 8515.610064] 
[ 8515.610064] runnable tasks:
[ 8515.610064]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8515.610064] ----------------------------------------------------------------------------------------------------------
[ 8515.610064] 
[ 8515.610064] cpu#3, 2492.186 MHz
[ 8515.610064]   .nr_running                    : 2
[ 8515.610064]   .load                          : 30
[ 8515.610064]   .nr_switches                   : 79261177
[ 8515.610064]   .nr_load_updates               : 878347
[ 8515.610064]   .nr_uninterruptible            : -1532
[ 8515.610064]   .next_balance                  : 4295.789331
[ 8515.610064]   .curr->pid                     : 3116
[ 8515.610064]   .clock                         : 8520206.563374
[ 8515.610064]   .cpu_load[0]                   : 30
[ 8515.610064]   .cpu_load[1]                   : 30
[ 8515.610064]   .cpu_load[2]                   : 30
[ 8515.610064]   .cpu_load[3]                   : 30
[ 8515.610064]   .cpu_load[4]                   : 30
[ 8515.610064]   .yld_count                     : 0
[ 8515.610064]   .sched_count                   : 132471944
[ 8515.610064]   .sched_goidle                  : 4920863
[ 8515.610064]   .avg_idle                      : 1000000
[ 8515.610064]   .ttwu_count                    : 11675019
[ 8515.610064]   .ttwu_local                    : 4910525
[ 8515.610064] 
[ 8515.610064] cfs_rq[3]:/
[ 8515.610064]   .exec_clock                    : 4863949.298047
[ 8515.610064]   .MIN_vruntime                  : 138832863.245618
[ 8515.610064]   .min_vruntime                  : 138832845.932989
[ 8515.610064]   .max_vruntime                  : 138832863.245618
[ 8515.610064]   .spread                        : 0.000000
[ 8515.610064]   .spread0                       : 29902598.280896
[ 8515.610064]   .nr_spread_over                : 186040
[ 8515.610064]   .nr_running                    : 2
[ 8515.610064]   .load                          : 30
[ 8515.610064]   .runnable_load_avg             : 28
[ 8515.610064]   .blocked_load_avg              : 0
[ 8515.610064]   .tg_load_avg                   : 385
[ 8515.610064]   .tg_load_contrib               : 28
[ 8515.610064]   .tg_runnable_contrib           : 1010
[ 8515.610064]   .tg->runnable_avg              : 3534
[ 8515.610064]   .avg->runnable_avg_sum         : 47098
[ 8515.610064]   .avg->runnable_avg_period      : 46708
[ 8515.610064] 
[ 8515.610064] rt_rq[3]:/
[ 8515.610064]   .rt_nr_running                 : 0
[ 8515.610064]   .rt_throttled                  : 0
[ 8515.610064]   .rt_time                       : 0.000000
[ 8515.610064]   .rt_runtime                    : 950.000000
[ 8515.610064] 
[ 8515.610064] runnable tasks:
[ 8515.610064]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8515.610064] ----------------------------------------------------------------------------------------------------------
[ 8515.610064] Rrcu_torture_rea  3111 138833507.926258  34228338   139 138833534.004329   1585459.744197   4156966.611465 /
[ 8515.610064] Rrcu_torture_rea  3116 138833571.233410  34425154   139 138833628.937107   1563254.859362   4157317.122852 /
[ 8515.610064] 
[ 8515.610064] cpu#4, 2492.186 MHz
[ 8515.610064]   .nr_running                    : 3
[ 8515.610064]   .load                          : 45
[ 8515.610064]   .nr_switches                   : 84127016
[ 8515.610064]   .nr_load_updates               : 878479
[ 8515.610064]   .nr_uninterruptible            : 3145
[ 8515.610064]   .next_balance                  : 4295.789337
[ 8515.610064]   .curr->pid                     : 3115
[ 8515.610064]   .clock                         : 8520249.952940
[ 8515.610064]   .cpu_load[0]                   : 45
[ 8515.610064]   .cpu_load[1]                   : 45
[ 8515.610064]   .cpu_load[2]                   : 45
[ 8515.610064]   .cpu_load[3]                   : 45
[ 8515.610064]   .cpu_load[4]                   : 45
[ 8515.610064]   .yld_count                     : 0
[ 8515.610064]   .sched_count                   : 132369104
[ 8515.610064]   .sched_goidle                  : 4911378
[ 8515.610064]   .avg_idle                      : 1000000
[ 8515.610064]   .ttwu_count                    : 11570047
[ 8515.610064]   .ttwu_local                    : 4877781
[ 8515.610064] 
[ 8515.610064] cfs_rq[4]:/
[ 8515.610064]   .exec_clock                    : 4851938.579624
[ 8515.610064]   .MIN_vruntime                  : 132508488.069472
[ 8515.610064]   .min_vruntime                  : 132508487.601969
[ 8515.610064]   .max_vruntime                  : 132508619.482990
[ 8515.610064]   .spread                        : 131.413518
[ 8515.610064]   .spread0                       : 23578239.949876
[ 8515.610064]   .nr_spread_over                : 195249
[ 8515.610064]   .nr_running                    : 3
[ 8515.610064]   .load                          : 45
[ 8515.610064]   .runnable_load_avg             : 42
[ 8515.610064]   .blocked_load_avg              : 0
[ 8515.610064]   .tg_load_avg                   : 586
[ 8515.610064]   .tg_load_contrib               : 42
[ 8515.610064]   .tg_runnable_contrib           : 1008
[ 8515.610064]   .tg->runnable_avg              : 3534
[ 8515.610064]   .avg->runnable_avg_sum         : 47056
[ 8515.610064]   .avg->runnable_avg_period      : 47056
[ 8515.610064] 
[ 8515.610064] rt_rq[4]:/
[ 8515.610064]   .rt_nr_running                 : 0
[ 8515.610064]   .rt_throttled                  : 0
[ 8515.610064]   .rt_time                       : 0.000000
[ 8515.610064]   .rt_runtime                    : 950.000000
[ 8515.610064] 
[ 8515.610064] runnable tasks:
[ 8515.610064]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 8515.610064] ----------------------------------------------------------------------------------------------------------
[ 8515.610064] Rrcu_torture_rea  3112 132508897.679486  34158286   139 132509108.162276   1592568.878978   4156847.202643 /
[ 8515.610064]  rcu_torture_rea  3114 132509028.453656  35302962   139 132509057.822045   1552021.454395   4157152.327085 /
[ 8515.610064] Rrcu_torture_rea  3115 132509060.377940  33737949   139 132509060.377940   1663303.786040   4156943.382589 /
[ 8515.610064] 
[ 8515.610064] 
[ 8515.610064] Showing all locks held in the system:
[ 8515.610064] 2 locks held by ksmd/3175:
[ 8515.610064]  #0:  (ksm_thread_mutex){+.+.+.}, at: [<ffffffff812656de>] ksm_scan_thread+0x4e/0x2d0
[ 8515.610064]  #1:  (&mm->mmap_sem){++++++}, at: [<ffffffff81263fda>] unstable_tree_search_insert+0x6a/0x1e0
[ 8515.610064] 1 lock held by rngd/6849:
[ 8515.610064]  #0:  (rng_mutex){+.+.+.}, at: [<ffffffff81ca180e>] rng_dev_read+0x4e/0x200
[ 8515.610064] 1 lock held by sh/6879:
[ 8515.610064]  #0:  (&ldata->atomic_read_lock){+.+...}, at: [<ffffffff81c222b9>] n_tty_read+0x1f9/0x840
[ 8515.610064] 3 locks held by trinity-watchdo/6882:
[ 8515.610064]  #0:  (&tty->atomic_write_lock){+.+.+.}, at: [<ffffffff81c1e6a2>] tty_write_lock+0x22/0x60
[ 8515.610064]  #1:  (&ldata->output_lock){+.+...}, at: [<ffffffff81c20fad>] process_output_block+0x3d/0x1a0
[ 8515.610064]  #2:  (&port_lock_key){..-.-.}, at: [<ffffffff81c429c4>] uart_write_room+0x24/0x60
[ 8515.610064] 2 locks held by trinity-child9/16356:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child30/16364:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child26/16735:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child51/16861:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child41/16881:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child16/16892:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child18/16939:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child43/16943:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child17/17017:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child15/17105:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child25/17109:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child1/17153:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child5/17183:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child36/17191:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child11/17234:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child3/17264:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child20/17301:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child35/17310:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child39/17328:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child0/17334:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child6/17339:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child45/17342:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child29/17367:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child42/17368:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child33/17369:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child32/17370:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child47/17372:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child10/17374:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child37/17378:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child31/17384:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child28/17385:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff812313bc>] vm_mmap_pgoff+0x6c/0xb0
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child49/17392:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8123b9a2>] sys_madvise+0x272/0x280
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child2/17394:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child48/17396:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124713e>] vm_munmap+0x3e/0x70
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child8/17399:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child12/17400:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child27/17403:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child13/17421:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child23/17432:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child50/17433:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child7/17439:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child38/17440:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child40/17441:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child44/17442:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child24/17446:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child22/17449:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8123b9a2>] sys_madvise+0x272/0x280
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245a60>] vma_adjust+0x270/0x6f0
[ 8515.610064] 2 locks held by trinity-child19/17453:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124949e>] sys_mprotect+0xde/0x260
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child46/17457:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124757e>] sys_brk+0x3e/0x160
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child34/17460:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124416f>] sys_mlock+0x4f/0x130
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child4/17464:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124757e>] sys_brk+0x3e/0x160
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child14/17465:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124a361>] sys_mremap+0x51/0x300
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 2 locks held by trinity-child21/17466:
[ 8515.610064]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124757e>] sys_brk+0x3e/0x160
[ 8515.610064]  #1:  (&anon_vma->rwsem){++++.-}, at: [<ffffffff81245480>] validate_mm+0x40/0x130
[ 8515.610064] 
[ 8515.610064] =============================================

--------------060907080706000407010207--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
