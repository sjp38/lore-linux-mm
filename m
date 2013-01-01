Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 84B8E6B006C
	for <linux-mm@kvack.org>; Mon, 31 Dec 2012 23:16:15 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id un3so11716075obb.7
        for <linux-mm@kvack.org>; Mon, 31 Dec 2012 20:16:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50E1D192.1020308@oracle.com>
References: <50E1D192.1020308@oracle.com>
Date: Tue, 1 Jan 2013 12:16:14 +0800
Message-ID: <CAJd=RBCpBk9p-yr-eeLXd3sbNvFGV-36z401r8hOe3+HQkh1WA@mail.gmail.com>
Subject: Re: mm: lockup on mmap_sem
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jan 1, 2013 at 1:55 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest, running latest -next kernel,
> I've stumbled on the following hang:
>
> [ 7204.030178] INFO: task khugepaged:3257 blocked for more than 120 seconds.
> [ 7204.031043] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 7204.032056] khugepaged      D 00000000001d6dc0  5144  3257      2 0x00000000
> [ 7204.032969]  ffff8800be8bdc00 0000000000000002 ffff880007dd6e78 ffff880007dd6e78
> [ 7204.033959]  ffff8800bf9cb000 ffff8800be8b3000 ffff8800be8bdc00 00000000001d6dc0
> [ 7204.034994]  ffff8800be8b3000 ffff8800be8bdfd8 00000000001d6dc0 00000000001d6dc0
> [ 7204.036057] Call Trace:
> [ 7204.036388]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
> [ 7204.037090]  [<ffffffff83ce3d15>] schedule+0x55/0x60
> [ 7204.037711]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
> [ 7204.038511]  [<ffffffff83ce4ca5>] rwsem_down_read_failed+0x15/0x17
> [ 7204.039292]  [<ffffffff81a139a4>] call_rwsem_down_read_failed+0x14/0x30
> [ 7204.040207]  [<ffffffff83ce3349>] ? down_read+0x79/0x8e
> [ 7204.040895]  [<ffffffff81276147>] ? khugepaged_scan_mm_slot+0xa7/0x2b0
> [ 7204.041689]  [<ffffffff83ce55b0>] ? _raw_spin_unlock+0x30/0x60
> [ 7204.042482]  [<ffffffff81276147>] khugepaged_scan_mm_slot+0xa7/0x2b0
> [ 7204.043299]  [<ffffffff8127644d>] khugepaged_do_scan+0xfd/0x1a0
> [ 7204.044105]  [<ffffffff812764f0>] ? khugepaged_do_scan+0x1a0/0x1a0
> [ 7204.044874]  [<ffffffff81276515>] khugepaged+0x25/0x70
> [ 7204.045527]  [<ffffffff8113f1b3>] kthread+0xe3/0xf0
> [ 7204.046129]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
> [ 7204.046905]  [<ffffffff83ce68fc>] ret_from_fork+0x7c/0xb0
> [ 7204.047609]  [<ffffffff8113f0d0>] ? flush_kthread_worker+0x190/0x190
> [ 7204.048524] 1 lock held by khugepaged/3257:
> [ 7204.049046]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81276147>] khugepaged_scan_mm_slot+0xa7/0x2b0
> [ 7204.050449] INFO: task trinity-child22:15461 blocked for more than 120 seconds.
> [ 7204.051355] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 7204.052390] trinity-child22 D ffff88000c00e4c0  4920 15461   6883 0x00000004
> [ 7204.053347]  ffff88002fba9bc0 0000000000000002 ffff88000b6c2000 ffff88000b6c2000
> [ 7204.054387]  ffff880008003000 ffff880007898000 ffff88002fba9bc0 00000000001d6dc0
> [ 7204.055373]  ffff880007898000 ffff88002fba9fd8 00000000001d6dc0 00000000001d6dc0
> [ 7204.056396] Call Trace:
> [ 7204.056703]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
> [ 7204.057402]  [<ffffffff83ce3d15>] schedule+0x55/0x60
> [ 7204.058036]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
> [ 7204.058826]  [<ffffffff83ce4ca5>] rwsem_down_read_failed+0x15/0x17
> [ 7204.059588]  [<ffffffff81a139a4>] call_rwsem_down_read_failed+0x14/0x30
> [ 7204.060502]  [<ffffffff83ce3349>] ? down_read+0x79/0x8e
> [ 7204.061188]  [<ffffffff8125fa16>] ? do_migrate_pages+0x56/0x2b0
> [ 7204.061906]  [<ffffffff81220d50>] ? lru_add_drain_all+0x10/0x20
> [ 7204.062648]  [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0
> [ 7204.063418]  [<ffffffff81a26ef8>] ? do_raw_spin_unlock+0xc8/0xe0
> [ 7204.064240]  [<ffffffff8194e573>] ? security_capable+0x13/0x20
> [ 7204.064865]  [<ffffffff8111d8c0>] ? ns_capable+0x50/0x80
> [ 7204.065443]  [<ffffffff812601c2>] sys_migrate_pages+0x4e2/0x550
> [ 7204.065964]  [<ffffffff8125fd98>] ? sys_migrate_pages+0xb8/0x550
> [ 7204.066513]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
> [ 7204.067011] 1 lock held by trinity-child22/15461:
> [ 7204.067452]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0
> [ 7204.068489] INFO: task trinity-child16:15829 blocked for more than 120 seconds.
> [ 7204.069224] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 7204.070057] trinity-child16 D ffff880008ba74c0  5128 15829   6883 0x00000004
> [ 7204.070732]  ffff88000c791bc0 0000000000000002 ffff880012dd6000 ffff880012dd6000
> [ 7204.071550]  ffff88000c083000 ffff88000d808000 ffff88000c791bc0 00000000001d6dc0
> [ 7204.072380]  ffff88000d808000 ffff88000c791fd8 00000000001d6dc0 00000000001d6dc0
> [ 7204.073323] Call Trace:
> [ 7204.073614]  [<ffffffff83ce3ae9>] __schedule+0x2e9/0x3b0
> [ 7204.074179]  [<ffffffff83ce3d15>] schedule+0x55/0x60
> [ 7204.074619]  [<ffffffff83ce4c35>] rwsem_down_failed_common+0xf5/0x130
> [ 7204.075285]  [<ffffffff83ce4ca5>] rwsem_down_read_failed+0x15/0x17
> [ 7204.075839]  [<ffffffff81a139a4>] call_rwsem_down_read_failed+0x14/0x30
> [ 7204.076435]  [<ffffffff83ce3349>] ? down_read+0x79/0x8e
> [ 7204.076900]  [<ffffffff8125fa16>] ? do_migrate_pages+0x56/0x2b0
> [ 7204.077623]  [<ffffffff81220d50>] ? lru_add_drain_all+0x10/0x20
> [ 7204.078360]  [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0
> [ 7204.079063]  [<ffffffff81a26ef8>] ? do_raw_spin_unlock+0xc8/0xe0
> [ 7204.079622]  [<ffffffff8194e573>] ? security_capable+0x13/0x20
> [ 7204.080329]  [<ffffffff8111d8c0>] ? ns_capable+0x50/0x80
> [ 7204.080938]  [<ffffffff812601c2>] sys_migrate_pages+0x4e2/0x550
> [ 7204.081692]  [<ffffffff8125fd98>] ? sys_migrate_pages+0xb8/0x550
> [ 7204.082241]  [<ffffffff83ce6bd8>] tracesys+0xe1/0xe6
> [ 7204.082735] 1 lock held by trinity-child16/15829:
> [ 7204.083401]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8125fa16>] do_migrate_pages+0x56/0x2b0
>
> I'm not quite sure how it happened, but I've attached a full sysrq-t which could possibly
> help with figuring it out.
>
Hey Sasha

Can you please try with the following commits reverted?

Hillf


[1] commit: 5a505085f
mm/rmap: Convert the struct anon_vma::mutex to an rwsem

[2] commit: 4fc3f1d66
mm/rmap, migration: Make rmap_walk_anon() and try_to_unmap_anon() more scalable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
