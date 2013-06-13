Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 2E2C16B0036
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 07:48:28 -0400 (EDT)
Received: by mail-vb0-f49.google.com with SMTP id 12so3362886vbf.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2013 04:48:27 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 13 Jun 2013 13:48:27 +0200
Message-ID: <CAFLxGvzKes7mGknTJgqFamr_-ODPBArf6BajF+m5x-S4AEtdmQ@mail.gmail.com>
Subject: mem_cgroup_page_lruvec: BUG: unable to handle kernel NULL pointer
 dereference at 00000000000001a8
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups mailinglist <cgroups@vger.kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, bsingharora@gmail.com, Michal Hocko <mhocko@suse.cz>, hannes@cmpxchg.org

Hi!

While playing with user namespaces my kernel crashed under heavy load.
Kernel is 3.9.0 plus some trivial patches.

[35355.882105] BUG: unable to handle kernel NULL pointer dereference
at 00000000000001a8
[35355.883056] IP: [<ffffffff811297d9>] mem_cgroup_page_lruvec+0x79/0x90
[35355.883056] PGD 0
[35355.883056] Oops: 0000 [#1] SMP
[35355.883056] CPU 3
[35355.883056] Pid: 477, comm: kswapd0 Not tainted 3.9.0+ #12 Bochs Bochs
[35355.883056] RIP: 0010:[<ffffffff811297d9>]  [<ffffffff811297d9>]
mem_cgroup_page_lruvec+0x79/0x90
[35355.883056] RSP: 0000:ffff88003d523aa8  EFLAGS: 00010002
[35355.883056] RAX: 0000000000000138 RBX: ffff88003fffa600 RCX: ffff88003e04a800
[35355.883056] RDX: 0000000000000020 RSI: 0000000000000000 RDI: 0000000000028500
[35355.883056] RBP: ffff88003d523ab8 R08: 0000000000000000 R09: 0000000000000000
[35355.883056] R10: 0000000000000000 R11: dead000000100100 R12: ffffea0000a14000
[35355.883056] R13: ffff88003e04b138 R14: ffff88003d523bb8 R15: ffffea0000a14020
[35355.883056] FS:  0000000000000000(0000) GS:ffff88003fd80000(0000)
knlGS:0000000000000000
[35355.883056] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[35355.883056] CR2: 00000000000001a8 CR3: 0000000001a0b000 CR4: 00000000000006e0
[35355.883056] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[35355.883056] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[35355.883056] Process kswapd0 (pid: 477, threadinfo ffff88003d522000,
task ffff88003db6dc40)
[35355.883056] Stack:
[35355.883056]  0000000000000014 ffffea0000a14000 ffff88003d523b28
ffffffff810ea4c5
[35355.883056]  ffff88003d523b90 ffff88003fffa9c0 ffff88003d523b98
0000000000000020
[35355.883056]  ffff88003fffa600 0000000200000003 ffff88003fffa600
ffff88003d523b98
[35355.883056] Call Trace:
[35355.883056]  [<ffffffff810ea4c5>] move_active_pages_to_lru+0x65/0x190
[35355.883056]  [<ffffffff810ec4e7>] shrink_active_list+0x297/0x380
[35355.883056]  [<ffffffff810ebff6>] ? shrink_inactive_list+0x1a6/0x400
[35355.883056]  [<ffffffff810ec815>] shrink_lruvec+0x245/0x4b0
[35355.883056]  [<ffffffff810ecae6>] shrink_zone+0x66/0x180
[35355.883056]  [<ffffffff810edcb4>] balance_pgdat+0x474/0x5b0
[35355.883056]  [<ffffffff810edf58>] kswapd+0x168/0x440
[35355.883056]  [<ffffffff8105d310>] ? abort_exclusive_wait+0xb0/0xb0
[35355.883056]  [<ffffffff810eddf0>] ? balance_pgdat+0x5b0/0x5b0
[35355.883056]  [<ffffffff8105c5fb>] kthread+0xbb/0xc0
[35355.883056]  [<ffffffff8105c540>] ? __kthread_unpark+0x50/0x50
[35355.883056]  [<ffffffff81748eac>] ret_from_fork+0x7c/0xb0
[35355.883056]  [<ffffffff8105c540>] ? __kthread_unpark+0x50/0x50
[35355.883056] Code: 89 50 08 48 89 d1 0f 1f 40 00 49 8b 04 24 48 89
c2 48 c1 e8 38 83 e0 03 48 c1 ea 3a 48 69 c0 38 01 00 00 48 03 84 d1
e0 02 00 00 <48> 3b 58 70 75 0a 48 8b 5d f0 4c 8b 65 f8 c9 c3 48 89 58
70 eb
[35355.883056] RIP  [<ffffffff811297d9>] mem_cgroup_page_lruvec+0x79/0x90
[35355.883056]  RSP <ffff88003d523aa8>
[35355.883056] CR2: 00000000000001a8
[35355.883056] ---[ end trace 2c9b8eec517f960d ]---


--
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
