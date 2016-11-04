Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 210E428026C
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 08:18:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n67so15552164wme.7
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 05:18:56 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id 191si4741076wmh.55.2016.11.04.05.18.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 05:18:53 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id p190so47259775wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 05:18:52 -0700 (PDT)
Subject: Re: Softlockup during memory allocation
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <a73f4917-48ac-bf1e-04d9-64fb937abfc6@kyup.com>
Date: Fri, 4 Nov 2016 14:18:49 +0200
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

So after further debugging the following seems to be a better representation of what's happened: 

So the softlockup for a task is as follows: 

[7056427.875372] NMI watchdog: BUG: soft lockup - CPU#17 stuck for 22s! [nginx:47108]
[7056427.875832] CPU: 17 PID: 47108 Comm: nginx Tainted: G        W  O  K 4.4.14-clouder5 #2
[7056427.875833] Hardware name: Supermicro PIO-628U-TR4T+-ST031/X10DRU-i+, BIOS 1.0c 03/23/2015
[7056427.875835] task: ffff88208a06d280 ti: ffff88235af70000 task.ti: ffff88235af70000
[7056427.875836] RIP: 0010:[<ffffffff8118dbf3>]  [<ffffffff8118dbf3>] mem_cgroup_iter+0x33/0x3e0
[7056427.875844] RSP: 0018:ffff88235af73868  EFLAGS: 00000246
[7056427.875845] RAX: 0000000000000005 RBX: ffff88235af739a8 RCX: ffff88207fffc000
[7056427.875846] RDX: ffff88235af738e0 RSI: 0000000000000000 RDI: ffff8823990d1400
[7056427.875847] RBP: ffff88235af738a0 R08: 0000000000000000 R09: 0000000001d0df03
[7056427.875848] R10: 28f5c28f5c28f5c3 R11: 0000000000000000 R12: ffff8823990d1400
[7056427.875849] R13: ffff8823990d1400 R14: 0000000000000000 R15: ffff88407fffae30
[7056427.875850] FS:  00007f8cdee26720(0000) GS:ffff883fff2a0000(0000) knlGS:0000000000000000
[7056427.875851] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[7056427.875852] CR2: 00007f4d199780e0 CR3: 0000002e0b4e3000 CR4: 00000000001406e0
[7056427.875853] Stack:
[7056427.875854]  00ff8823990d1598 ffff88235af738a0 ffff88235af739a8 ffff8823990d1400
[7056427.875856]  0000000000000000 ffff88207fffc000 ffff88407fffae30 ffff88235af73918
[7056427.875858]  ffffffff8113f92e 0000000000000000 0000000000000000 0000000000000000
[7056427.875860] Call Trace:
[7056427.875866]  [<ffffffff8113f92e>] shrink_zone+0x6e/0x2a0
[7056427.875869]  [<ffffffff8113fcd4>] do_try_to_free_pages+0x174/0x460
[7056427.875873]  [<ffffffff81308415>] ? find_next_bit+0x15/0x20
[7056427.875875]  [<ffffffff811401e7>] try_to_free_mem_cgroup_pages+0xa7/0x170
[7056427.875878]  [<ffffffff8118d0ef>] try_charge+0x18f/0x650
[7056427.875883]  [<ffffffff81087486>] ? update_curr+0x66/0x180
[7056427.875885]  [<ffffffff811915ed>] mem_cgroup_try_charge+0x7d/0x1c0
[7056427.875889]  [<ffffffff81128cf2>] __add_to_page_cache_locked+0x42/0x230
[7056427.875891]  [<ffffffff81128f28>] add_to_page_cache_lru+0x28/0x80
[7056427.875894]  [<ffffffff812719b2>] ext4_mpage_readpages+0x172/0x820
[7056427.875898]  [<ffffffff81172d02>] ? alloc_pages_current+0x92/0x120
[7056427.875903]  [<ffffffff81228ce6>] ext4_readpages+0x36/0x40
[7056427.875905]  [<ffffffff811374e0>] __do_page_cache_readahead+0x180/0x210
[7056427.875907]  [<ffffffff8112b1f0>] filemap_fault+0x370/0x400
[7056427.875909]  [<ffffffff81231716>] ext4_filemap_fault+0x36/0x50
[7056427.875912]  [<ffffffff8115629f>] __do_fault+0x3f/0xd0
[7056427.875915]  [<ffffffff8115a205>] handle_mm_fault+0x1245/0x19c0
[7056427.875916]  [<ffffffff81190a67>] ? mem_cgroup_oom_synchronize+0x2c7/0x360
[7056427.875920]  [<ffffffff810430bb>] __do_page_fault+0x1ab/0x410
[7056427.875921]  [<ffffffff8104332c>] do_page_fault+0xc/0x10
[7056427.875924]  [<ffffffff81616172>] page_fault+0x22/0x30


ffffffff8118dbf3 is mem_cgroup_iter called from shrink_zone but in the outer do {} while. However, 
after crashing the machine via sysrq and looking at the callstack for the same process looks like:

#0 [ffff88235af73598] __schedule at ffffffff8160fa9a
 #1 [ffff88235af735e0] preempt_schedule_common at ffffffff8161043f
 #2 [ffff88235af735f8] _cond_resched at ffffffff8161047c
 #3 [ffff88235af73608] shrink_page_list at ffffffff8113dd94
 #4 [ffff88235af736e8] shrink_inactive_list at ffffffff8113eab1
 #5 [ffff88235af737a8] shrink_lruvec at ffffffff8113f710
 #6 [ffff88235af738a8] shrink_zone at ffffffff8113f99c
 #7 [ffff88235af73920] do_try_to_free_pages at ffffffff8113fcd4
 #8 [ffff88235af739a0] try_to_free_mem_cgroup_pages at ffffffff811401e7
 #9 [ffff88235af73a10] try_charge at ffffffff8118d0ef
#10 [ffff88235af73ab0] mem_cgroup_try_charge at ffffffff811915ed
#11 [ffff88235af73af0] __add_to_page_cache_locked at ffffffff81128cf2
#12 [ffff88235af73b48] add_to_page_cache_lru at ffffffff81128f28
#13 [ffff88235af73b70] ext4_mpage_readpages at ffffffff812719b2
#14 [ffff88235af73c78] ext4_readpages at ffffffff81228ce6
#15 [ffff88235af73c88] __do_page_cache_readahead at ffffffff811374e0
#16 [ffff88235af73d30] filemap_fault at ffffffff8112b1f0
#17 [ffff88235af73d88] ext4_filemap_fault at ffffffff81231716
#18 [ffff88235af73db0] __do_fault at ffffffff8115629f
#19 [ffff88235af73e10] handle_mm_fault at ffffffff8115a205
#20 [ffff88235af73ee8] __do_page_fault at ffffffff810430bb
#21 [ffff88235af73f40] do_page_fault at ffffffff8104332c
#22 [ffff88235af73f50] page_fault at ffffffff81616172

This is the shrink_lruvec in the inner do {} while

So clearly the same task has made some progress and has even 
re-scheduled due to the cond_resched in shrink_page_list. 
This means that in order for the softlockup to be triggered 
in shrink_zone this means that the code after the inner while 
should've taken more than 22 seconds (the time out for the s
oftlockup watchdog). The function which are there are 
shrink_slab (but this seems to have the necessary cond_resched 
in its callees e.g. do_shrink_slab) and vmpressure - this is very lightweight. 

So it's still puzzling how come the softlockup is triggered in shrink_zone, when
there in fact is plenty of opportunity to resched while scanning the lists

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
