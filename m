Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCAE96B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 01:23:04 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id y142-v6so6111994itb.7
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 22:23:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id n11-v6sor3957297ita.85.2018.09.30.22.23.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Sep 2018 22:23:03 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 30 Sep 2018 22:23:03 -0700
In-Reply-To: <000000000000f7a28e057653dc6e@google.com>
Message-ID: <000000000000d2c6c3057723ffc5@google.com>
Subject: Re: possible deadlock in __do_page_fault
From: syzbot <syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, akpm@linux-foundation.org, arve@android.com, dhowells@redhat.com, dvyukov@google.com, gregkh@linuxfoundation.org, hannes@cmpxchg.org, jack@suse.cz, jlayton@kernel.org, joel@joelfernandes.org, joelaf@google.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, maco@android.com, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tkjos@android.com, tkjos@google.com

syzbot has found a reproducer for the following crash on:

HEAD commit:    17b57b1883c1 Linux 4.19-rc6
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=17920a7e400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c0af03fe452b65fb
dashboard link: https://syzkaller.appspot.com/bug?extid=a76129f18c89f3e2ddd4
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=160c0f11400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1788de81400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com

audit: type=1800 audit(1538371187.479:30): pid=5202 uid=0 auid=4294967295  
ses=4294967295 subj=_ op=collect_data cause=failed(directio)  
comm="startpar" name="rmnologin" dev="sda1" ino=2423 res=0

======================================================
WARNING: possible circular locking dependency detected
4.19.0-rc6+ #39 Not tainted
------------------------------------------------------
syz-executor559/5371 is trying to acquire lock:
00000000e34677d1 (&mm->mmap_sem){++++}, at: __do_page_fault+0xb70/0xed0  
arch/x86/mm/fault.c:1331

but task is already holding lock:
00000000b0c242ca (&sb->s_type->i_mutex_key#11){+.+.}, at: inode_lock  
include/linux/fs.h:738 [inline]
00000000b0c242ca (&sb->s_type->i_mutex_key#11){+.+.}, at:  
generic_file_write_iter+0xed/0x870 mm/filemap.c:3289

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&sb->s_type->i_mutex_key#11){+.+.}:
        down_write+0x8a/0x130 kernel/locking/rwsem.c:70
        inode_lock include/linux/fs.h:738 [inline]
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
        call_mmap include/linux/fs.h:1813 [inline]
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
        down_read+0xb0/0x1d0 kernel/locking/rwsem.c:24
        __do_page_fault+0xb70/0xed0 arch/x86/mm/fault.c:1331
        do_page_fault+0xf2/0x7e0 arch/x86/mm/fault.c:1470
        page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1161
        fault_in_pages_readable include/linux/pagemap.h:609 [inline]
        iov_iter_fault_in_readable+0x363/0x450 lib/iov_iter.c:421
        generic_perform_write+0x216/0x6a0 mm/filemap.c:3129
        __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3264
        generic_file_write_iter+0x436/0x870 mm/filemap.c:3292
        call_write_iter include/linux/fs.h:1808 [inline]
        new_sync_write fs/read_write.c:474 [inline]
        __vfs_write+0x6b8/0x9f0 fs/read_write.c:487
        vfs_write+0x1fc/0x560 fs/read_write.c:549
        ksys_write+0x101/0x260 fs/read_write.c:598
        __do_sys_write fs/read_write.c:610 [inline]
        __se_sys_write fs/read_write.c:607 [inline]
        __x64_sys_write+0x73/0xb0 fs/read_write.c:607
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
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

2 locks held by syz-executor559/5371:
  #0: 0000000012b388bb (sb_writers#5){.+.+}, at: file_start_write  
include/linux/fs.h:2759 [inline]
  #0: 0000000012b388bb (sb_writers#5){.+.+}, at: vfs_write+0x42a/0x560  
fs/read_write.c:548
  #1: 00000000b0c242ca (&sb->s_type->i_mutex_key#11){+.+.}, at: inode_lock  
include/linux/fs.h:738 [inline]
  #1: 00000000b0c242ca (&sb->s_type->i_mutex_key#11){+.+.}, at:  
generic_file_write_iter+0xed/0x870 mm/filemap.c:3289

stack backtrace:
CPU: 1 PID: 5371 Comm: syz-executor559 Not tainted 4.19.0-rc6+ #39
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
  print_circular_bug.isra.33.cold.54+0x1bd/0x27d  
kernel/locking/lockdep.c:1221
  check_prev_add kernel/locking/lockdep.c:1861 [inline]
  check_prevs_add kernel/locking/lockdep.c:1974 [inline]
  validate_chain kernel/locking/lockdep.c:2415 [inline]
  __lock_acquire+0x33e4/0x4ec0 kernel/locking/lockdep.c:3411
  lock_acquire+0x1ed/0x520 kernel/locking/lockdep.c:3900
  down_read+0xb0/0x1d0 kernel/locking/rwsem.c:24
  __do_page_fault+0xb70/0xed0 arch/x86/mm/fault.c:1331
  do_page_fault+0xf2/0x7e0 arch/x86/mm/fault.c:1470
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1161
RIP: 0010:fault_in_pages_readable include/linux/pagemap.h:609 [inline]
RIP: 0010:iov_iter_fault_in_readable+0x363/0x450 lib/iov_iter.c:421
Code: 00 31 ff 44 89 ee 88 55 98 e8 59 27 f4 fd 45 85 ed 74 c2 e9 7d fe ff  
ff e8 3a 26 f4 fd 0f 1f 00 0f ae e8 48 8b 85 28 ff ff ff <8a> 00 0f 1f 00  
31 ff 89 de 88 85 58 ff ff ff e8 29 27 f4 fd 85 db
RSP: 0018:ffff8801bf4e77d0 EFLAGS: 00010293
RAX: 000000002100053f RBX: 0000000000000000 RCX: ffffffff838a8de2
RDX: 0000000000000000 RSI: ffffffff838a8f46 RDI: 0000000000000007
RBP: ffff8801bf4e78a8 R08: ffff8801d81b24c0 R09: fffff94000da818e
R10: fffff94000da818e R11: ffffea0006d40c77 R12: 0000000000000000
R13: 0000000000001000 R14: 0000000000001000 R15: ffff8801bf4e7bc8
  generic_perform_write+0x216/0x6a0 mm/filemap.c:3129
  __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3264
  generic_file_write_iter+0x436/0x870 mm/filemap.c:3292
  call_write_iter include/linux/fs.h:1808 [inline]
  new_sync_write fs/read_write.c:474 [inline]
  __vfs_write+0x6b8/0x9f0 fs/read_write.c:487
  vfs_write+0x1fc/0x560 fs/read_write.c:549
  ksys_write+0x101/0x260 fs/read_write.c:598
  __do_sys_write fs/read_write.c:610 [inline]
  __se_sys_write fs/read_write.c:607 [inline]
  __x64_sys_write+0x73/0xb0 fs/read_write.c:607
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x446339
Code: e8 2c b3 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 2b 09 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007ff3053d5da8 EFLAGS: 00000293 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00000000006dac28 RCX: 0000000000446339
RDX: 00000000fffffda2 RSI: 0000000020000540 RDI: 0000000000000003
RBP: 00000000006dac20 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000293 R12: 00000000006dac2c
R13: dfdd4f11168a8b2b R14: 6873612f7665642f R15: 00000000006dad2c
kobject: 'regulatory.0' (000000004f5af2e3): kobject_uevent_env
kobject: 'regulatory.0' (000000004f5af2e3): fill_kobj_path: path  
= '/devices/platform/regulatory.0'
