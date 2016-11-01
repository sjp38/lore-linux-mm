Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6AE86B02A6
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 04:16:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 68so56943565wmz.5
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 01:16:45 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id 5si29538282wmv.79.2016.11.01.01.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 01:16:44 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id n67so272044617wme.1
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 01:16:44 -0700 (PDT)
Subject: Re: Softlockup during memory allocation
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <65e53598-8908-208e-add0-a2f52c836154@kyup.com>
Date: Tue, 1 Nov 2016 10:16:42 +0200
MIME-Version: 1.0
In-Reply-To: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>



On 11/01/2016 10:12 AM, Nikolay Borisov wrote:
> Hello, 
> 

I forgot to mention that this is on kernel 4.4.14

> I got the following rcu_sched/soft lockup on a server: 
> 
> [7056389.638502] INFO: rcu_sched self-detected stall on CPU
> [7056389.638509]        21-...: (20994 ticks this GP) idle=9ef/140000000000001/0 softirq=3256767558/3256767596 fqs=6843 
> [7056389.638510]         (t=21001 jiffies g=656551647 c=656551646 q=469247)
> [7056389.638513] Task dump for CPU 21:
> [7056389.638515] hive_exec       R  running task        0  4413  31126 0x0000000a
> [7056389.638518]  ffffffff81c40280 ffff883fff323dc0 ffffffff8107f53d 0000000000000015
> [7056389.638520]  ffffffff81c40280 ffff883fff323dd8 ffffffff81081ce9 0000000000000016
> [7056389.638522]  ffff883fff323e08 ffffffff810aa34b ffff883fff335d00 ffffffff81c40280
> [7056389.638524] Call Trace:
> [7056389.638525]  <IRQ>  [<ffffffff8107f53d>] sched_show_task+0xbd/0x120
> [7056389.638535]  [<ffffffff81081ce9>] dump_cpu_task+0x39/0x40
> [7056389.638539]  [<ffffffff810aa34b>] rcu_dump_cpu_stacks+0x8b/0xc0
> [7056389.638541]  [<ffffffff810ade76>] rcu_check_callbacks+0x4d6/0x7b0
> [7056389.638547]  [<ffffffff810c0a50>] ? tick_init_highres+0x20/0x20
> [7056389.638549]  [<ffffffff810b28b9>] update_process_times+0x39/0x60
> [7056389.638551]  [<ffffffff810c0a9d>] tick_sched_timer+0x4d/0x180
> [7056389.638553]  [<ffffffff810c0a50>] ? tick_init_highres+0x20/0x20
> [7056389.638554]  [<ffffffff810b3197>] __hrtimer_run_queues+0xe7/0x260
> [7056389.638556]  [<ffffffff810b3718>] hrtimer_interrupt+0xa8/0x1a0
> [7056389.638561]  [<ffffffff81034608>] local_apic_timer_interrupt+0x38/0x60
> [7056389.638565]  [<ffffffff81616a7d>] smp_apic_timer_interrupt+0x3d/0x50
> [7056389.638568]  [<ffffffff816151e9>] apic_timer_interrupt+0x89/0x90
> [7056389.638569]  <EOI>  [<ffffffff8113fb4a>] ? shrink_zone+0x28a/0x2a0
> [7056389.638575]  [<ffffffff8113fcd4>] do_try_to_free_pages+0x174/0x460
> [7056389.638579]  [<ffffffff81308415>] ? find_next_bit+0x15/0x20
> [7056389.638581]  [<ffffffff811401e7>] try_to_free_mem_cgroup_pages+0xa7/0x170
> [7056389.638585]  [<ffffffff8118d0ef>] try_charge+0x18f/0x650
> [7056389.638588]  [<ffffffff81087486>] ? update_curr+0x66/0x180
> [7056389.638591]  [<ffffffff811915ed>] mem_cgroup_try_charge+0x7d/0x1c0
> [7056389.638595]  [<ffffffff81128cf2>] __add_to_page_cache_locked+0x42/0x230
> [7056389.638596]  [<ffffffff81128f28>] add_to_page_cache_lru+0x28/0x80
> [7056389.638600]  [<ffffffff812719b2>] ext4_mpage_readpages+0x172/0x820
> [7056389.638603]  [<ffffffff81172d02>] ? alloc_pages_current+0x92/0x120
> [7056389.638608]  [<ffffffff81228ce6>] ext4_readpages+0x36/0x40
> [7056389.638611]  [<ffffffff811374e0>] __do_page_cache_readahead+0x180/0x210
> [7056389.638613]  [<ffffffff8112b1f0>] filemap_fault+0x370/0x400
> [7056389.638615]  [<ffffffff81231716>] ext4_filemap_fault+0x36/0x50
> [7056389.638618]  [<ffffffff8115629f>] __do_fault+0x3f/0xd0
> [7056389.638620]  [<ffffffff8115a205>] handle_mm_fault+0x1245/0x19c0
> [7056389.638622]  [<ffffffff810b2f1a>] ? hrtimer_try_to_cancel+0x1a/0x110
> [7056389.638626]  [<ffffffff810775a2>] ? __might_sleep+0x52/0xb0
> [7056389.638628]  [<ffffffff810b3bdd>] ? hrtimer_nanosleep+0xbd/0x1a0
> [7056389.638631]  [<ffffffff810430bb>] __do_page_fault+0x1ab/0x410
> [7056389.638632]  [<ffffffff8104332c>] do_page_fault+0xc/0x10
> [7056389.638634]  [<ffffffff81616172>] page_fault+0x22/0x30
> 
> Here is the stack of the same process when taken with 'bt' in crash: 
> 
> #0 [ffff8820d5fb3598] __schedule at ffffffff8160fa9a
>  #1 [ffff8820d5fb35e0] preempt_schedule_common at ffffffff8161043f
>  #2 [ffff8820d5fb35f8] _cond_resched at ffffffff8161047c
>  #3 [ffff8820d5fb3608] shrink_page_list at ffffffff8113dd94
>  #4 [ffff8820d5fb36e8] shrink_inactive_list at ffffffff8113eab1
>  #5 [ffff8820d5fb37a8] shrink_lruvec at ffffffff8113f710
>  #6 [ffff8820d5fb38a8] shrink_zone at ffffffff8113f99c
>  #7 [ffff8820d5fb3920] do_try_to_free_pages at ffffffff8113fcd4
>  #8 [ffff8820d5fb39a0] try_to_free_mem_cgroup_pages at ffffffff811401e7
>  #9 [ffff8820d5fb3a10] try_charge at ffffffff8118d0ef
> #10 [ffff8820d5fb3ab0] mem_cgroup_try_charge at ffffffff811915ed
> #11 [ffff8820d5fb3af0] __add_to_page_cache_locked at ffffffff81128cf2
> #12 [ffff8820d5fb3b48] add_to_page_cache_lru at ffffffff81128f28
> #13 [ffff8820d5fb3b70] ext4_mpage_readpages at ffffffff812719b2
> #14 [ffff8820d5fb3c78] ext4_readpages at ffffffff81228ce6
> #15 [ffff8820d5fb3c88] __do_page_cache_readahead at ffffffff811374e0
> #16 [ffff8820d5fb3d30] filemap_fault at ffffffff8112b1f0
> #17 [ffff8820d5fb3d88] ext4_filemap_fault at ffffffff81231716
> #18 [ffff8820d5fb3db0] __do_fault at ffffffff8115629f
> #19 [ffff8820d5fb3e10] handle_mm_fault at ffffffff8115a205
> #20 [ffff8820d5fb3ee8] __do_page_fault at ffffffff810430bb
> #21 [ffff8820d5fb3f40] do_page_fault at ffffffff8104332c
> #22 [ffff8820d5fb3f50] page_fault at ffffffff81616172
> 
> 
> And then multiple softlockups such as : 
> 
> [7056427.875860] Call Trace:
> [7056427.875866]  [<ffffffff8113f92e>] shrink_zone+0x6e/0x2a0
> [7056427.875869]  [<ffffffff8113fcd4>] do_try_to_free_pages+0x174/0x460
> [7056427.875873]  [<ffffffff81308415>] ? find_next_bit+0x15/0x20
> [7056427.875875]  [<ffffffff811401e7>] try_to_free_mem_cgroup_pages+0xa7/0x170
> [7056427.875878]  [<ffffffff8118d0ef>] try_charge+0x18f/0x650
> [7056427.875883]  [<ffffffff81087486>] ? update_curr+0x66/0x180
> [7056427.875885]  [<ffffffff811915ed>] mem_cgroup_try_charge+0x7d/0x1c0
> [7056427.875889]  [<ffffffff81128cf2>] __add_to_page_cache_locked+0x42/0x230
> [7056427.875891]  [<ffffffff81128f28>] add_to_page_cache_lru+0x28/0x80
> [7056427.875894]  [<ffffffff812719b2>] ext4_mpage_readpages+0x172/0x820
> [7056427.875898]  [<ffffffff81172d02>] ? alloc_pages_current+0x92/0x120
> [7056427.875903]  [<ffffffff81228ce6>] ext4_readpages+0x36/0x40
> [7056427.875905]  [<ffffffff811374e0>] __do_page_cache_readahead+0x180/0x210
> [7056427.875907]  [<ffffffff8112b1f0>] filemap_fault+0x370/0x400
> [7056427.875909]  [<ffffffff81231716>] ext4_filemap_fault+0x36/0x50
> [7056427.875912]  [<ffffffff8115629f>] __do_fault+0x3f/0xd0
> [7056427.875915]  [<ffffffff8115a205>] handle_mm_fault+0x1245/0x19c0
> [7056427.875916]  [<ffffffff81190a67>] ? mem_cgroup_oom_synchronize+0x2c7/0x360
> [7056427.875920]  [<ffffffff810430bb>] __do_page_fault+0x1ab/0x410
> [7056427.875921]  [<ffffffff8104332c>] do_page_fault+0xc/0x10
> [7056427.875924]  [<ffffffff81616172>] page_fault+0x22/0x30
> 
> So what happens is that the file system needs memory and kicks in direct page reclaim, 
> however it seems that due to excessive reclaim behavior it locksup in the 
> do { shrink_zones(); }while() in do_try_to_free_pages. However, when I get
> a backtrace from the process, I see that while going through the (in)active lists
> the processes have correctly cond_resched: 
> 
>  #0 [ffff881fe60f3598] __schedule at ffffffff8160fa9a
>  #1 [ffff881fe60f35e0] preempt_schedule_common at ffffffff8161043f
>  #2 [ffff881fe60f35f8] _cond_resched at ffffffff8161047c
>  #3 [ffff881fe60f3608] shrink_page_list at ffffffff8113dd94
>  #4 [ffff881fe60f36e8] shrink_inactive_list at ffffffff8113eab1
>  #5 [ffff881fe60f37a8] shrink_lruvec at ffffffff8113f710
>  #6 [ffff881fe60f38a8] shrink_zone at ffffffff8113f99c
>  #7 [ffff881fe60f3920] do_try_to_free_pages at ffffffff8113fcd4
>  #8 [ffff881fe60f39a0] try_to_free_mem_cgroup_pages at ffffffff811401e7
>  #9 [ffff881fe60f3a10] try_charge at ffffffff8118d0ef
> #10 [ffff881fe60f3ab0] mem_cgroup_try_charge at ffffffff811915ed
> #11 [ffff881fe60f3af0] __add_to_page_cache_locked at ffffffff81128cf2
> #12 [ffff881fe60f3b48] add_to_page_cache_lru at ffffffff81128f28
> #13 [ffff881fe60f3b70] ext4_mpage_readpages at ffffffff812719b2
> #14 [ffff881fe60f3c78] ext4_readpages at ffffffff81228ce6
> #15 [ffff881fe60f3c88] __do_page_cache_readahead at ffffffff811374e0
> #16 [ffff881fe60f3d30] filemap_fault at ffffffff8112b1f0
> #17 [ffff881fe60f3d88] ext4_filemap_fault at ffffffff81231716
> #18 [ffff881fe60f3db0] __do_fault at ffffffff8115629f
> #19 [ffff881fe60f3e10] handle_mm_fault at ffffffff8115a205
> #20 [ffff881fe60f3ee8] __do_page_fault at ffffffff810430bb
> #21 [ffff881fe60f3f40] do_page_fault at ffffffff8104332c
> #22 [ffff881fe60f3f50] page_fault at ffffffff81616172
> 
> Given the state of the page lists there are respectively 30 millions and
> 17 million pages respectively on node 0 and node 1 that direct reclaim 
> should go through. Naturally this takes time, esp on a busy box, however
> the reclaim code seems to have resched points. So I'm perplexed as to 
> why those softlockups materialized. 
> 
> Here's the state of the memory:
> 
>                  PAGES        TOTAL      PERCENTAGE
>     TOTAL MEM  65945937     251.6 GB         ----
>          FREE  1197261       4.6 GB    1% of TOTAL MEM
>          USED  64748676       247 GB   98% of TOTAL MEM
>        SHARED  16603507      63.3 GB   25% of TOTAL MEM
>       BUFFERS  3508833      13.4 GB    5% of TOTAL MEM
>        CACHED  25814634      98.5 GB   39% of TOTAL MEM
>          SLAB  7521229      28.7 GB   11% of TOTAL MEM
> 
>    TOTAL SWAP   262143      1024 MB         ----
>     SWAP USED   262143      1024 MB  100% of TOTAL SWAP
>     SWAP FREE        0            0    0% of TOTAL SWAP
> 
>  COMMIT LIMIT  33235111     126.8 GB         ----
>     COMMITTED  65273273       249 GB  196% of TOTAL LIMIT
> 
> As well as the zone statistics: 
> 
> NODE: 0  ZONE: 2  ADDR: ffff88207fffcf00  NAME: "Normal"
>   SIZE: 33030144  MIN/LOW/HIGH: 22209/27761/33313
>   VM_STAT:
>                 NR_FREE_PAGES: 62436
>                NR_ALLOC_BATCH: 2024
>              NR_INACTIVE_ANON: 8177867
>                NR_ACTIVE_ANON: 5407176
>              NR_INACTIVE_FILE: 5804642
>                NR_ACTIVE_FILE: 9694170
>                NR_UNEVICTABLE: 50013
>                      NR_MLOCK: 59860
>                 NR_ANON_PAGES: 13276046
>                NR_FILE_MAPPED: 969231
>                 NR_FILE_PAGES: 15858085
>                 NR_FILE_DIRTY: 683
>                  NR_WRITEBACK: 530
>           NR_SLAB_RECLAIMABLE: 2688882
>         NR_SLAB_UNRECLAIMABLE: 255070
>                  NR_PAGETABLE: 182007
>               NR_KERNEL_STACK: 8419
>               NR_UNSTABLE_NFS: 0
>                     NR_BOUNCE: 0
>               NR_VMSCAN_WRITE: 1129513
>           NR_VMSCAN_IMMEDIATE: 39497899
>             NR_WRITEBACK_TEMP: 0
>              NR_ISOLATED_ANON: 0
>              NR_ISOLATED_FILE: 462
>                      NR_SHMEM: 331386
>                    NR_DIRTIED: 6868276352
>                    NR_WRITTEN: 5816499568
>              NR_PAGES_SCANNED: -490
>                      NUMA_HIT: 922019911612
>                     NUMA_MISS: 2935289654
>                  NUMA_FOREIGN: 1903827196
>           NUMA_INTERLEAVE_HIT: 57290
>                    NUMA_LOCAL: 922017951068
>                    NUMA_OTHER: 2937250198
>            WORKINGSET_REFAULT: 6998116360
>           WORKINGSET_ACTIVATE: 6033595269
>        WORKINGSET_NODERECLAIM: 2300965
> NR_ANON_TRANSPARENT_HUGEPAGES: 0
>             NR_FREE_CMA_PAGES: 0
> 
> NODE: 1  ZONE: 2  ADDR: ffff88407fff9f00  NAME: "Normal"
>   SIZE: 33554432  MIN/LOW/HIGH: 22567/28208/33850
>   VM_STAT:
>                 NR_FREE_PAGES: 1003922
>                NR_ALLOC_BATCH: 4572
>              NR_INACTIVE_ANON: 7092366
>                NR_ACTIVE_ANON: 6898921
>              NR_INACTIVE_FILE: 4880696
>                NR_ACTIVE_FILE: 8185594
>                NR_UNEVICTABLE: 5311
>                      NR_MLOCK: 25509
>                 NR_ANON_PAGES: 13644139
>                NR_FILE_MAPPED: 790292
>                 NR_FILE_PAGES: 13418055
>                 NR_FILE_DIRTY: 2081
>                  NR_WRITEBACK: 944
>           NR_SLAB_RECLAIMABLE: 3948975
>         NR_SLAB_UNRECLAIMABLE: 546053
>                  NR_PAGETABLE: 207960
>               NR_KERNEL_STACK: 10382
>               NR_UNSTABLE_NFS: 0
>                     NR_BOUNCE: 0
>               NR_VMSCAN_WRITE: 213029
>           NR_VMSCAN_IMMEDIATE: 28902492
>             NR_WRITEBACK_TEMP: 0
>              NR_ISOLATED_ANON: 0
>              NR_ISOLATED_FILE: 23
>                      NR_SHMEM: 327804
>                    NR_DIRTIED: 12275571618
>                    NR_WRITTEN: 11397580462
>              NR_PAGES_SCANNED: -787
>                      NUMA_HIT: 798927158945
>                     NUMA_MISS: 1903827196
>                  NUMA_FOREIGN: 2938097677
>           NUMA_INTERLEAVE_HIT: 57726
>                    NUMA_LOCAL: 798925933393
>                    NUMA_OTHER: 1905052748
>            WORKINGSET_REFAULT: 3461465775
>           WORKINGSET_ACTIVATE: 2724000507
>        WORKINGSET_NODERECLAIM: 4756016
> NR_ANON_TRANSPARENT_HUGEPAGES: 70
>             NR_FREE_CMA_PAGES: 0
> 
> In addition to that I believe there is something wrong
> with the NR_PAGES_SCANNED stats since they are being negative. 
> I haven't looked into the code to see how this value is being 
> synchronized and if there is a possibility of it temporary going negative. 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
