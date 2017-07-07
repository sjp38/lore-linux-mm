Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 967A16B02C3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 06:27:21 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 188so42977462itx.9
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 03:27:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o196si3049773itg.90.2017.07.07.03.27.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 03:27:18 -0700 (PDT)
Subject: Re: mm: Why WQ_MEM_RECLAIM workqueue remains pending?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201706291957.JGH39511.tQMOFSLOFJVHOF@I-love.SAKURA.ne.jp>
In-Reply-To: <201706291957.JGH39511.tQMOFSLOFJVHOF@I-love.SAKURA.ne.jp>
Message-Id: <201707071927.IGG34813.tSQOMJFOHOFVLF@I-love.SAKURA.ne.jp>
Date: Fri, 7 Jul 2017 19:27:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net, tj@kernel.org, vbabka@suse.cz, linux-mm@kvack.org
Cc: hillf.zj@alibaba-inc.com, brouer@redhat.com

Tetsuo Handa wrote:
> I haven't succeeded reproducing mm_percpu_wq with this patch applied.

OK. I succeeded reproducing mm_percpu_wq with this patch applied.
I confirmed that drain_local_pages_wq is indeed stalling for minutes
when all allocations got stuck (i.e. CPU usage is nearly 0%).

Why WQ_MEM_RECLAIM workqueue does not process pending works?

    mm_percpu_wq = alloc_workqueue("mm_percpu_wq", WQ_MEM_RECLAIM, 0);

Aren't we missing yet another basic something in addition to
http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp ?



Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170707.txt.xz .
----------
[  444.140700] mm_percpu_wq    S14768     6      2 0x00000000
[  444.142793] Call Trace:
[  444.143893]  __schedule+0x23f/0x5d0
[  444.145346]  schedule+0x31/0x80
[  444.146656]  rescuer_thread+0x343/0x390
[  444.148211]  kthread+0xff/0x140
[  444.149555]  ? worker_thread+0x410/0x410
[  444.151101]  ? kthread_create_on_node+0x60/0x60
[  444.152973]  ret_from_fork+0x25/0x30
(...snipped...)
[  465.086921] c.out           D12296  4561   4382 0x00000080
[  465.089063] Call Trace:
[  465.090251]  __schedule+0x23f/0x5d0
[  465.091745]  ? update_load_avg+0x406/0x4f0
[  465.093381]  schedule+0x31/0x80
[  465.094769]  schedule_timeout+0x1c1/0x290
[  465.096434]  ? pick_next_task_fair+0x431/0x520
[  465.098210]  ? __switch_to+0x23d/0x3b0
[  465.099779]  wait_for_completion+0xaf/0x140
[  465.101482]  ? wait_for_completion+0xaf/0x140
[  465.103206]  ? wake_up_q+0x70/0x70
[  465.104764]  flush_work+0x145/0x210
[  465.106295]  ? worker_detach_from_pool+0xa0/0xa0
[  465.108096]  drain_all_pages+0x1e5/0x250
[  465.109715]  __alloc_pages_slowpath+0x498/0xd50
[  465.111513]  __alloc_pages_nodemask+0x20c/0x250
[  465.113285]  alloc_pages_current+0x65/0xd0
[  465.114982]  new_slab+0x472/0x600
[  465.116521]  ___slab_alloc+0x41b/0x590
[  465.118160]  ? kmem_alloc+0x8a/0x110 [xfs]
[  465.119965]  ? kmem_alloc+0x8a/0x110 [xfs]
[  465.121672]  __slab_alloc+0x1b/0x30
[  465.123125]  ? __save_stack_trace+0x70/0xf0
[  465.124839]  ? __slab_alloc+0x1b/0x30
[  465.126388]  __kmalloc+0x17e/0x200
[  465.127820]  kmem_alloc+0x8a/0x110 [xfs]
[  465.129677]  xfs_iext_inline_to_direct+0x1f/0x80 [xfs]
[  465.131668]  xfs_iext_realloc_direct+0xc6/0x140 [xfs]
[  465.133591]  xfs_iext_add+0x196/0x2e0 [xfs]
[  465.135294]  xfs_iext_insert+0x37/0xa0 [xfs]
[  465.137021]  xfs_bmap_add_extent_hole_delay+0xff/0x510 [xfs]
[  465.139216]  ? free_debug_processing+0x251/0x3a0
[  465.141015]  ? xfs_mod_fdblocks+0xa1/0x1a0 [xfs]
[  465.142863]  xfs_bmapi_reserve_delalloc+0x282/0x340 [xfs]
[  465.145080]  xfs_file_iomap_begin+0x574/0x750 [xfs]
[  465.146980]  ? iomap_write_begin.constprop.16+0x120/0x120
[  465.149042]  iomap_apply+0x55/0x110
[  465.150482]  ? iomap_write_begin.constprop.16+0x120/0x120
[  465.152568]  iomap_file_buffered_write+0x69/0x90
[  465.154466]  ? iomap_write_begin.constprop.16+0x120/0x120
[  465.156604]  xfs_file_buffered_aio_write+0xb7/0x200 [xfs]
[  465.158668]  xfs_file_write_iter+0x8d/0x130 [xfs]
[  465.160526]  __vfs_write+0xef/0x150
[  465.161972]  vfs_write+0xb0/0x190
[  465.163361]  SyS_write+0x50/0xc0
[  465.164762]  do_syscall_64+0x62/0x140
[  465.166290]  entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  541.104151] Showing busy workqueues and worker pools:
[  541.106286] workqueue events: flags=0x0
[  541.107928]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  541.110294]     pending: console_callback{132766}, vmw_fb_dirty_flush [vmwgfx]{110231}, sysrq_reinject_alt_sysrq{109775}, push_to_pool{97580}
[  541.114924]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  541.117355]     pending: e1000_watchdog [e1000]{143326}, check_corruption{101853}
[  541.120297]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  541.122756]     pending: vmpressure_work_fn{144398}, e1000_watchdog [e1000]{142948}
[  541.125759]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  541.128121]     pending: vmstat_shepherd{143401}
[  541.129990] workqueue events_long: flags=0x0
[  541.131838]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  541.134258]     pending: gc_worker [nf_conntrack]{144295}
[  541.136561] workqueue events_freezable: flags=0x4
[  541.138588]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  541.141037]     pending: vmballoon_work [vmw_balloon]{143414}
[  541.143428] workqueue events_power_efficient: flags=0x80
[  541.145661]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  541.148083]     pending: neigh_periodic_work{134652}
[  541.150237]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  541.152722]     pending: fb_flashcursor{144370}, do_cache_clean{137210}
[  541.155409]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  541.157936]     pending: neigh_periodic_work{130557}
[  541.160062] workqueue events_freezable_power_: flags=0x84
[  541.162356]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  541.164910]     pending: disk_events_workfn{143950}
[  541.167097] workqueue mm_percpu_wq: flags=0x8
[  541.169071]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  541.171570]     pending: vmstat_update{143444}
[  541.173543]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  541.176035]     pending: vmstat_update{143441}
[  541.177987]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  541.180506]     pending: drain_local_pages_wq{144380} BAR(4561){144380}
[  541.183292] workqueue writeback: flags=0x4e
[  541.185241]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[  541.187726]     in-flight: 354:wb_workfn{118308}
[  541.190206] workqueue ipv6_addrconf: flags=0x40008
[  541.192376]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/1 MAYDAY
[  541.195062]     pending: addrconf_verify_work{28203}
[  541.197343] workqueue mpt_poll_0: flags=0x8
[  541.199364]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  541.202015]     pending: mpt_fault_reset_work [mptbase]{143283}
[  541.204580] workqueue xfs-buf/sda1: flags=0xc
[  541.206656]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/1
[  541.209152]     pending: xfs_buf_ioend_work [xfs]{144349}
[  541.211588]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/1
[  541.214141]     pending: xfs_buf_ioend_work [xfs]{144317}
[  541.216590]     delayed: xfs_buf_ioend_work [xfs]{144273}, xfs_buf_ioend_work [xfs]{144267}, xfs_buf_ioend_work [xfs]{144267}
[  541.220929] workqueue xfs-data/sda1: flags=0xc
[  541.223026]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=22/256
[  541.225602]     in-flight: 3221:xfs_end_io [xfs]{144401}, 3212:xfs_end_io [xfs]{144518}, 29:xfs_end_io [xfs]{144560}, 3230:xfs_end_io [xfs]{144531}, 3229:xfs_end_io [xfs]{144459}, 50:xfs_end_io [xfs]{144459}, 3223:xfs_end_io [xfs]{144405}, 165:xfs_end_io [xfs]{144413}, 3215:xfs_end_io [xfs]{144407}
[  541.235455]     pending: xfs_end_io [xfs]{144374}, xfs_end_io [xfs]{144370}, xfs_end_io [xfs]{144370}, xfs_end_io [xfs]{144362}, xfs_end_io [xfs]{144340}, xfs_end_io [xfs]{144338}, xfs_end_io [xfs]{144333}, xfs_end_io [xfs]{144326}, xfs_end_io [xfs]{144326}, xfs_end_io [xfs]{144313}, xfs_end_io [xfs]{144311}, xfs_end_io [xfs]{144311}, xfs_end_io [xfs]{144309}
[  541.247828]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=27/256 MAYDAY
[  541.250691]     in-flight: 3225:xfs_end_io [xfs]{144613}, 236:xfs_end_io [xfs]{144527}, 23:xfs_end_io [xfs]{144515}, 3228:xfs_end_io [xfs]{144515}, 4380:xfs_end_io [xfs]{144623}, 3214:xfs_end_io [xfs]{144604}, 3220:xfs_end_io [xfs]{144576}, 3227:xfs_end_io [xfs]{144597}
[  541.259961]     pending: xfs_end_io [xfs]{144524}, xfs_end_io [xfs]{144514}, xfs_end_io [xfs]{144493}, xfs_end_io [xfs]{144493}, xfs_end_io [xfs]{144493}, xfs_end_io [xfs]{144493}, xfs_end_io [xfs]{144493}, xfs_end_io [xfs]{144481}, xfs_end_io [xfs]{144475}, xfs_end_io [xfs]{144461}, xfs_end_io [xfs]{144461}, xfs_end_io [xfs]{144457}, xfs_end_io [xfs]{144447}, xfs_end_io [xfs]{144426}, xfs_end_io [xfs]{144423}, xfs_end_io [xfs]{144416}, xfs_end_io [xfs]{144405}, xfs_end_io [xfs]{144386}, xfs_end_io [xfs]{144379}
[  541.278219]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=24/256 MAYDAY
[  541.281279]     in-flight: 375(RESCUER):xfs_end_io [xfs]{144555}, 42:xfs_end_io [xfs]{144639}, 3222:xfs_end_io [xfs]{144647}, 17:xfs_end_io [xfs]{144556}, 65:xfs_end_io [xfs]{144602}, 122:xfs_end_io [xfs]{144591}
[  541.289186]     pending: xfs_end_io [xfs]{144549}, xfs_end_io [xfs]{144516}, xfs_end_io [xfs]{144475}, xfs_end_io [xfs]{144450}, xfs_end_io [xfs]{144443}, xfs_end_io [xfs]{144433}, xfs_end_io [xfs]{144432}, xfs_end_io [xfs]{144429}, xfs_end_io [xfs]{144424}, xfs_end_io [xfs]{144415}, xfs_end_io [xfs]{144413}, xfs_end_io [xfs]{144409}, xfs_end_io [xfs]{144394}, xfs_end_io [xfs]{144389}, xfs_end_io [xfs]{144379}, xfs_end_io [xfs]{144378}, xfs_end_io [xfs]{144376}, xfs_end_io [xfs]{144373}
[  541.307292]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=13/256
[  541.310168]     in-flight: 3218:xfs_end_io [xfs]{144631}, 3216:xfs_end_io [xfs]{144628}, 3:xfs_end_io [xfs]{144586}, 33:xfs_end_io [xfs]{144544}, 101:xfs_end_io [xfs]{144522}, 4381:xfs_end_io [xfs]{144657}, 3219:xfs_end_io [xfs]{144544}
[  541.319071]     pending: xfs_end_io [xfs]{144516}, xfs_end_io [xfs]{144508}, xfs_end_io [xfs]{144500}, xfs_end_io [xfs]{144424}, xfs_end_io [xfs]{144393}, xfs_end_io [xfs]{144392}
[  541.326402] workqueue xfs-reclaim/sda1: flags=0xc
[  541.329042]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  541.332094]     pending: xfs_reclaim_worker [xfs]{143541}
[  541.334909] workqueue xfs-sync/sda1: flags=0x4
[  541.337455]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  541.340467]     pending: xfs_log_worker [xfs]{137404}
[  541.343145] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=144s workers=8 manager: 3224
[  541.346676] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=144s workers=6 manager: 3213
[  541.350074] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=144s workers=9 manager: 47
[  541.353556] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=144s workers=10 manager: 3217
[  541.357194] pool 128: cpus=0-63 flags=0x4 nice=0 hung=118s workers=3 idle: 355 356
[  574.951090] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 178s!
[  574.965692] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 178s!
[  574.978062] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 178s!
[  574.990564] BUG: workqueue lockup - pool cpus=3 node=0 flags=0x0 nice=0 stuck for 33s!
[  574.995614] Showing busy workqueues and worker pools:
[  574.999262] workqueue events: flags=0x0
[  575.002637]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  575.006859]     pending: console_callback{166657}, vmw_fb_dirty_flush [vmwgfx]{144122}, sysrq_reinject_alt_sysrq{143666}, push_to_pool{131471}
[  575.013957]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  575.018004]     pending: e1000_watchdog [e1000]{177225}, check_corruption{135752}
[  575.022236]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  575.025090]     pending: vmpressure_work_fn{178298}, e1000_watchdog [e1000]{176848}
[  575.028448]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  575.031276]     pending: vmstat_shepherd{177304}
[  575.033687] workqueue events_long: flags=0x0
[  575.035960]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.038732]     pending: gc_worker [nf_conntrack]{178192}
[  575.041299] workqueue events_freezable: flags=0x4
[  575.043747]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  575.046476]     pending: vmballoon_work [vmw_balloon]{177314}
[  575.049136] workqueue events_power_efficient: flags=0x80
[  575.051623]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  575.054292]     pending: check_lifetime{33686}
[  575.056478]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.059110]     pending: neigh_periodic_work{168560}
[  575.061404]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  575.064070]     pending: fb_flashcursor{178280}, do_cache_clean{171120}
[  575.066866]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  575.069442]     pending: neigh_periodic_work{164462}
[  575.071709] workqueue events_freezable_power_: flags=0x84
[  575.074100]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.076610]     pending: disk_events_workfn{177856}
[  575.078806] workqueue mm_percpu_wq: flags=0x8
[  575.080807]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.083278]     pending: vmstat_update{177346}
[  575.085235]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  575.087654]     pending: drain_local_pages_wq{178281} BAR(4561){178281}
[  575.090339] workqueue writeback: flags=0x4e
[  575.092216]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[  575.094624]     in-flight: 354:wb_workfn{152208}
[  575.096978] workqueue mpt_poll_0: flags=0x8
[  575.098911]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.101330]     pending: mpt_fault_reset_work [mptbase]{177177}
[  575.104022] workqueue xfs-buf/sda1: flags=0xc
[  575.105933]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/1
[  575.108326]     pending: xfs_buf_ioend_work [xfs]{178206}
[  575.110552]     delayed: xfs_buf_ioend_work [xfs]{178160}, xfs_buf_ioend_work [xfs]{178154}, xfs_buf_ioend_work [xfs]{178154}
[  575.114766] workqueue xfs-data/sda1: flags=0xc
[  575.116756]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=22/256 MAYDAY
[  575.119431]     in-flight: 3221:xfs_end_io [xfs]{178291}, 3212:xfs_end_io [xfs]{178408}, 29:xfs_end_io [xfs]{178450}, 3230:xfs_end_io [xfs]{178421}, 3229:xfs_end_io [xfs]{178349}, 50:xfs_end_io [xfs]{178349}, 3223:xfs_end_io [xfs]{178295}, 165:xfs_end_io [xfs]{178302}, 3215:xfs_end_io [xfs]{178296}
[  575.128992]     pending: xfs_end_io [xfs]{178267}, xfs_end_io [xfs]{178263}, xfs_end_io [xfs]{178263}, xfs_end_io [xfs]{178255}, xfs_end_io [xfs]{178233}, xfs_end_io [xfs]{178231}, xfs_end_io [xfs]{178226}, xfs_end_io [xfs]{178219}, xfs_end_io [xfs]{178219}, xfs_end_io [xfs]{178206}, xfs_end_io [xfs]{178204}, xfs_end_io [xfs]{178204}, xfs_end_io [xfs]{178202}
[  575.141004]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=27/256 MAYDAY
[  575.143800]     in-flight: 3225:xfs_end_io [xfs]{178498}, 236:xfs_end_io [xfs]{178412}, 23:xfs_end_io [xfs]{178400}, 3228:xfs_end_io [xfs]{178400}, 4380:xfs_end_io [xfs]{178508}, 3214:xfs_end_io [xfs]{178489}, 3220:xfs_end_io [xfs]{178461}, 3227:xfs_end_io [xfs]{178482}
[  575.152624]     pending: xfs_end_io [xfs]{178415}, xfs_end_io [xfs]{178405}, xfs_end_io [xfs]{178384}, xfs_end_io [xfs]{178384}, xfs_end_io [xfs]{178384}, xfs_end_io [xfs]{178384}, xfs_end_io [xfs]{178384}, xfs_end_io [xfs]{178372}, xfs_end_io [xfs]{178366}, xfs_end_io [xfs]{178352}, xfs_end_io [xfs]{178352}, xfs_end_io [xfs]{178348}, xfs_end_io [xfs]{178338}, xfs_end_io [xfs]{178317}, xfs_end_io [xfs]{178314}, xfs_end_io [xfs]{178307}, xfs_end_io [xfs]{178296}, xfs_end_io [xfs]{178277}, xfs_end_io [xfs]{178270}
[  575.169750]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=24/256 MAYDAY
[  575.172622]     in-flight: 375(RESCUER):xfs_end_io [xfs]{178442}, 42:xfs_end_io [xfs]{178526}, 3222:xfs_end_io [xfs]{178534}, 17:xfs_end_io [xfs]{178443}, 65:xfs_end_io [xfs]{178489}, 122:xfs_end_io [xfs]{178478}
[  575.180109]     pending: xfs_end_io [xfs]{178436}, xfs_end_io [xfs]{178403}, xfs_end_io [xfs]{178362}, xfs_end_io [xfs]{178337}, xfs_end_io [xfs]{178330}, xfs_end_io [xfs]{178320}, xfs_end_io [xfs]{178319}, xfs_end_io [xfs]{178316}, xfs_end_io [xfs]{178311}, xfs_end_io [xfs]{178302}, xfs_end_io [xfs]{178300}, xfs_end_io [xfs]{178296}, xfs_end_io [xfs]{178281}, xfs_end_io [xfs]{178276}, xfs_end_io [xfs]{178266}, xfs_end_io [xfs]{178265}, xfs_end_io [xfs]{178263}, xfs_end_io [xfs]{178260}
[  575.197034]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=13/256
[  575.199866]     in-flight: 3218:xfs_end_io [xfs]{178512}, 3216:xfs_end_io [xfs]{178509}, 3:xfs_end_io [xfs]{178467}, 33:xfs_end_io [xfs]{178425}, 101:xfs_end_io [xfs]{178403}, 4381:xfs_end_io [xfs]{178538}, 3219:xfs_end_io [xfs]{178425}
[  575.208549]     pending: xfs_end_io [xfs]{178405}, xfs_end_io [xfs]{178397}, xfs_end_io [xfs]{178389}, xfs_end_io [xfs]{178313}, xfs_end_io [xfs]{178282}, xfs_end_io [xfs]{178281}
[  575.215489] workqueue xfs-reclaim/sda1: flags=0xc
[  575.218281] workqueue xfs-sync/sda1: flags=0x4
[  575.220637]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.223526]     pending: xfs_log_worker [xfs]{171287}
[  575.226102] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=178s workers=8 manager: 3224
[  575.229489] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=178s workers=6 manager: 3213
[  575.233018] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=178s workers=9 manager: 47
[  575.236383] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=33s workers=10 manager: 3217
[  575.239771] pool 128: cpus=0-63 flags=0x4 nice=0 hung=152s workers=3 idle: 355 356
[  605.720125] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 208s!
[  605.736025] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 209s!
[  605.746669] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 209s!
[  605.755091] BUG: workqueue lockup - pool cpus=3 node=0 flags=0x0 nice=0 stuck for 64s!
[  605.763390] Showing busy workqueues and worker pools:
[  605.769436] workqueue events: flags=0x0
[  605.772204]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  605.775548]     pending: console_callback{197431}, vmw_fb_dirty_flush [vmwgfx]{174896}, sysrq_reinject_alt_sysrq{174440}, push_to_pool{162245}
[  605.780761]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[  605.783603]     pending: e1000_watchdog [e1000]{207984}, check_corruption{166511}, rht_deferred_worker{28894}
[  605.787725]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  605.790682]     pending: vmpressure_work_fn{209065}, e1000_watchdog [e1000]{207615}
[  605.794271]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.797150]     pending: vmstat_shepherd{208067}
[  605.799610] workqueue events_long: flags=0x0
[  605.801951]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.805098]     pending: gc_worker [nf_conntrack]{208961}
[  605.807976] workqueue events_freezable: flags=0x4
[  605.810391]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.813151]     pending: vmballoon_work [vmw_balloon]{208085}
[  605.815851] workqueue events_power_efficient: flags=0x80
[  605.818382]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  605.821124]     pending: check_lifetime{64453}
[  605.823337]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.826091]     pending: neigh_periodic_work{199329}
[  605.828426]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  605.831068]     pending: fb_flashcursor{209042}, do_cache_clean{201882}
[  605.833902]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.836545]     pending: neigh_periodic_work{195234}
[  605.838838] workqueue events_freezable_power_: flags=0x84
[  605.841295]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.843824]     pending: disk_events_workfn{208625}
[  605.846084] workqueue mm_percpu_wq: flags=0x8
[  605.848145]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  605.850667]     pending: drain_local_pages_wq{209047} BAR(4561){209047}
[  605.853368] workqueue writeback: flags=0x4e
[  605.855382]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[  605.857793]     in-flight: 354:wb_workfn{182977}
[  605.860182] workqueue xfs-data/sda1: flags=0xc
[  605.862314]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=23/256 MAYDAY
[  605.865010]     in-flight: 3221:xfs_end_io [xfs]{209041}, 3212:xfs_end_io [xfs]{209158}, 29:xfs_end_io [xfs]{209200}, 3230:xfs_end_io [xfs]{209171}, 3229:xfs_end_io [xfs]{209099}, 50:xfs_end_io [xfs]{209099}, 3223:xfs_end_io [xfs]{209045}, 165:xfs_end_io [xfs]{209052}, 3215:xfs_end_io [xfs]{209046}
[  605.874362]     pending: xfs_end_io [xfs]{209011}, xfs_end_io [xfs]{209007}, xfs_end_io [xfs]{209007}, xfs_end_io [xfs]{208999}, xfs_end_io [xfs]{208977}, xfs_end_io [xfs]{208975}, xfs_end_io [xfs]{208970}, xfs_end_io [xfs]{208963}, xfs_end_io [xfs]{208963}, xfs_end_io [xfs]{208950}, xfs_end_io [xfs]{208948}, xfs_end_io [xfs]{208948}, xfs_end_io [xfs]{208946}, xfs_end_io [xfs]{30655}
[  605.886882]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=28/256 MAYDAY
[  605.889661]     in-flight: 3225:xfs_end_io [xfs]{209249}, 236:xfs_end_io [xfs]{209163}, 23:xfs_end_io [xfs]{209151}, 3228:xfs_end_io [xfs]{209151}, 4380:xfs_end_io [xfs]{209259}, 3214:xfs_end_io [xfs]{209240}, 3220:xfs_end_io [xfs]{209212}, 3227:xfs_end_io [xfs]{209233}
[  605.898706]     pending: xfs_end_io [xfs]{209159}, xfs_end_io [xfs]{209149}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209128}, xfs_end_io [xfs]{209116}, xfs_end_io [xfs]{209110}, xfs_end_io [xfs]{209096}, xfs_end_io [xfs]{209096}, xfs_end_io [xfs]{209092}, xfs_end_io [xfs]{209082}, xfs_end_io [xfs]{209061}, xfs_end_io [xfs]{209058}, xfs_end_io [xfs]{209051}, xfs_end_io [xfs]{209040}, xfs_end_io [xfs]{209021}, xfs_end_io [xfs]{209014}, xfs_end_io [xfs]{30678}
[  605.917299]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=24/256 MAYDAY
[  605.920254]     in-flight: 375(RESCUER):xfs_end_io [xfs]{209194}, 42:xfs_end_io [xfs]{209278}, 3222:xfs_end_io [xfs]{209286}, 17:xfs_end_io [xfs]{209195}, 65:xfs_end_io [xfs]{209241}, 122:xfs_end_io [xfs]{209230}
[  605.927845]     pending: xfs_end_io [xfs]{209187}, xfs_end_io [xfs]{209154}, xfs_end_io [xfs]{209113}, xfs_end_io [xfs]{209088}, xfs_end_io [xfs]{209081}, xfs_end_io [xfs]{209071}, xfs_end_io [xfs]{209070}, xfs_end_io [xfs]{209067}, xfs_end_io [xfs]{209062}, xfs_end_io [xfs]{209053}, xfs_end_io [xfs]{209051}, xfs_end_io [xfs]{209047}, xfs_end_io [xfs]{209032}, xfs_end_io [xfs]{209027}, xfs_end_io [xfs]{209017}, xfs_end_io [xfs]{209016}, xfs_end_io [xfs]{209014}, xfs_end_io [xfs]{209011}
[  605.944773]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=13/256
[  605.947616]     in-flight: 3218:xfs_end_io [xfs]{209268}, 3216:xfs_end_io [xfs]{209265}, 3:xfs_end_io [xfs]{209223}, 33:xfs_end_io [xfs]{209181}, 101:xfs_end_io [xfs]{209159}, 4381:xfs_end_io [xfs]{209294}, 3219:xfs_end_io [xfs]{209181}
[  605.956005]     pending: xfs_end_io [xfs]{209149}, xfs_end_io [xfs]{209141}, xfs_end_io [xfs]{209133}, xfs_end_io [xfs]{209057}, xfs_end_io [xfs]{209026}, xfs_end_io [xfs]{209025}
[  605.963018] workqueue xfs-sync/sda1: flags=0x4
[  605.965455]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  605.968299]     pending: xfs_log_worker [xfs]{202031}
[  605.970872] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=209s workers=8 manager: 3224
[  605.974252] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=209s workers=6 manager: 3213
[  605.977682] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=209s workers=9 manager: 47
[  605.981015] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=64s workers=10 manager: 3217
[  605.984382] pool 128: cpus=0-63 flags=0x4 nice=0 hung=183s workers=3 idle: 355 356
[  605.989894] c.out: page allocation stalls for 209368ms, order:0, mode:0x1604040(GFP_NOFS|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
[  605.994839] c.out cpuset=/ mems_allowed=0
[  605.997152] CPU: 3 PID: 4561 Comm: c.out Not tainted 4.12.0-next-20170705+ #113
[  606.000524] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  606.004974] Call Trace:
[  606.006766]  dump_stack+0x63/0x8d
[  606.008851]  warn_alloc+0x10f/0x1b0
[  606.010991]  __alloc_pages_slowpath+0x8b9/0xd50
[  606.013424]  __alloc_pages_nodemask+0x20c/0x250
[  606.015835]  alloc_pages_current+0x65/0xd0
[  606.018095]  new_slab+0x472/0x600
[  606.020117]  ___slab_alloc+0x41b/0x590
[  606.022255]  ? kmem_alloc+0x8a/0x110 [xfs]
[  606.024497]  ? kmem_alloc+0x8a/0x110 [xfs]
[  606.026751]  __slab_alloc+0x1b/0x30
[  606.028806]  ? __save_stack_trace+0x70/0xf0
[  606.031089]  ? __slab_alloc+0x1b/0x30
[  606.033145]  __kmalloc+0x17e/0x200
[  606.035111]  kmem_alloc+0x8a/0x110 [xfs]
[  606.037159]  xfs_iext_inline_to_direct+0x1f/0x80 [xfs]
[  606.039635]  xfs_iext_realloc_direct+0xc6/0x140 [xfs]
[  606.042052]  xfs_iext_add+0x196/0x2e0 [xfs]
[  606.044161]  xfs_iext_insert+0x37/0xa0 [xfs]
[  606.046305]  xfs_bmap_add_extent_hole_delay+0xff/0x510 [xfs]
[  606.048841]  ? free_debug_processing+0x251/0x3a0
[  606.051049]  ? xfs_mod_fdblocks+0xa1/0x1a0 [xfs]
[  606.053192]  xfs_bmapi_reserve_delalloc+0x282/0x340 [xfs]
[  606.055584]  xfs_file_iomap_begin+0x574/0x750 [xfs]
[  606.057856]  ? iomap_write_begin.constprop.16+0x120/0x120
[  606.060224]  iomap_apply+0x55/0x110
[  606.061927]  ? iomap_write_begin.constprop.16+0x120/0x120
[  606.064218]  iomap_file_buffered_write+0x69/0x90
[  606.066286]  ? iomap_write_begin.constprop.16+0x120/0x120
[  606.068538]  xfs_file_buffered_aio_write+0xb7/0x200 [xfs]
[  606.070807]  xfs_file_write_iter+0x8d/0x130 [xfs]
[  606.072890]  __vfs_write+0xef/0x150
[  606.074598]  vfs_write+0xb0/0x190
[  606.076173]  SyS_write+0x50/0xc0
[  606.077699]  do_syscall_64+0x62/0x140
[  606.079272]  entry_SYSCALL64_slow_path+0x25/0x25
[  606.081254] RIP: 0033:0x7f554047fc90
[  606.082874] RSP: 002b:00007fffc842cc58 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
[  606.085745] RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 00007f554047fc90
[  606.088406] RDX: 0000000000001000 RSI: 00000000006010c0 RDI: 0000000000000003
[  606.091091] RBP: 0000000000000003 R08: 00007f55403df938 R09: 000000000000000e
[  606.093839] R10: 00007fffc842c9e0 R11: 0000000000000246 R12: 000000000040085d
[  606.096584] R13: 00007fffc842cd60 R14: 0000000000000000 R15: 0000000000000000
[  606.099478] Mem-Info:
[  606.100680] active_anon:836258 inactive_anon:5420 isolated_anon:0
[  606.100680]  active_file:99 inactive_file:64 isolated_file:65
[  606.100680]  unevictable:0 dirty:5 writeback:88 unstable:0
[  606.100680]  slab_reclaimable:0 slab_unreclaimable:93
[  606.100680]  mapped:3143 shmem:5581 pagetables:10619 bounce:0
[  606.100680]  free:21343 free_pcp:94 free_cma:0
[  606.113419] Node 0 active_anon:3345032kB inactive_anon:21680kB active_file:396kB inactive_file:256kB unevictable:0kB isolated(anon):0kB isolated(file):260kB mapped:12572kB dirty:20kB writeback:352kB shmem:22324kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2975744kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  606.123785] Node 0 DMA free:14836kB min:284kB low:352kB high:420kB active_anon:1032kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  606.133156] lowmem_reserve[]: 0 2700 3642 3642
[  606.135189] Node 0 DMA32 free:53284kB min:49888kB low:62360kB high:74832kB active_anon:2711124kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2765492kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  606.145014] lowmem_reserve[]: 0 0 942 942
[  606.146879] Node 0 Normal free:17252kB min:17404kB low:21752kB high:26100kB active_anon:632876kB inactive_anon:21680kB active_file:232kB inactive_file:468kB unevictable:0kB writepending:372kB present:1048576kB managed:964816kB mlocked:0kB kernel_stack:20944kB pagetables:42468kB bounce:0kB free_pcp:376kB local_pcp:100kB free_cma:0kB
[  606.158166] lowmem_reserve[]: 0 0 0 0
[  606.160059] Node 0 DMA: 1*4kB (U) 2*8kB (UM) 2*16kB (UM) 2*32kB (UM) 2*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14836kB
[  606.166066] Node 0 DMA32: 1*4kB (U) 2*8kB (U) 3*16kB (U) 5*32kB (UM) 3*64kB (UM) 3*128kB (UM) 5*256kB (UM) 8*512kB (UM) 6*1024kB (UM) 2*2048kB (U) 9*4096kB (UME) = 53284kB
[  606.172427] Node 0 Normal: 29*4kB (UM) 33*8kB (UM) 22*16kB (UME) 134*32kB (UME) 22*64kB (UE) 5*128kB (UME) 0*256kB 2*512kB (UM) 9*1024kB (M) 0*2048kB 0*4096kB = 17308kB
[  606.178731] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  606.182325] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  606.185806] 5816 total pagecache pages
[  606.187829] 0 pages in swap cache
[  606.189681] Swap cache stats: add 0, delete 0, find 0/0
[  606.192165] Free swap  = 0kB
[  606.194020] Total swap = 0kB
[  606.195774] 1048445 pages RAM
[  606.197545] 0 pages HighMem/MovableOnly
[  606.199536] 111892 pages reserved
[  606.201413] 0 pages cma reserved
[  606.203248] 0 pages hwpoisoned
[  636.464050] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 30s!
[  636.479332] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 239s!
[  636.488530] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 239s!
[  636.492635] BUG: workqueue lockup - pool cpus=3 node=0 flags=0x0 nice=0 stuck for 94s!
[  636.496715] Showing busy workqueues and worker pools:
[  636.499694] workqueue events: flags=0x0
[  636.502181]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  636.505801]     pending: console_callback{228160}, vmw_fb_dirty_flush [vmwgfx]{205625}, sysrq_reinject_alt_sysrq{205169}, push_to_pool{192974}
[  636.511750]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[  636.515126]     pending: e1000_watchdog [e1000]{238720}, check_corruption{197247}, rht_deferred_worker{59630}
[  636.519373]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  636.522146]     pending: vmpressure_work_fn{239794}, e1000_watchdog [e1000]{238344}
[  636.525433]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  636.528181]     pending: vmstat_shepherd{238799}
[  636.530540] workqueue events_long: flags=0x0
[  636.532791]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  636.535576]     pending: gc_worker [nf_conntrack]{239690}
[  636.538146] workqueue events_freezable: flags=0x4
[  636.540518]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  636.543224]     pending: vmballoon_work [vmw_balloon]{238809}
[  636.545964] workqueue events_power_efficient: flags=0x80
[  636.548437]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  636.551131]     pending: check_lifetime{95187}
[  636.553297]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  636.555915]     pending: neigh_periodic_work{230055}
[  636.558186]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  636.560831]     pending: fb_flashcursor{239776}, do_cache_clean{232616}
[  636.563575]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  636.566117]     pending: neigh_periodic_work{225958}
[  636.568332] workqueue events_freezable_power_: flags=0x84
[  636.570689]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  636.573190]     pending: disk_events_workfn{239356}
[  636.575368] workqueue writeback: flags=0x4e
[  636.577296]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[  636.579702]     in-flight: 354:wb_workfn{213696}
[  636.582020] workqueue xfs-data/sda1: flags=0xc
[  636.584000]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=23/256 MAYDAY
[  636.586630]     in-flight: 3221:xfs_end_io [xfs]{239760}, 3212:xfs_end_io [xfs]{239877}, 29:xfs_end_io [xfs]{239919}, 3230:xfs_end_io [xfs]{239890}, 3229:xfs_end_io [xfs]{239818}, 50:xfs_end_io [xfs]{239818}, 3223:xfs_end_io [xfs]{239764}, 165:xfs_end_io [xfs]{239771}, 3215:xfs_end_io [xfs]{239765}
[  636.596055]     pending: xfs_end_io [xfs]{239733}, xfs_end_io [xfs]{239729}, xfs_end_io [xfs]{239729}, xfs_end_io [xfs]{239721}, xfs_end_io [xfs]{239699}, xfs_end_io [xfs]{239697}, xfs_end_io [xfs]{239692}, xfs_end_io [xfs]{239685}, xfs_end_io [xfs]{239685}, xfs_end_io [xfs]{239672}, xfs_end_io [xfs]{239670}, xfs_end_io [xfs]{239670}, xfs_end_io [xfs]{239668}, xfs_end_io [xfs]{61377}
[  636.609025]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=28/256 MAYDAY
[  636.611804]     in-flight: 3225:xfs_end_io [xfs]{239971}, 236:xfs_end_io [xfs]{239885}, 23:xfs_end_io [xfs]{239873}, 3228:xfs_end_io [xfs]{239873}, 4380:xfs_end_io [xfs]{239981}, 3214:xfs_end_io [xfs]{239962}, 3220:xfs_end_io [xfs]{239934}, 3227:xfs_end_io [xfs]{239955}
[  636.620591]     pending: xfs_end_io [xfs]{239880}, xfs_end_io [xfs]{239870}, xfs_end_io [xfs]{239849}, xfs_end_io [xfs]{239849}, xfs_end_io [xfs]{239849}, xfs_end_io [xfs]{239849}, xfs_end_io [xfs]{239849}, xfs_end_io [xfs]{239837}, xfs_end_io [xfs]{239831}, xfs_end_io [xfs]{239817}, xfs_end_io [xfs]{239817}, xfs_end_io [xfs]{239813}, xfs_end_io [xfs]{239803}, xfs_end_io [xfs]{239782}, xfs_end_io [xfs]{239779}, xfs_end_io [xfs]{239772}, xfs_end_io [xfs]{239761}, xfs_end_io [xfs]{239742}, xfs_end_io [xfs]{239735}, xfs_end_io [xfs]{61399}
[  636.638457]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=24/256 MAYDAY
[  636.641379]     in-flight: 375(RESCUER):xfs_end_io [xfs]{239913}, 42:xfs_end_io [xfs]{239997}, 3222:xfs_end_io [xfs]{240005}, 17:xfs_end_io [xfs]{239914}, 65:xfs_end_io [xfs]{239960}, 122:xfs_end_io [xfs]{239949}
[  636.648939]     pending: xfs_end_io [xfs]{239909}, xfs_end_io [xfs]{239876}, xfs_end_io [xfs]{239835}, xfs_end_io [xfs]{239810}, xfs_end_io [xfs]{239803}, xfs_end_io [xfs]{239793}, xfs_end_io [xfs]{239792}, xfs_end_io [xfs]{239789}, xfs_end_io [xfs]{239784}, xfs_end_io [xfs]{239775}, xfs_end_io [xfs]{239773}, xfs_end_io [xfs]{239769}, xfs_end_io [xfs]{239754}, xfs_end_io [xfs]{239749}, xfs_end_io [xfs]{239739}, xfs_end_io [xfs]{239738}, xfs_end_io [xfs]{239736}, xfs_end_io [xfs]{239733}
[  636.665876]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=13/256 MAYDAY
[  636.668887]     in-flight: 3218:xfs_end_io [xfs]{239985}, 3216:xfs_end_io [xfs]{239982}, 3:xfs_end_io [xfs]{239940}, 33:xfs_end_io [xfs]{239898}, 101:xfs_end_io [xfs]{239876}, 4381:xfs_end_io [xfs]{240011}, 3219:xfs_end_io [xfs]{239898}
[  636.677214]     pending: xfs_end_io [xfs]{239868}, xfs_end_io [xfs]{239860}, xfs_end_io [xfs]{239852}, xfs_end_io [xfs]{239776}, xfs_end_io [xfs]{239745}, xfs_end_io [xfs]{239744}
[  636.684203] workqueue xfs-sync/sda1: flags=0x4
[  636.686584]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  636.689436]     pending: xfs_log_worker [xfs]{232753}
[  636.691989] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=30s workers=8 manager: 3224
[  636.695341] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=239s workers=6 manager: 3213
[  636.698743] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=239s workers=9 manager: 47
[  636.702057] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=95s workers=10 manager: 3217
[  636.705626] pool 128: cpus=0-63 flags=0x4 nice=0 hung=213s workers=3 idle: 355 356
(...snipped...)
[  759.360053] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 153s!
[  759.375960] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 362s!
[  759.391621] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 362s!
[  759.398229] BUG: workqueue lockup - pool cpus=3 node=0 flags=0x0 nice=0 stuck for 217s!
[  759.404705] Showing busy workqueues and worker pools:
[  759.409228] workqueue events: flags=0x0
[  759.413073]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  759.418084]     pending: console_callback{351071}, vmw_fb_dirty_flush [vmwgfx]{328536}, sysrq_reinject_alt_sysrq{328080}, push_to_pool{315885}
[  759.426979]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[  759.432080]     pending: e1000_watchdog [e1000]{361636}, check_corruption{320163}, rht_deferred_worker{182546}
[  759.439485]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  759.444696]     pending: vmpressure_work_fn{362715}, e1000_watchdog [e1000]{361265}
[  759.450822]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  759.454480]     pending: vmstat_shepherd{361724}
[  759.456946] workqueue events_long: flags=0x0
[  759.459238]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  759.462057]     pending: gc_worker [nf_conntrack]{362616}
[  759.464659] workqueue events_freezable: flags=0x4
[  759.467040]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  759.469827]     pending: vmballoon_work [vmw_balloon]{361728}
[  759.472739] workqueue events_power_efficient: flags=0x80
[  759.475236]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  759.478058]     pending: check_lifetime{218115}
[  759.480357]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  759.483023]     pending: neigh_periodic_work{352981}
[  759.485355]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  759.488029]     pending: fb_flashcursor{362694}, do_cache_clean{355534}
[  759.490781]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  759.493357]     pending: neigh_periodic_work{348876}
[  759.495597] workqueue events_freezable_power_: flags=0x84
[  759.498032]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  759.500545]     pending: disk_events_workfn{362285}
[  759.503818] workqueue writeback: flags=0x4e
[  759.505835]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[  759.508299]     in-flight: 354:wb_workfn{336620}
[  759.510701] workqueue xfs-data/sda1: flags=0xc
[  759.512740]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=23/256 MAYDAY
[  759.515402]     in-flight: 3221:xfs_end_io [xfs]{362676}, 3212:xfs_end_io [xfs]{362793}, 29:xfs_end_io [xfs]{362835}, 3230:xfs_end_io [xfs]{362806}, 3229:xfs_end_io [xfs]{362734}, 50:xfs_end_io [xfs]{362734}, 3223:xfs_end_io [xfs]{362680}, 165:xfs_end_io [xfs]{362687}, 3215:xfs_end_io [xfs]{362681}
[  759.524948]     pending: xfs_end_io [xfs]{362661}, xfs_end_io [xfs]{362657}, xfs_end_io [xfs]{362657}, xfs_end_io [xfs]{362649}, xfs_end_io [xfs]{362627}, xfs_end_io [xfs]{362625}, xfs_end_io [xfs]{362620}, xfs_end_io [xfs]{362613}, xfs_end_io [xfs]{362613}, xfs_end_io [xfs]{362600}, xfs_end_io [xfs]{362598}, xfs_end_io [xfs]{362598}, xfs_end_io [xfs]{362596}, xfs_end_io [xfs]{184305}
[  759.537671]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=28/256 MAYDAY
[  759.540432]     in-flight: 3225:xfs_end_io [xfs]{362900}, 236:xfs_end_io [xfs]{362814}, 23:xfs_end_io [xfs]{362802}, 3228:xfs_end_io [xfs]{362802}, 4380:xfs_end_io [xfs]{362910}, 3214:xfs_end_io [xfs]{362891}, 3220:xfs_end_io [xfs]{362863}, 3227:xfs_end_io [xfs]{362884}
[  759.549634]     pending: xfs_end_io [xfs]{362809}, xfs_end_io [xfs]{362799}, xfs_end_io [xfs]{362778}, xfs_end_io [xfs]{362778}, xfs_end_io [xfs]{362778}, xfs_end_io [xfs]{362778}, xfs_end_io [xfs]{362778}, xfs_end_io [xfs]{362766}, xfs_end_io [xfs]{362760}, xfs_end_io [xfs]{362746}, xfs_end_io [xfs]{362746}, xfs_end_io [xfs]{362742}, xfs_end_io [xfs]{362732}, xfs_end_io [xfs]{362711}, xfs_end_io [xfs]{362708}, xfs_end_io [xfs]{362701}, xfs_end_io [xfs]{362690}, xfs_end_io [xfs]{362671}, xfs_end_io [xfs]{362664}, xfs_end_io [xfs]{184328}
[  759.567586]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=24/256 MAYDAY
[  759.570488]     in-flight: 375(RESCUER):xfs_end_io [xfs]{362841}, 42:xfs_end_io [xfs]{362925}, 3222:xfs_end_io [xfs]{362933}, 17:xfs_end_io [xfs]{362842}, 65:xfs_end_io [xfs]{362888}, 122:xfs_end_io [xfs]{362877}
[  759.578099]     pending: xfs_end_io [xfs]{362827}, xfs_end_io [xfs]{362794}, xfs_end_io [xfs]{362753}, xfs_end_io [xfs]{362728}, xfs_end_io [xfs]{362721}, xfs_end_io [xfs]{362711}, xfs_end_io [xfs]{362710}, xfs_end_io [xfs]{362707}, xfs_end_io [xfs]{362702}, xfs_end_io [xfs]{362693}, xfs_end_io [xfs]{362691}, xfs_end_io [xfs]{362687}, xfs_end_io [xfs]{362672}, xfs_end_io [xfs]{362667}, xfs_end_io [xfs]{362657}, xfs_end_io [xfs]{362656}, xfs_end_io [xfs]{362654}, xfs_end_io [xfs]{362651}
[  759.595092]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=13/256 MAYDAY
[  759.598096]     in-flight: 3218:xfs_end_io [xfs]{362911}, 3216:xfs_end_io [xfs]{362908}, 3:xfs_end_io [xfs]{362866}, 33:xfs_end_io [xfs]{362824}, 101:xfs_end_io [xfs]{362802}, 4381:xfs_end_io [xfs]{362937}, 3219:xfs_end_io [xfs]{362824}
[  759.607196]     pending: xfs_end_io [xfs]{362787}, xfs_end_io [xfs]{362779}, xfs_end_io [xfs]{362771}, xfs_end_io [xfs]{362695}, xfs_end_io [xfs]{362664}, xfs_end_io [xfs]{362663}
[  759.614201] workqueue xfs-eofblocks/sda1: flags=0xc
[  759.616695]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  759.619543]     in-flight: 380(RESCUER):xfs_eofblocks_worker [xfs]{99164}
[  759.622697] workqueue xfs-sync/sda1: flags=0x4
[  759.625087]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  759.627992]     pending: xfs_log_worker [xfs]{355689}
[  759.630545] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=153s workers=8 manager: 3224
[  759.633960] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=362s workers=6 manager: 3213
[  759.637414] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=362s workers=9 manager: 47
[  759.640746] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=217s workers=10 manager: 3217
[  759.644187] pool 128: cpus=0-63 flags=0x4 nice=0 hung=336s workers=3 idle: 355 356
(...snipped...)
[  773.195011] mm_percpu_wq    S14768     6      2 0x00000000
[  773.197070] Call Trace:
[  773.198171]  __schedule+0x23f/0x5d0
[  773.199614]  ? _cond_resched+0x15/0x40
[  773.201175]  schedule+0x31/0x80
[  773.202553]  rescuer_thread+0x343/0x390
[  773.204076]  kthread+0xff/0x140
[  773.205415]  ? worker_thread+0x410/0x410
[  773.207171]  ? kthread_create_on_node+0x60/0x60
[  773.209045]  ret_from_fork+0x25/0x30
(...snipped...)
[  794.604916] c.out           D11856  4561   4382 0x00000080
[  794.606998] Call Trace:
[  794.608142]  __schedule+0x23f/0x5d0
[  794.609694]  schedule+0x31/0x80
[  794.611040]  schedule_timeout+0x189/0x290
[  794.612740]  ? set_track+0x6b/0x140
[  794.614287]  ? del_timer_sync+0x40/0x40
[  794.615844]  io_schedule_timeout+0x19/0x40
[  794.617544]  ? io_schedule_timeout+0x19/0x40
[  794.619275]  congestion_wait+0x7d/0xd0
[  794.620806]  ? wait_woken+0x80/0x80
[  794.622294]  shrink_inactive_list+0x3e3/0x4d0
[  794.624074]  shrink_node_memcg+0x360/0x780
[  794.625707]  ? list_lru_count_one+0x65/0x70
[  794.627628]  shrink_node+0xdc/0x310
[  794.629121]  ? shrink_node+0xdc/0x310
[  794.630621]  do_try_to_free_pages+0xea/0x370
[  794.632338]  try_to_free_pages+0xc3/0x100
[  794.633986]  __alloc_pages_slowpath+0x441/0xd50
[  794.635750]  __alloc_pages_nodemask+0x20c/0x250
[  794.637731]  alloc_pages_current+0x65/0xd0
[  794.639548]  new_slab+0x472/0x600
[  794.640943]  ___slab_alloc+0x41b/0x590
[  794.642546]  ? kmem_alloc+0x8a/0x110 [xfs]
[  794.644269]  ? kmem_alloc+0x8a/0x110 [xfs]
[  794.645892]  __slab_alloc+0x1b/0x30
[  794.647355]  ? __save_stack_trace+0x70/0xf0
[  794.649032]  ? __slab_alloc+0x1b/0x30
[  794.650515]  __kmalloc+0x17e/0x200
[  794.651923]  kmem_alloc+0x8a/0x110 [xfs]
[  794.653485]  xfs_iext_inline_to_direct+0x1f/0x80 [xfs]
[  794.655458]  xfs_iext_realloc_direct+0xc6/0x140 [xfs]
[  794.657394]  xfs_iext_add+0x196/0x2e0 [xfs]
[  794.659096]  xfs_iext_insert+0x37/0xa0 [xfs]
[  794.660752]  xfs_bmap_add_extent_hole_delay+0xff/0x510 [xfs]
[  794.662852]  ? free_debug_processing+0x251/0x3a0
[  794.664776]  ? xfs_mod_fdblocks+0xa1/0x1a0 [xfs]
[  794.666598]  xfs_bmapi_reserve_delalloc+0x282/0x340 [xfs]
[  794.668635]  xfs_file_iomap_begin+0x574/0x750 [xfs]
[  794.670566]  ? iomap_write_begin.constprop.16+0x120/0x120
[  794.672638]  iomap_apply+0x55/0x110
[  794.674128]  ? iomap_write_begin.constprop.16+0x120/0x120
[  794.676207]  iomap_file_buffered_write+0x69/0x90
[  794.677985]  ? iomap_write_begin.constprop.16+0x120/0x120
[  794.680117]  xfs_file_buffered_aio_write+0xb7/0x200 [xfs]
[  794.682184]  xfs_file_write_iter+0x8d/0x130 [xfs]
[  794.684043]  __vfs_write+0xef/0x150
[  794.685481]  vfs_write+0xb0/0x190
[  794.686943]  SyS_write+0x50/0xc0
[  794.688310]  do_syscall_64+0x62/0x140
[  794.689862]  entry_SYSCALL64_slow_path+0x25/0x25
----------



Well, looking at the traces as of uptime = 465, drain_local_pages_wq was
stuck at wait_for_completion() from flush_work()

----------
bool flush_work(struct work_struct *work)
{
        struct wq_barrier barr;

        if (WARN_ON(!wq_online))
                return false;

        lock_map_acquire(&work->lockdep_map);
        lock_map_release(&work->lockdep_map);

        if (start_flush_work(work, &barr)) {
                wait_for_completion(&barr.done);
                destroy_work_on_stack(&barr.work);
                return true;
        } else {
                return false;
        }
}
----------

which can be called on multiple CPUs from drain_all_pages().

----------
void drain_all_pages(struct zone *zone)
{
(...snipped...)
        for_each_cpu(cpu, &cpus_with_pcps) {
                struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
                INIT_WORK(work, drain_local_pages_wq);
                queue_work_on(cpu, mm_percpu_wq, work);
        }
        for_each_cpu(cpu, &cpus_with_pcps)
                flush_work(per_cpu_ptr(&pcpu_drain, cpu));
(...snipped...)
}
----------

If start_flush_work() returned true (well, since we will fail to wait for
completion of drain_local_pages_wq() if start_flush_work() returned false,
start_flush_work() is expected to return true), we wait for completion.

flush_work() in drain_all_pages() expected that per_cpu_ptr(&pcpu_drain, cpu) is
processed as soon as possible using mm_percpu_wq thread (PID = 6) if memory
cannot be allocated.

Since drain_local_pages_wq work was stalling for 144 seconds as of uptime = 541,
drain_local_pages_wq work was queued around uptime = 397 (which is about 6 seconds
since the OOM killer/reaper reclaimed some memory for the last time). 

But as far as I can see from traces, the mm_percpu_wq thread as of uptime = 444 was
idle, while drain_local_pages_wq work was pending from uptime = 541 to uptime = 605.
This means that the mm_percpu_wq thread did not start processing drain_local_pages_wq
work immediately. (I don't know what made drain_local_pages_wq work be processed.)

Why? Is this a workqueue implementation bug? Is this a workqueue usage bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
