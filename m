Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3F16B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 07:42:59 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r71so207598487ioi.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 04:42:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a28si6802640ote.165.2016.07.15.04.42.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 04:42:57 -0700 (PDT)
Subject: Re: System freezes after OOM
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
 <740b17f0-e1bb-b021-e9e1-ad6dcf5f033a@redhat.com>
 <20160714153120.GD12289@dhcp22.suse.cz>
 <9ca3459a-8226-b870-163e-58e2bb10df74@redhat.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <747214d9-be8c-2bbb-9b19-147541b3d439@I-love.SAKURA.ne.jp>
Date: Fri, 15 Jul 2016 20:42:40 +0900
MIME-Version: 1.0
In-Reply-To: <9ca3459a-8226-b870-163e-58e2bb10df74@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ondrej Kozina <okozina@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On 2016/07/15 2:07, Ondrej Kozina wrote:
> On 07/14/2016 05:31 PM, Michal Hocko wrote:
>> On Thu 14-07-16 16:08:28, Ondrej Kozina wrote:
>> [...]
>>> As Mikulas pointed out, this doesn't work. The system froze as well with the
>>> patch above. Will try to tweak the patch with Mikulas's suggestion...
>>
>> Thank you for testing! Do you happen to have traces of the frozen
>> processes? Does the flusher still gets throttled because the bias it
>> gets is not sufficient. Or does it get throttled at a different place?
>>
> 
> Sure. Here it is (including sysrq+t and sysrq+w output): https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/4.7.0-rc7+/1/4.7.0-rc7+.log
> 

Oh, this resembles another dm-crypt lockup problem reported last month.
( http://lkml.kernel.org/r/20160616212641.GA3308@sig21.net )

In Johannes's case, there are so many pending kcryptd_crypt work requests and
mempool_alloc() is waiting at throttle_vm_writeout() or shrink_inactive_list().

[ 2378.279029] kswapd0         D ffff88003744f538     0   766      2 0x00000000
[ 2378.286167]  ffff88003744f538 00ff88011b5ccd80 ffff88011b5d62d8 ffff88011ae58000
[ 2378.293628]  ffff880037450000 ffff880037450000 00000001000984f2 ffff88003744f570
[ 2378.301168]  ffff88011b5ccd80 ffff880037450000 ffff88003744f550 ffffffff81845cec
[ 2378.308674] Call Trace:
[ 2378.311154]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2378.316153]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2378.322028]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2378.327931]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2378.333960]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2378.340166]  [<ffffffff81162c2b>] mempool_alloc+0x123/0x154
[ 2378.345781]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2378.351148]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2378.356910]  [<ffffffff816342ea>] alloc_tio+0x2d/0x47
[ 2378.361996]  [<ffffffff8163587e>] __split_and_process_bio+0x310/0x3a3
[ 2378.368470]  [<ffffffff81635e15>] dm_make_request+0xb5/0xe2
[ 2378.374078]  [<ffffffff81347ae7>] generic_make_request+0xcc/0x180
[ 2378.380206]  [<ffffffff81347c98>] submit_bio+0xfd/0x145
[ 2378.385482]  [<ffffffff81198948>] __swap_writepage+0x202/0x225
[ 2378.391349]  [<ffffffff810a5eeb>] ? preempt_count_sub+0xf0/0x100
[ 2378.397398]  [<ffffffff8184a5f7>] ? _raw_spin_unlock+0x31/0x44
[ 2378.403273]  [<ffffffff8119a903>] ? page_swapcount+0x45/0x4c
[ 2378.408984]  [<ffffffff811989a5>] swap_writepage+0x3a/0x3e
[ 2378.414530]  [<ffffffff811727ef>] pageout.isra.16+0x160/0x2a7
[ 2378.420320]  [<ffffffff81173a8f>] shrink_page_list+0x5a0/0x8c4
[ 2378.426197]  [<ffffffff81174489>] shrink_inactive_list+0x29e/0x4a1
[ 2378.432434]  [<ffffffff81174e8b>] shrink_zone_memcg+0x4c1/0x661
[ 2378.438406]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2378.443742]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2378.449238]  [<ffffffff8117628f>] kswapd+0x6df/0x814
[ 2378.454222]  [<ffffffff81175bb0>] ? mem_cgroup_shrink_node_zone+0x209/0x209
[ 2378.461196]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2378.466182]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2378.471631]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea

[ 2378.769494] kworker/u8:4    D ffff8800c5dc3508     0  1592      2 0x00000000
[ 2378.776582] Workqueue: kcryptd kcryptd_crypt
[ 2378.780887]  ffff8800c5dc3508 00ff88011b7ccd80 ffff88011b7d62d8 ffff88011ae5a900
[ 2378.788399]  ffff88011a605200 ffff8800c5dc4000 00000001000983f7 ffff8800c5dc3540
[ 2378.795930]  ffff88011b7ccd80 0000000000000000 ffff8800c5dc3520 ffffffff81845cec
[ 2378.803408] Call Trace:
[ 2378.805879]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2378.810908]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2378.816783]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2378.822677]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2378.828716]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2378.834956]  [<ffffffff8117d5c0>] congestion_wait+0x84/0x160
[ 2378.840658]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2378.845997]  [<ffffffff8116c32f>] throttle_vm_writeout+0x88/0xab
[ 2378.852036]  [<ffffffff81174fff>] shrink_zone_memcg+0x635/0x661
[ 2378.857982]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2378.863309]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2378.868832]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2378.875028]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2378.880972]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2378.887385]  [<ffffffff8138027a>] ? debug_smp_processor_id+0x17/0x19
[ 2378.893782]  [<ffffffff8119fb2a>] new_slab+0xbc/0x3bb
[ 2378.898868]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2378.905634]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2378.911659]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2378.916909]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2378.922325]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2378.928877]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2378.934138]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2378.939555]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2378.946125]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2378.953289]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2378.960630]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2378.966706]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2378.972503]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2378.978567]  [<ffffffff81162a88>] mempool_alloc_slab+0x15/0x17
[ 2378.984426]  [<ffffffff81162b7a>] mempool_alloc+0x72/0x154
[ 2378.989930]  [<ffffffff810c4b45>] ? lockdep_init_map+0xc9/0x5a3
[ 2378.995866]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2379.001300]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2379.007107]  [<ffffffff81643127>] kcryptd_crypt+0x1ab/0x325
[ 2379.012704]  [<ffffffff810998fd>] ? process_one_work+0x1ad/0x4e2
[ 2379.018753]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2379.024629]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2379.030851]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2379.036423]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2379.042309]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2379.047310]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2379.052726]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea

[ 2379.059328] kworker/u8:6    D ffff8800c5ec3508     0  1594      2 0x00000000
[ 2379.066468] Workqueue: kcryptd kcryptd_crypt
[ 2379.070808]  ffff8800c5ec3508 00ff88011b7ccd80 ffff88011b7d62d8 ffff88011ae5a900
[ 2379.078296]  ffff88003749a900 ffff8800c5ec4000 0000000100098467 ffff8800c5ec3540
[ 2379.085836]  ffff88011b7ccd80 0000000000000000 ffff8800c5ec3520 ffffffff81845cec
[ 2379.093315] Call Trace:
[ 2379.095776]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2379.100785]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2379.106627]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2379.112494]  [<ffffffff81845070>] io_schedule_timeout+0xa0/0x102
[ 2379.118524]  [<ffffffff81845070>] ? io_schedule_timeout+0xa0/0x102
[ 2379.124740]  [<ffffffff8117d5c0>] congestion_wait+0x84/0x160
[ 2379.130432]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2379.135771]  [<ffffffff8116c32f>] throttle_vm_writeout+0x88/0xab
[ 2379.141839]  [<ffffffff81174fff>] shrink_zone_memcg+0x635/0x661
[ 2379.147810]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2379.153155]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2379.158651]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2379.164881]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2379.170861]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2379.177292]  [<ffffffff811a1776>] ? get_partial_node.isra.19+0x353/0x3af
[ 2379.184026]  [<ffffffff8119fb2a>] new_slab+0xbc/0x3bb
[ 2379.189103]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2379.195843]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2379.201895]  [<ffffffff81049da2>] ? glue_xts_crypt_128bit+0x1a6/0x1d8
[ 2379.208357]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2379.213610]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2379.219050]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2379.225596]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2379.232769]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2379.240143]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2379.246177]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2379.251957]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2379.258024]  [<ffffffff81162a88>] mempool_alloc_slab+0x15/0x17
[ 2379.263907]  [<ffffffff81162b7a>] mempool_alloc+0x72/0x154
[ 2379.269403]  [<ffffffff810c4b45>] ? lockdep_init_map+0xc9/0x5a3
[ 2379.275354]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2379.280754]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2379.286535]  [<ffffffff81643127>] kcryptd_crypt+0x1ab/0x325
[ 2379.292143]  [<ffffffff810998fd>] ? process_one_work+0x1ad/0x4e2
[ 2379.298208]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2379.304117]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2379.310341]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2379.315946]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2379.321840]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2379.326825]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2379.332299]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea

[ 2385.193584] kworker/u8:1    D ffff880022e634b8     0  2342      2 0x00000000
[ 2385.200692] Workqueue: kcryptd kcryptd_crypt
[ 2385.205023]  ffff880022e634b8 00ff88011b3ccd80 ffff88011b3d62d8 ffff88011ae45200
[ 2385.212554]  ffff88011a472900 ffff880022e64000 0000000100098b0a ffff880022e634f0
[ 2385.220052]  ffff88011b3ccd80 ffff8800c5b19350 ffff880022e634d0 ffffffff81845cec
[ 2385.227547] Call Trace:
[ 2385.230002]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2385.235001]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2385.240893]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2385.246787]  [<ffffffff81849c33>] schedule_timeout_uninterruptible+0x1e/0x20
[ 2385.253858]  [<ffffffff81849c33>] ? schedule_timeout_uninterruptible+0x1e/0x20
[ 2385.261140]  [<ffffffff8117d72e>] wait_iff_congested+0x92/0x1b4
[ 2385.267083]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2385.272448]  [<ffffffff811745c7>] shrink_inactive_list+0x3dc/0x4a1
[ 2385.278662]  [<ffffffff81174e8b>] shrink_zone_memcg+0x4c1/0x661
[ 2385.284643]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2385.290006]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2385.295518]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2385.301739]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2385.307710]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2385.314097]  [<ffffffff8138027a>] ? debug_smp_processor_id+0x17/0x19
[ 2385.320509]  [<ffffffff8119fb2a>] new_slab+0xbc/0x3bb
[ 2385.325598]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2385.332320]  [<ffffffff8138027a>] ? debug_smp_processor_id+0x17/0x19
[ 2385.338726]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2385.344784]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2385.350052]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2385.355494]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2385.362063]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2385.369247]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2385.376630]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2385.382689]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2385.388493]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2385.394544]  [<ffffffff81162a88>] mempool_alloc_slab+0x15/0x17
[ 2385.400410]  [<ffffffff81162b7a>] mempool_alloc+0x72/0x154
[ 2385.405915]  [<ffffffff810c4b45>] ? lockdep_init_map+0xc9/0x5a3
[ 2385.411875]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2385.417311]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2385.423082]  [<ffffffff81643127>] kcryptd_crypt+0x1ab/0x325
[ 2385.428704]  [<ffffffff810998fd>] ? process_one_work+0x1ad/0x4e2
[ 2385.434771]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2385.440664]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2385.446904]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2385.452510]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2385.458385]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2385.463379]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2385.468776]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea

[ 2386.089621] kworker/u8:0    D ffff88010cd434b8     0 15543      2 0x00000000
[ 2386.096770] Workqueue: kcryptd kcryptd_crypt
[ 2386.101060]  ffff88010cd434b8 00ff88011b1ccd80 ffff88011b1d62d8 ffffffff81e1d540
[ 2386.108598]  ffff8800c00ca900 ffff88010cd44000 00000001000982fe ffff88010cd434f0
[ 2386.116102]  ffff88011b1ccd80 ffff8800c5b19350 ffff88010cd434d0 ffffffff81845cec
[ 2386.123651] Call Trace:
[ 2386.126132]  [<ffffffff81845cec>] schedule+0x8b/0xa3
[ 2386.131167]  [<ffffffff81849b5b>] schedule_timeout+0x20b/0x285
[ 2386.137017]  [<ffffffff810e6da6>] ? init_timer_key+0x112/0x112
[ 2386.142902]  [<ffffffff81849c33>] schedule_timeout_uninterruptible+0x1e/0x20
[ 2386.149999]  [<ffffffff81849c33>] ? schedule_timeout_uninterruptible+0x1e/0x20
[ 2386.157271]  [<ffffffff8117d72e>] wait_iff_congested+0x92/0x1b4
[ 2386.163258]  [<ffffffff810bdd00>] ? wait_woken+0x72/0x72
[ 2386.168622]  [<ffffffff811745c7>] shrink_inactive_list+0x3dc/0x4a1
[ 2386.174862]  [<ffffffff81174e8b>] shrink_zone_memcg+0x4c1/0x661
[ 2386.180834]  [<ffffffff81175107>] shrink_zone+0xdc/0x1e5
[ 2386.186154]  [<ffffffff81175107>] ? shrink_zone+0xdc/0x1e5
[ 2386.191691]  [<ffffffff811753b5>] do_try_to_free_pages+0x1a5/0x2c3
[ 2386.197931]  [<ffffffff811755f6>] try_to_free_pages+0x123/0x21f
[ 2386.203893]  [<ffffffff81168216>] __alloc_pages_nodemask+0x4c9/0x978
[ 2386.210314]  [<ffffffff811a1776>] ? get_partial_node.isra.19+0x353/0x3af
[ 2386.217057]  [<ffffffff8119fb97>] new_slab+0x129/0x3bb
[ 2386.222246]  [<ffffffff811a1acd>] ___slab_alloc.constprop.22+0x2fb/0x37b
[ 2386.228979]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2386.235039]  [<ffffffff81049da2>] ? glue_xts_crypt_128bit+0x1a6/0x1d8
[ 2386.241529]  [<ffffffff8101f5ba>] ? sched_clock+0x9/0xd
[ 2386.246790]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2386.252248]  [<ffffffff810c6438>] ? __lock_acquire.isra.16+0x55e/0xb4c
[ 2386.258863]  [<ffffffff811a1ba4>] __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2386.266027]  [<ffffffff811a1ba4>] ? __slab_alloc.isra.17.constprop.21+0x57/0x8b
[ 2386.273358]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2386.279383]  [<ffffffff811a1c78>] kmem_cache_alloc+0xa0/0x1d6
[ 2386.285196]  [<ffffffff81162a88>] ? mempool_alloc_slab+0x15/0x17
[ 2386.291246]  [<ffffffff81162a88>] mempool_alloc_slab+0x15/0x17
[ 2386.297146]  [<ffffffff81162b7a>] mempool_alloc+0x72/0x154
[ 2386.302669]  [<ffffffff810c4b45>] ? lockdep_init_map+0xc9/0x5a3
[ 2386.308622]  [<ffffffff810ae420>] ? local_clock+0x20/0x22
[ 2386.314073]  [<ffffffff8133fdc1>] bio_alloc_bioset+0xe8/0x1d7
[ 2386.319843]  [<ffffffff81643127>] kcryptd_crypt+0x1ab/0x325
[ 2386.325443]  [<ffffffff810998fd>] ? process_one_work+0x1ad/0x4e2
[ 2386.331482]  [<ffffffff810999d3>] process_one_work+0x283/0x4e2
[ 2386.337331]  [<ffffffff810c502d>] ? put_lock_stats.isra.9+0xe/0x20
[ 2386.343528]  [<ffffffff8109a860>] worker_thread+0x285/0x370
[ 2386.349143]  [<ffffffff8109a5db>] ? rescuer_thread+0x2d1/0x2d1
[ 2386.355055]  [<ffffffff8109f208>] kthread+0xff/0x107
[ 2386.360048]  [<ffffffff8184b1f2>] ret_from_fork+0x22/0x50
[ 2386.365471]  [<ffffffff8109f109>] ? kthread_create_on_node+0x1ea/0x1ea

[ 2419.047134] workqueue kcryptd: flags=0x2a
[ 2419.051178]   pwq 8: cpus=0-3 flags=0x4 nice=0 active=4/4
[ 2419.056687]     in-flight: 1592:kcryptd_crypt, 1594:kcryptd_crypt, 2342:kcryptd_crypt, 15543:kcryptd_crypt
[ 2419.066479]     delayed: kcryptd_crypt, kcryptd_crypt, (...snipped...) kcryptd_crypt, (...too long to finish...)

Why can't we stop queuing so many kcryptd_crypt work requests?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
