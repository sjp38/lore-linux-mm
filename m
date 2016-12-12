Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 817D76B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 01:54:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so109513311pfb.7
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 22:54:21 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id o61si42405892plb.168.2016.12.11.22.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 22:54:20 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CANaxB-y0rcGcVY1_CRzRp7to-C3k7tSM5GDwzyLvzj5_BKP5Mw@mail.gmail.com>
	<CANaxB-yqO6gmMJkpYiWp7fq-TJwPo6yHGaLvQgHPJ0ug+j5STQ@mail.gmail.com>
Date: Mon, 12 Dec 2016 19:51:12 +1300
In-Reply-To: <CANaxB-yqO6gmMJkpYiWp7fq-TJwPo6yHGaLvQgHPJ0ug+j5STQ@mail.gmail.com>
	(Andrei Vagin's message of "Sun, 11 Dec 2016 22:04:04 -0800")
Message-ID: <87eg1dk5cv.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: linux-next: kernel BUG at mm/vmalloc.c:463!
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrei Vagin <avagin@gmail.com>
Cc: linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>

Andrei Vagin <avagin@gmail.com> writes:

> On Sun, Dec 11, 2016 at 6:55 PM, Andrei Vagin <avagin@gmail.com> wrote:
>> Hi,
>>
>> CRIU tests triggered a kernel bug:
>
> I''ve booted this kernel with slub_debug=FZ and now I see these
> messages:

I think I have dropped the cause of this corruption from my linux-next
tree, and hopefully from linux-next.  

I believe this was: "inotify: Convert to using per-namespace limits"
If you could verify dropping/reverting that patch from linux-next causes
this failure to go away I would appreciate.

I am quite puzzled why that patch causes heap corruption but it seems clear
it does.

If you can trigger this problem without that patch I would really
appreciate knowing.

Thank you,
Eric

> [  119.130447] BUG kmalloc-512 (Not tainted): Freepointer corrupt
> [  119.130447] -----------------------------------------------------------------------------
> [  119.130447]
> [  119.130447] Disabling lock debugging due to kernel taint
> [  119.130447] INFO: Allocated in setup_userns_sysctls+0x44/0xd0
> age=1588 cpu=1 pid=7327
> [  119.130447] ___slab_alloc+0x557/0x5c0
> [  119.130447] __slab_alloc+0x51/0x90
> [  119.130447] __kmalloc_track_caller+0x213/0x2e0
> [  119.130447] kmemdup+0x20/0x50
> [  119.130447] setup_userns_sysctls+0x44/0xd0
> [  119.130447] create_user_ns+0x287/0x380
> [  119.130447] copy_creds+0xf3/0x130
> [  119.130447] copy_process.part.32+0x316/0x20c0
> [  119.130447] _do_fork+0xf3/0x6f0
> [  119.130447] SyS_clone+0x19/0x20
> [  119.130447] do_syscall_64+0x6c/0x1f0
> [  119.130447] return_from_SYSCALL_64+0x0/0x7a
> [  119.130447] INFO: Freed in load_elf_binary+0xa4f/0x1690 age=1589
> cpu=0 pid=7326
> [  119.130447] __slab_free+0x1ed/0x370
> [  119.130447] kfree+0x20d/0x290
> [  119.130447] load_elf_binary+0xa4f/0x1690
> [  119.130447] search_binary_handler+0xa1/0x200
> [  119.130447] do_execveat_common.isra.35+0x6f5/0xa10
> [  119.130447] SyS_execve+0x3a/0x50
> [  119.130447] do_syscall_64+0x6c/0x1f0
> [  119.130447] return_from_SYSCALL_64+0x0/0x7a
> [  119.130447] INFO: Slab 0xfffffaeb84dba700 objects=19 used=17
> fp=0xffff950b36e9eb18 flags=0x2fffc000004081
> [  119.130447] INFO: Object 0xffff950b36e9c358 @offset=856 fp=0xffff950b29c90258
> [  119.130447]
> [  119.130447] Redzone ffff950b36e9c350: cc cc cc cc cc cc cc cc
>                    ........
> [  119.130447] Object ffff950b36e9c358: 51 0c 9f 97 ff ff ff ff 38 02
> c9 29 0b 95 ff ff  Q.......8..)....
> [  119.130447] Object ffff950b36e9c368: 04 00 00 00 a4 01 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c378: 00 a9 09 97 ff ff ff ff 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c388: e0 27 ec 97 ff ff ff ff 40 33
> c5 97 ff ff ff ff  .'......@3......
> [  119.130447] Object ffff950b36e9c398: 65 0c 9f 97 ff ff ff ff 3c 02
> c9 29 0b 95 ff ff  e.......<..)....
> [  119.130447] Object ffff950b36e9c3a8: 04 00 00 00 a4 01 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c3b8: 00 a9 09 97 ff ff ff ff 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c3c8: e0 27 ec 97 ff ff ff ff 40 33
> c5 97 ff ff ff ff  .'......@3......
> [  119.130447] Object ffff950b36e9c3d8: 78 0c 9f 97 ff ff ff ff 40 02
> c9 29 0b 95 ff ff  x.......@..)....
> [  119.130447] Object ffff950b36e9c3e8: 04 00 00 00 a4 01 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c3f8: 00 a9 09 97 ff ff ff ff 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c408: e0 27 ec 97 ff ff ff ff 40 33
> c5 97 ff ff ff ff  .'......@3......
> [  119.130447] Object ffff950b36e9c418: 8b 0c 9f 97 ff ff ff ff 44 02
> c9 29 0b 95 ff ff  ........D..)....
> [  119.130447] Object ffff950b36e9c428: 04 00 00 00 a4 01 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c438: 00 a9 09 97 ff ff ff ff 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c448: e0 27 ec 97 ff ff ff ff 40 33
> c5 97 ff ff ff ff  .'......@3......
> [  119.130447] Object ffff950b36e9c458: 9e 0c 9f 97 ff ff ff ff 48 02
> c9 29 0b 95 ff ff  ........H..)....
> [  119.130447] Object ffff950b36e9c468: 04 00 00 00 a4 01 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c478: 00 a9 09 97 ff ff ff ff 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c488: e0 27 ec 97 ff ff ff ff 40 33
> c5 97 ff ff ff ff  .'......@3......
> [  119.130447] Object ffff950b36e9c498: b1 0c 9f 97 ff ff ff ff 4c 02
> c9 29 0b 95 ff ff  ........L..)....
> [  119.130447] Object ffff950b36e9c4a8: 04 00 00 00 a4 01 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c4b8: 00 a9 09 97 ff ff ff ff 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c4c8: e0 27 ec 97 ff ff ff ff 40 33
> c5 97 ff ff ff ff  .'......@3......
> [  119.130447] Object ffff950b36e9c4d8: c4 0c 9f 97 ff ff ff ff 50 02
> c9 29 0b 95 ff ff  ........P..)....
> [  119.130447] Object ffff950b36e9c4e8: 04 00 00 00 a4 01 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c4f8: 00 a9 09 97 ff ff ff ff 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c508: e0 27 ec 97 ff ff ff ff 40 33
> c5 97 ff ff ff ff  .'......@3......
> [  119.130447] Object ffff950b36e9c518: 00 00 00 00 00 00 00 00 54 02
> c9 29 0b 95 ff ff  ........T..)....
> [  119.130447] Object ffff950b36e9c528: 00 00 00 00 00 00 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c538: 00 00 00 00 00 00 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Object ffff950b36e9c548: 00 00 00 00 00 00 00 00 00 00
> 00 00 00 00 00 00  ................
> [  119.130447] Redzone ffff950b36e9c558: cc cc cc cc cc cc cc cc
>                    ........
> [  119.130447] Padding ffff950b36e9c698: 5a 5a 5a 5a 5a 5a 5a 5a
>                    ZZZZZZZZ
> [  119.130447] CPU: 1 PID: 170 Comm: kworker/1:2 Tainted: G    B
>     4.9.0-rc8-11553-g59f68472-dirty #117
> [  119.130447] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.9.1-1.fc24 04/01/2014
> [  119.130447] Workqueue: events free_user_ns
> [  119.130447] Call Trace:
> [  119.130447]  dump_stack+0x86/0xc3
> [  119.130447]  print_trailer+0x15a/0x250
> [  119.130447]  check_object+0x160/0x280
> [  119.130447]  free_debug_processing+0x161/0x3d0
> [  119.130447]  ? retire_userns_sysctls+0x33/0x40
> [  119.130447]  __slab_free+0x1ed/0x370
> [  119.130447]  ? debug_lockdep_rcu_enabled+0x1d/0x20
> [  119.130447]  ? mark_held_locks+0x6f/0xa0
> [  119.130447]  ? kfree+0xcd/0x290
> [  119.130447]  ? retire_userns_sysctls+0x33/0x40
> [  119.130447]  ? retire_userns_sysctls+0x33/0x40
> [  119.130447]  kfree+0x20d/0x290
> [  119.130447]  retire_userns_sysctls+0x33/0x40
> [  119.130447]  free_user_ns+0x2b/0x70
> [  119.130447]  process_one_work+0x212/0x6c0
> [  119.130447]  ? process_one_work+0x197/0x6c0
> [  119.130447]  worker_thread+0x4e/0x4a0
> [  119.130447]  ? process_one_work+0x6c0/0x6c0
> [  119.130447]  kthread+0xff/0x120
> [  119.130447]  ? kthread_park+0x60/0x60
> [  119.130447]  ret_from_fork+0x2a/0x40
> [  119.213921] FIX kmalloc-512: Object at 0xffff950b36e9c358 not freed
>
>
>>
>> [   80.470890] kernel BUG at mm/vmalloc.c:463!
>> [   80.471007] invalid opcode: 0000 [#1] SMP
>> [   80.471007] Modules linked in:
>> [   80.471007] CPU: 0 PID: 14795 Comm: criu Not tainted
>> 4.9.0-rc8-next-20161209 #114
>> [   80.471007] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
>> BIOS 1.9.1-1.fc24 04/01/2014
>> [   80.471007] task: ffff8bc26c34a680 task.stack: ffff9c6a43d58000
>> [   80.471007] RIP: 0010:alloc_vmap_area+0x366/0x390
>> [   80.471007] RSP: 0018:ffff9c6a43d5bc58 EFLAGS: 00010206
>> [   80.471007] RAX: ffff8bc272ce8000 RBX: ffff8bc267b11420 RCX: 0000000000000000
>> [   80.471007] RDX: ffffffff8b222bb3 RSI: 0000000000000000 RDI: ffffffff8bc7e7e0
>> [   80.471007] RBP: ffff9c6a43d5bcb0 R08: ffffffff8bc7e7d0 R09: 0000000000000000
>> [   80.471007] R10: 0000000000000001 R11: 0000000000000000 R12: ffff9c6a40000000
>> [   80.471007] R13: ffff9c6a40000000 R14: ffffffffffffc000 R15: 0000000000003fff
>> [   80.471007] FS:  00007fac30a4f800(0000) GS:ffff8bc27fc00000(0000)
>> knlGS:0000000000000000
>> [   80.471007] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   80.471007] CR2: 00000000006fc618 CR3: 000000012ffd9000 CR4: 00000000003406f0
>> [   80.471007] DR0: 0000000000010130 DR1: 0000000000000000 DR2: 0000000000000000
>> [   80.471007] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>> [   80.471007] Call Trace:
>> [   80.471007]  __get_vm_area_node+0xb7/0x170
>> [   80.471007]  __vmalloc_node_range+0x73/0x290
>> [   80.471007]  ? _do_fork+0xf3/0x6f0
>> [   80.471007]  ? copy_process.part.31+0x12a/0x20c0
>> [   80.471007]  copy_process.part.31+0x793/0x20c0
>> [   80.471007]  ? _do_fork+0xf3/0x6f0
>> [   80.471007]  _do_fork+0xf3/0x6f0
>> [   80.471007]  ? __might_fault+0x8c/0xa0
>> [   80.471007]  ? __might_fault+0x43/0xa0
>> [   80.471007]  ? trace_hardirqs_on_caller+0xf5/0x1b0
>> [   80.471007]  SyS_clone+0x19/0x20
>> [   80.471007]  do_syscall_64+0x6c/0x1f0
>> [   80.471007]  entry_SYSCALL64_slow_path+0x25/0x25
>> [   80.471007] RIP: 0033:0x7fac2f6b6941
>> [   80.471007] RSP: 002b:00007ffdb42f3c30 EFLAGS: 00000246 ORIG_RAX:
>> 0000000000000038
>> [   80.471007] RAX: ffffffffffffffda RBX: 00007ffdb42f3c30 RCX: 00007fac2f6b6941
>> [   80.471007] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
>> [   80.471007] RBP: 00007ffdb42f3c80 R08: 00007fac30a4f800 R09: 000000000000001c
>> [   80.471007] R10: 00007fac30a4fad0 R11: 0000000000000246 R12: 0000000000000000
>> [   80.471007] R13: 0000000000000020 R14: 0000000000000000 R15: 0000000000000000
>> [   80.471007] Code: 18 97 01 e8 1d 72 5a 00 48 8b 03 4c 85 f8 75 19
>> 49 39 c5 77 16 48 8b 45 a8 48 8b 5d b0 48 3b 58 08 0f 83 5e ff ff ff
>> 0f 0b 0f 0b <0f> 0b e8 23 c7 e6 ff 48 89 3d 24 18 97 01 e9 cd fe ff ff
>> 4c 89
>> [   80.471007] RIP: alloc_vmap_area+0x366/0x390 RSP: ffff9c6a43d5bc58
>> [   80.506584] ---[ end trace 14dbfb61a09961b9 ]---
>>
>>
>> Steps to reproduce:
>> $ apt-get install gcc make protobuf-c-compiler libprotobuf-c0-dev libaio-dev \
>> libprotobuf-dev protobuf-compiler python-ipaddr libcap-dev \
>> libnl-3-dev gdb bash python-protobuf
>> $ git clone https://github.com/xemul/criu.git
>> $ cd criu
>> $ make
>> $ python test/zdtm.py run -a -p 4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
