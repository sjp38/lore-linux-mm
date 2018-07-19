Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFD986B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:27:27 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u130-v6so3447403pgc.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:27:27 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10112.outbound.protection.outlook.com. [40.107.1.112])
        by mx.google.com with ESMTPS id u184-v6si5109801pgd.31.2018.07.19.03.27.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 03:27:26 -0700 (PDT)
Subject: Re: KASAN: use-after-free Read in shrink_slab
References: <000000000000f0319c05706389e0@google.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <b7cf35c5-6be4-489e-7734-e364522ec96e@virtuozzo.com>
Date: Thu, 19 Jul 2018 13:27:13 +0300
MIME-Version: 1.0
In-Reply-To: <000000000000f0319c05706389e0@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+6a3cf57dddcf4e4ea443@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, sfr@canb.auug.org.au, shakeelb@google.com, syzkaller-bugs@googlegroups.com, willy@infradead.org, ying.huang@intel.com

On 07.07.2018 10:15, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:A A A  526674536360 Add linux-next specific files for 20180706
> git tree:A A A A A A  linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=1703690c400000
> kernel config:A  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
> dashboard link: https://syzkaller.appspot.com/bug?extid=6a3cf57dddcf4e4ea443
> compiler:A A A A A A  gcc (GCC) 8.0.1 20180413 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+6a3cf57dddcf4e4ea443@syzkaller.appspotmail.com
> 
> ==================================================================
> BUG: KASAN: use-after-free in shrink_slab_memcg mm/vmscan.c:593 [inline]
> BUG: KASAN: use-after-free in shrink_slab+0xd22/0xdb0 mm/vmscan.c:672
> Read of size 8 at addr ffff8801cc325210 by task syz-executor4/10315
> 
> CPU: 1 PID: 10315 Comm: syz-executor4 Not tainted 4.18.0-rc3-next-20180706+ #1
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> Call Trace:
> A __dump_stack lib/dump_stack.c:77 [inline]
> A dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
> A print_address_description+0x6c/0x20b mm/kasan/report.c:256
> A kasan_report_error mm/kasan/report.c:354 [inline]
> A kasan_report.cold.7+0x242/0x30d mm/kasan/report.c:412
> A __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
> A shrink_slab_memcg mm/vmscan.c:593 [inline]
> A shrink_slab+0xd22/0xdb0 mm/vmscan.c:672
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
> RIP: 0033:0x455ba9
> Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007fbb1ad41c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 00007fbb1ad426d4 RCX: 0000000000455ba9
> RDX: 000000000000006b RSI: 0000000020000740 RDI: 0000000000000015
> RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
> R13: 00000000004c28ce R14: 00000000004d4238 R15: 0000000000000000
> 
> Allocated by task 15966:
> A save_stack+0x43/0xd0 mm/kasan/kasan.c:448
> A set_track mm/kasan/kasan.c:460 [inline]
> A kasan_kmalloc+0xc4/0xe0 mm/kasan/kasan.c:553
> A kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
> A kmem_cache_alloc+0x12e/0x760 mm/slab.c:3554
> A getname_flags+0xd0/0x5a0 fs/namei.c:140
> A user_path_at_empty+0x2d/0x50 fs/namei.c:2625
> A user_path_at include/linux/namei.h:57 [inline]
> A vfs_statx+0x129/0x210 fs/stat.c:185
> A vfs_stat include/linux/fs.h:3143 [inline]
> A __do_sys_newstat+0x8f/0x110 fs/stat.c:337
> A __se_sys_newstat fs/stat.c:333 [inline]
> A __x64_sys_newstat+0x54/0x80 fs/stat.c:333
> A do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> A entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> Freed by task 15966:
> A save_stack+0x43/0xd0 mm/kasan/kasan.c:448
> A set_track mm/kasan/kasan.c:460 [inline]
> A __kasan_slab_free+0x11a/0x170 mm/kasan/kasan.c:521
> A kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
> A __cache_free mm/slab.c:3498 [inline]
> A kmem_cache_free+0x86/0x2d0 mm/slab.c:3756
> A putname+0xf2/0x130 fs/namei.c:261
> A filename_lookup+0x397/0x510 fs/namei.c:2371
> A user_path_at_empty+0x40/0x50 fs/namei.c:2625
> A user_path_at include/linux/namei.h:57 [inline]
> A vfs_statx+0x129/0x210 fs/stat.c:185
> A vfs_stat include/linux/fs.h:3143 [inline]
> A __do_sys_newstat+0x8f/0x110 fs/stat.c:337
> A __se_sys_newstat fs/stat.c:333 [inline]
> A __x64_sys_newstat+0x54/0x80 fs/stat.c:333
> A do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> A entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> The buggy address belongs to the object at ffff8801cc324e00
> A which belongs to the cache names_cache of size 4096
> The buggy address is located 1040 bytes inside of
> A 4096-byte region [ffff8801cc324e00, ffff8801cc325e00)
> The buggy address belongs to the page:
> page:ffffea000730c900 count:1 mapcount:0 mapping:ffff8801da987dc0 index:0x0 compound_mapcount: 0
> flags: 0x2fffc0000008100(slab|head)
> raw: 02fffc0000008100 ffffea0006609a08 ffffea0006b75508 ffff8801da987dc0
> raw: 0000000000000000 ffff8801cc324e00 0000000100000001 0000000000000000
> page dumped because: kasan: bad access detected
> 
> Memory state around the buggy address:
> A ffff8801cc325100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> A ffff8801cc325180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>> ffff8801cc325200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> A A A A A A A A A A A A A A A A A A A A A A A A  ^
> A ffff8801cc325280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> A ffff8801cc325300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================

#syz invalid

This should be fixed by 49bf58ae4530 "fs/super.c: fix double prealloc_shrinker() in sget_fc()"
and 38a177aa7a72 "fs-fix-double-prealloc_shrinker-in-sget_fc-fix" in linux-next.
