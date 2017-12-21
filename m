Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 201AE6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 19:34:46 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id x62so8295669ioe.8
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:34:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7sor10046798iob.42.2017.12.20.16.34.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 16:34:45 -0800 (PST)
Date: Wed, 20 Dec 2017 16:34:41 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: general protection fault in __schedule
Message-ID: <20171221003441.GH38504@gmail.com>
References: <001a113c0b98c936d20560c7b7ec@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a113c0b98c936d20560c7b7ec@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+df206d897b7957e7c7a8c34e18c39a24d5256877@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, jglisse@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, paulmck@linux.vnet.ibm.com, syzkaller-bugs@googlegroups.com, vegard.nossum@oracle.com

On Wed, Dec 20, 2017 at 08:03:01AM -0800, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on
> 7dc9f647127d6955ffacaf51cb6a627b31dceec2
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> kvm: KVM_SET_TSS_ADDR need to be called before entering vcpu
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 3151 Comm: syzkaller527934 Not tainted
> 4.15.0-rc4-next-20171220+ #77
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> RIP: 0010:__fire_sched_out_preempt_notifiers
> kernel/sched/core.c:2550 [inline]
> RIP: 0010:fire_sched_out_preempt_notifiers kernel/sched/core.c:2558 [inline]
> RIP: 0010:prepare_task_switch kernel/sched/core.c:2594 [inline]
> RIP: 0010:context_switch kernel/sched/core.c:2765 [inline]
> RIP: 0010:__schedule+0xdf0/0x2060 kernel/sched/core.c:3376
> RSP: 0018:ffff8801c93a7068 EFLAGS: 00010806
> RAX: 1bd5a00000000022 RBX: ffff8801db32c900 RCX: ffffffff810caeaf
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: dead000000000110
> RBP: ffff8801c93a7238 R08: 0000000000000000 R09: 1ffff10039274de1
> R10: ffff8801c93a6ed0 R11: 0000000000000001 R12: ffff8801d3948040
> R13: dead000000000100 R14: dffffc0000000000 R15: ffff8801c9ca20c0
> FS:  0000000000000000(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020001000 CR3: 0000000006422006 CR4: 00000000001626e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  preempt_schedule_common+0x22/0x60 kernel/sched/core.c:3515
>  _cond_resched+0x1d/0x30 kernel/sched/core.c:4852
>  __wait_for_common kernel/sched/completion.c:107 [inline]
>  wait_for_common kernel/sched/completion.c:123 [inline]
>  wait_for_completion+0xa5/0x770 kernel/sched/completion.c:144
>  __synchronize_srcu+0x1ad/0x260 kernel/rcu/srcutree.c:925
>  synchronize_srcu_expedited kernel/rcu/srcutree.c:950 [inline]
>  synchronize_srcu+0x1a3/0x570 kernel/rcu/srcutree.c:1001
>  __mmu_notifier_release+0x357/0x690 mm/mmu_notifier.c:102
>  mmu_notifier_release include/linux/mmu_notifier.h:225 [inline]
>  exit_mmap+0x3ff/0x500 mm/mmap.c:3009
>  __mmput kernel/fork.c:965 [inline]
>  mmput+0x223/0x6c0 kernel/fork.c:986
>  exit_mm kernel/exit.c:544 [inline]
>  do_exit+0x90a/0x1ad0 kernel/exit.c:856
>  do_group_exit+0x149/0x400 kernel/exit.c:972
>  SYSC_exit_group kernel/exit.c:983 [inline]
>  SyS_exit_group+0x1d/0x20 kernel/exit.c:981
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x43ee88
> RSP: 002b:00007ffc8be9bb08 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043ee88
> RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> RBP: 00000000006ca018 R08: 00000000000000e7 R09: ffffffffffffffd0
> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000401bb0
> R13: 0000000000401c40 R14: 0000000000000000 R15: 0000000000000000
> Code: 08 4c 89 e8 48 c1 e8 03 42 80 3c 30 00 0f 85 ce 0f 00 00 4d 8b
> 6d 00 4d 85 ed 0f 84 72 f9 ff ff 49 8d 7d 10 48 89 f8 48 c1 e8 03
> <42> 80 3c 30 00 74 ac eb a5 49 8d bc 24 28 04 00 00 48 b8 00 00
> RIP: __fire_sched_out_preempt_notifiers kernel/sched/core.c:2550
> [inline] RSP: ffff8801c93a7068
> RIP: fire_sched_out_preempt_notifiers kernel/sched/core.c:2558
> [inline] RSP: ffff8801c93a7068
> RIP: prepare_task_switch kernel/sched/core.c:2594 [inline] RSP:
> ffff8801c93a7068
> RIP: context_switch kernel/sched/core.c:2765 [inline] RSP: ffff8801c93a7068
> RIP: __schedule+0xdf0/0x2060 kernel/sched/core.c:3376 RSP: ffff8801c93a7068
> 

Duplicate:

#syz dup: KASAN: use-after-free Read in __schedule

It's a recent KVM bug, caused by a missing vcpu_put().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
