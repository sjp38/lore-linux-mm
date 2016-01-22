Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 89D626B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:50:53 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id uo6so43039043pac.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 05:50:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id k67si9732885pfb.171.2016.01.22.05.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 05:50:52 -0800 (PST)
Date: Fri, 22 Jan 2016 16:50:42 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: PROBLEM: BUG when using memory.kmem.limit_in_bytes
Message-ID: <20160122135042.GF26192@esperanza>
References: <CAKB58ikDkzc8REt31WBkD99+hxNzjK4+FBmhkgS+NVrC9vjMSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAKB58ikDkzc8REt31WBkD99+hxNzjK4+FBmhkgS+NVrC9vjMSg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Christiansen <brian.o.christiansen@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hi Brian,

Thanks for the report.

I managed to reproduce the bug on the latest mmotm kernel using the
script you attached, so it isn't ubuntu-specific:

: kernel BUG at mm/memcontrol.c:2929!
: invalid opcode: 0000 [#1] SMP
: CPU: 0 PID: 4441 Comm: kworker/0:2 Not tainted 4.4.0-mm1+ #256
: Workqueue: cgroup_destroy css_killed_work_fn
: task: ffff8800aaddd880 ti: ffff8800369b0000 task.ti: ffff8800369b0000
: RIP: 0010:[<ffffffff81220551>]  [<ffffffff81220551>] memcg_offline_kmem+0xd1/0xe0
: RSP: 0018:ffff8800369b3b08  EFLAGS: 00010293
: RAX: ffff8800a9cba800 RBX: ffff8800ab1c7000 RCX: 0000000000000003
: RDX: ffff8800a9cba850 RSI: ffff8800ab1c7060 RDI: ffff8800ab1c1000
: RBP: ffff8800369b3b28 R08: 0000000000000001 R09: 0000000000000000
: R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800ab1c5000
: R13: 0000000000000000 R14: ffff8800ab1c7650 R15: ffff8800ab1c7640
: FS:  0000000000000000(0000) GS:ffff88014ae00000(0000) knlGS:0000000000000000
: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
: CR2: 00007f3ad9d3b090 CR3: 0000000148d61000 CR4: 00000000000006f0
: Stack:
:  ffff8800369b3b28 ffff8800ab1c7640 ffff8800ab1c7640 ffff8800ab1c7000
:  ffff8800369b3b88 ffffffff81220601 0000000000000001 0000000000000000
:  0000000000000002 ffff8800aaddd880 ffff8800369b3b88 ffff8800ab1c7090
: Call Trace:
:  [<ffffffff81220601>] mem_cgroup_css_offline+0xa1/0xc0
:  [<ffffffff81124b5c>] css_killed_work_fn+0x5c/0x170
:  [<ffffffff8109ea30>] process_one_work+0x200/0x560
:  [<ffffffff8109e99f>] ? process_one_work+0x16f/0x560
:  [<ffffffff810d2bb2>] ? __lock_acquire+0x1a2/0x440
:  [<ffffffff8109f6d4>] ? worker_thread+0x204/0x530
:  [<ffffffff8109f6c7>] ? worker_thread+0x1f7/0x530
:  [<ffffffff8109f63e>] worker_thread+0x16e/0x530
:  [<ffffffff816f2eb4>] ? __schedule+0x354/0x900
:  [<ffffffff810b2e22>] ? default_wake_function+0x12/0x20
:  [<ffffffff810ca356>] ? __wake_up_common+0x56/0x90
:  [<ffffffff8109f4d0>] ? maybe_create_worker+0x110/0x110
:  [<ffffffff816f3567>] ? schedule+0x47/0xc0
:  [<ffffffff8109f4d0>] ? maybe_create_worker+0x110/0x110
:  [<ffffffff810a4ac9>] kthread+0xe9/0x110
:  [<ffffffff810af22e>] ? schedule_tail+0x1e/0xd0
:  [<ffffffff810a49e0>] ? __init_kthread_worker+0x70/0x70
:  [<ffffffff816f92cf>] ret_from_fork+0x3f/0x70
:  [<ffffffff810a49e0>] ? __init_kthread_worker+0x70/0x70

>From first glance, it looks like the bug was triggered, because
mem_cgroup_css_offline was run for a child cgroup earlier than for its
parent. This couldn't happen for sure before the cgroup was switched to
percpu_ref, because cgroup_destroy_wq has always had max_active == 1.
Now, however, it looks like this is perfectly possible for
css_killed_ref_fn is called from an rcu callback - see kill_css ->
percpu_ref_kill_and_confirm. This breaks kmemcg assumptions.

I'll take a look what can be done about that.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
