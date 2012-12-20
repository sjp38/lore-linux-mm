Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id DDA886B005A
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:16 -0500 (EST)
Message-ID: <50D387FD.4020008@oracle.com>
Date: Thu, 20 Dec 2012 16:49:49 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: make rmap walks more scalable
References: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils> <alpine.LNX.2.00.1212191742440.25409@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1212191742440.25409@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/19/2012 08:44 PM, Hugh Dickins wrote:
> The rmap walks in ksm.c are like those in rmap.c:
> they can safely be done with anon_vma_lock_read().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---

Hi Hugh,

This patch didn't fix the ksm oopses I'm seeing.

This is with both patches applied:


[  191.221082] BUG: unable to handle kernel NULL pointer dereference at 0000000000000110
[  191.226749] IP: [<ffffffff81185bf0>] __lock_acquire+0xb0/0xa90
[  191.228437] PGD 1469f067 PUD 1466a067 PMD 0
[  191.229185] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  191.230031] Dumping ftrace buffer:
[  191.230031]    (ftrace buffer empty)
[  191.230031] CPU 3
[  191.230031] Pid: 3174, comm: ksmd Tainted: G        W    3.7.0-next-20121220-sasha-00015-g5dc79b2-dirty #223
[  191.230031] RIP: 0010:[<ffffffff81185bf0>]  [<ffffffff81185bf0>] __lock_acquire+0xb0/0xa90
[  191.230031] RSP: 0018:ffff8800be933b78  EFLAGS: 00010046
[  191.230031] RAX: 0000000000000086 RBX: 0000000000000110 RCX: 0000000000000001
[  191.230031] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000110
[  191.230031] RBP: ffff8800be933c18 R08: 0000000000000002 R09: 0000000000000000
[  191.230031] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
[  191.230031] R13: 0000000000000002 R14: ffff8800be940000 R15: 0000000000000000
[  191.230031] FS:  0000000000000000(0000) GS:ffff88000fc00000(0000) knlGS:0000000000000000
[  191.230031] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  191.230031] CR2: 0000000000000110 CR3: 000000001469e000 CR4: 00000000000406e0
[  191.230031] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  191.230031] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  191.230031] Process ksmd (pid: 3174, threadinfo ffff8800be932000, task ffff8800be940000)
[  191.230031] Stack:
[  191.230031]  ffff8800be933fd8 0000000000000000 ffff8800be933bb8 ffffffff810a4ec8
[  191.230031]  ffff8800be933bc8 ffffffff811572a8 ffff88000fdd78c0 ffff88000fdd78d0
[  191.230031]  ffff8800be933bc8 ffffffff81077ce5 ffff8800be933bf8 ffffffff81157075
[  191.230031] Call Trace:
[  191.230031]  [<ffffffff810a4ec8>] ? kvm_clock_read+0x38/0x70
[  191.230031]  [<ffffffff811572a8>] ? sched_clock_cpu+0x108/0x120
[  191.230031]  [<ffffffff81077ce5>] ? sched_clock+0x15/0x20
[  191.230031]  [<ffffffff81157075>] ? sched_clock_local+0x25/0x90
[  191.230031]  [<ffffffff81188a3a>] lock_acquire+0x1ca/0x270
[  191.230031]  [<ffffffff812599cf>] ? unstable_tree_search_insert+0x9f/0x260
[  191.230031]  [<ffffffff83cd7f27>] down_read+0x47/0x90
[  191.230031]  [<ffffffff812599cf>] ? unstable_tree_search_insert+0x9f/0x260
[  191.230031]  [<ffffffff812599cf>] unstable_tree_search_insert+0x9f/0x260
[  191.230031]  [<ffffffff8125afc7>] cmp_and_merge_page+0xe7/0x1e0
[  191.230031]  [<ffffffff8125b125>] ksm_do_scan+0x65/0xa0
[  191.230031]  [<ffffffff8125b1cf>] ksm_scan_thread+0x6f/0x2d0
[  191.230031]  [<ffffffff8113deb0>] ? abort_exclusive_wait+0xb0/0xb0
[  191.230031]  [<ffffffff8125b160>] ? ksm_do_scan+0xa0/0xa0
[  191.230031]  [<ffffffff8113cc43>] kthread+0xe3/0xf0
[  191.230031]  [<ffffffff8113cb60>] ? __kthread_bind+0x40/0x40
[  191.230031]  [<ffffffff83cdba7c>] ret_from_fork+0x7c/0xb0
[  191.230031]  [<ffffffff8113cb60>] ? __kthread_bind+0x40/0x40
[  191.230031] Code: 00 83 3d 33 2b b0 05 00 0f 85 d5 09 00 00 be f9 0b 00 00 48 c7 c7 24 d1 b2 84 89 55 88 e8 09 80 f8 ff 8b 55
88 e9 b9 09 00 00 90 <48> 81 3b 60 59 22 86 b8 01 00 00 00 44 0f 44 e8 41 83 fc 01 77
[  191.230031] RIP  [<ffffffff81185bf0>] __lock_acquire+0xb0/0xa90
[  191.230031]  RSP <ffff8800be933b78>
[  191.230031] CR2: 0000000000000110
[  191.230031] ---[ end trace 55f664bfe0f01693 ]---


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
