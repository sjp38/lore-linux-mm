Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09FB9C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 11:26:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A988D2084B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 11:26:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A988D2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F22A6B0010; Thu, 25 Apr 2019 07:26:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A3446B0266; Thu, 25 Apr 2019 07:26:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B8046B0269; Thu, 25 Apr 2019 07:26:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE1D76B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 07:26:07 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id o197so5938167ito.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:26:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=/gkhunVa3g55a0c9i5WsQm7U5eGdl/bsD2OziaOLXQQ=;
        b=IIFz+qvoy5cURBiH4hN6qafzqvXnIK2ClALO7H9hc2fWfvZDNWUAJY8fc8DeIU6sYf
         cFUNrOX7sF56KEH/IBN+Ih+Ky1BUQPzKIjPywYahihMMTgn+xr1GPQr0Ajj0i1oiCWbK
         bynMInHawBsV9WXFCpmCpqyBs0Dg84J3IS/galINA1D9hw9uSLtvcJRfM+AVFlJrKAgO
         T6DlcNtJrTncJE26FOq1B+eNYZjcM9zpf6EcUYXonU1XL1CmQK8uOwKe1c1wnu2pyJQD
         klzKghYVcAkiGIFqIHmH1Pb8Ti2cW6oU3L/GNfLOO2pxwkzdBPoQDIk3Poz5EnvXhbb9
         7zAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3tznbxakbahiiopaqbbuhqffyt.weewbukiuhsedjudj.sec@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3TZnBXAkbAHIiopaQbbUhQffYT.WeeWbUkiUhSedjUdj.Sec@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXrfUGqp4lptNZVGQJo95slETsOKMXGA/y6iSKfFK2+GTyNYpFH
	oKs1/DyibB00MlG2BwvrsneMFpz4vmoMfV9GyKvSfDu9rvMVcjjjCudcI88Sk7DVsE+N+0lpk8o
	j1U+E+zMAJCyZ9oYBcRdDlVRKS7E8eEctqT2AZLCnluR+ovt3zwOwHugkcpMlDHM=
X-Received: by 2002:a24:70d5:: with SMTP id f204mr3268595itc.32.1556191567626;
        Thu, 25 Apr 2019 04:26:07 -0700 (PDT)
X-Received: by 2002:a24:70d5:: with SMTP id f204mr3268537itc.32.1556191566309;
        Thu, 25 Apr 2019 04:26:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556191566; cv=none;
        d=google.com; s=arc-20160816;
        b=xhL7A8e5kiQNwjtm3zoy6wv8F2Zv2+g2TpUORUdkaKR+j9LghnhmMbjI63aUWQ0Kz8
         4kxJ79WvAPBogaIqQfmzA7XRr8ru3PyI3w7ulvFOCJ6K2XNEBeqlUnjHrnloBqK1eBJO
         NX460pFMPlp/E5uC3AML0e1SXM9DAH7T0xY9oKEBGiyZY5XcixxkSROw9ZduoWz/y2b5
         tzq591H/Ia3AY6O5FHHF48JrkS/fbPMY/05PEJjXgJbLjQATASBkFqxSd+/ypNcupGhH
         5b7XHyru5Uiwim8xIe7McNDq2AJKotBN7O9sNcO0hYFP5NBOIve8eYo+lyw/sg852iZ+
         XNjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=/gkhunVa3g55a0c9i5WsQm7U5eGdl/bsD2OziaOLXQQ=;
        b=akURbImabCnkJeNl+W8BgSyg0zPpQFz3E5m/FpD7w3qnU4ZgDFW48vLa7HjgGkx74G
         DdpKKJOXNyxE+YT4ciqkPCZfI2qemF6HE6Q/U/gSavBriFsDtRTpg0kaei4FVfPjSwcM
         1h8H965w4WlBjfk6PTBARfXPFMtgcJiucsCA5fx6D/VU8SxhAY4sKgM554F75EfGMLQW
         CpMdwpjF3EOXyC3LLsVx9GM+P/l3d4xCjohDItJWtqdtTanZys8i7LqTgglxwslTqy9W
         btb98HCni0/Uy/bhjXaWTszG+9CLXvd/mp4JujesRE9ia3Fn9Qjg3aOv/aAm+LM3ZdXk
         uovg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3tznbxakbahiiopaqbbuhqffyt.weewbukiuhsedjudj.sec@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3TZnBXAkbAHIiopaQbbUhQffYT.WeeWbUkiUhSedjUdj.Sec@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id b4sor12596489iot.10.2019.04.25.04.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 04:26:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tznbxakbahiiopaqbbuhqffyt.weewbukiuhsedjudj.sec@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3tznbxakbahiiopaqbbuhqffyt.weewbukiuhsedjudj.sec@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3TZnBXAkbAHIiopaQbbUhQffYT.WeeWbUkiUhSedjUdj.Sec@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqwW5Xzoz2pVems9GFjTmveXWp2wMTNJ637hiTM8pWhjHdiFauMlc8StLrFS+kqRZsPjbyCzLQMNEutRTXx9oLO3JcYYEMpA
MIME-Version: 1.0
X-Received: by 2002:a6b:b989:: with SMTP id j131mr10532357iof.131.1556191565883;
 Thu, 25 Apr 2019 04:26:05 -0700 (PDT)
Date: Thu, 25 Apr 2019 04:26:05 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000007cb1ee0587591549@google.com>
Subject: WARNING: suspicious RCU usage in line6_pcm_acquire
From: syzbot <syzbot+06b7a5a8c4acc0445995@syzkaller.appspotmail.com>
To: andreyknvl@google.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-usb@vger.kernel.org, 
	mhocko@kernel.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    43151d6c usb-fuzzer: main usb gadget fuzzer driver
git tree:       https://github.com/google/kasan/tree/usb-fuzzer
console output: https://syzkaller.appspot.com/x/log.txt?x=11b5f9d4a00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4183eeef650d1234
dashboard link: https://syzkaller.appspot.com/bug?extid=06b7a5a8c4acc0445995
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+06b7a5a8c4acc0445995@syzkaller.appspotmail.com

=============================
WARNING: suspicious RCU usage
5.1.0-rc3-319004-g43151d6 #6 Not tainted
-----------------------------
include/linux/rcupdate.h:267 Illegal context switch in RCU read-side  
critical section!

other info that might help us debug this:


rcu_scheduler_active = 2, debug_locks = 1
2 locks held by syz-executor.4/5712:
  #0: 0000000034ec6c83 (rcu_read_lock){....}, at: arch_static_branch  
arch/x86/include/asm/jump_label.h:23 [inline]
  #0: 0000000034ec6c83 (rcu_read_lock){....}, at: mem_cgroup_disabled  
include/linux/memcontrol.h:333 [inline]
  #0: 0000000034ec6c83 (rcu_read_lock){....}, at:  
get_mem_cgroup_from_mm+0x66/0x570 mm/memcontrol.c:838
  #1: 000000004e680701 ((&toneport->timer)){+.-.}, at: lockdep_copy_map  
include/linux/lockdep.h:170 [inline]
  #1: 000000004e680701 ((&toneport->timer)){+.-.}, at:  
call_timer_fn+0xce/0x5f0 kernel/time/timer.c:1315

stack backtrace:
CPU: 0 PID: 5712 Comm: syz-executor.4 Not tainted 5.1.0-rc3-319004-g43151d6  
#6
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0xe8/0x16e lib/dump_stack.c:113
  rcu_preempt_sleep_check include/linux/rcupdate.h:267 [inline]
  rcu_preempt_sleep_check include/linux/rcupdate.h:265 [inline]
  ___might_sleep+0x1b6/0x280 kernel/sched/core.c:6155
  __mutex_lock_common kernel/locking/mutex.c:908 [inline]
  __mutex_lock+0xcd/0x12b0 kernel/locking/mutex.c:1072
  line6_pcm_acquire+0x35/0x210 sound/usb/line6/pcm.c:311
  call_timer_fn+0x161/0x5f0 kernel/time/timer.c:1325
  expire_timers kernel/time/timer.c:1362 [inline]
  __run_timers kernel/time/timer.c:1681 [inline]
  __run_timers kernel/time/timer.c:1649 [inline]
  run_timer_softirq+0x58b/0x1400 kernel/time/timer.c:1694
  __do_softirq+0x22a/0x8cd kernel/softirq.c:293
  invoke_softirq kernel/softirq.c:374 [inline]
  irq_exit+0x187/0x1b0 kernel/softirq.c:414
  exiting_irq arch/x86/include/asm/apic.h:536 [inline]
  smp_apic_timer_interrupt+0xfe/0x4a0 arch/x86/kernel/apic/apic.c:1062
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:767  
[inline]
RIP: 0010:lock_is_held_type+0x1df/0x250 kernel/locking/lockdep.c:4251
Code: 48 c1 ea 03 0f b6 14 02 48 89 f8 83 e0 07 83 c0 03 38 d0 7c 04 84 d2  
75 6d c7 83 3c 08 00 00 00 00 00 00 48 8b 7c 24 08 57 9d <0f> 1f 44 00 00  
48 83 c4 18 44 89 e8 5b 5d 41 5c 41 5d 41 5e 41 5f
RSP: 0018:ffff888074387a60 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 0000000000000007 RBX: ffff88808c00e200 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff917d62e0 RDI: 0000000000000246
RBP: ffff88808c00e200 R08: 00000000d2d39b7b R09: ffffed1015a05c28
R10: ffffed1015a05c27 R11: ffff8880ad02e13b R12: ffff88808c00ea38
R13: 0000000000000001 R14: ffff88808c00ea40 R15: ffffffff917d62e0
  get_mem_cgroup_from_mm mm/memcontrol.c:851 [inline]
  get_mem_cgroup_from_mm+0x3b6/0x570 mm/memcontrol.c:834
  get_mem_cgroup_from_current mm/memcontrol.c:897 [inline]
  memcg_kmem_get_cache+0x142/0x5d0 mm/memcontrol.c:2548
  slab_pre_alloc_hook mm/slab.h:425 [inline]
  slab_alloc_node mm/slub.c:2682 [inline]
  slab_alloc mm/slub.c:2764 [inline]
  kmem_cache_alloc+0x12f/0x270 mm/slub.c:2769
  copy_sighand kernel/fork.c:1468 [inline]
  copy_process.part.0+0x1e84/0x76b0 kernel/fork.c:1910
  copy_process kernel/fork.c:1709 [inline]
  _do_fork+0x234/0xed0 kernel/fork.c:2226
  do_syscall_64+0xcf/0x4f0 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x45736a
Code: f7 d8 64 89 04 25 d4 02 00 00 64 4c 8b 0c 25 10 00 00 00 31 d2 4d 8d  
91 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff  
ff 0f 87 f5 00 00 00 85 c0 41 89 c5 0f 85 fc 00 00
RSP: 002b:00007fff80f37540 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 00007fff80f37540 RCX: 000000000045736a
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
RBP: 00007fff80f37580 R08: 0000000000000001 R09: 0000000000a57940
R10: 0000000000a57c10 R11: 0000000000000246 R12: 0000000000000001
R13: 0000000000000000 R14: 0000000000000000 R15: 00007fff80f375d0
BUG: sleeping function called from invalid context at  
kernel/locking/mutex.c:908
in_atomic(): 1, irqs_disabled(): 0, pid: 5712, name: syz-executor.4
2 locks held by syz-executor.4/5712:
  #0: 0000000034ec6c83 (rcu_read_lock){....}, at: arch_static_branch  
arch/x86/include/asm/jump_label.h:23 [inline]
  #0: 0000000034ec6c83 (rcu_read_lock){....}, at: mem_cgroup_disabled  
include/linux/memcontrol.h:333 [inline]
  #0: 0000000034ec6c83 (rcu_read_lock){....}, at:  
get_mem_cgroup_from_mm+0x66/0x570 mm/memcontrol.c:838
  #1: 000000004e680701 ((&toneport->timer)){+.-.}, at: lockdep_copy_map  
include/linux/lockdep.h:170 [inline]
  #1: 000000004e680701 ((&toneport->timer)){+.-.}, at:  
call_timer_fn+0xce/0x5f0 kernel/time/timer.c:1315
CPU: 0 PID: 5712 Comm: syz-executor.4 Not tainted 5.1.0-rc3-319004-g43151d6  
#6
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0xe8/0x16e lib/dump_stack.c:113
  ___might_sleep.cold+0x11c/0x136 kernel/sched/core.c:6190
  __mutex_lock_common kernel/locking/mutex.c:908 [inline]
  __mutex_lock+0xcd/0x12b0 kernel/locking/mutex.c:1072
  line6_pcm_acquire+0x35/0x210 sound/usb/line6/pcm.c:311
  call_timer_fn+0x161/0x5f0 kernel/time/timer.c:1325
  expire_timers kernel/time/timer.c:1362 [inline]
  __run_timers kernel/time/timer.c:1681 [inline]
  __run_timers kernel/time/timer.c:1649 [inline]
  run_timer_softirq+0x58b/0x1400 kernel/time/timer.c:1694
  __do_softirq+0x22a/0x8cd kernel/softirq.c:293
  invoke_softirq kernel/softirq.c:374 [inline]
  irq_exit+0x187/0x1b0 kernel/softirq.c:414
  exiting_irq arch/x86/include/asm/apic.h:536 [inline]
  smp_apic_timer_interrupt+0xfe/0x4a0 arch/x86/kernel/apic/apic.c:1062
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:767  
[inline]
RIP: 0010:lock_is_held_type+0x1df/0x250 kernel/locking/lockdep.c:4251
Code: 48 c1 ea 03 0f b6 14 02 48 89 f8 83 e0 07 83 c0 03 38 d0 7c 04 84 d2  
75 6d c7 83 3c 08 00 00 00 00 00 00 48 8b 7c 24 08 57 9d <0f> 1f 44 00 00  
48 83 c4 18 44 89 e8 5b 5d 41 5c 41 5d 41 5e 41 5f
RSP: 0018:ffff888074387a60 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 0000000000000007 RBX: ffff88808c00e200 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff917d62e0 RDI: 0000000000000246
RBP: ffff88808c00e200 R08: 00000000d2d39b7b R09: ffffed1015a05c28
R10: ffffed1015a05c27 R11: ffff8880ad02e13b R12: ffff88808c00ea38
R13: 0000000000000001 R14: ffff88808c00ea40 R15: ffffffff917d62e0
  get_mem_cgroup_from_mm mm/memcontrol.c:851 [inline]
  get_mem_cgroup_from_mm+0x3b6/0x570 mm/memcontrol.c:834
  get_mem_cgroup_from_current mm/memcontrol.c:897 [inline]
  memcg_kmem_get_cache+0x142/0x5d0 mm/memcontrol.c:2548
  slab_pre_alloc_hook mm/slab.h:425 [inline]
  slab_alloc_node mm/slub.c:2682 [inline]
  slab_alloc mm/slub.c:2764 [inline]
  kmem_cache_alloc+0x12f/0x270 mm/slub.c:2769
  copy_sighand kernel/fork.c:1468 [inline]
  copy_process.part.0+0x1e84/0x76b0 kernel/fork.c:1910
  copy_process kernel/fork.c:1709 [inline]
  _do_fork+0x234/0xed0 kernel/fork.c:2226
  do_syscall_64+0xcf/0x4f0 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x45736a
Code: f7 d8 64 89 04 25 d4 02 00 00 64 4c 8b 0c 25 10 00 00 00 31 d2 4d 8d  
91 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff  
ff 0f 87 f5 00 00 00 85 c0 41 89 c5 0f 85 fc 00 00
RSP: 002b:00007fff80f37540 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 00007fff80f37540 RCX: 000000000045736a
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
RBP: 00007fff80f37580 R08: 0000000000000001 R09: 0000000000a57940
R10: 0000000000a57c10 R11: 0000000000000246 R12: 0000000000000001
R13: 0000000000000000 R14: 0000000000000000 R15: 00007fff80f375d0
==================================================================
BUG: KASAN: null-ptr-deref in memset include/linux/string.h:337 [inline]
BUG: KASAN: null-ptr-deref in submit_audio_out_urb+0x91e/0x1780  
sound/usb/line6/playback.c:246
Write of size 176 at addr 0000000000000010 by task syz-executor.4/5712

CPU: 0 PID: 5712 Comm: syz-executor.4 Tainted: G        W          
5.1.0-rc3-319004-g43151d6 #6
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0xe8/0x16e lib/dump_stack.c:113
  kasan_report.cold+0x5/0x3c mm/kasan/report.c:321
  memset+0x20/0x40 mm/kasan/common.c:115
  memset include/linux/string.h:337 [inline]
  submit_audio_out_urb+0x91e/0x1780 sound/usb/line6/playback.c:246
  line6_submit_audio_out_all_urbs+0xce/0x120 sound/usb/line6/playback.c:295
  line6_stream_start+0x15b/0x1f0 sound/usb/line6/pcm.c:199
  line6_pcm_acquire+0x139/0x210 sound/usb/line6/pcm.c:322
  call_timer_fn+0x161/0x5f0 kernel/time/timer.c:1325
  expire_timers kernel/time/timer.c:1362 [inline]
  __run_timers kernel/time/timer.c:1681 [inline]
  __run_timers kernel/time/timer.c:1649 [inline]
  run_timer_softirq+0x58b/0x1400 kernel/time/timer.c:1694
  __do_softirq+0x22a/0x8cd kernel/softirq.c:293
  invoke_softirq kernel/softirq.c:374 [inline]
  irq_exit+0x187/0x1b0 kernel/softirq.c:414
  exiting_irq arch/x86/include/asm/apic.h:536 [inline]
  smp_apic_timer_interrupt+0xfe/0x4a0 arch/x86/kernel/apic/apic.c:1062
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:767  
[inline]
RIP: 0010:lock_is_held_type+0x1df/0x250 kernel/locking/lockdep.c:4251
Code: 48 c1 ea 03 0f b6 14 02 48 89 f8 83 e0 07 83 c0 03 38 d0 7c 04 84 d2  
75 6d c7 83 3c 08 00 00 00 00 00 00 48 8b 7c 24 08 57 9d <0f> 1f 44 00 00  
48 83 c4 18 44 89 e8 5b 5d 41 5c 41 5d 41 5e 41 5f
RSP: 0018:ffff888074387a60 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 0000000000000007 RBX: ffff88808c00e200 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff917d62e0 RDI: 0000000000000246
RBP: ffff88808c00e200 R08: 00000000d2d39b7b R09: ffffed1015a05c28
R10: ffffed1015a05c27 R11: ffff8880ad02e13b R12: ffff88808c00ea38
R13: 0000000000000001 R14: ffff88808c00ea40 R15: ffffffff917d62e0
  get_mem_cgroup_from_mm mm/memcontrol.c:851 [inline]
  get_mem_cgroup_from_mm+0x3b6/0x570 mm/memcontrol.c:834
  get_mem_cgroup_from_current mm/memcontrol.c:897 [inline]
  memcg_kmem_get_cache+0x142/0x5d0 mm/memcontrol.c:2548
  slab_pre_alloc_hook mm/slab.h:425 [inline]
  slab_alloc_node mm/slub.c:2682 [inline]
  slab_alloc mm/slub.c:2764 [inline]
  kmem_cache_alloc+0x12f/0x270 mm/slub.c:2769
  copy_sighand kernel/fork.c:1468 [inline]
  copy_process.part.0+0x1e84/0x76b0 kernel/fork.c:1910
  copy_process kernel/fork.c:1709 [inline]
  _do_fork+0x234/0xed0 kernel/fork.c:2226
  do_syscall_64+0xcf/0x4f0 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x45736a
Code: f7 d8 64 89 04 25 d4 02 00 00 64 4c 8b 0c 25 10 00 00 00 31 d2 4d 8d  
91 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff  
ff 0f 87 f5 00 00 00 85 c0 41 89 c5 0f 85 fc 00 00
RSP: 002b:00007fff80f37540 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 00007fff80f37540 RCX: 000000000045736a
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
RBP: 00007fff80f37580 R08: 0000000000000001 R09: 0000000000a57940
R10: 0000000000a57c10 R11: 0000000000000246 R12: 0000000000000001
R13: 0000000000000000 R14: 0000000000000000 R15: 00007fff80f375d0
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

