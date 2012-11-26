Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 442DA6B006C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 15:33:26 -0500 (EST)
Message-ID: <50B3D1CD.10802@oracle.com>
Date: Mon, 26 Nov 2012 15:32:13 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 19/33] sched: Add adaptive NUMA affinity support
References: <1353624594-1118-1-git-send-email-mingo@kernel.org> <1353624594-1118-20-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-20-git-send-email-mingo@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>

Hi all,

On 11/22/2012 05:49 PM, Ingo Molnar wrote:
> +static void task_numa_placement(struct task_struct *p)
> +{
> +	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);

I was fuzzing with trinity on my fake numa setup, and discovered that this can
be called for task_structs with p->mm == NULL, which would cause things like:

[ 1140.001957] BUG: unable to handle kernel NULL pointer dereference at 00000000000006d0
[ 1140.010037] IP: [<ffffffff81157627>] task_numa_placement+0x27/0x1a0
[ 1140.015020] PGD 9b002067 PUD 9fb3c067 PMD 14a89067 PTE 5a4098bf040
[ 1140.015020] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1140.015020] Dumping ftrace buffer:
[ 1140.015020]    (ftrace buffer empty)
[ 1140.015020] CPU 1
[ 1140.015020] Pid: 3179, comm: ksmd Tainted: G        W    3.7.0-rc6-next-20121126-sasha-00015-gb04382b-dirty #200
[ 1140.015020] RIP: 0010:[<ffffffff81157627>]  [<ffffffff81157627>] task_numa_placement+0x27/0x1a0
[ 1140.015020] RSP: 0018:ffff8800bfae5b08  EFLAGS: 00010292
[ 1140.015020] RAX: 0000000000000000 RBX: ffff8800bfaeb000 RCX: 0000000000000001
[ 1140.015020] RDX: ffff880007c00000 RSI: 000000000000000e RDI: ffff8800bfaeb000
[ 1140.015020] RBP: ffff8800bfae5b38 R08: ffff8800bf805e00 R09: ffff880000369000
[ 1140.015020] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000000000e
[ 1140.015020] R13: 0000000000000004 R14: 0000000000000001 R15: 0000000000000064
[ 1140.015020] FS:  0000000000000000(0000) GS:ffff880007c00000(0000) knlGS:0000000000000000
[ 1140.015020] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1140.015020] CR2: 00000000000006d0 CR3: 0000000097b18000 CR4: 00000000000406e0
[ 1140.015020] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1140.015020] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1140.015020] Process ksmd (pid: 3179, threadinfo ffff8800bfae4000, task ffff8800bfaeb000)
[ 1140.015020] Stack:
[ 1140.015020]  0000000000000000 0000000000000000 000000000000000e ffff8800bfaeb000
[ 1140.015020]  000000000000000e 0000000000000004 ffff8800bfae5b88 ffffffff8115a577
[ 1140.015020]  ffff8800bfae5b68 ffffffff00000001 ffff88000c1d0068 ffffea0000ec1000
[ 1140.015020] Call Trace:
[ 1140.015020]  [<ffffffff8115a577>] task_numa_fault+0xb7/0xd0
[ 1140.015020]  [<ffffffff81230d96>] do_numa_page.isra.42+0x1b6/0x270
[ 1140.015020]  [<ffffffff8126fe08>] ? mem_cgroup_count_vm_event+0x178/0x1a0
[ 1140.015020]  [<ffffffff812333f4>] handle_pte_fault+0x174/0x220
[ 1140.015020]  [<ffffffff819e7ad9>] ? __const_udelay+0x29/0x30
[ 1140.015020]  [<ffffffff81234780>] handle_mm_fault+0x320/0x350
[ 1140.015020]  [<ffffffff81256845>] break_ksm+0x65/0xc0
[ 1140.015020]  [<ffffffff81256b4d>] break_cow+0x5d/0x80
[ 1140.015020]  [<ffffffff81258442>] cmp_and_merge_page+0x122/0x1e0
[ 1140.015020]  [<ffffffff81258565>] ksm_do_scan+0x65/0xa0
[ 1140.015020]  [<ffffffff8125860f>] ksm_scan_thread+0x6f/0x2d0
[ 1140.015020]  [<ffffffff8113b990>] ? abort_exclusive_wait+0xb0/0xb0
[ 1140.015020]  [<ffffffff812585a0>] ? ksm_do_scan+0xa0/0xa0
[ 1140.015020]  [<ffffffff8113a723>] kthread+0xe3/0xf0
[ 1140.015020]  [<ffffffff8113a640>] ? __kthread_bind+0x40/0x40
[ 1140.015020]  [<ffffffff83c8813c>] ret_from_fork+0x7c/0xb0
[ 1140.015020]  [<ffffffff8113a640>] ? __kthread_bind+0x40/0x40
[ 1140.015020] Code: 00 00 00 00 55 48 89 e5 41 55 41 54 53 48 89 fb 48 83 ec 18 48 c7 45 d0 00 00 00 00 48 8b 87 a0 04 00 00 48
c7 45 d8 00 00 00 00 <8b> 80 d0 06 00 00 39 87 d4 15 00 00 0f 84 57 01 00 00 89 87 d4
[ 1140.015020] RIP  [<ffffffff81157627>] task_numa_placement+0x27/0x1a0
[ 1140.015020]  RSP <ffff8800bfae5b08>
[ 1140.015020] CR2: 00000000000006d0
[ 1140.660568] ---[ end trace 9f1fd31243556513 ]---

In exchange to this bug report, I have couple of questions about this NUMA code which I wasn't
able to answer myself :)

 - In this case, would it mean that KSM may run on one node, but scan the memory of a different node?
 - If yes, we should migrate KSM to each node we scan, right? Or possibly start a dedicated KSM
thread for each NUMA node?
 - Is there a class of per-numa threads in the works?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
