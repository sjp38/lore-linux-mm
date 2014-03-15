Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 788836B0037
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 23:15:50 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id h18so3284916igc.0
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 20:15:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nv2si31992icc.117.2014.03.14.20.15.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 20:15:49 -0700 (PDT)
Message-ID: <5323C5D9.2070902@oracle.com>
Date: Fri, 14 Mar 2014 23:15:37 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: numa: Recheck for transhuge pages under lock during
 protection changes
References: <20140307140650.GA1931@suse.de> <20140307150923.GB1931@suse.de> <20140307182745.GD1931@suse.de> <20140311162845.GA30604@suse.de> <531F3F15.8050206@oracle.com> <531F4128.8020109@redhat.com> <531F48CC.303@oracle.com> <20140311180652.GM10663@suse.de> <531F616A.7060300@oracle.com> <20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org> <20140312103602.GN10663@suse.de>
In-Reply-To: <20140312103602.GN10663@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com, Davidlohr Bueso <davidlohr@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/12/2014 06:36 AM, Mel Gorman wrote:
> Andrew, this should go with the patches
> mmnuma-reorganize-change_pmd_range.patch
> mmnuma-reorganize-change_pmd_range-fix.patch
> move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch
> in mmotm please.
>
> Thanks.
>
> ---8<---
> From: Mel Gorman<mgorman@suse.de>
> Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during protection changes
>
> Sasha Levin reported the following bug using trinity

I'm seeing a different issue with this patch. A NULL ptr deref occurs in the
pte_offset_map_lock() macro right before the new recheck code:

[ 1877.093980] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[ 1877.095174] IP: __lock_acquire+0xbc/0x5a0 (kernel/locking/lockdep.c:3069)
[ 1877.096069] PGD 6dee7a067 PUD 6dee7b067 PMD 0
[ 1877.096821] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1877.097706] Dumping ftrace buffer:
[ 1877.098281]    (ftrace buffer empty)
[ 1877.098825] Modules linked in:
[ 1877.099327] CPU: 19 PID: 27913 Comm: trinity-c100 Tainted: G        W     3.14.0-rc6-next-20140314-sasha-00012-g5590866 #219
[ 1877.100044] task: ffff8808f4280000 ti: ffff8806e1e54000 task.ti: ffff8806e1e54000
[ 1877.100044] RIP:  __lock_acquire+0xbc/0x5a0 (kernel/locking/lockdep.c:3069)
[ 1877.100044] RSP: 0000:ffff8806e1e55be8  EFLAGS: 00010002
[ 1877.100044] RAX: 0000000000000082 RBX: 0000000000000018 RCX: 0000000000000000
[ 1877.100044] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000018
[ 1877.100044] RBP: ffff8806e1e55c58 R08: 0000000000000001 R09: 0000000000000000
[ 1877.100044] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8808f4280000
[ 1877.100044] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000001
[ 1877.100044] FS:  00007fe3fe152700(0000) GS:ffff88042ba00000(0000) knlGS:0000000000000000
[ 1877.100044] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1877.100044] CR2: 0000000000000018 CR3: 00000006dee79000 CR4: 00000000000006a0
[ 1877.100044] DR0: 0000000000698000 DR1: 0000000000698000 DR2: 0000000000698000
[ 1877.100044] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000009060a
[ 1877.100044] Stack:
[ 1877.100044]  ffff8806e1e55c18 ffffffff81184e95 ffff8808f4280038 00000000001d8500
[ 1877.100044]  ffff88042bbd8500 0000000000000013 ffff8806e1e55c48 ffffffff81185108
[ 1877.100044]  ffffffff87c13bd0 ffff8808f4280000 0000000000000000 0000000000000001
[ 1877.100044] Call Trace:
[ 1877.100044]  ? sched_clock_local+0x25/0x90 (kernel/sched/clock.c:205)
[ 1877.100044]  ? sched_clock_cpu+0xb8/0x100 (kernel/sched/clock.c:310)
[ 1877.100044]  lock_acquire+0x182/0x1d0 (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[ 1877.100044]  ? change_pte_range+0xa3/0x410 (mm/mprotect.c:55)
[ 1877.100044]  ? __lock_release+0x1e2/0x200 (kernel/locking/lockdep.c:3506)
[ 1877.100044]  _raw_spin_lock+0x40/0x80 (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[ 1877.100044]  ? change_pte_range+0xa3/0x410 (mm/mprotect.c:55)
[ 1877.100044]  ? _raw_spin_unlock+0x35/0x60 (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
[ 1877.100044]  change_pte_range+0xa3/0x410 (mm/mprotect.c:55)
[ 1877.100044]  change_protection_range+0x3a8/0x4d0 (mm/mprotect.c:164 mm/mprotect.c:188 mm/mprotect.c:213)
[ 1877.100044]  ? preempt_count_sub+0xe2/0x120 (kernel/sched/core.c:2529)
[ 1877.100044]  change_protection+0x25/0x30 (mm/mprotect.c:237)
[ 1877.100044]  change_prot_numa+0x1b/0x30 (mm/mempolicy.c:559)
[ 1877.100044]  task_numa_work+0x279/0x360 (kernel/sched/fair.c:1911)
[ 1877.100044]  task_work_run+0xae/0xf0 (kernel/task_work.c:125)
[ 1877.100044]  do_notify_resume+0x8e/0xe0 (include/linux/tracehook.h:196 arch/x86/kernel/signal.c:751)
[ 1877.100044]  retint_signal+0x4d/0x92 (arch/x86/kernel/entry_64.S:1096)
[ 1877.100044] Code: c2 6f 3b 6d 85 be fa 0b 00 00 48 c7 c7 ce 94 6d 85 e8 f9 78 f9 ff 31 c0 e9 bc 04 00 00 66 90 44 8b 1d 29 69 cd 04 45 85 db 74 0c <48> 81 3b 80 f2 75 87 75 06 0f 1f 00 45 31 c0 83 fe 01 77 0c 89
[ 1877.100044] RIP  __lock_acquire+0xbc/0x5a0 (kernel/locking/lockdep.c:3069)
[ 1877.100044]  RSP <ffff8806e1e55be8>
[ 1877.100044] CR2: 0000000000000018


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
