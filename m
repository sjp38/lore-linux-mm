Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m3E7vLEr004493
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:57:21 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3E7vpNX3928278
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:57:52 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3E7vrSK017873
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:57:54 +1000
Message-ID: <48030DFF.9070407@linux.vnet.ibm.com>
Date: Mon, 14 Apr 2008 13:25:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix oops in oom handling
References: <4802FF10.6030905@cn.fujitsu.com>
In-Reply-To: <4802FF10.6030905@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> When I used a test program to fork mass processes and immediately
> move them to a cgroup where the memory limit is low enough to
> trigger oom kill, I got oops:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000808
> IP: [<ffffffff8045c47f>] _spin_lock_irqsave+0x8/0x18
> PGD 4c95f067 PUD 4406c067 PMD 0
> Oops: 0002 [1] SMP
> CPU 2
> Modules linked in:
> 
> Pid: 11973, comm: a.out Not tainted 2.6.25-rc7 #5
> RIP: 0010:[<ffffffff8045c47f>]  [<ffffffff8045c47f>] _spin_lock_irqsave+0x8/0x18
> RSP: 0018:ffff8100448c7c30  EFLAGS: 00010002
> RAX: 0000000000000202 RBX: 0000000000000009 RCX: 000000000001c9f3
> RDX: 0000000000000100 RSI: 0000000000000001 RDI: 0000000000000808
> RBP: ffff81007e444080 R08: 0000000000000000 R09: ffff8100448c7900
> R10: ffff81000105f480 R11: 00000100ffffffff R12: ffff810067c84140
> R13: 0000000000000001 R14: ffff8100441d0018 R15: ffff81007da56200
> FS:  00007f70eb1856f0(0000) GS:ffff81007fbad3c0(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000808 CR3: 000000004498a000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process a.out (pid: 11973, threadinfo ffff8100448c6000, task ffff81007da533e0)
> Stack:  ffffffff8023ef5a 00000000000000d0 ffffffff80548dc0 00000000000000d0
>  ffff810067c84140 ffff81007e444080 ffffffff8026cef9 00000000000000d0
>  ffff8100441d0000 00000000000000d0 ffff8100441d0000 ffff8100505445c0
> Call Trace:
>  [<ffffffff8023ef5a>] ? force_sig_info+0x25/0xb9
>  [<ffffffff8026cef9>] ? oom_kill_task+0x77/0xe2
>  [<ffffffff8026d696>] ? mem_cgroup_out_of_memory+0x55/0x67
>  [<ffffffff802910ad>] ? mem_cgroup_charge_common+0xec/0x202
>  [<ffffffff8027997b>] ? handle_mm_fault+0x24e/0x77f
>  [<ffffffff8022c4af>] ? default_wake_function+0x0/0xe
>  [<ffffffff8027a17a>] ? get_user_pages+0x2ce/0x3af
>  [<ffffffff80290fee>] ? mem_cgroup_charge_common+0x2d/0x202
>  [<ffffffff8027a441>] ? make_pages_present+0x8e/0xa4
>  [<ffffffff8027d1ab>] ? mmap_region+0x373/0x429
>  [<ffffffff8027d7eb>] ? do_mmap_pgoff+0x2ff/0x364
>  [<ffffffff80210471>] ? sys_mmap+0xe5/0x111
>  [<ffffffff8020bfc9>] ? tracesys+0xdc/0xe1
> 
> Code: 00 00 01 48 8b 3c 24 e9 46 d4 dd ff f0 ff 07 48 8b 3c 24 e9 3a d4 dd ff fe 07 48 8b 3c 24 e9 2f d4 dd ff 9c 58 fa ba 00 01 00 00 <f0> 66 0f c1 17 38 f2 74 06 f3 90 8a 17 eb f6 c3 fa b8 00 01 00
> RIP  [<ffffffff8045c47f>] _spin_lock_irqsave+0x8/0x18
>  RSP <ffff8100448c7c30>
> CR2: 0000000000000808
> ---[ end trace c3702fa668021ea4 ]---
> 
> It's reproducable in a x86_64 box, but doesn't happen in x86_32.
> 
> This is because tsk->sighand is not guarded by RCU, so we have to
> hold tasklist_lock, just as what out_of_memory() does.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu>
> ---
>  mm/oom_kill.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f255eda..beb592f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -423,7 +423,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  	struct task_struct *p;
> 
>  	cgroup_lock();
> -	rcu_read_lock();
> +	read_lock(&tasklist_lock);
>  retry:
>  	p = select_bad_process(&points, mem);
>  	if (PTR_ERR(p) == -1UL)
> @@ -436,7 +436,7 @@ retry:
>  				"Memory cgroup out of memory"))
>  		goto retry;
>  out:
> -	rcu_read_unlock();
> +	read_unlock(&tasklist_lock);
>  	cgroup_unlock();
>  }
>  #endif
> -- 1.5.4.rc3 

This looks sane to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
