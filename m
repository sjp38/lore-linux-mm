Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7175A6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:19:28 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id i38so19355130uag.5
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 23:19:28 -0700 (PDT)
Received: from mail-ua0-x233.google.com (mail-ua0-x233.google.com. [2607:f8b0:400c:c08::233])
        by mx.google.com with ESMTPS id x5si5285405uag.177.2017.06.25.23.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Jun 2017 23:19:27 -0700 (PDT)
Received: by mail-ua0-x233.google.com with SMTP id z22so62326151uah.1
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 23:19:26 -0700 (PDT)
MIME-Version: 1.0
From: Ming Lei <tom.leiming@gmail.com>
Date: Mon, 26 Jun 2017 14:19:25 +0800
Message-ID: <CACVXFVPRAFtZBXL0sV6NGywtHV3QFLkW9zrMaqyDU=ot6ei4Xw@mail.gmail.com>
Subject: v4.12-rc6: kernel hang during booting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi Guys,

I just found that sometimes v4.12-rc6 kernel hang happens during
booting, please see the following stack trace:

[  OK  ] Listening on LVM2 poll daemon socket.
INFO: rcu_preempt detected stalls on CPUs/tasks:
    0-...: (0 ticks this GP) idle=732/140000000000000/0
softirq=1182/1186 fqs=8061
    (detected by 1, t=16252 jiffies, g=86, c=85, q=3)
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 PID: 1 Comm: systemd Not tainted 4.12.0-rc6 #305
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS
rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
task: ffff880234098040 task.stack: ffff8802340a0000
RIP: 0010:___slab_alloc+0x391/0x600
RSP: 0018:ffff8802340a7800 EFLAGS: 00000093
RAX: 0000000000000005 RBX: ffff880235410380 RCX: ffffffff9a36690e
RDX: ffff88027ffdcd80 RSI: ffff880235403d00 RDI: 0000000000000000
RBP: ffff8802340a78c0 R08: 0000000000000000 R09: 0000000000000000
R10: ffff8802340a7800 R11: 0000000000000001 R12: 0000000001080020
R13: ffff880235403d00 R14: 0000000000000002 R15: ffff88027ffddb00
FS:  00007f00143ed8c0(0000) GS:ffff880236000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055d905dba758 CR3: 0000000231d99000 CR4: 00000000003406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 ? alloc_cpumask_var_node+0x3b/0x60
 __slab_alloc.isra.65+0x61/0xa0
 ? __slab_alloc.isra.65+0x61/0xa0
 ? alloc_cpumask_var_node+0x3b/0x60
 ? alloc_cpumask_var_node+0x3b/0x60
 __kmalloc_node+0xe0/0x500
 ? free_cpumask_var+0x9/0x10
 ? kasan_slab_free+0x88/0xc0
 alloc_cpumask_var_node+0x3b/0x60
 alloc_cpumask_var+0xe/0x10
 native_send_call_func_ipi+0x64/0x1e0
 ? smp_stop_nmi_callback+0x180/0x180
 ? __bitmap_and+0xd3/0x100
 ? _find_next_bit+0x31/0xa0
 smp_call_function_many+0x25c/0x330
 ? arch_unregister_cpu+0x40/0x40
 ? arch_unregister_cpu+0x40/0x40
 ? ___slab_alloc+0x413/0x600
 smp_call_function+0x3b/0x70
 ? arch_unregister_cpu+0x40/0x40
 on_each_cpu+0x2f/0xb0
 ? ___slab_alloc+0x412/0x600
 text_poke_bp+0xf0/0x130
 ? poke_int3_handler+0x70/0x70
 ? get_online_cpus+0x2e/0x80
 ? ___slab_alloc+0x412/0x600
 arch_jump_label_transform+0x111/0x1b0
 ? bug_at+0x30/0x30
 ? check_chain_key+0x147/0x1f0
 ? mark_lock+0xc9/0x7b0
 __jump_label_update+0xc2/0xe0
 jump_label_update+0xbc/0x170
 static_key_slow_inc+0xa9/0xc0
 cpuset_css_online+0x95/0x6c0
 online_css+0x51/0xf0
 cgroup_apply_control_enable+0x349/0x4e0
 cgroup_mkdir+0x3db/0x550
 ? cgroup_destroy_locked+0x1f0/0x1f0
 kernfs_iop_mkdir+0xb1/0xe0
 vfs_mkdir+0x1f1/0x2c0
 SyS_mkdir+0x16f/0x1a0
 ? SyS_mkdirat+0x1b0/0x1b0
 ? trace_hardirqs_on_caller+0x1b2/0x2a0
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 entry_SYSCALL_64_fastpath+0x23/0xc2
RIP: 0033:0x7f00129e2727
RSP: 002b:00007ffd7c8bbad8 EFLAGS: 00000246 ORIG_RAX: 0000000000000053
RAX: ffffffffffffffda RBX: ffffffff9a159ce8 RCX: 00007f00129e2727
RDX: 00007ffd7c8bb9a0 RSI: 00000000000001ed RDI: 000055d905cf8eb0
RBP: ffff8802340a7f98 R08: 000000000000fefc R09: 0000000000000000
R10: 000055d905cf8ec0 R11: 0000000000000246 R12: ffffffff9a728503
R13: ffff8802340a7f78 R14: 000055d905d08090 R15: 000055d905d08388
 ? __this_cpu_preempt_check+0x13/0x20
 ? trace_hardirqs_off_caller+0xe8/0x160
Code: c7 48 8b bd 70 ff ff ff 4c 8d bc 38 00 1b 00 00 45 3b 77 08 0f
82 56 02 00 00 49 8b 17 44 8b 65 88 48 85 d2 75 1a e9 81 00 00 00 <45>
3b 77 18 49 8d 47 10 72 68 48 8b 10 49 89 c7 48 85 d2 74 6c


Thanks,
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
