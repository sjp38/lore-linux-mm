Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43435C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 13:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF8CC2075B
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 13:01:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF8CC2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 782748E0022; Wed,  2 Jan 2019 08:01:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 708FE8E0002; Wed,  2 Jan 2019 08:01:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D1F28E0022; Wed,  2 Jan 2019 08:01:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3031B8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 08:01:06 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id v8so35672912ioh.11
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 05:01:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=hK9B/5cBZKe4Rlvrcua+tl4s4BF94cvUHGg3kc0hZlU=;
        b=RCLEOIh/cJAWV9CpOA74PEJdNx+kX8e3jv69HXXzSqOW9Ovy8fEMki7I8cSVaa+/YK
         ZVfY5OA8Ae5EgR+dST+SfGWfRSjzyz5EqvvIqc1Cb5eqcCaRjusP4xpyDUQXINYrTZBz
         R+PuxrXXpIytbygtGcW7wqg8EqsrNO7guMS6MF+8YBcepc7Uxstptm6uP9BtVDzXOCsP
         fYcKu4Y22qpXmxA9IAcYbIMkTIg0NVoMEfDAlNCmiryBMloFRRk+3Z4Z0crJziPlcCua
         NsjhnthVHc/JTCt2NoMUHL0rkKmQEi/BLtPUmNuNj3PL51HNTv9Dh+/NFVE4S14VpxVu
         vhtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3elysxakbabcflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ELYsXAkbABcFLM7x881ExCC50.3BB381HF1EzBAG1AG.zB9@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukf4VeuoOuykV92bM9gIukNP75KI7z2DIPUXEK3/Sgp5r9dcxOJ9
	tPVmRKL1pjhfXVQCWBXnZE+LJ3BjVkOyuA51/Ar9VB5mdmSUVpYazlk/E06EmR54LS9EGfwwdH/
	m/rNVWQUDgaHov3V2RVNz33b4BpAsHU5N0T51vUzZec82+hWWb7Zv4CJRW9x3MeRSQcDreBSXH8
	/KsfB2VOY6V0JcnXxwhAkWbq6mx32FjRXLQcELY0e7Iix87UyyDk6hNE4JmCvkU5sGYRQJrvBHE
	sS47TmCRVMCu8QRfXEjaXrCR5KFKOmJpIeI6OZLjNv+skskmTDUXnX3Qq2T5TwwbGVHiZ5znLwg
	uxJRaVLnBEFNudApdkQadQfUnym/I3H2MIkarNVi6qIkRQyBzf1IpLxI5cAuuVqfuiMabvJ3zQ=
	=
X-Received: by 2002:a6b:cc07:: with SMTP id c7mr11326013iog.136.1546434065908;
        Wed, 02 Jan 2019 05:01:05 -0800 (PST)
X-Received: by 2002:a6b:cc07:: with SMTP id c7mr11325965iog.136.1546434064668;
        Wed, 02 Jan 2019 05:01:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546434064; cv=none;
        d=google.com; s=arc-20160816;
        b=oEE/6fkONPdiRrNOS6g5+r5SFlBW9qNF5cRj6pVIfTRiTacVy2Rn9DSCeJ8WGIGyAg
         g8HuJ/7XUzIge9jV2l6IePaHV9ioYW/EYDWt7ydCc+hgDHeFEr8wLaBfiPOKQ1khdVcI
         CNzChV8KAhK9RZ4/Gik4Og0f6ZAIFsbBczTQPVYi4PhsWn6WU8BqUoBNyzL674Qnqy7S
         uAfeypZ35GM+WqWhAzjeGTUTthi+uY93jFoON8JsuaIOc0lc8bEHbue7/x+2mFTkmiwY
         yCQgwwXmO+8J+zf8s20/nIpYJUCm12/hu0gObaTBLBP8F/zuYVDKNSZsGTDxDViZZqT+
         YtYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=hK9B/5cBZKe4Rlvrcua+tl4s4BF94cvUHGg3kc0hZlU=;
        b=bJ5ai+IA0fJrJGRnmRI2MnuzmC3WTkfnns20kB1ebiWDKGBWv+3kPASijVg9lOWRmr
         NTPJxiJdNNvrH4hjqOmGyVMoFqyKOmXPQ2QtVqXg4NO8WdhcrxkTICtVQdbSO6kgowNS
         CDWyjm9gYGwuVnIpL0JY+xvOxmg3ERAShhoR+eGQyZwOgJ7SYaLqZ5snCF+4IFXwlPhg
         +hee4gTYHU4w/kTdrPIUl5jLNPIR/MJPmI2mvhUCIX+r1eBwoD7kUSLwXX40QRypICV/
         7+Es14sHmCqsFgAERG6OFg/kbjBR2GSWxx2LRzGb0EYXRlcb9uPH9pMMaXnP1x9KJPvw
         h9gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3elysxakbabcflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ELYsXAkbABcFLM7x881ExCC50.3BB381HF1EzBAG1AG.zB9@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id u141sor41953053itb.8.2019.01.02.05.01.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 05:01:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 3elysxakbabcflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3elysxakbabcflm7x881excc50.3bb381hf1ezbag1ag.zb9@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3ELYsXAkbABcFLM7x881ExCC50.3BB381HF1EzBAG1AG.zB9@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN5Ra43dQjcXwpW17wMW66ko0Dbj5IGXU92XiFif8/2KgIfLGB3kT9V6LobVjujtcagXPbxzWW1xFmCpZZQdLHsQvjP7MrRD
MIME-Version: 1.0
X-Received: by 2002:a24:ed8c:: with SMTP id r134mr32293833ith.30.1546434064362;
 Wed, 02 Jan 2019 05:01:04 -0800 (PST)
Date: Wed, 02 Jan 2019 05:01:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000133d0a057e793df4@google.com>
Subject: KASAN: stack-out-of-bounds Read in corrupted (3)
From: syzbot <syzbot+2ab493acb9d8329345a3@syzkaller.appspotmail.com>
To: crecklin@redhat.com, keescook@chromium.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102130104.TVaK4ftA3_L2_MLPl0_tluH-edIZ60-im79Yal-X3Pk@z>

Hello,

syzbot found the following crash on:

HEAD commit:    28e8c4bc8eb4 Merge tag 'rtc-4.21' of git://git.kernel.org/..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=122355bf400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c2ab9708c613a224
dashboard link: https://syzkaller.appspot.com/bug?extid=2ab493acb9d8329345a3
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=106e29e7400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+2ab493acb9d8329345a3@syzkaller.appspotmail.com


------------[ cut here ]------------
==================================================================
DEBUG_LOCKS_WARN_ON(current->hardirq_context)
------------[ cut here ]------------
BUG: KASAN: stack-out-of-bounds in debug_spin_lock_before  
kernel/locking/spinlock_debug.c:83 [inline]
BUG: KASAN: stack-out-of-bounds in do_raw_spin_lock+0x303/0x360  
kernel/locking/spinlock_debug.c:112
Bad or missing usercopy whitelist? Kernel memory overwrite attempt detected  
to SLAB object 'task_struct' (offset 912, size 2)!
Read of size 4 at addr ffff8880a9466a44 by task kworker/1:0/7562
WARNING: CPU: 0 PID: -1455013312 at mm/usercopy.c:78  
usercopy_warn+0xeb/0x110 mm/usercopy.c:78

Kernel panic - not syncing: panic_on_warn set ...
CPU: 1 PID: 7562 Comm: kworker/1:0 Not tainted 4.20.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Workqueue: rcu_gp process_srcu
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1db/0x2d0 lib/dump_stack.c:113
  print_address_description.cold+0x7c/0x20d mm/kasan/report.c:187
  kasan_report.cold+0x1b/0x40 mm/kasan/report.c:317
  __asan_report_load4_noabort+0x14/0x20 mm/kasan/generic_report.c:134
  debug_spin_lock_before kernel/locking/spinlock_debug.c:83 [inline]
  do_raw_spin_lock+0x303/0x360 kernel/locking/spinlock_debug.c:112
  __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:117 [inline]
  _raw_spin_lock_irqsave+0x9d/0xcd kernel/locking/spinlock.c:152
  try_to_wake_up+0xb9/0x1480 kernel/sched/core.c:1965
  wake_up_process+0x10/0x20 kernel/sched/core.c:2129
  process_timeout+0x31/0x40 kernel/time/timer.c:1732
  call_timer_fn+0x254/0x900 kernel/time/timer.c:1325
  expire_timers kernel/time/timer.c:1362 [inline]
  __run_timers+0x6fc/0xd50 kernel/time/timer.c:1681
  run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1694
  __do_softirq+0x30b/0xb11 kernel/softirq.c:292
  invoke_softirq kernel/softirq.c:373 [inline]
  irq_exit+0x180/0x1d0 kernel/softirq.c:413
  exiting_irq arch/x86/include/asm/apic.h:536 [inline]
  smp_apic_timer_interrupt+0x1b7/0x760 arch/x86/kernel/apic/apic.c:1062
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:rdtsc arch/x86/include/asm/msr.h:207 [inline]
RIP: 0010:rdtsc_ordered arch/x86/include/asm/msr.h:232 [inline]
RIP: 0010:delay_tsc+0x4c/0xc0 arch/x86/lib/delay.c:61
Code: e8 0f 31 48 c1 e2 20 48 09 c2 49 89 d4 eb 16 f3 90 bf 01 00 00 00 e8  
33 70 68 f9 e8 de 5c a0 fb 44 39 e8 75 36 0f ae e8 0f 31 <48> c1 e2 20 48  
89 d3 48 09 c3 48 89 d8 4c 29 e0 4c 39 f0 73 24 bf
RSP: 0018:ffff8880891af5a0 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 00000000f513364d RBX: 00000201f5133563 RCX: ffffffff838fb3ca
RDX: 0000000000000201 RSI: ffffffff838fb3d8 RDI: 0000000000000005
RBP: ffff8880891af5c0 R08: ffff88808f0ec240 R09: fffffbfff16af64d
R10: ffff8880891af710 R11: ffffffff8b57b267 R12: 00000201f51326c9
R13: 0000000000000001 R14: 0000000000002ced R15: ffffffff8b57aec0
  __delay arch/x86/lib/delay.c:161 [inline]
  __const_udelay+0x5f/0x80 arch/x86/lib/delay.c:175
  try_check_zero+0x352/0x5c0 kernel/rcu/srcutree.c:730
  srcu_advance_state kernel/rcu/srcutree.c:1167 [inline]
  process_srcu+0x642/0x1400 kernel/rcu/srcutree.c:1261
  process_one_work+0xd0c/0x1ce0 kernel/workqueue.c:2153
  worker_thread+0x143/0x14a0 kernel/workqueue.c:2296
  kthread+0x357/0x430 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352

CPU: 0 PID: -1455013312 Comm:  Not tainted 4.20.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Allocated by task 2839968544:
Call Trace:
BUG: unable to handle kernel paging request at ffffffff8cf07580
#PF error: [normal kernel read fault]
PGD 9871067 P4D 9871067 PUD 9872063 PMD 0
Oops: 0000 [#1] PREEMPT SMP KASAN
CPU: 1 PID: 7562 Comm: kworker/1:0 Not tainted 4.20.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Workqueue: rcu_gp process_srcu
RIP: 0010:depot_fetch_stack+0x10/0x30 lib/stackdepot.c:202
Code: 36 0f 23 fe e9 20 fe ff ff 48 89 df e8 29 0f 23 fe e9 f1 fd ff ff 90  
90 90 90 89 f8 c1 ef 11 25 ff ff 1f 00 81 e7 f0 3f 00 00 <48> 03 3c c5 80  
31 f4 8b 8b 47 0c 48 83 c7 18 c7 46 10 00 00 00 00
RSP: 0018:ffff8880ae707640 EFLAGS: 00010006
RAX: 00000000001f8880 RBX: ffff8880a9467a44 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8880ae707648 RDI: 0000000000003ff0
RBP: ffff8880ae707670 R08: 000000000000001d R09: ffffed1015ce3ef9
R10: ffffed1015ce3ef8 R11: ffff8880ae71f7c7 R12: ffffea0002a51980
R13: ffff8880a9466a44 R14: ffff8880aa13d900 R15: ffff8880a9467a40
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffff8cf07580 CR3: 0000000099fe2000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  <IRQ>
  describe_object mm/kasan/report.c:158 [inline]
  print_address_description.cold+0x16a/0x20d mm/kasan/report.c:194
  kasan_report.cold+0x1b/0x40 mm/kasan/report.c:317
  __asan_report_load4_noabort+0x14/0x20 mm/kasan/generic_report.c:134
  debug_spin_lock_before kernel/locking/spinlock_debug.c:83 [inline]
  do_raw_spin_lock+0x303/0x360 kernel/locking/spinlock_debug.c:112
  __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:117 [inline]
  _raw_spin_lock_irqsave+0x9d/0xcd kernel/locking/spinlock.c:152
  try_to_wake_up+0xb9/0x1480 kernel/sched/core.c:1965
  wake_up_process+0x10/0x20 kernel/sched/core.c:2129
  process_timeout+0x31/0x40 kernel/time/timer.c:1732
  call_timer_fn+0x254/0x900 kernel/time/timer.c:1325
  expire_timers kernel/time/timer.c:1362 [inline]
  __run_timers+0x6fc/0xd50 kernel/time/timer.c:1681
  run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1694
  __do_softirq+0x30b/0xb11 kernel/softirq.c:292
  invoke_softirq kernel/softirq.c:373 [inline]
  irq_exit+0x180/0x1d0 kernel/softirq.c:413
  exiting_irq arch/x86/include/asm/apic.h:536 [inline]
  smp_apic_timer_interrupt+0x1b7/0x760 arch/x86/kernel/apic/apic.c:1062
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:rdtsc arch/x86/include/asm/msr.h:207 [inline]
RIP: 0010:rdtsc_ordered arch/x86/include/asm/msr.h:232 [inline]
RIP: 0010:delay_tsc+0x4c/0xc0 arch/x86/lib/delay.c:61
Code: e8 0f 31 48 c1 e2 20 48 09 c2 49 89 d4 eb 16 f3 90 bf 01 00 00 00 e8  
33 70 68 f9 e8 de 5c a0 fb 44 39 e8 75 36 0f ae e8 0f 31 <48> c1 e2 20 48  
89 d3 48 09 c3 48 89 d8 4c 29 e0 4c 39 f0 73 24 bf
RSP: 0018:ffff8880891af5a0 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 00000000f513364d RBX: 00000201f5133563 RCX: ffffffff838fb3ca
RDX: 0000000000000201 RSI: ffffffff838fb3d8 RDI: 0000000000000005
RBP: ffff8880891af5c0 R08: ffff88808f0ec240 R09: fffffbfff16af64d
R10: ffff8880891af710 R11: ffffffff8b57b267 R12: 00000201f51326c9
R13: 0000000000000001 R14: 0000000000002ced R15: ffffffff8b57aec0
  __delay arch/x86/lib/delay.c:161 [inline]
  __const_udelay+0x5f/0x80 arch/x86/lib/delay.c:175
  try_check_zero+0x352/0x5c0 kernel/rcu/srcutree.c:730
  srcu_advance_state kernel/rcu/srcutree.c:1167 [inline]
  process_srcu+0x642/0x1400 kernel/rcu/srcutree.c:1261
  process_one_work+0xd0c/0x1ce0 kernel/workqueue.c:2153
  worker_thread+0x143/0x14a0 kernel/workqueue.c:2296
  kthread+0x357/0x430 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
Modules linked in:
CR2: ffffffff8cf07580
---[ end trace 7f399f30ebf94723 ]---
RIP: 0010:depot_fetch_stack+0x10/0x30 lib/stackdepot.c:202
Code: 36 0f 23 fe e9 20 fe ff ff 48 89 df e8 29 0f 23 fe e9 f1 fd ff ff 90  
90 90 90 89 f8 c1 ef 11 25 ff ff 1f 00 81 e7 f0 3f 00 00 <48> 03 3c c5 80  
31 f4 8b 8b 47 0c 48 83 c7 18 c7 46 10 00 00 00 00
RSP: 0018:ffff8880ae707640 EFLAGS: 00010006
RAX: 00000000001f8880 RBX: ffff8880a9467a44 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8880ae707648 RDI: 0000000000003ff0
RBP: ffff8880ae707670 R08: 000000000000001d R09: ffffed1015ce3ef9
R10: ffffed1015ce3ef8 R11: ffff8880ae71f7c7 R12: ffffea0002a51980
R13: ffff8880a9466a44 R14: ffff8880aa13d900 R15: ffff8880a9467a40
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffff8cf07580 CR3: 0000000099fe2000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Shutting down cpus with NMI
usercopy: Kernel memory overwrite attempt detected to SLAB  
object 'sighand_cache' (offset 2320, size 2)!
------------[ cut here ]------------
kernel BUG at mm/usercopy.c:102!
WARNING: CPU: 0 PID: -1455013312 at kernel/rcu/tree_plugin.h:414  
__rcu_read_lock+0x75/0x90 kernel/rcu/tree_plugin.h:416
Modules linked in:
CPU: 0 PID: -1455013312 Comm:  Tainted: G      D           4.20.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__rcu_read_lock+0x75/0x90 kernel/rcu/tree_plugin.h:414
Code: 00 48 8d bb 70 03 00 00 48 89 fa 48 c1 ea 03 0f b6 04 02 84 c0 74 04  
3c 03 7e 14 81 bb 70 03 00 00 ff ff ff 3f 7f 03 5b 5d c3 <0f> 0b 5b 5d c3  
e8 61 db 59 00 eb e5 e8 5a db 59 00 eb aa 0f 1f 84
RSP: 0018:ffff8880a9463850 EFLAGS: 00010012
RAX: 0000000000000000 RBX: ffff8880a9464240 RCX: ffffffff816b545f
RDX: 0000000000000000 RSI: 0000000000000004 RDI: ffff8880a94645b0
RBP: ffff8880a9463858 R08: ffff8880a9464240 R09: 0000000000000004
R10: ffffed1015cc3ef8 R11: ffff8880ae61f7c7 R12: 0000000000000000
R13: 0000000000000008 R14: ffff8880a94638d0 R15: ffff8880a94639d8
FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f1524df3169 CR3: 000000008509b000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
irq event stamp: 2321324489
hardirqs last  enabled at (2170814927): [<ffffed101528c974>]  
0xffffed101528c974
hardirqs last disabled at (2321324489): [<ffffffff8167a729>]  
vprintk_emit+0x169/0x960 kernel/printk/printk.c:1911
softirqs last  enabled at (0): [<ffffffff86e92120>] gue6_err+0x0/0x6b0  
net/ipv6/fou6.c:86
softirqs last disabled at (1): [<0000000000000001>] 0x1
---[ end trace 7f399f30ebf94724 ]---
invalid opcode: 0000 [#2] PREEMPT SMP KASAN
CPU: 0 PID: -1455013312 Comm:  Tainted: G      D W         4.20.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:usercopy_abort+0xbd/0xbf mm/usercopy.c:102
Code: c0 e8 0d 0b b2 ff 48 8b 55 c0 49 89 d9 4d 89 f0 ff 75 c8 4c 89 e1 4c  
89 ee 48 c7 c7 00 27 55 88 ff 75 d0 41 57 e8 5d 4b 98 ff <0f> 0b e8 e2 0a  
b2 ff e8 dd af f5 ff 8b 95 20 ff ff ff 4c 89 e1 31
RSP: 0018:ffff8880a9463a80 EFLAGS: 00010086
RAX: 0000000000000068 RBX: ffffffff88494720 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff8167d666 RDI: ffffed101528c742
RBP: ffff8880a9463ad8 R08: 0000000000000068 R09: ffffed1015cc3ef9
R10: ffffed1015cc3ef8 R11: ffff8880ae61f7c7 R12: ffffffff893bcfb5
R13: ffffffff88552560 R14: ffffffff885524a0 R15: ffffffff88552460
FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f1524df3169 CR3: 000000008509b000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
Modules linked in:
---[ end trace 7f399f30ebf94725 ]---
RIP: 0010:depot_fetch_stack+0x10/0x30 lib/stackdepot.c:202
Code: 36 0f 23 fe e9 20 fe ff ff 48 89 df e8 29 0f 23 fe e9 f1 fd ff ff 90  
90 90 90 89 f8 c1 ef 11 25 ff ff 1f 00 81 e7 f0 3f 00 00 <48> 03 3c c5 80  
31 f4 8b 8b 47 0c 48 83 c7 18 c7 46 10 00 00 00 00
RSP: 0018:ffff8880ae707640 EFLAGS: 00010006
RAX: 00000000001f8880 RBX: ffff8880a9467a44 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8880ae707648 RDI: 0000000000003ff0
RBP: ffff8880ae707670 R08: 000000000000001d R09: ffffed1015ce3ef9
R10: ffffed1015ce3ef8 R11: ffff8880ae71f7c7 R12: ffffea0002a51980
R13: ffff8880a9466a44 R14: ffff8880aa13d900 R15: ffff8880a9467a40
FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f1524df3169 CR3: 000000008509b000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

