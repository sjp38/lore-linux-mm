Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 183E7C43387
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 13:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA7C62070B
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 13:31:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA7C62070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A0BD8E0140; Sun,  6 Jan 2019 08:31:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 550F48E0001; Sun,  6 Jan 2019 08:31:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4660C8E0140; Sun,  6 Jan 2019 08:31:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 204B78E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 08:31:05 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id 123so5949849itv.6
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 05:31:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=U6ZAiz8PM2lv1eqCmfc7bB55uxu/ZeZ3gJGG8MVX+AQ=;
        b=Bj0XHx9djw8vIJYb+noAU42X42kxaU24NOPO0ke48C00FpKt1zrnBS1Tj8iibbk2aD
         XgspeixgsqTS6gnp1ZPGwMqORKjfTwAzOUELPe30nNCtzPj4gqKUFUHW8xl9jAeOtKM1
         hA5DiN+WmrvRDBwVCCL9RhM0gDxCTQUfGM+9/yogAACqtH2rPFr2cERBwnVjq1WqdS2w
         V2ufK8OO1WykEhtwoMUNpRIxOtNgl13KKoceHgmjKJuA7n8d/t3AvW/4HCNXKy2W7fJh
         Xwl9R1S1pIvGI/1OdFEweJEtOuuPNyhmO4tTK1GWxhJymJJ4kissjt8TggoyJpGjWTYA
         /gxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3fwmyxakbamwagh2s33w9s770v.y66y3wcaw9u65bw5b.u64@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FwMyXAkbAMwAGH2s33w9s770v.y66y3wCAw9u65Bw5B.u64@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AA+aEWYf9+lhMOzpxLSJJOB7rr1J++YTbx5dh833PsJpiz8xBql1jFt3
	CvN52nFj42oPhUwIe5jJMlR+3Sj6GautCOXLsx/yx8V99IjOtZE1dkGIM2XHbrqSI25XMB0ep5D
	GMLDi6bChfgZ7WxWKZD4iXUyIN+QhxY75ZjewOejAlsoG5byMgqLzV7jkHMKeTYg3i76h4S6PN+
	XfMhzMVqqk5DRnXgYyR4IbgkGDy/0PWC6RVheqF3Toug3gkF04DyDrOai4xrPqgPzqUJpxcavko
	wEhup6RWh8b0BD1xg26iUzU758d0bOawyAjXn6wob/MI+nEa/k+ioOmonExvwEJR6WDMvwIvQom
	nSoBY5HwuOrIkASA9hSReANhO66zhms+ZgiiRuedOPpEMY5ZW64P1GoRkHed00Ur+0mNgHZL5Q=
	=
X-Received: by 2002:a02:9281:: with SMTP id b1mr39681627jah.86.1546781464863;
        Sun, 06 Jan 2019 05:31:04 -0800 (PST)
X-Received: by 2002:a02:9281:: with SMTP id b1mr39681594jah.86.1546781463850;
        Sun, 06 Jan 2019 05:31:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546781463; cv=none;
        d=google.com; s=arc-20160816;
        b=gfR9+N4CYAWqIaNk8oDrcdf+odJQQIt45Yrj8nPOpT6YHuwhJXkdmNlzansxmkODM2
         4d4B7KcO4bkv4KvL7uv5jMGBHU1hwaCfOmMdeioeKqxj/tELAogM0GNO4Ivsn7eKARby
         sgZNfSiNN7P2b4gujh239r+wxgBzsaP09e+gCYBU0neoMHBcQFqhn3AZ6CKlSg+j2mxh
         G1gLyUFY/mtKfazm1YpY0LXLUxF4PSQifHqVG3aCn+Gqh0Qw9zAcovLoI8rl/5scaOmD
         elSx9ImtqIblk6MO1eQL8ZYC+Vhnd6kLHpjnqkgkhBr3TXrweuZaaA4UP2SmZrsnzGyV
         JMrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=U6ZAiz8PM2lv1eqCmfc7bB55uxu/ZeZ3gJGG8MVX+AQ=;
        b=UypqDI1fZ5NSmMf1pF362dYiU0v35RBpYq8W9rrPUre4xkynG6qr1SQlSD22KYiuqX
         v9oQCvN0b/u4nN5C1uxLCeO243J1GiuBvySKQX4zP/TFhvM3ooEh5hPivzZze5K9Iiy2
         HJR2emPD/rGI/C9GqAQjwLpPXxNxfc3/ts9KMNHB+gKd+JD2UvNDt8qnOcNSi6UhkLSy
         3uw8LteY4RD2PkKzkow/Z/RK0DKXwdm1OprOCjgzZY//XZ/EdqGpkcDUZnwIKc7QSfbV
         /rvJ+0p0f4Zry7aYZ2hLqUyb6DdZaIq1RYfiHM2M/ncj15O2VJRpDO8QITFYxY78xSMf
         vn/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3fwmyxakbamwagh2s33w9s770v.y66y3wcaw9u65bw5b.u64@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FwMyXAkbAMwAGH2s33w9s770v.y66y3wCAw9u65Bw5B.u64@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id l14sor22975319jac.7.2019.01.06.05.31.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 05:31:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3fwmyxakbamwagh2s33w9s770v.y66y3wcaw9u65bw5b.u64@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3fwmyxakbamwagh2s33w9s770v.y66y3wcaw9u65bw5b.u64@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FwMyXAkbAMwAGH2s33w9s770v.y66y3wCAw9u65Bw5B.u64@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN7U/3u9LgB0McW/mapeC9QnXkbgg38Ap5yiMnk3Eyf8irSegakaT2Qoh2m/4zcqnJu5Ii+wWMJ0ckZ+2u6BshBEy0gfIkBG
MIME-Version: 1.0
X-Received: by 2002:a02:8785:: with SMTP id t5mr10930781jai.10.1546781463550;
 Sun, 06 Jan 2019 05:31:03 -0800 (PST)
Date: Sun, 06 Jan 2019 05:31:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000ae2357057eca1fa5@google.com>
Subject: KASAN: stack-out-of-bounds Read in check_stack_object
From: syzbot <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com>
To: crecklin@redhat.com, keescook@chromium.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106133103.GyLwc3wYh4Bst-06yle_2qup0jVTHT2P8omPrDu1u4A@z>

Hello,

syzbot found the following crash on:

HEAD commit:    3fed6ae4b027 ia64: fix compile without swiotlb
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=161ce1d7400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
dashboard link: https://syzkaller.appspot.com/bug?extid=05fc3a636f5ee8830a99
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
userspace arch: i386
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10b3769f400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com

------------[ cut here ]------------
DEBUG_LOCKS_WARN_ON(current->hardirq_context)
------------[ cut here ]------------
Bad or missing usercopy whitelist? Kernel memory overwrite attempt detected  
to SLAB object 'task_struct' (offset 912, size 2)!
==================================================================
BUG: KASAN: stack-out-of-bounds in task_stack_page  
include/linux/sched/task_stack.h:21 [inline]
BUG: KASAN: stack-out-of-bounds in check_stack_object+0x14e/0x160  
mm/usercopy.c:39
list_add corruption. next->prev should be prev (ffff8880ae62d8d8), but was  
0000000000000000. (next=ffff8880a94642f0).
Read of size 8 at addr ffff8880a9464258 by task /-1455013312
------------[ cut here ]------------

kernel BUG at lib/list_debug.c:23!
CPU: 0 PID: -1455013312 Comm:  Not tainted 4.20.0+ #10
invalid opcode: 0000 [#1] PREEMPT SMP KASAN
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
CPU: 1 PID: 5941 Comm: syz-executor1 Not tainted 4.20.0+ #10
Call Trace:
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011

RIP: 0010:__list_add_valid.cold+0xf/0x3c lib/list_debug.c:23
Allocated by task 2570092928:
Code: 34 fe eb d5 4c 89 e7 e8 2a dd 34 fe eb a3 4c 89 f7 e8 20 dd 34 fe e9  
56 ff ff ff 4c 89 e1 48 c7 c7 60 b4 81 88 e8 f0 2d d7 fd <0f> 0b 48 89 f2  
4c 89 e1 4c 89 ee 48 c7 c7 a0 b5 81 88 e8 d9 2d d7
RSP: 0018:ffff8880ae707770 EFLAGS: 00010086
RAX: 0000000000000075 RBX: ffff8880a3260730 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff81684c16 RDI: ffffed1015ce0ee0
RBP: ffff8880ae707788 R08: 0000000000000075 R09: ffffed1015ce5021
R10: ffffed1015ce5020 R11: ffff8880ae728107 R12: ffff8880a94642f0
R13: ffff8880a3260730 R14: ffff8880ae62d8d8 R15: ffff8880ae707ad0
FS:  0000000000000000(0000) GS:ffff8880ae700000(0063) knlGS:00000000f7fbbb40
CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
CR2: 0000000000625208 CR3: 00000000a57b8000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  <IRQ>
  __list_add include/linux/list.h:60 [inline]
  list_add include/linux/list.h:79 [inline]
  list_move include/linux/list.h:171 [inline]
  detach_tasks kernel/sched/fair.c:7557 [inline]
  load_balance+0x1bdd/0x39d0 kernel/sched/fair.c:8979
  rebalance_domains+0x815/0xf00 kernel/sched/fair.c:9366
  run_rebalance_domains+0x376/0x4e0 kernel/sched/fair.c:9986
  __do_softirq+0x30b/0xb11 kernel/softirq.c:292
  invoke_softirq kernel/softirq.c:373 [inline]
  irq_exit+0x180/0x1d0 kernel/softirq.c:413
  exiting_irq arch/x86/include/asm/apic.h:536 [inline]
  smp_apic_timer_interrupt+0x1b7/0x760 arch/x86/kernel/apic/apic.c:1062
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:update_stack_state+0x24c/0x680 arch/x86/kernel/unwind_frame.c:244
Code: 48 b9 00 00 00 00 00 fc ff df 4c 89 f6 48 c1 ee 03 80 3c 0e 00 0f 85  
b3 03 00 00 48 39 9d 30 ff ff ff 4d 8b 67 40 40 0f 97 c6 <4d> 85 e4 0f 95  
c1 40 84 ce 74 0c 39 85 44 ff ff ff 0f 84 68 01 00
RSP: 0018:ffff88809870e768 EFLAGS: 00000283 ORIG_RAX: ffffffffffffff13
RAX: 0000000000000001 RBX: ffff88809870ec58 RCX: dffffc0000000000
RDX: ffff888098708000 RSI: 1ffff110130e1d00 RDI: ffff88809870e968
RBP: ffff88809870e850 R08: 0000000000000001 R09: ffff88809870e9a8
R10: ffff88809870e980 R11: ffff88809870e990 R12: ffff88809870e948
R13: dffffc0000000000 R14: ffff88809870e998 R15: ffff88809870e958
  unwind_next_frame.part.0+0x1ae/0xa90 arch/x86/kernel/unwind_frame.c:329
  unwind_next_frame+0x3b/0x50 arch/x86/kernel/unwind_frame.c:287
  __save_stack_trace+0x7a/0xf0 arch/x86/kernel/stacktrace.c:44
  save_stack_trace+0x1a/0x20 arch/x86/kernel/stacktrace.c:60
  save_stack+0x45/0xd0 mm/kasan/common.c:73
  set_track mm/kasan/common.c:85 [inline]
  kasan_kmalloc mm/kasan/common.c:482 [inline]
  kasan_kmalloc+0xcf/0xe0 mm/kasan/common.c:455
  kasan_slab_alloc+0xf/0x20 mm/kasan/common.c:397
  slab_post_alloc_hook mm/slab.h:444 [inline]
  slab_alloc_node mm/slab.c:3322 [inline]
  kmem_cache_alloc_node_trace+0x13c/0x720 mm/slab.c:3648
  __do_kmalloc_node mm/slab.c:3670 [inline]
  __kmalloc_node_track_caller+0x3d/0x70 mm/slab.c:3685
  __kmalloc_reserve.isra.0+0x40/0xe0 net/core/skbuff.c:140
  __alloc_skb+0x12d/0x730 net/core/skbuff.c:208
  alloc_skb include/linux/skbuff.h:1011 [inline]
  alloc_skb_with_frags+0x13a/0x770 net/core/skbuff.c:5288
  sock_alloc_send_pskb+0x8c9/0xad0 net/core/sock.c:2091
  sock_alloc_send_skb+0x32/0x40 net/core/sock.c:2108
  __ip6_append_data.isra.0+0x2556/0x3f20 net/ipv6/ip6_output.c:1443
  ip6_make_skb+0x391/0x5f0 net/ipv6/ip6_output.c:1806
  udpv6_sendmsg+0x2b58/0x3550 net/ipv6/udp.c:1460
  inet_sendmsg+0x1af/0x740 net/ipv4/af_inet.c:798
  sock_sendmsg_nosec net/socket.c:621 [inline]
  sock_sendmsg+0xdd/0x130 net/socket.c:631
  ___sys_sendmsg+0x409/0x910 net/socket.c:2116
  __sys_sendmmsg+0x3bc/0x730 net/socket.c:2204
  __compat_sys_sendmmsg net/compat.c:771 [inline]
  __do_compat_sys_sendmmsg net/compat.c:778 [inline]
  __se_compat_sys_sendmmsg net/compat.c:775 [inline]
  __ia32_compat_sys_sendmmsg+0x9f/0x100 net/compat.c:775
  do_syscall_32_irqs_on arch/x86/entry/common.c:326 [inline]
  do_fast_syscall_32+0x333/0xf98 arch/x86/entry/common.c:397
  entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139
RIP: 0023:0xf7fbf869
Code: 85 d2 74 02 89 0a 5b 5d c3 8b 04 24 c3 8b 14 24 c3 8b 3c 24 c3 90 90  
90 90 90 90 90 90 90 90 90 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90  
90 90 90 eb 0d 90 90 90 90 90 90 90 90 90 90 90 90
RSP: 002b:00000000f7fbb0cc EFLAGS: 00000296 ORIG_RAX: 0000000000000159
RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000020005fc0
RDX: 00000000000000fc RSI: 0000000008000000 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
Modules linked in:
---[ end trace e0e50d48068f1e3d ]---
BUG: unable to handle kernel paging request at ffffffff8cf14780
#PF error: [normal kernel read fault]
RIP: 0010:__list_add_valid.cold+0xf/0x3c lib/list_debug.c:23
PGD 9874067 P4D 9874067 PUD 9875063 PMD 0
Code: 34 fe eb d5 4c 89 e7 e8 2a dd 34 fe eb a3 4c 89 f7 e8 20 dd 34 fe e9  
56 ff ff ff 4c 89 e1 48 c7 c7 60 b4 81 88 e8 f0 2d d7 fd <0f> 0b 48 89 f2  
4c 89 e1 4c 89 ee 48 c7 c7 a0 b5 81 88 e8 d9 2d d7
Thread overran stack, or stack corrupted
RSP: 0018:ffff8880ae707770 EFLAGS: 00010086
Oops: 0000 [#2] PREEMPT SMP KASAN
RAX: 0000000000000075 RBX: ffff8880a3260730 RCX: 0000000000000000
CPU: 0 PID: -1455013312 Comm:  Tainted: G      D           4.20.0+ #10
RDX: 0000000000000000 RSI: ffffffff81684c16 RDI: ffffed1015ce0ee0
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RBP: ffff8880ae707788 R08: 0000000000000075 R09: ffffed1015ce5021
RIP: 0010:depot_fetch_stack+0x10/0x30 lib/stackdepot.c:202
R10: ffffed1015ce5020 R11: ffff8880ae728107 R12: ffff8880a94642f0
Code: e6 72 22 fe e9 20 fe ff ff 48 89 df e8 d9 72 22 fe e9 f1 fd ff ff 90  
90 90 90 89 f8 c1 ef 11 25 ff ff 1f 00 81 e7 f0 3f 00 00 <48> 03 3c c5 80  
03 f5 8b 8b 47 0c 48 83 c7 18 c7 46 10 00 00 00 00
R13: ffff8880a3260730 R14: ffff8880ae62d8d8 R15: ffff8880ae707ad0
RSP: 0018:ffff8880a9463fb8 EFLAGS: 00010006
FS:  0000000000000000(0000) GS:ffff8880ae700000(0063) knlGS:00000000f7fbbb40
RAX: 00000000001f8880 RBX: ffff8880a9465a04 RCX: 0000000000000000
CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
RDX: 0000000000000000 RSI: ffff8880a9463fc0 RDI: 0000000000003ff0
CR2: 0000000000625208 CR3: 00000000a57b8000 CR4: 00000000001406e0
RBP: ffff8880a9463fe8 R08: 000000000000001d R09: ffffed1015cc3ef9
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
R10: ffffed1015cc3ef8 R11: ffff8880ae61f7c7 R12: ffffea0002a51900
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
R13: ffff8880a9464258 R14: ffff8880aa13d900 R15: ffff8880a9465a00


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

