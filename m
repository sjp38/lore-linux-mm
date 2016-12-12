Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEC446B0038
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 21:55:15 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id j198so159990323oih.5
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 18:55:15 -0800 (PST)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id 10si20613755otm.169.2016.12.11.18.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 18:55:14 -0800 (PST)
Received: by mail-oi0-x22b.google.com with SMTP id b126so75287726oia.2
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 18:55:14 -0800 (PST)
MIME-Version: 1.0
From: Andrei Vagin <avagin@gmail.com>
Date: Sun, 11 Dec 2016 18:55:14 -0800
Message-ID: <CANaxB-y0rcGcVY1_CRzRp7to-C3k7tSM5GDwzyLvzj5_BKP5Mw@mail.gmail.com>
Subject: linux-next: kernel BUG at mm/vmalloc.c:463!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>

Hi,

CRIU tests triggered a kernel bug:

[   80.470890] kernel BUG at mm/vmalloc.c:463!
[   80.471007] invalid opcode: 0000 [#1] SMP
[   80.471007] Modules linked in:
[   80.471007] CPU: 0 PID: 14795 Comm: criu Not tainted
4.9.0-rc8-next-20161209 #114
[   80.471007] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.9.1-1.fc24 04/01/2014
[   80.471007] task: ffff8bc26c34a680 task.stack: ffff9c6a43d58000
[   80.471007] RIP: 0010:alloc_vmap_area+0x366/0x390
[   80.471007] RSP: 0018:ffff9c6a43d5bc58 EFLAGS: 00010206
[   80.471007] RAX: ffff8bc272ce8000 RBX: ffff8bc267b11420 RCX: 0000000000000000
[   80.471007] RDX: ffffffff8b222bb3 RSI: 0000000000000000 RDI: ffffffff8bc7e7e0
[   80.471007] RBP: ffff9c6a43d5bcb0 R08: ffffffff8bc7e7d0 R09: 0000000000000000
[   80.471007] R10: 0000000000000001 R11: 0000000000000000 R12: ffff9c6a40000000
[   80.471007] R13: ffff9c6a40000000 R14: ffffffffffffc000 R15: 0000000000003fff
[   80.471007] FS:  00007fac30a4f800(0000) GS:ffff8bc27fc00000(0000)
knlGS:0000000000000000
[   80.471007] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   80.471007] CR2: 00000000006fc618 CR3: 000000012ffd9000 CR4: 00000000003406f0
[   80.471007] DR0: 0000000000010130 DR1: 0000000000000000 DR2: 0000000000000000
[   80.471007] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[   80.471007] Call Trace:
[   80.471007]  __get_vm_area_node+0xb7/0x170
[   80.471007]  __vmalloc_node_range+0x73/0x290
[   80.471007]  ? _do_fork+0xf3/0x6f0
[   80.471007]  ? copy_process.part.31+0x12a/0x20c0
[   80.471007]  copy_process.part.31+0x793/0x20c0
[   80.471007]  ? _do_fork+0xf3/0x6f0
[   80.471007]  _do_fork+0xf3/0x6f0
[   80.471007]  ? __might_fault+0x8c/0xa0
[   80.471007]  ? __might_fault+0x43/0xa0
[   80.471007]  ? trace_hardirqs_on_caller+0xf5/0x1b0
[   80.471007]  SyS_clone+0x19/0x20
[   80.471007]  do_syscall_64+0x6c/0x1f0
[   80.471007]  entry_SYSCALL64_slow_path+0x25/0x25
[   80.471007] RIP: 0033:0x7fac2f6b6941
[   80.471007] RSP: 002b:00007ffdb42f3c30 EFLAGS: 00000246 ORIG_RAX:
0000000000000038
[   80.471007] RAX: ffffffffffffffda RBX: 00007ffdb42f3c30 RCX: 00007fac2f6b6941
[   80.471007] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[   80.471007] RBP: 00007ffdb42f3c80 R08: 00007fac30a4f800 R09: 000000000000001c
[   80.471007] R10: 00007fac30a4fad0 R11: 0000000000000246 R12: 0000000000000000
[   80.471007] R13: 0000000000000020 R14: 0000000000000000 R15: 0000000000000000
[   80.471007] Code: 18 97 01 e8 1d 72 5a 00 48 8b 03 4c 85 f8 75 19
49 39 c5 77 16 48 8b 45 a8 48 8b 5d b0 48 3b 58 08 0f 83 5e ff ff ff
0f 0b 0f 0b <0f> 0b e8 23 c7 e6 ff 48 89 3d 24 18 97 01 e9 cd fe ff ff
4c 89
[   80.471007] RIP: alloc_vmap_area+0x366/0x390 RSP: ffff9c6a43d5bc58
[   80.506584] ---[ end trace 14dbfb61a09961b9 ]---


Steps to reproduce:
$ apt-get install gcc make protobuf-c-compiler libprotobuf-c0-dev libaio-dev \
libprotobuf-dev protobuf-compiler python-ipaddr libcap-dev \
libnl-3-dev gdb bash python-protobuf
$ git clone https://github.com/xemul/criu.git
$ cd criu
$ make
$ python test/zdtm.py run -a -p 4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
