Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE3668E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 17:04:07 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id o4-v6so14636404iob.12
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 14:04:07 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id o7-v6sor15190943iom.167.2018.09.20.14.04.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 14:04:05 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 20 Sep 2018 14:04:05 -0700
Message-ID: <000000000000f7a28e057653dc6e@google.com>
Subject: possible deadlock in __do_page_fault
From: syzbot <syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, jack@suse.cz, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com

Hello,

syzbot found the following crash on:

HEAD commit:    a0cb0cabe4bb Add linux-next specific files for 20180920
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=15139721400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=786006c5dafbadf6
dashboard link: https://syzkaller.appspot.com/bug?extid=a76129f18c89f3e2ddd4
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com


======================================================
WARNING: possible circular locking dependency detected
4.19.0-rc4-next-20180920+ #76 Not tainted
------------------------------------------------------
syz-executor3/21327 is trying to acquire lock:
000000009bc5286f (&mm->mmap_sem){++++}, at: __do_page_fault+0xb61/0xec0  
arch/x86/mm/fault.c:1333

but task is already holding lock:
00000000a2c51c08 (&sb->s_type->i_mutex_key#10){+.+.}, at: inode_lock  
include/linux/fs.h:745 [inline]
00000000a2c51c08 (&sb->s_type->i_mutex_key#10){+.+.}, at:  
generic_file_write_iter+0xed/0x870 mm/filemap.c:3304

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&sb->s_type->i_mutex_key#10){+.+.}:
        down_write+0x8a/0x130 kernel/locking/rwsem.c:70
        inode_lock include/linux/fs.h:745 [inline]
        shmem_fallocate+0x18b/0x12c0 mm/shmem.c:2651
        ashmem_shrink_scan+0x238/0x660 drivers/staging/android/ashmem.c:455
        ashmem_ioctl+0x3ae/0x13a0 drivers/staging/android/ashmem.c:797
        vfs_ioctl fs/ioctl.c:46 [inline]
        file_ioctl fs/ioctl.c:501 [inline]
        do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
        ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
        __do_sys_ioctl fs/ioctl.c:709 [inline]
        __se_sys_ioctl fs/ioctl.c:707 [inline]
        __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #1 (ashmem_mutex){+.+.}:
        __mutex_lock_common kernel/locking/mutex.c:925 [inline]
        __mutex_lock+0x166/0x1700 kernel/locking/mutex.c:1072
        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:1087
        ashmem_mmap+0x55/0x520 drivers/staging/android/ashmem.c:361
        call_mmap include/linux/fs.h:1830 [inline]
        mmap_region+0xe82/0x1cd0 mm/mmap.c:1762
        do_mmap+0xa10/0x1220 mm/mmap.c:1535
        do_mmap_pgoff include/linux/mm.h:2298 [inline]
        vm_mmap_pgoff+0x213/0x2c0 mm/util.c:357
        ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1585
        __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
        __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
        __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #0 (&mm->mmap_sem){++++}:
        lock_acquire+0x1ed/0x520 kernel/locking/lockdep.c:3900
        down_read+0x8d/0x120 kernel/locking/rwsem.c:24
        __do_page_fault+0xb61/0xec0 arch/x86/mm/fault.c:1333
        do_page_fault+0xed/0x7d1 arch/x86/mm/fault.c:1472
        page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1139
        fault_in_pages_readable include/linux/pagemap.h:601 [inline]
        iov_iter_fault_in_readable+0x1b4/0x450 lib/iov_iter.c:421
        generic_perform_write+0x216/0x6a0 mm/filemap.c:3144
        __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3279
        generic_file_write_iter+0x436/0x870 mm/filemap.c:3307
        call_write_iter include/linux/fs.h:1825 [inline]
        do_iter_readv_writev+0x8b0/0xa80 fs/read_write.c:680
        do_iter_write+0x185/0x5f0 fs/read_write.c:959
        vfs_writev+0x1f1/0x360 fs/read_write.c:1004
        do_pwritev+0x1cc/0x280 fs/read_write.c:1093
        __do_sys_pwritev fs/read_write.c:1140 [inline]
        __se_sys_pwritev fs/read_write.c:1135 [inline]
        __x64_sys_pwritev+0x9a/0xf0 fs/read_write.c:1135
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

other info that might help us debug this:

Chain exists of:
   &mm->mmap_sem --> ashmem_mutex --> &sb->s_type->i_mutex_key#10

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&sb->s_type->i_mutex_key#10);
                                lock(ashmem_mutex);
                                lock(&sb->s_type->i_mutex_key#10);
   lock(&mm->mmap_sem);

  *** DEADLOCK ***

2 locks held by syz-executor3/21327:
  #0: 000000003de4eab1 (sb_writers#3){.+.+}, at: file_start_write  
include/linux/fs.h:2784 [inline]
  #0: 000000003de4eab1 (sb_writers#3){.+.+}, at: vfs_writev+0x2bd/0x360  
fs/read_write.c:1003
  #1: 00000000a2c51c08 (&sb->s_type->i_mutex_key#10){+.+.}, at: inode_lock  
include/linux/fs.h:745 [inline]
  #1: 00000000a2c51c08 (&sb->s_type->i_mutex_key#10){+.+.}, at:  
generic_file_write_iter+0xed/0x870 mm/filemap.c:3304

stack backtrace:
CPU: 1 PID: 21327 Comm: syz-executor3 Not tainted 4.19.0-rc4-next-20180920+  
#76
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1d3/0x2c4 lib/dump_stack.c:113
  print_circular_bug.isra.33.cold.54+0x1bd/0x27d  
kernel/locking/lockdep.c:1221
  check_prev_add kernel/locking/lockdep.c:1861 [inline]
  check_prevs_add kernel/locking/lockdep.c:1974 [inline]
  validate_chain kernel/locking/lockdep.c:2415 [inline]
  __lock_acquire+0x33e4/0x4ec0 kernel/locking/lockdep.c:3411
  lock_acquire+0x1ed/0x520 kernel/locking/lockdep.c:3900
  down_read+0x8d/0x120 kernel/locking/rwsem.c:24
  __do_page_fault+0xb61/0xec0 arch/x86/mm/fault.c:1333
  do_page_fault+0xed/0x7d1 arch/x86/mm/fault.c:1472
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1139
RIP: 0010:fault_in_pages_readable include/linux/pagemap.h:601 [inline]
RIP: 0010:iov_iter_fault_in_readable+0x1b4/0x450 lib/iov_iter.c:421
Code: fd 49 39 dc 76 17 eb 3c e8 e9 a0 ef fd 49 81 c4 00 10 00 00 4c 39 a5  
28 ff ff ff 72 2e e8 d4 a0 ef fd 0f 1f 00 0f ae e8 31 db <41> 8a 04 24 0f  
1f 00 31 ff 89 de 88 85 58 ff ff ff e8 c6 a1 ef fd
RSP: 0018:ffff88018dfe7650 EFLAGS: 00010246
RAX: 0000000000040000 RBX: 0000000000000000 RCX: ffffc90005662000
RDX: 00000000000001c2 RSI: ffffffff838daf1c RDI: 0000000000000005
RBP: ffff88018dfe7728 R08: ffff880198ad2240 R09: ffffed00319dc039
R10: ffffed00319dc039 R11: ffff88018cee01cb R12: 0000000020012000
R13: 0000000000000001 R14: 0000000000000001 R15: ffff88018dfe7c50
  generic_perform_write+0x216/0x6a0 mm/filemap.c:3144
  __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3279
  generic_file_write_iter+0x436/0x870 mm/filemap.c:3307
  call_write_iter include/linux/fs.h:1825 [inline]
  do_iter_readv_writev+0x8b0/0xa80 fs/read_write.c:680
  do_iter_write+0x185/0x5f0 fs/read_write.c:959
  vfs_writev+0x1f1/0x360 fs/read_write.c:1004
  do_pwritev+0x1cc/0x280 fs/read_write.c:1093
  __do_sys_pwritev fs/read_write.c:1140 [inline]
  __se_sys_pwritev fs/read_write.c:1135 [inline]
  __x64_sys_pwritev+0x9a/0xf0 fs/read_write.c:1135
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457679
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f96ef162c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000128
RAX: ffffffffffffffda RBX: 00007f96ef1636d4 RCX: 0000000000457679
RDX: 0000000000000001 RSI: 0000000020000000 RDI: 0000000000000004
RBP: 000000000072bf00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004d4a88 R14: 00000000004c31d4 R15: 0000000000000000
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
FAULT_FLAG_ALLOW_RETRY missing 30
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
CPU: 1 PID: 21327 Comm: syz-executor3 Not tainted 4.19.0-rc4-next-20180920+  
#76
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1d3/0x2c4 lib/dump_stack.c:113
  handle_userfault.cold.33+0x47/0x62 fs/userfaultfd.c:432
  do_anonymous_page mm/memory.c:2915 [inline]
  handle_pte_fault mm/memory.c:3732 [inline]
  __handle_mm_fault+0x45ed/0x53e0 mm/memory.c:3858
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3895
  __do_page_fault+0x673/0xec0 arch/x86/mm/fault.c:1397
  do_page_fault+0xed/0x7d1 arch/x86/mm/fault.c:1472
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1139
RIP: 0010:fault_in_pages_readable include/linux/pagemap.h:601 [inline]
RIP: 0010:iov_iter_fault_in_readable+0x1b4/0x450 lib/iov_iter.c:421
Code: fd 49 39 dc 76 17 eb 3c e8 e9 a0 ef fd 49 81 c4 00 10 00 00 4c 39 a5  
28 ff ff ff 72 2e e8 d4 a0 ef fd 0f 1f 00 0f ae e8 31 db <41> 8a 04 24 0f  
1f 00 31 ff 89 de 88 85 58 ff ff ff e8 c6 a1 ef fd
RSP: 0018:ffff88018dfe7650 EFLAGS: 00010246
RAX: 0000000000040000 RBX: 0000000000000000 RCX: ffffc90005662000
RDX: 00000000000001c2 RSI: ffffffff838daf1c RDI: 0000000000000005
RBP: ffff88018dfe7728 R08: ffff880198ad2240 R09: ffffed00319dc039
R10: ffffed00319dc039 R11: ffff88018cee01cb R12: 0000000020012000
R13: 0000000000000001 R14: 0000000000000001 R15: ffff88018dfe7c50
  generic_perform_write+0x216/0x6a0 mm/filemap.c:3144
  __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3279
  generic_file_write_iter+0x436/0x870 mm/filemap.c:3307
  call_write_iter include/linux/fs.h:1825 [inline]
  do_iter_readv_writev+0x8b0/0xa80 fs/read_write.c:680
  do_iter_write+0x185/0x5f0 fs/read_write.c:959
  vfs_writev+0x1f1/0x360 fs/read_write.c:1004
  do_pwritev+0x1cc/0x280 fs/read_write.c:1093
  __do_sys_pwritev fs/read_write.c:1140 [inline]
  __se_sys_pwritev fs/read_write.c:1135 [inline]
  __x64_sys_pwritev+0x9a/0xf0 fs/read_write.c:1135
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457679
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f96ef162c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000128
RAX: ffffffffffffffda RBX: 00007f96ef1636d4 RCX: 0000000000457679
RDX: 0000000000000001 RSI: 0000000020000000 RDI: 0000000000000004
RBP: 000000000072bf00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004d4a88 R14: 00000000004c31d4 R15: 0000000000000000
kobject: 'loop4' (000000004119f3b1): kobject_uevent_env
kobject: 'loop4' (000000004119f3b1): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop4' (000000004119f3b1): kobject_uevent_env
kobject: 'loop4' (000000004119f3b1): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (000000004119f3b1): kobject_uevent_env
kobject: 'loop4' (000000004119f3b1): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (000000004119f3b1): kobject_uevent_env
kobject: 'loop4' (000000004119f3b1): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (000000004119f3b1): kobject_uevent_env
kobject: 'loop4' (000000004119f3b1): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop4' (000000004119f3b1): kobject_uevent_env
kobject: 'loop4' (000000004119f3b1): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
audit: type=1326 audit(2000000012.020:46): auid=4294967295 uid=0 gid=0  
ses=4294967295 subj==unconfined pid=21534 comm="syz-executor0"  
exe="/root/syz-executor0" sig=31 arch=c000003e syscall=202 compat=0  
ip=0x457679 code=0x0
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
audit: type=1326 audit(2000000012.950:47): auid=4294967295 uid=0 gid=0  
ses=4294967295 subj==unconfined pid=21566 comm="syz-executor0"  
exe="/root/syz-executor0" sig=31 arch=c000003e syscall=202 compat=0  
ip=0x457679 code=0x0
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop2' (00000000dc629c38): kobject_uevent_env
kobject: 'loop2' (00000000dc629c38): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000aff594d4): kobject_uevent_env
kobject: 'loop3' (00000000aff594d4): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop4' (000000004119f3b1): kobject_uevent_env
kobject: 'loop4' (000000004119f3b1): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
audit: type=1326 audit(2000000013.460:48): auid=4294967295 uid=0 gid=0  
ses=4294967295 subj==unconfined pid=21585 comm="syz-executor4"  
exe="/root/syz-executor4" sig=31 arch=c000003e syscall=202 compat=0  
ip=0x457679 code=0x0
audit: type=1326 audit(2000000013.510:49): auid=4294967295 uid=0 gid=0  
ses=4294967295 subj==unconfined pid=21588 comm="syz-executor2"  
exe="/root/syz-executor2" sig=31 arch=c000003e syscall=202 compat=0  
ip=0x457679 code=0x0
kobject: 'loop1' (00000000980d23a1): kobject_uevent_env
kobject: 'loop1' (00000000980d23a1): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000ee0adfaf): kobject_uevent_env
kobject: 'loop0' (00000000ee0adfaf): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
audit: type=1326 audit(2000000013.800:50): auid=4294967295 uid=0 gid=0  
ses=4294967295 subj==unconfined pid=21601 comm="syz-executor0"  
exe="/root/syz-executor0" sig=31 arch=c000003e syscall=202 compat=0  
ip=0x457679 code=0x0
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop5' (00000000699d1086): kobject_uevent_env
kobject: 'loop5' (00000000699d1086): fill_kobj_path: path  
= '/devices/virtual/block/loop5'


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
