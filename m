Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2E026B0005
	for <linux-mm@kvack.org>; Sat,  3 Feb 2018 02:48:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v17so16360094pgb.18
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 23:48:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 33-v6si3320754pll.161.2018.02.02.23.48.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Feb 2018 23:48:34 -0800 (PST)
Subject: Re: Possible deadlock in v4.14.15 contention on shrinker_rwsem in shrink_slab()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <4e9300f9-14c4-84a9-2258-b7e52bb6f753@I-love.SAKURA.ne.jp>
	<alpine.LRH.2.11.1801272305200.20457@mail.ewheeler.net>
	<201801290527.w0T5RsPg024008@www262.sakura.ne.jp>
In-Reply-To: <201801290527.w0T5RsPg024008@www262.sakura.ne.jp>
Message-Id: <201802031648.EBH81222.QOSOFVOMtJFHLF@I-love.SAKURA.ne.jp>
Date: Sat, 3 Feb 2018 16:48:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@lists.ewheeler.net
Cc: linux-mm@kvack.org, kirill@shutemov.name, minchan@kernel.org, tj@kernel.org, agk@redhat.com, snitzer@redhat.com, kent.overstreet@gmail.com

Michal, what do you think? If no comment, let's try page_owner + SystemTap
and check whether there are some characteristics with stalling pages.

Tetsuo Handa wrote:
> Eric Wheeler wrote:
> > I just tried v4.9.78 and we still get the deadlock. I've backported your 
> > MemAlloc timing patch and yout timing is included in the output.  Both 
> > full sysrq traces (30 seconds apart) are available here and I made sure it 
> > includes both "Showing busy workqueues and worker pools" sections:
> > 
> >   https://www.linuxglobal.com/static/2018-01-27-hv1-deadlock-v4.9.78
> > 
> > # ps -eo pid,lstart,cmd,stat |grep D
> >   PID                  STARTED CMD                         STAT
> > 16127 Sat Jan 27 05:24:29 2018 crm_node -N 2               D    << Both in D state
> > 22444 Sat Jan 27 05:39:50 2018 rsync --server --sender -vl DNs  << Both in D state
> > 
> 
> Thank you. Although the capture is still incomplete, I noticed that
> there was a surprising entry.
> 
> crm_node was stalling at page fault for 33950 seconds!
> That is, crm_node already started stalling at uptime = 45375.
> 
> ----------
> [79325.124062] MemAlloc: crm_node(16127) flags=0xc00900 switches=10 seq=441 gfp=0x24200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=33950065 uninterruptible
> [79325.125113]  ffff8cf6d750dd00 0000000000000000 ffff8cf74b9d5800 ffff8cf76fd19940
> [79325.125684]  ffff8cf6c3d84200 ffffada2a17af6c8 ffffffff8e7178f5 0000000000000000
> [79325.126245]  0000000000000000 0000000000000000 ffff8cf6c3d84200 7fffffffffffffff
> [79325.126800] Call Trace:
> [79325.127339]  [<ffffffff8e7178f5>] ? __schedule+0x195/0x630
> [79325.127985]  [<ffffffff8e718630>] ? bit_wait+0x50/0x50
> [79325.128519]  [<ffffffff8e717dc6>] schedule+0x36/0x80
> [79325.129040]  [<ffffffff8e71afa6>] schedule_timeout+0x1e6/0x320
> [79325.129560]  [<ffffffff8e718630>] ? bit_wait+0x50/0x50
> [79325.130100]  [<ffffffff8e7176f6>] io_schedule_timeout+0xa6/0x110
> [79325.130683]  [<ffffffff8e71864b>] bit_wait_io+0x1b/0x60
> [79325.131199]  [<ffffffff8e718286>] __wait_on_bit_lock+0x86/0xd0
> [79325.131723]  [<ffffffff8e1acb22>] __lock_page+0x82/0xb0
> [79325.132238]  [<ffffffff8e0e9e00>] ? autoremove_wake_function+0x40/0x40
> [79325.132765]  [<ffffffff8e1ae63b>] pagecache_get_page+0x16b/0x230
> [79325.133284]  [<ffffffff8e1ca3da>] shmem_unused_huge_shrink+0x28a/0x330
> [79325.133814]  [<ffffffff8e1ca4a7>] shmem_unused_huge_scan+0x27/0x30
> [79325.134338]  [<ffffffff8e23f941>] super_cache_scan+0x181/0x190
> [79325.134875]  [<ffffffff8e1c1ab1>] shrink_slab+0x261/0x470
> [79325.135386]  [<ffffffff8e1c6588>] shrink_node+0x108/0x310
> [79325.135904]  [<ffffffff8e1c6927>] node_reclaim+0x197/0x210
> [79325.136458]  [<ffffffff8e1b5dd8>] get_page_from_freelist+0x168/0x9f0
> [79325.137023]  [<ffffffff8e1adc8e>] ? find_get_entry+0x1e/0x100
> [79325.137560]  [<ffffffff8e1ca9c5>] ? shmem_getpage_gfp+0xf5/0xbb0
> [79325.138061]  [<ffffffff8e1b77ae>] __alloc_pages_nodemask+0x10e/0x2d0
> [79325.138619]  [<ffffffff8e207d08>] alloc_pages_current+0x88/0x120
> [79325.139117]  [<ffffffff8e070287>] pte_alloc_one+0x17/0x40
> [79325.139626]  [<ffffffff8e1e117e>] __pte_alloc+0x1e/0x100
> [79325.140138]  [<ffffffff8e1e3622>] alloc_set_pte+0x4f2/0x560
> [79325.140698]  [<ffffffff8e1e3770>] do_fault+0xe0/0x620
> [79325.141168]  [<ffffffff8e1e5504>] handle_mm_fault+0x644/0xdd0
> [79325.141667]  [<ffffffff8e06a96e>] __do_page_fault+0x25e/0x4f0
> [79325.142163]  [<ffffffff8e06ac30>] do_page_fault+0x30/0x80
> [79325.142660]  [<ffffffff8e003b55>] ? do_syscall_64+0x175/0x180
> [79325.143132]  [<ffffffff8e71dae8>] page_fault+0x28/0x30
> ----------
> 
> You took SysRq-t after multiple processes (in this case, crm_node and rsync)
> got stuck, didn't you? I feel anxious about LIST_POISON1 (dead000000000100) and
> LIST_POISON2 (dead000000000200) are showing up at rsync side.
> 
> ----------
> [79325.156361] rsync           D    0 22444  22441 0x00000080
> [79325.156871]  ffff8cf3b8437440 0000000000000000 ffff8cf74b9d1600 ffff8cf76fc59940
> [79325.157307]  ffff8cf3eef74200 ffffada2a0e17b18 ffffffff8e7178f5 dead000000000100
> [79325.157764]  dead000000000200 ffff8cf6db9101a8 ffff8cf3eef74200 7fffffffffffffff
> [79325.158225] Call Trace:
> [79325.158690]  [<ffffffff8e7178f5>] ? __schedule+0x195/0x630
> [79325.159142]  [<ffffffff8e718630>] ? bit_wait+0x50/0x50
> [79325.159604]  [<ffffffff8e717dc6>] schedule+0x36/0x80
> [79325.160053]  [<ffffffff8e71afa6>] schedule_timeout+0x1e6/0x320
> [79325.160536]  [<ffffffff8e0de21c>] ? enqueue_entity+0x3bc/0x570
> [79325.160984]  [<ffffffff8e11bf5b>] ? ktime_get+0x3b/0xb0
> [79325.161450]  [<ffffffff8e718630>] ? bit_wait+0x50/0x50
> [79325.161891]  [<ffffffff8e7176f6>] io_schedule_timeout+0xa6/0x110
> [79325.162337]  [<ffffffff8e71864b>] bit_wait_io+0x1b/0x60
> [79325.162787]  [<ffffffff8e718286>] __wait_on_bit_lock+0x86/0xd0
> [79325.163231]  [<ffffffff8e1acb22>] __lock_page+0x82/0xb0
> [79325.163681]  [<ffffffff8e0e9e00>] ? autoremove_wake_function+0x40/0x40
> [79325.164133]  [<ffffffff8e1addd1>] find_lock_entry+0x61/0x80
> [79325.164597]  [<ffffffff8e1ca9c5>] shmem_getpage_gfp+0xf5/0xbb0
> [79325.165053]  [<ffffffff8e1cb9b9>] shmem_file_read_iter+0x159/0x310
> [79325.165516]  [<ffffffff8e23b2ff>] __vfs_read+0xdf/0x130
> [79325.165966]  [<ffffffff8e23ba2c>] vfs_read+0x8c/0x130
> [79325.166430]  [<ffffffff8e23cf95>] SyS_read+0x55/0xc0
> [79325.166865]  [<ffffffff8e003a47>] do_syscall_64+0x67/0x180
> [79325.167292]  [<ffffffff8e71c530>] entry_SYSCALL64_slow_path+0x25/0x25
> ----------
> 
> > 
> > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > crm_node        D    0 16127  16126 0x00000080
> > MemAlloc: crm_node(16127) flags=0xc00900 switches=10 seq=441 gfp=0x24200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=209469 uninterruptible
> 
> At this point, crm_node already stalled for 209 seconds. Since switches= and
> seq= did not change until you took SysRq-t, crm_node kept sleeping.
> 
> > ffff8cf6d750dd00 0000000000000000 ffff8cf74b9d5800 ffff8cf76fd19940
> > ffff8cf6c3d84200 ffffada2a17af6c8 ffffffff8e7178f5 0000000000000000
> > 0000000000000000 0000000000000000 ffff8cf6c3d84200 7fffffffffffffff
> > Call Trace:
> > [<ffffffff8e7178f5>] ? __schedule+0x195/0x630
> > [<ffffffff8e718630>] ? bit_wait+0x50/0x50
> > [<ffffffff8e717dc6>] schedule+0x36/0x80
> > [<ffffffff8e71afa6>] schedule_timeout+0x1e6/0x320
> > [<ffffffff8e718630>] ? bit_wait+0x50/0x50
> > [<ffffffff8e7176f6>] io_schedule_timeout+0xa6/0x110
> > [<ffffffff8e71864b>] bit_wait_io+0x1b/0x60
> > [<ffffffff8e718286>] __wait_on_bit_lock+0x86/0xd0
> > [<ffffffff8e1acb22>] __lock_page+0x82/0xb0
> > [<ffffffff8e0e9e00>] ? autoremove_wake_function+0x40/0x40
> > [<ffffffff8e1ae63b>] pagecache_get_page+0x16b/0x230
> > [<ffffffff8e1ca3da>] shmem_unused_huge_shrink+0x28a/0x330
> > [<ffffffff8e1ca4a7>] shmem_unused_huge_scan+0x27/0x30
> > [<ffffffff8e23f941>] super_cache_scan+0x181/0x190
> > [<ffffffff8e1c1ab1>] shrink_slab+0x261/0x470
> > [<ffffffff8e1c6588>] shrink_node+0x108/0x310
> > [<ffffffff8e1c6927>] node_reclaim+0x197/0x210
> > [<ffffffff8e1b5dd8>] get_page_from_freelist+0x168/0x9f0
> > [<ffffffff8e1adc8e>] ? find_get_entry+0x1e/0x100
> > [<ffffffff8e1ca9c5>] ? shmem_getpage_gfp+0xf5/0xbb0
> > [<ffffffff8e1b77ae>] __alloc_pages_nodemask+0x10e/0x2d0
> > [<ffffffff8e207d08>] alloc_pages_current+0x88/0x120
> > [<ffffffff8e070287>] pte_alloc_one+0x17/0x40
> > [<ffffffff8e1e117e>] __pte_alloc+0x1e/0x100
> > [<ffffffff8e1e3622>] alloc_set_pte+0x4f2/0x560
> > [<ffffffff8e1e3770>] do_fault+0xe0/0x620
> > [<ffffffff8e1e5504>] handle_mm_fault+0x644/0xdd0
> > [<ffffffff8e06a96e>] __do_page_fault+0x25e/0x4f0
> > [<ffffffff8e06ac30>] do_page_fault+0x30/0x80
> > [<ffffffff8e003b55>] ? do_syscall_64+0x175/0x180
> > [<ffffffff8e71dae8>] page_fault+0x28/0x30
> > 
> > Pid 22444 didn't show up in the hung_task warning like crm_node did,
> > but its /proc/pid/stack looks like so:
> > 
> > ~]# cat /proc/22444/stack
> > [<ffffffff8e1acb22>] __lock_page+0x82/0xb0
> > [<ffffffff8e1addd1>] find_lock_entry+0x61/0x80
> > [<ffffffff8e1ca9c5>] shmem_getpage_gfp+0xf5/0xbb0
> > [<ffffffff8e1cb9b9>] shmem_file_read_iter+0x159/0x310
> > [<ffffffff8e23b2ff>] __vfs_read+0xdf/0x130
> > [<ffffffff8e23ba2c>] vfs_read+0x8c/0x130
> > [<ffffffff8e23cf95>] SyS_read+0x55/0xc0
> > [<ffffffff8e003a47>] do_syscall_64+0x67/0x180
> > [<ffffffff8e71c530>] entry_SYSCALL64_slow_path+0x25/0x25
> > [<ffffffffffffffff>] 0xffffffffffffffff
> 
> I guess that /proc/sys/kernel/hung_task_warnings already became 0.
> Since the default value of /proc/sys/kernel/hung_task_warnings is 10,
> only first 10 warnings are shown. You can set -1 to
> /proc/sys/kernel/hung_task_warnings so that all hung_task warnings
> are shown.
> 
> > 
> > 
> > ==================== 4.14.15 ====================
> > 
> > On the other server running 4.14.15 the stacks look the same as you've 
> > seen before.  Both full sysrq traces (30 seconds apart) are available here 
> > and I made sure it includes both "Showing busy workqueues and worker 
> > pools" sections:
> > 
> > 	https://www.linuxglobal.com/static/2018-01-28-hv2-deadlock-v4.14.15
> > 
> > ~]# ps -eo pid,lstart,cmd,stat |grep D
> >   PID                  STARTED CMD                         STAT
> > 27163 Sat Jan 27 05:15:48 2018 crm_node -N 2               D
> >  1125 Sat Jan 27 14:34:40 2018 /usr/sbin/libvirtd          D
> > 
> 
> crm_node was stalling at page fault for 119634 seconds (more than one day)!
> 
> ----------
> crm_node        D    0 27163      1 0x00000084
> MemAlloc: crm_node(27163) flags=0xc00900 switches=3 seq=438 gfp=0x14200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=119634513 uninterruptible
> Call Trace:
>  ? __schedule+0x1dc/0x770
>  schedule+0x32/0x80
>  io_schedule+0x12/0x40
>  __lock_page+0x105/0x150
>  ? page_cache_tree_insert+0xb0/0xb0
>  pagecache_get_page+0x161/0x210
>  shmem_unused_huge_shrink+0x334/0x3f0
>  super_cache_scan+0x176/0x180
>  shrink_slab+0x275/0x460
>  shrink_node+0x10e/0x320
>  node_reclaim+0x19d/0x250
>  get_page_from_freelist+0x16a/0xac0
>  ? radix_tree_lookup_slot+0x1e/0x50
>  ? find_lock_entry+0x45/0x80
>  ? shmem_getpage_gfp.isra.34+0xe5/0xc80
>  __alloc_pages_nodemask+0x111/0x2c0
>  pte_alloc_one+0x13/0x40
>  __pte_alloc+0x19/0x100
>  alloc_set_pte+0x468/0x4c0
>  finish_fault+0x3a/0x70
>  __handle_mm_fault+0x94a/0x1190
>  handle_mm_fault+0xf2/0x210
>  __do_page_fault+0x253/0x4d0
>  do_page_fault+0x33/0x120
>  ? page_fault+0x36/0x60
>  page_fault+0x4c/0x60
> 
> crm_node        D    0 27163      1 0x00000084
> MemAlloc: crm_node(27163) flags=0xc00900 switches=3 seq=438 gfp=0x14200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=119682540 uninterruptible
> Call Trace:
>  ? __schedule+0x1dc/0x770
>  schedule+0x32/0x80
>  io_schedule+0x12/0x40
>  __lock_page+0x105/0x150
>  ? page_cache_tree_insert+0xb0/0xb0
>  pagecache_get_page+0x161/0x210
>  shmem_unused_huge_shrink+0x334/0x3f0
>  super_cache_scan+0x176/0x180
>  shrink_slab+0x275/0x460
>  shrink_node+0x10e/0x320
>  node_reclaim+0x19d/0x250
>  get_page_from_freelist+0x16a/0xac0
>  ? radix_tree_lookup_slot+0x1e/0x50
>  ? find_lock_entry+0x45/0x80
>  ? shmem_getpage_gfp.isra.34+0xe5/0xc80
>  __alloc_pages_nodemask+0x111/0x2c0
>  pte_alloc_one+0x13/0x40
>  __pte_alloc+0x19/0x100
>  alloc_set_pte+0x468/0x4c0
>  finish_fault+0x3a/0x70
>  __handle_mm_fault+0x94a/0x1190
>  handle_mm_fault+0xf2/0x210
>  __do_page_fault+0x253/0x4d0
>  do_page_fault+0x33/0x120
>  ? page_fault+0x36/0x60
>  page_fault+0x4c/0x60
> ----------
> 
> And since switches= and seq= did not change, crm_node kept sleeping.
> 
> libvirtd remained stuck waiting for crm_node.
> But something already went wrong more than one day ago.
> 
> ----------
> libvirtd        D    0  1125      1 0x00000080
> Call Trace:
>  ? __schedule+0x1dc/0x770
>  schedule+0x32/0x80
>  rwsem_down_write_failed+0x20d/0x380
>  ? ida_get_new_above+0x110/0x3b0
>  call_rwsem_down_write_failed+0x13/0x20
>  down_write+0x29/0x40
>  register_shrinker+0x45/0xa0
>  sget_userns+0x468/0x4a0
>  ? get_anon_bdev+0x100/0x100
>  ? shmem_create+0x20/0x20
>  mount_nodev+0x2a/0xa0
>  mount_fs+0x34/0x150
>  vfs_kern_mount+0x62/0x120
>  do_mount+0x1ee/0xc50
>  SyS_mount+0x7e/0xd0
>  do_syscall_64+0x61/0x1a0
>  entry_SYSCALL64_slow_path+0x25/0x25
> ----------
> 
> > I'm not sure if this is relevant, but the load average is wrong on the
> > 4.14.15 machine:
> >   load average: 1308.46, 1246.69, 1078.29
> > There is no way those numbers are correct, top shows nothing spinning
> > and vmstat only shows 1-4 processes in a running or blocked state.
> 
> If I recall correctly, insanely growing load average is a possible sign of
> processes getting stuck one by one as one is created (by e.g. crond).
> 
> > 
> > Here are the pid stacks in D states from ps above:
> > 
> > ~]# cat /proc/27163/stack 
> > [<ffffffff900cd0d2>] io_schedule+0x12/0x40
> > [<ffffffff901b4735>] __lock_page+0x105/0x150
> > [<ffffffff901b4e61>] pagecache_get_page+0x161/0x210
> > [<ffffffff901d4c74>] shmem_unused_huge_shrink+0x334/0x3f0
> > [<ffffffff90251746>] super_cache_scan+0x176/0x180
> > [<ffffffff901cb885>] shrink_slab+0x275/0x460
> > [<ffffffff901d0d4e>] shrink_node+0x10e/0x320
> > [<ffffffff901d10fd>] node_reclaim+0x19d/0x250
> > [<ffffffff901be1ca>] get_page_from_freelist+0x16a/0xac0
> > [<ffffffff901bef81>] __alloc_pages_nodemask+0x111/0x2c0
> > [<ffffffff9006dbc3>] pte_alloc_one+0x13/0x40
> > [<ffffffff901ef4e9>] __pte_alloc+0x19/0x100
> > [<ffffffff901f1978>] alloc_set_pte+0x468/0x4c0
> > [<ffffffff901f1a0a>] finish_fault+0x3a/0x70
> > [<ffffffff901f385a>] __handle_mm_fault+0x94a/0x1190
> > [<ffffffff901f4192>] handle_mm_fault+0xf2/0x210
> > [<ffffffff900682a3>] __do_page_fault+0x253/0x4d0
> > [<ffffffff90068553>] do_page_fault+0x33/0x120
> > [<ffffffff908019dc>] page_fault+0x4c/0x60
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > 
> > ~]# cat /proc/1125/stack 
> > [<ffffffff907538d3>] call_rwsem_down_write_failed+0x13/0x20
> > [<ffffffff901cbb45>] register_shrinker+0x45/0xa0
> > [<ffffffff90251168>] sget_userns+0x468/0x4a0
> > [<ffffffff9025126a>] mount_nodev+0x2a/0xa0
> > [<ffffffff90251de4>] mount_fs+0x34/0x150
> > [<ffffffff902703f2>] vfs_kern_mount+0x62/0x120
> > [<ffffffff90272c0e>] do_mount+0x1ee/0xc50
> > [<ffffffff9027397e>] SyS_mount+0x7e/0xd0
> > [<ffffffff90003831>] do_syscall_64+0x61/0x1a0
> > [<ffffffff9080012c>] entry_SYSCALL64_slow_path+0x25/0x25
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > > > If you have any ideas on creating an easy way to reproduce the problem, 
> > > > then I can bisect---but bisecting one day at a time will take a long time, 
> > > > and could be prone to bugs which I would like to avoid on this production 
> > > > system.
> > > > 
> > > Thinking from SysRq-t output, I feel that some disk read is stuck.
> > 
> > Possibly.  I would not expect a hardware problem since we see this on two 
> > different systems with different kernel versions.
> > 
> > > Since rsyslogd failed to catch portion of SysRq-t output, I can't confirm
> > > whether register_shrinker() was in progress (nor all kernel worker threads
> > > were reported).
> > 
> > As linked above, I was able to get the full trace with netconsole.
> > 
> > > But what I was surprised is number of kernel worker threads.
> > > "grep ^kworker/ | sort" matched 314 threads and "grep ^kworker/0:"
> > > matched 244.
> > 
> > We have many DRBD volumes and LVM volumes, most of which are dm-thin, so 
> > that might be why. Also these servers have both scsi-mq and dm-mq enabled.
> 
> Ideally you could reproduce without DRBD, LVM, bcache etc. , for Marc MERLIN's
> report ( http://lkml.kernel.org/r/20170502041235.zqmywvj5tiiom3jk@merlins.org )
> was using (at least) bcache. It might be a bug which fails to submit I/O
> request.
> 
> > > 
> > > One of workqueue threads was waiting at
> > > 
> > > ----------
> > > static void *new_read(struct dm_bufio_client *c, sector_t block,
> > > 		      enum new_flag nf, struct dm_buffer **bp)
> > > {
> > > 	int need_submit;
> > > 	struct dm_buffer *b;
> > > 
> > > 	LIST_HEAD(write_list);
> > > 
> > > 	dm_bufio_lock(c);
> > > 	b = __bufio_new(c, block, nf, &need_submit, &write_list);
> > > #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
> > > 	if (b && b->hold_count == 1)
> > > 		buffer_record_stack(b);
> > > #endif
> > > 	dm_bufio_unlock(c);
> > > 
> > > 	__flush_write_list(&write_list);
> > > 
> > > 	if (!b)
> > > 		return NULL;
> > > 
> > > 	if (need_submit)
> > > 		submit_io(b, READ, read_endio);
> > > 
> > > 	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE); // <= here
> > > 
> > > 	if (b->read_error) {
> > > 		int error = blk_status_to_errno(b->read_error);
> > > 
> > > 		dm_bufio_release(b);
> > > 
> > > 		return ERR_PTR(error);
> > > 	}
> > > 
> > > 	*bp = b;
> > > 
> > > 	return b->data;
> > > }
> > > ----------
> > > 
> > > but what are possible reasons? Does this request depend on workqueue availability?
> > 
> > We are using dm-thin which uses dm-bufio.  The dm-thin pools are working
> > properly, so I don't think this is the problem---or at least if it is
> > the problem, it isn't affecting the thin pool.
> 
> Some suggestions:
> 
> 
> You can enlarge kernel printk() buffer size using log_buf_len= kernel command line
> parameter. As your system is large, you could allocate e.g. log_buf_len=67108864 .
> Then, you can read kernel buffer using dmesg command (e.g. /usr/bin/dmesg ).
> You can add timestamp to printk() messages by doing below command.
> 
> ----------
> # echo Y > /sys/module/printk/parameters/time
> ----------
> 
> 
> Since crm_node starts stalling rather early, you can watch out for kernel
> messages and userspace messages which were printed around crm_node started
> stalling, for there might be some events (e.g. error recovery) occurring.
> 
> 
> I'm not sure but maybe page_owner gives us some clue. (Michal, what do you think?)
> You can compile your kernel with CONFIG_PAGE_OWNER=y and boot your kernel with
> page_owner=on kernel command line option added. But that alone does not tell on
> which "struct page *" processes got stuck. We will need to call dump_page() for
> reporting specific "struct page *". One of approaches would be to run a SystemTap
> script shown below (in background using -F option) and check how stalling pages
> has been allocated. There might be some characteristics with stalling pages.
> 
> ----------
> # stap -DSTP_NO_OVERLOAD=1 -F -g - << "EOF"
> global waiting_pages;
> probe kernel.function("__lock_page").call { waiting_pages[$__page] = gettimeofday_s(); }
> probe kernel.function("__lock_page").return { delete waiting_pages[@entry($__page)]; }
> function my_dump_page(page:long) %{
>   dump_page((struct page *) STAP_ARG_page, "lock_page() stalling");
> %}
> probe timer.s(60) {
>   now = gettimeofday_s();
>   foreach (page in waiting_pages)
>     if (now - waiting_pages[page] >= 30)
>       my_dump_page(page);
> }
> EOF
> ----------
> 
> An example allocated by plain write() (though this is without stall period
> because I can't reproduce your problem) is shown below.
> 
> ----------
> [  164.573566] page:fffff3a9024b17c0 count:4 mapcount:0 mapping:ffff8811e2876d68 index:0x5827
> [  164.584758] flags: 0x1fffff800010a9(locked|waiters|uptodate|lru|private)
> [  164.593678] raw: 001fffff800010a9 ffff8811e2876d68 0000000000005827 00000004ffffffff
> [  164.603410] raw: fffff3a9024b17a0 fffff3a9024cc420 ffff8811e2be27b8 ffff881269fdf800
> [  164.608676] page dumped because: lock_page() stalling
> [  164.612558] page->mem_cgroup:ffff881269fdf800
> [  164.615770] page allocated via order 0, migratetype Movable, gfp_mask 0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
> [  164.623143]  __alloc_pages_nodemask+0x184/0x470
> [  164.626939]  pagecache_get_page+0xbe/0x310
> [  164.630028]  grab_cache_page_write_begin+0x1f/0x40
> [  164.633436]  iomap_write_begin.constprop.15+0x5a/0x150
> [  164.636013]  iomap_write_actor+0x95/0x180
> [  164.637955]  iomap_apply+0xa4/0x110
> [  164.639710]  iomap_file_buffered_write+0x61/0x80
> [  164.641796]  xfs_file_buffered_aio_write+0xfe/0x3b0 [xfs]
> [  164.643945]  xfs_file_write_iter+0xfc/0x150 [xfs]
> [  164.646290]  __vfs_write+0xfc/0x170
> [  164.648048]  vfs_write+0xc5/0x1b0
> [  164.649760]  SyS_write+0x55/0xc0
> [  164.651317]  do_syscall_64+0x66/0x210
> [  164.652994]  return_from_SYSCALL_64+0x0/0x75
> ----------
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
