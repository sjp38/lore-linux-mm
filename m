Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E74968E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 11:57:42 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id u73-v6so229829lja.4
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 08:57:42 -0800 (PST)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [37.9.109.47])
        by mx.google.com with ESMTPS id h9-v6si54960353ljm.21.2019.01.07.08.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 08:57:40 -0800 (PST)
Subject: Re: kernel BUG at mm/huge_memory.c:LINE!
References: <0000000000004d2e19057e8b6d78@google.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <3478bd83-6f5c-bf8e-6b62-56139110f712@yandex-team.ru>
Date: Mon, 7 Jan 2019 19:57:38 +0300
MIME-Version: 1.0
In-Reply-To: <0000000000004d2e19057e8b6d78@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, willy@infradead.org

On 03.01.2019 13:43, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    4cd1b60def51 Add linux-next specific files for 20190102
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=147760d3400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=e8ea56601353001c
> dashboard link: https://syzkaller.appspot.com/bug?extid=8e075128f7db8555391a
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com


Few more lines from "console output"

[  549.659441] page:ffffea0000e80000 count:512 mapcount:0 mapping:ffff88809a33f5b1 index:0x20000 compound_mapcount: -1
[  549.746649] anon
[  549.746665] flags: 0x1fffc000009000d(locked|uptodate|dirty|head|swapbacked)

> 
> raw: 01fffc000009000d dead000000000100 dead000000000200 ffff88809a33f5b1
> raw: 0000000000020000 0000000000000000 0000020000000000 ffff888095368000
> page dumped because: VM_BUG_ON_PAGE(compound_mapcount(head))
> page->mem_cgroup:ffff888095368000
> ------------[ cut here ]------------
> kernel BUG at mm/huge_memory.c:2683!
> invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> CPU: 0 PID: 1551 Comm: kswapd0 Not tainted 4.20.0-next-20190102 #3
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> RIP: 0010:split_huge_page_to_list+0x2161/0x2ac0 mm/huge_memory.c:2683
> Code: ff e8 33 35 b8 ff 48 8b 85 10 fc ff ff 4c 8d 70 ff e9 1e ea ff ff e8 1e 35 b8 ff 48 c7 c6 a0 a3 54 88 4c 89 ef e8 0f 15 ea ff <0f> 0b 
> 48 89 85 10 fc ff ff e8 01 35 b8 ff 48 8b 85 10 fc ff ff 4c
> RSP: 0018:ffff8880a5f36de8 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff8880a5f371d8 RCX: 0000000000000000
> RDX: ffffed1014be6d6e RSI: ffffffff81b3831e RDI: ffffed1014be6dae
> RBP: ffff8880a5f37200 R08: 0000000000000021 R09: ffffed1015cc5021
> R10: ffffed1015cc5020 R11: ffff8880ae628107 R12: ffffea0000e80080
> R13: ffffea0000e80000 R14: 00000000fffffffe R15: 01fffc000009000d
> FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020003030 CR3: 0000000219267000 CR4: 00000000001426f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   split_huge_page include/linux/huge_mm.h:148 [inline]
>   deferred_split_scan+0xa47/0x11d0 mm/huge_memory.c:2820
>   do_shrink_slab+0x4e5/0xd30 mm/vmscan.c:561
>   shrink_slab mm/vmscan.c:710 [inline]
>   shrink_slab+0x6bb/0x8c0 mm/vmscan.c:690
>   shrink_node+0x61a/0x17e0 mm/vmscan.c:2776
>   kswapd_shrink_node mm/vmscan.c:3535 [inline]
>   balance_pgdat+0xb00/0x18b0 mm/vmscan.c:3693
>   kswapd+0x839/0x1330 mm/vmscan.c:3948
>   kthread+0x357/0x430 kernel/kthread.c:246
>   ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> Modules linked in:
> kobject: 'loop1' (000000002d2ad2ad): kobject_uevent_env
> kobject: 'loop1' (000000002d2ad2ad): fill_kobj_path: path = '/devices/virtual/block/loop1'
> kobject: 'loop3' (000000003c94a079): kobject_uevent_env
> kobject: 'loop3' (000000003c94a079): fill_kobj_path: path = '/devices/virtual/block/loop3'
> kobject: 'loop5' (0000000000e89d9d): kobject_uevent_env
> kobject: 'loop5' (0000000000e89d9d): fill_kobj_path: path = '/devices/virtual/block/loop5'
> kobject: 'loop2' (000000001a685ee7): kobject_uevent_env
> kobject: 'loop2' (000000001a685ee7): fill_kobj_path: path = '/devices/virtual/block/loop2'
> kobject: 'loop3' (000000003c94a079): kobject_uevent_env
> kobject: 'loop3' (000000003c94a079): fill_kobj_path: path = '/devices/virtual/block/loop3'
> ---[ end trace a543f5c1741fca97 ]---
> kobject: 'loop0' (00000000aa59ea1f): kobject_uevent_env
> RIP: 0010:split_huge_page_to_list+0x2161/0x2ac0 mm/huge_memory.c:2683
> Code: ff e8 33 35 b8 ff 48 8b 85 10 fc ff ff 4c 8d 70 ff e9 1e ea ff ff e8 1e 35 b8 ff 48 c7 c6 a0 a3 54 88 4c 89 ef e8 0f 15 ea ff <0f> 0b 
> 48 89 85 10 fc ff ff e8 01 35 b8 ff 48 8b 85 10 fc ff ff 4c
> kobject: 'loop0' (00000000aa59ea1f): fill_kobj_path: path = '/devices/virtual/block/loop0'
> RSP: 0018:ffff8880a5f36de8 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff8880a5f371d8 RCX: 0000000000000000
> RDX: ffffed1014be6d6e RSI: ffffffff81b3831e RDI: ffffed1014be6dae
> RBP: ffff8880a5f37200 R08: 0000000000000021 R09: ffffed1015cc5021
> netlink: 'syz-executor0': attribute type 22 has an invalid length.
> R10: ffffed1015cc5020 R11: ffff8880ae628107 R12: ffffea0000e80080
> R13: ffffea0000e80000 R14: 00000000fffffffe R15: 01fffc000009000d
> FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
> kobject: 'loop1' (000000002d2ad2ad): kobject_uevent_env
> kobject: 'loop1' (000000002d2ad2ad): fill_kobj_path: path = '/devices/virtual/block/loop1'
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000004efb18 CR3: 00000000702a7000 CR4: 00000000001426e0
> kobject: 'loop5' (0000000000e89d9d): kobject_uevent_env
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> kobject: 'loop5' (0000000000e89d9d): fill_kobj_path: path = '/devices/virtual/block/loop5'
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> kobject: 'loop3' (000000003c94a079): kobject_uevent_env
> 


I've got couple of these for 4.14.
Maybe related but this happened with THP tmpfs.


<1>[220723.475439] huge_memory: total_mapcount: 63, page_count(): 576
<0>[220723.475474] page:ffffea0024ee8000 count:576 mapcount:0 mapping:ffff881813235550 index:0x0 compound_mapcount: 0
<0>[220723.475512] flags: 0x10000000004807d(locked|referenced|uptodate|dirty|lru|active|head|swapbacked)
<1>[220723.475545] raw: 010000000004807d ffff881813235550 0000000000000000 00000240ffffffff
<1>[220723.475573] raw: ffffea004c099a20 ffffea002bd9e020 0000000000000000 ffff883018044800
<1>[220723.475601] page dumped because: total_mapcount(head) > 0
<1>[220723.475621] page->mem_cgroup:ffff883018044800
<4>[220723.475644] ------------[ cut here ]------------
<2>[220723.475645] kernel BUG at mm/huge_memory.c:2652!
<4>[220723.475667] invalid opcode: 0000 [#1] SMP PTI
<4>[220723.475684] Modules linked in: xt_nat xt_limit overlay ip6table_nat nf_nat_ipv6 nf_nat veth tcp_diag inet_diag unix_diag xt_NFLOG 
nfnetlink_log nfnetlink ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 nf_log_common xt_LOG nf_conntrack_ipv6 nf_defrag_ipv6 xt_u32 ip6table_raw 
xt_conntrack ip6table_filter xt_tcpudp xt_CT nf_conntrack iptable_raw xt_multiport iptable_filter bridge ip6_tables ip_tables x_tables 
sch_fq_codel sch_hfsc netconsole configfs 8021q mrp garp stp llc intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp mgag200 coretemp 
ttm kvm_intel drm_kms_helper drm kvm fb_sys_fops sysimgblt input_leds sysfillrect syscopyarea irqbypass lpc_ich mfd_core ghash_clmulni_intel 
shpchp ioatdma wmi tcp_bbr ip6_tunnel tunnel6 mlx4_en mlx4_core devlink tcp_nv tcp_htcp raid456 async_raid6_recov async_pq async_xor
<4>[220723.475954]  xor async_memcpy async_tx raid10 igb isci dca libsas i2c_algo_bit ptp scsi_transport_sas pps_core raid6_pq libcrc32c 
raid1 raid0 multipath linear [last unloaded: ipmi_msghandler]
<4>[220723.476021] CPU: 5 PID: 529913 Comm: qpipe-updater Not tainted 4.14.80-33 #1
<4>[220723.476047] Hardware name: Aquarius Aquarius Server/X9DRW, BIOS 3.0c 10/30/2014
<4>[220723.476074] task: ffff8817b98f3900 task.stack: ffffc900311d4000
<4>[220723.476099] RIP: 0010:split_huge_page_to_list+0x7b5/0x8d0
<4>[220723.476120] RSP: 0018:ffffc900311d76a0 EFLAGS: 00010086
<4>[220723.476140] RAX: 0000000000000021 RBX: ffff881813235550 RCX: 0000000000000006
<4>[220723.476165] RDX: 0000000000000007 RSI: 0000000000000082 RDI: ffff88181fb55730
<4>[220723.476190] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000c20
<4>[220723.476216] R10: ffffc900311d7690 R11: 0000000000000001 R12: 0000000000000000
<4>[220723.476241] R13: ffffea0024ee8000 R14: ffff88187fffb000 R15: ffffea0024ee8000
<4>[220723.476267] FS:  00007fe7a69097c0(0000) GS:ffff88181fb40000(0000) knlGS:0000000000000000
<4>[220723.476296] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[220723.476317] CR2: 00007fe78c1e1000 CR3: 0000001815530005 CR4: 00000000000606e0
<4>[220723.476342] Call Trace:
<4>[220723.476358]  ? find_get_entry+0x20/0x140
<4>[220723.476377]  shmem_unused_huge_shrink+0x184/0x3f0
<4>[220723.476398]  super_cache_scan+0x184/0x190
<4>[220723.476416]  shrink_slab.part.54+0x1ec/0x430
<4>[220723.476434]  shrink_node+0x300/0x310
<4>[220723.476451]  do_try_to_free_pages+0xe3/0x350
<4>[220723.476469]  try_to_free_pages+0xe4/0x1d0
<4>[220723.476487]  __alloc_pages_slowpath+0x3a5/0xe70
<4>[220723.476507]  __alloc_pages_nodemask+0x25c/0x2a0
<4>[220723.476526]  shmem_alloc_hugepage+0xc7/0x110
<4>[220723.476545]  ? __radix_tree_create+0x168/0x1f0
<4>[220723.476563]  ? release_pages+0x2c8/0x3a0
<4>[220723.476579]  ? release_pages+0x2c8/0x3a0
<4>[220723.477420]  ? __activate_page+0x200/0x2d0
<4>[220723.478254]  ? percpu_counter_add_batch+0x52/0x70
<4>[220723.479095]  shmem_alloc_and_acct_page+0x108/0x1d0
<4>[220723.479926]  shmem_getpage_gfp+0x4ef/0xdf0
<4>[220723.480736]  shmem_write_begin+0x35/0x60
<4>[220723.481514]  generic_perform_write+0xaf/0x1b0
<4>[220723.482293]  __generic_file_write_iter+0x196/0x1e0
<4>[220723.483061]  generic_file_write_iter+0xe6/0x1f0
<4>[220723.483820]  __vfs_write+0xdc/0x150
<4>[220723.484573]  vfs_write+0xc5/0x1c0
<4>[220723.485324]  SyS_write+0x42/0x90
<4>[220723.486067]  do_syscall_64+0x67/0x120
<4>[220723.486790]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
<4>[220723.487496] RIP: 0033:0x7fe7a60d8330
<4>[220723.488175] RSP: 002b:00007ffc05104af8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
<4>[220723.488851] RAX: ffffffffffffffda RBX: 00007fe785e00000 RCX: 00007fe7a60d8330
<4>[220723.489511] RDX: 0000000011be3b28 RSI: 00007fe785e00000 RDI: 0000000000000003
<4>[220723.490156] RBP: 0000000011be3b28 R08: 00007fe7a69097c0 R09: 00007ffc05104bb7
<4>[220723.490770] R10: 00007ffc051048c0 R11: 0000000000000246 R12: 0000000107b88c00
<4>[220723.491364] R13: 00007ffc051057b8 R14: 0000000011be3b28 R15: 00000001072886b8
<4>[220723.491933] Code: 8b 54 24 08 48 c7 c7 28 54 06 82 e8 51 59 eb ff 49 8b 45 20 a8 01 0f 85 1b 01 00 00 48 c7 c6 8c 50 06 82 4c 89 ef 
e8 cb 64 fb ff <0f> 0b 48 c7 c6 60 53 06 82 4c 89 ff e8 ba 64 fb ff 0f 0b e8 23
<1>[220723.493137] RIP: split_huge_page_to_list+0x7b5/0x8d0 RSP: ffffc900311d76a0
<4>[220723.493731] ---[ end trace 74a2900540d3546c ]---
<5>[220723.494322] ---[ now 2018-12-24 07:08:37+03 ]---



> 
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
> 
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with syzbot.
