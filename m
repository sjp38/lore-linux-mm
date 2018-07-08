Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0884A6B0003
	for <linux-mm@kvack.org>; Sun,  8 Jul 2018 10:42:30 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id s63-v6so18986948qkc.7
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 07:42:30 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30097.outbound.protection.outlook.com. [40.107.3.97])
        by mx.google.com with ESMTPS id s10-v6si930878qvm.97.2018.07.08.07.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 08 Jul 2018 07:42:27 -0700 (PDT)
Subject: Re: KASAN: slab-out-of-bounds Read in find_first_bit
References: <000000000000af3c0305705c5425@google.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <b52255a2-9680-70dd-6a21-2f05bd0315b6@virtuozzo.com>
Date: Sun, 8 Jul 2018 17:42:13 +0300
MIME-Version: 1.0
In-Reply-To: <000000000000af3c0305705c5425@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+5248ff94d8e3548ee995@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, sfr@canb.auug.org.au, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

On 07.07.2018 01:39, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:A A A  526674536360 Add linux-next specific files for 20180706
> git tree:A A A A A A  linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=13e6a50c400000
> kernel config:A  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
> dashboard link: https://syzkaller.appspot.com/bug?extid=5248ff94d8e3548ee995
> compiler:A A A A A A  gcc (GCC) 8.0.1 20180413 (experimental)
> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=13a08a78400000
> C reproducer:A A  https://syzkaller.appspot.com/x/repro.c?x=17a08a78400000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+5248ff94d8e3548ee995@syzkaller.appspotmail.com
> 
> random: sshd: uninitialized urandom read (32 bytes read)
> random: sshd: uninitialized urandom read (32 bytes read)
> random: sshd: uninitialized urandom read (32 bytes read)
> IPVS: ftp: loaded support on port[0] = 21
> ==================================================================
> BUG: KASAN: slab-out-of-bounds in find_first_bit+0xf7/0x100 lib/find_bit.c:107
> Read of size 8 at addr ffff8801d7548d50 by task syz-executor441/4505
> 
> CPU: 1 PID: 4505 Comm: syz-executor441 Not tainted 4.18.0-rc3-next-20180706+ #1
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> Call Trace:
> A __dump_stack lib/dump_stack.c:77 [inline]
> A dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
> A print_address_description+0x6c/0x20b mm/kasan/report.c:256
> A kasan_report_error mm/kasan/report.c:354 [inline]
> A kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
> A __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
> A find_first_bit+0xf7/0x100 lib/find_bit.c:107
> A shrink_slab_memcg mm/vmscan.c:580 [inline]
> A shrink_slab+0x5d0/0xdb0 mm/vmscan.c:672
> A shrink_node+0x429/0x16a0 mm/vmscan.c:2736
> A shrink_zones mm/vmscan.c:2965 [inline]
> A do_try_to_free_pages+0x3e7/0x1290 mm/vmscan.c:3027
> A try_to_free_mem_cgroup_pages+0x49d/0xc90 mm/vmscan.c:3325
> A memory_high_write+0x283/0x310 mm/memcontrol.c:5597
> A cgroup_file_write+0x31f/0x840 kernel/cgroup/cgroup.c:3500
> A kernfs_fop_write+0x2ba/0x480 fs/kernfs/file.c:316
> A __vfs_write+0x117/0x9f0 fs/read_write.c:485
> A vfs_write+0x1fc/0x560 fs/read_write.c:549
> A ksys_write+0x101/0x260 fs/read_write.c:598
> A __do_sys_write fs/read_write.c:610 [inline]
> A __se_sys_write fs/read_write.c:607 [inline]
> A __x64_sys_write+0x73/0xb0 fs/read_write.c:607
> A do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> A entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x4419d9
> Code: e8 ec b5 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 7b 08 fc ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007ffcd44b9a78 EFLAGS: 00000217 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00000000004419d9
> RDX: 000000000000006b RSI: 0000000020000740 RDI: 0000000000000004
> RBP: 0000000000000000 R08: 0000000000000006 R09: 0000000000000006
> R10: 0000000000000006 R11: 0000000000000217 R12: 0000000000000000
> R13: 6c616b7a79732f2e R14: 0000000000000000 R15: 0000000000000000
> 
> Allocated by task 4504:
> A save_stack+0x43/0xd0 mm/kasan/kasan.c:448
> A set_track mm/kasan/kasan.c:460 [inline]
> A kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
> A __do_kmalloc_node mm/slab.c:3682 [inline]
> A __kmalloc_node+0x47/0x70 mm/slab.c:3689
> A kmalloc_node include/linux/slab.h:555 [inline]
> A kvmalloc_node+0x65/0xf0 mm/util.c:423
> A kvmalloc include/linux/mm.h:557 [inline]
> A kvzalloc include/linux/mm.h:565 [inline]
> A memcg_alloc_shrinker_maps mm/memcontrol.c:386 [inline]
> A mem_cgroup_css_online+0x169/0x3c0 mm/memcontrol.c:4685
> A online_css+0x10c/0x350 kernel/cgroup/cgroup.c:4768
> A css_create kernel/cgroup/cgroup.c:4839 [inline]
> A cgroup_apply_control_enable+0x777/0xe90 kernel/cgroup/cgroup.c:2987
> A cgroup_mkdir+0x88a/0x1170 kernel/cgroup/cgroup.c:5029
> A kernfs_iop_mkdir+0x159/0x1e0 fs/kernfs/dir.c:1099
> A vfs_mkdir+0x42e/0x6b0 fs/namei.c:3874
> A do_mkdirat+0x27b/0x310 fs/namei.c:3897
> A __do_sys_mkdir fs/namei.c:3913 [inline]
> A __se_sys_mkdir fs/namei.c:3911 [inline]
> A __x64_sys_mkdir+0x5c/0x80 fs/namei.c:3911
> A do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> A entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> Freed by task 2873:
> A save_stack+0x43/0xd0 mm/kasan/kasan.c:448
> A set_track mm/kasan/kasan.c:460 [inline]
> A __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
> A kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
> A __cache_free mm/slab.c:3498 [inline]
> A kfree+0xd9/0x260 mm/slab.c:3813
> A single_release+0x8f/0xb0 fs/seq_file.c:596
> A __fput+0x35d/0x930 fs/file_table.c:215
> A ____fput+0x15/0x20 fs/file_table.c:251
> A task_work_run+0x1ec/0x2a0 kernel/task_work.c:113
> A tracehook_notify_resume include/linux/tracehook.h:192 [inline]
> A exit_to_usermode_loop+0x313/0x370 arch/x86/entry/common.c:166
> A prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
> A syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
> A do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
> A entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> The buggy address belongs to the object at ffff8801d7548d40
> A which belongs to the cache kmalloc-32 of size 32
> The buggy address is located 16 bytes inside of
> A 32-byte region [ffff8801d7548d40, ffff8801d7548d60)
> The buggy address belongs to the page:
> page:ffffea00075d5200 count:1 mapcount:0 mapping:ffff8801da8001c0 index:0xffff8801d7548fc1
> flags: 0x2fffc0000000100(slab)
> raw: 02fffc0000000100 ffffea00075d5448 ffffea00075d3b08 ffff8801da8001c0
> raw: ffff8801d7548fc1 ffff8801d7548000 0000000100000039 0000000000000000
> page dumped because: kasan: bad access detected
> 
> Memory state around the buggy address:
> A ffff8801d7548c00: 00 04 fc fc fc fc fc fc 00 03 fc fc fc fc fc fc
> A ffff8801d7548c80: 00 05 fc fc fc fc fc fc 00 03 fc fc fc fc fc fc
>> ffff8801d7548d00: 00 07 fc fc fc fc fc fc 00 00 05 fc fc fc fc fc
> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  ^
> A ffff8801d7548d80: 00 00 00 fc fc fc fc fc 00 00 00 fc fc fc fc fc
> A ffff8801d7548e00: 00 00 00 fc fc fc fc fc 00 00 00 fc fc fc fc fc
> ==================================================================

Since find_first_bit() reads memory with unsigned long alignment,
we have to use it for allocation:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0ab20e2a5270..2da65d58520e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -401,7 +401,7 @@ int memcg_expand_shrinker_maps(int new_id)
 	int size, old_size, ret = 0;
 	struct mem_cgroup *memcg;
 
-	size = DIV_ROUND_UP(new_id + 1, BITS_PER_BYTE);
+	size = DIV_ROUND_UP(new_id + 1, BITS_PER_LONG) * sizeof(unsigned long);
 	old_size = memcg_shrinker_map_size;
 	if (size <= old_size)
 		return 0;
