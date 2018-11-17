Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6798A6B0E87
	for <linux-mm@kvack.org>; Sat, 17 Nov 2018 05:15:11 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id s53so17498334ota.16
        for <linux-mm@kvack.org>; Sat, 17 Nov 2018 02:15:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c6si13735655oto.262.2018.11.17.02.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Nov 2018 02:15:09 -0800 (PST)
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
 <20181108022138.GA2343@jagdpanzerIV>
 <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
 <20181108123049.GA30440@jagdpanzerIV>
 <20181109141012.accx62deekzq5gh5@pathway.suse.cz>
 <20181112075920.GA497@jagdpanzerIV>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <83ad1f64-9901-2286-7dbc-dd9fdebdd671@i-love.sakura.ne.jp>
Date: Sat, 17 Nov 2018 19:14:08 +0900
MIME-Version: 1.0
In-Reply-To: <20181112075920.GA497@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/12 16:59, Sergey Senozhatsky wrote:
> On (11/09/18 15:10), Petr Mladek wrote:
>>>
>>> If I'm not mistaken, this is for the futute "printk injection" work.
>>
>> The above code only tries to push complete lines to the main log buffer
>> and consoles ASAP. It sounds like a Good Idea(tm).
> 
> Probably it is. So *quite likely* I'm wrong here.

In the future, I want to inject caller information to standard console output,
for syzbot is using serial console

  [    0.000000] Linux version 4.20.0-rc2-next-20181116+ (syzkaller@ci) (gcc version 8.0.1 20180413 (experimental) (GCC)) #120 SMP PREEMPT Fri Nov 16 20:21:42 UTC 2018
  [    0.000000] Command line: BOOT_IMAGE=/vmlinuz root=/dev/sda1 console=ttyS0 earlyprintk=serial vsyscall=native rodata=n oops=panic panic_on_warn=1 nmi_watchdog=panic panic=86400 security=apparmor ima_policy=tcb workqueue.watchdog_thresh=140 kvm-intel.nested=1 nf-conntrack-ftp.ports=20000 nf-conntrack-tftp.ports=20000 nf-conntrack-sip.ports=20000 nf-conntrack-irc.ports=20000 nf-conntrack-sane.ports=20000 vivid.n_devs=16 vivid.multiplanar=1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2 nopcid

and is experiencing confusion due to concurrent printk() like

  [  552.907865] syz-executor0: vmalloc: allocation failure: 256 bytes, mode:0x6000c0(GFP_KERNEL), nodemask=(null)
  [  552.921666] ------------[ cut here ]------------
  [  552.926434] DEBUG_LOCKS_WARN_ON(depth <= 0)
  [  552.926563] WARNING: CPU: 0 PID: 24211 at kernel/locking/lockdep.c:3595 lock_release+0x740/0xa10
  [  552.927489] syz-executor0 cpuset=syz0 mems_allowed=0
  [  552.930893] Kernel panic - not syncing: panic_on_warn set ...
  [  552.943750] CPU: 1 PID: 24208 Comm: syz-executor0 Not tainted 4.20.0-rc1-next-20181109+ #110
  [  552.959345] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
  [  552.968694] Call Trace:
  [  552.971296]  dump_stack+0x244/0x39d
  [  552.974934]  ? dump_stack_print_info.cold.1+0x20/0x20
  [  552.980138]  ? rcu_lockdep_current_cpu_online+0x1a4/0x210
  [  552.985685]  warn_alloc.cold.116+0xb7/0x1bd
  [  552.990011]  ? zone_watermark_ok_safe+0x3f0/0x3f0
  [  552.994884]  ? __get_vm_area_node+0x130/0x3a0
  [  552.999387]  ? rcu_read_lock_sched_held+0x14f/0x180
  [  553.004414]  ? __might_fault+0x12b/0x1e0
  [  553.008487]  ? __get_vm_area_node+0x2e5/0x3a0
  [  553.013000]  __vmalloc_node_range+0x472/0x750
  [  553.017514]  ? do_replace+0x23b/0x4c0
  [  553.021327]  vmalloc+0x6f/0x80
  (...snipped...)
  [  553.296333]  __warn.cold.8+0x20/0x45
  [  553.296353]  ? lock_release+0x740/0xa10
  [  553.329854] Node 0 DMA free:15908kB min:164kB low:204kB high:244kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
  [  553.332731]  report_bug+0x254/0x2d0
  [  553.332796]  do_error_trap+0x11b/0x200
  [  553.332822]  do_invalid_op+0x36/0x40
  [  553.336825] lowmem_reserve[]: 0 2818 6321 6321
  [  553.362888]  ? lock_release+0x740/0xa10
  [  553.362906]  invalid_op+0x14/0x20
  [  553.362920] RIP: 0010:lock_release+0x740/0xa10
  [  553.362935] Code: 03 38 d0 7c 08 84 d2 0f 85 da 02 00 00 8b 35 a7 95 b3 08 85 f6 75 15 48 c7 c6 20 66 2b 88 48 c7 c7 c0 33 2b 88 e8 10 36 e7 ff <0f> 0b 48 8b 95 e8 fe ff ff 4c 89 f7 48 8b b5 f0 fe ff ff e8 e8 58
  [  553.362941] RSP: 0018:ffff8801839ef868 EFLAGS: 00010086
  [  553.362950] RAX: 0000000000000000 RBX: 1ffff1003073df12 RCX: ffffc9000be41000
  [  553.362957] RDX: 00000000000087b4 RSI: ffffffff8165ba15 RDI: 0000000000000006
  [  553.362966] RBP: ffff8801839ef998 R08: ffff88017c010600 R09: fffffbfff12b2254
  [  553.362974] R10: fffffbfff12b2254 R11: ffffffff895912a3 R12: ffffffff8b0e27a0
  [  553.362989] R13: ffff8801839ef970 R14: ffff88017c010600 R15: ffff8801839ef8b0
  [  553.373138] Node 0 DMA32 free:2887356kB min:30052kB low:37564kB high:45076kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129332kB managed:2888772kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:1416kB local_pcp:0kB free_cma:0kB
  [  553.374209]  ? vprintk_func+0x85/0x181
  [  553.387199] lowmem_reserve[]: 0 0 3503 3503
  [  553.390755]  ? lock_release+0x740/0xa10
  [  553.390840]  ? loop_control_ioctl+0xf5/0x4e0

in https://syzkaller.appspot.com/bug?id=e7838e1e659de1ba566bb17410438b9d1dc59eb7 .

Thus, I appreciate if we could mitigate KERN_CONT problem using try_buffered_printk()
and move on to "caller information injection" topic. I'm fine with starting with
CONFIG_DEBUG_AID_FOR_SYZBOT=y.
