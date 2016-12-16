Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30C766B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:00:47 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id hb5so35563091wjc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:00:47 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ui11si7092035wjb.278.2016.12.16.06.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:00:45 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so5675705wmu.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:00:45 -0800 (PST)
Date: Fri, 16 Dec 2016 15:00:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: crash during oom reaper
Message-ID: <20161216140043.GN13940@dhcp22.suse.cz>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 16-12-16 14:14:17, Vegard Nossum wrote:
[...]
> Out of memory: Kill process 1650 (trinity-main) score 90 or sacrifice child
> Killed process 1724 (trinity-c14) total-vm:37280kB, anon-rss:236kB,
> file-rss:112kB, shmem-rss:112kB
> BUG: unable to handle kernel NULL pointer dereference at 00000000000001e8
> IP: [<ffffffff8126b1c0>] copy_process.part.41+0x2150/0x5580
> PGD c001067 PUD c000067
> PMD 0
> Oops: 0002 [#1] PREEMPT SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> CPU: 28 PID: 1650 Comm: trinity-main Not tainted 4.9.0-rc6+ #317

Hmm, so this was the oom victim initially but we have decided to kill
its child 1724 instead.

> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> task: ffff88000f9bc440 task.stack: ffff88000c778000
> RIP: 0010:[<ffffffff8126b1c0>]  [<ffffffff8126b1c0>]
> copy_process.part.41+0x2150/0x5580

Could you match this to the kernel source please?

> RSP: 0018:ffff88000c77fc18  EFLAGS: 00010297
> RAX: 0000000000000000 RBX: ffff88000fa11c00 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: dffffc0000000000 RDI: ffff88000f2a33b0
> RBP: ffff88000c77fdb0 R08: ffff88000c77f900 R09: 0000000000000002
> R10: 00000000cb9401ca R11: 00000000c6eda739 R12: ffff88000f894d00
> R13: ffff88000c7c4700 R14: ffff88000fa11c50 R15: ffff88000f2a3200
> FS:  00007fb7d2a24700(0000) GS:ffff880011b00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000000001e8 CR3: 000000001010d000 CR4: 00000000000406e0
> Stack:
>  0000000000000046 0000000001200011 ffffed0001f129ac ffff88000f894d60
>  0000000000000000 0000000000000000 ffff88000f894d08 ffff88000f894da0
>  ffff88000c7a8620 ffff88000f020318 ffff88000fa11c18 ffff88000f894e40
> Call Trace:
>  [<ffffffff81269070>] ? __cleanup_sighand+0x50/0x50
>  [<ffffffff81fd552e>] ? memzero_explicit+0xe/0x10
>  [<ffffffff822cb592>] ? urandom_read+0x232/0x4d0
>  [<ffffffff8126e974>] _do_fork+0x1a4/0xa40

and here we are copying the pid 1650 to its child. I am wondering
whether that might be the killed child. But the child is visible only
very late during the fork to the oom killer.

>  [<ffffffff8126e7d0>] ? fork_idle+0x180/0x180
>  [<ffffffff81002dba>] ? syscall_trace_enter+0x3aa/0xd40
>  [<ffffffff815179ea>] ? __context_tracking_exit.part.4+0x9a/0x1e0
>  [<ffffffff81002a10>] ? exit_to_usermode_loop+0x150/0x150
>  [<ffffffff8201df57>] ? check_preemption_disabled+0x37/0x1e0
>  [<ffffffff8126f2e7>] SyS_clone+0x37/0x50
>  [<ffffffff83caea50>] ? ptregs_sys_rt_sigreturn+0x10/0x10
>  [<ffffffff8100524f>] do_syscall_64+0x1af/0x4d0
>  [<ffffffff83cae974>] entry_SYSCALL64_slow_path+0x25/0x25
> Code: be 00 00 00 00 00 fc ff df 48 c1 e8 03 80 3c 30 00 74 08 4c 89 f7 e8
> d0 7d 3c 00 f6 43 51 08 74 11 e8 45 fa 1d 00 48 8b 44 24 20 <f0> ff 88 e8 01
> 00 00 e8 34 fa 1d 00 48 8b 44 24 70 48 83 c0 60
> RIP  [<ffffffff8126b1c0>] copy_process.part.41+0x2150/0x5580
>  RSP <ffff88000c77fc18>
> CR2: 00000000000001e8
> ---[ end trace b8f81ad60c106e75 ]---
> 
> Manifestation 2:
> 
> Killed process 1775 (trinity-c21) total-vm:37404kB, anon-rss:232kB,
> file-rss:420kB, shmem-rss:116kB
> oom_reaper: reaped process 1775 (trinity-c21), now anon-rss:0kB,
> file-rss:0kB, shmem-rss:116kB
> ==================================================================
> BUG: KASAN: use-after-free in p9_client_read+0x8f0/0x960 at addr
> ffff880010284d00
> Read of size 8 by task trinity-main/1649
> CPU: 3 PID: 1649 Comm: trinity-main Not tainted 4.9.0+ #318
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>  ffff8800068a7770 ffffffff82012301 ffff88001100f600 ffff880010284d00
>  ffff880010284d60 ffff880010284d00 ffff8800068a7798 ffffffff8165872c
>  ffff8800068a7828 ffff880010284d00 ffff88001100f600 ffff8800068a7818
> Call Trace:
>  [<ffffffff82012301>] dump_stack+0x83/0xb2
>  [<ffffffff8165872c>] kasan_object_err+0x1c/0x70
>  [<ffffffff816589c5>] kasan_report_error+0x1f5/0x4e0
>  [<ffffffff81657d92>] ? kasan_slab_alloc+0x12/0x20
>  [<ffffffff82079357>] ? check_preemption_disabled+0x37/0x1e0
>  [<ffffffff81658e4e>] __asan_report_load8_noabort+0x3e/0x40
>  [<ffffffff82079300>] ? assoc_array_gc+0x1310/0x1330
>  [<ffffffff83b84c30>] ? p9_client_read+0x8f0/0x960
>  [<ffffffff83b84c30>] p9_client_read+0x8f0/0x960

no idea how we would end up with use after here. Even if I unmapped the
page then the read code should be able to cope with that. This smells
like a p9 issue to me.

[...]
> Manifestation 3:
> 
> Out of memory: Kill process 1650 (trinity-main) score 91 or sacrifice child
> Killed process 1731 (trinity-main) total-vm:37140kB, anon-rss:192kB,
> file-rss:0kB, shmem-rss:0kB
> ==================================================================
> BUG: KASAN: use-after-free in unlink_file_vma+0xa5/0xb0 at addr
> ffff880006689db0
> Read of size 8 by task trinity-main/1731
> CPU: 5 PID: 1731 Comm: trinity-main Not tainted 4.9.0 #314
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>  ffff880000aaf7f8 ffffffff81fb1ab1 ffff8800110ed500 ffff880006689c00
>  ffff880006689db8 ffff880000aaf998 ffff880000aaf820 ffffffff8162c5ac
>  ffff880000aaf8b0 ffff880006689c00Out of memory: Kill process 1650
> (trinity-main) score 91 or sacrifice child
> Killed process 1650 (trinity-main) total-vm:37140kB, anon-rss:192kB,
> file-rss:140kB, shmem-rss:18632kB
> oom_reaper: reaped process 1650 (trinity-main), now anon-rss:0kB,
> file-rss:0kB, shmem-rss:18632kB
>  ffff8800110ed500 ffff880000aaf8a0
> Call Trace:
>  [<ffffffff81fb1ab1>] dump_stack+0x83/0xb2
>  [<ffffffff8162c5ac>] kasan_object_err+0x1c/0x70
>  [<ffffffff8162c845>] kasan_report_error+0x1f5/0x4e0
>  [<ffffffff815afd80>] ? vm_normal_page_pmd+0x240/0x240
>  [<ffffffff8162ccce>] __asan_report_load8_noabort+0x3e/0x40
>  [<ffffffff815c4305>] ? unlink_file_vma+0xa5/0xb0
>  [<ffffffff815c4305>] unlink_file_vma+0xa5/0xb0

Hmm, the oom repaper doesn't touch vma->vm_file so I do not see how it
could be related to the activity of the reaper. I will have a look
closer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
