Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2316B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 22:50:44 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id x130so2436471lff.10
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 19:50:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p82sor1458975lja.87.2017.12.07.19.50.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 19:50:41 -0800 (PST)
Message-ID: <1512705038.7843.6.camel@gmail.com>
Subject: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Fri, 08 Dec 2017 08:50:38 +0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

can anybody said what here happens?
And which info needed for fixing it?
Thanks.

[16712.376081] INFO: task tracker-store:27121 blocked for more than 120
seconds.
[16712.376088]       Not tainted 4.15.0-rc2-amd-vega+ #10
[16712.376092] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[16712.376095] tracker-store   D13400 27121   1843 0x00000000
[16712.376102] Call Trace:
[16712.376114]  ? __schedule+0x2e3/0xb90
[16712.376123]  ? wait_for_completion+0x146/0x1e0
[16712.376128]  schedule+0x2f/0x90
[16712.376132]  schedule_timeout+0x236/0x540
[16712.376143]  ? mark_held_locks+0x4e/0x80
[16712.376147]  ? _raw_spin_unlock_irq+0x29/0x40
[16712.376153]  ? wait_for_completion+0x146/0x1e0
[16712.376158]  wait_for_completion+0x16e/0x1e0
[16712.376162]  ? wake_up_q+0x70/0x70
[16712.376204]  ? xfs_buf_read_map+0x134/0x2f0 [xfs]
[16712.376234]  xfs_buf_submit_wait+0xaf/0x520 [xfs]
[16712.376263]  xfs_buf_read_map+0x134/0x2f0 [xfs]
[16712.376293]  ? xfs_trans_read_buf_map+0xc3/0x580 [xfs]
[16712.376325]  xfs_trans_read_buf_map+0xc3/0x580 [xfs]
[16712.376353]  xfs_da_read_buf+0xd3/0x120 [xfs]
[16712.376387]  xfs_dir3_block_read+0x35/0x70 [xfs]
[16712.376413]  xfs_dir2_block_lookup_int+0x4d/0x220 [xfs]
[16712.376444]  xfs_dir2_block_replace+0x4e/0x1d0 [xfs]
[16712.376467]  ? xfs_dir2_isblock+0x2f/0x90 [xfs]
[16712.376492]  xfs_dir_replace+0x10a/0x180 [xfs]
[16712.376526]  xfs_rename+0x586/0xbd0 [xfs]
[16712.376573]  xfs_vn_rename+0xd5/0x140 [xfs]
[16712.376586]  vfs_rename+0x494/0xa00
[16712.376601]  SyS_rename+0x338/0x390
[16712.376618]  entry_SYSCALL_64_fastpath+0x1f/0x96
[16712.376622] RIP: 0033:0x7f02d4a2c167
[16712.376624] RSP: 002b:00007ffd0998cb98 EFLAGS: 00000207 ORIG_RAX:
0000000000000052
[16712.376629] RAX: ffffffffffffffda RBX: 0000000000000001 RCX:
00007f02d4a2c167
[16712.376631] RDX: 0000000000000002 RSI: 0000560149d23fd0 RDI:
0000560149e737b0
[16712.376633] RBP: 000000000000000f R08: 0000560149e73710 R09:
000000000000002c
[16712.376635] R10: 0000000000058a8e R11: 0000000000000207 R12:
0000000000000000
[16712.376638] R13: 0000560149e6c360 R14: 0000560149d23fd0 R15:
0000000000000000
[16712.376828] 
               Showing all locks held in the system:
[16712.376876] 1 lock held by khungtaskd/67:
[16712.376886]  #0:  (tasklist_lock){.+.+}, at: [<00000000a615f1dc>]
debug_show_all_locks+0x37/0x190
[16712.377113] 3 locks held by kworker/u16:2/18769:
[16712.377115]  #0:  ((wq_completion)"writeback"){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[16712.377128]  #1:  ((work_completion)(&(&wb->dwork)->work)){+.+.},
at: [<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[16712.377138]  #2:  (&type->s_umount_key#63){++++}, at:
[<00000000ecbba71d>] trylock_super+0x16/0x50
[16712.377176] 8 locks held by tracker-store/27121:
[16712.377178]  #0:  (sb_writers#17){.+.+}, at: [<0000000063218e58>]
mnt_want_write+0x20/0x50
[16712.377191]  #1:  (&type->i_mutex_dir_key#7/1){+.+.}, at:
[<0000000026b21526>] lock_rename+0xcf/0xf0
[16712.377208]  #2:  (&inode->i_rwsem){++++}, at: [<00000000b63ba570>]
lock_two_nondirectories+0x6d/0x80
[16712.377219]  #3:  (&inode->i_rwsem/4){+.+.}, at:
[<00000000d44f800a>] vfs_rename+0x337/0xa00
[16712.377232]  #4:  (sb_internal){.+.+}, at: [<00000000b5b0ff39>]
xfs_trans_alloc+0xe2/0x120 [xfs]
[16712.377269]  #5:  (&xfs_dir_ilock_class){++++}, at:
[<000000007c7eac55>] xfs_rename+0x45e/0xbd0 [xfs]
[16712.377306]  #6:  (&xfs_nondir_ilock_class/2){+.+.}, at:
[<000000007c7eac55>] xfs_rename+0x45e/0xbd0 [xfs]
[16712.377343]  #7:  (&xfs_nondir_ilock_class/3){+.+.}, at:
[<000000007c7eac55>] xfs_rename+0x45e/0xbd0 [xfs]
[16712.377380] 3 locks held by TaskSchedulerFo/27216:
[16712.377382]  #0:  (sb_writers#17){.+.+}, at: [<0000000054534ce6>]
do_sys_ftruncate.constprop.17+0xda/0x110
[16712.377396]  #1:  (&sb->s_type->i_mutex_key#20){++++}, at:
[<0000000086cbd317>] do_truncate+0x66/0xc0
[16712.377408]  #2:  (&(&ip->i_mmaplock)->mr_lock){++++}, at:
[<00000000adf132fd>] xfs_ilock+0x14b/0x200 [xfs]
[16712.377443] 3 locks held by TaskSchedulerFo/27217:
[16712.377445]  #0:  (sb_writers#17){.+.+}, at: [<0000000054534ce6>]
do_sys_ftruncate.constprop.17+0xda/0x110
[16712.377457]  #1:  (&sb->s_type->i_mutex_key#20){++++}, at:
[<0000000086cbd317>] do_truncate+0x66/0xc0
[16712.377471]  #2:  (&(&ip->i_mmaplock)->mr_lock){++++}, at:
[<00000000adf132fd>] xfs_ilock+0x14b/0x200 [xfs]
[16712.377504] 1 lock held by TaskSchedulerFo/27219:
[16712.377506]  #0:  (sb_writers#17){.+.+}, at: [<0000000063218e58>]
mnt_want_write+0x20/0x50
[16712.377521] 3 locks held by TaskSchedulerFo/27287:
[16712.377523]  #0:  (sb_writers#17){.+.+}, at: [<0000000054534ce6>]
do_sys_ftruncate.constprop.17+0xda/0x110
[16712.377535]  #1:  (&sb->s_type->i_mutex_key#20){++++}, at:
[<0000000086cbd317>] do_truncate+0x66/0xc0
[16712.377547]  #2:  (&(&ip->i_mmaplock)->mr_lock){++++}, at:
[<00000000adf132fd>] xfs_ilock+0x14b/0x200 [xfs]
[16712.377581] 3 locks held by TaskSchedulerFo/27289:
[16712.377583]  #0:  (&f->f_pos_lock){+.+.}, at: [<00000000cb121025>]
__fdget_pos+0x48/0x60
[16712.377594]  #1:  (&type->i_mutex_dir_key#7){++++}, at:
[<00000000a872ed9a>] iterate_dir+0x56/0x180
[16712.377607]  #2:  (&xfs_dir_ilock_class){++++}, at:
[<000000002829e721>] xfs_ilock_data_map_shared+0x2c/0x30 [xfs]
[16712.377641] 3 locks held by TaskSchedulerFo/27292:
[16712.377642]  #0:  (sb_writers#17){.+.+}, at: [<0000000054534ce6>]
do_sys_ftruncate.constprop.17+0xda/0x110
[16712.377655]  #1:  (&inode->i_rwsem){++++}, at: [<0000000086cbd317>]
do_truncate+0x66/0xc0
[16712.377667]  #2:  (&(&ip->i_mmaplock)->mr_lock){++++}, at:
[<00000000adf132fd>] xfs_ilock+0x14b/0x200 [xfs]

[16712.377873] =============================================

[18432.706561] INFO: task htop:2690 blocked for more than 120 seconds.
[18432.706575]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18432.706581] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18432.706588] htop            D12280  2690   2565 0x00000000
[18432.706602] Call Trace:
[18432.706622]  ? __schedule+0x2e3/0xb90
[18432.706637]  ? rwsem_down_read_failed+0x147/0x190
[18432.706648]  schedule+0x2f/0x90
[18432.706654]  rwsem_down_read_failed+0x118/0x190
[18432.706662]  ? __lock_acquire+0x2c3/0x1270
[18432.706688]  ? call_rwsem_down_read_failed+0x14/0x30
[18432.706695]  call_rwsem_down_read_failed+0x14/0x30
[18432.706710]  down_read+0x97/0xa0
[18432.706719]  proc_pid_cmdline_read+0xd2/0x4a0
[18432.706731]  ? debug_check_no_obj_freed+0x160/0x248
[18432.706753]  ? __vfs_read+0x33/0x170
[18432.706759]  __vfs_read+0x33/0x170
[18432.706781]  vfs_read+0x9e/0x150
[18432.706792]  SyS_read+0x55/0xc0
[18432.706807]  entry_SYSCALL_64_fastpath+0x1f/0x96
[18432.706814] RIP: 0033:0x7fc2d8f4ae01
[18432.706819] RSP: 002b:00007fffedb1f998 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[18432.706827] RAX: ffffffffffffffda RBX: 000056139647bc10 RCX:
00007fc2d8f4ae01
[18432.706831] RDX: 0000000000001000 RSI: 00007fffedb1fa60 RDI:
0000000000000007
[18432.706835] RBP: 000056139696f483 R08: 000056139696f483 R09:
0000000000000005
[18432.706839] R10: 0000000000000000 R11: 0000000000000246 R12:
0000000000000007
[18432.706844] R13: 000056139696f3f0 R14: 00005613961bb8a0 R15:
00005613961bc5e0
[18432.707027] INFO: task Chrome_IOThread:27225 blocked for more than
120 seconds.
[18432.707034]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18432.707039] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18432.707045] Chrome_IOThread D11304 27225   3654 0x00000000
[18432.707057] Call Trace:
[18432.707070]  ? __schedule+0x2e3/0xb90
[18432.707086]  ? __lock_page+0xa9/0x180
[18432.707095]  schedule+0x2f/0x90
[18432.707102]  io_schedule+0x12/0x40
[18432.707109]  __lock_page+0xe9/0x180
[18432.707121]  ? page_cache_tree_insert+0x130/0x130
[18432.707138]  deferred_split_scan+0x2b6/0x300
[18432.707160]  shrink_slab.part.47+0x1f8/0x590
[18432.707179]  ? percpu_ref_put_many+0x84/0x100
[18432.707197]  shrink_node+0x2f4/0x300
[18432.707219]  do_try_to_free_pages+0xca/0x350
[18432.707236]  try_to_free_pages+0x140/0x350
[18432.707259]  __alloc_pages_slowpath+0x43c/0x1080
[18432.707298]  __alloc_pages_nodemask+0x3ac/0x430
[18432.707316]  alloc_pages_vma+0x7c/0x200
[18432.707331]  __handle_mm_fault+0x8a1/0x1230
[18432.707359]  handle_mm_fault+0x14c/0x310
[18432.707373]  __do_page_fault+0x28c/0x530
[18432.707450]  do_page_fault+0x32/0x270
[18432.707470]  page_fault+0x22/0x30
[18432.707478] RIP: 0033:0x7f9f336ac4ef
[18432.707482] RSP: 002b:00007f9f1533c968 EFLAGS: 00010206
[18432.707491] RAX: 00003d60824b4000 RBX: 00000000000885c8 RCX:
0000000000001040
[18432.707495] RDX: 0000000000001040 RSI: 00003d602692c400 RDI:
00003d60824b4000
[18432.707499] RBP: 00007f9f1533c9a0 R08: 0000000000000089 R09:
00003d602692d440
[18432.707503] R10: 00007f9f1533caf0 R11: 0000000000000000 R12:
00003d602c90f3c0
[18432.707507] R13: 0000000000000010 R14: 00000000000885b8 R15:
00003d60824b4000
[18432.707539] INFO: task TaskSchedulerFo:9369 blocked for more than
120 seconds.
[18432.707546]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18432.707551] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18432.707557] TaskSchedulerFo D11224  9369   3654 0x00000000
[18432.707568] Call Trace:
[18432.707581]  ? __schedule+0x2e3/0xb90
[18432.707596]  ? rwsem_down_read_failed+0x147/0x190
[18432.707605]  schedule+0x2f/0x90
[18432.707611]  rwsem_down_read_failed+0x118/0x190
[18432.707618]  ? __lock_acquire+0x2c3/0x1270
[18432.707643]  ? call_rwsem_down_read_failed+0x14/0x30
[18432.707650]  call_rwsem_down_read_failed+0x14/0x30
[18432.707665]  down_read+0x97/0xa0
[18432.707673]  SyS_madvise+0x859/0x920
[18432.707682]  ? SyS_rename+0xfc/0x390
[18432.707695]  ? trace_hardirqs_on_caller+0xed/0x180
[18432.707704]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[18432.707720]  ? entry_SYSCALL_64_fastpath+0x1f/0x96
[18432.707726]  entry_SYSCALL_64_fastpath+0x1f/0x96
[18432.707731] RIP: 0033:0x7f9f3363c4a7
[18432.707735] RSP: 002b:00007f9ebe2805c8 EFLAGS: 00000206 ORIG_RAX:
000000000000001c
[18432.707743] RAX: ffffffffffffffda RBX: 00007f9ebe2806d0 RCX:
00007f9f3363c4a7
[18432.707747] RDX: 0000000000000004 RSI: 0000000000041000 RDI:
00003d6073c5d000
[18432.707751] RBP: 00007f9ebe280600 R08: 0000000000000000 R09:
000000000000018d
[18432.707755] R10: 0000000000000000 R11: 0000000000000206 R12:
0000000000000000
[18432.707759] R13: 0000000000021796 R14: 00000000be280601 R15:
00007f9ebe2806d0
[18432.707998] INFO: task kworker/3:1:10525 blocked for more than 120
seconds.
[18432.708004]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18432.708009] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18432.708015] kworker/3:1     D13784 10525      2 0x80000000
[18432.708055] Workqueue: events async_pf_execute [kvm]
[18432.708063] Call Trace:
[18432.708075]  ? __schedule+0x2e3/0xb90
[18432.708094]  schedule+0x2f/0x90
[18432.708100]  io_schedule+0x12/0x40
[18432.708108]  __lock_page_or_retry+0x2e4/0x350
[18432.708121]  ? page_cache_tree_insert+0x130/0x130
[18432.708137]  do_swap_page+0x721/0x9f0
[18432.708149]  ? __lock_acquire+0x2c3/0x1270
[18432.708163]  __handle_mm_fault+0xa5c/0x1230
[18432.708209]  handle_mm_fault+0x14c/0x310
[18432.708222]  __get_user_pages+0x1b0/0x6e0
[18432.708244]  get_user_pages_remote+0x13a/0x200
[18432.708281]  async_pf_execute+0x96/0x280 [kvm]
[18432.708303]  process_one_work+0x25e/0x6c0
[18432.708320]  worker_thread+0x3a/0x390
[18432.708323]  ? process_one_work+0x6c0/0x6c0
[18432.708325]  kthread+0x15d/0x180
[18432.708338]  ? kthread_create_worker_on_cpu+0x70/0x70
[18432.708341]  ret_from_fork+0x24/0x30
[18432.708353] INFO: task kworker/3:2:13474 blocked for more than 120
seconds.
[18432.708355]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18432.708357] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18432.708358] kworker/3:2     D14176 13474      2 0x80000000
[18432.708369] Workqueue: events async_pf_execute [kvm]
[18432.708371] Call Trace:
[18432.708384]  ? __schedule+0x2e3/0xb90
[18432.708395]  schedule+0x2f/0x90
[18432.708396]  io_schedule+0x12/0x40
[18432.708399]  __lock_page_or_retry+0x2e4/0x350
[18432.708403]  ? page_cache_tree_insert+0x130/0x130
[18432.708407]  do_swap_page+0x721/0x9f0
[18432.708411]  ? __lock_acquire+0x2c3/0x1270
[18432.708415]  __handle_mm_fault+0xa5c/0x1230
[18432.708425]  handle_mm_fault+0x14c/0x310
[18432.708432]  __get_user_pages+0x1b0/0x6e0
[18432.708443]  get_user_pages_remote+0x13a/0x200
[18432.708457]  async_pf_execute+0x96/0x280 [kvm]
[18432.708464]  process_one_work+0x25e/0x6c0
[18432.708472]  worker_thread+0x3a/0x390
[18432.708478]  ? process_one_work+0x6c0/0x6c0
[18432.708481]  kthread+0x15d/0x180
[18432.708485]  ? kthread_create_worker_on_cpu+0x70/0x70
[18432.708491]  ret_from_fork+0x24/0x30
[18432.708507] 
               Showing all locks held in the system:
[18432.708526] 1 lock held by khungtaskd/67:
[18432.708527]  #0:  (tasklist_lock){.+.+}, at: [<00000000a615f1dc>]
debug_show_all_locks+0x37/0x190
[18432.708637] 1 lock held by htop/2690:
[18432.708638]  #0:  (&mm->mmap_sem){++++}, at: [<000000003ae69604>]
proc_pid_cmdline_read+0xd2/0x4a0
[18432.708657] 1 lock held by CPU 0/KVM/3893:
[18432.708658]  #0:  (&vcpu->mutex){+.+.}, at: [<00000000ff3fb7f4>]
vcpu_load+0x17/0x60 [kvm]
[18432.708759] 2 locks held by Chrome_IOThread/27225:
[18432.708760]  #0:  (&mm->mmap_sem){++++}, at: [<0000000012cb6189>]
__do_page_fault+0x17a/0x530
[18432.708766]  #1:  (shrinker_rwsem){++++}, at: [<0000000033d29b77>]
shrink_slab.part.47+0x5b/0x590
[18432.708773] 1 lock held by CacheThread_Blo/27264:
[18432.708774]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18432.708780] 1 lock held by Chrome_HistoryT/27286:
[18432.708781]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18432.708788] 1 lock held by TaskSchedulerFo/9369:
[18432.708788]  #0:  (&mm->mmap_sem){++++}, at: [<00000000603ee2cd>]
SyS_madvise+0x859/0x920
[18432.708794] 1 lock held by TaskSchedulerFo/12373:
[18432.708795]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18432.708802] 1 lock held by TaskSchedulerFo/13115:
[18432.708803]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18432.708809] 1 lock held by TaskSchedulerFo/13125:
[18432.708810]  #0:  (&mm->mmap_sem){++++}, at: [<000000003933f0be>]
vm_mmap_pgoff+0xa5/0x120
[18432.708816] 1 lock held by TaskSchedulerBa/13514:
[18432.708817]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18432.708977] 1 lock held by tracker-store/5038:
[18432.708978]  #0:  (&sb->s_type->i_mutex_key#20){++++}, at:
[<00000000c3f6e04c>] xfs_ilock+0x195/0x200 [xfs]
[18432.709033] 2 locks held by kworker/3:1/10525:
[18432.709034]  #0:  ((wq_completion)"events"){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18432.709040]  #1:  ((work_completion)(&work->work)){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18432.709049] 2 locks held by kworker/3:2/13474:
[18432.709050]  #0:  ((wq_completion)"events"){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18432.709056]  #1:  ((work_completion)(&work->work)){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18432.709064] 2 locks held by cc1/14068:
[18432.709065]  #0:  (&mm->mmap_sem){++++}, at: [<0000000012cb6189>]
__do_page_fault+0x17a/0x530
[18432.709070]  #1:  (shrinker_rwsem){++++}, at: [<0000000033d29b77>]
shrink_slab.part.47+0x5b/0x590

[18432.709078] =============================================


[18555.587276] INFO: task htop:2690 blocked for more than 120 seconds.
[18555.587281]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18555.587283] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18555.587285] htop            D12280  2690   2565 0x00000000
[18555.587290] Call Trace:
[18555.587298]  ? __schedule+0x2e3/0xb90
[18555.587303]  ? rwsem_down_read_failed+0x147/0x190
[18555.587307]  schedule+0x2f/0x90
[18555.587309]  rwsem_down_read_failed+0x118/0x190
[18555.587312]  ? __lock_acquire+0x2c3/0x1270
[18555.587320]  ? call_rwsem_down_read_failed+0x14/0x30
[18555.587323]  call_rwsem_down_read_failed+0x14/0x30
[18555.587328]  down_read+0x97/0xa0
[18555.587331]  proc_pid_cmdline_read+0xd2/0x4a0
[18555.587335]  ? debug_check_no_obj_freed+0x160/0x248
[18555.587343]  ? __vfs_read+0x33/0x170
[18555.587344]  __vfs_read+0x33/0x170
[18555.587351]  vfs_read+0x9e/0x150
[18555.587354]  SyS_read+0x55/0xc0
[18555.587359]  entry_SYSCALL_64_fastpath+0x1f/0x96
[18555.587372] RIP: 0033:0x7fc2d8f4ae01
[18555.587373] RSP: 002b:00007fffedb1f998 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[18555.587376] RAX: ffffffffffffffda RBX: 000056139647bc10 RCX:
00007fc2d8f4ae01
[18555.587377] RDX: 0000000000001000 RSI: 00007fffedb1fa60 RDI:
0000000000000007
[18555.587378] RBP: 000056139696f483 R08: 000056139696f483 R09:
0000000000000005
[18555.587380] R10: 0000000000000000 R11: 0000000000000246 R12:
0000000000000007
[18555.587381] R13: 000056139696f3f0 R14: 00005613961bb8a0 R15:
00005613961bc5e0
[18555.587516] INFO: task Chrome_IOThread:27225 blocked for more than
120 seconds.
[18555.587519]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18555.587521] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18555.587522] Chrome_IOThread D11304 27225   3654 0x00000000
[18555.587526] Call Trace:
[18555.587531]  ? __schedule+0x2e3/0xb90
[18555.587537]  ? __lock_page+0xa9/0x180
[18555.587539]  schedule+0x2f/0x90
[18555.587542]  io_schedule+0x12/0x40
[18555.587544]  __lock_page+0xe9/0x180
[18555.587548]  ? page_cache_tree_insert+0x130/0x130
[18555.587553]  deferred_split_scan+0x2b6/0x300
[18555.587560]  shrink_slab.part.47+0x1f8/0x590
[18555.587566]  ? percpu_ref_put_many+0x84/0x100
[18555.587572]  shrink_node+0x2f4/0x300
[18555.587579]  do_try_to_free_pages+0xca/0x350
[18555.587584]  try_to_free_pages+0x140/0x350
[18555.587592]  __alloc_pages_slowpath+0x43c/0x1080
[18555.587605]  __alloc_pages_nodemask+0x3ac/0x430
[18555.587611]  alloc_pages_vma+0x7c/0x200
[18555.587617]  __handle_mm_fault+0x8a1/0x1230
[18555.587626]  handle_mm_fault+0x14c/0x310
[18555.587631]  __do_page_fault+0x28c/0x530
[18555.587637]  do_page_fault+0x32/0x270
[18555.587641]  page_fault+0x22/0x30
[18555.587643] RIP: 0033:0x7f9f336ac4ef
[18555.587644] RSP: 002b:00007f9f1533c968 EFLAGS: 00010206
[18555.587646] RAX: 00003d60824b4000 RBX: 00000000000885c8 RCX:
0000000000001040
[18555.587648] RDX: 0000000000001040 RSI: 00003d602692c400 RDI:
00003d60824b4000
[18555.587649] RBP: 00007f9f1533c9a0 R08: 0000000000000089 R09:
00003d602692d440
[18555.587650] R10: 00007f9f1533caf0 R11: 0000000000000000 R12:
00003d602c90f3c0
[18555.587651] R13: 0000000000000010 R14: 00000000000885b8 R15:
00003d60824b4000


[18555.587666] INFO: task CacheThread_Blo:27264 blocked for more than
120 seconds.
[18555.587669]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18555.587672] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18555.587674] CacheThread_Blo D12488 27264   3654 0x00000000
[18555.587680] Call Trace:
[18555.587687]  ? __schedule+0x2e3/0xb90
[18555.587694]  ? rwsem_down_read_failed+0x147/0x190
[18555.587699]  schedule+0x2f/0x90
[18555.587702]  rwsem_down_read_failed+0x118/0x190
[18555.587713]  ? call_rwsem_down_read_failed+0x14/0x30
[18555.587715]  call_rwsem_down_read_failed+0x14/0x30
[18555.587720]  down_read+0x97/0xa0
[18555.587723]  __do_page_fault+0x493/0x530
[18555.587727]  ? trace_hardirqs_on_caller+0xed/0x180
[18555.587732]  do_page_fault+0x32/0x270
[18555.587735]  page_fault+0x22/0x30
[18555.587737] RIP: 0033:0x55c9558374c0
[18555.587738] RSP: 002b:00007f9efed7b648 EFLAGS: 00010206
[18555.587740] RAX: 0000000000000128 RBX: 0000000000000200 RCX:
00007f9efed7b658
[18555.587741] RDX: 00000000000000b0 RSI: 00000000a1010000 RDI:
00003d60252f1088
[18555.587743] RBP: 00007f9efed7b680 R08: 00007f9f1d5eb520 R09:
00000000ffff0001
[18555.587744] R10: 0000000000000000 R11: 0000000000b10000 R12:
00003d6066f02c00
[18555.587745] R13: 0000000000000000 R14: 0000000000000128 R15:
00003d60252f1088
[18555.587754] INFO: task Chrome_HistoryT:27286 blocked for more than
120 seconds.
[18555.587756]       Not tainted 4.15.0-rc2-amd-vega+ #10
[18555.587757] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[18555.587759] Chrome_HistoryT D11432 27286   3654 0x00000000
[18555.587762] Call Trace:
[18555.587766]  ? __schedule+0x2e3/0xb90
[18555.587771]  ? rwsem_down_read_failed+0x147/0x190
[18555.587774]  schedule+0x2f/0x90
[18555.587776]  rwsem_down_read_failed+0x118/0x190
[18555.587784]  ? call_rwsem_down_read_failed+0x14/0x30
[18555.587786]  call_rwsem_down_read_failed+0x14/0x30
[18555.587790]  down_read+0x97/0xa0
[18555.587792]  __do_page_fault+0x493/0x530
[18555.587797]  ? SyS_futex+0x12d/0x180
[18555.587799]  ? trace_hardirqs_on_caller+0xed/0x180
[18555.587803]  do_page_fault+0x32/0x270
[18555.587806]  page_fault+0x22/0x30
[18555.587808] RIP: 0033:0x55c95555fa7a
[18555.587809] RSP: 002b:00007f9efdb5ac70 EFLAGS: 00010202
[18555.587811] RAX: 00007f9f1d5a7498 RBX: 000000000000000a RCX:
000000000000000b
[18555.587812] RDX: 000000000000000a RSI: 0000000000000000 RDI:
00003d60258bb200
[18555.587813] RBP: 00007f9efdb5aca0 R08: 0000000000000002 R09:
00003d602c693580
[18555.587814] R10: 000000000000000d R11: 0000000000000001 R12:
000000000000000a
[18555.587816] R13: 0000000000000001 R14: 00003d60258bb200 R15:
0000000000000001
[18555.588004] 
               Showing all locks held in the system:
[18555.588014] 1 lock held by khungtaskd/67:
[18555.588016]  #0:  (tasklist_lock){.+.+}, at: [<00000000a615f1dc>]
debug_show_all_locks+0x37/0x190
[18555.588124] 1 lock held by htop/2690:
[18555.588125]  #0:  (&mm->mmap_sem){++++}, at: [<000000003ae69604>]
proc_pid_cmdline_read+0xd2/0x4a0
[18555.588162] 1 lock held by CPU 0/KVM/3893:
[18555.588163]  #0:  (&vcpu->mutex){+.+.}, at: [<00000000ff3fb7f4>]
vcpu_load+0x17/0x60 [kvm]
[18555.588278] 1 lock held by atop/15452:
[18555.588279]  #0:  (&mm->mmap_sem){++++}, at: [<000000003ae69604>]
proc_pid_cmdline_read+0xd2/0x4a0
[18555.588306] 2 locks held by Chrome_IOThread/27225:
[18555.588307]  #0:  (&mm->mmap_sem){++++}, at: [<0000000012cb6189>]
__do_page_fault+0x17a/0x530
[18555.588318]  #1:  (shrinker_rwsem){++++}, at: [<0000000033d29b77>]
shrink_slab.part.47+0x5b/0x590
[18555.588330] 1 lock held by CacheThread_Blo/27264:
[18555.588332]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18555.588340] 1 lock held by Chrome_HistoryT/27286:
[18555.588341]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18555.588348] 1 lock held by TaskSchedulerFo/9369:
[18555.588349]  #0:  (&mm->mmap_sem){++++}, at: [<00000000603ee2cd>]
SyS_madvise+0x859/0x920
[18555.588356] 1 lock held by TaskSchedulerFo/12373:
[18555.588357]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18555.588363] 1 lock held by TaskSchedulerFo/13115:
[18555.588365]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18555.588371] 1 lock held by TaskSchedulerFo/13125:
[18555.588372]  #0:  (&mm->mmap_sem){++++}, at: [<000000003933f0be>]
vm_mmap_pgoff+0xa5/0x120
[18555.588379] 1 lock held by TaskSchedulerBa/13514:
[18555.588380]  #0:  (&mm->mmap_sem){++++}, at: [<00000000aa62fc68>]
__do_page_fault+0x493/0x530
[18555.588574] 2 locks held by kworker/3:1/10525:
[18555.588575]  #0:  ((wq_completion)"events"){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18555.588582]  #1:  ((work_completion)(&work->work)){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18555.588592] 2 locks held by kworker/3:2/13474:
[18555.588593]  #0:  ((wq_completion)"events"){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18555.588599]  #1:  ((work_completion)(&work->work)){+.+.}, at:
[<000000000f8b6ef4>] process_one_work+0x1d4/0x6c0
[18555.588606] 2 locks held by cc1/14068:
[18555.588608]  #0:  (&mm->mmap_sem){++++}, at: [<0000000012cb6189>]
__do_page_fault+0x17a/0x530
[18555.588613]  #1:  (shrinker_rwsem){++++}, at: [<0000000033d29b77>]
shrink_slab.part.47+0x5b/0x590

[18555.588623] =============================================

--
Regards
Mikhail

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
