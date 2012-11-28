Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 832D16B006E
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 15:35:03 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so12557776qcq.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 12:35:02 -0800 (PST)
Date: Wed, 28 Nov 2012 12:35:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: BUG_ON(inode->i_blocks);
In-Reply-To: <20121127182738.GA13608@redhat.com>
Message-ID: <alpine.LNX.2.00.1211281221140.14341@eggly.anvils>
References: <20121127182738.GA13608@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Fedora Kernel Team <kernel-team@fedoraproject.org>

On Tue, 27 Nov 2012, Dave Jones wrote:

> Hugh,
> 
> We had a user report hitting the BUG_ON at the end of shmem_evict_inode.
> I see in 3.7 you changed this to a WARN instead.
> 
> Does the trace below match the one you described chasing in commit
> 0f3c42f522dc1ad7e27affc0a4aa8c790bce0a66 ?

The trace fits (apart from, I hit mine in the days before task_work_run
was used for fput), but that doesn't tell us anything much.

> 
> Full report at https://bugzilla.redhat.com/show_bug.cgi?id=879422, though
> there's not much more than the trace tbh.

It does say "system was idle", which makes me think that this has to
have a different cause from my race between eviction and swapout.

Of course, the change from BUG_ON to WARN_ON would equally neuter
this crash, but it looks to me like a sign of... something else.
Please do let me know if more keep coming.

Hugh

> 
> 	Dave
> 
> 
> :kernel BUG at mm/shmem.c:657!
> :invalid opcode: 0000 [#1] SMP 
> :CPU 1 
> :Pid: 1017, comm: kwin Not tainted 3.6.6-1.fc17.x86_64 #1 System manufacturer P5E-VM HDMI/P5E-VM HDMI
> :RIP: 0010:[<ffffffff81145792>]  [<ffffffff81145792>] shmem_evict_inode+0x112/0x120
> :RSP: 0018:ffff88012b94ddb8  EFLAGS: 00010282
> :RAX: 0000000050aeab47 RBX: ffff880117a424a8 RCX: 0000000000000018
> :RDX: 000000001fea11fd RSI: 0000000005537c1c RDI: ffffffff81f1d500
> :RBP: ffff88012b94ddd8 R08: 0000000000000000 R09: 0000000000000000
> :R10: 0000000000000000 R11: 0000000000000000 R12: ffff880117a424a8
> :R13: ffff880117a424a8 R14: ffff880117a424b8 R15: ffff880139a79220
> :FS:  00007fa606014880(0000) GS:ffff88013fc80000(0000) knlGS:0000000000000000
> :CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> :CR2: 00007fa5f0021010 CR3: 000000012c2d0000 CR4: 00000000000007e0
> :DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> :DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> :Process kwin (pid: 1017, threadinfo ffff88012b94c000, task ffff880134f30000)
> :Stack:
> : ffff880117a424b8 ffff880117a425b0 ffffffff81812f80 ffffffff81812f80
> : ffff88012b94de08 ffffffff811a8da2 ffff88012b94dde8 ffff880117a424b8
> : ffff880117a42540 ffff880139a34000 ffff88012b94de38 ffffffff811a8fa3
> :Call Trace:
> : [<ffffffff811a8da2>] evict+0xa2/0x1a0
> : [<ffffffff811a8fa3>] iput+0x103/0x1f0
> : [<ffffffff811a50e8>] d_kill+0xd8/0x110
> : [<ffffffff811a5782>] dput+0xe2/0x1b0
> : [<ffffffff811900d6>] __fput+0x166/0x240
> : [<ffffffff811901be>] ____fput+0xe/0x10
> : [<ffffffff8107beab>] task_work_run+0x6b/0x90
> : [<ffffffff81013921>] do_notify_resume+0x71/0xb0
> : [<ffffffff81625be2>] int_signal+0x12/0x17
> :Code: c7 80 1c c4 81 e8 8f 5a 4d 00 48 89 df e8 77 80 1a 00 49 89 5e e0 49 89 5e e8 48 c7 c7 80 1c c4 81 e8 13 5a 4d 00 e9 1c ff ff ff <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 41 57 41 
> :RIP  [<ffffffff81145792>] shmem_evict_inode+0x112/0x120
> : RSP <ffff88012b94ddb8>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
