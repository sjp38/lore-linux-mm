Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA50B8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:44:04 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id o205so28861250itc.2
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:44:04 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id p14sor14674230iob.11.2018.12.30.23.44.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:44:03 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 30 Dec 2018 23:44:03 -0800
Message-ID: <000000000000a72593057e4c934d@google.com>
Subject: BUG: unable to handle kernel NULL pointer dereference in unlink_file_vma
From: syzbot <syzbot+4cbac4707f8e5215007b@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, dwmw@amazon.co.uk, jrdr.linux@gmail.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com

Hello,

syzbot found the following crash on:

HEAD commit:    3d647e62686f Merge tag 's390-4.19-4' of git://git.kernel.o..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1316f4a5400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=88e9a8a39dc0be2d
dashboard link: https://syzkaller.appspot.com/bug?extid=4cbac4707f8e5215007b
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+4cbac4707f8e5215007b@syzkaller.appspotmail.com

RAX: 0000000000000002 RBX: 00000000ffffffff RCX: 000000000045df89
RDX: 0000000000000080 RSI: 000000c420033890 RDI: 0000000000000004
RBP: 000000c420033e90 R08: 0000000000000003 R09: 000000c420000d80
R10: 00000000ffffffff R11: 0000000000000246 R12: 0000000000000001
R13: 000000c42f90d718 R14: 0000000000000066 R15: 000000c42f90d708
BUG: unable to handle kernel NULL pointer dereference at 0000000000000068
PGD 1d85b1067 P4D 1d85b1067 PUD 1cd360067 PMD 0
Oops: 0002 [#1] PREEMPT SMP KASAN
CPU: 1 PID: 2748 Comm: syz-executor0 Not tainted 4.19.0-rc7+ #55
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__down_write arch/x86/include/asm/rwsem.h:142 [inline]
RIP: 0010:down_write+0x97/0x130 kernel/locking/rwsem.c:72
Code: a5 f9 31 d2 45 31 c9 41 b8 01 00 00 00 ff 75 08 48 8d 7b 60 31 c9 31  
f6 e8 c6 01 b1 f9 48 89 d8 48 ba 01 00 00 00 ff ff ff ff <f0> 48 0f c1 10  
85 d2 74 05 e8 3b 29 fe ff 48 8d 7d a0 5a 48 89 f8
RSP: 0000:ffff880128396ff0 EFLAGS: 00010246
RAX: 0000000000000068 RBX: 0000000000000068 RCX: 0000000000000000
RDX: ffffffff00000001 RSI: 0000000000000000 RDI: 0000000000000286
RBP: ffff880128397078 R08: 0000000000000001 R09: 0000000000000000
R10: ffff8801ce8da278 R11: 0000000000000000 R12: 1ffff10025072dff
R13: 0000000000000068 R14: dffffc0000000000 R15: 00007fca701da000
FS:  00007fca6ebd9700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000068 CR3: 00000001d88cd000 CR4: 00000000001406e0
kobject: 'syz_tun' (00000000bb2f2151): kobject_cleanup, parent            
(null)
Call Trace:
  i_mmap_lock_write include/linux/fs.h:482 [inline]
  unlink_file_vma+0x75/0xb0 mm/mmap.c:166
  free_pgtables+0x279/0x380 mm/memory.c:641
  exit_mmap+0x2cd/0x590 mm/mmap.c:3094
  __mmput kernel/fork.c:1001 [inline]
  mmput+0x247/0x610 kernel/fork.c:1022
  exit_mm kernel/exit.c:545 [inline]
  do_exit+0xe6f/0x2610 kernel/exit.c:854
  do_group_exit+0x177/0x440 kernel/exit.c:970
  get_signal+0x8b0/0x1980 kernel/signal.c:2513
  do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 24 08 48 89 01 e8 d7 2d fc ff e8 22 7a fc ff b8 02 00 00 00 48 8d 0d  
6a 60 09 01 87 01 8b 05 62 60 09 01 83 f8 01 0f 85 8a 00 <00> 00 b8 01 00  
00 00 88 05 9e 65 09 01 84 c0 74 72 b8 01 00 00 00
RSP: 002b:00007fca6ebd8cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 000000000072bf08 RCX: 0000000000457579
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 00007ffd2b23c63f R14: 00007fca6ebd99c0 R15: 0000000000000000
Modules linked in:
CR2: 0000000000000068
---[ end trace ea9ba926f44bc95e ]---
RIP: 0010:__down_write arch/x86/include/asm/rwsem.h:142 [inline]
RIP: 0010:down_write+0x97/0x130 kernel/locking/rwsem.c:72
Code: a5 f9 31 d2 45 31 c9 41 b8 01 00 00 00 ff 75 08 48 8d 7b 60 31 c9 31  
f6 e8 c6 01 b1 f9 48 89 d8 48 ba 01 00 00 00 ff ff ff ff <f0> 48 0f c1 10  
85 d2 74 05 e8 3b 29 fe ff 48 8d 7d a0 5a 48 89 f8
RSP: 0000:ffff880128396ff0 EFLAGS: 00010246
RAX: 0000000000000068 RBX: 0000000000000068 RCX: 0000000000000000
RDX: ffffffff00000001 RSI: 0000000000000000 RDI: 0000000000000286
RBP: ffff880128397078 R08: 0000000000000001 R09: 0000000000000000
R10: ffff8801ce8da278 R11: 0000000000000000 R12: 1ffff10025072dff
R13: 0000000000000068 R14: dffffc0000000000 R15: 00007fca701da000
FS:  00007fca6ebd9700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000068 CR3: 00000001d88cd000 CR4: 00000000001406e0


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
