Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4B5BC43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 02:33:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CCE520651
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 02:33:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CCE520651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD2738E0004; Wed, 16 Jan 2019 21:33:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D80628E0002; Wed, 16 Jan 2019 21:33:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6EFA8E0004; Wed, 16 Jan 2019 21:33:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A18F8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 21:33:06 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id b14so3679062itd.1
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 18:33:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=9iYWz2U9DaZDQJoJs93gFR59qcXySa/M63bO0obIbsg=;
        b=K/i2B7wIHdJAq3f1grlkmJ3IXphmjFh8OXhj2957m9Q9T1Gh/Lp98UJoHYlkJ3uw1r
         BmjZAi/GPiKasXYG9h0tkeWbmfu75PXMNG1vXDRxeyFnMVAwEcocFhqtbsLU1iGXZYFO
         43wcrNuQsg8B3oQp/gMMmb2/u5Fsa7e7f3EvA5dcXGd50byoi2qxupRCSdUx0t+6TK0Y
         yRYcAFL0irujUeWhGf0APAfbzZEdL98BjHzJk24zkBT2Pnt7jg+o/NGXKH2kQ+ombwrs
         T2XXuFlAitSaSvbLOs/2+4rB553a688RvdSFxiLsfYKngnyVXgqNu79XmZJj9gwja7/A
         XMSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3yok_xakbabsjpqb1cc5i1gg94.7ff7c5lj5i3fek5ek.3fd@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3YOk_XAkbABsJPQB1CC5I1GG94.7FF7C5LJ5I3FEK5EK.3FD@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukeXEbBIzQQQaApUvziiHFYiE3AeBM6RC6wp6J/euj+GbX789b6G
	UmNMiFhKK9fOZXeXOyOLwZ7NUjzLkbBeuIRdayIndkr42eieWzbKm+Vg++cdzjmWShXamxX2jvS
	qa1mrqz3SQShtqNxOKqIdUD0yYHxfMcM/dpy4GWtSxuYyAkLUzR3hqBKOkcHF/7OJa2sCKbdRKE
	wR7Vama4tMhO86iWbERAOMyOWIQuCA0tTEMcnCVjlomTrnOdfKwB6hd3Q226DRtqVIGqU3kejAr
	d/m7iQPcvseit3F+tfZprg5SJ67NTjTOOEP3delzWRNSO3NMSZxbAackf8a1NhBk6ytrYw1Ul1P
	nlESUenAUwuPkawZHz3rr4yI/HqAfbPRWcQi4UAe54Zy9ECQH04WcTiU0nbyuN8bo/YNuJ1Fsg=
	=
X-Received: by 2002:a02:c88:: with SMTP id 8mr6940406jan.87.1547692386323;
        Wed, 16 Jan 2019 18:33:06 -0800 (PST)
X-Received: by 2002:a02:c88:: with SMTP id 8mr6940373jan.87.1547692384889;
        Wed, 16 Jan 2019 18:33:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547692384; cv=none;
        d=google.com; s=arc-20160816;
        b=BpNfTDKI9nNrQiW01NnD/gpcLBDsvO6UHmEquTnXGtdOJZmro8n0GbedR8K10ZNxRR
         n8n0jIDeieXoqHcAHewOZBJpHErH2nmGwYibhZVNGtl/6vgG/S5pNVpNwMysIcCxBnTu
         6HE0rE32WJB8NFWSrLa7iOX1HFMvhMLLt6zCOpMkypWVwmS/IzE0gYy8NZCWnQwerZNs
         eFvSxwenDrLE2BRNMVmvI6sf2cvqa74QWZn63elyMUnJS1nD3/LN0W4AY3u8sXWnVsJO
         2PTJZ+8WDl1V/BZD8tFju31xjiXjf7kY4ST4CjvxdF3su4jP+K04nplWJJLezvj3HjAB
         y3hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=9iYWz2U9DaZDQJoJs93gFR59qcXySa/M63bO0obIbsg=;
        b=tyBmpBpBi79lQxesbvnedpPEmN7jZT2LvgqMGmQWOj3SA4gVthhjBCkVIWqGZHw09x
         JZmkGh5TQ5Nf1dTNZjeMPqFz7fdQS+cpzuMGca0pEQNxFKmDEUoWH9kNigJRztRr1IPR
         Bha8eV8Bv7ej5GdhaOZW2Y+JgvVlrCSARdTw0/Cue6HtLDRnvlIVBs3KUflGkrlJDl7Y
         mi9Tnw/oyqDhC+fTPAUZi2bDhuHWTDRychZvijwiVUdMLM5KubFb3DTnPXSIX2YjqyVY
         HTZZlJzxnddD/JIWLeILHXcoi/0A0/OiPhBgJ2ArqIJn5/XcnRCQF9q/mOE8+2GsFbNx
         fJ9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3yok_xakbabsjpqb1cc5i1gg94.7ff7c5lj5i3fek5ek.3fd@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3YOk_XAkbABsJPQB1CC5I1GG94.7FF7C5LJ5I3FEK5EK.3FD@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id r204sor257914ita.16.2019.01.16.18.33.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 18:33:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 3yok_xakbabsjpqb1cc5i1gg94.7ff7c5lj5i3fek5ek.3fd@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3yok_xakbabsjpqb1cc5i1gg94.7ff7c5lj5i3fek5ek.3fd@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3YOk_XAkbABsJPQB1CC5I1GG94.7FF7C5LJ5I3FEK5EK.3FD@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN5tWPIN5Ij97PgrCHPn1K9wE+E79IZpMo8sUy2bwOR+AUoGY+nqfxeufwpDK36oFy4ZWvxbsooOzeOGmWZ70c2gV7j+byyV
MIME-Version: 1.0
X-Received: by 2002:a24:2c43:: with SMTP id i64mr7703276iti.2.1547692384563;
 Wed, 16 Jan 2019 18:33:04 -0800 (PST)
Date: Wed, 16 Jan 2019 18:33:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000cdc61b057f9e360e@google.com>
Subject: kernel BUG at mm/page_alloc.c:LINE!
From: syzbot <syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, 
	mhocko@suse.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, 
	vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117023304.qwqETC4fU6qbvjt5fBas-i5OoQpzPKzYmPDyeCEHlL4@z>

Hello,

syzbot found the following crash on:

HEAD commit:    b808822a75a3 Add linux-next specific files for 20190111
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=16a471d8c00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c052ead0aed5001b
dashboard link: https://syzkaller.appspot.com/bug?extid=80dd4798c16c634daf15
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com

------------[ cut here ]------------
kernel BUG at mm/page_alloc.c:3112!
invalid opcode: 0000 [#1] PREEMPT SMP KASAN
CPU: 0 PID: 1043 Comm: kcompactd0 Not tainted 5.0.0-rc1-next-20190111 #10
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3112
Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd  
ff ff 48 c7 c6 a0 63 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6  
c0 64 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
RSP: 0000:ffff8880a78e6f58 EFLAGS: 00010007
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88812fffc7e0
RDX: 1ffff11025fff8fc RSI: 0000000000000007 RDI: ffff88812fffc7b0
RBP: ffff8880a78e7018 R08: ffff8880a78ce000 R09: ffffed1014f1cdf2
R10: ffffed1014f1cdf1 R11: 0000000000000003 R12: ffff88812fffc7b0
R13: 1ffff11014f1cdf2 R14: ffff88812fffc7b0 R15: ffff8880a78e6ff0
FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000438ca0 CR3: 0000000009871000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Call Trace:
  fast_isolate_freepages mm/compaction.c:1356 [inline]
  isolate_freepages mm/compaction.c:1429 [inline]
  compaction_alloc+0xd05/0x2970 mm/compaction.c:1541
  unmap_and_move mm/migrate.c:1177 [inline]
  migrate_pages+0x48e/0x2cc0 mm/migrate.c:1417
  compact_zone+0x2207/0x3e90 mm/compaction.c:2173
  kcompactd_do_work+0x6de/0x1200 mm/compaction.c:2564
  kcompactd+0x251/0x970 mm/compaction.c:2657
  kthread+0x357/0x430 kernel/kthread.c:247
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
Modules linked in:

======================================================
WARNING: possible circular locking dependency detected
5.0.0-rc1-next-20190111 #10 Not tainted
------------------------------------------------------
kcompactd0/1043 is trying to acquire lock:
00000000a0848583 (console_owner){-.-.}, at: log_next  
kernel/printk/printk.c:499 [inline]
00000000a0848583 (console_owner){-.-.}, at: console_unlock+0x4ac/0x1040  
kernel/printk/printk.c:2442

but task is already holding lock:
00000000c8e67de2 (&(&zone->lock)->rlock){..-.}, at: fast_isolate_freepages  
mm/compaction.c:1313 [inline]
00000000c8e67de2 (&(&zone->lock)->rlock){..-.}, at: isolate_freepages  
mm/compaction.c:1429 [inline]
00000000c8e67de2 (&(&zone->lock)->rlock){..-.}, at:  
compaction_alloc+0x6f3/0x2970 mm/compaction.c:1541

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3 (&(&zone->lock)->rlock){..-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:152
        rmqueue mm/page_alloc.c:3253 [inline]
        get_page_from_freelist+0xf6c/0x4870 mm/page_alloc.c:3668
        __alloc_pages_nodemask+0x4fd/0xdc0 mm/page_alloc.c:4714
        alloc_pages_current+0x107/0x210 mm/mempolicy.c:2106
        alloc_pages include/linux/gfp.h:509 [inline]
        depot_save_stack+0x3da/0x460 lib/stackdepot.c:260
        save_stack+0xa9/0xd0 mm/kasan/common.c:79
        set_track mm/kasan/common.c:85 [inline]
        __kasan_kmalloc mm/kasan/common.c:496 [inline]
        __kasan_kmalloc.constprop.0+0xcf/0xe0 mm/kasan/common.c:469
        kasan_kmalloc mm/kasan/common.c:504 [inline]
        kasan_slab_alloc+0xf/0x20 mm/kasan/common.c:411
        slab_post_alloc_hook mm/slab.h:440 [inline]
        slab_alloc mm/slab.c:3381 [inline]
        __do_kmalloc mm/slab.c:3709 [inline]
        __kmalloc+0x145/0x740 mm/slab.c:3720
        kmalloc include/linux/slab.h:550 [inline]
        tty_buffer_alloc drivers/tty/tty_buffer.c:175 [inline]
        __tty_buffer_request_room+0x2bf/0x7e0 drivers/tty/tty_buffer.c:273
        tty_insert_flip_string_fixed_flag+0x93/0x1f0  
drivers/tty/tty_buffer.c:318
        tty_insert_flip_string include/linux/tty_flip.h:37 [inline]
        pty_write+0x133/0x200 drivers/tty/pty.c:122
        tty_put_char+0x137/0x160 drivers/tty/tty_io.c:3022
        __process_echoes+0x5c8/0xa40 drivers/tty/n_tty.c:726
        flush_echoes drivers/tty/n_tty.c:827 [inline]
        __receive_buf drivers/tty/n_tty.c:1646 [inline]
        n_tty_receive_buf_common+0xc2c/0x2f30 drivers/tty/n_tty.c:1740
        n_tty_receive_buf2+0x34/0x40 drivers/tty/n_tty.c:1775
        tty_ldisc_receive_buf+0xaf/0x1c0 drivers/tty/tty_buffer.c:461
        tty_port_default_receive_buf+0x114/0x190 drivers/tty/tty_port.c:38
        receive_buf drivers/tty/tty_buffer.c:481 [inline]
        flush_to_ldisc+0x3b2/0x590 drivers/tty/tty_buffer.c:533
        process_one_work+0xd0c/0x1ce0 kernel/workqueue.c:2153
        worker_thread+0x143/0x14a0 kernel/workqueue.c:2296
        kthread+0x357/0x430 kernel/kthread.c:247
        ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352

-> #2 (&(&port->lock)->rlock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:152
        tty_port_tty_get+0x22/0x80 drivers/tty/tty_port.c:287
        tty_port_default_wakeup+0x16/0x40 drivers/tty/tty_port.c:47
        tty_port_tty_wakeup+0x5d/0x70 drivers/tty/tty_port.c:387
        uart_write_wakeup+0x46/0x70 drivers/tty/serial/serial_core.c:103
        serial8250_tx_chars+0x4a4/0xb20  
drivers/tty/serial/8250/8250_port.c:1806
        serial8250_handle_irq.part.0+0x1be/0x2e0  
drivers/tty/serial/8250/8250_port.c:1879
        serial8250_handle_irq drivers/tty/serial/8250/8250_port.c:1865  
[inline]
        serial8250_default_handle_irq+0xc5/0x150  
drivers/tty/serial/8250/8250_port.c:1895
        serial8250_interrupt+0xfb/0x1a0  
drivers/tty/serial/8250/8250_core.c:125
        __handle_irq_event_percpu+0x1c6/0xb10 kernel/irq/handle.c:149
        handle_irq_event_percpu+0xa0/0x1d0 kernel/irq/handle.c:189
        handle_irq_event+0xa7/0x134 kernel/irq/handle.c:206
        handle_edge_irq+0x232/0x8a0 kernel/irq/chip.c:791
        generic_handle_irq_desc include/linux/irqdesc.h:154 [inline]
        handle_irq+0x252/0x3d8 arch/x86/kernel/irq_64.c:78
        do_IRQ+0x99/0x1d0 arch/x86/kernel/irq.c:246
        ret_from_intr+0x0/0x1e
        native_safe_halt+0x2/0x10 arch/x86/include/asm/irqflags.h:57
        arch_cpu_idle+0x10/0x20 arch/x86/kernel/process.c:555
        default_idle_call+0x36/0x90 kernel/sched/idle.c:93
        cpuidle_idle_call kernel/sched/idle.c:153 [inline]
        do_idle+0x386/0x5d0 kernel/sched/idle.c:262
        cpu_startup_entry+0x1b/0x20 kernel/sched/idle.c:353
        start_secondary+0x435/0x620 arch/x86/kernel/smpboot.c:272
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243

-> #1 (&port_lock_key){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:152
        serial8250_console_write+0x253/0xab0  
drivers/tty/serial/8250/8250_port.c:3245
        univ8250_console_write+0x5f/0x70  
drivers/tty/serial/8250/8250_core.c:586
        call_console_drivers kernel/printk/printk.c:1784 [inline]
        console_unlock+0xc9a/0x1040 kernel/printk/printk.c:2455
        vprintk_emit+0x370/0x960 kernel/printk/printk.c:1978
        vprintk_default+0x28/0x30 kernel/printk/printk.c:2005
        vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:398
        printk+0xba/0xed kernel/printk/printk.c:2038
        register_console+0x74d/0xb50 kernel/printk/printk.c:2770
        univ8250_console_init+0x3e/0x4b  
drivers/tty/serial/8250/8250_core.c:681
        console_init+0x6b7/0x9fe kernel/printk/printk.c:2856
        start_kernel+0x5df/0x8bd init/main.c:667
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:470
        x86_64_start_kernel+0x77/0x7b arch/x86/kernel/head64.c:451
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243

-> #0 (console_owner){-.-.}:
        lock_acquire+0x1db/0x570 kernel/locking/lockdep.c:3860
        console_lock_spinning_enable kernel/printk/printk.c:1647 [inline]
        console_unlock+0x516/0x1040 kernel/printk/printk.c:2452
        vprintk_emit+0x370/0x960 kernel/printk/printk.c:1978
        vprintk_default+0x28/0x30 kernel/printk/printk.c:2005
        vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:398
        printk+0xba/0xed kernel/printk/printk.c:2038
        report_bug.cold+0x11/0x5e lib/bug.c:191
        fixup_bug arch/x86/kernel/traps.c:178 [inline]
        fixup_bug arch/x86/kernel/traps.c:173 [inline]
        do_error_trap+0x11b/0x200 arch/x86/kernel/traps.c:271
        do_invalid_op+0x37/0x50 arch/x86/kernel/traps.c:290
        invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:973
        __ClearPageBuddy include/linux/page-flags.h:706 [inline]
        rmv_page_order mm/page_alloc.c:744 [inline]
        rmv_page_order mm/page_alloc.c:742 [inline]
        __isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3134
        fast_isolate_freepages mm/compaction.c:1356 [inline]
        isolate_freepages mm/compaction.c:1429 [inline]
        compaction_alloc+0xd05/0x2970 mm/compaction.c:1541
        unmap_and_move mm/migrate.c:1177 [inline]
        migrate_pages+0x48e/0x2cc0 mm/migrate.c:1417
        compact_zone+0x2207/0x3e90 mm/compaction.c:2173
        kcompactd_do_work+0x6de/0x1200 mm/compaction.c:2564
        kcompactd+0x251/0x970 mm/compaction.c:2657
        kthread+0x357/0x430 kernel/kthread.c:247
        ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352

other info that might help us debug this:

Chain exists of:
   console_owner --> &(&port->lock)->rlock --> &(&zone->lock)->rlock

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&(&zone->lock)->rlock);
                                lock(&(&port->lock)->rlock);
                                lock(&(&zone->lock)->rlock);
   lock(console_owner);

  *** DEADLOCK ***

2 locks held by kcompactd0/1043:
  #0: 00000000c8e67de2 (&(&zone->lock)->rlock){..-.}, at:  
fast_isolate_freepages mm/compaction.c:1313 [inline]
  #0: 00000000c8e67de2 (&(&zone->lock)->rlock){..-.}, at: isolate_freepages  
mm/compaction.c:1429 [inline]
  #0: 00000000c8e67de2 (&(&zone->lock)->rlock){..-.}, at:  
compaction_alloc+0x6f3/0x2970 mm/compaction.c:1541
  #1: 0000000001912981 (console_lock){+.+.}, at: console_trylock_spinning  
kernel/printk/printk.c:1709 [inline]
  #1: 0000000001912981 (console_lock){+.+.}, at: vprintk_emit+0x351/0x960  
kernel/printk/printk.c:1977

stack backtrace:
CPU: 0 PID: 1043 Comm: kcompactd0 Not tainted 5.0.0-rc1-next-20190111 #10
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1db/0x2d0 lib/dump_stack.c:113
  print_circular_bug.isra.0.cold+0x1cc/0x28f kernel/locking/lockdep.c:1225
  check_prev_add kernel/locking/lockdep.c:1867 [inline]
  check_prevs_add kernel/locking/lockdep.c:1980 [inline]
  validate_chain kernel/locking/lockdep.c:2351 [inline]
  __lock_acquire+0x2fed/0x4a10 kernel/locking/lockdep.c:3339
  lock_acquire+0x1db/0x570 kernel/locking/lockdep.c:3860
  console_lock_spinning_enable kernel/printk/printk.c:1647 [inline]
  console_unlock+0x516/0x1040 kernel/printk/printk.c:2452
  vprintk_emit+0x370/0x960 kernel/printk/printk.c:1978
  vprintk_default+0x28/0x30 kernel/printk/printk.c:2005
  vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:398
  printk+0xba/0xed kernel/printk/printk.c:2038
  report_bug.cold+0x11/0x5e lib/bug.c:191
  fixup_bug arch/x86/kernel/traps.c:178 [inline]
  fixup_bug arch/x86/kernel/traps.c:173 [inline]
  do_error_trap+0x11b/0x200 arch/x86/kernel/traps.c:271
  do_invalid_op+0x37/0x50 arch/x86/kernel/traps.c:290
  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:973
RIP: 0010:__isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3112
Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd  
ff ff 48 c7 c6 a0 63 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6  
c0 64 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
RSP: 0000:ffff8880a78e6f58 EFLAGS: 00010007
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88812fffc7e0
RDX: 1ffff11025fff8fc RSI: 0000000000000007 RDI: ffff88812fffc7b0
RBP: ffff8880a78e7018 R08: ffff8880a78ce000 R09: ffffed1014f1cdf2
R10: ffffed1014f1cdf1 R11: 0000000000000003 R12: ffff88812fffc7b0
R13: 1ffff11014f1cdf2 R14: ffff88812fffc7b0 R15: ffff8880a78e6ff0
  fast_isolate_freepages mm/compaction.c:1356 [inline]
  isolate_freepages mm/compaction.c:1429 [inline]
  compaction_alloc+0xd05/0x2970 mm/compaction.c:1541
  unmap_and_move mm/migrate.c:1177 [inline]
  migrate_pages+0x48e/0x2cc0 mm/migrate.c:1417
  compact_zone+0x2207/0x3e90 mm/compaction.c:2173
Lost 33 message(s)!
---[ end trace b088aebfc4c7ea50 ]---
RIP: 0010:__isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3112
Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd  
ff ff 48 c7 c6 a0 63 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6  
c0 64 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
RSP: 0000:ffff8880a78e6f58 EFLAGS: 00010007
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88812fffc7e0
RDX: 1ffff11025fff8fc RSI: 0000000000000007 RDI: ffff88812fffc7b0
RBP: ffff8880a78e7018 R08: ffff8880a78ce000 R09: ffffed1014f1cdf2
R10: ffffed1014f1cdf1 R11: 0000000000000003 R12: ffff88812fffc7b0
R13: 1ffff11014f1cdf2 R14: ffff88812fffc7b0 R15: ffff8880a78e6ff0
FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000438ca0 CR3: 0000000009871000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.

