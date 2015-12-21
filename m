Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id DC97E6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 15:28:37 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id v6so142076604ykc.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:28:37 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g204si5860314ywa.284.2015.12.21.12.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 12:28:37 -0800 (PST)
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
References: <5674A5C3.1050504@oracle.com>
 <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <567860EB.4000103@oracle.com>
Date: Mon, 21 Dec 2015 15:28:27 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/21/2015 08:08 AM, Christoph Lameter wrote:
> On Fri, 18 Dec 2015, Sasha Levin wrote:
> 
>> > [  531.164630] RIP vmstat_update (mm/vmstat.c:1408)
> Hmmm.. Yes we need to fold the diffs first before disabling the timer
> otherwise the shepherd task may intervene.
> 
> Does this patch fix it?

It didn't. With the patch I'm still seeing:

[ 1997.674112] kernel BUG at mm/vmstat.c:1408!
[ 1997.674930] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[ 1997.676252] Modules linked in:
[ 1997.676880] CPU: 4 PID: 14713 Comm: kworker/4:0 Not tainted 4.4.0-rc5-next-20151221-sasha-00020-g840272e-dirty #2753
[ 1997.679262] Workqueue: vmstat vmstat_update
[ 1997.680109] task: ffff88015bca0000 ti: ffff88015bcb8000 task.ti: ffff88015bcb8000
[ 1997.681279] RIP: 0010:[<ffffffffa2683c48>]  [<ffffffffa2683c48>] vmstat_update+0x178/0x1a0
[ 1997.682810] RSP: 0018:ffff88015bcbfc00  EFLAGS: 00010297
[ 1997.683611] RAX: 0000000000000004 RBX: ffff8803d2801a18 RCX: 0000000000000000
[ 1997.684689] RDX: 0000000000000007 RSI: ffffffffad098220 RDI: ffffffffbc8be724
[ 1997.685750] RBP: ffff88015bcbfc20 R08: 0000000000000000 R09: ffff88015bca0230
[ 1997.686812] R10: ffffffffad098220 R11: ffff880180a1be78 R12: ffff880180a1be60
[ 1997.688087] R13: ffff880157b27908 R14: ffff880180a21000 R15: ffff880157b27900
[ 1997.689120] FS:  0000000000000000(0000) GS:ffff880180a00000(0000) knlGS:0000000000000000
[ 1997.690290] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1997.691141] CR2: 00007f05e5690000 CR3: 0000000158699000 CR4: 00000000000006a0
[ 1997.692189] Stack:
[ 1997.692496]  ffff880180a21000 ffff880157b27918 ffff880180a1be60 ffff880157b27908
[ 1997.693689]  ffff88015bcbfd40 ffffffffa23aa40f ffffffffaf66686b ffff880157b27948
[ 1997.694851]  ffff880180a1be68 ffff880100000000 ffff880157b27910 ffff880157b27920
[ 1997.696013] Call Trace:
[ 1997.696542]  [<ffffffffa23aa40f>] process_one_work+0xacf/0x12a0
[ 1997.697516]  [<ffffffffa23a9940>] ? cancel_delayed_work_sync+0x10/0x10
[ 1997.698889]  [<fffffffface0df27>] ? __schedule+0x1127/0x14c0
[ 1997.699738]  [<ffffffffa23e11bd>] ? get_parent_ip+0xd/0x40
[ 1997.700547]  [<ffffffffa23e12d9>] ? preempt_count_add+0xe9/0x140
[ 1997.701426]  [<ffffffffa23ab898>] worker_thread+0xcb8/0x1090
[ 1997.702259]  [<ffffffffa23d2ad0>] ? load_mm_ldt+0x1f0/0x1f0
[ 1997.703084]  [<ffffffffa23d5b53>] ? update_rq_clock+0x123/0x2e0
[ 1997.703962]  [<ffffffffa23aabe0>] ? process_one_work+0x12a0/0x12a0
[ 1997.704896]  [<ffffffffa23aabe0>] ? process_one_work+0x12a0/0x12a0
[ 1997.705804]  [<ffffffffa23bf8ce>] kthread+0x31e/0x330
[ 1997.706551]  [<ffffffffa23d3195>] ? finish_task_switch+0x6c5/0x970
[ 1997.707481]  [<ffffffffa23bf5b0>] ? kthread_worker_fn+0x680/0x680
[ 1997.708374]  [<ffffffffa23bf5b0>] ? kthread_worker_fn+0x680/0x680
[ 1997.709269]  [<fffffffface1a50f>] ret_from_fork+0x3f/0x70
[ 1997.710067]  [<ffffffffa23bf5b0>] ? kthread_worker_fn+0x680/0x680
[ 1997.710964] Code: 75 1e be 79 00 00 00 48 c7 c7 40 16 10 ad 89 45 e4 e8 2d 88 cd ff 8b 45 e4 c6 05 a0 a9 13 1a 01 89 c0 f0 48 0f ab 03 72 02 eb 0e <0f> 0b 48 c7 c7 c0 21 48 b1 e8 45 d6 ad 01 48 83 c4 08 5b 41 5c
[ 1997.714961] RIP  [<ffffffffa2683c48>] vmstat_update+0x178/0x1a0
[ 1997.715852]  RSP <ffff88015bcbfc00>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
