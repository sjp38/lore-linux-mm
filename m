Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 650F76B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:42:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t24so3325638pfe.20
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:42:56 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0101.outbound.protection.outlook.com. [104.47.2.101])
        by mx.google.com with ESMTPS id 3-v6si4107854plu.465.2018.03.15.07.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 07:42:54 -0700 (PDT)
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
References: <20180314220909.GE2943022@devbig577.frc2.facebook.com>
 <20180314152203.c06fce436d221d34d3e4cf4a@linux-foundation.org>
 <c5c1c98b-9e0c-ec09-36c6-4266ad239ef1@virtuozzo.com>
 <5a4a1aae-8c61-de28-d3cd-2f8f4355f050@i-love.sakura.ne.jp>
 <77e9be93-3c94-269e-3100-463b39ed9776@virtuozzo.com>
 <201803152309.HGH64517.FOFOMHFSJVtLOQ@I-love.SAKURA.ne.jp>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <be1a9ffe-176f-4ce2-7705-d840a5b9780b@virtuozzo.com>
Date: Thu, 15 Mar 2018 17:42:47 +0300
MIME-Version: 1.0
In-Reply-To: <201803152309.HGH64517.FOFOMHFSJVtLOQ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, tj@kernel.org, willy@infradead.org
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15.03.2018 17:09, Tetsuo Handa wrote:
> Kirill Tkhai wrote:
>>>>>>> My memory is weak and our documentation is awful.? What does
>>>>>>> mutex_lock_killable() actually do and how does it differ from
>>>>>>> mutex_lock_interruptible()?? Userspace tasks can run pcpu_alloc() and I
>>>>>>
>>>>>> IIRC, killable listens only to SIGKILL.
>>>
>>> I think that killable listens to any signal which results in termination of
>>> that process. For example, if a process is configured to terminate upon SIGINT,
>>> fatal_signal_pending() becomes true upon SIGINT.
>>
>> It shouldn't act on SIGINT:
>>
>> static inline int __fatal_signal_pending(struct task_struct *p)
>> {
>>         return unlikely(sigismember(&p->pending.signal, SIGKILL));
>> }
>>
>> static inline int fatal_signal_pending(struct task_struct *p)
>> {
>>         return signal_pending(p) && __fatal_signal_pending(p);
>> }
>>
> 
> Really? Compile below module and try to load using insmod command.
> 
> ----------------------------------------
> #include <linux/module.h>
> #include <linux/sched/signal.h>
> 
> static int __init test_init(void)
> {
> 	static DEFINE_MUTEX(lock);
> 
> 	mutex_lock(&lock);
> 	printk(KERN_INFO "signal_pending()=%d fatal_signal_pending()=%d\n", signal_pending(current), fatal_signal_pending(current));
> 	if (mutex_lock_killable(&lock)) {
> 		printk(KERN_INFO "signal_pending()=%d fatal_signal_pending()=%d\n", signal_pending(current), fatal_signal_pending(current));
> 		mutex_unlock(&lock);
> 		return -EINTR;
> 	}
> 	mutex_unlock(&lock);
> 	mutex_unlock(&lock);
> 	return -EINVAL;
> }
> 
> module_init(test_init);
> MODULE_LICENSE("GPL");
> ----------------------------------------
> 
> What you will see (apart from lockdep warning) upon SIGINT or SIGHUP is
> 
>   signal_pending()=0 fatal_signal_pending()=0
>   signal_pending()=1 fatal_signal_pending()=1
> 
> which means that fatal_signal_pending() becomes true without SIGKILL.
> If insmod is executed via nohup wrapper, insmod does not terminate upon SIGHUP.

Matthew already pointed that. Thanks for the explanation again :)
 
>> The problem is that net namespace init/exit methods are not made to be executed in parallel,
>> and exclusive mutex is used there. I'm working on solution at the moment, and you may find
>> that I've done in net-next.git, if you are interested.
> 
> I see. Despite your patch, torture tests using your test case still allows OOM panic.

I know. There are several problems. But fresh net-next.git with this patch and these two patchsets:

https://patchwork.ozlabs.org/project/netdev/list/?series=33829
https://patchwork.ozlabs.org/project/netdev/list/?series=33949

does not bump into OOM during the test.

Despite that, there is a lot of work, which should be made more.

Kirill
 
> ----------------------------------------
> [  860.420677] Out of memory: Kill process 12727 (a.out) score 0 or sacrifice child
> [  860.423228] Killed process 12727 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  860.428125] oom_reaper: reaped process 12727 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  860.438257] Out of memory: Kill process 12728 (a.out) score 0 or sacrifice child
> [  860.440709] Killed process 12728 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  860.445840] oom_reaper: reaped process 12728 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  860.456815] Out of memory: Kill process 12729 (a.out) score 0 or sacrifice child
> [  860.459618] Killed process 12729 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  860.464686] oom_reaper: reaped process 12729 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  860.489807] Out of memory: Kill process 12730 (a.out) score 0 or sacrifice child
> [  860.492495] Killed process 12730 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  860.501268] oom_reaper: reaped process 12730 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  860.536786] Out of memory: Kill process 12731 (a.out) score 0 or sacrifice child
> [  860.539392] Killed process 12731 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  860.544130] oom_reaper: reaped process 12731 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  860.553587] Out of memory: Kill process 12732 (a.out) score 0 or sacrifice child
> [  860.556359] Killed process 12732 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  860.559639] oom_reaper: reaped process 12732 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  860.564972] Out of memory: Kill process 12733 (a.out) score 0 or sacrifice child
> [  860.567603] Killed process 12733 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  860.573416] oom_reaper: reaped process 12733 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  860.579675] Out of memory: Kill process 762 (dbus-daemon) score 0 or sacrifice child
> [  860.582334] Killed process 762 (dbus-daemon) total-vm:24560kB, anon-rss:480kB, file-rss:0kB, shmem-rss:0kB
> [  860.590607] systemd invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
> [  860.594065] systemd cpuset=/ mems_allowed=0
> [  860.596172] CPU: 1 PID: 1 Comm: systemd Kdump: loaded Tainted: G           O      4.16.0-rc5-next-20180315 #695
> [  860.599401] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
> [  860.602676] Call Trace:
> [  860.604118]  dump_stack+0x5f/0x8b
> [  860.605741]  dump_header+0x69/0x431
> [  860.607380]  ? rcu_read_unlock_special+0x2cc/0x2f0
> [  860.609342]  out_of_memory+0x4d8/0x720
> [  860.611044]  __alloc_pages_nodemask+0x12c5/0x1410
> [  860.613041]  filemap_fault+0x479/0x640
> [  860.614725]  __xfs_filemap_fault.constprop.0+0x5f/0x1f0
> [  860.616717]  __do_fault+0x15/0xa0
> [  860.618294]  __handle_mm_fault+0xcb2/0x1140
> [  860.620031]  handle_mm_fault+0x186/0x350
> [  860.621720]  __do_page_fault+0x2a7/0x510
> [  860.623402]  do_page_fault+0x2c/0x2a0
> [  860.624999]  ? page_fault+0x2f/0x50
> [  860.626548]  page_fault+0x45/0x50
> [  860.628045] RIP: 61fa2380:0x55c6609099a0
> [  860.629805] RSP: 608a920b:00007ffc83a98620 EFLAGS: 7fdbd590e740
> [  860.630698] Mem-Info:
> [  860.634428] active_anon:3783 inactive_anon:3987 isolated_anon:0
> [  860.634428]  active_file:3 inactive_file:0 isolated_file:0
> [  860.634428]  unevictable:0 dirty:0 writeback:0 unstable:0
> [  860.634428]  slab_reclaimable:124666 slab_unreclaimable:694094
> [  860.634428]  mapped:37 shmem:6270 pagetables:2087 bounce:0
> [  860.634428]  free:21037 free_pcp:299 free_cma:0
> [  860.646361] Node 0 active_anon:15132kB inactive_anon:15948kB active_file:12kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:148kB dirty:0kB writeback:0kB shmem:25080kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2048kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
> [  860.653706] Node 0 DMA free:14828kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [  860.660693] lowmem_reserve[]: 0 2684 3642 3642
> [  860.662661] Node 0 DMA32 free:53532kB min:49596kB low:61992kB high:74388kB active_anon:3420kB inactive_anon:5048kB active_file:192kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2771556kB mlocked:0kB kernel_stack:5184kB pagetables:7680kB bounce:0kB free_pcp:444kB local_pcp:76kB free_cma:0kB
> [  860.671523] lowmem_reserve[]: 0 0 958 958
> [  860.673464] Node 0 Normal free:15616kB min:17696kB low:22120kB high:26544kB active_anon:11948kB inactive_anon:10900kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:981136kB mlocked:0kB kernel_stack:2640kB pagetables:636kB bounce:0kB free_pcp:892kB local_pcp:648kB free_cma:0kB
> [  860.682664] lowmem_reserve[]: 0 0 0 0
> [  860.684412] Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 1*32kB (U) 1*64kB (U) 1*128kB (E) 1*256kB (E) 2*512kB (UE) 1*1024kB (E) 2*2048kB (ME) 2*4096kB (M) = 14828kB
> [  860.688963] Node 0 DMA32: 565*4kB (UM) 568*8kB (UM) 1037*16kB (UM) 42*32kB (ME) 26*64kB (UME) 15*128kB (ME) 15*256kB (UM) 8*512kB (ME) 7*1024kB (UME) 3*2048kB (M) 1*4096kB (M) = 53668kB
> [  860.694161] Node 0 Normal: 67*4kB (ME) 1218*8kB (UME) 348*16kB (UME) 1*32kB (E) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15612kB
> [  860.698195] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
> [  860.701105] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> [  860.703682] 6267 total pagecache pages
> [  860.705388] 0 pages in swap cache
> [  860.707457] Swap cache stats: add 0, delete 0, find 0/0
> [  860.709624] Free swap  = 0kB
> [  860.711105] Total swap = 0kB
> [  860.712841] 1048445 pages RAM
> [  860.714320] 0 pages HighMem/MovableOnly
> [  860.715970] 106296 pages reserved
> [  860.717625] 0 pages hwpoisoned
> [  860.719086] Unreclaimable slab info:
> [  860.720677] Name                      Used          Total
> [  860.722685] scsi_sense_cache          44KB         44KB
> [  860.724517] RAWv6                 237460KB     237460KB
> [  860.726353] TCPv6                    118KB        118KB
> [  860.728183] sgpool-128               192KB        192KB
> [  860.730434] sgpool-16                 64KB         64KB
> [  860.732303] mqueue_inode_cache         31KB         31KB
> [  860.734302] xfs_buf                  584KB        640KB
> [  860.736188] xfs_ili                  134KB        134KB
> [  860.738154] xfs_efd_item             110KB        110KB
> [  860.740163] xfs_trans                 31KB         31KB
> [  860.742707] xfs_ifork                108KB        108KB
> [  860.744781] xfs_da_state              63KB         63KB
> [  860.747019] xfs_btree_cur             31KB         31KB
> [  860.748845] bio-2                     47KB         47KB
> [  860.750647] UNIX                     273KB        273KB
> [  860.752534] RAW                   277018KB     277018KB
> [  860.754339] UDP                    19861KB      19861KB
> [  860.756221] tw_sock_TCP                7KB          7KB
> [  860.758115] request_sock_TCP           7KB          7KB
> [  860.759851] TCP                      120KB        120KB
> [  860.761508] hugetlbfs_inode_cache         63KB         63KB
> [  860.763700] eventpoll_pwq             15KB         15KB
> [  860.765423] inotify_inode_mark         52KB         52KB
> [  860.767707] request_queue             94KB         94KB
> [  860.769379] blkdev_ioc                39KB         39KB
> [  860.771060] biovec-(1<<(21-12))        784KB        912KB
> [  860.772759] biovec-128               192KB        192KB
> [  860.775225] biovec-64                128KB        128KB
> [  860.777187] uid_cache                 15KB         15KB
> [  860.779341] dmaengine-unmap-2         16KB         16KB
> [  860.781330] skbuff_head_cache        184KB        216KB
> [  860.783001] file_lock_cache           31KB         31KB
> [  860.784593] file_lock_ctx             15KB         15KB
> [  860.786172] net_namespace          55270KB      55270KB
> [  860.787706] shmem_inode_cache        980KB        980KB
> [  860.789349] task_delay_info          138KB        179KB
> [  860.791090] taskstats                 23KB         23KB
> [  860.792623] proc_dir_entry        142317KB     142317KB
> [  860.794287] pde_opener                15KB         15KB
> [  860.796069] seq_file                  31KB         31KB
> [  860.797641] sigqueue                  19KB         19KB
> [  860.799060] kernfs_node_cache     173844KB     173844KB
> [  860.800572] mnt_cache                141KB        141KB
> [  860.802101] filp                     656KB        656KB
> [  860.803624] names_cache              256KB        256KB
> [  860.805107] key_jar                   31KB         31KB
> [  860.806655] vm_area_struct          1293KB       1726KB
> [  860.808074] mm_struct                789KB       1012KB
> [  860.809482] files_cache             1330KB       1330KB
> [  860.811777] signal_cache             998KB       1606KB
> [  860.813835] sighand_cache           1610KB       1990KB
> [  860.815698] task_struct             3795KB       4766KB
> [  860.817247] cred_jar                 368KB        460KB
> [  860.818819] anon_vma                1457KB       1747KB
> [  860.820406] pid                     1534KB       2196KB
> [  860.822081] Acpi-Operand             480KB        480KB
> [  860.823955] Acpi-State                27KB         27KB
> [  860.825518] Acpi-Namespace           179KB        179KB
> [  860.827060] numa_policy               15KB         15KB
> [  860.828772] trace_event_file          90KB         90KB
> [  860.830696] ftrace_event_field         95KB         95KB
> [  860.832241] pool_workqueue           144KB        144KB
> [  860.833746] task_group               599KB        630KB
> [  860.835272] page->ptl                362KB        411KB
> [  860.836755] dma-kmalloc-512           16KB         16KB
> [  860.838274] kmalloc-8192          211320KB     211320KB
> [  860.839748] kmalloc-4096          631748KB     631748KB
> [  860.841248] kmalloc-2048          529296KB     529296KB
> [  860.843094] kmalloc-1024           79300KB      79300KB
> [  860.844575] kmalloc-512           192744KB     192744KB
> [  860.847059] kmalloc-256            24292KB      24292KB
> [  860.848747] kmalloc-192            56959KB      56959KB
> [  860.850504] kmalloc-128            77732KB      77732KB
> [  860.852197] kmalloc-96              1426KB       1519KB
> [  860.853936] kmalloc-64             19192KB      19192KB
> [  860.855454] kmalloc-32              1368KB       1368KB
> [  860.856988] kmalloc-16               336KB        336KB
> [  860.858478] kmalloc-8                864KB        864KB
> [  860.859990] kmem_cache_node           20KB         20KB
> [  860.861448] kmem_cache                78KB         78KB
> [  860.863006] Kernel panic - not syncing: Out of memory and no killable processes...
> [  860.863006] 
> [  860.866069] CPU: 3 PID: 1 Comm: systemd Kdump: loaded Tainted: G           O      4.16.0-rc5-next-20180315 #695
> [  860.868829] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
> [  860.871926] Call Trace:
> [  860.872850]  dump_stack+0x5f/0x8b
> [  860.873965]  panic+0xde/0x231
> [  860.875005]  out_of_memory+0x4e4/0x720
> [  860.876218]  __alloc_pages_nodemask+0x12c5/0x1410
> [  860.877645]  filemap_fault+0x479/0x640
> [  860.878842]  __xfs_filemap_fault.constprop.0+0x5f/0x1f0
> [  860.880542]  __do_fault+0x15/0xa0
> [  860.881674]  __handle_mm_fault+0xcb2/0x1140
> [  860.883004]  handle_mm_fault+0x186/0x350
> [  860.884283]  __do_page_fault+0x2a7/0x510
> [  860.885576]  do_page_fault+0x2c/0x2a0
> [  860.886805]  ? page_fault+0x2f/0x50
> [  860.888003]  page_fault+0x45/0x50
> [  860.889169] RIP: 61fa2380:0x55c6609099a0
> ----------------------------------------
