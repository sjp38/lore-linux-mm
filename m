Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6118E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 15:46:11 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id w126-v6so3673935qka.11
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 12:46:11 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v13-v6sor1660602qtj.126.2018.09.27.12.46.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 12:46:09 -0700 (PDT)
Date: Thu, 27 Sep 2018 12:46:01 -0700
Message-Id: <20180927194601.207765-1-wonderfly@google.com>
Mime-Version: 1.0
Subject: 4.14 backport request for dbdda842fe96f: "printk: Add console owner
 and waiter logic to load balance console writes"
From: Daniel Wang <wonderfly@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org
Cc: pmladek@suse.com, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@I-love.SAKURA.ne.jp, peterz@infradead.org, rostedt@goodmis.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, xiyou.wangcong@gmail.com, pfeiner@google.com

Prior to this change, the combination of `softlockup_panic=1` and
`softlockup_all_cpu_stacktrace=1` may result in a deadlock when the reboot path
is trying to grab the console lock that is held by the stack trace printing
path. What seems to be happening is that while there are multiple CPUs, only one
of them is tasked to print the back trace of all CPUs. On a machine with many
CPUs and a slow serial console (on Google Compute Engine for example), the stack
trace printing routine hits a timeout and the reboot path kicks in. The latter
then tries to print something else, but can't get the lock because it's still
held by earlier printing path. This is easily reproducible on a VM with 16+
vCPUs on Google Compute Engine - which is a very common scenario.

A quick repro is available at
https://github.com/wonderfly/printk-deadlock-repro. The system hangs 3 seconds
into executing repro.sh. Both deadlock analysis and repro are credits to Peter
Feiner.

Note that I have read previous discussions on backporting this to stable [1].
The argument for objecting the backport was that this is a non-trivial fix and
is supported to prevent hypothetical soft lockups. What we are hitting is a real
deadlock, in production, however. Hence this request.

[1] https://lore.kernel.org/lkml/20180409081535.dq7p5bfnpvd3xk3t@pathway.suse.cz/T/#u

Serial console logs leading up to the deadlock. As can be seen the stack trace
was incomplete because the printing path hit a timeout.

```
lockup-test-16-2 login: [  206.648060] LoadPin: kernel-module pinning-ignored obj="/tmp/release/hog.ko" pid=3003 cmdline="insmod hog.ko"
[  206.650851] hog: loading out-of-tree module taints kernel.
[  206.654761] Hogging a CPU now
[  209.577900] watchdog: BUG: soft lockup - CPU#13 stuck for 3s! [hog:3010]
[  209.584883] Modules linked in: hog(O) ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 xt_addrtype nf_nat br_netfilter ip6table_filter ip6_tables aesni_intel aes_x86_64 crypto_simd cryptd glue_helper
[  209.603952] CPU: 13 PID: 3010 Comm: hog Tainted: G           O     4.14.0+ #11
[  209.611390] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.620733] task: ffff9501b8ca9d00 task.stack: ffffb99c0732c000
[  209.626766] RIP: 0010:hog_thread+0x13/0x1000 [hog]
[  209.631763] RSP: 0018:ffffb99c0732ff10 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff11
[  209.639466] RAX: 0000000000000011 RBX: ffff9501bc1af580 RCX: 0000000000000000
[  209.646818] RDX: ffff9501c3554d80 RSI: ffff9501c354cc38 RDI: ffff9501c354cc38
[  209.654087] RBP: ffffb99c0732ff48 R08: 0000000000000030 R09: 0000000000000000
[  209.661510] R10: ffffb99c08df3ce0 R11: 0000000000000000 R12: ffff9501aeab8e80
[  209.668773] R13: ffffb99c0803bc28 R14: 0000000000000000 R15: ffff9501bc1af5c8
[  209.676089] FS:  0000000000000000(0000) GS:ffff9501c3540000(0000) knlGS:0000000000000000
[  209.684292] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.690150] CR2: 00007f146fd8aba0 CR3: 0000000b0ba11006 CR4: 00000000003606a0
[  209.697571] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  209.704936] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  209.712184] Call Trace:
[  209.714853]  kthread+0x120/0x160
[  209.718198]  ? 0xffffffffc0307000
[  209.721641]  ? kthread_stop+0x120/0x120
[  209.725591]  ? ret_from_fork+0x1f/0x30
[  209.729462] Code: <eb> fe 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
[  209.737518] Sending NMI from CPU 13 to CPUs 0-12,14-15:
[  209.742864] NMI backtrace for cpu 0
[  209.742868] CPU: 0 PID: 2866 Comm: dd Tainted: G           O     4.14.0+ #11
[  209.742868] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.742870] task: ffff95019d150000 task.stack: ffffb99c08d98000
[  209.742875] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[  209.742876] RSP: 0018:ffffb99c08d9bda8 EFLAGS: 00000002
[  209.742877] RAX: 0000000000000001 RBX: ffff9501c2cdda68 RCX: 0000000000000000
[  209.742877] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9501c2cdda68
[  209.742878] RBP: ffffb99c08d9bdd8 R08: 000000007f569b7d R09: 000000006930609f
[  209.742880] R10: 000000000a41d205 R11: 000000008b5d54b4 R12: ffff9501c2cdda68
[  209.742881] R13: ffffb99c08d9be30 R14: ffffb99c08d9be30 R15: 0000000000000040
[  209.742882] FS:  00007f2605cd3700(0000) GS:ffff9501c3200000(0000) knlGS:0000000000000000
[  209.742883] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.742884] CR2: 00007fe4acdfe9c0 CR3: 0000000ef55fa001 CR4: 00000000003606b0
[  209.742888] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  209.742889] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  209.742890] Call Trace:
[  209.742895]  do_raw_spin_lock+0xa0/0xb0
[  209.742900]  _raw_spin_lock_irqsave+0x20/0x30
[  209.742905]  _extract_crng+0x45/0x120
[  209.742907]  ? urandom_read+0xfa/0x2a0
[  209.742910]  ? vfs_read+0xad/0x170
[  209.742912]  ? SyS_read+0x4b/0xa0
[  209.742916]  ? __audit_syscall_exit+0x21e/0x2c0
[  209.742918]  ? do_syscall_64+0x63/0x1f0
[  209.742920]  ? entry_SYSCALL64_slow_path+0x25/0x25
[  209.742921] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 f5 b4 98 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00 00 b9 
[  209.742940] NMI backtrace for cpu 8
[  209.742942] CPU: 8 PID: 2883 Comm: dd Tainted: G           O     4.14.0+ #11
[  209.742943] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.742943] task: ffff95019d260000 task.stack: ffffb99c07bec000
[  209.742945] RIP: 0010:native_queued_spin_lock_slowpath+0x20/0x1b0
[  209.742946] RSP: 0018:ffffb99c07befda8 EFLAGS: 00000097
[  209.742947] RAX: 0000000000000001 RBX: ffff9501c2cdda68 RCX: 0000000000000000
[  209.742948] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9501c2cdda68
[  209.742948] RBP: ffffb99c07befdd8 R08: 000000007f6dbc9d R09: 0000000011140320
[  209.742949] R10: 00000000cde5e021 R11: 000000008b7475d4 R12: ffff9501c2cdda68
[  209.742950] R13: ffffb99c07befe30 R14: ffffb99c07befe30 R15: 0000000000000040
[  209.742951] FS:  00007f9247798700(0000) GS:ffff9501c3400000(0000) knlGS:0000000000000000
[  209.742952] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.742953] CR2: 0000561d05e288b0 CR3: 0000000edd2c2001 CR4: 00000000003606a0
[  209.742956] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  209.742956] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  209.742957] Call Trace:
[  209.742959]  do_raw_spin_lock+0xa0/0xb0
[  209.742961]  _raw_spin_lock_irqsave+0x20/0x30
[  209.742962]  _extract_crng+0x45/0x120
[  209.742964]  ? urandom_read+0xfa/0x2a0
[  209.742966]  ? vfs_read+0xad/0x170
[  209.742967]  ? SyS_read+0x4b/0xa0
[  209.742969]  ? __audit_syscall_exit+0x21e/0x2c0
[  209.742970]  ? do_syscall_64+0x63/0x1f0
[  209.742971]  ? entry_SYSCALL64_slow_path+0x25/0x25
[  209.742972] Code: 00 00 00 e9 1d fe ff ff 0f 1f 00 0f 1f 44 00 00 8b 05 f5 b4 98 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 <85> c0 75 f2 5d c3 f3 90 eb ec 81 fe 00 01 00 00 0f 84 9a 00 00 
[  209.742991] NMI backtrace for cpu 5
[  209.742994] CPU: 5 PID: 2872 Comm: dd Tainted: G           O     4.14.0+ #11
[  209.742994] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.742995] task: ffff95019f229d00 task.stack: ffffb99c07d00000
[  209.742998] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[  209.742999] RSP: 0018:ffffb99c07d03da8 EFLAGS: 00000002
[  209.743000] RAX: 0000000000000001 RBX: ffff9501c2cdda68 RCX: 0000000000000000
[  209.743001] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9501c2cdda68
[  209.743005] RBP: ffffb99c07d03dd8 R08: 00000000d10b17ce R09: 000000004db462a0
[  209.743006] R10: 00000000fe50950b R11: 00000000dd11d105 R12: ffff9501c2cdda68
[  209.743006] R13: ffffb99c07d03e30 R14: ffffb99c07d03e30 R15: 0000000000000040
[  209.743008] FS:  00007fd82c5e2700(0000) GS:ffff9501c3340000(0000) knlGS:0000000000000000
[  209.743009] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.743009] CR2: 00007f43a5388b20 CR3: 0000000ef5f9d004 CR4: 00000000003606a0
[  209.743013] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  209.743013] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  209.743014] Call Trace:
[  209.743017]  do_raw_spin_lock+0xa0/0xb0
[  209.743020]  _raw_spin_lock_irqsave+0x20/0x30
[  209.743024]  _extract_crng+0x45/0x120
[  209.743026]  ? urandom_read+0xfa/0x2a0
[  209.743028]  ? vfs_read+0xad/0x170
[  209.743030]  ? SyS_read+0x4b/0xa0
[  209.743033]  ? __audit_syscall_exit+0x21e/0x2c0
[  209.743034]  ? do_syscall_64+0x63/0x1f0
[  209.743036]  ? entry_SYSCALL64_slow_path+0x25/0x25
[  209.743037] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 f5 b4 98 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00 00 b9 
[  209.743059] NMI backtrace for cpu 6
[  209.743061] CPU: 6 PID: 2893 Comm: dd Tainted: G           O     4.14.0+ #11
[  209.743062] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.743063] task: ffff95019d2e2b80 task.stack: ffffb99c07e30000
[  209.743066] RIP: 0010:native_queued_spin_lock_slowpath+0x18/0x1b0
[  209.743067] RSP: 0018:ffffb99c07e33da8 EFLAGS: 00000002
[  209.743068] RAX: 0000000000000001 RBX: ffff9501c2cdda68 RCX: 0000000000000000
[  209.743069] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9501c2cdda68
[  209.743069] RBP: ffffb99c07e33dd8 R08: 00000000ae91c56e R09: 00000000aa3ad454
[  209.743070] R10: 00000000646b9d65 R11: 00000000ba987ea5 R12: ffff9501c2cdda68
[  209.743071] R13: ffffb99c07e33e30 R14: ffffb99c07e33e30 R15: 0000000000000040
[  209.743072] FS:  00007f525c77c700(0000) GS:ffff9501c3380000(0000) knlGS:0000000000000000
[  209.743073] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.743074] CR2: 00007f11dcd8c8c0 CR3: 0000000edd2b0004 CR4: 00000000003606a0
[  209.743077] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  209.743078] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  209.743078] Call Trace:
[  209.743082]  do_raw_spin_lock+0xa0/0xb0
[  209.743084]  _raw_spin_lock_irqsave+0x20/0x30
[  209.743087]  _extract_crng+0x45/0x120
[  209.743089]  ? urandom_read+0xfa/0x2a0
[  209.743091]  ? vfs_read+0xad/0x170
[  209.743092]  ? SyS_read+0x4b/0xa0
[  209.743094]  ? __audit_syscall_exit+0x21e/0x2c0
[  209.743096]  ? do_syscall_64+0x63/0x1f0
[  209.743097]  ? entry_SYSCALL64_slow_path+0x25/0x25
[  209.743098] Code: 48 8b 2c 24 48 c7 00 00 00 00 00 e9 1d fe ff ff 0f 1f 00 0f 1f 44 00 00 8b 05 f5 b4 98 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 <85> c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 eb ec 81 fe 00 
[  209.743119] NMI backtrace for cpu 14
[  209.743120] CPU: 14 PID: 2885 Comm: dd Tainted: G           O     4.14.0+ #11
[  209.743121] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.743122] task: ffff95019d1c8e80 task.stack: ffffb99c07e08000
[  209.743124] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[  209.743124] RSP: 0018:ffffb99c07e0bda8 EFLAGS: 00000002
[  209.743126] RAX: 0000000000000001 RBX: ffff9501c2cdda68 RCX: 0000000000000000
[  209.743126] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9501c2cdda68
[  209.743127] RBP: ffffb99c07e0bdd8 R08: 00000000482066d2 R09: 000000005b007fea
[  209.743128] R10: 0000000012b1557e R11: 0000000054272009 R12: ffff9501c2cdda68
[  209.743129] R13: ffffb99c07e0be30 R14: ffffb99c07e0be30 R15: 0000000000000040
[  209.743130] FS:  00007f4282ed5700(0000) GS:ffff9501c3580000(0000) knlGS:0000000000000000
[  209.743131] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.743131] CR2: 00007f32728e9ba0 CR3: 0000000edd0d7006 CR4: 00000000003606a0
[  209.743135] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  209.743136] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  209.743136] Call Trace:
[  209.743139]  do_raw_spin_lock+0xa0/0xb0
[  209.743141]  _raw_spin_lock_irqsave+0x20/0x30
[  209.743143]  _extract_crng+0x45/0x120
[  209.743145]  ? urandom_read+0xfa/0x2a0
[  209.743147]  ? vfs_read+0xad/0x170
[  209.743148]  ? SyS_read+0x4b/0xa0
[  209.743150]  ? __audit_syscall_exit+0x21e/0x2c0
[  209.743151]  ? do_syscall_64+0x63/0x1f0
[  209.743152]  ? entry_SYSCALL64_slow_path+0x25/0x25
[  209.743153] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 f5 b4 98 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00 00 b9 
[  209.743174] NMI backtrace for cpu 1
[  209.743176] CPU: 1 PID: 2865 Comm: dd Tainted: G           O     4.14.0+ #11
[  209.743177] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.743178] task: ffff95019d110000 task.stack: ffffb99c07d18000
[  209.743181] RIP: 0010:native_queued_spin_lock_slowpath+0x18/0x1b0
[  209.743182] RSP: 0018:ffffb99c07d1bda8 EFLAGS: 00000002
[  209.743183] RAX: 0000000000000001 RBX: ffff9501c2cdda68 RCX: 0000000000000000
[  209.743184] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9501c2cdda68
[  209.743184] RBP: ffffb99c07d1bdd8 R08: 0000000052b91797 R09: 000000002f2f8e5c
[  209.743185] R10: 00000000c5b37258 R11: 000000005ebfd0ce R12: ffff9501c2cdda68
[  209.743186] R13: ffffb99c07d1be30 R14: ffffb99c07d1be30 R15: 0000000000000040
[  209.743187] FS:  00007fd12de78700(0000) GS:ffff9501c3240000(0000) knlGS:0000000000000000
[  209.743188] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  209.743189] CR2: 00007f3f9d1beba0 CR3: 0000000eddffa003 CR4: 00000000003606a0
[  209.743192] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  209.743193] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  209.743193] Call Trace:
[  209.743197]  do_raw_spin_lock+0xa0/0xb0
[  209.743200]  _raw_spin_lock_irqsave+0x20/0x30
[  209.743202]  _extract_crng+0x45/0x120
[  209.743204]  ? urandom_read+0xfa/0x2a0
[  209.743206]  ? vfs_read+0xad/0x170
[  209.743207]  ? SyS_read+0x4b/0xa0
[  209.743209]  ? __audit_syscall_exit+0x21e/0x2c0
[  209.743211]  ? do_syscall_64+0x63/0x1f0
[  209.743212]  ? entry_SYSCALL64_slow_path+0x25/0x25
[  209.743213] Code: 48 8b 2c 24 48 c7 00 00 00 00 00 e9 1d fe ff ff 0f 1f 00 0f 1f 44 00 00 8b 05 f5 b4 98 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 <85> c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 eb ec 81 fe 00 
[  209.743235] NMI backtrace for cpu 7
[  209.743238] CPU: 7 PID: 2884 Comm: dd Tainted: G           O     4.14.0+ #11
[  209.743238] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  209.743239] task: ffff95019f259d00 task.stack: ffffb99c078f4000
[  209.743242] RIP: 0010:native_queued_spin_lock_slowpath+0x18/0x1b0
[  209.743243] RSP: 0018:ffffb99c078f7da8 EFLAGS: 00000002
[  209.743244] RAX: 0000000000000001 RBX: ffff9501c2cdda68 RCX: 0000000000000000
[  209.743245] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9501c2cdda68
[  209.74
```
