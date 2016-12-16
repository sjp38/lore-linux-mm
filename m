Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66BBE6B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 08:14:57 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id t184so14695255qkd.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:14:57 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k127si3131130qkd.147.2016.12.16.05.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 05:14:55 -0800 (PST)
Subject: Re: crash during oom reaper
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
Date: Fri, 16 Dec 2016 14:14:17 +0100
MIME-Version: 1.0
In-Reply-To: <20161216101113.GE13940@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 12/16/2016 11:11 AM, Michal Hocko wrote:
> On Fri 16-12-16 10:43:52, Vegard Nossum wrote:
> [...]
>> I don't think it's a bug in the OOM reaper itself, but either of the
>> following two patches will fix the problem (without my understand how or
>> why):
>>
> What is the atual crash?

Annoyingly it doesn't seem to reproduce with the very latest
linus/master, so maybe it's been fixed recently after all and I missed it.

I've started a bisect to see what fixed it. Just in case, I added 4
different crashes I saw with various kernels. I think there may have
been a few others too (I remember seeing one in a page fault path), but
these were the most frequent ones.


Vegard

--

Manifestation 1:

Out of memory: Kill process 1650 (trinity-main) score 90 or sacrifice child
Killed process 1724 (trinity-c14) total-vm:37280kB, anon-rss:236kB, 
file-rss:112kB, shmem-rss:112kB
BUG: unable to handle kernel NULL pointer dereference at 00000000000001e8
IP: [<ffffffff8126b1c0>] copy_process.part.41+0x2150/0x5580
PGD c001067 PUD c000067
PMD 0
Oops: 0002 [#1] PREEMPT SMP KASAN
Dumping ftrace buffer:
    (ftrace buffer empty)
CPU: 28 PID: 1650 Comm: trinity-main Not tainted 4.9.0-rc6+ #317
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
Ubuntu-1.8.2-1ubuntu1 04/01/2014
task: ffff88000f9bc440 task.stack: ffff88000c778000
RIP: 0010:[<ffffffff8126b1c0>]  [<ffffffff8126b1c0>] 
copy_process.part.41+0x2150/0x5580
RSP: 0018:ffff88000c77fc18  EFLAGS: 00010297
RAX: 0000000000000000 RBX: ffff88000fa11c00 RCX: 0000000000000000
RDX: 0000000000000000 RSI: dffffc0000000000 RDI: ffff88000f2a33b0
RBP: ffff88000c77fdb0 R08: ffff88000c77f900 R09: 0000000000000002
R10: 00000000cb9401ca R11: 00000000c6eda739 R12: ffff88000f894d00
R13: ffff88000c7c4700 R14: ffff88000fa11c50 R15: ffff88000f2a3200
FS:  00007fb7d2a24700(0000) GS:ffff880011b00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000001e8 CR3: 000000001010d000 CR4: 00000000000406e0
Stack:
  0000000000000046 0000000001200011 ffffed0001f129ac ffff88000f894d60
  0000000000000000 0000000000000000 ffff88000f894d08 ffff88000f894da0
  ffff88000c7a8620 ffff88000f020318 ffff88000fa11c18 ffff88000f894e40
Call Trace:
  [<ffffffff81269070>] ? __cleanup_sighand+0x50/0x50
  [<ffffffff81fd552e>] ? memzero_explicit+0xe/0x10
  [<ffffffff822cb592>] ? urandom_read+0x232/0x4d0
  [<ffffffff8126e974>] _do_fork+0x1a4/0xa40
  [<ffffffff8126e7d0>] ? fork_idle+0x180/0x180
  [<ffffffff81002dba>] ? syscall_trace_enter+0x3aa/0xd40
  [<ffffffff815179ea>] ? __context_tracking_exit.part.4+0x9a/0x1e0
  [<ffffffff81002a10>] ? exit_to_usermode_loop+0x150/0x150
  [<ffffffff8201df57>] ? check_preemption_disabled+0x37/0x1e0
  [<ffffffff8126f2e7>] SyS_clone+0x37/0x50
  [<ffffffff83caea50>] ? ptregs_sys_rt_sigreturn+0x10/0x10
  [<ffffffff8100524f>] do_syscall_64+0x1af/0x4d0
  [<ffffffff83cae974>] entry_SYSCALL64_slow_path+0x25/0x25
Code: be 00 00 00 00 00 fc ff df 48 c1 e8 03 80 3c 30 00 74 08 4c 89 f7 
e8 d0 7d 3c 00 f6 43 51 08 74 11 e8 45 fa 1d 00 48 8b 44 24 20 <f0> ff 
88 e8 01 00 00 e8 34 fa 1d 00 48 8b 44 24 70 48 83 c0 60
RIP  [<ffffffff8126b1c0>] copy_process.part.41+0x2150/0x5580
  RSP <ffff88000c77fc18>
CR2: 00000000000001e8
---[ end trace b8f81ad60c106e75 ]---

Manifestation 2:

Killed process 1775 (trinity-c21) total-vm:37404kB, anon-rss:232kB, 
file-rss:420kB, shmem-rss:116kB
oom_reaper: reaped process 1775 (trinity-c21), now anon-rss:0kB, 
file-rss:0kB, shmem-rss:116kB
==================================================================
BUG: KASAN: use-after-free in p9_client_read+0x8f0/0x960 at addr 
ffff880010284d00
Read of size 8 by task trinity-main/1649
CPU: 3 PID: 1649 Comm: trinity-main Not tainted 4.9.0+ #318
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
Ubuntu-1.8.2-1ubuntu1 04/01/2014
  ffff8800068a7770 ffffffff82012301 ffff88001100f600 ffff880010284d00
  ffff880010284d60 ffff880010284d00 ffff8800068a7798 ffffffff8165872c
  ffff8800068a7828 ffff880010284d00 ffff88001100f600 ffff8800068a7818
Call Trace:
  [<ffffffff82012301>] dump_stack+0x83/0xb2
  [<ffffffff8165872c>] kasan_object_err+0x1c/0x70
  [<ffffffff816589c5>] kasan_report_error+0x1f5/0x4e0
  [<ffffffff81657d92>] ? kasan_slab_alloc+0x12/0x20
  [<ffffffff82079357>] ? check_preemption_disabled+0x37/0x1e0
  [<ffffffff81658e4e>] __asan_report_load8_noabort+0x3e/0x40
  [<ffffffff82079300>] ? assoc_array_gc+0x1310/0x1330
  [<ffffffff83b84c30>] ? p9_client_read+0x8f0/0x960
  [<ffffffff83b84c30>] p9_client_read+0x8f0/0x960
  [<ffffffff8207953c>] ? __this_cpu_preempt_check+0x1c/0x20
  [<ffffffff81685388>] ? memcg_check_events+0x28/0x460
  [<ffffffff83b84340>] ? p9_client_unlinkat+0x100/0x100
  [<ffffffff8168f147>] ? mem_cgroup_commit_charge+0xb7/0x11b0
  [<ffffffff815357f4>] ? __add_to_page_cache_locked+0x3a4/0x520
  [<ffffffff815a6bdb>] ? __inc_node_state+0x6b/0xe0
  [<ffffffff813727c7>] ? do_raw_spin_unlock+0x137/0x210
  [<ffffffff820587d0>] ? iov_iter_bvec+0x30/0x120
  [<ffffffff81b7d6ac>] v9fs_fid_readpage+0x15c/0x390
  [<ffffffff81b7d550>] ? v9fs_write_end+0x410/0x410
  [<ffffffff81571205>] ? __lru_cache_add+0x145/0x1f0
  [<ffffffff815713d5>] ? lru_cache_add+0x15/0x20
  [<ffffffff8153761b>] ? add_to_page_cache_lru+0x13b/0x280
  [<ffffffff815374e0>] ? add_to_page_cache_locked+0x40/0x40
  [<ffffffff8153786d>] ? __page_cache_alloc+0x10d/0x290
  [<ffffffff81b7d91f>] v9fs_vfs_readpage+0x3f/0x50
  [<ffffffff8153b188>] filemap_fault+0xbe8/0x1140
  [<ffffffff8153af1d>] ? filemap_fault+0x97d/0x1140
  [<ffffffff815d2eb6>] __do_fault+0x206/0x410
  [<ffffffff815d2cb0>] ? do_page_mkwrite+0x320/0x320
  [<ffffffff815ddc4c>] ? handle_mm_fault+0x1cc/0x2a60
  [<ffffffff815df76f>] handle_mm_fault+0x1cef/0x2a60
  [<ffffffff815ddbb2>] ? handle_mm_fault+0x132/0x2a60
  [<ffffffff815dda80>] ? __pmd_alloc+0x370/0x370
  [<ffffffff81302550>] ? dl_bw_of+0x80/0x80
  [<ffffffff8123b5f0>] ? __do_page_fault+0x220/0x9f0
  [<ffffffff815f1820>] ? find_vma+0x30/0x150
  [<ffffffff8123b822>] __do_page_fault+0x452/0x9f0
  [<ffffffff8123c075>] trace_do_page_fault+0x1e5/0x3a0
  [<ffffffff8122e497>] do_async_page_fault+0x27/0xa0
  [<ffffffff83d86c58>] async_page_fault+0x28/0x30
Object at ffff880010284d00, in cache kmalloc-96 size: 96
Allocated:
PID = 1649
  [<ffffffff811db686>] save_stack_trace+0x16/0x20
  [<ffffffff81657566>] save_stack+0x46/0xd0
  [<ffffffff81657d4d>] kasan_kmalloc+0xad/0xe0
  [<ffffffff81653532>] kmem_cache_alloc_trace+0x152/0x2c0
  [<ffffffff83b7cc58>] p9_fid_create+0x58/0x3a0
  [<ffffffff83b83a3d>] p9_client_walk+0xbd/0x7a0
  [<ffffffff81b7df1c>] v9fs_file_open+0x38c/0x740
  [<ffffffff816ab927>] do_dentry_open+0x5c7/0xc50
  [<ffffffff816af4c5>] vfs_open+0x105/0x220
  [<ffffffff816e07a0>] path_openat+0x8f0/0x2920
  [<ffffffff816e539e>] do_filp_open+0x18e/0x250
  [<ffffffff816c4403>] do_open_execat+0xe3/0x4c0
  [<ffffffff816cad41>] do_execveat_common.isra.36+0x671/0x1d00
  [<ffffffff816cce52>] SyS_execve+0x42/0x50
  [<ffffffff8100524f>] do_syscall_64+0x1af/0x4d0
  [<ffffffff83d85b74>] return_from_SYSCALL_64+0x0/0x6a
Freed:
PID = 1280
  [<ffffffff811db686>] save_stack_trace+0x16/0x20
  [<ffffffff81657566>] save_stack+0x46/0xd0
  [<ffffffff81657c61>] kasan_slab_free+0x71/0xb0
  [<ffffffff8165506c>] kfree+0xfc/0x230
  [<ffffffff83b7cb42>] p9_fid_destroy+0x1c2/0x280
  [<ffffffff83b838bd>] p9_client_clunk+0xdd/0x1a0
  [<ffffffff81b80694>] v9fs_dir_release+0x44/0x60
  [<ffffffff816b9d67>] __fput+0x287/0x710
  [<ffffffff816ba239>] delayed_fput+0x49/0x70
  [<ffffffff812c6600>] process_one_work+0x8b0/0x14c0
  [<ffffffff812c72fb>] worker_thread+0xeb/0x1210
  [<ffffffff812da5a4>] kthread+0x244/0x2d0
  [<ffffffff83d85d25>] ret_from_fork+0x25/0x30
Memory state around the buggy address:
  ffff880010284c00: fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc fc
  ffff880010284c80: fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc fc
 >ffff880010284d00: fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc fc
                    ^
  ffff880010284d80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880010284e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================
Disabling lock debugging due to kernel taint
==================================================================

Manifestation 3:

Out of memory: Kill process 1650 (trinity-main) score 91 or sacrifice child
Killed process 1731 (trinity-main) total-vm:37140kB, anon-rss:192kB, 
file-rss:0kB, shmem-rss:0kB
==================================================================
BUG: KASAN: use-after-free in unlink_file_vma+0xa5/0xb0 at addr 
ffff880006689db0
Read of size 8 by task trinity-main/1731
CPU: 5 PID: 1731 Comm: trinity-main Not tainted 4.9.0 #314
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
Ubuntu-1.8.2-1ubuntu1 04/01/2014
  ffff880000aaf7f8 ffffffff81fb1ab1 ffff8800110ed500 ffff880006689c00
  ffff880006689db8 ffff880000aaf998 ffff880000aaf820 ffffffff8162c5ac
  ffff880000aaf8b0 ffff880006689c00Out of memory: Kill process 1650 
(trinity-main) score 91 or sacrifice child
Killed process 1650 (trinity-main) total-vm:37140kB, anon-rss:192kB, 
file-rss:140kB, shmem-rss:18632kB
oom_reaper: reaped process 1650 (trinity-main), now anon-rss:0kB, 
file-rss:0kB, shmem-rss:18632kB
  ffff8800110ed500 ffff880000aaf8a0
Call Trace:
  [<ffffffff81fb1ab1>] dump_stack+0x83/0xb2
  [<ffffffff8162c5ac>] kasan_object_err+0x1c/0x70
  [<ffffffff8162c845>] kasan_report_error+0x1f5/0x4e0
  [<ffffffff815afd80>] ? vm_normal_page_pmd+0x240/0x240
  [<ffffffff8162ccce>] __asan_report_load8_noabort+0x3e/0x40
  [<ffffffff815c4305>] ? unlink_file_vma+0xa5/0xb0
  [<ffffffff815c4305>] unlink_file_vma+0xa5/0xb0
  [<ffffffff815ad610>] free_pgtables+0x80/0x350
  [<ffffffff815ca662>] exit_mmap+0x212/0x3d0
  [<ffffffff815ca450>] ? SyS_munmap+0xa0/0xa0
  [<ffffffff8130b2a5>] ? __might_sleep+0x95/0x1a0
  [<ffffffff812684a0>] mmput+0x90/0x1c0
  [<ffffffff8127e3dd>] do_exit+0x71d/0x2930
  [<ffffffff815adeb0>] ? vm_normal_page+0x200/0x200
  [<ffffffff8127dcc0>] ? mm_update_next_owner+0x710/0x710
  [<ffffffff815b614f>] ? handle_mm_fault+0xcbf/0x2a60
  [<ffffffff81298403>] ? __dequeue_signal+0x133/0x470
  [<ffffffff81280768>] do_group_exit+0x108/0x330
  [<ffffffff812a1d83>] get_signal+0x613/0x1390
  [<ffffffff8135e912>] ? __lock_acquire.isra.32+0xc2/0x1a30
  [<ffffffff811b1b9f>] do_signal+0x7f/0x18f0
  [<ffffffff81237354>] ? __do_page_fault+0x474/0x9f0
  [<ffffffff811b1b20>] ? setup_sigcontext+0x7d0/0x7d0
  [<ffffffff8123719c>] ? __do_page_fault+0x2bc/0x9f0
  [<ffffffff82017d27>] ? check_preemption_disabled+0x37/0x1e0
  [<ffffffff81004ee8>] ? prepare_exit_to_usermode+0xb8/0xd0
  [<ffffffff81237b94>] ? trace_do_page_fault+0x1f4/0x3a0
  [<ffffffff81004ee8>] ? prepare_exit_to_usermode+0xb8/0xd0
  [<ffffffff81229fa7>] ? do_async_page_fault+0x27/0xa0
  [<ffffffff83c993d8>] ? async_page_fault+0x28/0x30
  [<ffffffff81004ee8>] ? prepare_exit_to_usermode+0xb8/0xd0
  [<ffffffff81002975>] exit_to_usermode_loop+0xb5/0x150
  [<ffffffff81004ee8>] ? prepare_exit_to_usermode+0xb8/0xd0
  [<ffffffff8100506e>] syscall_return_slowpath+0x16e/0x1a0
  [<ffffffff83c98495>] ret_from_fork+0x15/0x30
Object at ffff880006689c00, in cache filp size: 440
Allocated:
PID = 1650
  [<ffffffff811d77d6>] save_stack_trace+0x16/0x20
  [<ffffffff8162b3e6>] save_stack+0x46/0xd0
  [<ffffffff8162bbcd>] kasan_kmalloc+0xad/0xe0
  [<ffffffff8162bc12>] kasan_slab_alloc+0x12/0x20
  [<ffffffff81627195>] kmem_cache_alloc+0xf5/0x2c0
  [<ffffffff8168aaa1>] get_empty_filp+0x91/0x3e0
  [<ffffffff816affd2>] path_openat+0xb2/0x2920
  [<ffffffff816b540e>] do_filp_open+0x18e/0x250
  [<ffffffff816946f3>] do_open_execat+0xe3/0x4c0
  [<ffffffff8169adb1>] do_execveat_common.isra.36+0x671/0x1d00
  [<ffffffff8169cec2>] SyS_execve+0x42/0x50
  [<ffffffff8100524f>] do_syscall_64+0x1af/0x4d0
  [<ffffffff83c982f4>] return_from_SYSCALL_64+0x0/0x6a
Freed:
PID = 2
  [<ffffffff811d77d6>] save_stack_trace+0x16/0x20
  [<ffffffff8162b3e6>] save_stack+0x46/0xd0
  [<ffffffff8162bae1>] kasan_slab_free+0x71/0xb0
  [<ffffffff81627ddf>] kmem_cache_free+0xaf/0x2a0
  [<ffffffff8168a1b5>] file_free_rcu+0x65/0xa0
  [<ffffffff8139bd87>] rcu_process_callbacks+0x9b7/0x10e0
  [<ffffffff83c9ae01>] __do_softirq+0x1c1/0x5ba
Memory state around the buggy address:
  ffff880006689c80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880006689d00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 >ffff880006689d80: fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc
                                      ^
  ffff880006689e00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

Manifestation 4:

Killed process 1650 (trinity-main) total-vm:37140kB, anon-rss:192kB, 
file-rss:144kB, shmem-rss:18632kB
oom_reaper: reaped process 1650 (trinity-main), now anon-rss:0kB, 
file-rss:0kB, shmem-rss:18632kB
==================================================================
BUG: KASAN: use-after-free in unlink_file_vma+0xa5/0xb0 at addr 
ffff880006b523b0
Read of size 8 by task kworker/3:1/1344
CPU: 3 PID: 1344 Comm: kworker/3:1 Not tainted 4.9.0 #314
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
Ubuntu-1.8.2-1ubuntu1 04/01/2014
Workqueue: events mmput_async_fn
  ffff88000d3bf978 ffffffff81fb1ab1 ffff8800110ed500 ffff880006b52200
  ffff880006b523b8 ffff88000d3bfb18 ffff88000d3bf9a0/home/vegard/lin 
ffffffff8162c5acux/init-trinity.
sh: line 127:  1 ffff88000d3bfa30650 Killed       ffff880006b52200 
      /sbi ffff8800110ed500n/capsh --user=n ffff88000d3bfa20obody --caps= --
  -c '/home/vegarCall Trace:
d/trinity/trinit [<ffffffff81fb1ab1>] dump_stack+0x83/0xb2
y -qq -C32 --ena [<ffffffff8162c5ac>] kasan_object_err+0x1c/0x70
ble-fds=pseudo - [<ffffffff8162c845>] kasan_report_error+0x1f5/0x4e0
cexecve,64 -V /p [<ffffffff815afd80>] ? vm_normal_page_pmd+0x240/0x240
roc/self/mem'
  [<ffffffff8162ccce>] __asan_report_load8_noabort+0x3e/0x40
  [<ffffffff815c4305>] ? unlink_file_vma+0xa5/0xb0
  [<ffffffff815c4305>] unlink_file_vma+0xa5/0xb0
  [<ffffffff815ad610>] free_pgtables+0x80/0x350
  [<ffffffff815ca662>] exit_mmap+0x212/0x3d0
  [<ffffffff815ca450>] ? SyS_munmap+0xa0/0xa0
  [<ffffffff812bf478>] ? process_one_work+0x6e8/0x13a0
+ true [<ffffffff812682d1>] mmput_async_fn+0x61/0x1a0
  [<ffffffff812bf54f>] process_one_work+0x7bf/0x13a0
  [<ffffffff812bf478>] ? process_one_work+0x6e8/0x13a0
  [<ffffffff812ebf84>] ? finish_task_switch+0x184/0x660
  [<ffffffff812bed90>] ? __cancel_work+0x220/0x220
  [<ffffffff812c021b>] worker_thread+0xeb/0x1150
  [<ffffffff83c88471>] ? __schedule+0x461/0x17c0
  [<ffffffff812d29f4>] kthread+0x244/0x2d0
  [<ffffffff812c0130>] ? process_one_work+0x13a0/0x13a0

+ true
  [<ffffffff812d27b0>] ? __kthread_create_on_node+0x380/0x380
  [<ffffffff812d27b0>] ? __kthread_create_on_node+0x380/0x380
  [<ffffffff812d27b0>] ? __kthread_create_on_node+0x380/0x380
  [<ffffffff83c984a5>] ret_from_fork+0x25/0x30
Object at ffff880006b52200, in cache filp size: 440
Allocated:
PID = 1650
  [<ffffffff811d77d6>] save_stack_trace+0x16/0x20
  [<ffffffff8162b3e6>] save_stack+0x46/0xd0
  [<ffffffff8162bbcd>] kasan_kmalloc+0xad/0xe0
  [<ffffffff8162bc12>] kasan_slab_alloc+0x12/0x20
  [<ffffffff81627195>] kmem_cache_alloc+0xf5/0x2c0
  [<ffffffff8168aaa1>] get_empty_filp+0x91/0x3e0
  [<ffffffff816affd2>] path_openat+0xb2/0x2920
  [<ffffffff816b540e>] do_filp_open+0x18e/0x250
  [<ffffffff816946f3>] do_open_execat+0xe3/0x4c0
  [<ffffffff8169adb1>] do_execveat_common.isra.36+0x671/0x1d00
  [<ffffffff8169cec2>] SyS_execve+0x42/0x50
  [<ffffffff8100524f>] do_syscall_64+0x1af/0x4d0
  [<ffffffff83c982f4>] return_from_SYSCALL_64+0x0/0x6a
Freed:
PID = 0
  [<ffffffff811d77d6>] save_stack_trace+0x16/0x20
  [<ffffffff8162b3e6>] save_stack+0x46/0xd0
  [<ffffffff8162bae1>] kasan_slab_free+0x71/0xb0
  [<ffffffff81627ddf>] kmem_cache_free+0xaf/0x2a0
  [<ffffffff8168a1b5>] file_free_rcu+0x65/0xa0
  [<ffffffff8139bd87>] rcu_process_callbacks+0x9b7/0x10e0
  [<ffffffff83c9ae01>] __do_softirq+0x1c1/0x5ba
Memory state around the buggy address:
  ffff880006b52280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880006b52300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 >ffff880006b52380: fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc
                                      ^
  ffff880006b52400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880006b52480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
