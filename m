Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84DA86B000A
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 09:06:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id l8-v6so1861510ita.4
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 06:06:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id q207-v6sor228536iod.299.2018.08.10.06.06.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Aug 2018 06:06:03 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 10 Aug 2018 06:06:02 -0700
Message-ID: <000000000000e106310573146798@google.com>
Subject: KASAN: use-after-free Read in finish_task_switch
From: syzbot <syzbot+e62f8ba2b2af8dbd6729@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, jglisse@redhat.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, riel@surriel.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, zwisler@kernel.org

Hello,

syzbot found the following crash on:

HEAD commit:    8c8399e0a3fb Add linux-next specific files for 20180806
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=173d8672400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=1b6bc1781e49e93e
dashboard link: https://syzkaller.appspot.com/bug?extid=e62f8ba2b2af8dbd6729
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+e62f8ba2b2af8dbd6729@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: use-after-free in __fire_sched_in_preempt_notifiers  
kernel/sched/core.c:2481 [inline]
BUG: KASAN: use-after-free in fire_sched_in_preempt_notifiers  
kernel/sched/core.c:2487 [inline]
BUG: KASAN: use-after-free in finish_task_switch+0x544/0x870  
kernel/sched/core.c:2679
Read of size 8 at addr ffff880193b21d18 by task syz-executor3/4885

CPU: 0 PID: 4885 Comm: syz-executor3 Not tainted 4.18.0-rc8-next-20180806+  
#32
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_address_description+0x6c/0x20b mm/kasan/report.c:256
  kasan_report_error mm/kasan/report.c:354 [inline]
  kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
  __fire_sched_in_preempt_notifiers kernel/sched/core.c:2481 [inline]
  fire_sched_in_preempt_notifiers kernel/sched/core.c:2487 [inline]
  finish_task_switch+0x544/0x870 kernel/sched/core.c:2679
  context_switch kernel/sched/core.c:2826 [inline]
  __schedule+0x884/0x1ec0 kernel/sched/core.c:3471
  preempt_schedule_common+0x22/0x60 kernel/sched/core.c:3595
  _cond_resched+0x1d/0x30 kernel/sched/core.c:4961
  zap_pmd_range mm/memory.c:1449 [inline]
  zap_pud_range mm/memory.c:1476 [inline]
  zap_p4d_range mm/memory.c:1497 [inline]
  unmap_page_range+0x11d2/0x2100 mm/memory.c:1518
  unmap_single_vma+0x1a0/0x310 mm/memory.c:1563
  unmap_vmas+0x125/0x200 mm/memory.c:1593
  exit_mmap+0x2c2/0x590 mm/mmap.c:3093
  __mmput kernel/fork.c:1003 [inline]
  mmput+0x265/0x620 kernel/fork.c:1024
  exit_mm kernel/exit.c:544 [inline]
  do_exit+0xec6/0x2760 kernel/exit.c:856
  do_group_exit+0x177/0x440 kernel/exit.c:972
  get_signal+0x88e/0x1970 kernel/signal.c:2467
  do_signal+0x9c/0x21c0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x456cb9
Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f24f212ecf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 00000000009300a8 RCX: 0000000000456cb9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000009300a8
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000009300ac
R13: 00007ffe23b48b7f R14: 00007f24f212f9c0 R15: 0000000000000000

Allocated by task 4885:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
  kmem_cache_alloc+0x12e/0x760 mm/slab.c:3554
  kmem_cache_zalloc include/linux/slab.h:697 [inline]
  vmx_create_vcpu+0xcf/0x2980 arch/x86/kvm/vmx.c:10656
  kvm_arch_vcpu_create+0xe5/0x220 arch/x86/kvm/x86.c:8398
  kvm_vm_ioctl_create_vcpu arch/x86/kvm/../../../virt/kvm/kvm_main.c:2476  
[inline]
  kvm_vm_ioctl+0x488/0x1d80 arch/x86/kvm/../../../virt/kvm/kvm_main.c:2977
  vfs_ioctl fs/ioctl.c:46 [inline]
  file_ioctl fs/ioctl.c:501 [inline]
  do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
  __do_sys_ioctl fs/ioctl.c:709 [inline]
  __se_sys_ioctl fs/ioctl.c:707 [inline]
  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 4884:
  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
  set_track mm/kasan/kasan.c:460 [inline]
  __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
  __cache_free mm/slab.c:3498 [inline]
  kmem_cache_free+0x86/0x2d0 mm/slab.c:3756
  vmx_free_vcpu+0x26b/0x300 arch/x86/kvm/vmx.c:10650
  kvm_arch_vcpu_free arch/x86/kvm/x86.c:8384 [inline]
  kvm_free_vcpus arch/x86/kvm/x86.c:8833 [inline]
  kvm_arch_destroy_vm+0x365/0x7c0 arch/x86/kvm/x86.c:8930
  kvm_destroy_vm arch/x86/kvm/../../../virt/kvm/kvm_main.c:752 [inline]
  kvm_put_kvm+0x73f/0x1060 arch/x86/kvm/../../../virt/kvm/kvm_main.c:773
  kvm_vcpu_release+0x7b/0xa0 arch/x86/kvm/../../../virt/kvm/kvm_main.c:2407
  __fput+0x376/0x8a0 fs/file_table.c:279
  ____fput+0x15/0x20 fs/file_table.c:312
  task_work_run+0x1e8/0x2a0 kernel/task_work.c:113
  tracehook_notify_resume include/linux/tracehook.h:193 [inline]
  exit_to_usermode_loop+0x318/0x380 arch/x86/entry/common.c:166
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff880193b21d00
  which belongs to the cache kvm_vcpu of size 23808
The buggy address is located 24 bytes inside of
  23808-byte region [ffff880193b21d00, ffff880193b27a00)
The buggy address belongs to the page:
page:ffffea00064ec800 count:1 mapcount:0 mapping:ffff8801d4c35dc0 index:0x0  
compound_mapcount: 0
flags: 0x2fffc0000008100(slab|head)
raw: 02fffc0000008100 ffffea000657de08 ffff8801d4c29648 ffff8801d4c35dc0
raw: 0000000000000000 ffff880193b21d00 0000000100000001 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff880193b21c00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880193b21c80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ffff880193b21d00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                             ^
  ffff880193b21d80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880193b21e00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
