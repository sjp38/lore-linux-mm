Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD6A6B000E
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 18:39:05 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r184-v6so5952585ith.0
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 15:39:05 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 201-v6sor3801672itj.114.2018.07.06.15.39.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 15:39:04 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 06 Jul 2018 15:39:04 -0700
Message-ID: <000000000000b9a32405705c54c2@google.com>
Subject: BUG: bad usercopy in __check_heap_object (3)
From: syzbot <syzbot+4b712dce5cbce6700f27@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

Hello,

syzbot found the following crash on:

HEAD commit:    526674536360 Add linux-next specific files for 20180706
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=12d51a2c400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
dashboard link: https://syzkaller.appspot.com/bug?extid=4b712dce5cbce6700f27
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=14b05afc400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17594968400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+4b712dce5cbce6700f27@syzkaller.appspotmail.com

IPv6: ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
IPv6: ADDRCONF(NETDEV_UP): team0: link is not ready
8021q: adding VLAN 0 to HW filter on device team0
usercopy: Kernel memory exposure attempt detected from SLAB  
object 'kmalloc-4096' (offset 2399, size 2626)!
------------[ cut here ]------------
kernel BUG at mm/usercopy.c:100!
invalid opcode: 0000 [#1] SMP KASAN
CPU: 1 PID: 4718 Comm: syz-executor688 Not tainted  
4.18.0-rc3-next-20180706+ #1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:usercopy_abort+0xbb/0xbd mm/usercopy.c:88
Code: c0 e8 37 ec b8 ff ff 75 c8 48 8b 55 c0 4d 89 f9 ff 75 d0 4d 89 e8 48  
89 d9 4c 89 e6 41 56 48 c7 c7 e0 4c f3 87 e8 37 a0 9f ff <0f> 0b e8 0c ec  
b8 ff e8 97 42 f7 ff 4c 89 e1 8b 95 14 ff ff ff 31
RSP: 0018:ffff8801d33a78b0 EFLAGS: 00010286
RAX: 000000000000006b RBX: ffffffff88c10e70 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff81634381 RDI: 0000000000000001
RBP: ffff8801d33a7908 R08: ffff8801d1e2a200 R09: ffffed003b5e4fc0
R10: ffffed003b5e4fc0 R11: ffff8801daf27e07 R12: ffffffff87f34bc0
R13: ffffffff87f34a80 R14: ffffffff87f34a40 R15: ffffffff88c0c905
FS:  00007f56a6072700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020001000 CR3: 00000001b8fdf000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  __check_heap_object+0xb5/0xb5 mm/slab.c:4445
  check_heap_object mm/usercopy.c:236 [inline]
  __check_object_size+0x4db/0x5f2 mm/usercopy.c:259
  check_object_size include/linux/thread_info.h:119 [inline]
  check_copy_size include/linux/thread_info.h:150 [inline]
  copy_to_user include/linux/uaccess.h:154 [inline]
  seq_read+0x578/0x10e0 fs/seq_file.c:211
  do_loop_readv_writev fs/read_write.c:700 [inline]
  do_iter_read+0x49e/0x650 fs/read_write.c:924
  vfs_readv+0x175/0x1c0 fs/read_write.c:986
  do_readv+0x11a/0x310 fs/read_write.c:1019
  __do_sys_readv fs/read_write.c:1106 [inline]
  __se_sys_readv fs/read_write.c:1103 [inline]
  __x64_sys_readv+0x75/0xb0 fs/read_write.c:1103
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x446c09
Code: e8 1c bc 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 5b 07 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f56a6071d18 EFLAGS: 00000246 ORIG_RAX: 0000000000000013
RAX: ffffffffffffffda RBX: 00000000006dcc5c RCX: 0000000000446c09
RDX: 0000000000000002 RSI: 00000000200021c0 RDI: 0000000000000005
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006dcc58
R13: 00007f56a6071d20 R14: 6f72746e6f632f2e R15: 0000000000000007
Modules linked in:
Dumping ftrace buffer:
    (ftrace buffer empty)
---[ end trace 532b9c3f493b2e4d ]---
RIP: 0010:usercopy_abort+0xbb/0xbd mm/usercopy.c:88
Code: c0 e8 37 ec b8 ff ff 75 c8 48 8b 55 c0 4d 89 f9 ff 75 d0 4d 89 e8 48  
89 d9 4c 89 e6 41 56 48 c7 c7 e0 4c f3 87 e8 37 a0 9f ff <0f> 0b e8 0c ec  
b8 ff e8 97 42 f7 ff 4c 89 e1 8b 95 14 ff ff ff 31
RSP: 0018:ffff8801d33a78b0 EFLAGS: 00010286
RAX: 000000000000006b RBX: ffffffff88c10e70 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff81634381 RDI: 0000000000000001
RBP: ffff8801d33a7908 R08: ffff8801d1e2a200 R09: ffffed003b5e4fc0
R10: ffffed003b5e4fc0 R11: ffff8801daf27e07 R12: ffffffff87f34bc0
R13: ffffffff87f34a80 R14: ffffffff87f34a40 R15: ffffffff88c0c905
FS:  00007f56a6072700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020001000 CR3: 00000001b8fdf000 CR4: 00000000001406e0
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
