Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 849CD8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:08:07 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id o205so13522345itc.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 06:08:07 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id m130sor8110445ioa.78.2019.01.22.06.08.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 06:08:05 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 22 Jan 2019 06:08:04 -0800
In-Reply-To: <CACT4Y+b7KhMECUF01fz0+1LJOiqzJhTRHOvezN4baPNd02om0Q@mail.gmail.com>
Message-ID: <00000000000089b42c05800c8145@google.com>
Subject: Re: possible deadlock in __do_page_fault
From: syzbot <syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, akpm@linux-foundation.org, arve@android.com, dvyukov@google.com, gregkh@linuxfoundation.org, hannes@cmpxchg.org, jack@suse.cz, joel@joelfernandes.org, joelaf@google.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, maco@android.com, mgorman@techsingularity.net, penguin-kernel@i-love.sakura.ne.jp, syzkaller-bugs@googlegroups.com, tkjos@android.com, tkjos@google.com

Hello,

syzbot has tested the proposed patch but the reproducer still triggered  
crash:
possible deadlock in __do_page_fault

8021q: adding VLAN 0 to HW filter on device team0
8021q: adding VLAN 0 to HW filter on device team0
8021q: adding VLAN 0 to HW filter on device team0
8021q: adding VLAN 0 to HW filter on device team0
======================================================
WARNING: possible circular locking dependency detected
5.0.0-rc3+ #1 Not tainted
------------------------------------------------------
syz-executor2/7371 is trying to acquire lock:
00000000435ca279 (&mm->mmap_sem){++++}, at: do_user_addr_fault  
arch/x86/mm/fault.c:1426 [inline]
00000000435ca279 (&mm->mmap_sem){++++}, at: __do_page_fault+0x9c2/0xd60  
arch/x86/mm/fault.c:1541

but task is already holding lock:
00000000b64def52 (&sb->s_type->i_mutex_key#11){+.+.}, at: inode_lock  
include/linux/fs.h:757 [inline]
00000000b64def52 (&sb->s_type->i_mutex_key#11){+.+.}, at:  
generic_file_write_iter+0xe5/0x6a0 mm/filemap.c:3358

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&sb->s_type->i_mutex_key#11){+.+.}:
        down_write+0x8a/0x130 kernel/locking/rwsem.c:70
        inode_lock include/linux/fs.h:757 [inline]
        shmem_fallocate+0x168/0x1200 mm/shmem.c:2633
        ashmem_shrink_scan drivers/staging/android/ashmem.c:455 [inline]
        ashmem_shrink_scan+0x239/0x630 drivers/staging/android/ashmem.c:439
        ashmem_ioctl+0x38a/0x12c0 drivers/staging/android/ashmem.c:797
        vfs_ioctl fs/ioctl.c:46 [inline]
        file_ioctl fs/ioctl.c:509 [inline]
        do_vfs_ioctl+0x107b/0x17d0 fs/ioctl.c:696
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
        ksys_ioctl+0xab/0xd0 fs/ioctl.c:713
        __do_sys_ioctl fs/ioctl.c:720 [inline]
        __se_sys_ioctl fs/ioctl.c:718 [inline]
        __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:718
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
        do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #1 (ashmem_mutex){+.+.}:
        __mutex_lock_common kernel/locking/mutex.c:925 [inline]
        __mutex_lock+0x12f/0x1670 kernel/locking/mutex.c:1072
        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:1087
        ashmem_mmap+0x55/0x520 drivers/staging/android/ashmem.c:361
        call_mmap include/linux/fs.h:1867 [inline]
        mmap_region+0xde5/0x1ca0 mm/mmap.c:1786
        do_mmap+0xa09/0x1220 mm/mmap.c:1559
        do_mmap_pgoff include/linux/mm.h:2379 [inline]
        vm_mmap_pgoff+0x20b/0x2b0 mm/util.c:350
        ksys_mmap_pgoff+0x4f8/0x650 mm/mmap.c:1609
        __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
        __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
        __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
        do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #0 (&mm->mmap_sem){++++}:
        lock_acquire+0x1db/0x570 kernel/locking/lockdep.c:3841
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
        down_read+0x8d/0x120 kernel/locking/rwsem.c:24
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
        do_user_addr_fault arch/x86/mm/fault.c:1426 [inline]
        __do_page_fault+0x9c2/0xd60 arch/x86/mm/fault.c:1541
        do_page_fault+0xe6/0x7d8 arch/x86/mm/fault.c:1572
        page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1143
        fault_in_pages_readable include/linux/pagemap.h:611 [inline]
        iov_iter_fault_in_readable+0x377/0x450 lib/iov_iter.c:425
        generic_perform_write+0x202/0x6b0 mm/filemap.c:3198
        __generic_file_write_iter+0x25e/0x630 mm/filemap.c:3333
        generic_file_write_iter+0x34e/0x6a0 mm/filemap.c:3361
        call_write_iter include/linux/fs.h:1862 [inline]
        new_sync_write fs/read_write.c:474 [inline]
        __vfs_write+0x764/0xb40 fs/read_write.c:487
        vfs_write+0x20c/0x580 fs/read_write.c:549
        ksys_write+0x105/0x260 fs/read_write.c:598
        __do_sys_write fs/read_write.c:610 [inline]
        __se_sys_write fs/read_write.c:607 [inline]
        __x64_sys_write+0x73/0xb0 fs/read_write.c:607
        do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

other info that might help us debug this:

Chain exists of:
   &mm->mmap_sem --> ashmem_mutex --> &sb->s_type->i_mutex_key#11

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&sb->s_type->i_mutex_key#11);
                                lock(ashmem_mutex);
                                lock(&sb->s_type->i_mutex_key#11);
   lock(&mm->mmap_sem);

  *** DEADLOCK ***

2 locks held by syz-executor2/7371:
  #0: 00000000cdd032c7 (sb_writers#5){.+.+}, at: file_start_write  
include/linux/fs.h:2815 [inline]
  #0: 00000000cdd032c7 (sb_writers#5){.+.+}, at: vfs_write+0x429/0x580  
fs/read_write.c:548
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
  #1: 00000000b64def52 (&sb->s_type->i_mutex_key#11){+.+.}, at: inode_lock  
include/linux/fs.h:757 [inline]
  #1: 00000000b64def52 (&sb->s_type->i_mutex_key#11){+.+.}, at:  
generic_file_write_iter+0xe5/0x6a0 mm/filemap.c:3358

stack backtrace:
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
CPU: 1 PID: 7371 Comm: syz-executor2 Not tainted 5.0.0-rc3+ #1
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1db/0x2d0 lib/dump_stack.c:113
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
  print_circular_bug.isra.0.cold+0x1cc/0x28f kernel/locking/lockdep.c:1224
  check_prev_add kernel/locking/lockdep.c:1866 [inline]
  check_prevs_add kernel/locking/lockdep.c:1979 [inline]
  validate_chain kernel/locking/lockdep.c:2350 [inline]
  __lock_acquire+0x3014/0x4a30 kernel/locking/lockdep.c:3338
  lock_acquire+0x1db/0x570 kernel/locking/lockdep.c:3841
  down_read+0x8d/0x120 kernel/locking/rwsem.c:24
  do_user_addr_fault arch/x86/mm/fault.c:1426 [inline]
  __do_page_fault+0x9c2/0xd60 arch/x86/mm/fault.c:1541
  do_page_fault+0xe6/0x7d8 arch/x86/mm/fault.c:1572
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1143
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
RIP: 0010:fault_in_pages_readable include/linux/pagemap.h:611 [inline]
RIP: 0010:iov_iter_fault_in_readable+0x377/0x450 lib/iov_iter.c:425
Code: 89 f6 41 88 57 e0 e8 b8 2f f4 fd 45 85 f6 74 c1 e9 70 fe ff ff e8 29  
2e f4 fd 0f 1f 00 0f ae e8 44 89 f0 48 8b 8d 68 ff ff ff <8a> 11 89 c3 0f  
1f 00 41 88 57 d0 31 ff 89 de e8 85 2f f4 fd 85 db
RSP: 0018:ffff8881c52478a8 EFLAGS: 00010293
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 000000002020053f
RDX: 0000000000000000 RSI: ffffffff838db067 RDI: 0000000000000007
RBP: ffff8881c5247948 R08: ffff8881c4c18240 R09: fffff94000d13e07
R10: fffff94000d13e06 R11: ffffea000689f037 R12: 0000000000001000
R13: 0000000000001000 R14: 0000000000000000 R15: ffff8881c5247920
  generic_perform_write+0x202/0x6b0 mm/filemap.c:3198
  __generic_file_write_iter+0x25e/0x630 mm/filemap.c:3333
  generic_file_write_iter+0x34e/0x6a0 mm/filemap.c:3361
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
  call_write_iter include/linux/fs.h:1862 [inline]
  new_sync_write fs/read_write.c:474 [inline]
  __vfs_write+0x764/0xb40 fs/read_write.c:487
  vfs_write+0x20c/0x580 fs/read_write.c:549
  ksys_write+0x105/0x260 fs/read_write.c:598
  __do_sys_write fs/read_write.c:610 [inline]
  __se_sys_write fs/read_write.c:607 [inline]
  __x64_sys_write+0x73/0xb0 fs/read_write.c:607
  do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
RSP: 002b:00007f51cc66ac78 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000457579
RDX: 00000000fffffda2 RSI: 0000000020000540 RDI: 0000000000000003
RBP: 000000000072bf00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f51cc66b6d4
R13: 00000000004c554e R14: 00000000004d8e68 R15: 00000000ffffffff
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop0' (00000000a9b29aa3): kobject_uevent_env
kobject: 'loop0' (00000000a9b29aa3): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (00000000bfa624b6): kobject_uevent_env
kobject: 'loop3' (00000000bfa624b6): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (000000008a2391db): kobject_uevent_env
kobject: 'loop5' (000000008a2391db): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop2' (0000000019bfd72c): kobject_uevent_env
kobject: 'loop2' (0000000019bfd72c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000893eaf09): kobject_uevent_env
kobject: 'loop1' (00000000893eaf09): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000e9e52bda): kobject_uevent_env
kobject: 'loop4' (00000000e9e52bda): fill_kobj_path: path  
= '/devices/virtual/block/loop4'


Tested on:

commit:         48b161983ae5 Merge tag 'xarray-5.0-rc3' of git://git.infra..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=13d8ae5b400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=ae7255cd515c8fef
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
