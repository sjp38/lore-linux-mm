Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9C68E6B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 11:35:39 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id u188so29892766wmu.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 08:35:39 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id w192si6322903wme.65.2016.01.05.08.35.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 08:35:38 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id f206so29608082wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 08:35:38 -0800 (PST)
Date: Tue, 5 Jan 2016 17:35:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [4.4-rc7] spinlock recursion while oom'ing.
Message-ID: <20160105163535.GD15594@dhcp22.suse.cz>
References: <20160103222728.GA11973@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160103222728.GA11973@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

[CCing David]

On Sun 03-01-16 17:27:28, Dave Jones wrote:
> This is an odd one..
> 
> Out of memory: Kill process 5861 (trinity-c10) score 504 or sacrifice child
> BUG: spinlock recursion on CPU#1, trinity-c8/8828
>  lock: 0xffff8800a3635410, .magic: dead4ead, .owner: trinity-c8/8828, .owner_cpu: 1
> CPU: 1 PID: 8828 Comm: trinity-c8 Not tainted 4.4.0-rc7-gelk-debug+ #3 
>  00000000000001f8 ffff8800968d7808 ffffffff9a4d4451 ffff8800a3635410
>  ffff8800968d7838 ffffffff9a117b36 ffff8800a3635410 ffff8800a3635420
>  ffff8800a3635410 ffff8800a3635398 ffff8800968d7870 ffffffff9a117d63
> Call Trace:
>  [<ffffffff9a4d4451>] dump_stack+0x4e/0x7d
>  [<ffffffff9a117b36>] spin_dump+0xc6/0x130
>  [<ffffffff9a117d63>] do_raw_spin_lock+0x163/0x1a0
>  [<ffffffff9aae15ef>] _raw_spin_lock+0x1f/0x30
>  [<ffffffff9a2271cb>] find_lock_task_mm+0x5b/0xd0
>  [<ffffffff9a227cc0>] oom_kill_process+0x2a0/0x660
>  [<ffffffff9a22855d>] out_of_memory+0x45d/0x4b0

Hmm, this is indeed weird. We are certainly not holding task_lock during
the allocation AFAICS (if yes that would be a GFP_KERNEL allocation with
a spinlock so I would assume a blow up earlier than when entering OOM).

oom_badness unlocks in all paths AFAICS. oom_kill_process will lock the
victim again but it releases the lock as well. dump_tasks the same.

>  [<ffffffff9a228100>] ? check_panic_on_oom+0x80/0x80
>  [<ffffffff9a22f4af>] ? __alloc_pages_direct_compact+0x7f/0x160
>  [<ffffffff9a2302d0>] __alloc_pages_nodemask+0xd40/0xe80
>  [<ffffffff9a0a2ae9>] ? copy_process+0x1d9/0x2ab0
>  [<ffffffff9a22f590>] ? __alloc_pages_direct_compact+0x160/0x160
>  [<ffffffff9a294700>] ? print_section+0x50/0x60
>  [<ffffffff9a0deff1>] ? preempt_count_sub+0xc1/0x120
>  [<ffffffff9aada916>] ? preempt_schedule_irq+0x86/0xb0
>  [<ffffffff9aae28bd>] ? retint_kernel+0x1b/0x1d
>  [<ffffffff9a2973f3>] ? deactivate_slab+0x3a3/0x400
>  [<ffffffff9aae1758>] ? _raw_spin_unlock+0x18/0x30
>  [<ffffffff9a297be5>] ? __slab_alloc.isra.62.constprop.64+0x45/0x50
>  [<ffffffff9a29c00e>] ? kasan_kmalloc+0x5e/0x70
>  [<ffffffff9a29c2ed>] ? kasan_slab_alloc+0xd/0x10
>  [<ffffffff9a297ce1>] ? kmem_cache_alloc+0xf1/0x200
>  [<ffffffff9a230505>] alloc_kmem_pages_node+0x25/0x30
>  [<ffffffff9a0a2b07>] copy_process+0x1f7/0x2ab0
>  [<ffffffff9a0def4a>] ? preempt_count_sub+0x1a/0x120
>  [<ffffffff9aae1758>] ? _raw_spin_unlock+0x18/0x30
>  [<ffffffff9a4f0d32>] ? iov_iter_init+0x82/0xc0
>  [<ffffffff9a141d82>] ? jiffies_to_timeval+0x52/0x70
>  [<ffffffff9a1ab530>] ? taskstats_exit+0x5a0/0x5a0
>  [<ffffffff9a0f1b4f>] ? sched_clock_local+0x3f/0xb0
>  [<ffffffff9a0a2910>] ? __cleanup_sighand+0x30/0x30
>  [<ffffffff9a1abf40>] ? acct_account_cputime+0x40/0x50
>  [<ffffffff9a0deff1>] ? preempt_count_sub+0xc1/0x120
>  [<ffffffff9a0a5637>] _do_fork+0x107/0x510
>  [<ffffffff9a0a5530>] ? fork_idle+0x130/0x130
>  [<ffffffff9a002f20>] ? enter_from_user_mode+0x50/0x50
>  [<ffffffff9a501f43>] ? __this_cpu_preempt_check+0x13/0x20
>  [<ffffffff9a21ebc5>] ? __context_tracking_enter+0x95/0x140
>  [<ffffffff9a1e2f20>] ? syscall_exit_register+0x310/0x310
>  [<ffffffff9a0a5ae9>] SyS_clone+0x19/0x20
>  [<ffffffff9aae1ef9>] tracesys_phase2+0x84/0x89
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
