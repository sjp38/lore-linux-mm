Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2AF6B025F
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 22:21:56 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u2so15653610itb.7
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 19:21:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z190si2103287ioz.114.2017.10.06.19.21.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Oct 2017 19:21:54 -0700 (PDT)
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org> <20171004185906.GB2136@cmpxchg.org>
 <20171004153245.2b08d831688bb8c66ef64708@linux-foundation.org>
 <20171004231821.GA3610@cmpxchg.org>
 <20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
 <55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <ceb25fb9-de4d-e401-6d6d-ce240705483c@I-love.SAKURA.ne.jp>
Date: Sat, 7 Oct 2017 11:21:26 +0900
MIME-Version: 1.0
In-Reply-To: <55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 2017/10/05 19:36, Tetsuo Handa wrote:
> I don't want this patch backported. If you want to backport,
> "s/fatal_signal_pending/tsk_is_oom_victim/" is the safer way.

If you backport this patch, you will see "complete depletion of memory reserves"
and "extra OOM kills due to depletion of memory reserves" using below reproducer.

----------
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/oom.h>

static char *buffer;

static int __init test_init(void)
{
	set_current_oom_origin();
	buffer = vmalloc((1UL << 32) - 480 * 1048576);
	clear_current_oom_origin();
	return buffer ? 0 : -ENOMEM;
}

static void test_exit(void)
{
	vfree(buffer);
}

module_init(test_init);
module_exit(test_exit);
MODULE_LICENSE("GPL");
----------

----------
CentOS Linux 7 (Core)
Kernel 4.13.5+ on an x86_64

ccsecurity login: [   53.637666] test: loading out-of-tree module taints kernel.
[   53.856166] insmod invoked oom-killer: gfp_mask=0x14002c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_NOWARN), nodemask=(null),  order=0, oom_score_adj=0
[   53.858754] insmod cpuset=/ mems_allowed=0
[   53.859713] CPU: 1 PID: 2763 Comm: insmod Tainted: G           O    4.13.5+ #10
[   53.861134] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   53.863072] Call Trace:
[   53.863548]  dump_stack+0x4d/0x6f
[   53.864172]  dump_header+0x92/0x22a
[   53.864869]  ? has_ns_capability_noaudit+0x30/0x40
[   53.865887]  oom_kill_process+0x250/0x440
[   53.866644]  out_of_memory+0x10d/0x480
[   53.867343]  __alloc_pages_nodemask+0x1087/0x1140
[   53.868216]  alloc_pages_current+0x65/0xd0
[   53.869086]  __vmalloc_node_range+0x129/0x230
[   53.869895]  vmalloc+0x39/0x40
[   53.870472]  ? test_init+0x26/0x1000 [test]
[   53.871248]  test_init+0x26/0x1000 [test]
[   53.871993]  ? 0xffffffffa00fa000
[   53.872609]  do_one_initcall+0x4d/0x190
[   53.873301]  do_init_module+0x5a/0x1f7
[   53.873999]  load_module+0x2022/0x2960
[   53.874678]  ? vfs_read+0x116/0x130
[   53.875312]  SyS_finit_module+0xe1/0xf0
[   53.876074]  ? SyS_finit_module+0xe1/0xf0
[   53.876806]  do_syscall_64+0x5c/0x140
[   53.877488]  entry_SYSCALL64_slow_path+0x25/0x25
[   53.878316] RIP: 0033:0x7f1b27c877f9
[   53.878964] RSP: 002b:00007ffff552e718 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   53.880620] RAX: ffffffffffffffda RBX: 0000000000a2d210 RCX: 00007f1b27c877f9
[   53.881883] RDX: 0000000000000000 RSI: 000000000041a678 RDI: 0000000000000003
[   53.883167] RBP: 000000000041a678 R08: 0000000000000000 R09: 00007ffff552e8b8
[   53.884685] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   53.885949] R13: 0000000000a2d1e0 R14: 0000000000000000 R15: 0000000000000000
[   53.887392] Mem-Info:
[   53.887909] active_anon:14248 inactive_anon:2088 isolated_anon:0
[   53.887909]  active_file:4 inactive_file:2 isolated_file:2
[   53.887909]  unevictable:0 dirty:3 writeback:2 unstable:0
[   53.887909]  slab_reclaimable:2818 slab_unreclaimable:4420
[   53.887909]  mapped:453 shmem:2162 pagetables:1676 bounce:0
[   53.887909]  free:21418 free_pcp:0 free_cma:0
[   53.895172] Node 0 active_anon:56992kB inactive_anon:8352kB active_file:12kB inactive_file:12kB unevictable:0kB isolated(anon):0kB isolated(file):8kB mapped:1812kB dirty:12kB writeback:8kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 6144kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   53.901844] Node 0 DMA free:14932kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   53.907765] lowmem_reserve[]: 0 2703 3662 3662
[   53.909333] Node 0 DMA32 free:53424kB min:49684kB low:62104kB high:74524kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2790292kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   53.915597] lowmem_reserve[]: 0 0 958 958
[   53.916992] Node 0 Normal free:17192kB min:17608kB low:22008kB high:26408kB active_anon:56992kB inactive_anon:8352kB active_file:12kB inactive_file:12kB unevictable:0kB writepending:20kB present:1048576kB managed:981384kB mlocked:0kB kernel_stack:3648kB pagetables:6704kB bounce:0kB free_pcp:112kB local_pcp:0kB free_cma:0kB
[   53.924610] lowmem_reserve[]: 0 0 0 0
[   53.926131] Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (U) 0*32kB 1*64kB (U) 0*128kB 0*256kB 1*512kB (U) 0*1024kB 1*2048kB (M) 3*4096kB (M) = 14932kB
[   53.929273] Node 0 DMA32: 4*4kB (UM) 2*8kB (UM) 5*16kB (UM) 4*32kB (M) 3*64kB (M) 4*128kB (M) 5*256kB (UM) 4*512kB (M) 4*1024kB (UM) 2*2048kB (UM) 10*4096kB (M) = 53424kB
[   53.934010] Node 0 Normal: 896*4kB (ME) 466*8kB (UME) 288*16kB (UME) 128*32kB (UME) 23*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17488kB
[   53.937833] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   53.940769] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   53.943250] 2166 total pagecache pages
[   53.944788] 0 pages in swap cache
[   53.946249] Swap cache stats: add 0, delete 0, find 0/0
[   53.948075] Free swap  = 0kB
[   53.949419] Total swap = 0kB
[   53.950873] 1048445 pages RAM
[   53.952238] 0 pages HighMem/MovableOnly
[   53.953768] 101550 pages reserved
[   53.955555] 0 pages hwpoisoned
[   53.956923] Out of memory: Kill process 2763 (insmod) score 3621739297 or sacrifice child
[   53.959298] Killed process 2763 (insmod) total-vm:13084kB, anon-rss:132kB, file-rss:0kB, shmem-rss:0kB
[   53.962059] oom_reaper: reaped process 2763 (insmod), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   53.968054] insmod invoked oom-killer: gfp_mask=0x14002c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_NOWARN), nodemask=(null),  order=0, oom_score_adj=0
[   53.971406] insmod cpuset=/ mems_allowed=0
[   53.973066] CPU: 1 PID: 2763 Comm: insmod Tainted: G           O    4.13.5+ #10
[   53.975339] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   53.978388] Call Trace:
[   53.979714]  dump_stack+0x4d/0x6f
[   53.981176]  dump_header+0x92/0x22a
[   53.982747]  ? has_ns_capability_noaudit+0x30/0x40
[   53.984481]  oom_kill_process+0x250/0x440
[   53.986133]  out_of_memory+0x10d/0x480
[   53.987667]  __alloc_pages_nodemask+0x1087/0x1140
[   53.989431]  alloc_pages_current+0x65/0xd0
[   53.991037]  __vmalloc_node_range+0x129/0x230
[   53.992775]  vmalloc+0x39/0x40
[   53.994421]  ? test_init+0x26/0x1000 [test]
[   53.996063]  test_init+0x26/0x1000 [test]
[   53.997825]  ? 0xffffffffa00fa000
[   53.999280]  do_one_initcall+0x4d/0x190
[   54.000786]  do_init_module+0x5a/0x1f7
[   54.002351]  load_module+0x2022/0x2960
[   54.003789]  ? vfs_read+0x116/0x130
[   54.005299]  SyS_finit_module+0xe1/0xf0
[   54.006872]  ? SyS_finit_module+0xe1/0xf0
[   54.008300]  do_syscall_64+0x5c/0x140
[   54.009912]  entry_SYSCALL64_slow_path+0x25/0x25
[   54.011464] RIP: 0033:0x7f1b27c877f9
[   54.012816] RSP: 002b:00007ffff552e718 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   54.014958] RAX: ffffffffffffffda RBX: 0000000000a2d210 RCX: 00007f1b27c877f9
[   54.017062] RDX: 0000000000000000 RSI: 000000000041a678 RDI: 0000000000000003
[   54.019065] RBP: 000000000041a678 R08: 0000000000000000 R09: 00007ffff552e8b8
[   54.020951] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   54.022738] R13: 0000000000a2d1e0 R14: 0000000000000000 R15: 0000000000000000
[   54.024673] Mem-Info:
[   54.025767] active_anon:14220 inactive_anon:2088 isolated_anon:0
[   54.025767]  active_file:3 inactive_file:0 isolated_file:0
[   54.025767]  unevictable:0 dirty:1 writeback:2 unstable:0
[   54.025767]  slab_reclaimable:2774 slab_unreclaimable:4420
[   54.025767]  mapped:453 shmem:2162 pagetables:1676 bounce:0
[   54.025767]  free:72 free_pcp:0 free_cma:0
[   54.034925] Node 0 active_anon:56880kB inactive_anon:8352kB active_file:12kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1812kB dirty:4kB writeback:8kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 6144kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[   54.041176] Node 0 DMA free:12kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   54.047349] lowmem_reserve[]: 0 2703 3662 3662
[   54.048922] Node 0 DMA32 free:104kB min:49684kB low:62104kB high:74524kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2790292kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   54.055698] lowmem_reserve[]: 0 0 958 958
[   54.057182] Node 0 Normal free:188kB min:17608kB low:22008kB high:26408kB active_anon:56880kB inactive_anon:8352kB active_file:12kB inactive_file:0kB unevictable:0kB writepending:12kB present:1048576kB managed:981384kB mlocked:0kB kernel_stack:3648kB pagetables:6704kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   54.065665] lowmem_reserve[]: 0 0 0 0
[   54.067279] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   54.069949] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   54.072630] Node 0 Normal: 31*4kB (UM) 5*8kB (UM) 1*16kB (E) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 180kB
[   54.075624] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   54.078142] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   54.080509] 2165 total pagecache pages
[   54.081931] 0 pages in swap cache
[   54.083381] Swap cache stats: add 0, delete 0, find 0/0
[   54.085051] Free swap  = 0kB
[   54.086305] Total swap = 0kB
[   54.087931] 1048445 pages RAM
[   54.089296] 0 pages HighMem/MovableOnly
[   54.090731] 101550 pages reserved
[   54.092161] 0 pages hwpoisoned
[   54.093738] Out of memory: Kill process 2458 (tuned) score 3 or sacrifice child
[   54.095910] Killed process 2458 (tuned) total-vm:562424kB, anon-rss:12764kB, file-rss:0kB, shmem-rss:0kB
[   54.098531] insmod: vmalloc: allocation failure, allocated 3725393920 of 3791654912 bytes, mode:0x14000c0(GFP_KERNEL), nodemask=(null)
[   54.101771] insmod cpuset=/ mems_allowed=0
[   54.103661] oom_reaper: reaped process 2458 (tuned), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   54.103807] tuned invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=0, oom_score_adj=0
[   54.103809] tuned cpuset=/ mems_allowed=0
[   54.103815] CPU: 2 PID: 2712 Comm: tuned Tainted: G           O    4.13.5+ #10
[   54.103815] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   54.103816] Call Trace:
[   54.103825]  dump_stack+0x4d/0x6f
[   54.103827]  dump_header+0x92/0x22a
[   54.103830]  ? has_ns_capability_noaudit+0x30/0x40
[   54.103834]  oom_kill_process+0x250/0x440
[   54.103835]  out_of_memory+0x10d/0x480
[   54.103836]  __alloc_pages_nodemask+0x1087/0x1140
[   54.103840]  alloc_pages_current+0x65/0xd0
[   54.103843]  pte_alloc_one+0x12/0x40
[   54.103845]  do_huge_pmd_anonymous_page+0xfd/0x620
[   54.103847]  __handle_mm_fault+0x9a7/0x1040
[   54.103848]  ? _lookup_address_cpa.isra.7+0x38/0x40
[   54.103849]  handle_mm_fault+0xd1/0x1c0
[   54.103852]  __do_page_fault+0x28b/0x4f0
[   54.103854]  do_page_fault+0x20/0x70
[   54.103857]  page_fault+0x22/0x30
[   54.103859] RIP: 0010:__get_user_8+0x1b/0x25
[   54.103860] RSP: 0000:ffffc90002703c38 EFLAGS: 00010287
[   54.103860] RAX: 00007fc407fff9e7 RBX: ffff880136cbc740 RCX: 00000000000002b0
[   54.103861] RDX: ffff880133c98e00 RSI: ffff880136cbc740 RDI: ffff880133c98e00
[   54.103861] RBP: ffffc90002703c80 R08: 0000000000000001 R09: 0000000000000000
[   54.103862] R10: ffffc90002703c48 R11: 00000000000003f6 R12: ffff880133c98e00
[   54.103862] R13: ffff880133c98e00 R14: 00007fc407fff9e0 R15: 0000000001399fc8
[   54.103866]  ? exit_robust_list+0x2e/0x110
[   54.103868]  mm_release+0x100/0x140
[   54.103869]  do_exit+0x14b/0xb50
[   54.103871]  ? pick_next_task_fair+0x17d/0x4d0
[   54.103874]  ? put_prev_entity+0x26/0x340
[   54.103875]  do_group_exit+0x36/0xb0
[   54.103878]  get_signal+0x263/0x5f0
[   54.103881]  do_signal+0x32/0x630
[   54.103884]  ? __audit_syscall_exit+0x21a/0x2b0
[   54.103886]  ? syscall_slow_exit_work+0x15c/0x1a0
[   54.103888]  ? getnstimeofday64+0x9/0x20
[   54.103890]  ? wake_up_q+0x80/0x80
[   54.103891]  exit_to_usermode_loop+0x76/0x90
[   54.103892]  do_syscall_64+0x12e/0x140
[   54.103893]  entry_SYSCALL64_slow_path+0x25/0x25
[   54.103895] RIP: 0033:0x7fc42486e923
[   54.103895] RSP: 002b:00007fc407ffe360 EFLAGS: 00000293 ORIG_RAX: 00000000000000e8
[   54.103896] RAX: fffffffffffffffc RBX: 00007fc4259b7828 RCX: 00007fc42486e923
[   54.103896] RDX: 00000000000003ff RSI: 00007fc400001980 RDI: 000000000000000a
[   54.103897] RBP: 00000000ffffffff R08: 00007fc41a1558e0 R09: 0000000000002ff4
[   54.103897] R10: 00000000ffffffff R11: 0000000000000293 R12: 00007fc40c010140
[   54.103898] R13: 00007fc400001980 R14: 00007fc400001790 R15: 0000000001399fc8
[   54.103899] Mem-Info:
[   54.103902] active_anon:11004 inactive_anon:2088 isolated_anon:0
[   54.103902]  active_file:6 inactive_file:0 isolated_file:0
[   54.103902]  unevictable:0 dirty:1 writeback:2 unstable:0
[   54.103902]  slab_reclaimable:2770 slab_unreclaimable:4420
[   54.103902]  mapped:453 shmem:2162 pagetables:1676 bounce:0
[   54.103902]  free:3117 free_pcp:158 free_cma:0
[   54.103904] Node 0 active_anon:44016kB inactive_anon:8352kB active_file:24kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1812kB dirty:4kB writeback:8kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 6144kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[   54.103905] Node 0 DMA free:12kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   54.103908] lowmem_reserve[]: 0 2703 3662 3662
[   54.103909] Node 0 DMA32 free:104kB min:49684kB low:62104kB high:74524kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2790292kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   54.103911] lowmem_reserve[]: 0 0 958 958
[   54.103912] Node 0 Normal free:12352kB min:17608kB low:22008kB high:26408kB active_anon:44068kB inactive_anon:8352kB active_file:24kB inactive_file:0kB unevictable:0kB writepending:12kB present:1048576kB managed:981384kB mlocked:0kB kernel_stack:3616kB pagetables:6704kB bounce:0kB free_pcp:632kB local_pcp:632kB free_cma:0kB
[   54.103914] lowmem_reserve[]: 0 0 0 0
[   54.103915] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   54.103918] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   54.103921] Node 0 Normal: 536*4kB (UM) 281*8kB (UM) 124*16kB (UME) 76*32kB (UM) 12*64kB (U) 3*128kB (U) 2*256kB (U) 0*512kB 0*1024kB 1*2048kB (M) 0*4096kB = 12520kB
[   54.103926] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   54.103926] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   54.103927] 2165 total pagecache pages
[   54.103928] 0 pages in swap cache
[   54.103929] Swap cache stats: add 0, delete 0, find 0/0
[   54.103929] Free swap  = 0kB
[   54.103929] Total swap = 0kB
[   54.103929] 1048445 pages RAM
[   54.103930] 0 pages HighMem/MovableOnly
[   54.103930] 101550 pages reserved
[   54.103930] 0 pages hwpoisoned
[   54.103931] Out of memory: Kill process 2353 (dhclient) score 3 or sacrifice child
[   54.103984] Killed process 2353 (dhclient) total-vm:113384kB, anon-rss:12488kB, file-rss:0kB, shmem-rss:0kB
[   54.262237] CPU: 1 PID: 2763 Comm: insmod Tainted: G           O    4.13.5+ #10
[   54.264476] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   54.267326] Call Trace:
[   54.268614]  dump_stack+0x4d/0x6f
[   54.270200]  warn_alloc+0x10f/0x1a0
[   54.271723]  __vmalloc_node_range+0x14e/0x230
[   54.273359]  vmalloc+0x39/0x40
[   54.274778]  ? test_init+0x26/0x1000 [test]
[   54.276480]  test_init+0x26/0x1000 [test]
[   54.278081]  ? 0xffffffffa00fa000
[   54.279576]  do_one_initcall+0x4d/0x190
[   54.281089]  do_init_module+0x5a/0x1f7
[   54.282637]  load_module+0x2022/0x2960
[   54.284221]  ? vfs_read+0x116/0x130
[   54.285674]  SyS_finit_module+0xe1/0xf0
[   54.287216]  ? SyS_finit_module+0xe1/0xf0
[   54.288737]  do_syscall_64+0x5c/0x140
[   54.290285]  entry_SYSCALL64_slow_path+0x25/0x25
[   54.291930] RIP: 0033:0x7f1b27c877f9
[   54.293557] RSP: 002b:00007ffff552e718 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   54.295810] RAX: ffffffffffffffda RBX: 0000000000a2d210 RCX: 00007f1b27c877f9
[   54.297875] RDX: 0000000000000000 RSI: 000000000041a678 RDI: 0000000000000003
[   54.299904] RBP: 000000000041a678 R08: 0000000000000000 R09: 00007ffff552e8b8
[   54.301935] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   54.303884] R13: 0000000000a2d1e0 R14: 0000000000000000 R15: 0000000000000000
[   54.305896] Mem-Info:
[   54.307238] active_anon:7863 inactive_anon:2088 isolated_anon:0
[   54.307238]  active_file:3 inactive_file:431 isolated_file:0
[   54.307238]  unevictable:0 dirty:1 writeback:2 unstable:0
[   54.307238]  slab_reclaimable:2767 slab_unreclaimable:4413
[   54.307238]  mapped:660 shmem:2162 pagetables:1529 bounce:0
[   54.307238]  free:5315 free_pcp:291 free_cma:0
[   54.317589] Node 0 active_anon:31452kB inactive_anon:8352kB active_file:12kB inactive_file:1836kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2700kB dirty:4kB writeback:8kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 4096kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[   54.324325] Node 0 DMA free:12kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   54.330628] lowmem_reserve[]: 0 2703 3662 3662
[   54.332163] Node 0 DMA32 free:104kB min:49684kB low:62104kB high:74524kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2790292kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   54.338996] lowmem_reserve[]: 0 0 958 958
[   54.340615] Node 0 Normal free:20648kB min:17608kB low:22008kB high:26408kB active_anon:31452kB inactive_anon:8352kB active_file:12kB inactive_file:2360kB unevictable:0kB writepending:12kB present:1048576kB managed:981384kB mlocked:0kB kernel_stack:3584kB pagetables:6116kB bounce:0kB free_pcp:1192kB local_pcp:8kB free_cma:0kB
[   54.348671] lowmem_reserve[]: 0 0 0 0
[   54.350205] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   54.353027] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   54.355895] Node 0 Normal: 580*4kB (UE) 329*8kB (U) 129*16kB (UE) 70*32kB (U) 16*64kB (U) 5*128kB (UM) 5*256kB (UM) 2*512kB (M) 1*1024kB (M) 3*2048kB (M) 0*4096kB = 20392kB
[   54.360581] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   54.363080] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   54.365507] 2864 total pagecache pages
[   54.366963] 0 pages in swap cache
[   54.368390] Swap cache stats: add 0, delete 0, find 0/0
[   54.370124] Free swap  = 0kB
[   54.371431] Total swap = 0kB
[   54.372770] 1048445 pages RAM
[   54.374085] 0 pages HighMem/MovableOnly
[   54.376827] 101550 pages reserved
[   54.378635] 0 pages hwpoisoned
----------

On the other hand, if you do "s/fatal_signal_pending/tsk_is_oom_victim/", there
is no "depletion of memory reseres" and no "extra OOM kills due to depletion of
memory reserves".

----------
CentOS Linux 7 (Core)
Kernel 4.13.5+ on an x86_64

ccsecurity login: [   54.746704] test: loading out-of-tree module taints kernel.
[   54.896608] insmod invoked oom-killer: gfp_mask=0x14002c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_NOWARN), nodemask=(null),  order=0, oom_score_adj=0
[   54.900107] insmod cpuset=/ mems_allowed=0
[   54.902235] CPU: 3 PID: 2749 Comm: insmod Tainted: G           O    4.13.5+ #11
[   54.906886] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   54.909943] Call Trace:
[   54.911433]  dump_stack+0x4d/0x6f
[   54.912957]  dump_header+0x92/0x22a
[   54.914426]  ? has_ns_capability_noaudit+0x30/0x40
[   54.916242]  oom_kill_process+0x250/0x440
[   54.917912]  out_of_memory+0x10d/0x480
[   54.919426]  __alloc_pages_nodemask+0x1087/0x1140
[   54.921365]  ? vmap_page_range_noflush+0x280/0x320
[   54.923232]  alloc_pages_current+0x65/0xd0
[   54.924784]  __vmalloc_node_range+0x16a/0x280
[   54.926386]  vmalloc+0x39/0x40
[   54.927686]  ? test_init+0x26/0x1000 [test]
[   54.929258]  test_init+0x26/0x1000 [test]
[   54.930793]  ? 0xffffffffa00a0000
[   54.932167]  do_one_initcall+0x4d/0x190
[   54.933586]  ? kfree+0x16f/0x180
[   54.934992]  ? kfree+0x16f/0x180
[   54.936393]  do_init_module+0x5a/0x1f7
[   54.937807]  load_module+0x2022/0x2960
[   54.939344]  ? vfs_read+0x116/0x130
[   54.940901]  SyS_finit_module+0xe1/0xf0
[   54.942386]  ? SyS_finit_module+0xe1/0xf0
[   54.943955]  do_syscall_64+0x5c/0x140
[   54.945991]  entry_SYSCALL64_slow_path+0x25/0x25
[   54.947802] RIP: 0033:0x7fd1655057f9
[   54.949220] RSP: 002b:00007fff9d59fdf8 EFLAGS: 00000202 ORIG_RAX: 0000000000000139
[   54.951317] RAX: ffffffffffffffda RBX: 000000000085e210 RCX: 00007fd1655057f9
[   54.953379] RDX: 0000000000000000 RSI: 000000000041a678 RDI: 0000000000000003
[   54.955837] RBP: 000000000041a678 R08: 0000000000000000 R09: 00007fff9d59ff98
[   54.959966] R10: 0000000000000003 R11: 0000000000000202 R12: 0000000000000000
[   54.962171] R13: 000000000085e1e0 R14: 0000000000000000 R15: 0000000000000000
[   54.978917] Mem-Info:
[   54.980118] active_anon:13936 inactive_anon:2088 isolated_anon:0
[   54.980118]  active_file:32 inactive_file:6 isolated_file:0
[   54.980118]  unevictable:0 dirty:10 writeback:0 unstable:0
[   54.980118]  slab_reclaimable:2812 slab_unreclaimable:4414
[   54.980118]  mapped:456 shmem:2162 pagetables:1681 bounce:0
[   54.980118]  free:21335 free_pcp:0 free_cma:0
[   54.990120] Node 0 active_anon:55744kB inactive_anon:8352kB active_file:128kB inactive_file:24kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1824kB dirty:40kB writeback:0kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 10240kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   54.996847] Node 0 DMA free:14932kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   55.003426] lowmem_reserve[]: 0 2703 3662 3662
[   55.004962] Node 0 DMA32 free:53056kB min:49684kB low:62104kB high:74524kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2790292kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   55.011598] lowmem_reserve[]: 0 0 958 958
[   55.013852] Node 0 Normal free:17352kB min:17608kB low:22008kB high:26408kB active_anon:55696kB inactive_anon:8352kB active_file:364kB inactive_file:180kB unevictable:0kB writepending:36kB present:1048576kB managed:981384kB mlocked:0kB kernel_stack:3600kB pagetables:6724kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
[   55.021929] lowmem_reserve[]: 0 0 0 0
[   55.023636] Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (U) 0*32kB 1*64kB (U) 0*128kB 0*256kB 1*512kB (U) 0*1024kB 1*2048kB (M) 3*4096kB (M) = 14932kB
[   55.026942] Node 0 DMA32: 4*4kB (UM) 2*8kB (UM) 5*16kB (UM) 4*32kB (M) 3*64kB (M) 5*128kB (UM) 4*256kB (M) 4*512kB (M) 4*1024kB (UM) 2*2048kB (UM) 10*4096kB (M) = 53296kB
[   55.031534] Node 0 Normal: 974*4kB (UME) 560*8kB (UME) 288*16kB (ME) 96*32kB (ME) 24*64kB (UM) 0*128kB 1*256kB (U) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17848kB
[   55.036126] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   55.038841] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   55.041431] 2197 total pagecache pages
[   55.043071] 0 pages in swap cache
[   55.044597] Swap cache stats: add 0, delete 0, find 0/0
[   55.046509] Free swap  = 0kB
[   55.047977] Total swap = 0kB
[   55.049548] 1048445 pages RAM
[   55.051143] 0 pages HighMem/MovableOnly
[   55.052799] 101550 pages reserved
[   55.054319] 0 pages hwpoisoned
[   55.055906] Out of memory: Kill process 2749 (insmod) score 3621739297 or sacrifice child
[   55.058429] Killed process 2749 (insmod) total-vm:13084kB, anon-rss:132kB, file-rss:0kB, shmem-rss:0kB
[   55.061278] oom_reaper: reaped process 2749 (insmod), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------

Therfore, I throw

Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
