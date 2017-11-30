Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16FED6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:39:00 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f64so4944812pfd.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:39:00 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 3si3191907pli.43.2017.11.30.05.38.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 05:38:58 -0800 (PST)
Date: Thu, 30 Nov 2017 21:38:40 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC),
 nodemask=(null)
Message-ID: <20171130133840.6yz4774274e5scpi@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="y7hnjbnavwaasi5b"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, lkp@01.org


--y7hnjbnavwaasi5b
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

It looks like a regression in 4.15.0-rc1 -- the test case simply run a
set of parallel dd's and there seems no reason to run into memory problem.

It occurs in 1 out of 4 tests.

The test goes like this:

        https://git.kernel.org/pub/scm/linux/kernel/git/wfg/vm-scalability.git/tree/case-lru-file-readtwice

        mount -t tmpfs -o size=100% vm-scalability-tmp /tmp/vm-scalability-tmp
        truncate -s 67192406016 /tmp/vm-scalability-tmp/vm-scalability.img
        mkfs.xfs -q /tmp/vm-scalability-tmp/vm-scalability.img
        mount -o loop /tmp/vm-scalability-tmp/vm-scalability.img /tmp/vm-scalability-tmp/vm-scalability
        ./case-lru-file-readtwice
        truncate /tmp/vm-scalability-tmp/vm-scalability/sparse-lru-file-readtwice-1 -s 39268272420
        truncate /tmp/vm-scalability-tmp/vm-scalability/sparse-lru-file-readtwice-2 -s 39268272420
        truncate /tmp/vm-scalability-tmp/vm-scalability/sparse-lru-file-readtwice-3 -s 39268272420
        ...
        truncate /tmp/vm-scalability-tmp/vm-scalability/sparse-lru-file-readtwice-112 -s 39268272420

The test machine is

        hostname: lkp-skl-2sp2
        model: Skylake
        nr_cpu: 112
        memory: 64G

[   35.877083]
[   35.879974] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-scalability/sparse-lru-file-readtwice-111 -s 39268272420
[   35.879977]
[   35.882960] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-scalability/sparse-lru-file-readtwice-112 -s 39268272420
[   35.882964]
[   71.088242] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC), nodemask=(null)
[   71.098654] dd cpuset=/ mems_allowed=0-1
[   71.104460] CPU: 0 PID: 6016 Comm: dd Tainted: G           O     4.15.0-rc1 #1
[   71.113553] Call Trace:
[   71.117886]  <IRQ>
[   71.121749]  dump_stack+0x5c/0x7b:
						dump_stack at lib/dump_stack.c:55
[   71.126785]  warn_alloc+0xbe/0x150:
						preempt_count at arch/x86/include/asm/preempt.h:23
						 (inlined by) should_suppress_show_mem at mm/page_alloc.c:3244
						 (inlined by) warn_alloc_show_mem at mm/page_alloc.c:3254
						 (inlined by) warn_alloc at mm/page_alloc.c:3293
[   71.131939]  __alloc_pages_slowpath+0xda7/0xdf0:
						__alloc_pages_slowpath at mm/page_alloc.c:4151
[   71.138110]  ? xhci_urb_enqueue+0x23d/0x580:
						xhci_urb_enqueue at drivers/usb/host/xhci.c:1389
[   71.143941]  __alloc_pages_nodemask+0x269/0x280:
						__alloc_pages_nodemask at mm/page_alloc.c:4245
[   71.150167]  page_frag_alloc+0x11c/0x150:
						__page_frag_cache_refill at mm/page_alloc.c:4335
						 (inlined by) page_frag_alloc at mm/page_alloc.c:4364
[   71.155668]  __netdev_alloc_skb+0xa0/0x110:
						__netdev_alloc_skb at net/core/skbuff.c:415
[   71.161386]  rx_submit+0x3b/0x2e0:
						rx_submit at drivers/net/usb/usbnet.c:488
[   71.166232]  rx_complete+0x196/0x2d0:
						rx_complete at drivers/net/usb/usbnet.c:659
[   71.171354]  __usb_hcd_giveback_urb+0x86/0x100:
						arch_local_irq_restore at arch/x86/include/asm/paravirt.h:777
						 (inlined by) __usb_hcd_giveback_urb at drivers/usb/core/hcd.c:1769
[   71.177281]  xhci_giveback_urb_in_irq+0x86/0x100
[   71.184107]  xhci_td_cleanup+0xe7/0x170:
						xhci_td_cleanup at drivers/usb/host/xhci-ring.c:1924
[   71.189457]  handle_tx_event+0x297/0x1190:
						process_bulk_intr_td at drivers/usb/host/xhci-ring.c:2267
						 (inlined by) handle_tx_event at drivers/usb/host/xhci-ring.c:2598
[   71.194905]  ? reweight_entity+0x145/0x180:
						enqueue_runnable_load_avg at kernel/sched/fair.c:2742
						 (inlined by) reweight_entity at kernel/sched/fair.c:2810
[   71.200466]  xhci_irq+0x300/0xb80:
						xhci_handle_event at drivers/usb/host/xhci-ring.c:2676
						 (inlined by) xhci_irq at drivers/usb/host/xhci-ring.c:2777
[   71.205195]  ? scheduler_tick+0xb2/0xe0:
						rq_last_tick_reset at kernel/sched/sched.h:1643
						 (inlined by) scheduler_tick at kernel/sched/core.c:3036
[   71.210407]  ? run_timer_softirq+0x73/0x460:
						__collect_expired_timers at kernel/time/timer.c:1375
						 (inlined by) collect_expired_timers at kernel/time/timer.c:1609
						 (inlined by) __run_timers at kernel/time/timer.c:1656
						 (inlined by) run_timer_softirq at kernel/time/timer.c:1688
[   71.215905]  __handle_irq_event_percpu+0x3a/0x1a0:
						__handle_irq_event_percpu at kernel/irq/handle.c:147
[   71.221975]  handle_irq_event_percpu+0x20/0x50:
						handle_irq_event_percpu at kernel/irq/handle.c:189
[   71.227641]  handle_irq_event+0x3d/0x60:
						handle_irq_event at kernel/irq/handle.c:206
[   71.232682]  handle_edge_irq+0x71/0x190:
						handle_edge_irq at kernel/irq/chip.c:796
[   71.237715]  handle_irq+0xa5/0x100:
						handle_irq at arch/x86/kernel/irq_64.c:78
[   71.242326]  do_IRQ+0x41/0xc0:
						do_IRQ at arch/x86/kernel/irq.c:241
[   71.246472]  common_interrupt+0x96/0x96:
						ret_from_intr at arch/x86/entry/entry_64.S:611
[   71.251509]  </IRQ>
[   71.254696] RIP: 0010:_raw_spin_unlock_irqrestore+0x11/0x20:
						arch_local_irq_restore at arch/x86/include/asm/paravirt.h:777
						 (inlined by) __raw_spin_unlock_irqrestore at include/linux/spinlock_api_smp.h:160
						 (inlined by) _raw_spin_unlock_irqrestore at kernel/locking/spinlock.c:191
[   71.261306] RSP: 0018:ffffc9000a0f7718 EFLAGS: 00000246 ORIG_RAX: ffffffffffffffd9
[   71.269926] RAX: 0000000000000001 RBX: ffffea00124bce40 RCX: 0000000000000000
[   71.278165] RDX: ffffffff811d5b10 RSI: 0000000000000246 RDI: 0000000000000246
[   71.286380] RBP: ffff8808196b0688 R08: 0000000000000001 R09: 0000000000000016
[   71.294533] R10: ffff8804676c3258 R11: 0000000000000017 R12: 0000000000000001
[   71.302666] R13: ffff8808196b0670 R14: 0000000000000246 R15: 0000000000000000
[   71.310729]  ? count_shadow_nodes+0xa0/0xa0:
						workingset_update_node at mm/workingset.c:344
[   71.315862]  __remove_mapping+0xe8/0x200:
						__remove_mapping at mm/vmscan.c:748
[   71.320667]  shrink_page_list+0x8e5/0xbd0:
						shrink_page_list at mm/vmscan.c:1308 (discriminator 1)
[   71.325599]  shrink_inactive_list+0x216/0x550:
						spin_lock_irq at include/linux/spinlock.h:340
						 (inlined by) shrink_inactive_list at mm/vmscan.c:1806
[   71.330861]  shrink_node_memcg+0x37e/0x780:
						shrink_list at mm/vmscan.c:2161
						 (inlined by) shrink_node_memcg at mm/vmscan.c:2424
[   71.335879]  ? shrink_node+0xeb/0x2e0:
						shrink_node at mm/vmscan.c:2617
[   71.340356]  shrink_node+0xeb/0x2e0:
						shrink_node at mm/vmscan.c:2617
[   71.344646]  do_try_to_free_pages+0xb3/0x310:
						shrink_zones at mm/vmscan.c:2743
						 (inlined by) do_try_to_free_pages at mm/vmscan.c:2860
[   71.349761]  try_to_free_pages+0xf2/0x1c0:
						try_to_free_pages at mm/vmscan.c:3066
[   71.354467]  __alloc_pages_slowpath+0x3e2/0xdf0:
						__perform_reclaim at mm/page_alloc.c:3625
						 (inlined by) __alloc_pages_direct_reclaim at mm/page_alloc.c:3646
						 (inlined by) __alloc_pages_slowpath at mm/page_alloc.c:4045
[   71.359719]  __alloc_pages_nodemask+0x269/0x280:
						__alloc_pages_nodemask at mm/page_alloc.c:4245
[   71.364901]  __do_page_cache_readahead+0xfd/0x290:
						__do_page_cache_readahead at mm/readahead.c:184
[   71.370326]  ? set_next_entity+0xa1/0x210:
						set_next_entity at kernel/sched/fair.c:4165
[   71.374955]  ? current_time+0x18/0x70:
						current_kernel_time at include/linux/timekeeping32.h:17
						 (inlined by) current_time at fs/inode.c:2118
[   71.379284]  ? ondemand_readahead+0x117/0x2c0:
						ra_submit at mm/internal.h:66
						 (inlined by) ondemand_readahead at mm/readahead.c:478
[   71.384303]  ondemand_readahead+0x117/0x2c0:
						ra_submit at mm/internal.h:66
						 (inlined by) ondemand_readahead at mm/readahead.c:478
[   71.389205]  generic_file_read_iter+0x731/0x980:
						generic_file_buffered_read at mm/filemap.c:2103
						 (inlined by) generic_file_read_iter at mm/filemap.c:2365
[   71.394425]  ? _cond_resched+0xf/0x30:
						_cond_resched at kernel/sched/core.c:4849
[   71.398789]  ? _cond_resched+0x19/0x30:
						_cond_resched at kernel/sched/core.c:4855
[   71.403210]  ? down_read+0x21/0x40:
						__down_read at arch/x86/include/asm/rwsem.h:83
						 (inlined by) down_read at kernel/locking/rwsem.c:26
[   71.407317]  xfs_file_buffered_aio_read+0x53/0xf0 [xfs]
[   71.413255]  xfs_file_read_iter+0x64/0xc0 [xfs]
[   71.418424]  __vfs_read+0xd2/0x140:
						new_sync_read at fs/read_write.c:402
						 (inlined by) __vfs_read at fs/read_write.c:413
[   71.422504]  vfs_read+0x9b/0x140:
						vfs_read at fs/read_write.c:448
[   71.426392]  SyS_read+0x42/0x90
[   71.430203]  entry_SYSCALL_64_fastpath+0x1a/0x7d:
						entry_SYSCALL_64_fastpath at arch/x86/entry/entry_64.S:210
[   71.435466] RIP: 0033:0x7ff145cae060
[   71.439728] RSP: 002b:00007ffee3f33b98 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[   71.447993] RAX: ffffffffffffffda RBX: 00000000000b1bf2 RCX: 00007ff145cae060
[   71.455801] RDX: 0000000000001000 RSI: 0000000000ff4000 RDI: 0000000000000000
[   71.463637] RBP: 0000000000001000 R08: 0000000000000003 R09: 0000000000003011
[   71.471442] R10: 000000000000086d R11: 0000000000000246 R12: 0000000000ff4000
[   71.479267] R13: 0000000000000000 R14: 0000000000ff4000 R15: 0000000000000000
[   78.848629] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC), nodemask=(null)
[   78.857841] dd cpuset=/ mems_allowed=0-1
[   78.862502] CPU: 0 PID: 6131 Comm: dd Tainted: G           O     4.15.0-rc1 #1
[   78.870437] Call Trace:
[   78.873610]  <IRQ>
[   78.876342]  dump_stack+0x5c/0x7b:
						dump_stack at lib/dump_stack.c:55
[   78.880414]  warn_alloc+0xbe/0x150:
						preempt_count at arch/x86/include/asm/preempt.h:23
						 (inlined by) should_suppress_show_mem at mm/page_alloc.c:3244
						 (inlined by) warn_alloc_show_mem at mm/page_alloc.c:3254
						 (inlined by) warn_alloc at mm/page_alloc.c:3293
[   78.884550]  __alloc_pages_slowpath+0xda7/0xdf0:
						__alloc_pages_slowpath at mm/page_alloc.c:4151
[   78.889822]  ? xhci_urb_enqueue+0x23d/0x580:
						xhci_urb_enqueue at drivers/usb/host/xhci.c:1389
[   78.894713]  __alloc_pages_nodemask+0x269/0x280:
						__alloc_pages_nodemask at mm/page_alloc.c:4245
[   78.899891]  page_frag_alloc+0x11c/0x150:
						__page_frag_cache_refill at mm/page_alloc.c:4335
						 (inlined by) page_frag_alloc at mm/page_alloc.c:4364
[   78.904471]  __netdev_alloc_skb+0xa0/0x110:
						__netdev_alloc_skb at net/core/skbuff.c:415
[   78.909277]  rx_submit+0x3b/0x2e0:
						rx_submit at drivers/net/usb/usbnet.c:488
[   78.913256]  rx_complete+0x196/0x2d0:
						rx_complete at drivers/net/usb/usbnet.c:659
[   78.917560]  __usb_hcd_giveback_urb+0x86/0x100:
						arch_local_irq_restore at arch/x86/include/asm/paravirt.h:777
						 (inlined by) __usb_hcd_giveback_urb at drivers/usb/core/hcd.c:1769
[   78.922681]  xhci_giveback_urb_in_irq+0x86/0x100
[   78.928769]  ? ip_rcv+0x261/0x390:
						NF_HOOK at include/linux/netfilter.h:250
						 (inlined by) ip_rcv at net/ipv4/ip_input.c:493
[   78.932739]  xhci_td_cleanup+0xe7/0x170:
						xhci_td_cleanup at drivers/usb/host/xhci-ring.c:1924
[   78.937308]  handle_tx_event+0x297/0x1190:
						process_bulk_intr_td at drivers/usb/host/xhci-ring.c:2267
						 (inlined by) handle_tx_event at drivers/usb/host/xhci-ring.c:2598
[   78.941990]  xhci_irq+0x300/0xb80:
						xhci_handle_event at drivers/usb/host/xhci-ring.c:2676
						 (inlined by) xhci_irq at drivers/usb/host/xhci-ring.c:2777
[   78.945968]  ? pciehp_isr+0x46/0x320
[   78.950870]  __handle_irq_event_percpu+0x3a/0x1a0:
						__handle_irq_event_percpu at kernel/irq/handle.c:147
[   78.956311]  handle_irq_event_percpu+0x20/0x50:
						handle_irq_event_percpu at kernel/irq/handle.c:189
[   78.961466]  handle_irq_event+0x3d/0x60:
						handle_irq_event at kernel/irq/handle.c:206
[   78.965962]  handle_edge_irq+0x71/0x190:
						handle_edge_irq at kernel/irq/chip.c:796
[   78.970480]  handle_irq+0xa5/0x100:
						handle_irq at arch/x86/kernel/irq_64.c:78
[   78.974565]  do_IRQ+0x41/0xc0:
						do_IRQ at arch/x86/kernel/irq.c:241
[   78.978206]  ? pagevec_move_tail_fn+0x350/0x350:
						__activate_page at mm/swap.c:275
[   78.983412]  common_interrupt+0x96/0x96:
						ret_from_intr at arch/x86/entry/entry_64.S:611
[   78.987887]  </IRQ>
[   78.990638] RIP: 0010:_raw_spin_unlock_irqrestore+0x11/0x20:
						arch_local_irq_restore at arch/x86/include/asm/paravirt.h:777
						 (inlined by) __raw_spin_unlock_irqrestore at include/linux/spinlock_api_smp.h:160
						 (inlined by) _raw_spin_unlock_irqrestore at kernel/locking/spinlock.c:191
[   78.996915] RSP: 0018:ffffc9000a347cf8 EFLAGS: 00000246 ORIG_RAX: ffffffffffffffd9
[   79.005196] RAX: ffff881035e00008 RBX: 000000000000000e RCX: 0000000000000001
[   79.013024] RDX: ffffea003eb91ba0 RSI: 0000000000000246 RDI: 0000000000000246
[   79.020886] RBP: ffff88085d8166a0 R08: ffffea003eb91ba0 R09: 00000000005eb501
[   79.028770] R10: ffff88107ffcd000 R11: ffffffffffffffff R12: 0000000000000246
[   79.036607] R13: ffffffff811b33b0 R14: ffff88107ffcd000 R15: ffffea003eb91bc0
[   79.044528]  ? pagevec_move_tail_fn+0x350/0x350:
						__activate_page at mm/swap.c:275
[   79.049871]  pagevec_lru_move_fn+0xab/0xd0:
						spin_unlock_irqrestore at include/linux/spinlock.h:370
						 (inlined by) pagevec_lru_move_fn at mm/swap.c:212
[   79.054723]  activate_page+0xbb/0xd0:
						__preempt_count_sub at arch/x86/include/asm/preempt.h:81
						 (inlined by) activate_page at mm/swap.c:314
[   79.059035]  mark_page_accessed+0x7a/0x150:
						__read_once_size at include/linux/compiler.h:183
						 (inlined by) compound_head at include/linux/page-flags.h:147
						 (inlined by) ClearPageReferenced at include/linux/page-flags.h:268
						 (inlined by) mark_page_accessed at mm/swap.c:392
[   79.063876]  generic_file_read_iter+0x42d/0x980:
						generic_file_buffered_read at mm/filemap.c:2188
						 (inlined by) generic_file_read_iter at mm/filemap.c:2365
[   79.069112]  ? _cond_resched+0x19/0x30:
						_cond_resched at kernel/sched/core.c:4855
[   79.073611]  ? _cond_resched+0x19/0x30:
						_cond_resched at kernel/sched/core.c:4855
[   79.078092]  ? down_read+0x21/0x40:
						__down_read at arch/x86/include/asm/rwsem.h:83
						 (inlined by) down_read at kernel/locking/rwsem.c:26
[   79.082287]  xfs_file_buffered_aio_read+0x53/0xf0 [xfs]
[   79.088284]  xfs_file_read_iter+0x64/0xc0 [xfs]
[   79.093515]  __vfs_read+0xd2/0x140:
						new_sync_read at fs/read_write.c:402
						 (inlined by) __vfs_read at fs/read_write.c:413
[   79.097639]  vfs_read+0x9b/0x140:
						vfs_read at fs/read_write.c:448
[   79.101563]  SyS_read+0x42/0x90
[   79.105374]  entry_SYSCALL_64_fastpath+0x1a/0x7d:
						entry_SYSCALL_64_fastpath at arch/x86/entry/entry_64.S:210
[   79.110692] RIP: 0033:0x7f2611b8c060
[   79.114910] RSP: 002b:00007ffd6360fda8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[   79.123181] RAX: ffffffffffffffda RBX: 00000000000c4a1e RCX: 00007f2611b8c060
[   79.131037] RDX: 0000000000001000 RSI: 00000000009a4000 RDI: 0000000000000000
[   79.138858] RBP: 0000000000001000 R08: 0000000000000003 R09: 0000000000003011
[   79.146708] R10: 000000000000086d R11: 0000000000000246 R12: 00000000009a4000
[   79.154579] R13: 0000000000000000 R14: 00000000009a4000 R15: 0000000000000000
[   85.364572] Terminated
[   85.364576]
[   85.806857] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-append-var?job_file=/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-file-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-58530-nmcjkk-0.yaml&job_state=post_run -o /dev/null

Thanks,
Fengguang

--y7hnjbnavwaasi5b
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-lkp-skl-2sp2:20171129101019:x86_64-rhel-7.2:gcc-7:4.15.0-rc1:1"
Content-Transfer-Encoding: quoted-printable

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 4.15.0-rc1 (kbuild@ivb42) (gcc version 7.2.1 2=
0171025 (Debian 7.2.0-12)) #1 SMP Mon Nov 27 09:58:37 CST 2017
[    0.000000] Command line: ip=3D::::lkp-skl-2sp2::dhcp root=3D/dev/ram0 u=
ser=3Dlkp job=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-file-re=
adtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-58530=
-nmcjkk-0.yaml ARCH=3Dx86_64 kconfig=3Dx86_64-rhel-7.2 branch=3Dlinus/maste=
r commit=3D4fbd8d194f06c8a3fd2af1ce560ddb31f7ec8323 BOOT_IMAGE=3D/pkg/linux=
/x86_64-rhel-7.2/gcc-7/4fbd8d194f06c8a3fd2af1ce560ddb31f7ec8323/vmlinuz-4.1=
5.0-rc1 acpi_rsdp=3D0x6C295014 max_uptime=3D1500 RESULT_ROOT=3D/result/vm-s=
calability/300s-lru-file-readtwice-performance/lkp-skl-2sp2/debian-x86_64-2=
016-08-31.cgz/x86_64-rhel-7.2/gcc-7/4fbd8d194f06c8a3fd2af1ce560ddb31f7ec832=
3/0 LKP_SERVER=3Dinn debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_c=
pu_stall_timeout=3D100 net.ifnames=3D0 printk.devkmsg=3Don panic=3D-1 softl=
ockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_r=
amdisk=3D0 drbd.minor_count=3D8 systemd.log_level=3Derr ignore_loglevel con=
sole=3Dtty0 earlyprintk=3DttyS0,115200 console=3DttyS0,115200 vga=3Dnormal =
rw
[    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point=
 registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x008: 'MPX bounds registe=
rs'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x010: 'MPX CSR'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x020: 'AVX-512 opmask'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x040: 'AVX-512 Hi256'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x080: 'AVX-512 ZMM_Hi256'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x200: 'Protection Keys Us=
er registers'
[    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.000000] x86/fpu: xstate_offset[3]:  832, xstate_sizes[3]:   64
[    0.000000] x86/fpu: xstate_offset[4]:  896, xstate_sizes[4]:   64
[    0.000000] x86/fpu: xstate_offset[5]:  960, xstate_sizes[5]:   64
[    0.000000] x86/fpu: xstate_offset[6]: 1024, xstate_sizes[6]:  512
[    0.000000] x86/fpu: xstate_offset[7]: 1536, xstate_sizes[7]: 1024
[    0.000000] x86/fpu: xstate_offset[9]: 2560, xstate_sizes[9]:    8
[    0.000000] x86/fpu: Enabled xstate features 0x2ff, context size is 2568=
 bytes, using 'compacted' format.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000000a0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000677f0fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000677f1000-0x0000000067a17fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000067a18000-0x0000000067d43fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000067d44000-0x0000000067d69fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x0000000067d6a000-0x0000000067d8ffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000067d90000-0x0000000067dc3fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x0000000067dc4000-0x0000000067e2bfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000067e2c000-0x0000000067e45fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x0000000067e46000-0x0000000067e5ffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000067e60000-0x0000000067e8afff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x0000000067e8b000-0x0000000068c82fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000068c83000-0x0000000069c82fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000069c83000-0x000000006b465fff] usable
[    0.000000] BIOS-e820: [mem 0x000000006b466000-0x000000006b765fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x000000006b766000-0x000000006c195fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x000000006c196000-0x000000006c295fff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x000000006c296000-0x000000006fafffff] usable
[    0.000000] BIOS-e820: [mem 0x000000006fb00000-0x000000008fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fe000000-0x00000000fe010fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000107fffffff] usable
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI not present or invalid.
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x1080000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask 3FF000000000 write-back
[    0.000000]   1 base 001000000000 mask 3FFF80000000 write-back
[    0.000000]   2 base 000080000000 mask 3FFF80000000 uncachable
[    0.000000]   3 base 00007F000000 mask 3FFFFF000000 uncachable
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT=
 =20
[    0.000000] e820: update [mem 0x7f000000-0xffffffff] usable =3D=3D> rese=
rved
[    0.000000] e820: last_pfn =3D 0x6fb00 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] Scan for SMP in [mem 0x0009c000-0x0009c3ff]
[    0.000000] Base memory trampoline at [ffff880000096000] 96000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] BRK [0x107f90a000, 0x107f90afff] PGTABLE
[    0.000000] BRK [0x107f90b000, 0x107f90bfff] PGTABLE
[    0.000000] BRK [0x107f90c000, 0x107f90cfff] PGTABLE
[    0.000000] BRK [0x107f90d000, 0x107f90dfff] PGTABLE
[    0.000000] BRK [0x107f90e000, 0x107f90efff] PGTABLE
[    0.000000] BRK [0x107f90f000, 0x107f90ffff] PGTABLE
[    0.000000] RAMDISK: [mem 0x1068a28000-0x107dffffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000006C295014 000024 (v02 INTEL )
[    0.000000] ACPI: XSDT 0x000000006C1A7188 0000F4 (v01 INTEL  S2600WF  00=
000000 INTL 20091013)
[    0.000000] ACPI: FACP 0x000000006C292000 00010C (v05 INTEL  S2600WF  00=
000000 INTL 20091013)
[    0.000000] ACPI: DSDT 0x000000006C24E000 035F66 (v02 INTEL  S2600WF  00=
000003 INTL 20091013)
[    0.000000] ACPI: FACS 0x000000006C10E000 000040
[    0.000000] ACPI: SSDT 0x000000006C293000 0004B0 (v02 INTEL  S2600WF  00=
000000 MSFT 0100000D)
[    0.000000] ACPI: UEFI 0x000000006C185000 000042 (v01 INTEL  S2600WF  00=
000002 INTL 20091013)
[    0.000000] ACPI: UEFI 0x000000006C110000 00005C (v01 INTEL  RstUefiV 00=
000000      00000000)
[    0.000000] ACPI: HPET 0x000000006C291000 000038 (v01 INTEL  S2600WF  00=
000001 INTL 20091013)
[    0.000000] ACPI: APIC 0x000000006C28F000 0016DE (v03 INTEL  S2600WF  00=
000000 INTL 20091013)
[    0.000000] ACPI: MCFG 0x000000006C28E000 00003C (v01 INTEL  S2600WF  00=
000001 INTL 20091013)
[    0.000000] ACPI: MSCT 0x000000006C28D000 000090 (v01 INTEL  S2600WF  00=
000001 INTL 20091013)
[    0.000000] ACPI: PCAT 0x000000006C28C000 000048 (v01 INTEL  S2600WF  00=
000002 INTL 20091013)
[    0.000000] ACPI: PCCT 0x000000006C28B000 0000AC (v01 INTEL  S2600WF  00=
000002 INTL 20091013)
[    0.000000] ACPI: RASF 0x000000006C28A000 000030 (v01 INTEL  S2600WF  00=
000001 INTL 20091013)
[    0.000000] ACPI: SLIT 0x000000006C289000 00006C (v01 INTEL  S2600WF  00=
000001 INTL 20091013)
[    0.000000] ACPI: SRAT 0x000000006C286000 002830 (v03 INTEL  S2600WF  00=
000002 INTL 20091013)
[    0.000000] ACPI: SPMI 0x000000006C285000 000041 (v05 INTEL  S2600WF  00=
000001 INTL 20091013)
[    0.000000] ACPI: WDDT 0x000000006C284000 000040 (v01 INTEL  S2600WF  00=
000000 INTL 20091013)
[    0.000000] ACPI: OEM4 0x000000006C1AB000 0A27C4 (v02 INTEL  CPU  CST 00=
003000 INTL 20140828)
[    0.000000] ACPI: OEM1 0x0000000067E60000 02A2C4 (v02 INTEL  CPU EIST 00=
003000 INTL 20140828)
[    0.000000] ACPI: OEM2 0x0000000067E2C000 019464 (v02 INTEL  CPU  HWP 00=
003000 INTL 20140828)
[    0.000000] ACPI: SSDT 0x0000000067D90000 033990 (v02 INTEL  S2600WF  00=
004000 INTL 20091013)
[    0.000000] ACPI: OEM3 0x0000000067D44000 025F64 (v02 INTEL  CPU  TST 00=
003000 INTL 20140828)
[    0.000000] ACPI: SSDT 0x000000006C1A8000 002AF6 (v02 INTEL  S2600WF  00=
000002 INTL 20091013)
[    0.000000] ACPI: HEST 0x000000006C294000 0000A8 (v01 INTEL  S2600WF  00=
000001 INTL 00000001)
[    0.000000] ACPI: BERT 0x000000006C1A6000 000030 (v01 INTEL  S2600WF  00=
000001 INTL 00000001)
[    0.000000] ACPI: ERST 0x000000006C1A5000 000230 (v01 INTEL  S2600WF  00=
000001 INTL 00000001)
[    0.000000] ACPI: EINJ 0x000000006C1A4000 000150 (v01 INTEL  S2600WF  00=
000001 INTL 00000001)
[    0.000000] ACPI: BGRT 0x000000006C1A3000 000038 (v01 INTEL  S2600WF  00=
000002 INTL 20091013)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x16 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x18 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x20 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x22 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x24 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x26 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x28 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x2a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x2c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x30 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x32 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x34 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x36 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x38 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x3a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x3c -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x40 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x42 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x44 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x46 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x48 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x4a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x4c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x50 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x52 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x54 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x56 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x58 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x5a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x5c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x60 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x62 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x64 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x66 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x68 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x6a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x6c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x70 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x72 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x74 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x76 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x78 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x7a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x7c -> Node 1
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x17 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x19 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x1d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x21 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x23 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x25 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x27 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x29 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x2b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x2d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x31 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x33 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x35 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x37 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x39 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x3b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x3d -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x41 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x43 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x45 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x47 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x49 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x4b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x4d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x51 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x53 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x55 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x57 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x59 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x5b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x5d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x61 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x63 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x65 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x67 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x69 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x6b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x6d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x71 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x73 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x75 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x77 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x79 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x7b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x7d -> Node 1
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x87fffffff]
[    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x880000000-0x107fffffff]
[    0.000000] NUMA: Initialized distance table, cnt=3D2
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-=
0x87fffffff] -> [mem 0x00000000-0x87fffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x87ffd5000-0x87fffffff]
[    0.000000] NODE_DATA(1) allocated [mem 0x107ffcd000-0x107fff7fff]
[    0.000000] cma: Reserved 200 MiB at 0x000000105c000000
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000107fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009ffff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000677f0fff]
[    0.000000]   node   0: [mem 0x0000000067a18000-0x0000000067d43fff]
[    0.000000]   node   0: [mem 0x0000000067d6a000-0x0000000067d8ffff]
[    0.000000]   node   0: [mem 0x0000000067dc4000-0x0000000067e2bfff]
[    0.000000]   node   0: [mem 0x0000000067e46000-0x0000000067e5ffff]
[    0.000000]   node   0: [mem 0x0000000067e8b000-0x0000000068c82fff]
[    0.000000]   node   0: [mem 0x0000000069c83000-0x000000006b465fff]
[    0.000000]   node   0: [mem 0x000000006c296000-0x000000006fafffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000087fffffff]
[    0.000000]   node   1: [mem 0x0000000880000000-0x000000107fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000087ffff=
fff]
[    0.000000] On node 0 totalpages: 8313257
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 25 pages reserved
[    0.000000]   DMA zone: 3999 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 6953 pages used for memmap
[    0.000000]   DMA32 zone: 444938 pages, LIFO batch:31
[    0.000000]   Normal zone: 122880 pages used for memmap
[    0.000000]   Normal zone: 7864320 pages, LIFO batch:31
[    0.000000] Initmem setup node 1 [mem 0x0000000880000000-0x000000107ffff=
fff]
[    0.000000] On node 1 totalpages: 8388608
[    0.000000]   Normal zone: 131072 pages used for memmap
[    0.000000]   Normal zone: 8388608 pages, LIFO batch:31
[    0.000000] Reserved but unavailable: 97 pages
[    0.000000] ACPI: PM-Timer IO Port: 0x508
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: X2APIC_NMI (uid[0xffffffff] high level lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high level lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24=
-31
[    0.000000] IOAPIC[2]: apic_id 10, version 32, address 0xfec08000, GSI 3=
2-39
[    0.000000] IOAPIC[3]: apic_id 11, version 32, address 0xfec10000, GSI 4=
0-47
[    0.000000] IOAPIC[4]: apic_id 12, version 32, address 0xfec18000, GSI 4=
8-55
[    0.000000] IOAPIC[5]: apic_id 15, version 32, address 0xfec20000, GSI 7=
2-79
[    0.000000] IOAPIC[6]: apic_id 16, version 32, address 0xfec28000, GSI 8=
0-87
[    0.000000] IOAPIC[7]: apic_id 17, version 32, address 0xfec30000, GSI 8=
8-95
[    0.000000] IOAPIC[8]: apic_id 18, version 32, address 0xfec38000, GSI 9=
6-103
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC =
INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC =
INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC =
INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC =
INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC =
INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] [Firmware Bug]: TSC_DEADLINE disabled due to Errata; please =
update microcode to version: 0xffffffff (or later)
[    0.000000] smpboot: Allowing 336 CPUs, 224 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec01000)
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec08000)
[    0.000000] mapped IOAPIC to ffffffffff5f8000 (fec10000)
[    0.000000] mapped IOAPIC to ffffffffff5f7000 (fec18000)
[    0.000000] mapped IOAPIC to ffffffffff5f6000 (fec20000)
[    0.000000] mapped IOAPIC to ffffffffff5f5000 (fec28000)
[    0.000000] mapped IOAPIC to ffffffffff5f4000 (fec30000)
[    0.000000] mapped IOAPIC to ffffffffff5f3000 (fec38000)
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x677f1000-0x67a17fff]
[    0.000000] PM: Registered nosave memory: [mem 0x67d44000-0x67d69fff]
[    0.000000] PM: Registered nosave memory: [mem 0x67d90000-0x67dc3fff]
[    0.000000] PM: Registered nosave memory: [mem 0x67e2c000-0x67e45fff]
[    0.000000] PM: Registered nosave memory: [mem 0x67e60000-0x67e8afff]
[    0.000000] PM: Registered nosave memory: [mem 0x68c83000-0x69c82fff]
[    0.000000] PM: Registered nosave memory: [mem 0x6b466000-0x6b765fff]
[    0.000000] PM: Registered nosave memory: [mem 0x6b766000-0x6c195fff]
[    0.000000] PM: Registered nosave memory: [mem 0x6c196000-0x6c295fff]
[    0.000000] PM: Registered nosave memory: [mem 0x6fb00000-0x8fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x90000000-0xfdffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfe000000-0xfe010fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfe011000-0xffffffff]
[    0.000000] e820: [mem 0x90000000-0xfdffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0=
xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] random: fast init done
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:336 nr_cpu_ids:33=
6 nr_node_ids:2
[    0.000000] percpu: Embedded 39 pages/cpu @ffff88085d800000 s119448 r819=
2 d32104 u262144
[    0.000000] pcpu-alloc: s119448 r8192 d32104 u262144 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 000 001 002 003 004 005 006 007=20
[    0.000000] pcpu-alloc: [0] 008 009 010 011 012 013 014 015=20
[    0.000000] pcpu-alloc: [0] 016 017 018 019 020 021 022 023=20
[    0.000000] pcpu-alloc: [0] 024 025 026 027 056 057 058 059=20
[    0.000000] pcpu-alloc: [0] 060 061 062 063 064 065 066 067=20
[    0.000000] pcpu-alloc: [0] 068 069 070 071 072 073 074 075=20
[    0.000000] pcpu-alloc: [0] 076 077 078 079 080 081 082 083=20
[    0.000000] pcpu-alloc: [0] 112 114 116 118 120 122 124 126=20
[    0.000000] pcpu-alloc: [0] 128 130 132 134 136 138 140 142=20
[    0.000000] pcpu-alloc: [0] 144 146 148 150 152 154 156 158=20
[    0.000000] pcpu-alloc: [0] 160 162 164 166 168 170 172 174=20
[    0.000000] pcpu-alloc: [0] 176 178 180 182 184 186 188 190=20
[    0.000000] pcpu-alloc: [0] 192 194 196 198 200 202 204 206=20
[    0.000000] pcpu-alloc: [0] 208 210 212 214 216 218 220 222=20
[    0.000000] pcpu-alloc: [0] 224 226 228 230 232 234 236 238=20
[    0.000000] pcpu-alloc: [0] 240 242 244 246 248 250 252 254=20
[    0.000000] pcpu-alloc: [0] 256 258 260 262 264 266 268 270=20
[    0.000000] pcpu-alloc: [0] 272 274 276 278 280 282 284 286=20
[    0.000000] pcpu-alloc: [0] 288 290 292 294 296 298 300 302=20
[    0.000000] pcpu-alloc: [0] 304 306 308 310 312 314 316 318=20
[    0.000000] pcpu-alloc: [0] 320 322 324 326 328 330 332 334=20
[    0.000000] pcpu-alloc: [1] 028 029 030 031 032 033 034 035=20
[    0.000000] pcpu-alloc: [1] 036 037 038 039 040 041 042 043=20
[    0.000000] pcpu-alloc: [1] 044 045 046 047 048 049 050 051=20
[    0.000000] pcpu-alloc: [1] 052 053 054 055 084 085 086 087=20
[    0.000000] pcpu-alloc: [1] 088 089 090 091 092 093 094 095=20
[    0.000000] pcpu-alloc: [1] 096 097 098 099 100 101 102 103=20
[    0.000000] pcpu-alloc: [1] 104 105 106 107 108 109 110 111=20
[    0.000000] pcpu-alloc: [1] 113 115 117 119 121 123 125 127=20
[    0.000000] pcpu-alloc: [1] 129 131 133 135 137 139 141 143=20
[    0.000000] pcpu-alloc: [1] 145 147 149 151 153 155 157 159=20
[    0.000000] pcpu-alloc: [1] 161 163 165 167 169 171 173 175=20
[    0.000000] pcpu-alloc: [1] 177 179 181 183 185 187 189 191=20
[    0.000000] pcpu-alloc: [1] 193 195 197 199 201 203 205 207=20
[    0.000000] pcpu-alloc: [1] 209 211 213 215 217 219 221 223=20
[    0.000000] pcpu-alloc: [1] 225 227 229 231 233 235 237 239=20
[    0.000000] pcpu-alloc: [1] 241 243 245 247 249 251 253 255=20
[    0.000000] pcpu-alloc: [1] 257 259 261 263 265 267 269 271=20
[    0.000000] pcpu-alloc: [1] 273 275 277 279 281 283 285 287=20
[    0.000000] pcpu-alloc: [1] 289 291 293 295 297 299 301 303=20
[    0.000000] pcpu-alloc: [1] 305 307 309 311 313 315 317 319=20
[    0.000000] pcpu-alloc: [1] 321 323 325 327 329 331 333 335=20
[    0.000000] Built 2 zonelists, mobility grouping on.  Total pages: 16440=
871
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: ip=3D::::lkp-skl-2sp2::dhcp root=3D/dev=
/ram0 user=3Dlkp job=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-=
file-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-2017112=
8-58530-nmcjkk-0.yaml ARCH=3Dx86_64 kconfig=3Dx86_64-rhel-7.2 branch=3Dlinu=
s/master commit=3D4fbd8d194f06c8a3fd2af1ce560ddb31f7ec8323 BOOT_IMAGE=3D/pk=
g/linux/x86_64-rhel-7.2/gcc-7/4fbd8d194f06c8a3fd2af1ce560ddb31f7ec8323/vmli=
nuz-4.15.0-rc1 acpi_rsdp=3D0x6C295014 max_uptime=3D1500 RESULT_ROOT=3D/resu=
lt/vm-scalability/300s-lru-file-readtwice-performance/lkp-skl-2sp2/debian-x=
86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-7/4fbd8d194f06c8a3fd2af1ce560ddb31=
f7ec8323/0 LKP_SERVER=3Dinn debug apic=3Ddebug sysrq_always_enabled rcupdat=
e.rcu_cpu_stall_timeout=3D100 net.ifnames=3D0 printk.devkmsg=3Don panic=3D-=
1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 p=
rompt_ramdisk=3D0 drbd.minor_count=3D8 systemd.log_level=3Derr ignore_logle=
vel console=3Dtty0 earlyprintk=3DttyS0,115200 console=3DttyS0,115200 vga=3D=
normal rw
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 1372160 bytes
[    0.000000] log_buf_len min size: 1048576 bytes
[    0.000000] log_buf_len: 4194304 bytes
[    0.000000] early log buf free: 1021704(97%)
[    0.000000] Memory: 65059416K/66807460K available (9339K kernel code, 25=
33K rwdata, 4012K rodata, 2304K init, 2516K bss, 1543244K reserved, 204800K=
 cma-reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D336,=
 Nodes=3D2
[    0.000000] ftrace: allocating 38525 entries in 151 pages
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D8192 to nr_cpu_ids=3D33=
6.
[    0.000000] 	RCU CPU stall warnings timeout set to 100 (rcu_cpu_stall_ti=
meout).
[    0.000000] 	Tasks RCU enabled.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D336
[    0.000000] NR_IRQS: 524544, nr_irqs: 4472, preallocated irqs: 16
[    0.000000] 	Offload RCU callbacks from CPUs: .
[    0.000000] spurious APIC interrupt through vector ff on CPU#0, should n=
ever happen.
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] mempolicy: Enabling automatic NUMA balancing. Configure with=
 numa_balancing=3D or the kernel.numa_balancing sysctl
[    0.000000] ACPI: Core revision 20170831
[    0.000000] ACPI: 4 ACPI AML tables successfully acquired and loaded
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, =
max_idle_ns: 79635855245 ns
[    0.000000] hpet clockevent registered
[    0.000000] APIC: Switch to symmetric I/O mode setup
[    0.000000] x2apic: IRQ remapping doesn't support X2APIC mode
[    0.000000] Switched APIC routing to physical flat.
[    0.000000] masked ExtINT on CPU#0
[    0.000000] ENABLING IO-APIC IRQs
[    0.000000] init IO_APIC IRQs
[    0.000000]  apic 8 pin 0 not connected
[    0.000000] IOAPIC[0]: Set routing entry (8-1 -> 0xef -> IRQ 1 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-3 -> 0xef -> IRQ 3 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-4 -> 0xef -> IRQ 4 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-5 -> 0xef -> IRQ 5 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-6 -> 0xef -> IRQ 6 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-7 -> 0xef -> IRQ 7 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-8 -> 0xef -> IRQ 8 Mode:0 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-9 -> 0xef -> IRQ 9 Mode:1 Ac=
tive:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-10 -> 0xef -> IRQ 10 Mode:0 =
Active:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-11 -> 0xef -> IRQ 11 Mode:0 =
Active:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-12 -> 0xef -> IRQ 12 Mode:0 =
Active:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-13 -> 0xef -> IRQ 13 Mode:0 =
Active:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-14 -> 0xef -> IRQ 14 Mode:0 =
Active:0 Dest:0)
[    0.000000] IOAPIC[0]: Set routing entry (8-15 -> 0xef -> IRQ 15 Mode:0 =
Active:0 Dest:0)
[    0.000000]  apic 8 pin 16 not connected
[    0.000000]  apic 8 pin 17 not connected
[    0.000000]  apic 8 pin 18 not connected
[    0.000000]  apic 8 pin 19 not connected
[    0.000000]  apic 8 pin 20 not connected
[    0.000000]  apic 8 pin 21 not connected
[    0.000000]  apic 8 pin 22 not connected
[    0.000000]  apic 8 pin 23 not connected
[    0.000000]  apic 9 pin 0 not connected
[    0.000000]  apic 9 pin 1 not connected
[    0.000000]  apic 9 pin 2 not connected
[    0.000000]  apic 9 pin 3 not connected
[    0.000000]  apic 9 pin 4 not connected
[    0.000000]  apic 9 pin 5 not connected
[    0.000000]  apic 9 pin 6 not connected
[    0.000000]  apic 9 pin 7 not connected
[    0.000000]  apic 10 pin 0 not connected
[    0.000000]  apic 10 pin 1 not connected
[    0.000000]  apic 10 pin 2 not connected
[    0.000000]  apic 10 pin 3 not connected
[    0.000000]  apic 10 pin 4 not connected
[    0.000000]  apic 10 pin 5 not connected
[    0.000000]  apic 10 pin 6 not connected
[    0.000000]  apic 10 pin 7 not connected
[    0.000000]  apic 11 pin 0 not connected
[    0.000000]  apic 11 pin 1 not connected
[    0.000000]  apic 11 pin 2 not connected
[    0.000000]  apic 11 pin 3 not connected
[    0.000000]  apic 11 pin 4 not connected
[    0.000000]  apic 11 pin 5 not connected
[    0.000000]  apic 11 pin 6 not connected
[    0.000000]  apic 11 pin 7 not connected
[    0.000000]  apic 12 pin 0 not connected
[    0.000000]  apic 12 pin 1 not connected
[    0.000000]  apic 12 pin 2 not connected
[    0.000000]  apic 12 pin 3 not connected
[    0.000000]  apic 12 pin 4 not connected
[    0.000000]  apic 12 pin 5 not connected
[    0.000000]  apic 12 pin 6 not connected
[    0.000000]  apic 12 pin 7 not connected
[    0.000000]  apic 15 pin 0 not connected
[    0.000000]  apic 15 pin 1 not connected
[    0.000000]  apic 15 pin 2 not connected
[    0.000000]  apic 15 pin 3 not connected
[    0.000000]  apic 15 pin 4 not connected
[    0.000000]  apic 15 pin 5 not connected
[    0.000000]  apic 15 pin 6 not connected
[    0.000000]  apic 15 pin 7 not connected
[    0.000000]  apic 16 pin 0 not connected
[    0.000000]  apic 16 pin 1 not connected
[    0.000000]  apic 16 pin 2 not connected
[    0.000000]  apic 16 pin 3 not connected
[    0.000000]  apic 16 pin 4 not connected
[    0.000000]  apic 16 pin 5 not connected
[    0.000000]  apic 16 pin 6 not connected
[    0.000000]  apic 16 pin 7 not connected
[    0.000000]  apic 17 pin 0 not connected
[    0.000000]  apic 17 pin 1 not connected
[    0.000000]  apic 17 pin 2 not connected
[    0.000000]  apic 17 pin 3 not connected
[    0.000000]  apic 17 pin 4 not connected
[    0.000000]  apic 17 pin 5 not connected
[    0.000000]  apic 17 pin 6 not connected
[    0.000000]  apic 17 pin 7 not connected
[    0.000000]  apic 18 pin 0 not connected
[    0.000000]  apic 18 pin 1 not connected
[    0.000000]  apic 18 pin 2 not connected
[    0.000000]  apic 18 pin 3 not connected
[    0.000000]  apic 18 pin 4 not connected
[    0.000000]  apic 18 pin 5 not connected
[    0.000000]  apic 18 pin 6 not connected
[    0.000000]  apic 18 pin 7 not connected
[    0.000000] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.005000] tsc: Detected 1800.000 MHz processor
[    0.006000] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 3600.00 BogoMIPS (lpj=3D1800000)
[    0.007001] pid_max: default: 344064 minimum: 2688
[    0.009193] Security Framework initialized
[    0.010001] SELinux:  Initializing.
[    0.011008] SELinux:  Starting in permissive mode
[    0.023309] Dentry cache hash table entries: 8388608 (order: 14, 6710886=
4 bytes)
[    0.030072] Inode-cache hash table entries: 4194304 (order: 13, 33554432=
 bytes)
[    0.031436] Mount-cache hash table entries: 131072 (order: 8, 1048576 by=
tes)
[    0.033038] Mountpoint-cache hash table entries: 131072 (order: 8, 10485=
76 bytes)
[    0.036157] CPU: Physical Processor ID: 0
[    0.037001] CPU: Processor Core ID: 0
[    0.038017] mce: CPU supports 20 MCE banks
[    0.039015] CPU0: Thermal monitoring enabled (TM1)
[    0.040036] process: using mwait in idle threads
[    0.041003] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8
[    0.042000] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1GB 4
[    0.044842] Freeing SMP alternatives memory: 40K
[    0.047043] Using local APIC timer interrupts.
[    0.047043] calibrating APIC timer ...
[    0.049000] ... lapic delta =3D 155877
[    0.049000] ... PM-Timer delta =3D 357940
[    0.049000] ... PM-Timer result ok
[    0.049000] ..... delta 155877
[    0.049000] ..... mult: 6694866
[    0.049000] ..... calibration result: 24940
[    0.049000] ..... CPU clock speed is 1795.0706 MHz.
[    0.049000] ..... host bus clock speed is 24.0940 MHz.
[    0.049041] smpboot: CPU0: Intel 06/55 (family: 0x6, model: 0x55, steppi=
ng: 0x2)
[    0.050480] Performance Events: PEBS fmt3+, Skylake events, 32-deep LBR,=
 full-width counters, Intel PMU driver.
[    0.051003] ... version:                4
[    0.052001] ... bit width:              48
[    0.053000] ... generic registers:      4
[    0.054003] ... value mask:             0000ffffffffffff
[    0.055001] ... max period:             00007fffffffffff
[    0.056000] ... fixed-purpose events:   3
[    0.057000] ... event mask:             000000070000000f
[    0.058363] Hierarchical SRCU implementation.
[    0.083496] smp: Bringing up secondary CPUs ...
[    0.088249] NMI watchdog: Enabled. Permanently consumes one hw-PMU count=
er.
[    0.089148] x86: Booting SMP configuration:
[    0.090002] .... node  #0, CPUs:          #1
[    0.001000] masked ExtINT on CPU#1
[    0.102162]    #2
[    0.001000] masked ExtINT on CPU#2
[    0.111199]    #3
[    0.001000] masked ExtINT on CPU#3
[    0.120383]    #4
[    0.001000] masked ExtINT on CPU#4
[    0.129535]    #5
[    0.001000] masked ExtINT on CPU#5
[    0.139172]    #6
[    0.001000] masked ExtINT on CPU#6
[    0.148359]    #7
[    0.001000] masked ExtINT on CPU#7
[    0.158132]    #8
[    0.001000] masked ExtINT on CPU#8
[    0.167167]    #9
[    0.001000] masked ExtINT on CPU#9
[    0.176222]   #10
[    0.001000] masked ExtINT on CPU#10
[    0.185551]   #11
[    0.001000] masked ExtINT on CPU#11
[    0.195169]   #12
[    0.001000] masked ExtINT on CPU#12
[    0.204396]   #13
[    0.001000] masked ExtINT on CPU#13
[    0.214165]   #14
[    0.001000] masked ExtINT on CPU#14
[    0.223357]   #15
[    0.001000] masked ExtINT on CPU#15
[    0.233093]   #16
[    0.001000] masked ExtINT on CPU#16
[    0.242170]   #17
[    0.001000] masked ExtINT on CPU#17
[    0.251385]   #18
[    0.001000] masked ExtINT on CPU#18
[    0.261087]   #19
[    0.001000] masked ExtINT on CPU#19
[    0.270172]   #20
[    0.001000] masked ExtINT on CPU#20
[    0.279558]   #21
[    0.001000] masked ExtINT on CPU#21
[    0.289202]   #22
[    0.001000] masked ExtINT on CPU#22
[    0.299014]   #23
[    0.001000] masked ExtINT on CPU#23
[    0.308170]   #24
[    0.001000] masked ExtINT on CPU#24
[    0.317219]   #25
[    0.001000] masked ExtINT on CPU#25
[    0.327031]   #26
[    0.001000] masked ExtINT on CPU#26
[    0.336209]   #27
[    0.001000] masked ExtINT on CPU#27
[    0.346205] .... node  #1, CPUs:    #28
[    0.001000] masked ExtINT on CPU#28
[    0.418304]   #29
[    0.001000] masked ExtINT on CPU#29
[    0.001000] [Firmware Bug]: TSC ADJUST differs within socket(s), fixing =
all errors
[    0.428217]   #30
[    0.001000] masked ExtINT on CPU#30
[    0.438027]   #31
[    0.001000] masked ExtINT on CPU#31
[    0.447119]   #32
[    0.001000] masked ExtINT on CPU#32
[    0.456183]   #33
[    0.001000] masked ExtINT on CPU#33
[    0.465551]   #34
[    0.001000] masked ExtINT on CPU#34
[    0.475224]   #35
[    0.001000] masked ExtINT on CPU#35
[    0.484582]   #36
[    0.001000] masked ExtINT on CPU#36
[    0.494148]   #37
[    0.001000] masked ExtINT on CPU#37
[    0.503207]   #38
[    0.001000] masked ExtINT on CPU#38
[    0.512471]   #39
[    0.001000] masked ExtINT on CPU#39
[    0.522117]   #40
[    0.001000] masked ExtINT on CPU#40
[    0.531265]   #41
[    0.001000] masked ExtINT on CPU#41
[    0.541102]   #42
[    0.001000] masked ExtINT on CPU#42
[    0.550191]   #43
[    0.001000] masked ExtINT on CPU#43
[    0.559536]   #44
[    0.001000] masked ExtINT on CPU#44
[    0.569148]   #45
[    0.001000] masked ExtINT on CPU#45
[    0.578193]   #46
[    0.001000] masked ExtINT on CPU#46
[    0.587433]   #47
[    0.001000] masked ExtINT on CPU#47
[    0.597118]   #48
[    0.001000] masked ExtINT on CPU#48
[    0.606280]   #49
[    0.001000] masked ExtINT on CPU#49
[    0.616116]   #50
[    0.001000] masked ExtINT on CPU#50
[    0.625264]   #51
[    0.001000] masked ExtINT on CPU#51
[    0.634484]   #52
[    0.001000] masked ExtINT on CPU#52
[    0.644145]   #53
[    0.001000] masked ExtINT on CPU#53
[    0.653223]   #54
[    0.001000] masked ExtINT on CPU#54
[    0.663075]   #55
[    0.001000] masked ExtINT on CPU#55
[    0.672444] .... node  #0, CPUs:    #56
[    0.001000] masked ExtINT on CPU#56
[    0.682179]   #57
[    0.001000] masked ExtINT on CPU#57
[    0.691486]   #58
[    0.001000] masked ExtINT on CPU#58
[    0.701174]   #59
[    0.001000] masked ExtINT on CPU#59
[    0.710310]   #60
[    0.001000] masked ExtINT on CPU#60
[    0.719565]   #61
[    0.001000] masked ExtINT on CPU#61
[    0.729227]   #62
[    0.001000] masked ExtINT on CPU#62
[    0.739008]   #63
[    0.001000] masked ExtINT on CPU#63
[    0.748229]   #64
[    0.001000] masked ExtINT on CPU#64
[    0.757575]   #65
[    0.001000] masked ExtINT on CPU#65
[    0.767173]   #66
[    0.001000] masked ExtINT on CPU#66
[    0.776283]   #67
[    0.001000] masked ExtINT on CPU#67
[    0.786075]   #68
[    0.001000] masked ExtINT on CPU#68
[    0.795234]   #69
[    0.001000] masked ExtINT on CPU#69
[    0.805161]   #70
[    0.001000] masked ExtINT on CPU#70
[    0.814263]   #71
[    0.001000] masked ExtINT on CPU#71
[    0.824085]   #72
[    0.001000] masked ExtINT on CPU#72
[    0.833237]   #73
[    0.001000] masked ExtINT on CPU#73
[    0.842460]   #74
[    0.001000] masked ExtINT on CPU#74
[    0.852176]   #75
[    0.001000] masked ExtINT on CPU#75
[    0.861238]   #76
[    0.001000] masked ExtINT on CPU#76
[    0.871170]   #77
[    0.001000] masked ExtINT on CPU#77
[    0.880433]   #78
[    0.001000] masked ExtINT on CPU#78
[    0.890174]   #79
[    0.001000] masked ExtINT on CPU#79
[    0.899210]   #80
[    0.001000] masked ExtINT on CPU#80
[    0.908499]   #81
[    0.001000] masked ExtINT on CPU#81
[    0.918242]   #82
[    0.001000] masked ExtINT on CPU#82
[    0.927564]   #83
[    0.001000] masked ExtINT on CPU#83
[    0.937245] .... node  #1, CPUs:    #84
[    0.001000] masked ExtINT on CPU#84
[    0.949158]   #85
[    0.001000] masked ExtINT on CPU#85
[    0.958554]   #86
[    0.001000] masked ExtINT on CPU#86
[    0.968259]   #87
[    0.001000] masked ExtINT on CPU#87
[    0.977597]   #88
[    0.001000] masked ExtINT on CPU#88
[    0.987153]   #89
[    0.001000] masked ExtINT on CPU#89
[    0.996524]   #90
[    0.001000] masked ExtINT on CPU#90
[    1.006265]   #91
[    0.001000] masked ExtINT on CPU#91
[    1.015616]   #92
[    0.001000] masked ExtINT on CPU#92
[    1.025156]   #93
[    0.001000] masked ExtINT on CPU#93
[    1.034348]   #94
[    0.001000] masked ExtINT on CPU#94
[    1.044154]   #95
[    0.001000] masked ExtINT on CPU#95
[    1.053299]   #96
[    0.001000] masked ExtINT on CPU#96
[    1.063158]   #97
[    0.001000] masked ExtINT on CPU#97
[    1.072581]   #98
[    0.001000] masked ExtINT on CPU#98
[    1.082266]   #99
[    0.001000] masked ExtINT on CPU#99
[    1.092104]  #100
[    0.001000] masked ExtINT on CPU#100
[    1.101253]  #101
[    0.001000] masked ExtINT on CPU#101
[    1.111126]  #102
[    0.001000] masked ExtINT on CPU#102
[    1.120361]  #103
[    0.001000] masked ExtINT on CPU#103
[    1.130123]  #104
[    0.001000] masked ExtINT on CPU#104
[    1.140095]  #105
[    0.001000] masked ExtINT on CPU#105
[    1.149545]  #106
[    0.001000] masked ExtINT on CPU#106
[    1.159268]  #107
[    0.001000] masked ExtINT on CPU#107
[    1.169051]  #108
[    0.001000] masked ExtINT on CPU#108
[    1.178268]  #109
[    0.001000] masked ExtINT on CPU#109
[    1.188127]  #110
[    0.001000] masked ExtINT on CPU#110
[    1.198027]  #111
[    0.001000] masked ExtINT on CPU#111
[    1.207488] smp: Brought up 2 nodes, 112 CPUs
[    1.208005] smpboot: Max logical packages: 6
[    1.209010] smpboot: Total of 112 processors activated (402623.53 BogoMI=
PS)
[    1.217425] devtmpfs: initialized
[    1.218060] x86/mm: Memory block size: 2048MB
[    1.219511] evm: security.selinux
[    1.220001] evm: security.ima
[    1.221001] evm: security.capability
[    1.223171] PM: Registering ACPI NVS region [mem 0x6b766000-0x6c195fff] =
(10682368 bytes)
[    1.224646] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfffffff=
f, max_idle_ns: 1911260446275000 ns
[    1.226030] futex hash table entries: 131072 (order: 11, 8388608 bytes)
[    1.230844] pinctrl core: initialized pinctrl subsystem
[    1.232522] NET: Registered protocol family 16
[    1.234198] audit: initializing netlink subsys (disabled)
[    1.235033] audit: type=3D2000 audit(1511949323.235:1): state=3Dinitiali=
zed audit_enabled=3D0 res=3D1
[    1.244003] cpuidle: using governor menu
[    1.248006] ACPI: [PCCT:0x01] Invalid zero length
[    1.252001] ACPI: [PCCT:0x02] Invalid zero length
[    1.257001] Error parsing PCC subspaces from PCCT
[    1.262507] ACPI FADT declares the system doesn't support PCIe ASPM, so =
disable it
[    1.270002] ACPI: bus type PCI registered
[    1.274001] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.280440] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000=
-0x8fffffff] (base 0x80000000)
[    1.290065] PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
[    1.297007] pmd_set_huge: Cannot satisfy [mem 0x80000000-0x80200000] wit=
h a huge-page mapping due to MTRR override.
[    1.308069] PCI: Using configuration type 1 for base access
[    1.319027] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    1.325005] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    1.334602] ACPI: Added _OSI(Module Device)
[    1.339002] ACPI: Added _OSI(Processor Device)
[    1.343001] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.348001] ACPI: Added _OSI(Processor Aggregator Device)
[    1.380534] ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
[    1.429053] ACPI: Dynamic OEM Table Load:
[    1.474724] ACPI: Dynamic OEM Table Load:
[    1.484464] ACPI: Dynamic OEM Table Load:
[    1.516076] ACPI: Dynamic OEM Table Load:
[    1.643964] ACPI: Interpreter enabled
[    1.648017] ACPI: (supports S0 S5)
[    1.651002] ACPI: Using IOAPIC for interrupt routing
[    1.656051] HEST: Table parsing has been initialized.
[    1.661002] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.670704] ACPI: Enabled 7 GPEs in block 00 to 7F
[    1.756571] ACPI: PCI Root Bridge [PC00] (domain 0000 [bus 00-16])
[    1.763013] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    1.771157] acpi PNP0A08:00: _OSC: platform does not support [AER]
[    1.777118] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    1.785002] acpi PNP0A08:00: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    1.795105] PCI host bridge to bus 0000:00
[    1.799003] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    1.806002] pci_bus 0000:00: root bus resource [io  0x1000-0x3fff window]
[    1.812001] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    1.820001] pci_bus 0000:00: root bus resource [mem 0x000c4000-0x000c7ff=
f window]
[    1.827001] pci_bus 0000:00: root bus resource [mem 0xfe010000-0xfe010ff=
f window]
[    1.835002] pci_bus 0000:00: root bus resource [mem 0x90000000-0x9d7ffff=
f window]
[    1.842001] pci_bus 0000:00: root bus resource [mem 0x380000000000-0x383=
fffffffff window]
[    1.851002] pci_bus 0000:00: root bus resource [bus 00-16]
[    1.856010] pci 0000:00:00.0: [8086:2020] type 00 class 0x060000
[    1.863066] pci 0000:00:04.0: [8086:2021] type 00 class 0x088000
[    1.869012] pci 0000:00:04.0: reg 0x10: [mem 0x383ffff2c000-0x383ffff2ff=
ff 64bit]
[    1.877192] pci 0000:00:04.1: [8086:2021] type 00 class 0x088000
[    1.883011] pci 0000:00:04.1: reg 0x10: [mem 0x383ffff28000-0x383ffff2bf=
ff 64bit]
[    1.891318] pci 0000:00:04.2: [8086:2021] type 00 class 0x088000
[    1.897011] pci 0000:00:04.2: reg 0x10: [mem 0x383ffff24000-0x383ffff27f=
ff 64bit]
[    1.905441] pci 0000:00:04.3: [8086:2021] type 00 class 0x088000
[    1.911011] pci 0000:00:04.3: reg 0x10: [mem 0x383ffff20000-0x383ffff23f=
ff 64bit]
[    1.919567] pci 0000:00:04.4: [8086:2021] type 00 class 0x088000
[    1.925011] pci 0000:00:04.4: reg 0x10: [mem 0x383ffff1c000-0x383ffff1ff=
ff 64bit]
[    1.933609] pci 0000:00:04.5: [8086:2021] type 00 class 0x088000
[    1.939010] pci 0000:00:04.5: reg 0x10: [mem 0x383ffff18000-0x383ffff1bf=
ff 64bit]
[    1.947608] pci 0000:00:04.6: [8086:2021] type 00 class 0x088000
[    1.953010] pci 0000:00:04.6: reg 0x10: [mem 0x383ffff14000-0x383ffff17f=
ff 64bit]
[    1.961610] pci 0000:00:04.7: [8086:2021] type 00 class 0x088000
[    1.968011] pci 0000:00:04.7: reg 0x10: [mem 0x383ffff10000-0x383ffff13f=
ff 64bit]
[    1.976041] pci 0000:00:05.0: [8086:2024] type 00 class 0x088000
[    1.982613] pci 0000:00:05.2: [8086:2025] type 00 class 0x088000
[    1.989293] pci 0000:00:05.4: [8086:2026] type 00 class 0x080020
[    1.995009] pci 0000:00:05.4: reg 0x10: [mem 0x9220a000-0x9220afff]
[    2.002196] pci 0000:00:08.0: [8086:2014] type 00 class 0x088000
[    2.008599] pci 0000:00:08.1: [8086:2015] type 00 class 0x110100
[    2.015407] pci 0000:00:08.2: [8086:2016] type 00 class 0x088000
[    2.022032] pci 0000:00:11.0: [8086:a26c] type 00 class 0xff0000
[    2.028653] pci 0000:00:11.1: [8086:a26d] type 00 class 0xff0000
[    2.035370] pci 0000:00:11.5: [8086:a252] type 00 class 0x010601
[    2.041017] pci 0000:00:11.5: reg 0x10: [mem 0x92206000-0x92207fff]
[    2.047007] pci 0000:00:11.5: reg 0x14: [mem 0x92209000-0x922090ff]
[    2.054007] pci 0000:00:11.5: reg 0x18: [io  0x3068-0x306f]
[    2.059007] pci 0000:00:11.5: reg 0x1c: [io  0x3074-0x3077]
[    2.065007] pci 0000:00:11.5: reg 0x20: [io  0x3040-0x305f]
[    2.070007] pci 0000:00:11.5: reg 0x24: [mem 0x92180000-0x921fffff]
[    2.077014] pci 0000:00:11.5: PME# supported from D3hot
[    2.082624] pci 0000:00:14.0: [8086:a22f] type 00 class 0x0c0330
[    2.089022] pci 0000:00:14.0: reg 0x10: [mem 0x383ffff00000-0x383ffff0ff=
ff 64bit]
[    2.096064] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    2.102618] pci 0000:00:14.2: [8086:a231] type 00 class 0x118000
[    2.109021] pci 0000:00:14.2: reg 0x10: [mem 0x383ffff34000-0x383ffff34f=
ff 64bit]
[    2.117082] pci 0000:00:16.0: [8086:a23a] type 00 class 0x078000
[    2.123028] pci 0000:00:16.0: reg 0x10: [mem 0x383ffff33000-0x383ffff33f=
ff 64bit]
[    2.130083] pci 0000:00:16.0: PME# supported from D3hot
[    2.136516] pci 0000:00:16.1: [8086:a23b] type 00 class 0x078000
[    2.142026] pci 0000:00:16.1: reg 0x10: [mem 0x383ffff32000-0x383ffff32f=
ff 64bit]
[    2.150071] pci 0000:00:16.1: PME# supported from D3hot
[    2.155591] pci 0000:00:16.4: [8086:a23e] type 00 class 0x078000
[    2.162026] pci 0000:00:16.4: reg 0x10: [mem 0x383ffff31000-0x383ffff31f=
ff 64bit]
[    2.169070] pci 0000:00:16.4: PME# supported from D3hot
[    2.175345] pci 0000:00:17.0: [8086:a202] type 00 class 0x010601
[    2.181017] pci 0000:00:17.0: reg 0x10: [mem 0x92204000-0x92205fff]
[    2.187007] pci 0000:00:17.0: reg 0x14: [mem 0x92208000-0x922080ff]
[    2.194007] pci 0000:00:17.0: reg 0x18: [io  0x3060-0x3067]
[    2.199007] pci 0000:00:17.0: reg 0x1c: [io  0x3070-0x3073]
[    2.205007] pci 0000:00:17.0: reg 0x20: [io  0x3020-0x303f]
[    2.210007] pci 0000:00:17.0: reg 0x24: [mem 0x92100000-0x9217ffff]
[    2.217037] pci 0000:00:17.0: PME# supported from D3hot
[    2.222622] pci 0000:00:1c.0: [8086:a213] type 01 class 0x060400
[    2.229065] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    2.235665] pci 0000:00:1f.0: [8086:a242] type 00 class 0x060100
[    2.242387] pci 0000:00:1f.2: [8086:a221] type 00 class 0x058000
[    2.248014] pci 0000:00:1f.2: reg 0x10: [mem 0x92200000-0x92203fff]
[    2.255341] pci 0000:00:1f.4: [8086:a223] type 00 class 0x0c0500
[    2.261020] pci 0000:00:1f.4: reg 0x10: [mem 0x383ffff30000-0x383ffff300=
ff 64bit]
[    2.269022] pci 0000:00:1f.4: reg 0x20: [io  0x3000-0x301f]
[    2.275062] pci 0000:00:1f.5: [8086:a224] type 00 class 0x0c8000
[    2.281017] pci 0000:00:1f.5: reg 0x10: [mem 0xfe010000-0xfe010fff]
[    2.288050] pci 0000:01:00.0: [1a03:1150] type 01 class 0x060400
[    2.294104] pci 0000:01:00.0: supports D1 D2
[    2.298001] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.305062] pci 0000:00:1c.0: PCI bridge to [bus 01-02]
[    2.310003] pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
[    2.316003] pci 0000:00:1c.0:   bridge window [mem 0x91000000-0x920fffff]
[    2.323053] pci 0000:02:00.0: [1a03:2000] type 00 class 0x030000
[    2.329027] pci 0000:02:00.0: reg 0x10: [mem 0x91000000-0x91ffffff]
[    2.335012] pci 0000:02:00.0: reg 0x14: [mem 0x92000000-0x9201ffff]
[    2.342012] pci 0000:02:00.0: reg 0x18: [io  0x2000-0x207f]
[    2.347089] pci 0000:02:00.0: supports D1 D2
[    2.352001] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.358079] pci 0000:01:00.0: PCI bridge to [bus 02]
[    2.363006] pci 0000:01:00.0:   bridge window [io  0x2000-0x2fff]
[    2.369004] pci 0000:01:00.0:   bridge window [mem 0x91000000-0x920fffff]
[    2.376017] pci_bus 0000:00: on NUMA node 0
[    2.380338] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 1=
5), disabled.
[    2.388077] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10 11 12 14 1=
5), disabled.
[    2.396075] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 1=
5), disabled.
[    2.404074] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 10 *11 12 14 1=
5), disabled.
[    2.412074] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 *11 12 14 1=
5), disabled.
[    2.420074] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 *11 12 14 1=
5), disabled.
[    2.428074] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 *11 12 14 1=
5), disabled.
[    2.436074] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 10 *11 12 14 1=
5), disabled.
[    2.444366] ACPI: PCI Root Bridge [PC01] (domain 0000 [bus 17-39])
[    2.450004] acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    2.459362] acpi PNP0A08:01: _OSC: platform does not support [AER]
[    2.465276] acpi PNP0A08:01: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    2.473001] acpi PNP0A08:01: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    2.481293] PCI host bridge to bus 0000:17
[    2.486004] pci_bus 0000:17: root bus resource [io  0x4000-0x5fff window]
[    2.493002] pci_bus 0000:17: root bus resource [mem 0x9d800000-0xaafffff=
f window]
[    2.500001] pci_bus 0000:17: root bus resource [mem 0x384000000000-0x387=
fffffffff window]
[    2.508001] pci_bus 0000:17: root bus resource [bus 17-39]
[    2.514010] pci 0000:17:05.0: [8086:2034] type 00 class 0x088000
[    2.520118] pci 0000:17:05.2: [8086:2035] type 00 class 0x088000
[    2.526113] pci 0000:17:05.4: [8086:2036] type 00 class 0x080020
[    2.532009] pci 0000:17:05.4: reg 0x10: [mem 0x9d800000-0x9d800fff]
[    2.538111] pci 0000:17:08.0: [8086:208d] type 00 class 0x088000
[    2.544096] pci 0000:17:08.1: [8086:208d] type 00 class 0x088000
[    2.550090] pci 0000:17:08.2: [8086:208d] type 00 class 0x088000
[    2.557089] pci 0000:17:08.3: [8086:208d] type 00 class 0x088000
[    2.563055] pci 0000:17:08.4: [8086:208d] type 00 class 0x088000
[    2.569088] pci 0000:17:08.5: [8086:208d] type 00 class 0x088000
[    2.575091] pci 0000:17:08.6: [8086:208d] type 00 class 0x088000
[    2.581089] pci 0000:17:08.7: [8086:208d] type 00 class 0x088000
[    2.587088] pci 0000:17:09.0: [8086:208d] type 00 class 0x088000
[    2.593095] pci 0000:17:09.1: [8086:208d] type 00 class 0x088000
[    2.599088] pci 0000:17:09.2: [8086:208d] type 00 class 0x088000
[    2.605090] pci 0000:17:09.3: [8086:208d] type 00 class 0x088000
[    2.611088] pci 0000:17:09.4: [8086:208d] type 00 class 0x088000
[    2.618091] pci 0000:17:09.5: [8086:208d] type 00 class 0x088000
[    2.624074] pci 0000:17:09.6: [8086:208d] type 00 class 0x088000
[    2.630088] pci 0000:17:09.7: [8086:208d] type 00 class 0x088000
[    2.636091] pci 0000:17:0a.0: [8086:208d] type 00 class 0x088000
[    2.642092] pci 0000:17:0a.1: [8086:208d] type 00 class 0x088000
[    2.648090] pci 0000:17:0a.2: [8086:208d] type 00 class 0x088000
[    2.654090] pci 0000:17:0a.3: [8086:208d] type 00 class 0x088000
[    2.660088] pci 0000:17:0a.4: [8086:208d] type 00 class 0x088000
[    2.666090] pci 0000:17:0a.5: [8086:208d] type 00 class 0x088000
[    2.672090] pci 0000:17:0a.6: [8086:208d] type 00 class 0x088000
[    2.679004] pci 0000:17:0a.7: [8086:208d] type 00 class 0x088000
[    2.685089] pci 0000:17:0b.0: [8086:208d] type 00 class 0x088000
[    2.691095] pci 0000:17:0b.1: [8086:208d] type 00 class 0x088000
[    2.697091] pci 0000:17:0b.2: [8086:208d] type 00 class 0x088000
[    2.703089] pci 0000:17:0b.3: [8086:208d] type 00 class 0x088000
[    2.709094] pci 0000:17:0e.0: [8086:208e] type 00 class 0x088000
[    2.715092] pci 0000:17:0e.1: [8086:208e] type 00 class 0x088000
[    2.721091] pci 0000:17:0e.2: [8086:208e] type 00 class 0x088000
[    2.727090] pci 0000:17:0e.3: [8086:208e] type 00 class 0x088000
[    2.733088] pci 0000:17:0e.4: [8086:208e] type 00 class 0x088000
[    2.740019] pci 0000:17:0e.5: [8086:208e] type 00 class 0x088000
[    2.746089] pci 0000:17:0e.6: [8086:208e] type 00 class 0x088000
[    2.752090] pci 0000:17:0e.7: [8086:208e] type 00 class 0x088000
[    2.758100] pci 0000:17:0f.0: [8086:208e] type 00 class 0x088000
[    2.764092] pci 0000:17:0f.1: [8086:208e] type 00 class 0x088000
[    2.770090] pci 0000:17:0f.2: [8086:208e] type 00 class 0x088000
[    2.776088] pci 0000:17:0f.3: [8086:208e] type 00 class 0x088000
[    2.782090] pci 0000:17:0f.4: [8086:208e] type 00 class 0x088000
[    2.788089] pci 0000:17:0f.5: [8086:208e] type 00 class 0x088000
[    2.795088] pci 0000:17:0f.6: [8086:208e] type 00 class 0x088000
[    2.801033] pci 0000:17:0f.7: [8086:208e] type 00 class 0x088000
[    2.807088] pci 0000:17:10.0: [8086:208e] type 00 class 0x088000
[    2.813095] pci 0000:17:10.1: [8086:208e] type 00 class 0x088000
[    2.819091] pci 0000:17:10.2: [8086:208e] type 00 class 0x088000
[    2.825090] pci 0000:17:10.3: [8086:208e] type 00 class 0x088000
[    2.831089] pci 0000:17:10.4: [8086:208e] type 00 class 0x088000
[    2.837088] pci 0000:17:10.5: [8086:208e] type 00 class 0x088000
[    2.843090] pci 0000:17:10.6: [8086:208e] type 00 class 0x088000
[    2.849089] pci 0000:17:10.7: [8086:208e] type 00 class 0x088000
[    2.856090] pci 0000:17:11.0: [8086:208e] type 00 class 0x088000
[    2.862044] pci 0000:17:11.1: [8086:208e] type 00 class 0x088000
[    2.868090] pci 0000:17:11.2: [8086:208e] type 00 class 0x088000
[    2.874093] pci 0000:17:11.3: [8086:208e] type 00 class 0x088000
[    2.880102] pci 0000:17:1d.0: [8086:2054] type 00 class 0x088000
[    2.886095] pci 0000:17:1d.1: [8086:2055] type 00 class 0x088000
[    2.892091] pci 0000:17:1d.2: [8086:2056] type 00 class 0x088000
[    2.898089] pci 0000:17:1d.3: [8086:2057] type 00 class 0x088000
[    2.904095] pci 0000:17:1e.0: [8086:2080] type 00 class 0x088000
[    2.910092] pci 0000:17:1e.1: [8086:2081] type 00 class 0x088000
[    2.917091] pci 0000:17:1e.2: [8086:2082] type 00 class 0x088000
[    2.923089] pci 0000:17:1e.3: [8086:2083] type 00 class 0x088000
[    2.929091] pci 0000:17:1e.4: [8086:2084] type 00 class 0x088000
[    2.935090] pci 0000:17:1e.5: [8086:2085] type 00 class 0x088000
[    2.941088] pci 0000:17:1e.6: [8086:2086] type 00 class 0x088000
[    2.947092] pci_bus 0000:17: on NUMA node 0
[    2.951114] ACPI: PCI Root Bridge [PC02] (domain 0000 [bus 3a-5c])
[    2.958003] acpi PNP0A08:02: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    2.966472] acpi PNP0A08:02: _OSC: platform does not support [AER]
[    2.973106] acpi PNP0A08:02: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    2.980001] acpi PNP0A08:02: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    2.989151] PCI host bridge to bus 0000:3a
[    2.993002] pci_bus 0000:3a: root bus resource [io  0x6000-0x7fff window]
[    3.000002] pci_bus 0000:3a: root bus resource [mem 0xab000000-0xb87ffff=
f window]
[    3.007003] pci_bus 0000:3a: root bus resource [mem 0x388000000000-0x38b=
fffffffff window]
[    3.015002] pci_bus 0000:3a: root bus resource [bus 3a-5c]
[    3.021008] pci 0000:3a:00.0: [8086:2030] type 01 class 0x060400
[    3.027051] pci 0000:3a:00.0: PME# supported from D0 D3hot D3cold
[    3.033065] pci 0000:3a:05.0: [8086:2034] type 00 class 0x088000
[    3.039081] pci 0000:3a:05.2: [8086:2035] type 00 class 0x088000
[    3.045079] pci 0000:3a:05.4: [8086:2036] type 00 class 0x080020
[    3.051009] pci 0000:3a:05.4: reg 0x10: [mem 0xadb00000-0xadb00fff]
[    3.058081] pci 0000:3a:08.0: [8086:2066] type 00 class 0x088000
[    3.064070] pci 0000:3a:09.0: [8086:2066] type 00 class 0x088000
[    3.070077] pci 0000:3a:0a.0: [8086:2040] type 00 class 0x088000
[    3.076074] pci 0000:3a:0a.1: [8086:2041] type 00 class 0x088000
[    3.082071] pci 0000:3a:0a.2: [8086:2042] type 00 class 0x088000
[    3.088070] pci 0000:3a:0a.3: [8086:2043] type 00 class 0x088000
[    3.094069] pci 0000:3a:0a.4: [8086:2044] type 00 class 0x088000
[    3.100072] pci 0000:3a:0a.5: [8086:2045] type 00 class 0x088000
[    3.106070] pci 0000:3a:0a.6: [8086:2046] type 00 class 0x088000
[    3.112069] pci 0000:3a:0a.7: [8086:2047] type 00 class 0x088000
[    3.118070] pci 0000:3a:0b.0: [8086:2048] type 00 class 0x088000
[    3.124074] pci 0000:3a:0b.1: [8086:2049] type 00 class 0x088000
[    3.131069] pci 0000:3a:0b.2: [8086:204a] type 00 class 0x088000
[    3.137051] pci 0000:3a:0b.3: [8086:204b] type 00 class 0x088000
[    3.143073] pci 0000:3a:0c.0: [8086:2040] type 00 class 0x088000
[    3.149076] pci 0000:3a:0c.1: [8086:2041] type 00 class 0x088000
[    3.155072] pci 0000:3a:0c.2: [8086:2042] type 00 class 0x088000
[    3.161072] pci 0000:3a:0c.3: [8086:2043] type 00 class 0x088000
[    3.167070] pci 0000:3a:0c.4: [8086:2044] type 00 class 0x088000
[    3.173072] pci 0000:3a:0c.5: [8086:2045] type 00 class 0x088000
[    3.179072] pci 0000:3a:0c.6: [8086:2046] type 00 class 0x088000
[    3.185072] pci 0000:3a:0c.7: [8086:2047] type 00 class 0x088000
[    3.191073] pci 0000:3a:0d.0: [8086:2048] type 00 class 0x088000
[    3.197077] pci 0000:3a:0d.1: [8086:2049] type 00 class 0x088000
[    3.204070] pci 0000:3a:0d.2: [8086:204a] type 00 class 0x088000
[    3.210064] pci 0000:3a:0d.3: [8086:204b] type 00 class 0x088000
[    3.216124] pci 0000:3b:00.0: [8086:37c0] type 01 class 0x060400
[    3.222017] pci 0000:3b:00.0: reg 0x10: [mem 0xada00000-0xada1ffff 64bit]
[    3.229007] pci 0000:3b:00.0: reg 0x38: [mem 0xfff00000-0xffffffff pref]
[    3.235042] pci 0000:3b:00.0: PME# supported from D0 D3hot D3cold
[    3.245010] pci 0000:3a:00.0: PCI bridge to [bus 3b-3e]
[    3.250004] pci 0000:3a:00.0:   bridge window [mem 0xada00000-0xadafffff]
[    3.257003] pci 0000:3a:00.0:   bridge window [mem 0xab000000-0xad9fffff=
 64bit pref]
[    3.264069] pci 0000:3c:03.0: [8086:37c5] type 01 class 0x060400
[    3.271073] pci 0000:3c:03.0: PME# supported from D0 D3hot D3cold
[    3.277070] pci 0000:3b:00.0: PCI bridge to [bus 3c-3e]
[    3.282007] pci 0000:3b:00.0:   bridge window [mem 0xab000000-0xad9fffff=
 64bit pref]
[    3.290067] pci 0000:3d:00.0: [8086:37d2] type 00 class 0x020000
[    3.296024] pci 0000:3d:00.0: reg 0x10: [mem 0xac000000-0xacffffff 64bit=
 pref]
[    3.303017] pci 0000:3d:00.0: reg 0x1c: [mem 0xad808000-0xad80ffff 64bit=
 pref]
[    3.310014] pci 0000:3d:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[    3.317090] pci 0000:3d:00.0: reg 0x184: [mem 0xad400000-0xad41ffff 64bi=
t pref]
[    3.324002] pci 0000:3d:00.0: VF(n) BAR0 space: [mem 0xad400000-0xad7fff=
ff 64bit pref] (contains BAR0 for 32 VFs)
[    3.335015] pci 0000:3d:00.0: reg 0x190: [mem 0xad890000-0xad893fff 64bi=
t pref]
[    3.342002] pci 0000:3d:00.0: VF(n) BAR3 space: [mem 0xad890000-0xad90ff=
ff 64bit pref] (contains BAR3 for 32 VFs)
[    3.352127] pci 0000:3d:00.1: [8086:37d2] type 00 class 0x020000
[    3.358024] pci 0000:3d:00.1: reg 0x10: [mem 0xab000000-0xabffffff 64bit=
 pref]
[    3.366017] pci 0000:3d:00.1: reg 0x1c: [mem 0xad800000-0xad807fff 64bit=
 pref]
[    3.373015] pci 0000:3d:00.1: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[    3.380051] pci 0000:3d:00.1: reg 0x184: [mem 0xad000000-0xad01ffff 64bi=
t pref]
[    3.387002] pci 0000:3d:00.1: VF(n) BAR0 space: [mem 0xad000000-0xad3fff=
ff 64bit pref] (contains BAR0 for 32 VFs)
[    3.397014] pci 0000:3d:00.1: reg 0x190: [mem 0xad810000-0xad813fff 64bi=
t pref]
[    3.405002] pci 0000:3d:00.1: VF(n) BAR3 space: [mem 0xad810000-0xad88ff=
ff 64bit pref] (contains BAR3 for 32 VFs)
[    3.415144] pci 0000:3c:03.0: PCI bridge to [bus 3d-3e]
[    3.420008] pci 0000:3c:03.0:   bridge window [mem 0xab000000-0xad9fffff=
 64bit pref]
[    3.428014] pci_bus 0000:3a: on NUMA node 0
[    3.432114] ACPI: PCI Root Bridge [PC03] (domain 0000 [bus 5d-7f])
[    3.439003] acpi PNP0A08:03: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    3.447454] acpi PNP0A08:03: _OSC: platform does not support [AER]
[    3.453279] acpi PNP0A08:03: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    3.461001] acpi PNP0A08:03: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    3.470007] PCI host bridge to bus 0000:5d
[    3.474002] pci_bus 0000:5d: root bus resource [io  0x8000-0x9fff window]
[    3.481002] pci_bus 0000:5d: root bus resource [mem 0xb8800000-0xc5fffff=
f window]
[    3.488001] pci_bus 0000:5d: root bus resource [mem 0x38c000000000-0x38f=
fffffffff window]
[    3.496001] pci_bus 0000:5d: root bus resource [bus 5d-7f]
[    3.502011] pci 0000:5d:02.0: [8086:2032] type 01 class 0x060400
[    3.508059] pci 0000:5d:02.0: PME# supported from D0 D3hot D3cold
[    3.514065] pci 0000:5d:03.0: [8086:2033] type 01 class 0x060400
[    3.520058] pci 0000:5d:03.0: PME# supported from D0 D3hot D3cold
[    3.526063] pci 0000:5d:05.0: [8086:2034] type 00 class 0x088000
[    3.532084] pci 0000:5d:05.2: [8086:2035] type 00 class 0x088000
[    3.538082] pci 0000:5d:05.4: [8086:2036] type 00 class 0x080020
[    3.544010] pci 0000:5d:05.4: reg 0x10: [mem 0xb8800000-0xb8800fff]
[    3.551087] pci 0000:5d:0e.0: [8086:2058] type 00 class 0x110100
[    3.557080] pci 0000:5d:0e.1: [8086:2059] type 00 class 0x088000
[    3.563073] pci 0000:5d:0f.0: [8086:2058] type 00 class 0x110100
[    3.569070] pci 0000:5d:0f.1: [8086:2059] type 00 class 0x088000
[    3.575072] pci 0000:5d:10.0: [8086:2058] type 00 class 0x110100
[    3.581072] pci 0000:5d:10.1: [8086:2059] type 00 class 0x088000
[    3.587071] pci 0000:5d:12.0: [8086:204c] type 00 class 0x110100
[    3.593070] pci 0000:5d:12.1: [8086:204d] type 00 class 0x110100
[    3.599058] pci 0000:5d:12.2: [8086:204e] type 00 class 0x088000
[    3.605058] pci 0000:5d:12.4: [8086:204c] type 00 class 0x110100
[    3.611068] pci 0000:5d:12.5: [8086:204d] type 00 class 0x110100
[    3.618059] pci 0000:5d:15.0: [8086:2018] type 00 class 0x088000
[    3.624044] pci 0000:5d:16.0: [8086:2018] type 00 class 0x088000
[    3.630064] pci 0000:5d:16.4: [8086:2018] type 00 class 0x088000
[    3.636059] pci 0000:5d:17.0: [8086:2018] type 00 class 0x088000
[    3.642097] pci 0000:5d:02.0: PCI bridge to [bus 5e]
[    3.647003] pci 0000:5d:02.0:   bridge window [io  0x8000-0x8fff]
[    3.653002] pci 0000:5d:02.0:   bridge window [mem 0xb8900000-0xb8afffff]
[    3.660003] pci 0000:5d:02.0:   bridge window [mem 0x38c000000000-0x38c0=
001fffff 64bit pref]
[    3.668028] pci 0000:5d:03.0: PCI bridge to [bus 5f]
[    3.673002] pci 0000:5d:03.0:   bridge window [io  0x9000-0x9fff]
[    3.679002] pci 0000:5d:03.0:   bridge window [mem 0xb8b00000-0xb8cfffff]
[    3.686003] pci 0000:5d:03.0:   bridge window [mem 0x38c000200000-0x38c0=
003fffff 64bit pref]
[    3.695010] pci_bus 0000:5d: on NUMA node 0
[    3.699172] ACPI: PCI Root Bridge [PC06] (domain 0000 [bus 80-84])
[    3.705003] acpi PNP0A08:06: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    3.713280] acpi PNP0A08:06: _OSC: platform does not support [AER]
[    3.720212] acpi PNP0A08:06: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    3.728001] acpi PNP0A08:06: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    3.736185] PCI host bridge to bus 0000:80
[    3.740002] pci_bus 0000:80: root bus resource [io  0xa000-0xbfff window]
[    3.747001] pci_bus 0000:80: root bus resource [mem 0xc6000000-0xd37ffff=
f window]
[    3.754001] pci_bus 0000:80: root bus resource [mem 0x390000000000-0x393=
fffffffff window]
[    3.763002] pci_bus 0000:80: root bus resource [bus 80-84]
[    3.768010] pci 0000:80:04.0: [8086:2021] type 00 class 0x088000
[    3.774012] pci 0000:80:04.0: reg 0x10: [mem 0x393ffff1c000-0x393ffff1ff=
ff 64bit]
[    3.782042] pci 0000:80:04.1: [8086:2021] type 00 class 0x088000
[    3.788012] pci 0000:80:04.1: reg 0x10: [mem 0x393ffff18000-0x393ffff1bf=
ff 64bit]
[    3.795087] pci 0000:80:04.2: [8086:2021] type 00 class 0x088000
[    3.801012] pci 0000:80:04.2: reg 0x10: [mem 0x393ffff14000-0x393ffff17f=
ff 64bit]
[    3.809088] pci 0000:80:04.3: [8086:2021] type 00 class 0x088000
[    3.815011] pci 0000:80:04.3: reg 0x10: [mem 0x393ffff10000-0x393ffff13f=
ff 64bit]
[    3.822086] pci 0000:80:04.4: [8086:2021] type 00 class 0x088000
[    3.829011] pci 0000:80:04.4: reg 0x10: [mem 0x393ffff0c000-0x393ffff0ff=
ff 64bit]
[    3.836086] pci 0000:80:04.5: [8086:2021] type 00 class 0x088000
[    3.842011] pci 0000:80:04.5: reg 0x10: [mem 0x393ffff08000-0x393ffff0bf=
ff 64bit]
[    3.850019] pci 0000:80:04.6: [8086:2021] type 00 class 0x088000
[    3.856011] pci 0000:80:04.6: reg 0x10: [mem 0x393ffff04000-0x393ffff07f=
ff 64bit]
[    3.863086] pci 0000:80:04.7: [8086:2021] type 00 class 0x088000
[    3.869011] pci 0000:80:04.7: reg 0x10: [mem 0x393ffff00000-0x393ffff03f=
ff 64bit]
[    3.877086] pci 0000:80:05.0: [8086:2024] type 00 class 0x088000
[    3.883087] pci 0000:80:05.2: [8086:2025] type 00 class 0x088000
[    3.889086] pci 0000:80:05.4: [8086:2026] type 00 class 0x080020
[    3.895011] pci 0000:80:05.4: reg 0x10: [mem 0xc6000000-0xc6000fff]
[    3.901090] pci 0000:80:08.0: [8086:2014] type 00 class 0x088000
[    3.907074] pci 0000:80:08.1: [8086:2015] type 00 class 0x110100
[    3.914066] pci 0000:80:08.2: [8086:2016] type 00 class 0x088000
[    3.920024] pci_bus 0000:80: on NUMA node 1
[    3.924097] ACPI: PCI Root Bridge [PC07] (domain 0000 [bus 85-ad])
[    3.930003] acpi PNP0A08:07: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    3.939147] acpi PNP0A08:07: _OSC: platform does not support [AER]
[    3.945277] acpi PNP0A08:07: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    3.953001] acpi PNP0A08:07: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    3.961324] PCI host bridge to bus 0000:85
[    3.966002] pci_bus 0000:85: root bus resource [io  0xc000-0xdfff window]
[    3.972001] pci_bus 0000:85: root bus resource [mem 0xd3800000-0xe0fffff=
f window]
[    3.980001] pci_bus 0000:85: root bus resource [mem 0x394000000000-0x397=
fffffffff window]
[    3.988001] pci_bus 0000:85: root bus resource [bus 85-ad]
[    3.993010] pci 0000:85:05.0: [8086:2034] type 00 class 0x088000
[    4.000119] pci 0000:85:05.2: [8086:2035] type 00 class 0x088000
[    4.006081] pci 0000:85:05.4: [8086:2036] type 00 class 0x080020
[    4.012010] pci 0000:85:05.4: reg 0x10: [mem 0xd3800000-0xd3800fff]
[    4.018116] pci 0000:85:08.0: [8086:208d] type 00 class 0x088000
[    4.024100] pci 0000:85:08.1: [8086:208d] type 00 class 0x088000
[    4.030093] pci 0000:85:08.2: [8086:208d] type 00 class 0x088000
[    4.036093] pci 0000:85:08.3: [8086:208d] type 00 class 0x088000
[    4.042094] pci 0000:85:08.4: [8086:208d] type 00 class 0x088000
[    4.049013] pci 0000:85:08.5: [8086:208d] type 00 class 0x088000
[    4.055092] pci 0000:85:08.6: [8086:208d] type 00 class 0x088000
[    4.061092] pci 0000:85:08.7: [8086:208d] type 00 class 0x088000
[    4.067092] pci 0000:85:09.0: [8086:208d] type 00 class 0x088000
[    4.073097] pci 0000:85:09.1: [8086:208d] type 00 class 0x088000
[    4.079091] pci 0000:85:09.2: [8086:208d] type 00 class 0x088000
[    4.085093] pci 0000:85:09.3: [8086:208d] type 00 class 0x088000
[    4.091092] pci 0000:85:09.4: [8086:208d] type 00 class 0x088000
[    4.097093] pci 0000:85:09.5: [8086:208d] type 00 class 0x088000
[    4.104091] pci 0000:85:09.6: [8086:208d] type 00 class 0x088000
[    4.110059] pci 0000:85:09.7: [8086:208d] type 00 class 0x088000
[    4.116093] pci 0000:85:0a.0: [8086:208d] type 00 class 0x088000
[    4.122097] pci 0000:85:0a.1: [8086:208d] type 00 class 0x088000
[    4.128094] pci 0000:85:0a.2: [8086:208d] type 00 class 0x088000
[    4.134092] pci 0000:85:0a.3: [8086:208d] type 00 class 0x088000
[    4.140094] pci 0000:85:0a.4: [8086:208d] type 00 class 0x088000
[    4.146094] pci 0000:85:0a.5: [8086:208d] type 00 class 0x088000
[    4.152093] pci 0000:85:0a.6: [8086:208d] type 00 class 0x088000
[    4.158093] pci 0000:85:0a.7: [8086:208d] type 00 class 0x088000
[    4.165002] pci 0000:85:0b.0: [8086:208d] type 00 class 0x088000
[    4.171098] pci 0000:85:0b.1: [8086:208d] type 00 class 0x088000
[    4.177092] pci 0000:85:0b.2: [8086:208d] type 00 class 0x088000
[    4.183094] pci 0000:85:0b.3: [8086:208d] type 00 class 0x088000
[    4.189099] pci 0000:85:0e.0: [8086:208e] type 00 class 0x088000
[    4.195095] pci 0000:85:0e.1: [8086:208e] type 00 class 0x088000
[    4.201093] pci 0000:85:0e.2: [8086:208e] type 00 class 0x088000
[    4.207092] pci 0000:85:0e.3: [8086:208e] type 00 class 0x088000
[    4.213093] pci 0000:85:0e.4: [8086:208e] type 00 class 0x088000
[    4.220092] pci 0000:85:0e.5: [8086:208e] type 00 class 0x088000
[    4.226061] pci 0000:85:0e.6: [8086:208e] type 00 class 0x088000
[    4.232093] pci 0000:85:0e.7: [8086:208e] type 00 class 0x088000
[    4.238094] pci 0000:85:0f.0: [8086:208e] type 00 class 0x088000
[    4.244096] pci 0000:85:0f.1: [8086:208e] type 00 class 0x088000
[    4.250093] pci 0000:85:0f.2: [8086:208e] type 00 class 0x088000
[    4.256091] pci 0000:85:0f.3: [8086:208e] type 00 class 0x088000
[    4.262093] pci 0000:85:0f.4: [8086:208e] type 00 class 0x088000
[    4.268091] pci 0000:85:0f.5: [8086:208e] type 00 class 0x088000
[    4.274093] pci 0000:85:0f.6: [8086:208e] type 00 class 0x088000
[    4.281001] pci 0000:85:0f.7: [8086:208e] type 00 class 0x088000
[    4.287094] pci 0000:85:10.0: [8086:208e] type 00 class 0x088000
[    4.293097] pci 0000:85:10.1: [8086:208e] type 00 class 0x088000
[    4.299092] pci 0000:85:10.2: [8086:208e] type 00 class 0x088000
[    4.305093] pci 0000:85:10.3: [8086:208e] type 00 class 0x088000
[    4.311092] pci 0000:85:10.4: [8086:208e] type 00 class 0x088000
[    4.317094] pci 0000:85:10.5: [8086:208e] type 00 class 0x088000
[    4.323093] pci 0000:85:10.6: [8086:208e] type 00 class 0x088000
[    4.329092] pci 0000:85:10.7: [8086:208e] type 00 class 0x088000
[    4.336095] pci 0000:85:11.0: [8086:208e] type 00 class 0x088000
[    4.342057] pci 0000:85:11.1: [8086:208e] type 00 class 0x088000
[    4.348094] pci 0000:85:11.2: [8086:208e] type 00 class 0x088000
[    4.354095] pci 0000:85:11.3: [8086:208e] type 00 class 0x088000
[    4.360108] pci 0000:85:1d.0: [8086:2054] type 00 class 0x088000
[    4.366100] pci 0000:85:1d.1: [8086:2055] type 00 class 0x088000
[    4.372093] pci 0000:85:1d.2: [8086:2056] type 00 class 0x088000
[    4.378094] pci 0000:85:1d.3: [8086:2057] type 00 class 0x088000
[    4.384098] pci 0000:85:1e.0: [8086:2080] type 00 class 0x088000
[    4.390097] pci 0000:85:1e.1: [8086:2081] type 00 class 0x088000
[    4.397030] pci 0000:85:1e.2: [8086:2082] type 00 class 0x088000
[    4.403092] pci 0000:85:1e.3: [8086:2083] type 00 class 0x088000
[    4.409096] pci 0000:85:1e.4: [8086:2084] type 00 class 0x088000
[    4.415092] pci 0000:85:1e.5: [8086:2085] type 00 class 0x088000
[    4.421093] pci 0000:85:1e.6: [8086:2086] type 00 class 0x088000
[    4.427095] pci_bus 0000:85: on NUMA node 1
[    4.431131] ACPI: PCI Root Bridge [PC08] (domain 0000 [bus ae-d6])
[    4.438003] acpi PNP0A08:08: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    4.446454] acpi PNP0A08:08: _OSC: platform does not support [AER]
[    4.453156] acpi PNP0A08:08: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    4.460001] acpi PNP0A08:08: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    4.469231] PCI host bridge to bus 0000:ae
[    4.473002] pci_bus 0000:ae: root bus resource [io  0xe000-0xefff window]
[    4.480002] pci_bus 0000:ae: root bus resource [mem 0xe1000000-0xee7ffff=
f window]
[    4.487001] pci_bus 0000:ae: root bus resource [mem 0x398000000000-0x39b=
fffffffff window]
[    4.495001] pci_bus 0000:ae: root bus resource [bus ae-d6]
[    4.501010] pci 0000:ae:05.0: [8086:2034] type 00 class 0x088000
[    4.507088] pci 0000:ae:05.2: [8086:2035] type 00 class 0x088000
[    4.513092] pci 0000:ae:05.4: [8086:2036] type 00 class 0x080020
[    4.519010] pci 0000:ae:05.4: reg 0x10: [mem 0xe1000000-0xe1000fff]
[    4.525087] pci 0000:ae:08.0: [8086:2066] type 00 class 0x088000
[    4.532083] pci 0000:ae:09.0: [8086:2066] type 00 class 0x088000
[    4.538074] pci 0000:ae:0a.0: [8086:2040] type 00 class 0x088000
[    4.544078] pci 0000:ae:0a.1: [8086:2041] type 00 class 0x088000
[    4.550077] pci 0000:ae:0a.2: [8086:2042] type 00 class 0x088000
[    4.556076] pci 0000:ae:0a.3: [8086:2043] type 00 class 0x088000
[    4.562075] pci 0000:ae:0a.4: [8086:2044] type 00 class 0x088000
[    4.568086] pci 0000:ae:0a.5: [8086:2045] type 00 class 0x088000
[    4.574076] pci 0000:ae:0a.6: [8086:2046] type 00 class 0x088000
[    4.580074] pci 0000:ae:0a.7: [8086:2047] type 00 class 0x088000
[    4.586076] pci 0000:ae:0b.0: [8086:2048] type 00 class 0x088000
[    4.592079] pci 0000:ae:0b.1: [8086:2049] type 00 class 0x088000
[    4.599074] pci 0000:ae:0b.2: [8086:204a] type 00 class 0x088000
[    4.605038] pci 0000:ae:0b.3: [8086:204b] type 00 class 0x088000
[    4.611079] pci 0000:ae:0c.0: [8086:2040] type 00 class 0x088000
[    4.617079] pci 0000:ae:0c.1: [8086:2041] type 00 class 0x088000
[    4.623078] pci 0000:ae:0c.2: [8086:2042] type 00 class 0x088000
[    4.629078] pci 0000:ae:0c.3: [8086:2043] type 00 class 0x088000
[    4.635077] pci 0000:ae:0c.4: [8086:2044] type 00 class 0x088000
[    4.641077] pci 0000:ae:0c.5: [8086:2045] type 00 class 0x088000
[    4.647079] pci 0000:ae:0c.6: [8086:2046] type 00 class 0x088000
[    4.653077] pci 0000:ae:0c.7: [8086:2047] type 00 class 0x088000
[    4.659078] pci 0000:ae:0d.0: [8086:2048] type 00 class 0x088000
[    4.665081] pci 0000:ae:0d.1: [8086:2049] type 00 class 0x088000
[    4.672077] pci 0000:ae:0d.2: [8086:204a] type 00 class 0x088000
[    4.678077] pci 0000:ae:0d.3: [8086:204b] type 00 class 0x088000
[    4.684089] pci_bus 0000:ae: on NUMA node 1
[    4.688109] ACPI: PCI Root Bridge [PC09] (domain 0000 [bus d7-ff])
[    4.694003] acpi PNP0A08:09: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    4.703302] acpi PNP0A08:09: _OSC: platform does not support [AER]
[    4.709278] acpi PNP0A08:09: _OSC: OS now controls [PCIeHotplug PME PCIe=
Capability]
[    4.717001] acpi PNP0A08:09: FADT indicates ASPM is unsupported, using B=
IOS configuration
[    4.725228] PCI host bridge to bus 0000:d7
[    4.730002] pci_bus 0000:d7: root bus resource [io  0xf000-0xffff window]
[    4.736001] pci_bus 0000:d7: root bus resource [mem 0xee800000-0xfbfffff=
f window]
[    4.744001] pci_bus 0000:d7: root bus resource [mem 0x39c000000000-0x39f=
fffffffff window]
[    4.752001] pci_bus 0000:d7: root bus resource [bus d7-ff]
[    4.758009] pci 0000:d7:00.0: [8086:2030] type 01 class 0x060400
[    4.764066] pci 0000:d7:00.0: PME# supported from D0 D3hot D3cold
[    4.770069] pci 0000:d7:01.0: [8086:2031] type 01 class 0x060400
[    4.776065] pci 0000:d7:01.0: PME# supported from D0 D3hot D3cold
[    4.782065] pci 0000:d7:05.0: [8086:2034] type 00 class 0x088000
[    4.788088] pci 0000:d7:05.2: [8086:2035] type 00 class 0x088000
[    4.794087] pci 0000:d7:05.4: [8086:2036] type 00 class 0x080020
[    4.800015] pci 0000:d7:05.4: reg 0x10: [mem 0xee800000-0xee800fff]
[    4.807095] pci 0000:d7:0e.0: [8086:2058] type 00 class 0x110100
[    4.813041] pci 0000:d7:0e.1: [8086:2059] type 00 class 0x088000
[    4.819076] pci 0000:d7:0f.0: [8086:2058] type 00 class 0x110100
[    4.825077] pci 0000:d7:0f.1: [8086:2059] type 00 class 0x088000
[    4.831077] pci 0000:d7:10.0: [8086:2058] type 00 class 0x110100
[    4.837077] pci 0000:d7:10.1: [8086:2059] type 00 class 0x088000
[    4.843078] pci 0000:d7:12.0: [8086:204c] type 00 class 0x110100
[    4.849075] pci 0000:d7:12.1: [8086:204d] type 00 class 0x110100
[    4.855059] pci 0000:d7:12.2: [8086:204e] type 00 class 0x088000
[    4.861063] pci 0000:d7:12.4: [8086:204c] type 00 class 0x110100
[    4.867070] pci 0000:d7:12.5: [8086:204d] type 00 class 0x110100
[    4.873063] pci 0000:d7:15.0: [8086:2018] type 00 class 0x088000
[    4.880068] pci 0000:d7:16.0: [8086:2018] type 00 class 0x088000
[    4.886012] pci 0000:d7:16.4: [8086:2018] type 00 class 0x088000
[    4.892063] pci 0000:d7:17.0: [8086:2018] type 00 class 0x088000
[    4.898104] pci 0000:d7:00.0: PCI bridge to [bus d8]
[    4.903004] pci 0000:d7:00.0:   bridge window [mem 0xee900000-0xeeafffff]
[    4.910004] pci 0000:d7:00.0:   bridge window [mem 0x39c000000000-0x39c0=
001fffff 64bit pref]
[    4.918031] pci 0000:d7:01.0: PCI bridge to [bus d9]
[    4.923003] pci 0000:d7:01.0:   bridge window [io  0xf000-0xffff]
[    4.929003] pci 0000:d7:01.0:   bridge window [mem 0xeeb00000-0xeecfffff]
[    4.936004] pci 0000:d7:01.0:   bridge window [mem 0x39c000200000-0x39c0=
003fffff 64bit pref]
[    4.944011] pci_bus 0000:d7: on NUMA node 1
[    4.949575] pci 0000:02:00.0: vgaarb: VGA device added: decodes=3Dio+mem=
,owns=3Dnone,locks=3Dnone
[    4.958007] pci 0000:02:00.0: vgaarb: bridge control possible
[    4.963003] pci 0000:02:00.0: vgaarb: setting as boot device (VGA legacy=
 resources not available)
[    4.972001] vgaarb: loaded
[    4.975254] SCSI subsystem initialized
[    4.979019] ACPI: bus type USB registered
[    4.983013] usbcore: registered new interface driver usbfs
[    4.989007] usbcore: registered new interface driver hub
[    4.994500] usbcore: registered new device driver usb
[    4.999020] pps_core: LinuxPPS API ver. 1 registered
[    5.004001] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    5.014002] PTP clock support registered
[    5.018383] EDAC MC: Ver: 3.0.0
[    5.022060] dmi: Firmware registration failed.
[    5.026013] PCI: Using ACPI for IRQ routing
[    5.034665] PCI: pci_cache_line_size set to 64 bytes
[    5.039312] e820: reserve RAM buffer [mem 0x677f1000-0x67ffffff]
[    5.046002] e820: reserve RAM buffer [mem 0x67d44000-0x67ffffff]
[    5.052001] e820: reserve RAM buffer [mem 0x67d90000-0x67ffffff]
[    5.058002] e820: reserve RAM buffer [mem 0x67e2c000-0x67ffffff]
[    5.064001] e820: reserve RAM buffer [mem 0x67e60000-0x67ffffff]
[    5.070001] e820: reserve RAM buffer [mem 0x68c83000-0x6bffffff]
[    5.076001] e820: reserve RAM buffer [mem 0x6b466000-0x6bffffff]
[    5.082001] e820: reserve RAM buffer [mem 0x6fb00000-0x6fffffff]
[    5.088193] NetLabel: Initializing
[    5.091001] NetLabel:  domain hash size =3D 128
[    5.096001] NetLabel:  protocols =3D UNLABELED CIPSOv4 CALIPSO
[    5.101017] NetLabel:  unlabeled traffic allowed by default
[    5.107320] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    5.114002] hpet0: 8 comparators, 64-bit 24.000000 MHz counter
[    5.122132] clocksource: Switched to clocksource hpet
[    5.145295] VFS: Disk quotas dquot_6.6.0
[    5.149695] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    5.157170] pnp: PnP ACPI init
[    5.160977] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    5.167675] system 00:01: [io  0x0500-0x053f] has been reserved
[    5.173608] system 00:01: [io  0x0400-0x047f] has been reserved
[    5.179543] system 00:01: [io  0x0540-0x057f] has been reserved
[    5.185482] system 00:01: [io  0x0600-0x061f] has been reserved
[    5.191417] system 00:01: [io  0x0ca0-0x0ca5] could not be reserved
[    5.197694] system 00:01: [io  0x0880-0x0883] has been reserved
[    5.203627] system 00:01: [io  0x0800-0x081f] has been reserved
[    5.209564] system 00:01: [mem 0xfed1c000-0xfed3ffff] has been reserved
[    5.216194] system 00:01: [mem 0xfed45000-0xfed8bfff] has been reserved
[    5.222820] system 00:01: [mem 0xff000000-0xffffffff] has been reserved
[    5.229444] system 00:01: [mem 0xfee00000-0xfeefffff] has been reserved
[    5.236073] system 00:01: [mem 0xfed12000-0xfed1200f] has been reserved
[    5.242702] system 00:01: [mem 0xfed12010-0xfed1201f] has been reserved
[    5.249331] system 00:01: [mem 0xfed1b000-0xfed1bfff] has been reserved
[    5.255963] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    5.263019] pnp 00:02: Plug and Play ACPI device, IDs PNP0501 (active)
[    5.269776] pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (active)
[    5.276484] system 00:04: [mem 0xfd000000-0xfdabffff] has been reserved
[    5.283116] system 00:04: [mem 0xfdad0000-0xfdadffff] has been reserved
[    5.289746] system 00:04: [mem 0xfdb00000-0xfdffffff] has been reserved
[    5.296374] system 00:04: [mem 0xfe000000-0xfe00ffff] has been reserved
[    5.303015] system 00:04: [mem 0xfe011000-0xfe01ffff] has been reserved
[    5.309639] system 00:04: [mem 0xfe036000-0xfe03bfff] has been reserved
[    5.316266] system 00:04: [mem 0xfe03d000-0xfe3fffff] has been reserved
[    5.322891] system 00:04: [mem 0xfe410000-0xfe7fffff] has been reserved
[    5.329522] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    5.336586] system 00:05: [io  0x1000-0x10fe] has been reserved
[    5.342523] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    5.349914] pnp: PnP ACPI: found 6 devices
[    5.360975] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, m=
ax_idle_ns: 2085701024 ns
[    5.369863] pci 0000:3b:00.0: can't claim BAR 6 [mem 0xfff00000-0xffffff=
ff pref]: no compatible bridge window
[    5.379786] pci 0000:3d:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffff=
ff pref]: no compatible bridge window
[    5.389709] pci 0000:3d:00.1: can't claim BAR 6 [mem 0xfff80000-0xffffff=
ff pref]: no compatible bridge window
[    5.399661] pci 0000:01:00.0: PCI bridge to [bus 02]
[    5.404642] pci 0000:01:00.0:   bridge window [io  0x2000-0x2fff]
[    5.410755] pci 0000:01:00.0:   bridge window [mem 0x91000000-0x920fffff]
[    5.417562] pci 0000:00:1c.0: PCI bridge to [bus 01-02]
[    5.422798] pci 0000:00:1c.0:   bridge window [io  0x2000-0x2fff]
[    5.428910] pci 0000:00:1c.0:   bridge window [mem 0x91000000-0x920fffff]
[    5.435717] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    5.441908] pci_bus 0000:00: resource 5 [io  0x1000-0x3fff window]
[    5.448103] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff windo=
w]
[    5.454993] pci_bus 0000:00: resource 7 [mem 0x000c4000-0x000c7fff windo=
w]
[    5.461884] pci_bus 0000:00: resource 8 [mem 0xfe010000-0xfe010fff windo=
w]
[    5.468775] pci_bus 0000:00: resource 9 [mem 0x90000000-0x9d7fffff windo=
w]
[    5.475662] pci_bus 0000:00: resource 10 [mem 0x380000000000-0x383ffffff=
fff window]
[    5.483335] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[    5.488921] pci_bus 0000:01: resource 1 [mem 0x91000000-0x920fffff]
[    5.495195] pci_bus 0000:02: resource 0 [io  0x2000-0x2fff]
[    5.500778] pci_bus 0000:02: resource 1 [mem 0x91000000-0x920fffff]
[    5.507187] pci_bus 0000:17: resource 4 [io  0x4000-0x5fff window]
[    5.513381] pci_bus 0000:17: resource 5 [mem 0x9d800000-0xaaffffff windo=
w]
[    5.520268] pci_bus 0000:17: resource 6 [mem 0x384000000000-0x387fffffff=
ff window]
[    5.527886] pci 0000:3b:00.0: BAR 6: no space for [mem size 0x00100000 p=
ref]
[    5.534950] pci 0000:3b:00.0: BAR 6: failed to assign [mem size 0x001000=
00 pref]
[    5.542367] pci 0000:3b:00.0: BAR 14: no space for [mem size 0x00100000]
[    5.549077] pci 0000:3b:00.0: BAR 14: failed to assign [mem size 0x00100=
000]
[    5.556141] pci 0000:3c:03.0: BAR 14: no space for [mem size 0x00100000]
[    5.562855] pci 0000:3c:03.0: BAR 14: failed to assign [mem size 0x00100=
000]
[    5.569920] pci 0000:3d:00.0: BAR 6: assigned [mem 0xad980000-0xad9fffff=
 pref]
[    5.577158] pci 0000:3d:00.1: BAR 6: no space for [mem size 0x00080000 p=
ref]
[    5.584218] pci 0000:3d:00.1: BAR 6: failed to assign [mem size 0x000800=
00 pref]
[    5.591628] pci 0000:3c:03.0: PCI bridge to [bus 3d-3e]
[    5.596877] pci 0000:3c:03.0:   bridge window [mem 0xab000000-0xad9fffff=
 64bit pref]
[    5.604633] pci 0000:3b:00.0: PCI bridge to [bus 3c-3e]
[    5.609873] pci 0000:3b:00.0:   bridge window [mem 0xab000000-0xad9fffff=
 64bit pref]
[    5.617629] pci 0000:3a:00.0: PCI bridge to [bus 3b-3e]
[    5.622871] pci 0000:3a:00.0:   bridge window [mem 0xada00000-0xadafffff]
[    5.629675] pci 0000:3a:00.0:   bridge window [mem 0xab000000-0xad9fffff=
 64bit pref]
[    5.637434] pci_bus 0000:3a: Some PCI device resources are unassigned, t=
ry booting with pci=3Drealloc
[    5.646487] pci_bus 0000:3a: resource 4 [io  0x6000-0x7fff window]
[    5.652681] pci_bus 0000:3a: resource 5 [mem 0xab000000-0xb87fffff windo=
w]
[    5.659563] pci_bus 0000:3a: resource 6 [mem 0x388000000000-0x38bfffffff=
ff window]
[    5.667147] pci_bus 0000:3b: resource 1 [mem 0xada00000-0xadafffff]
[    5.673431] pci_bus 0000:3b: resource 2 [mem 0xab000000-0xad9fffff 64bit=
 pref]
[    5.680668] pci_bus 0000:3c: resource 2 [mem 0xab000000-0xad9fffff 64bit=
 pref]
[    5.687906] pci_bus 0000:3d: resource 2 [mem 0xab000000-0xad9fffff 64bit=
 pref]
[    5.695167] pci 0000:5d:02.0: PCI bridge to [bus 5e]
[    5.700151] pci 0000:5d:02.0:   bridge window [io  0x8000-0x8fff]
[    5.706259] pci 0000:5d:02.0:   bridge window [mem 0xb8900000-0xb8afffff]
[    5.713064] pci 0000:5d:02.0:   bridge window [mem 0x38c000000000-0x38c0=
001fffff 64bit pref]
[    5.721515] pci 0000:5d:03.0: PCI bridge to [bus 5f]
[    5.726495] pci 0000:5d:03.0:   bridge window [io  0x9000-0x9fff]
[    5.732606] pci 0000:5d:03.0:   bridge window [mem 0xb8b00000-0xb8cfffff]
[    5.739409] pci 0000:5d:03.0:   bridge window [mem 0x38c000200000-0x38c0=
003fffff 64bit pref]
[    5.747861] pci_bus 0000:5d: resource 4 [io  0x8000-0x9fff window]
[    5.754055] pci_bus 0000:5d: resource 5 [mem 0xb8800000-0xc5ffffff windo=
w]
[    5.760945] pci_bus 0000:5d: resource 6 [mem 0x38c000000000-0x38ffffffff=
ff window]
[    5.768528] pci_bus 0000:5e: resource 0 [io  0x8000-0x8fff]
[    5.774115] pci_bus 0000:5e: resource 1 [mem 0xb8900000-0xb8afffff]
[    5.780389] pci_bus 0000:5e: resource 2 [mem 0x38c000000000-0x38c0001fff=
ff 64bit pref]
[    5.788314] pci_bus 0000:5f: resource 0 [io  0x9000-0x9fff]
[    5.793900] pci_bus 0000:5f: resource 1 [mem 0xb8b00000-0xb8cfffff]
[    5.800178] pci_bus 0000:5f: resource 2 [mem 0x38c000200000-0x38c0003fff=
ff 64bit pref]
[    5.808121] pci_bus 0000:80: resource 4 [io  0xa000-0xbfff window]
[    5.814310] pci_bus 0000:80: resource 5 [mem 0xc6000000-0xd37fffff windo=
w]
[    5.821201] pci_bus 0000:80: resource 6 [mem 0x390000000000-0x393fffffff=
ff window]
[    5.828802] pci_bus 0000:85: resource 4 [io  0xc000-0xdfff window]
[    5.834997] pci_bus 0000:85: resource 5 [mem 0xd3800000-0xe0ffffff windo=
w]
[    5.841888] pci_bus 0000:85: resource 6 [mem 0x394000000000-0x397fffffff=
ff window]
[    5.849490] pci_bus 0000:ae: resource 4 [io  0xe000-0xefff window]
[    5.855685] pci_bus 0000:ae: resource 5 [mem 0xe1000000-0xee7fffff windo=
w]
[    5.862576] pci_bus 0000:ae: resource 6 [mem 0x398000000000-0x39bfffffff=
ff window]
[    5.870176] pci 0000:d7:00.0: bridge window [io  0x1000-0x0fff] to [bus =
d8] add_size 1000
[    5.878374] pci 0000:d7:00.0: BAR 13: no space for [io  size 0x1000]
[    5.884741] pci 0000:d7:00.0: BAR 13: failed to assign [io  size 0x1000]
[    5.891451] pci 0000:d7:00.0: BAR 13: no space for [io  size 0x1000]
[    5.897818] pci 0000:d7:00.0: BAR 13: failed to assign [io  size 0x1000]
[    5.904527] pci 0000:d7:00.0: PCI bridge to [bus d8]
[    5.909511] pci 0000:d7:00.0:   bridge window [mem 0xee900000-0xeeafffff]
[    5.916314] pci 0000:d7:00.0:   bridge window [mem 0x39c000000000-0x39c0=
001fffff 64bit pref]
[    5.924769] pci 0000:d7:01.0: PCI bridge to [bus d9]
[    5.929748] pci 0000:d7:01.0:   bridge window [io  0xf000-0xffff]
[    5.935859] pci 0000:d7:01.0:   bridge window [mem 0xeeb00000-0xeecfffff]
[    5.942662] pci 0000:d7:01.0:   bridge window [mem 0x39c000200000-0x39c0=
003fffff 64bit pref]
[    5.951114] pci_bus 0000:d7: resource 4 [io  0xf000-0xffff window]
[    5.957308] pci_bus 0000:d7: resource 5 [mem 0xee800000-0xfbffffff windo=
w]
[    5.964195] pci_bus 0000:d7: resource 6 [mem 0x39c000000000-0x39ffffffff=
ff window]
[    5.971779] pci_bus 0000:d8: resource 1 [mem 0xee900000-0xeeafffff]
[    5.978061] pci_bus 0000:d8: resource 2 [mem 0x39c000000000-0x39c0001fff=
ff 64bit pref]
[    5.985994] pci_bus 0000:d9: resource 0 [io  0xf000-0xffff]
[    5.991580] pci_bus 0000:d9: resource 1 [mem 0xeeb00000-0xeecfffff]
[    5.997858] pci_bus 0000:d9: resource 2 [mem 0x39c000200000-0x39c0003fff=
ff 64bit pref]
[    6.006248] NET: Registered protocol family 2
[    6.011931] TCP established hash table entries: 524288 (order: 10, 41943=
04 bytes)
[    6.020104] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    6.026946] TCP: Hash tables configured (established 524288 bind 65536)
[    6.034157] UDP hash table entries: 32768 (order: 8, 1048576 bytes)
[    6.040606] UDP-Lite hash table entries: 32768 (order: 8, 1048576 bytes)
[    6.048415] NET: Registered protocol family 1
[    6.053986] RPC: Registered named UNIX socket transport module.
[    6.059919] RPC: Registered udp transport module.
[    6.064641] RPC: Registered tcp transport module.
[    6.069364] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    6.076104] IOAPIC[0]: Set routing entry (8-16 -> 0xef -> IRQ 16 Mode:1 =
Active:1 Dest:0)
[    6.084729] PCI: CLS 32 bytes, default 64
[    6.088808] Unpacking initramfs...
[   12.736350] Freeing initrd memory: 350048K
[   12.740481] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[   12.746941] software IO TLB [mem 0x637f1000-0x677f1000] (64MB) mapped at=
 [ffff8800637f1000-ffff8800677f0fff]
[   12.759440] RAPL PMU: API unit is 2^-32 Joules, 3 fixed counters, 655360=
 ms ovfl timer
[   12.767367] RAPL PMU: hw unit of domain pp0-core 2^-14 Joules
[   12.773141] RAPL PMU: hw unit of domain package 2^-14 Joules
[   12.778816] RAPL PMU: hw unit of domain dram 2^-16 Joules
[   12.797976] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x19f=
2297dd97, max_idle_ns: 440795236593 ns
[   12.828949] Initialise system trusted keyrings
[   12.833541] workingset: timestamp_bits=3D36 max_order=3D24 bucket_order=
=3D0
[   12.841031] zbud: loaded
[   12.845018] 9p: Installing v9fs 9p2000 file system support
[   12.850663] SELinux:  Registering netfilter hooks
[   12.860345] NET: Registered protocol family 38
[   12.864812] Key type asymmetric registered
[   12.868932] Asymmetric key parser 'x509' registered
[   12.873866] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 247)
[   12.881602] io scheduler noop registered
[   12.885539] io scheduler deadline registered (default)
[   12.890766] io scheduler cfq registered
[   12.894619] io scheduler mq-deadline registered (default)
[   12.900030] io scheduler kyber registered
[   12.906549] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[   12.913563] gpio-mockup: probe of gpio-mockup failed with error -22
[   12.920285] IOAPIC[0]: Set routing entry (8-19 -> 0xef -> IRQ 19 Mode:1 =
Active:1 Dest:0)
[   12.928658] IOAPIC[3]: Set routing entry (11-7 -> 0xef -> IRQ 25 Mode:1 =
Active:1 Dest:0)
[   12.936932] IOAPIC[3]: Set routing entry (11-0 -> 0xef -> IRQ 27 Mode:1 =
Active:1 Dest:0)
[   12.945286] IOAPIC[4]: Set routing entry (12-7 -> 0xef -> IRQ 28 Mode:1 =
Active:1 Dest:0)
[   12.953926] IOAPIC[8]: Set routing entry (18-7 -> 0xef -> IRQ 31 Mode:1 =
Active:1 Dest:0)
[   12.962405] pcieport 0000:00:1c.0: Signaling PME with IRQ 24
[   12.968098] pcieport 0000:3a:00.0: Signaling PME with IRQ 26
[   12.973802] pcieport 0000:5d:02.0: Signaling PME with IRQ 29
[   12.979491] pcieport 0000:5d:03.0: Signaling PME with IRQ 30
[   12.985182] pcieport 0000:d7:00.0: Signaling PME with IRQ 32
[   12.990875] pcieport 0000:d7:01.0: Signaling PME with IRQ 33
[   12.996557] pciehp 0000:5d:02.0:pcie004: Slot #257 AttnBtn- PwrCtrl- MRL=
- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock- NoCompl- LLActRep+
[   13.009115] pciehp 0000:5d:03.0:pcie004: Slot #258 AttnBtn- PwrCtrl- MRL=
- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock- NoCompl- LLActRep+
[   13.009118] pciehp 0000:5d:02.0:pcie004: Slot(257-1): Power fault
[   13.027767] pciehp 0000:5d:03.0:pcie004: Slot(258-1): Power fault
[   13.027768] pciehp 0000:d7:00.0:pcie004: Slot #259 AttnBtn- PwrCtrl- MRL=
- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock- NoCompl- LLActRep+
[   13.027791] pciehp 0000:d7:01.0:pcie004: Slot #260 AttnBtn- PwrCtrl- MRL=
- AttnInd+ PwrInd+ HotPlug+ Surprise+ Interlock- NoCompl- LLActRep+
[   13.027846] intel_idle: MWAIT substates: 0x2020
[   13.027846] intel_idle: v0.4.1 model 0x55
[   13.057599] pciehp 0000:d7:00.0:pcie004: Slot(259-1): Power fault
[   13.057613] pciehp 0000:d7:01.0:pcie004: Slot(260-1): Power fault
[   13.084377] intel_idle: lapic_timer_reliable_states 0xffffffff
[   13.090454] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[   13.097973] ACPI: Power Button [PWRF]
[   13.310667] ERST: Error Record Serialization Table (ERST) support is ini=
tialized.
[   13.318169] pstore: using zlib compression
[   13.322286] pstore: Registered erst as persistent store backend
[   13.328757] GHES: APEI firmware first mode is enabled by APEI bit and WH=
EA _OSC.
[   13.336487] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   13.392693] 00:03: ttyS1 at I/O 0x2f8 (irq =3D 3, base_baud =3D 115200) =
is a 16550A
[   13.400777] Non-volatile memory driver v1.3
[   13.405108] Linux agpgart interface v0.103
[   13.425997] lpc_ich 0000:00:1f.0: I/O space for ACPI uninitialized
[   13.432200] lpc_ich 0000:00:1f.0: No MFD cells added
[   13.437296] rdac: device handler registered
[   13.441712] hp_sw: device handler registered
[   13.446013] emc: device handler registered
[   13.450467] alua: device handler registered
[   13.454688] libphy: Fixed MDIO Bus: probed
[   13.458868] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[   13.465928] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   13.471715] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[   13.477556] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[   13.483531] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.=
0-k
[   13.490496] igb: Copyright (c) 2007-2014 Intel Corporation.
[   13.496115] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 5.1.0-k
[   13.503781] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[   13.509768] usbcore: registered new interface driver catc
[   13.515186] usbcore: registered new interface driver kaweth
[   13.520770] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Etherne=
t driver
[   13.528171] usbcore: registered new interface driver pegasus
[   13.533839] usbcore: registered new interface driver rtl8150
[   13.539511] usbcore: registered new interface driver asix
[   13.544924] usbcore: registered new interface driver cdc_ether
[   13.550768] usbcore: registered new interface driver cdc_eem
[   13.556443] usbcore: registered new interface driver dm9601
[   13.562034] usbcore: registered new interface driver smsc75xx
[   13.567798] usbcore: registered new interface driver smsc95xx
[   13.573559] usbcore: registered new interface driver gl620a
[   13.579150] usbcore: registered new interface driver net1080
[   13.584826] usbcore: registered new interface driver plusb
[   13.590328] usbcore: registered new interface driver rndis_host
[   13.596267] usbcore: registered new interface driver cdc_subset
[   13.602200] usbcore: registered new interface driver zaurus
[   13.607791] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[   13.615203] usbcore: registered new interface driver int51x1
[   13.620877] usbcore: registered new interface driver ipheth
[   13.626466] usbcore: registered new interface driver sierra_net
[   13.632534] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   13.639078] ehci-pci: EHCI PCI platform driver
[   13.643553] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   13.649744] ohci-pci: OHCI PCI platform driver
[   13.654216] uhci_hcd: USB Universal Host Controller Interface driver
[   13.660765] IOAPIC[0]: Set routing entry (8-16 -> 0xef -> IRQ 16 Mode:1 =
Active:1 Dest:0)
[   13.668918] xhci_hcd 0000:00:14.0: xHCI Host Controller
[   13.674282] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus =
number 1
[   13.683194] xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x1=
00 quirks 0x00009810
[   13.691648] xhci_hcd 0000:00:14.0: cache line size of 32 is not supported
[   13.698652] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[   13.705460] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.712703] usb usb1: Product: xHCI Host Controller
[   13.717599] usb usb1: Manufacturer: Linux 4.15.0-rc1 xhci-hcd
[   13.723361] usb usb1: SerialNumber: 0000:00:14.0
[   13.728258] hub 1-0:1.0: USB hub found
[   13.732045] hub 1-0:1.0: 16 ports detected
[   13.737328] xhci_hcd 0000:00:14.0: xHCI Host Controller
[   13.742797] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus =
number 2
[   13.750284] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0003
[   13.757090] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   13.764328] usb usb2: Product: xHCI Host Controller
[   13.769223] usb usb2: Manufacturer: Linux 4.15.0-rc1 xhci-hcd
[   13.774985] usb usb2: SerialNumber: 0000:00:14.0
[   13.779783] hub 2-0:1.0: USB hub found
[   13.783572] hub 2-0:1.0: 10 ports detected
[   13.788208] usb: port power management may be unreliable
[   13.793838] usbcore: registered new interface driver usbserial_generic
[   13.800393] usbserial: USB Serial support registered for generic
[   13.806427] i8042: PNP: No PS/2 controller found.
[   13.811268] mousedev: PS/2 mouse device common for all mice
[   13.816956] clocksource: Switched to clocksource tsc
[   13.817010] rtc_cmos 00:00: RTC can wake from S4
[   13.817451] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   13.817535] rtc_cmos 00:00: alarms up to one month, y3k, 114 bytes nvram=
, hpet irqs
[   13.817649] i801_smbus 0000:00:1f.4: SPD Write Disable is set
[   13.817677] i801_smbus 0000:00:1f.4: SMBus using PCI interrupt
[   13.821126] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[   13.821214] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by=
 hardware/BIOS
[   13.821221] iTCO_vendor_support: vendor-support=3D0
[   13.821225] intel_pstate: Intel P-state driver initializing
[   13.856412] intel_pstate: HWP enabled
[   13.856413] dmi-sysfs: dmi entry is absent.
[   13.856424] hidraw: raw HID events driver (C) Jiri Kosina
[   13.856495] usbcore: registered new interface driver usbhid
[   13.856495] usbhid: USB HID core driver
[   13.856900] drop_monitor: Initializing network drop monitor service
[   13.857249] Initializing XFRM netlink socket
[   13.857450] NET: Registered protocol family 10
[   13.858559] Segment Routing with IPv6
[   13.858574] NET: Registered protocol family 17
[   13.858629] 9pnet: Installing 9P2000 support
[   13.884688] intel_rdt: Intel RDT MB allocation detected
[   13.884739] microcode: sig=3D0x50652, pf=3D0x1, revision=3D0x80000031
[   13.893389] microcode: Microcode Update Driver: v2.2.
[   13.893455] ... APIC ID:      00000000 (0)
[   13.893455] ... APIC VERSION: 01060015
[   13.893456] 000000000000000000000000000000000000000000000000000000000000=
0000
[   13.893458] 000000000000000000000000000000000000000000000000000000000000=
0000
[   13.893459] 000000000000000000000000000000000000000000000000000000000000=
0000
[   13.893462] number of MP IRQ sources: 15.
[   13.893462] number of IO-APIC #8 registers: 24.
[   13.893463] number of IO-APIC #9 registers: 8.
[   13.893463] number of IO-APIC #10 registers: 8.
[   13.893463] number of IO-APIC #11 registers: 8.
[   13.893464] number of IO-APIC #12 registers: 8.
[   13.893464] number of IO-APIC #15 registers: 8.
[   13.893465] number of IO-APIC #16 registers: 8.
[   13.893465] number of IO-APIC #17 registers: 8.
[   13.893465] number of IO-APIC #18 registers: 8.
[   13.893466] testing the IO APIC.......................
[   13.893478] IO APIC #8......
[   13.893478] .... register #00: 08000000
[   13.893479] .......    : physical APIC id: 08
[   13.893479] .......    : Delivery Type: 0
[   13.893479] .......    : LTS          : 0
[   13.893479] .... register #01: 00170020
[   13.893480] .......     : max redirection entries: 17
[   13.893480] .......     : PRQ implemented: 0
[   13.893480] .......     : IO APIC version: 20
[   13.893480] .... register #02: 00000000
[   13.893481] .......     : arbitration: 00
[   13.893481] .... IRQ redirection table:
[   13.893482] IOAPIC 0:
[   13.893491]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893500]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893511]  pin02, enabled , edge , high, V(30), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893521]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893531]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893542]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893552]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893562]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893573]  pin08, enabled , edge , high, V(27), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893583]  pin09, enabled , level, high, V(21), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893593]  pin0a, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893599]  pin0b, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893605]  pin0c, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893616]  pin0d, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893626]  pin0e, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893636]  pin0f, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893647]  pin10, enabled , level, low , V(28), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893657]  pin11, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893667]  pin12, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893678]  pin13, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893688]  pin14, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893698]  pin15, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893709]  pin16, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893719]  pin17, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893721] IO APIC #9......
[   13.893722] .... register #00: 09000000
[   13.893722] .......    : physical APIC id: 09
[   13.893722] .......    : Delivery Type: 0
[   13.893722] .......    : LTS          : 0
[   13.893723] .... register #01: 00070020
[   13.893723] .......     : max redirection entries: 07
[   13.893723] .......     : PRQ implemented: 0
[   13.893723] .......     : IO APIC version: 20
[   13.893724] .... register #02: 00000000
[   13.893724] .......     : arbitration: 00
[   13.893724] .... register #03: 00000001
[   13.893724] .......     : Boot DT    : 1
[   13.893724] .... IRQ redirection table:
[   13.893725] IOAPIC 1:
[   13.893726]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893728]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893730]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893732]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893733]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893735]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893737]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893738]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893741] IO APIC #10......
[   13.893741] .... register #00: 0A000000
[   13.893741] .......    : physical APIC id: 0A
[   13.893742] .......    : Delivery Type: 0
[   13.893742] .......    : LTS          : 0
[   13.893742] .... register #01: 00070020
[   13.893742] .......     : max redirection entries: 07
[   13.893743] .......     : PRQ implemented: 0
[   13.893743] .......     : IO APIC version: 20
[   13.893743] .... register #02: 00000000
[   13.893743] .......     : arbitration: 00
[   13.893743] .... register #03: 00000001
[   13.893744] .......     : Boot DT    : 1
[   13.893744] .... IRQ redirection table:
[   13.893744] IOAPIC 2:
[   13.893746]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893748]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893750]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893752]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893754]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893756]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893758]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893760]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893762] IO APIC #11......
[   13.893762] .... register #00: 0B000000
[   13.893762] .......    : physical APIC id: 0B
[   13.893763] .......    : Delivery Type: 0
[   13.893763] .......    : LTS          : 0
[   13.893763] .... register #01: 00070020
[   13.893763] .......     : max redirection entries: 07
[   13.893764] .......     : PRQ implemented: 0
[   13.893764] .......     : IO APIC version: 20
[   13.893764] .... register #02: 00000000
[   13.893764] .......     : arbitration: 00
[   13.893765] .... register #03: 00000001
[   13.893765] .......     : Boot DT    : 1
[   13.893765] .... IRQ redirection table:
[   13.893765] IOAPIC 3:
[   13.893767]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893769]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893770]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893772]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893774]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893776]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893777]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893779]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893782] IO APIC #12......
[   13.893782] .... register #00: 0C000000
[   13.893782] .......    : physical APIC id: 0C
[   13.893782] .......    : Delivery Type: 0
[   13.893783] .......    : LTS          : 0
[   13.893783] .... register #01: 00070020
[   13.893783] .......     : max redirection entries: 07
[   13.893783] .......     : PRQ implemented: 0
[   13.893784] .......     : IO APIC version: 20
[   13.893784] .... register #02: 00000000
[   13.893784] .......     : arbitration: 00
[   13.893784] .... register #03: 00000001
[   13.893785] .......     : Boot DT    : 1
[   13.893785] .... IRQ redirection table:
[   13.893785] IOAPIC 4:
[   13.893787]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893789]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893790]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893792]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893794]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893796]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893798]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893799]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893802] IO APIC #15......
[   13.893803] .... register #00: 0F000000
[   13.893803] .......    : physical APIC id: 0F
[   13.893803] .......    : Delivery Type: 0
[   13.893803] .......    : LTS          : 0
[   13.893804] .... register #01: 00070020
[   13.893804] .......     : max redirection entries: 07
[   13.893804] .......     : PRQ implemented: 0
[   13.893804] .......     : IO APIC version: 20
[   13.893804] .... register #02: 00000000
[   13.893805] .......     : arbitration: 00
[   13.893805] .... register #03: 00000001
[   13.893805] .......     : Boot DT    : 1
[   13.893805] .... IRQ redirection table:
[   13.893806] IOAPIC 5:
[   13.893808]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893810]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893812]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893814]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893816]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893818]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893820]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893822]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893825] IO APIC #16......
[   13.893826] .... register #00: 00000000
[   13.893826] .......    : physical APIC id: 00
[   13.893826] .......    : Delivery Type: 0
[   13.893826] .......    : LTS          : 0
[   13.893826] .... register #01: 00070020
[   13.893827] .......     : max redirection entries: 07
[   13.893827] .......     : PRQ implemented: 0
[   13.893827] .......     : IO APIC version: 20
[   13.893827] .... register #02: 00000000
[   13.893828] .......     : arbitration: 00
[   13.893828] .... register #03: 00000001
[   13.893828] .......     : Boot DT    : 1
[   13.893828] .... IRQ redirection table:
[   13.893828] IOAPIC 6:
[   13.893830]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893832]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893834]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893836]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893838]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893840]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893842]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893844]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893847] IO APIC #17......
[   13.893848] .... register #00: 01000000
[   13.893848] .......    : physical APIC id: 01
[   13.893848] .......    : Delivery Type: 0
[   13.893848] .......    : LTS          : 0
[   13.893848] .... register #01: 00070020
[   13.893849] .......     : max redirection entries: 07
[   13.893849] .......     : PRQ implemented: 0
[   13.893849] .......     : IO APIC version: 20
[   13.893849] .... register #02: 00000000
[   13.893850] .......     : arbitration: 00
[   13.893850] .... register #03: 00000001
[   13.893850] .......     : Boot DT    : 1
[   13.893850] .... IRQ redirection table:
[   13.893850] IOAPIC 7:
[   13.893852]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893854]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893856]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893858]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893860]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893862]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893864]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893866]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893869] IO APIC #18......
[   13.893870] .... register #00: 02000000
[   13.893870] .......    : physical APIC id: 02
[   13.893870] .......    : Delivery Type: 0
[   13.893870] .......    : LTS          : 0
[   13.893870] .... register #01: 00070020
[   13.893871] .......     : max redirection entries: 07
[   13.893871] .......     : PRQ implemented: 0
[   13.893871] .......     : IO APIC version: 20
[   13.893872] .... register #02: 00000000
[   13.893872] .......     : arbitration: 00
[   13.893872] .... register #03: 00000001
[   13.893872] .......     : Boot DT    : 1
[   13.893873] .... IRQ redirection table:
[   13.893873] IOAPIC 8:
[   13.893875]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893877]  pin01, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893879]  pin02, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893881]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893884]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893886]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893888]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893890]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[   13.893890] IRQ to pin mappings:
[   13.893891] IRQ0 -> 0:2
[   13.893892] IRQ1 -> 0:1
[   13.893892] IRQ3 -> 0:3
[   13.893893] IRQ4 -> 0:4
[   13.893894] IRQ5 -> 0:5
[   13.893894] IRQ6 -> 0:6
[   13.893895] IRQ7 -> 0:7
[   13.893895] IRQ8 -> 0:8
[   13.893896] IRQ9 -> 0:9
[   13.893896] IRQ10 -> 0:10
[   13.893897] IRQ11 -> 0:11
[   13.893897] IRQ12 -> 0:12
[   13.893898] IRQ13 -> 0:13
[   13.893898] IRQ14 -> 0:14
[   13.893899] IRQ15 -> 0:15
[   13.893900] IRQ16 -> 0:16
[   13.893900] IRQ19 -> 0:19
[   13.893901] IRQ25 -> 3:7
[   13.893901] IRQ27 -> 3:0
[   13.893902] IRQ28 -> 4:7
[   13.893903] IRQ31 -> 8:7
[   13.893904] .................................... done.
[   13.893909] sched_clock: Marking stable (13893384865, 0)->(15047834271, =
-1154449406)
[   13.979335] registered taskstats version 1
[   13.979336] Loading compiled-in X.509 certificates
[   13.979427] zswap: loaded using pool lzo/zbud
[   14.036921] Key type big_key registered
[   14.039249] Key type trusted registered
[   14.041381] Key type encrypted registered
[   14.041384] ima: No TPM chip found, activating TPM-bypass! (rc=3D-19)
[   14.041404] evm: HMAC attrs: 0x1
[   14.043327] rtc_cmos 00:00: setting system clock to 2017-11-29 09:55:38 =
UTC (1511949338)
[   14.058012] usb 1-2: new high-speed USB device number 2 using xhci_hcd
[   14.193549] usb 1-2: New USB device found, idVendor=3D0000, idProduct=3D=
0001
[   14.193550] usb 1-2: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[   14.193933] hub 1-2:1.0: USB hub found
[   14.194113] hub 1-2:1.0: 5 ports detected
[   14.311011] usb 1-3: new high-speed USB device number 3 using xhci_hcd
[   14.471242] usb 1-3: New USB device found, idVendor=3D0b95, idProduct=3D=
7720
[   14.471242] usb 1-3: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[   14.471243] usb 1-3: Product: AX88772=20
[   14.471244] usb 1-3: SerialNumber: 00316B
[   14.513010] usb 1-2.1: new low-speed USB device number 4 using xhci_hcd
[   14.597119] usb 1-2.1: New USB device found, idVendor=3D0b1f, idProduct=
=3D03e9
[   14.597120] usb 1-2.1: New USB device strings: Mfr=3D0, Product=3D0, Ser=
ialNumber=3D0
[   14.615382] input: HID 0b1f:03e9 as /devices/pci0000:00/0000:00:14.0/usb=
1/1-2/1-2.1/1-2.1:1.0/0003:0B1F:03E9.0001/input/input1
[   14.664169] hid-generic 0003:0B1F:03E9.0001: input,hidraw0: USB HID v1.0=
0 Keyboard [HID 0b1f:03e9] on usb-0000:00:14.0-2.1/input0
[   14.681865] input: HID 0b1f:03e9 as /devices/pci0000:00/0000:00:14.0/usb=
1/1-2/1-2.1/1-2.1:1.1/0003:0B1F:03E9.0002/input/input2
[   14.681989] hid-generic 0003:0B1F:03E9.0002: input,hidraw1: USB HID v1.0=
0 Mouse [HID 0b1f:03e9] on usb-0000:00:14.0-2.1/input1
[   14.714090] asix 1-3:1.0 eth0: register 'asix' at usb-0000:00:14.0-3, AS=
IX AX88772 USB 2.0 Ethernet, 00:10:60:b1:9f:b7
[   14.828011] usb 1-5: new full-speed USB device number 5 using xhci_hcd
[   14.960931] usb 1-5: New USB device found, idVendor=3D14dd, idProduct=3D=
1005
[   14.960933] usb 1-5: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[   14.960934] usb 1-5: Product: D2CIM-VUSB
[   14.960934] usb 1-5: Manufacturer: Raritan
[   14.960935] usb 1-5: SerialNumber: 7C07478CDFA46D1
[   14.968173] input: Raritan D2CIM-VUSB as /devices/pci0000:00/0000:00:14.=
0/usb1/1-5/1-5:1.0/0003:14DD:1005.0003/input/input3
[   15.019382] hid-generic 0003:14DD:1005.0003: input,hidraw2: USB HID v1.1=
1 Keyboard [Raritan D2CIM-VUSB] on usb-0000:00:14.0-5/input0
[   15.071923] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   15.533896] random: crng init done
[   16.374085] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   16.380789] asix 1-3:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   16.386057] Sending DHCP requests ., OK
[   16.398071] IP-Config: Got DHCP answer from 192.168.1.1, my address is 1=
92.168.1.100
[   16.405832] IP-Config: Complete:
[   16.409071]      device=3Deth0, hwaddr=3D00:10:60:b1:9f:b7, ipaddr=3D192=
=2E168.1.100, mask=3D255.255.255.0, gw=3D192.168.1.1
[   16.419221]      host=3Dlkp-skl-2sp2, domain=3Dlkp.intel.com, nis-domain=
=3D(none)
[   16.426162]      bootserver=3D192.168.1.1, rootserver=3D192.168.1.1, roo=
tpath=3D     nameserver0=3D192.168.1.1
[   16.438371] Freeing unused kernel memory: 2304K
[   16.442896] Write protecting the kernel read-only data: 14336k
[   16.449807] Freeing unused kernel memory: 876K
[   16.454695] Freeing unused kernel memory: 84K
[   16.459051] rodata_test: all tests were successful
SELinux:  Could=20
[   16.466525] systemd[1]: RTC configured in localtime, applying delta of 4=
80 minutes to system time.
not open policy file <=3D /etc/selinux/targeted/policy/policy.31:  No such =
file or directory
[   16.488184] ip_tables: (C) 2000-2006 Netfilter Core Team

         Mounting Huge Pages File System...
         Starting Remount Root and Kernel File Systems...
         Mounting RPC Pipe File System...
         Mounting Debug File System...
         Starting Create list of required st... nodes for the current kerne=
l...
         Mounting POSIX Message Queue File System...
         Starting Load Kernel Modules...
         Starting Journal Service...
         Starting Create Static Device Nodes in /dev...
         Starting Load/Save Random Seed...
         Starting udev Coldplug all Devices...
         Mounting Configuration File System...
         Starting Apply
[   16.733343] nfit_test_iomap: loading out-of-tree module taints kernel.
 Kernel Variables...
         Starting udev Kernel Device Manager...
         Starting Preprocess NFS configuration...
ces.
vice Manager.
[   16.820602] IPMI System Interface driver.
[   16.822073] input: PC Speaker as /devices/platform/pcspkr/input/input4
[   16.831004] ahci 0000:00:11.5: version 3.0
[   16.831637] ahci 0000:00:11.5: AHCI 0001.0301 32 slots 2 ports 6 Gbps 0x=
30 impl SATA mode
[   16.831639] ahci 0000:00:11.5: flags: 64bit ncq sntf led clo only pio sl=
um part ems deso sadm sds apst=20
[   16.839789] scsi host0: ahci
[   16.840219] scsi host1: ahci
[   16.840974] scsi host2: ahci
[   16.842049] scsi host3: ahci
[   16.842219] scsi host4: ahci
[   16.842415] scsi host5: ahci
[   16.842463] ata1: DUMMY
[   16.842464] ata2: DUMMY
[   16.842465] ata3: DUMMY
[   16.842465] ata4: DUMMY
[   16.842470] ata5: SATA max UDMA/133 abar m524288@0x92180000 port 0x92180=
300 irq 35
[   16.842474] ata6: SATA max UDMA/133 abar m524288@0x92180000 port 0x92180=
380 irq 35
[   16.842967] ahci 0000:00:17.0: AHCI 0001.0301 32 slots 8 ports 6 Gbps 0x=
ff impl SATA mode
[   16.842969] ahci 0000:00:17.0: flags: 64bit ncq sntf led clo only pio sl=
um part ems deso sadm sds apst=20
[   16.866473] scsi host6: ahci
[   16.866669] scsi host7: ahci
[   16.867033] scsi host8: ahci
[   16.868077] scsi host9: ahci
[   16.870025] scsi host10: ahci
[   16.870179] scsi host11: ahci
[   16.870325] scsi host12: ahci
[   16.872037] scsi host13: ahci
[   16.872127] ata7: SATA max UDMA/133 abar m524288@0x92100000 port 0x92100=
100 irq 36
[   16.872130] ata8: SATA max UDMA/133 abar m524288@0x92100000 port 0x92100=
180 irq 36
[   16.872133] ata9: SATA max UDMA/133 abar m524288@0x92100000 port 0x92100=
200 irq 36
[   16.872138] ata10: SATA max UDMA/133 abar m524288@0x92100000 port 0x9210=
0280 irq 36
[   16.872142] ata11: SATA max UDMA/133 abar m524288@0x92100000 port 0x9210=
0300 irq 36
[   16.872143] ata12: SATA max UDMA/133 abar m524288@0x92100000 port 0x9210=
0380 irq 36
[   16.872147] ata13: SATA max UDMA/133 abar m524288@0x92100000 port 0x9210=
0400 irq 36
[   16.872148] ata14: SATA max UDMA/133 abar m524288@0x92100000 port 0x9210=
0480 irq 36
[   16.996977] ipmi_si IPI0001:00: ipmi_platform: probing via ACPI
[
[   17.002920] ipmi_si IPI0001:00: [io  0x0ca2-0x0ca3] regsize 1 spacing 1 =
irq 0
[   17.010121] ipmi_si: Adding ACPI-specified kcs state machine
m
[   17.021348] ipmi_si: SPMI: io 0xca2 regsize 1 spacing 1 irq 0
[   17.027167] (NULL device *): SPMI-specified kcs state machine: duplicate
] Started udev Col
[   17.033968] ipmi_si: Trying ACPI-specified kcs state machine at i/o addr=
ess 0xca2, slave address 0x0, irq 0
dplug all Devices.
[   17.047188] i40e: Intel(R) Ethernet Connection XL710 Network Driver - ve=
rsion 2.1.14-k
[   17.055094] i40e: Copyright (c) 2013 - 2014 Intel Corporation.
        =20
[   17.061545] IOAPIC[3]: Set routing entry (11-6 -> 0xef -> IRQ 37 Mode:1 =
Active:1 Dest:0)
Starting Flush Journal to Persistent Storage...
[   17.079535] AVX2 version of gcm_enc/dec engaged.
[   17.084164] AES CTR mode by8 optimization enabled

[   17.095796] i40e 0000:3d:00.0: MAC address: a4:bf:01:12:39:bf
[   17.117172] Error: Driver 'pcspkr' is already registered, aborting...
         Starting Create Volatile Files a
[   17.126019] i40e 0000:3d:00.0: Added LAN device PF0 bus=3D0x3d dev=3D0x0=
0 func=3D0x00
nd Directories..
[   17.133806] ipmi_si IPI0001:00: IPMI kcs interface initialized
=2E
[   17.142460] i40e 0000:3d:00.0: Features: PF-id[0] VFs: 32 VSIs: 66 QP: 9=
4 RSS FD_ATR FD_SB NTUPLE VxLAN Geneve PTP VEPA
[   17.148152] ata6: SATA link down (SStatus 0 SControl 300)
[   17.148221] ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   17.153240] ata5.00: ATAPI: TEAC    DV-W28S-B, AT11, max UDMA/100
[   17.165168] ata5.00: configured for UDMA/100
m] Started Creat
[   17.180147] ata8: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[   17.180183] ata7: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
e Volatile Files
[   17.180221] ata9: SATA link down (SStatus 0 SControl 300)
 and Directories
[   17.180265] ata12: SATA link down (SStatus 0 SControl 300)
[   17.180311] ata10: SATA link down (SStatus 0 SControl 300)
=2E
[   17.180370] ata8.00: ATA-7: INTEL SSDSA2M080G2GN, 2CV102M3, max UDMA/133
[   17.180372] ata8.00: 156301488 sectors, multi 1: LBA48 NCQ (depth 31/32)
[   17.180545] ata7.00: ATA-9: INTEL SSDSC2BA800G4, G2010140, max UDMA/133
[   17.180546] ata7.00: 1562824368 sectors, multi 1: LBA48 NCQ (depth 31/32)
[   17.180613] ata8.00: configured for UDMA/133
[   17.180966] ata7.00: configured for UDMA/133
[   17.182707] ata14: SATA link down (SStatus 0 SControl 300)
[   17.183557] ata11: SATA link down (SStatus 0 SControl 300)
[   17.185201] ata13: SATA link down (SStatus 0 SControl 300)
[   17.206566] i40e 0000:3d:00.1: fw 3.0.44607 api 1.5 nvm 2.21 0x800004d6 =
1.1416.0
[   17.209941] i40e 0000:3d:00.1: MAC address: a4:bf:01:12:39:c0
[   17.227920] i40e 0000:3d:00.1: Added LAN device PF1 bus=3D0x3d dev=3D0x0=
0 func=3D0x01
[   17.228544] i40e 0000:3d:00.1: Features: PF-id[1] VFs: 32 VSIs: 66 QP: 9=
4 RSS FD_ATR FD_SB NTUPLE VxLAN Geneve PTP VEPA
         Starting Network Time Synchroniz
[   17.304176] [drm] Using P2A bridge for configuration
ation...
[   17.309750] [drm] AST 2500 detected
[   17.314044] [drm] Analog VGA only
[   17.317386] [drm] dram MCLK=3D800 Mhz type=3D7 bus_width=3D16 size=3D010=
00000
        =20
[   17.323979] [TTM] Zone  kernel: Available graphics memory: 32808792 kiB
Starting RPC bin
[   17.331446] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
d portmap servic
[   17.339200] [TTM] Initializing pool allocator
e...
[   17.343036] scsi 6:0:0:0: Direct-Access     ATA      INTEL SSDSC2BA80 01=
40 PQ: 0 ANSI: 5
[   17.351206] scsi 7:0:0:0: Direct-Access     ATA      INTEL SSDSA2M080 02=
M3 PQ: 0 ANSI: 5
[   17.362239] [TTM] Initializing DMA pool allocator
         Starting Update UTMP about System Boot/Shutdown...
[   17.433583] scsi 4:0:0:0: Attached scsi generic sg0 type 5
[   17.439121] scsi 6:0:0:0: Attached scsi generic sg1 type 0
[
[   17.444688] scsi 7:0:0:0: Attached scsi generic sg2 type 0
tem Boot/Shutdow
[   17.459096] ata8.00: Enabling discard_zeroes_data
n.
[   17.465185] sd 6:0:0:0: [sda] 1562824368 512-byte logical blocks: (800 G=
B/745 GiB)
[   17.465192] sd 7:0:0:0: [sdb] 156301488 512-byte logical blocks: (80.0 G=
B/74.5 GiB)
[   17.465200] sd 7:0:0:0: [sdb] Write Protect is off
[   17.465202] sd 7:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[   17.465211] sd 7:0:0:0: [sdb] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[   17.465354] ata8.00: Enabling discard_zeroes_data
[   17.465658]  sdb: sdb1
[   17.466168] ata8.00: Enabling discard_zeroes_data
[   17.466217] sd 7:0:0:0: [sdb] Attached SCSI disk
[   17.515937] sd 6:0:0:0: [sda] 4096-byte physical blocks
[   17.521174] sd 6:0:0:0: [sda] Write Protect is off
[   17.525971] sd 6:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   17.531029] sd 6:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[   17.533066] sr 4:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer dvd-ram cd=
/rw xa/form2 cdda tray
[   17.533068] cdrom: Uniform CD-ROM driver Revision: 3.20
[   17.533214] sr 4:0:0:0: Attached scsi CD-ROM sr0
[   17.560599] ata7.00: Enabling discard_zeroes_data
[   17.566041]  sda: sda1 sda2 < sda5 sda6 sda7 sda8 >
[   17.571428] ata7.00: Enabling discard_zeroes_data
[   17.576179] sd 6:0:0:0: [sda] Attached SCSI disk
[   17.709251] ast 0000:02:00.0: VGA-1: EDID is invalid:
[   17.714375] 	[00] BAD  00 ff ff ff ff ff ff 00 ff ff ff ff ff ff ff ff
[   17.720919] 	[00] BAD  ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   17.727466] 	[00] BAD  ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   17.734010] 	[00] BAD  ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   17.740545] 	[00] BAD  ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   17.747083] 	[00] BAD  ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   17.753623] 	[00] BAD  ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   17.760174] 	[00] BAD  ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[   17.767075] fbcon: astdrmfb (fb0) is primary device
[   17.776018] intel_rapl: Found RAPL domain package
[   17.776022] intel_rapl: Found RAPL domain dram
[   17.776023] intel_rapl: DRAM domain energy unit 15300pj
[   17.776024] intel_rapl: RAPL package 0 domain package locked by BIOS
[   17.776145] Console: switching to colour frame buffer device 128x48
[   17.776325] intel_rapl: Found RAPL domain package
[   17.776329] intel_rapl: Found RAPL domain dram
[   17.776331] intel_rapl: DRAM domain energy unit 15300pj
[   17.776332] intel_rapl: RAPL package 1 domain package locked by BIOS
[   17.838844] ast 0000:02:00.0: fb0: astdrmfb frame buffer device
[   17.853025] [drm] Initialized ast 0.1.0 20120228 for 0000:02:00.0 on min=
or 0
         Starting Login Service...
         Starting OpenBSD Secure Shell server...
         Starting LKP bootstrap...
         Starting /etc/rc.local Compatibility...
[   17.940966] rc.local[1274]: mkdir: cannot create directory '/var/lock/lk=
p-bootstrap.lock': File exists
LKP: HOSTNAME lkp-skl-2sp2, MAC 00:10:60:b1:9f:b7, kernel 4.15.0-rc1 1, ser=
ial console /dev/ttyS0
         Starting Permit User Sessions...
ar background pr
[   17.984186]=20
ogram processing daemon.
[   18.071614] install debs round one: dpkg -i --force-depends /opt/deb/mim=
e-support_3.60_all.deb
[   18.071617]=20
[   18.082468] /opt/deb/debconf_1.5.63_all.deb
[   18.082470]=20
[   18.089320] /opt/deb/libtext-charwidth-perl_0.04-7+b7_amd64.deb
[   18.089321]=20
[   18.097779] /opt/deb/libtext-iconv-perl_1.7-5+b6_amd64.deb
[   18.097780]=20
[   18.105623] /opt/deb/perl-base_5.26.0-5_amd64.deb
[   18.105624]=20
[   18.113685] /opt/deb/liblocale-gettext-perl_1.07-3+b3_amd64.deb
[   18.113686]=20
[   18.123456] /opt/deb/perl-modules-5.26_5.26.0-5_all.deb
[   18.123457]=20
[   18.132415] /opt/deb/libperl5.26_5.26.0-5_amd64.deb
[   18.132416]=20
[   18.140857] /opt/deb/perl_5.26.0-5_amd64.deb
[   18.140858]=20
[   18.148809] /opt/deb/gawk_1%3a4.1.4+dfsg-1_amd64.deb
[   18.148810]=20
[   18.157380] /opt/deb/libssl1.1_1.1.0f-3_amd64.deb
[   18.157381]=20
[   18.165625] /opt/deb/openssl_1.1.0f-3_amd64.deb
[   18.165626]=20
[   18.173901] /opt/deb/ca-certificates_20161130+nmu1_all.deb
[   18.173903]=20
[   18.183305] Selecting previously unselected package mime-support.
[   18.183306]=20
[   18.184840] (Reading database ... 2202 files and directories currently i=
nstalled.)
[   18.184841]=20
[   18.186095] Preparing to unpack .../deb/mime-support_3.60_all.deb ...
[   18.186096]=20
[   18.186826] Unpacking mime-support (3.60) ...
[   18.186827]=20
[   18.188109] Preparing to unpack .../opt/deb/debconf_1.5.63_all.deb ...
[   18.188109]=20
[   18.189074] Unpacking debconf (1.5.63) over (1.5.59) ...
[   18.189075]=20
[   18.190562] Preparing to unpack .../libtext-charwidth-perl_0.04-7+b7_amd=
64.deb ...
[   18.190563]=20
[   18.191976] Unpacking libtext-charwidth-perl (0.04-7+b7) over (0.04-7+b4=
) ...
[   18.191977]=20
[   18.193360] Preparing to unpack .../libtext-iconv-perl_1.7-5+b6_amd64.de=
b ...
[   18.193360]=20
[   18.194668] Unpacking libtext-iconv-perl (1.7-5+b6) over (1.7-5+b3) ...
[   18.194669]=20
[   18.195891] Preparing to unpack .../perl-base_5.26.0-5_amd64.deb ...
[   18.195892]=20
[   18.196994] Unpacking perl-base (5.26.0-5) over (5.22.2-3) ...
[   18.196995]=20
[   18.338750] Preparing to unpack .../liblocale-gettext-perl_1.07-3+b3_amd=
64.deb ...
[   18.338752]=20
[   18.350872] Unpacking liblocale-gettext-perl (1.07-3+b3) over (1.07-3) .=
=2E.
[   18.350874]=20
[   18.362141] Selecting previously unselected package perl-modules-5.26.
[   18.362142]=20
[   18.373131] Preparing to unpack .../perl-modules-5.26_5.26.0-5_all.deb .=
=2E.
[   18.373133]=20
[   18.384108] Unpacking perl-modules-5.26 (5.26.0-5) ...
[   18.384120]=20
[   18.742898] Selecting previously unselected package libperl5.26:amd64.
[   18.742900]=20
[   18.753941] Preparing to unpack .../libperl5.26_5.26.0-5_amd64.deb ...
[   18.753942]=20
[   18.764612] Unpacking libperl5.26:amd64 (5.26.0-5) ...
[   18.764613]=20
[   19.265570] Selecting previously unselected package perl.
[   19.265571]=20
[   19.275466] Preparing to unpack .../deb/perl_5.26.0-5_amd64.deb ...
[   19.275467]=20
[   19.285642] Unpacking perl (5.26.0-5) ...
[   19.285643]=20
[   19.305751] Preparing to unpack .../gawk_1%3a4.1.4+dfsg-1_amd64.deb ...
[   19.305752]=20
[   19.316845] Unpacking gawk (1:4.1.4+dfsg-1) over (1:4.1.1+dfsg-1) ...
[   19.316846]=20
[   19.390490] Selecting previously unselected package libssl1.1:amd64.
[   19.390492]=20
[   19.401307] Preparing to unpack .../libssl1.1_1.1.0f-3_amd64.deb ...
[   19.401309]=20
[   19.411787] Unpacking libssl1.1:amd64 (1.1.0f-3) ...
[   19.411788]=20
[   19.531011] Selecting previously unselected package openssl.
[   19.531012]=20
[   19.541233] Preparing to unpack .../deb/openssl_1.1.0f-3_amd64.deb ...
[   19.541234]=20
[   19.551716] Unpacking openssl (1.1.0f-3) ...
[   19.551717]=20
[   19.614671] Selecting previously unselected package ca-certificates.
[   19.614672]=20
[   19.625606] Preparing to unpack .../ca-certificates_20161130+nmu1_all.de=
b ...
[   19.625607]=20
[   19.636927] Unpacking ca-certificates (20161130+nmu1) ...
[   19.636928]=20
[   19.646267] Setting up mime-support (3.60) ...
[   19.646269]=20
[   19.654979] Setting up perl-base (5.26.0-5) ...
[   19.654980]=20
[   19.663737] Setting up liblocale-gettext-perl (1.07-3+b3) ...
[   19.663738]=20
[   19.673543] Setting up perl-modules-5.26 (5.26.0-5) ...
[   19.673544]=20
[   19.682538] Setting up debconf (1.5.63) ...
[   19.682539]=20
[   20.028592] Setting up libtext-charwidth-perl (0.04-7+b7) ...
[   20.028594]=20
[   20.038473] Setting up libtext-iconv-perl (1.7-5+b6) ...
[   20.038474]=20
[   20.047787] Setting up libssl1.1:amd64 (1.1.0f-3) ...
[   20.047788]=20
[   20.169232] Setting up openssl (1.1.0f-3) ...
[   20.169234]=20
[   20.177605] Setting up ca-certificates (20161130+nmu1) ...
[   20.177606]=20
[   22.637687] Setting up gawk (1:4.1.4+dfsg-1) ...
[   22.637690]=20
[   22.646364] Setting up libperl5.26:amd64 (5.26.0-5) ...
[   22.646365]=20
[   22.655290] Setting up perl (5.26.0-5) ...
[   22.655292]=20
[   22.665906] update-alternatives: using /usr/bin/prename to provide /usr/=
bin/rename (rename) in auto mode
[   22.665908]=20
[   22.679383] Processing triggers for libc-bin (2.23-5) ...
[   22.679385]=20
[   22.689071] Processing triggers for ca-certificates (20161130+nmu1) ...
[   22.689073]=20
[   22.699617] Updating certificates in /etc/ssl/certs...
[   22.699619]=20
[   23.097061] 0 added, 0 removed; done.
[   23.097063]=20
[   23.104816] Running hooks in /etc/ca-certificates/update.d...
[   23.104817]=20
[   23.113663] done.
[   23.113664]=20
[   29.213862] 29 Nov 10:01:59 ntpdate[4936]: step time server 192.168.1.1 =
offset 366.200747 sec
[   29.213866]=20
[   29.242087] EXT4-fs (sda7): mounted filesystem with ordered data mode. O=
pts: (null)
[   29.255523] /lkp/lkp/src/bin/run-lkp
[   29.255525]=20
[   29.276069] Key type dns_resolver registered
[   29.286502] RESULT_ROOT=3D/result/vm-scalability/300s-lru-file-readtwice=
-performance/lkp-skl-2sp2/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-=
7/4fbd8d194f06c8a3fd2af1ce560ddb31f7ec8323/0
[   29.286504]=20
[   29.308105] NFS: Registering the id_resolver key type
[   29.309015] job=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-fi=
le-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-=
58530-nmcjkk-0.yaml
[   29.309017]=20
[   29.331939] Key type id_resolver registered
[   29.336784] Key type id_legacy registered
[   30.840281] run-job /lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-=
file-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-2017112=
8-58530-nmcjkk-0.yaml
[   30.840283]=20
[   30.883114] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-fil=
e-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-5=
8530-nmcjkk-0.yaml&job_state=3Drunning -o /dev/null
[   30.883115]=20
[   32.139336] 2017-11-29 10:02:02=20
[   32.139338]=20
[   32.148719] for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*
[   32.148720]=20
[   32.158220] do
[   32.158221]=20
[   32.163279] 	online_file=3D"$cpu_dir"/online
[   32.163280]=20
[   32.171433] 	[ -f "$online_file" ] && [ "$(cat "$online_file")" -eq 0 ] =
&& continue
[   32.171434]=20
[   32.182048]=20
[   32.184882] 	file=3D"$cpu_dir"/cpufreq/scaling_governor
[   32.184883]=20
[   32.193575] 	[ -f "$file" ] && echo "performance" > "$file"
[   32.193576]=20
[   32.202111] done
[   32.202112]=20
[   32.206815]=20
[   32.243522] kernel profiling enabled schedstats, disable via kernel.sche=
d_schedstats.
[   32.281345] capability: warning: `turbostat' uses 32-bit capabilities (l=
egacy support in use)
[   32.312840] IPMI BMC is not supported on this machine, skip bmc-watchdog=
 setup!
[   32.312843]=20
[   32.487171]=20
[   33.252771] 2017-11-29 10:02:03 cd /lkp/benchmarks/vm-scalability
[   33.252774]=20
[   33.272202] 2017-11-29 10:02:03  mount -t tmpfs -o size=3D100% vm-scalab=
ility-tmp /tmp/vm-scalability-tmp
[   33.272204]=20
[   33.286808] 2017-11-29 10:02:03  truncate -s 67192406016 /tmp/vm-scalabi=
lity-tmp/vm-scalability.img
[   33.286809]=20
[   33.299851] loop: module loaded
[   33.300796] 2017-11-29 10:02:03  mkfs.xfs -q /tmp/vm-scalability-tmp/vm-=
scalability.img
[   33.300798]=20
[   33.328361] 2017-11-29 10:02:03  mount -o loop /tmp/vm-scalability-tmp/v=
m-scalability.img /tmp/vm-scalability-tmp/vm-scalability
[   33.328363]=20
[   33.379095] SGI XFS with ACLs, security attributes, no debug enabled
[   33.393893] XFS (loop0): Mounting V5 Filesystem
[   33.402512] XFS (loop0): Ending clean mount
[   33.410795] 2017-11-29 10:02:04  ./case-lru-file-readtwice
[   33.410797]=20
[   33.429871] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-1 -s 39268272420
[   33.429873]=20
[   33.446845] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-2 -s 39268272420
[   33.446848]=20
[   33.464142] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-3 -s 39268272420
[   33.464144]=20
[   33.481229] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-4 -s 39268272420
[   33.481231]=20
[   33.498422] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-5 -s 39268272420
[   33.498424]=20
[   33.515667] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-6 -s 39268272420
[   33.515669]=20
[   33.532995] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-7 -s 39268272420
[   33.532998]=20
[   33.551461] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-8 -s 39268272420
[   33.551464]=20
[   33.570070] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-9 -s 39268272420
[   33.570073]=20
[   33.588860] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-10 -s 39268272420
[   33.588863]=20
[   33.607706] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-11 -s 39268272420
[   33.607708]=20
[   33.626611] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-12 -s 39268272420
[   33.626613]=20
[   33.645719] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-13 -s 39268272420
[   33.645722]=20
[   33.664873] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-14 -s 39268272420
[   33.664875]=20
[   33.684331] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-15 -s 39268272420
[   33.684334]=20
[   33.703816] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-16 -s 39268272420
[   33.703819]=20
[   33.723523] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-17 -s 39268272420
[   33.723526]=20
[   33.743255] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-18 -s 39268272420
[   33.743258]=20
[   33.762986] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-19 -s 39268272420
[   33.762989]=20
[   33.782891] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-20 -s 39268272420
[   33.782894]=20
[   33.802630] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-21 -s 39268272420
[   33.802633]=20
[   33.822483] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-22 -s 39268272420
[   33.822485]=20
[   33.842437] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-23 -s 39268272420
[   33.842440]=20
[   33.862518] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-24 -s 39268272420
[   33.862522]=20
[   33.882650] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-25 -s 39268272420
[   33.882653]=20
[   33.902811] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-26 -s 39268272420
[   33.902814]=20
[   33.922958] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-27 -s 39268272420
[   33.922961]=20
[   33.943141] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-28 -s 39268272420
[   33.943144]=20
[   33.963311] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-29 -s 39268272420
[   33.963313]=20
[   33.983429] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-30 -s 39268272420
[   33.983431]=20
[   34.003590] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-31 -s 39268272420
[   34.003593]=20
[   34.023739] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-32 -s 39268272420
[   34.023742]=20
[   34.043989] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-33 -s 39268272420
[   34.043992]=20
[   34.064198] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-34 -s 39268272420
[   34.064201]=20
[   34.084496] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-35 -s 39268272420
[   34.084500]=20
[   34.104744] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-36 -s 39268272420
[   34.104747]=20
[   34.125020] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-37 -s 39268272420
[   34.125024]=20
[   34.145199] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-38 -s 39268272420
[   34.145202]=20
[   34.165381] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-39 -s 39268272420
[   34.165383]=20
[   34.185629] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-40 -s 39268272420
[   34.185631]=20
[   34.205864] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-41 -s 39268272420
[   34.205867]=20
[   34.226153] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-42 -s 39268272420
[   34.226157]=20
[   34.246471] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-43 -s 39268272420
[   34.246475]=20
[   34.266779] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-44 -s 39268272420
[   34.266783]=20
[   34.287103] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-45 -s 39268272420
[   34.287108]=20
[   34.307553] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-46 -s 39268272420
[   34.307557]=20
[   34.327897] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-47 -s 39268272420
[   34.327900]=20
[   34.348239] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-48 -s 39268272420
[   34.348243]=20
[   34.368665] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-49 -s 39268272420
[   34.368668]=20
[   34.388927] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-50 -s 39268272420
[   34.388931]=20
[   34.409314] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-51 -s 39268272420
[   34.409317]=20
[   34.412189] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-52 -s 39268272420
[   34.412192]=20
[   34.415054] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-53 -s 39268272420
[   34.415056]=20
[   34.417894] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-54 -s 39268272420
[   34.417898]=20
[   34.420750] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-55 -s 39268272420
[   34.420754]=20
[   34.423602] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-56 -s 39268272420
[   34.423605]=20
[   34.426468] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-57 -s 39268272420
[   34.426471]=20
[   34.429295] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-58 -s 39268272420
[   34.429297]=20
[   34.432126] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-59 -s 39268272420
[   34.432130]=20
[   34.434955] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-60 -s 39268272420
[   34.434957]=20
[   34.437781] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-61 -s 39268272420
[   34.437784]=20
[   34.440662] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-62 -s 39268272420
[   34.440665]=20
[   34.443506] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-63 -s 39268272420
[   34.443509]=20
[   34.446347] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-64 -s 39268272420
[   34.446350]=20
[   34.449213] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-65 -s 39268272420
[   34.449216]=20
[   34.452028] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-66 -s 39268272420
[   34.452032]=20
[   34.454863] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-67 -s 39268272420
[   34.454866]=20
[   34.457705] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-68 -s 39268272420
[   34.457708]=20
[   34.460534] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-69 -s 39268272420
[   34.460536]=20
[   34.463368] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-70 -s 39268272420
[   34.463370]=20
[   34.466235] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-71 -s 39268272420
[   34.466238]=20
[   34.469062] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-72 -s 39268272420
[   34.469065]=20
[   34.471895] 2017-11-29 10:02:04  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-73 -s 39268272420
[   34.471897]=20
[   34.474772] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-74 -s 39268272420
[   34.474775]=20
[   34.477643] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-75 -s 39268272420
[   34.477646]=20
[   34.480491] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-76 -s 39268272420
[   34.480494]=20
[   34.483336] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-77 -s 39268272420
[   34.483339]=20
[   34.508486] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-78 -s 39268272420
[   34.508490]=20
[   34.550546] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-79 -s 39268272420
[   34.550549]=20
[   34.579725] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-80 -s 39268272420
[   34.579728]=20
[   34.626459] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-81 -s 39268272420
[   34.626464]=20
[   34.660660] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-82 -s 39268272420
[   34.660663]=20
[   34.688536] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-83 -s 39268272420
[   34.688540]=20
[   34.718715] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-84 -s 39268272420
[   34.718719]=20
[   34.750756] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-85 -s 39268272420
[   34.750760]=20
[   34.782548] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-86 -s 39268272420
[   34.782553]=20
[   34.827861] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-87 -s 39268272420
[   34.827865]=20
[   34.870024] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-88 -s 39268272420
[   34.870029]=20
[   34.899567] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-89 -s 39268272420
[   34.899571]=20
[   34.941392] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-90 -s 39268272420
[   34.941395]=20
[   34.977107] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-91 -s 39268272420
[   34.977111]=20
[   35.017110] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-92 -s 39268272420
[   35.017114]=20
[   35.060843] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-93 -s 39268272420
[   35.060846]=20
[   35.104005] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-94 -s 39268272420
[   35.104028]=20
[   35.136987] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-95 -s 39268272420
[   35.136990]=20
[   35.182891] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-96 -s 39268272420
[   35.182894]=20
[   35.212757] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-97 -s 39268272420
[   35.212763]=20
[   35.315947] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-98 -s 39268272420
[   35.315951]=20
[   35.363916] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-99 -s 39268272420
[   35.363921]=20
[   35.432390] 2017-11-29 10:02:05  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-100 -s 39268272420
[   35.432397]=20
[   35.496084] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-101 -s 39268272420
[   35.496091]=20
[   35.529317] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-102 -s 39268272420
[   35.529320]=20
[   35.575973] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-103 -s 39268272420
[   35.575977]=20
[   35.626088] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-104 -s 39268272420
[   35.626093]=20
[   35.659309] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-105 -s 39268272420
[   35.659313]=20
[   35.707006] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-106 -s 39268272420
[   35.707024]=20
[   35.750903] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-107 -s 39268272420
[   35.750907]=20
[   35.809962] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-108 -s 39268272420
[   35.809967]=20
[   35.874163] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-109 -s 39268272420
[   35.874167]=20
[   35.877079] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-110 -s 39268272420
[   35.877083]=20
[   35.879974] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-111 -s 39268272420
[   35.879977]=20
[   35.882960] 2017-11-29 10:02:06  truncate /tmp/vm-scalability-tmp/vm-sca=
lability/sparse-lru-file-readtwice-112 -s 39268272420
[   35.882964]=20
[   71.088242] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATO=
MIC), nodemask=3D(null)
[   71.098654] dd cpuset=3D/ mems_allowed=3D0-1
[   71.104460] CPU: 0 PID: 6016 Comm: dd Tainted: G           O     4.15.0-=
rc1 #1
[   71.113553] Call Trace:
[   71.117886]  <IRQ>
[   71.121749]  dump_stack+0x5c/0x7b
[   71.126785]  warn_alloc+0xbe/0x150
[   71.131939]  __alloc_pages_slowpath+0xda7/0xdf0
[   71.138110]  ? xhci_urb_enqueue+0x23d/0x580
[   71.143941]  __alloc_pages_nodemask+0x269/0x280
[   71.150167]  page_frag_alloc+0x11c/0x150
[   71.155668]  __netdev_alloc_skb+0xa0/0x110
[   71.161386]  rx_submit+0x3b/0x2e0
[   71.166232]  rx_complete+0x196/0x2d0
[   71.171354]  __usb_hcd_giveback_urb+0x86/0x100
[   71.177281]  xhci_giveback_urb_in_irq+0x86/0x100
[   71.184107]  xhci_td_cleanup+0xe7/0x170
[   71.189457]  handle_tx_event+0x297/0x1190
[   71.194905]  ? reweight_entity+0x145/0x180
[   71.200466]  xhci_irq+0x300/0xb80
[   71.205195]  ? scheduler_tick+0xb2/0xe0
[   71.210407]  ? run_timer_softirq+0x73/0x460
[   71.215905]  __handle_irq_event_percpu+0x3a/0x1a0
[   71.221975]  handle_irq_event_percpu+0x20/0x50
[   71.227641]  handle_irq_event+0x3d/0x60
[   71.232682]  handle_edge_irq+0x71/0x190
[   71.237715]  handle_irq+0xa5/0x100
[   71.242326]  do_IRQ+0x41/0xc0
[   71.246472]  common_interrupt+0x96/0x96
[   71.251509]  </IRQ>
[   71.254696] RIP: 0010:_raw_spin_unlock_irqrestore+0x11/0x20
[   71.261306] RSP: 0018:ffffc9000a0f7718 EFLAGS: 00000246 ORIG_RAX: ffffff=
ffffffffd9
[   71.269926] RAX: 0000000000000001 RBX: ffffea00124bce40 RCX: 00000000000=
00000
[   71.278165] RDX: ffffffff811d5b10 RSI: 0000000000000246 RDI: 00000000000=
00246
[   71.286380] RBP: ffff8808196b0688 R08: 0000000000000001 R09: 00000000000=
00016
[   71.294533] R10: ffff8804676c3258 R11: 0000000000000017 R12: 00000000000=
00001
[   71.302666] R13: ffff8808196b0670 R14: 0000000000000246 R15: 00000000000=
00000
[   71.310729]  ? count_shadow_nodes+0xa0/0xa0
[   71.315862]  __remove_mapping+0xe8/0x200
[   71.320667]  shrink_page_list+0x8e5/0xbd0
[   71.325599]  shrink_inactive_list+0x216/0x550
[   71.330861]  shrink_node_memcg+0x37e/0x780
[   71.335879]  ? shrink_node+0xeb/0x2e0
[   71.340356]  shrink_node+0xeb/0x2e0
[   71.344646]  do_try_to_free_pages+0xb3/0x310
[   71.349761]  try_to_free_pages+0xf2/0x1c0
[   71.354467]  __alloc_pages_slowpath+0x3e2/0xdf0
[   71.359719]  __alloc_pages_nodemask+0x269/0x280
[   71.364901]  __do_page_cache_readahead+0xfd/0x290
[   71.370326]  ? set_next_entity+0xa1/0x210
[   71.374955]  ? current_time+0x18/0x70
[   71.379284]  ? ondemand_readahead+0x117/0x2c0
[   71.384303]  ondemand_readahead+0x117/0x2c0
[   71.389205]  generic_file_read_iter+0x731/0x980
[   71.394425]  ? _cond_resched+0xf/0x30
[   71.398789]  ? _cond_resched+0x19/0x30
[   71.403210]  ? down_read+0x21/0x40
[   71.407317]  xfs_file_buffered_aio_read+0x53/0xf0 [xfs]
[   71.413255]  xfs_file_read_iter+0x64/0xc0 [xfs]
[   71.418424]  __vfs_read+0xd2/0x140
[   71.422504]  vfs_read+0x9b/0x140
[   71.426392]  SyS_read+0x42/0x90
[   71.430203]  entry_SYSCALL_64_fastpath+0x1a/0x7d
[   71.435466] RIP: 0033:0x7ff145cae060
[   71.439728] RSP: 002b:00007ffee3f33b98 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000000
[   71.447993] RAX: ffffffffffffffda RBX: 00000000000b1bf2 RCX: 00007ff145c=
ae060
[   71.455801] RDX: 0000000000001000 RSI: 0000000000ff4000 RDI: 00000000000=
00000
[   71.463637] RBP: 0000000000001000 R08: 0000000000000003 R09: 00000000000=
03011
[   71.471442] R10: 000000000000086d R11: 0000000000000246 R12: 0000000000f=
f4000
[   71.479267] R13: 0000000000000000 R14: 0000000000ff4000 R15: 00000000000=
00000
[   78.848629] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATO=
MIC), nodemask=3D(null)
[   78.857841] dd cpuset=3D/ mems_allowed=3D0-1
[   78.862502] CPU: 0 PID: 6131 Comm: dd Tainted: G           O     4.15.0-=
rc1 #1
[   78.870437] Call Trace:
[   78.873610]  <IRQ>
[   78.876342]  dump_stack+0x5c/0x7b
[   78.880414]  warn_alloc+0xbe/0x150
[   78.884550]  __alloc_pages_slowpath+0xda7/0xdf0
[   78.889822]  ? xhci_urb_enqueue+0x23d/0x580
[   78.894713]  __alloc_pages_nodemask+0x269/0x280
[   78.899891]  page_frag_alloc+0x11c/0x150
[   78.904471]  __netdev_alloc_skb+0xa0/0x110
[   78.909277]  rx_submit+0x3b/0x2e0
[   78.913256]  rx_complete+0x196/0x2d0
[   78.917560]  __usb_hcd_giveback_urb+0x86/0x100
[   78.922681]  xhci_giveback_urb_in_irq+0x86/0x100
[   78.928769]  ? ip_rcv+0x261/0x390
[   78.932739]  xhci_td_cleanup+0xe7/0x170
[   78.937308]  handle_tx_event+0x297/0x1190
[   78.941990]  xhci_irq+0x300/0xb80
[   78.945968]  ? pciehp_isr+0x46/0x320
[   78.950870]  __handle_irq_event_percpu+0x3a/0x1a0
[   78.956311]  handle_irq_event_percpu+0x20/0x50
[   78.961466]  handle_irq_event+0x3d/0x60
[   78.965962]  handle_edge_irq+0x71/0x190
[   78.970480]  handle_irq+0xa5/0x100
[   78.974565]  do_IRQ+0x41/0xc0
[   78.978206]  ? pagevec_move_tail_fn+0x350/0x350
[   78.983412]  common_interrupt+0x96/0x96
[   78.987887]  </IRQ>
[   78.990638] RIP: 0010:_raw_spin_unlock_irqrestore+0x11/0x20
[   78.996915] RSP: 0018:ffffc9000a347cf8 EFLAGS: 00000246 ORIG_RAX: ffffff=
ffffffffd9
[   79.005196] RAX: ffff881035e00008 RBX: 000000000000000e RCX: 00000000000=
00001
[   79.013024] RDX: ffffea003eb91ba0 RSI: 0000000000000246 RDI: 00000000000=
00246
[   79.020886] RBP: ffff88085d8166a0 R08: ffffea003eb91ba0 R09: 00000000005=
eb501
[   79.028770] R10: ffff88107ffcd000 R11: ffffffffffffffff R12: 00000000000=
00246
[   79.036607] R13: ffffffff811b33b0 R14: ffff88107ffcd000 R15: ffffea003eb=
91bc0
[   79.044528]  ? pagevec_move_tail_fn+0x350/0x350
[   79.049871]  pagevec_lru_move_fn+0xab/0xd0
[   79.054723]  activate_page+0xbb/0xd0
[   79.059035]  mark_page_accessed+0x7a/0x150
[   79.063876]  generic_file_read_iter+0x42d/0x980
[   79.069112]  ? _cond_resched+0x19/0x30
[   79.073611]  ? _cond_resched+0x19/0x30
[   79.078092]  ? down_read+0x21/0x40
[   79.082287]  xfs_file_buffered_aio_read+0x53/0xf0 [xfs]
[   79.088284]  xfs_file_read_iter+0x64/0xc0 [xfs]
[   79.093515]  __vfs_read+0xd2/0x140
[   79.097639]  vfs_read+0x9b/0x140
[   79.101563]  SyS_read+0x42/0x90
[   79.105374]  entry_SYSCALL_64_fastpath+0x1a/0x7d
[   79.110692] RIP: 0033:0x7f2611b8c060
[   79.114910] RSP: 002b:00007ffd6360fda8 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000000
[   79.123181] RAX: ffffffffffffffda RBX: 00000000000c4a1e RCX: 00007f2611b=
8c060
[   79.131037] RDX: 0000000000001000 RSI: 00000000009a4000 RDI: 00000000000=
00000
[   79.138858] RBP: 0000000000001000 R08: 0000000000000003 R09: 00000000000=
03011
[   79.146708] R10: 000000000000086d R11: 0000000000000246 R12: 00000000009=
a4000
[   79.154579] R13: 0000000000000000 R14: 00000000009a4000 R15: 00000000000=
00000
[   85.364572] Terminated
[   85.364576]=20
[   85.806857] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-fil=
e-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-5=
8530-nmcjkk-0.yaml&job_state=3Dpost_run -o /dev/null
[   85.806861]=20
[   94.470143] kill 5128 vmstat --timestamp -n 10=20
[   94.470147]=20
[   94.686033] kill 5114 dmesg --follow --decode=20
[   94.686037]=20
[   94.962636] kill 5296 mpstat 1=20
[   94.962639]=20
[   96.252320] kill 5289 /lkp/benchmarks/perf/perf stat -a -c -I 1000 -x  -=
e {cpu-cycles,instructions,cache-references,cache-misses,branch-instruction=
s,branch-misses},{dTLB-loads,dTLB-load-misses},{dTLB-stores,dTLB-store-miss=
es},{iTLB-loads,iTLB-load-misses},{node-loads,node-load-misses},{node-store=
s,node-store-misses},cpu-clock,task-clock,page-faults,context-switches,cpu-=
migrations,minor-faults,major-faults --log-fd 1 --=20
[   96.252327]=20
[   96.300003] kill 5134 vmstat --timestamp -n 1=20
[   96.300010]=20
[   96.342934] wait for background monitors: 5121 5215 5149 5172 5181 5252 =
5165 5236 5138 5144 5157 5189 5279 5310 5270 5208 5112 uptime softirqs numa=
-meminfo meminfo slabinfo cpuidle proc-stat diskstats numa-numastat numa-vm=
stat proc-vmstat interrupts sched_debug oom-killer turbostat latency_stats =
perf-profile
[   96.342939]=20
[  100.817819] Invalid callchain mode: 0.5
[  100.817825]=20
[  100.844955] Invalid callchain order: 0.5
[  100.844958]=20
[  100.872304] Invalid callchain sort key: 0.5
[  100.872306]=20
[  100.896924] Invalid callchain config key: 0.5
[  100.896926]=20
[  100.923437] Invalid callchain mode: callee
[  100.923439]=20
[  102.226409] no symbols found in /bin/dash, maybe install a debug package?
[  102.226414]=20
[  115.750246] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-fil=
e-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-5=
8530-nmcjkk-0.yaml&loadavg=3D173.85%2056.64%2020.00%20224/1381%207556&start=
_time=3D1511920923&end_time=3D1511920976&version=3D/lkp/lkp/.src-20171129-0=
95612& -o /dev/null
[  115.750251]=20
[  121.942390] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-fil=
e-readtwice-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-5=
8530-nmcjkk-0.yaml&job_state=3DOOM -o /dev/null
[  121.942396]=20
[  128.817869] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-post-run?j=
ob_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-lru-file-readtwic=
e-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-58530-nmcjk=
k-0.yaml -o /dev/null
[  128.817873]=20
[  136.878297] getting new job...
[  136.878305]=20
[  137.147376] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/gpxelinux.cgi?=
hostname=3Dlkp-skl-2sp2&mac=3D00:10:60:b1:9f:b7&last_kernel=3D/pkg/linux/x8=
6_64-rhel-7.2/gcc-7/4fbd8d194f06c8a3fd2af1ce560ddb31f7ec8323/vmlinuz-4.15.0=
-rc1&lkp_wtmp -o /tmp/next-job-lkp
[  137.147380]=20
[  141.102210] /usr/bin/curl -sSf http://inn:80/~lkp//lkp/scheduled/lkp-skl=
-2sp2/vm-scalability-300s-mmap-pread-rand-performance-debian-x86_64-2016-08=
-31.cgz-CYCLIC_HEAD-20171128-11343-1ii6ucp-0.cgz -o /tmp/next-job.cgz
[  141.102217]=20
[  141.383457] 25 blocks
[  141.383461]=20
[  142.197864] downloading kernel image ...
[  142.197869]=20
[  142.434199] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-mmap-pr=
ead-rand-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-1134=
3-1ii6ucp-0.yaml&job_state=3Dwget_kernel -o /dev/null
[  142.434205]=20
[  142.965053] /usr/bin/curl -sSf http://inn:80/~lkp/pkg/linux/x86_64-rhel-=
7.2/gcc-7/1d3b78bbc6e983fabb3fbf91b76339bf66e4a12c/vmlinuz-4.14.0-13292-g1d=
3b78b -o /opt/rootfs/tmp/pkg/linux/x86_64-rhel-7.2/gcc-7/1d3b78bbc6e983fabb=
3fbf91b76339bf66e4a12c/vmlinuz-4.14.0-13292-g1d3b78b -z /opt/rootfs/tmp/pkg=
/linux/x86_64-rhel-7.2/gcc-7/1d3b78bbc6e983fabb3fbf91b76339bf66e4a12c/vmlin=
uz-4.14.0-13292-g1d3b78b
[  142.965059]=20
[  143.091559] downloading initrds ...
[  143.091563]=20
[  143.240554] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-mmap-pr=
ead-rand-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-1134=
3-1ii6ucp-0.yaml&job_state=3Dwget_initrd -o /dev/null
[  143.240560]=20
[  143.905879] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/debian/debian-=
x86_64-2016-08-31.cgz -o /opt/rootfs/tmp/osimage/debian/debian-x86_64-2016-=
08-31.cgz -z /opt/rootfs/tmp/osimage/debian/debian-x86_64-2016-08-31.cgz
[  143.905885]=20
[  186.499961] 868655 blocks
[  186.499965]=20
[  186.704109] /usr/bin/curl -sSf http://inn:80/~lkp/lkp/scheduled/lkp-skl-=
2sp2/vm-scalability-300s-mmap-pread-rand-performance-debian-x86_64-2016-08-=
31.cgz-CYCLIC_HEAD-20171128-11343-1ii6ucp-0.cgz -o /opt/rootfs/tmp/lkp/sche=
duled/lkp-skl-2sp2/vm-scalability-300s-mmap-pread-rand-performance-debian-x=
86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-11343-1ii6ucp-0.cgz
[  186.704113]=20
[  186.980673] 25 blocks
[  186.980677]=20
[  187.209885] /usr/bin/curl -sSf http://inn:80/~lkp/lkp/lkp/lkp-x86_64.cgz=
 -o /opt/rootfs/tmp/lkp/lkp/lkp-x86_64.cgz -z /opt/rootfs/tmp/lkp/lkp/lkp-x=
86_64.cgz
[  187.209893]=20
[  188.103907] 13537 blocks
[  188.103910]=20
[  188.305579] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/lkp_2017-08-01.cgz -o /opt/rootfs/tmp/osimage/deps/debi=
an-x86_64-2016-08-31.cgz/lkp_2017-08-01.cgz -z /opt/rootfs/tmp/osimage/deps=
/debian-x86_64-2016-08-31.cgz/lkp_2017-08-01.cgz
[  188.305584]=20
[  195.039277] 136441 blocks
[  195.039281]=20
[  195.349216] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/rsync-rootfs_2016-11-15.cgz -o /opt/rootfs/tmp/osimage/=
deps/debian-x86_64-2016-08-31.cgz/rsync-rootfs_2016-11-15.cgz -z /opt/rootf=
s/tmp/osimage/deps/debian-x86_64-2016-08-31.cgz/rsync-rootfs_2016-11-15.cgz
[  195.349220]=20
[  196.307701] 8266 blocks
[  196.307706]=20
[  196.656895] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/run-ipconfig_2016-11-15.cgz -o /opt/rootfs/tmp/osimage/=
deps/debian-x86_64-2016-08-31.cgz/run-ipconfig_2016-11-15.cgz -z /opt/rootf=
s/tmp/osimage/deps/debian-x86_64-2016-08-31.cgz/run-ipconfig_2016-11-15.cgz
[  196.656900]=20
[  196.939385] 1077 blocks
[  196.939389]=20
[  197.261440] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/perf_2017-10-01.cgz -o /opt/rootfs/tmp/osimage/deps/deb=
ian-x86_64-2016-08-31.cgz/perf_2017-10-01.cgz -z /opt/rootfs/tmp/osimage/de=
ps/debian-x86_64-2016-08-31.cgz/perf_2017-10-01.cgz
[  197.261444]=20
[  206.008637] 117222 blocks
[  206.008642]=20
[  206.206804] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/pkg/debian-x86=
_64-2016-08-31.cgz/perf-x86_64-a8c964eacb21_2017-10-01.cgz -o /opt/rootfs/t=
mp/osimage/pkg/debian-x86_64-2016-08-31.cgz/perf-x86_64-a8c964eacb21_2017-1=
0-01.cgz -z /opt/rootfs/tmp/osimage/pkg/debian-x86_64-2016-08-31.cgz/perf-x=
86_64-a8c964eacb21_2017-10-01.cgz
[  206.206810]=20
[  207.430392] 10149 blocks
[  207.430397]=20
[  207.698882] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/vm-scalability_2016-11-15.cgz -o /opt/rootfs/tmp/osimag=
e/deps/debian-x86_64-2016-08-31.cgz/vm-scalability_2016-11-15.cgz -z /opt/r=
ootfs/tmp/osimage/deps/debian-x86_64-2016-08-31.cgz/vm-scalability_2016-11-=
15.cgz
[  207.698886]=20
[  208.668163] 8383 blocks
[  208.668166]=20
[  208.947834] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/pkg/common/vm-=
scalability-x86_64.cgz -o /opt/rootfs/tmp/osimage/pkg/common/vm-scalability=
-x86_64.cgz -z /opt/rootfs/tmp/osimage/pkg/common/vm-scalability-x86_64.cgz
[  208.947838]=20
[  209.215079] 404 blocks
[  209.215083]=20
[  209.457152] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/iostat_2016-11-15.cgz -o /opt/rootfs/tmp/osimage/deps/d=
ebian-x86_64-2016-08-31.cgz/iostat_2016-11-15.cgz -z /opt/rootfs/tmp/osimag=
e/deps/debian-x86_64-2016-08-31.cgz/iostat_2016-11-15.cgz
[  209.457155]=20
[  211.995541] 2586 blocks
[  211.995547]=20
[  212.332139] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/turbostat_2016-11-15.cgz -o /opt/rootfs/tmp/osimage/dep=
s/debian-x86_64-2016-08-31.cgz/turbostat_2016-11-15.cgz -z /opt/rootfs/tmp/=
osimage/deps/debian-x86_64-2016-08-31.cgz/turbostat_2016-11-15.cgz
[  212.332144]=20
[  216.102165] 5007 blocks
[  216.102170]=20
[  216.360635] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/pkg/debian-x86=
_64-2016-08-31.cgz/turbostat-x86_64-d5256b2_2017-06-20.cgz -o /opt/rootfs/t=
mp/osimage/pkg/debian-x86_64-2016-08-31.cgz/turbostat-x86_64-d5256b2_2017-0=
6-20.cgz -z /opt/rootfs/tmp/osimage/pkg/debian-x86_64-2016-08-31.cgz/turbos=
tat-x86_64-d5256b2_2017-06-20.cgz
[  216.360639]=20
[  221.961423] 208 blocks
[  221.961428]=20
[  222.182668] /usr/bin/curl -sSf http://inn:80/~lkp/osimage/deps/debian-x8=
6_64-2016-08-31.cgz/hw_2016-11-15.cgz -o /opt/rootfs/tmp/osimage/deps/debia=
n-x86_64-2016-08-31.cgz/hw_2016-11-15.cgz -z /opt/rootfs/tmp/osimage/deps/d=
ebian-x86_64-2016-08-31.cgz/hw_2016-11-15.cgz
[  222.182674]=20
[  231.346610] 31441 blocks
[  231.346615]=20
[  231.552064] /usr/bin/curl -sSf http://inn:80/~lkp/pkg/linux/x86_64-rhel-=
7.2/gcc-7/1d3b78bbc6e983fabb3fbf91b76339bf66e4a12c/modules.cgz -o /opt/root=
fs/tmp/pkg/linux/x86_64-rhel-7.2/gcc-7/1d3b78bbc6e983fabb3fbf91b76339bf66e4=
a12c/modules.cgz -z /opt/rootfs/tmp/pkg/linux/x86_64-rhel-7.2/gcc-7/1d3b78b=
bc6e983fabb3fbf91b76339bf66e4a12c/modules.cgz
[  231.552069]=20
[  284.804451] 1096038 blocks
[  284.804455]=20
[  300.497227] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-mmap-pr=
ead-rand-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-1134=
3-1ii6ucp-0.yaml&job_state=3Dbooting -o /dev/null
[  300.497232]=20
[  300.992272] LKP: kexec loading...
[  300.992278]=20
[  301.004311] kexec --noefi -l /opt/rootfs/tmp/pkg/linux/x86_64-rhel-7.2/g=
cc-7/1d3b78bbc6e983fabb3fbf91b76339bf66e4a12c/vmlinuz-4.14.0-13292-g1d3b78b=
 --initrd=3D/opt/rootfs/tmp/initrd-concatenated
[  301.004315]=20
[  305.284651] --append=3Dip=3D::::lkp-skl-2sp2::dhcp root=3D/dev/ram0 user=
=3Dlkp job=3D/lkp/scheduled/lkp-skl-2sp2/vm-scalability-300s-mmap-pread-ran=
d-performance-debian-x86_64-2016-08-31.cgz-CYCLIC_HEAD-20171128-11343-1ii6u=
cp-0.yaml ARCH=3Dx86_64 kconfig=3Dx86_64-rhel-7.2 branch=3Dlinus/master com=
mit=3D1d3b78bbc6e983fabb3fbf91b76339bf66e4a12c BOOT_IMAGE=3D/pkg/linux/x86_=
64-rhel-7.2/gcc-7/1d3b78bbc6e983fabb3fbf91b76339bf66e4a12c/vmlinuz-4.14.0-1=
3292-g1d3b78b acpi_rsdp=3D0x6C295014 max_uptime=3D1500 RESULT_ROOT=3D/resul=
t/vm-scalability/300s-mmap-pread-rand-performance/lkp-skl-2sp2/debian-x86_6=
4-2016-08-31.cgz/x86_64-rhel-7.2/gcc-7/1d3b78bbc6e983fabb3fbf91b76339bf66e4=
a12c/0 LKP_SERVER=3Dinn debug apic=3Ddebug sysrq_always_enabled rcupdate.rc=
u_cpu_stall_timeout=3D100 net.ifnames=3D0 printk.devkmsg=3Don panic=3D-1 so=
ftlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 promp=
t_ramdisk=3D0 drbd.minor_count=3D8 systemd.log_level=3Derr ignore_l
[  305.375040]=20
[  336.811853] 6925019+0 records in
[  336.811855]=20
[  336.818578] 6925018+0 records out
[  336.818579]=20
[  336.825841] 28364873728 bytes (28 GB, 26 GiB) copied, 300 s, 94.5 MB/s
[  336.825843]=20
[  336.835686] 6858325+0 records in
[  336.835687]=20
[  336.842148] 6858324+0 records out
[  336.842149]=20
[  336.849191] 28091695104 bytes (28 GB, 26 GiB) copied, 300 s, 93.6 MB/s
[  336.849192]=20
[  336.858903] 4805116+0 records in
[  336.858904]=20
[  336.865284] 4805115+0 records out
[  336.865285]=20
[  336.872273] 19681751040 bytes (20 GB, 18 GiB) copied, 299.983 s, 65.6 MB=
/s
[  336.872274]=20
[  336.882230] 4714903+0 records in
[  336.882230]=20
[  336.888479] 4714902+0 records out
[  336.888479]=20
[  336.895342] 19312238592 bytes (19 GB, 18 GiB) copied, 299.983 s, 64.4 MB=
/s
[  336.895342]=20
[  336.905219] 6830151+0 records in
[  336.905220]=20
[  336.911381] 6830150+0 records out
[  336.911382]=20
[  336.918116] 27976294400 bytes (28 GB, 26 GiB) copied, 299.995 s, 93.3 MB=
/s
[  336.918117]=20
[  336.927879] 6896467+0 records in
[  336.927880]=20
[  336.933938] 6896466+0 records out
[  336.933939]=20
[  336.940618] 28247924736 bytes (28 GB, 26 GiB) copied, 299.989 s, 94.2 MB=
/s
[  336.940619]=20
[  336.950301] 6765840+0 records in
[  336.950301]=20
[  336.956294] 6765839+0 records out
[  336.956295]=20
[  336.962831] 27712876544 bytes (28 GB, 26 GiB) copied, 299.989 s, 92.4 MB=
/s
[  336.962832]=20
[  336.972336] 4909161+0 records in
[  336.972337]=20
[  336.978137] 4909160+0 records out
[  336.978138]=20
[  336.984472] 20107919360 bytes (20 GB, 19 GiB) copied, 299.984 s, 67.0 MB=
/s
[  336.984473]=20
[  336.993827] 6788157+0 records in
[  336.993828]=20
[  336.999570] 6788156+0 records out
[  336.999572]=20
[  337.005960] 27804286976 bytes (28 GB, 26 GiB) copied, 299.99 s, 92.7 MB/s
[  337.005961]=20
[  337.015239] 4945150+0 records in
[  337.015240]=20
[  337.020965] 4945149+0 records out
[  337.020966]=20
[  337.027300] 20255330304 bytes (20 GB, 19 GiB) copied, 299.985 s, 67.5 MB=
/s
[  337.027301]=20
[  337.036652] 5086933+0 records in
[  337.036653]=20
[  337.042388] 5086932+0 records out
[  337.042389]=20
[  337.048727] 20836073472 bytes (21 GB, 19 GiB) copied, 299.987 s, 69.5 MB=
/s
[  337.048728]=20
[  337.058084] 5034326+0 records in
[  337.058085]=20
[  337.063823] 5034325+0 records out
[  337.063824]=20
[  337.070156] 20620595200 bytes (21 GB, 19 GiB) copied, 299.986 s, 68.7 MB=
/s
[  337.070157]=20
[  337.079518] 6907821+0 records in
[  337.079518]=20
[  337.085246] 6907820+0 records out
[  337.085247]=20
[  337.091536] 28294430720 bytes (28 GB, 26 GiB) copied, 300 s, 94.3 MB/s
[  337.091537]=20
[  337.100541] 4912410+0 records in
[  337.100542]=20
[  337.106269] 4912409+0 records out
[  337.106270]=20
[  337.112599] 20121227264 bytes (20 GB, 19 GiB) copied, 299.986 s, 67.1 MB=
/s
[  337.112600]=20
[  337.121952] 6946878+0 records in
[  337.121953]=20
[  337.127675] 6946877+0 records out
[  337.127676]=20
[  337.134002] 28454408192 bytes (28 GB, 27 GiB) copied, 299.989 s, 94.9 MB=
/s
[  337.134003]=20
[  337.143349] 5153430+0 records in
[  337.143350]=20
[  337.149086] 5153429+0 records out
[  337.149087]=20
[  337.155419] 21108445184 bytes (21 GB, 20 GiB) copied, 299.988 s, 70.4 MB=
/s
[  337.155421]=20
[  337.164778] 4888436+0 records in
[  337.164779]=20
[  337.170511] 4888435+0 records out
[  337.170511]=20
[  337.176828] 20023029760 bytes (20 GB, 19 GiB) copied, 300.016 s, 66.7 MB=
/s
[  337.176829]=20
[  337.186185] 5065888+0 records in
[  337.186186]=20
[  337.191916] 5065887+0 records out
[  337.191917]=20
[  337.198244] 20749873152 bytes (21 GB, 19 GiB) copied, 300.003 s, 69.2 MB=
/s
[  337.198245]=20
[  337.207588] 5876201+0 records in
[  337.207589]=20
[  337.213315] 5876200+0 records out
[  337.213316]=20
[  337.219637] 24068915200 bytes (24 GB, 22 GiB) copied, 300.01 s, 80.2 MB/s
[  337.219638]=20
[  337.228900] 5090901+0 records in
[  337.228901]=20
[  337.234633] 5090900+0 records out
[  337.234634]=20
[  337.240901] 20852326400 bytes (21 GB, 19 GiB) copied, 300 s, 69.5 MB/s
[  337.240902]=20
[  337.249905] 4928621+0 records in
[  337.249905]=20
[  337.255631] 4928620+0 records out
[  337.255632]=20
[  337.261952] 20187627520 bytes (20 GB, 19 GiB) copied, 300.013 s, 67.3 MB=
/s
[  337.261953]=20
[  337.271301] 4910329+0 records in
[  337.271302]=20
[  337.277033] 4910328+0 records out
[  337.277034]=20
[  337.283350] 20112703488 bytes (20 GB, 19 GiB) copied, 300.001 s, 67.0 MB=
/s
[  337.283352]=20
[  337.292698] 4736282+0 records in
[  337.292698]=20
[  337.298427] 4736281+0 records out
[  337.298428]=20
[  337.304741] 19399806976 bytes (19 GB, 18 GiB) copied, 300.002 s, 64.7 MB=
/s
[  337.304742]=20
[  337.314097] 4905756+0 records in
[  337.314098]=20
[  337.319829] 4905755+0 records out
[  337.319830]=20
[  337.326150] 20093972480 bytes (20 GB, 19 GiB) copied, 300.009 s, 67.0 MB=
/s
[  337.326152]=20
[  337.335499] 6846825+0 records in
[  337.335500]=20
[  337.341229] 6846824+0 records out
[  337.341230]=20
[  337.347554] 28044591104 bytes (28 GB, 26 GiB) copied, 300.013 s, 93.5 MB=
/s
[  337.347555]=20
[  337.356898] 5077472+0 records in
[  337.356899]=20
[  337.362621] 5077471+0 records out
[  337.362622]=20
[  337.368933] 20797321216 bytes (21 GB, 19 GiB) copied, 299.999 s, 69.3 MB=
/s
[  337.368934]=20
[  337.378284] 5013781+0 records in
[  337.378285]=20
[  337.384023] 5013780+0 records out
[  337.384024]=20
[  337.390361] 20536442880 bytes (21 GB, 19 GiB) copied, 300.006 s, 68.5 MB=
/s
[  337.390363]=20
[  337.399704] 4827251+0 records in
[  337.399705]=20
[  337.405431] 4827250+0 records out
[  337.405432]=20
[  337.411752] 19772416000 bytes (20 GB, 18 GiB) copied, 300.003 s, 65.9 MB=
/s
[  337.411753]=20
[  337.421117] 5120712+0 records in
[  337.421118]=20
[  337.426851] 5120711+0 records out
[  337.426852]=20
[  337.433179] 20974432256 bytes (21 GB, 20 GiB) copied, 300.023 s, 69.9 MB=
/s
[  337.433181]=20
[  337.442535] 4859204+0 records in
[  337.442536]=20
[  337.448273] 4859203+0 records out
[  337.448273]=20
[  337.454601] 19903295488 bytes (20 GB, 19 GiB) copied, 300.018 s, 66.3 MB=
/s
[  337.454602]=20
[  337.463949] 5290253+0 records in
[  337.463949]=20
[  337.469675] 5290252+0 records out
[  337.469676]=20
[  337.476006] 21668872192 bytes (22 GB, 20 GiB) copied, 300.005 s, 72.2 MB=
/s
[  337.476007]=20
[  337.485355] 4761426+0 records in
[  337.485355]=20
[  337.491085] 4761425+0 records out
[  337.491086]=20
[  337.497409] 19502796800 bytes (20 GB, 18 GiB) copied, 300.002 s, 65.0 MB=
/s
[  337.497411]=20
[  337.506761] 4795933+0 records in
[  337.506762]=20
[  337.512491] 4795932+0 records out
[  337.512492]=20
[  337.518808] 19644137472 bytes (20 GB, 18 GiB) copied, 300.013 s, 65.5 MB=
/s
[  337.518809]=20
[  337.528172] 4914608+0 records in
[  337.528173]=20
[  337.533902] 4914607+0 records out
[  337.533903]=20
[  337.540226] 20130230272 bytes (20 GB, 19 GiB) copied, 300.011 s, 67.1 MB=
/s
[  337.540227]=20
[  337.549581] 6861559+0 records in
[  337.549582]=20
[  337.555313] 6861558+0 records out
[  337.555314]=20
[  337.561627] 28104941568 bytes (28 GB, 26 GiB) copied, 300.02 s, 93.7 MB/s
[  337.561628]=20
[  337.570903] 5166740+0 records in
[  337.570903]=20
[  337.576634] 5166739+0 records out
[  337.576635]=20
[  337.582952] 21162962944 bytes (21 GB, 20 GiB) copied, 300.012 s, 70.5 MB=
/s
[  337.582953]=20
[  337.592300] 6841987+0 records in
[  337.592301]=20
[  337.598037] 6841986+0 records out
[  337.598038]=20
[  337.604317] 28024774656 bytes (28 GB, 26 GiB) copied, 300 s, 93.4 MB/s
[  337.604318]=20
[  337.613312] 6741325+0 records in
[  337.613313]=20
[  337.619041] 6741324+0 records out
[  337.619042]=20
[  337.625362] 27612463104 bytes (28 GB, 26 GiB) copied, 300.013 s, 92.0 MB=
/s
[  337.625363]=20
[  337.634704] 5111518+0 records in
[  337.634704]=20
[  337.640433] 5111517+0 records out
[  337.640434]=20
[  337.646754] 20936773632 bytes (21 GB, 19 GiB) copied, 300.006 s, 69.8 MB=
/s
[  337.646755]=20
[  337.656115] 4898681+0 records in
[  337.656116]=20
[  337.661846] 4898680+0 records out
[  337.661846]=20
[  337.668156] 20064993280 bytes (20 GB, 19 GiB) copied, 300.01 s, 66.9 MB/s
[  337.668157]=20
[  337.677419] 5075027+0 records in
[  337.677420]=20
[  337.683144] 5075026+0 records out
[  337.683145]=20
[  337.689461] 20787306496 bytes (21 GB, 19 GiB) copied, 299.999 s, 69.3 MB=
/s
[  337.689462]=20
[  337.698806] 5741517+0 records in
[  337.698807]=20
[  337.704533] 5741516+0 records out
[  337.704533]=20
[  337.710837] 23517249536 bytes (24 GB, 22 GiB) copied, 299.999 s, 78.4 MB=
/s
[  337.710838]=20
[  337.720183] 4798867+0 records in
[  337.720184]=20
[  337.725907] 4798866+0 records out
[  337.725907]=20
[  337.732225] 19656155136 bytes (20 GB, 18 GiB) copied, 300.019 s, 65.5 MB=
/s
[  337.732226]=20
[  337.741567] 5341917+0 records in
[  337.741568]=20
[  337.747297] 5341916+0 records out
[  337.747298]=20
[  337.753612] 21880487936 bytes (22 GB, 20 GiB) copied, 300.004 s, 72.9 MB=
/s
[  337.753613]=20
[  337.762958] 5975126+0 records in
[  337.762959]=20
[  337.768687] 5975125+0 records out
[  337.768687]=20
[  337.775000] 24474112000 bytes (24 GB, 23 GiB) copied, 299.999 s, 81.6 MB=
/s
[  337.775002]=20
[  337.784348] 4659009+0 records in
[  337.784349]=20
[  337.790080] 4659008+0 records out
[  337.790081]=20
[  337.796404] 19083296768 bytes (19 GB, 18 GiB) copied, 300.008 s, 63.6 MB=
/s
[  337.796405]=20
[  337.805751] 6841325+0 records in
[  337.805751]=20
[  337.811481] 6841324+0 records out
[  337.811482]=20
[  337.817799] 28022063104 bytes (28 GB, 26 GiB) copied, 300.009 s, 93.4 MB=
/s
[  337.817800]=20
[  337.827161] 4866816+0 records in
[  337.827162]=20
[  337.832888] 4866815+0 records out
[  337.832889]=20
[  337.839227] 19934474240 bytes (20 GB, 19 GiB) copied, 300.004 s, 66.4 MB=
/s
[  337.839228]=20
[  337.848582] 5041550+0 records in
[  337.848583]=20
[  337.854308] 5041549+0 records out
[  337.854309]=20
[  337.860634] 20650184704 bytes (21 GB, 19 GiB) copied, 300.005 s, 68.8 MB=
/s
[  337.860635]=20
[  337.869984] 6932288+0 records in
[  337.869985]=20
[  337.875712] 6932287+0 records out
[  337.875714]=20
[  337.882037] 28394647552 bytes (28 GB, 26 GiB) copied, 299.999 s, 94.6 MB=
/s
[  337.882038]=20
[  337.891384] 5012087+0 records in
[  337.891385]=20
[  337.897112] 5012086+0 records out
[  337.897113]=20
[  337.903436] 20529504256 bytes (21 GB, 19 GiB) copied, 300.007 s, 68.4 MB=
/s
[  337.903438]=20
[  337.912786] 6701511+0 records in
[  337.912787]=20
[  337.918527] 6701510+0 records out
[  337.918528]=20
[  337.924796] 27449384960 bytes (27 GB, 26 GiB) copied, 300 s, 91.5 MB/s
[  337.924797]=20
[  337.933803] 5272144+0 records in
[  337.933804]=20
[  337.939538] 5272143+0 records out
[  337.939539]=20
[  337.945865] 21594697728 bytes (22 GB, 20 GiB) copied, 299.999 s, 72.0 MB=
/s
[  337.945866]=20
[  337.955229] 4793897+0 records in
[  337.955230]=20
[  337.960961] 4793896+0 records out
[  337.960962]=20
[  337.967284] 19635798016 bytes (20 GB, 18 GiB) copied, 300.008 s, 65.5 MB=
/s
[  337.967285]=20
[  337.976636] 5153578+0 records in
[  337.976637]=20
[  337.982370] 5153577+0 records out
[  337.982371]=20
[  337.988692] 21109051392 bytes (21 GB, 20 GiB) copied, 300.003 s, 70.4 MB=
/s
[  337.988693]=20
[  337.998044] 5051910+0 records in
[  337.998045]=20
[  338.003770] 5051909+0 records out
[  338.003771]=20
[  338.010084] 20692619264 bytes (21 GB, 19 GiB) copied, 300.01 s, 69.0 MB/s
[  338.010085]=20
[  338.019345] 5270288+0 records in
[  338.019345]=20
[  338.025074] 5270287+0 records out
[  338.025075]=20
[  338.031395] 21587095552 bytes (22 GB, 20 GiB) copied, 299.998 s, 72.0 MB=
/s
[  338.031396]=20
[  338.040748] 6276045+0 records in
[  338.040749]=20
[  338.046480] 6276044+0 records out
[  338.046480]=20
[  338.052794] 25706676224 bytes (26 GB, 24 GiB) copied, 300.014 s, 85.7 MB=
/s
[  338.052795]=20
[  338.062147] 4835735+0 records in
[  338.062148]=20
[  338.067877] 4835734+0 records out
[  338.067878]=20
[  338.074197] 19807166464 bytes (20 GB, 18 GiB) copied, 299.992 s, 66.0 MB=
/s
[  338.074198]=20
[  338.083540] 5215151+0 records in
[  338.083541]=20
[  338.089263] 5215150+0 records out
[  338.089263]=20
[  338.095612] 21361254400 bytes (21 GB, 20 GiB) copied, 300.002 s, 71.2 MB=
/s
[  338.095613]=20
[  338.104966] 4891922+0 records in
[  338.104967]=20
[  338.110695] 4891921+0 records out
[  338.110695]=20
[  338.117020] 20037308416 bytes (20 GB, 19 GiB) copied, 300.014 s, 66.8 MB=
/s
[  338.117021]=20
[  338.126369] 5902552+0 records in
[  338.126369]=20
[  338.132104] 5902551+0 records out
[  338.132105]=20
[  338.138428] 24176848896 bytes (24 GB, 23 GiB) copied, 300.008 s, 80.6 MB=
/s
[  338.138430]=20
[  338.147778] 6843652+0 records in
[  338.147778]=20
[  338.153509] 6843651+0 records out
[  338.153510]=20
[  338.159852] 28031594496 bytes (28 GB, 26 GiB) copied, 300.003 s, 93.4 MB=
/s
[  338.159853]=20
[  338.169209] 6025813+0 records in
[  338.169210]=20
[  338.174935] 6025812+0 records out
[  338.174935]=20
[  338.181212] 24681725952 bytes (25 GB, 23 GiB) copied, 300 s, 82.3 MB/s
[  338.181213]=20
[  338.190222] 4952226+0 records in
[  338.190223]=20
[  338.195953] 4952225+0 records out
[  338.195954]=20
[  338.202283] 20284313600 bytes (20 GB, 19 GiB) copied, 300.001 s, 67.6 MB=
/s
[  338.202284]=20
[  338.211630] 5103661+0 records in
[  338.211631]=20
[  338.217367] 5103660+0 records out
[  338.217368]=20
[  338.223691] 20904591360 bytes (21 GB, 19 GiB) copied, 299.996 s, 69.7 MB=
/s
[  338.223692]=20
[  338.233052] 5568863+0 records in
[  338.233053]=20
[  338.238778] 5568862+0 records out
[  338.238779]=20
[  338.245128] 22810058752 bytes (23 GB, 21 GiB) copied, 299.988 s, 76.0 MB=
/s
[  338.245129]=20
[  338.254477] 4861331+0 records in
[  338.254477]=20
[  338.260207] 4861330+0 records out
[  338.260208]=20
[  338.266527] 19912007680 bytes (20 GB, 19 GiB) copied, 299.994 s, 66.4 MB=
/s
[  338.266528]=20
[  338.275872] 4995485+0 records in
[  338.275873]=20
[  338.281598] 4995484+0 records out
[  338.281599]=20
[  338.287908] 20461502464 bytes (20 GB, 19 GiB) copied, 300.001 s, 68.2 MB=
/s
[  338.287909]=20
[  338.297253] 5111711+0 records in
[  338.297254]=20
[  338.302978] 5111710+0 records out
[  338.302979]=20
[  338.309299] 20937564160 bytes (21 GB, 19 GiB) copied, 299.976 s, 69.8 MB=
/s
[  338.309300]=20
[  338.318658] 6778763+0 records in
[  338.318659]=20
[  338.324387] 6778762+0 records out
[  338.324388]=20
[  338.330704] 27765809152 bytes (28 GB, 26 GiB) copied, 299.986 s, 92.6 MB=
/s
[  338.330705]=20
[  338.340055] 5428809+0 records in
[  338.340056]=20
[  338.345783] 5428808+0 records out
[  338.345783]=20
[  338.352132] 22236397568 bytes (22 GB, 21 GiB) copied, 299.983 s, 74.1 MB=
/s
[  338.352133]=20
[  338.361482] 6717436+0 records in
[  338.361483]=20
[  338.367234] 6717435+0 records out
[  338.367235]=20
[  338.373557] 27514613760 bytes (28 GB, 26 GiB) copied, 300.004 s, 91.7 MB=
/s
[  338.373559]=20
[  338.382904] 4908050+0 records in
[  338.382905]=20
[  338.388629] 4908049+0 records out
[  338.388630]=20
[  338.394945] 20103368704 bytes (20 GB, 19 GiB) copied, 299.984 s, 67.0 MB=
/s
[  338.394946]=20
[  338.404302] 4808231+0 records in
[  338.404303]=20
[  338.410042] 4808230+0 records out
[  338.410043]=20
[  338.416366] 19694510080 bytes (20 GB, 18 GiB) copied, 299.994 s, 65.6 MB=
/s
[  338.416367]=20
[  338.425709] 5021720+0 records in
[  338.425710]=20
[  338.431444] 5021719+0 records out
[  338.431445]=20
[  338.437763] 20568961024 bytes (21 GB, 19 GiB) copied, 299.988 s, 68.6 MB=
/s
[  338.437763]=20
[  338.447127] 5065601+0 records in
[  338.447128]=20
[  338.452854] 5065600+0 records out
[  338.452855]=20
[  338.459179] 20748697600 bytes (21 GB, 19 GiB) copied, 299.981 s, 69.2 MB=
/s
[  338.459180]=20
[  338.468528] 4882762+0 records in
[  338.468529]=20
[  338.474256] 4882761+0 records out
[  338.474257]=20
[  338.480589] 19999789056 bytes (20 GB, 19 GiB) copied, 299.993 s, 66.7 MB=
/s
[  338.480590]=20
[  338.489940] 4671285+0 records in
[  338.489941]=20
[  338.495670] 4671284+0 records out
[  338.495671]=20
[  338.501987] 19133579264 bytes (19 GB, 18 GiB) copied, 299.976 s, 63.8 MB=
/s
[  338.501988]=20
[  338.511338] 6794222+0 records in
[  338.511339]=20
[  338.517072] 6794221+0 records out
[  338.517073]=20
[  338.523393] 27829129216 bytes (28 GB, 26 GiB) copied, 300.002 s, 92.8 MB=
/s
[  338.523395]=20
[  338.532741] 6219693+0 records in
[  338.532741]=20
[  338.538472] 6219692+0 records out
[  338.538473]=20
[  338.544778] 25475858432 bytes (25 GB, 24 GiB) copied, 299.99 s, 84.9 MB/s
[  338.544779]=20
[  338.554044] 5066369+0 records in
[  338.554045]=20
[  338.559769] 5066368+0 records out
[  338.559770]=20
[  338.566093] 20751843328 bytes (21 GB, 19 GiB) copied, 299.995 s, 69.2 MB=
/s
[  338.566094]=20
[  338.575444] 5229910+0 records in
[  338.575445]=20
[  338.581175] 5229909+0 records out
[  338.581176]=20
[  338.587492] 21421707264 bytes (21 GB, 20 GiB) copied, 299.988 s, 71.4 MB=
/s
[  338.587493]=20
[  338.596842] 4823948+0 records in
[  338.596843]=20
[  338.602571] 4823947+0 records out
[  338.602572]=20
[  338.608889] 19758886912 bytes (20 GB, 18 GiB) copied, 299.987 s, 65.9 MB=
/s
[  338.608890]=20
[  338.618253] 6747805+0 records in
[  338.618254]=20
[  338.623989] 6747804+0 records out
[  338.623990]=20
[  338.630317] 27639005184 bytes (28 GB, 26 GiB) copied, 299.986 s, 92.1 MB=
/s
[  338.630318]=20
[  338.639672] 6703017+0 records in
[  338.639673]=20
[  338.645405] 6703016+0 records out
[  338.645406]=20
[  338.651724] 27455553536 bytes (27 GB, 26 GiB) copied, 299.991 s, 91.5 MB=
/s
[  338.651725]=20
[  338.661083] 4871763+0 records in
[  338.661085]=20
[  338.666812] 4871762+0 records out
[  338.666812]=20
[  338.673135] 19954737152 bytes (20 GB, 19 GiB) copied, 299.981 s, 66.5 MB=
/s
[  338.673136]=20
[  338.682486] 6648879+0 records in
[  338.682486]=20
[  338.688227] 6648878+0 records out
[  338.688228]=20
[  338.694555] 27233804288 bytes (27 GB, 25 GiB) copied, 299.988 s, 90.8 MB=
/s
[  338.694556]=20
[  338.703909] 6757784+0 records in
[  338.703909]=20
[  338.709635] 6757783+0 records out
[  338.709635]=20
[  338.715957] 27679879168 bytes (28 GB, 26 GiB) copied, 299.986 s, 92.3 MB=
/s
[  338.715958]=20
[  338.725304] 4975837+0 records in
[  338.725305]=20
[  338.731045] 4975836+0 records out
[  338.731046]=20
[  338.737371] 20381024256 bytes (20 GB, 19 GiB) copied, 299.983 s, 67.9 MB=
/s
[  338.737372]=20
[  338.746727] 6855967+0 records in
[  338.746727]=20
[  338.752465] 6855966+0 records out
[  338.752466]=20
[  338.758790] 28082036736 bytes (28 GB, 26 GiB) copied, 300.005 s, 93.6 MB=
/s
[  338.758791]=20
[  338.768152] 6789327+0 records in
[  338.768153]=20
[  338.773889] 6789326+0 records out
[  338.773889]=20
[  338.780211] 27809079296 bytes (28 GB, 26 GiB) copied, 299.989 s, 92.7 MB=
/s
[  338.780212]=20
[  338.789560] 6772282+0 records in
[  338.789561]=20
[  338.795287] 6772281+0 records out
[  338.795288]=20
[  338.801608] 27739262976 bytes (28 GB, 26 GiB) copied, 299.988 s, 92.5 MB=
/s
[  338.801609]=20
[  338.810954] 5448118+0 records in
[  338.810955]=20
[  338.816684] 5448117+0 records out
[  338.816685]=20
[  338.823004] 22315487232 bytes (22 GB, 21 GiB) copied, 299.997 s, 74.4 MB=
/s
[  338.823005]=20
[  338.832352] 4678763+0 records in
[  338.832352]=20
[  338.839217] 4678762+0 records out
[  338.839218]=20
[  338.845551] 19164209152 bytes (19 GB, 18 GiB) copied, 299.987 s, 63.9 MB=
/s
[  338.845552]=20
[  338.854906] 4705375+0 records in
[  338.854907]=20
[  338.860638] 4705374+0 records out
[  338.860639]=20
[  338.866971] 19273211904 bytes (19 GB, 18 GiB) copied, 299.982 s, 64.2 MB=
/s
[  338.866972]=20
[  338.876322] 6840592+0 records in
[  338.876323]=20
[  338.882059] 6840591+0 records out
[  338.882060]=20
[  338.888387] 28019060736 bytes (28 GB, 26 GiB) copied, 299.991 s, 93.4 MB=
/s
[  338.888388]=20
[  338.897737] 4890933+0 records in
[  338.897738]=20
[  338.903466] 4890932+0 records out
[  338.903467]=20
[  338.909791] 20033257472 bytes (20 GB, 19 GiB) copied, 299.987 s, 66.8 MB=
/s
[  338.909792]=20
[  338.919156] 6371433+0 records in
[  338.919157]=20
[  338.924890] 6371432+0 records out
[  338.924891]=20
[  338.931248] 26097385472 bytes (26 GB, 24 GiB) copied, 299.988 s, 87.0 MB=
/s
[  338.931249]=20
[  338.940598] 4822363+0 records in
[  338.940599]=20
[  338.946332] 4822362+0 records out
[  338.946333]=20
[  338.952655] 19752394752 bytes (20 GB, 18 GiB) copied, 299.985 s, 65.8 MB=
/s
[  338.952656]=20
[  338.962013] 6821508+0 records in
[  338.962014]=20
[  338.967746] 6821507+0 records out
[  338.967747]=20
[  338.974071] 27940892672 bytes (28 GB, 26 GiB) copied, 299.978 s, 93.1 MB=
/s
[  338.974072]=20
[  338.983416] 6787751+0 records in
[  338.983416]=20
[  338.989150] 6787750+0 records out
[  338.989151]=20
[  338.995469] 27802624000 bytes (28 GB, 26 GiB) copied, 300.007 s, 92.7 MB=
/s
[  338.995471]=20
[  339.004823] 4776722+0 records in
[  339.004823]=20
[  339.010555] 4776721+0 records out
[  339.010556]=20
[  339.016878] 19565449216 bytes (20 GB, 18 GiB) copied, 299.987 s, 65.2 MB=
/s
[  339.016878]=20
[  339.026239] 4768570+0 records in
[  339.026240]=20
[  339.031970] 4768569+0 records out
[  339.031971]=20
[  339.038301] 19532058624 bytes (20 GB, 18 GiB) copied, 299.985 s, 65.1 MB=
/s
[  339.038302]=20
[  339.047655] 6900344+0 records in
[  339.047656]=20
[  339.053386] 6900343+0 records out
[  339.053387]=20
[  339.059716] 28263804928 bytes (28 GB, 26 GiB) copied, 299.989 s, 94.2 MB=
/s
[  339.059717]=20
[  339.069073] 4875709+0 records in
[  339.069075]=20
[  339.074798] 4875708+0 records out
[  339.074798]=20
[  339.081131] 19970899968 bytes (20 GB, 19 GiB) copied, 299.991 s, 66.6 MB=
/s
[  339.081133]=20
[  339.090481] 5061140+0 records in
[  339.090481]=20
[  339.096210] 5061139+0 records out
[  339.096211]=20
[  339.102532] 20730425344 bytes (21 GB, 19 GiB) copied, 299.984 s, 69.1 MB=
/s
[  339.102533]=20
[  339.111879] 6771544+0 records in
[  339.111879]=20
[  339.117604] 6771543+0 records out
[  339.117605]=20
[  339.123933] 27736240128 bytes (28 GB, 26 GiB) copied, 299.986 s, 92.5 MB=
/s
[  339.123934]=20
[  339.133278] 4843945+0 records in
[  339.133278]=20
[  339.139015] 4843944+0 records out
[  339.139016]=20
[  339.145341] 19840794624 bytes (20 GB, 18 GiB) copied, 299.983 s, 66.1 MB=
/s
[  339.145342]=20
[  339.154688] 4998634+0 records in
[  339.154688]=20
[  339.160420] 4998633+0 records out
[  339.160421]=20
[  339.166740] 20474400768 bytes (20 GB, 19 GiB) copied, 299.981 s, 68.3 MB=
/s
[  339.166741]=20
[  339.176090] 4885818+0 records in
[  339.176092]=20
[  339.181825] 4885817+0 records out
[  339.181825]=20
[  339.188148] 20012306432 bytes (20 GB, 19 GiB) copied, 299.986 s, 66.7 MB=
/s
[  339.188149]=20
[  339.197496] 5085578+0 records in
[  339.197497]=20
[  339.203226] 5085577+0 records out
[  339.203227]=20
[  339.209547] 20830523392 bytes (21 GB, 19 GiB) copied, 299.981 s, 69.4 MB=
/s
[  339.209548]=20
[  339.218896] 6924836+0 records in
[  339.218897]=20
[  339.224629] 6924835+0 records out
[  339.224630]=20
[  339.230900] 28364124160 bytes (28 GB, 26 GiB) copied, 300 s, 94.5 MB/s
[  339.230901]=20
[  339.239901] 6858137+0 records in
[  339.239901]=20
[  339.245629] 6858136+0 records out
[  339.245630]=20
[  339.251976] 28090925056 bytes (28 GB, 26 GiB) copied, 300.001 s, 93.6 MB=
/s
[  339.251977]=20
[  339.261330] 4804284+0 records in
[  339.261331]=20
[  339.267058] 4804283+0 records out
[  339.267059]=20
[  339.273391] 19678343168 bytes (20 GB, 18 GiB) copied, 299.986 s, 65.6 MB=
/s
[  339.273392]=20
[  339.282737] 4715739+0 records in
[  339.282738]=20
[  339.288459] 4715739+0 records out
[  339.288460]=20
[  339.295340] 19315666944 bytes (19 GB, 18 GiB) copied, 299.96 s, 64.4 MB/s
[  339.295341]=20
[  339.304601] 6828754+0 records in
[  339.304602]=20
[  339.310328] 6828753+0 records out
[  339.310329]=20
[  339.316665] 27970572288 bytes (28 GB, 26 GiB) copied, 299.976 s, 93.2 MB=
/s
[  339.316666]=20
[  339.326012] 6894099+0 records in
[  339.326013]=20
[  339.331738] 6894098+0 records out
[  339.331740]=20
[  339.338070] 28238225408 bytes (28 GB, 26 GiB) copied, 299.989 s, 94.1 MB=
/s
[  339.338071]=20
[  339.347414] 6767024+0 records in
[  339.347415]=20
[  339.353151] 6767023+0 records out
[  339.353152]=20
[  339.359469] 27717726208 bytes (28 GB, 26 GiB) copied, 299.982 s, 92.4 MB=
/s
[  339.359471]=20
[  339.368836] 4909688+0 records in
[  339.368837]=20
[  339.374561] 4909687+0 records out
[  339.374562]=20
[  339.380886] 20110077952 bytes (20 GB, 19 GiB) copied, 299.976 s, 67.0 MB=
/s
[  339.380887]=20
[  339.390245] 6784381+0 records in
[  339.390246]=20
[  339.395976] 6784380+0 records out
[  339.395977]=20
[  339.402292] 27788820480 bytes (28 GB, 26 GiB) copied, 299.987 s, 92.6 MB=
/s
[  339.402293]=20
[  339.411641] 4945656+0 records in
[  339.411642]=20
[  339.417370] 4945655+0 records out
[  339.417371]=20
[  339.423696] 20257402880 bytes (20 GB, 19 GiB) copied, 299.981 s, 67.5 MB=
/s
[  339.423697]=20
[  339.433059] 5088261+0 records in
[  339.433061]=20
[  339.438798] 5088260+0 records out
[  339.438799]=20
[  339.445125] 20841512960 bytes (21 GB, 19 GiB) copied, 299.982 s, 69.5 MB=
/s
[  339.445125]=20
[  339.454479] 5029398+0 records in
[  339.454480]=20
[  339.460215] 5029397+0 records out
[  339.460216]=20
[  339.466545] 20600410112 bytes (21 GB, 19 GiB) copied, 299.987 s, 68.7 MB=
/s
[  339.466546]=20
[  339.475899] 6907892+0 records in
[  339.475900]=20
[  339.481624] 6907891+0 records out
[  339.481624]=20
[  339.487897] 28294721536 bytes (28 GB, 26 GiB) copied, 300 s, 94.3 MB/s
[  339.487898]=20
[  339.496910] 4911132+0 records in
[  339.496911]=20
[  339.502643] 4911131+0 records out
[  339.502644]=20
[  339.508973] 20115992576 bytes (20 GB, 19 GiB) copied, 299.978 s, 67.1 MB=
/s
[  339.508974]=20
[  339.518336] 6948216+0 records in
[  339.518337]=20
[  339.524084] 6948215+0 records out
[  339.524085]=20
[  339.530424] 28459888640 bytes (28 GB, 27 GiB) copied, 299.974 s, 94.9 MB=
/s
[  339.530425]=20
[  339.539775] 5155126+0 records in
[  339.539776]=20
[  339.545508] 5155125+0 records out
[  339.545509]=20
[  339.551818] 21115392000 bytes (21 GB, 20 GiB) copied, 299.988 s, 70.4 MB=
/s
[  339.551819]=20
[  339.561176] 4888291+0 records in
[  339.561177]=20
[  339.566904] 4888290+0 records out
[  339.566905]=20
[  339.573180] 20022435840 bytes (20 GB, 19 GiB) copied, 300 s, 66.7 MB/s
[  339.573181]=20
[  339.582187] 5065719+0 records in
[  339.582188]=20
[  339.587919] 5065718+0 records out
[  339.587920]=20
[  339.594259] 20749180928 bytes (21 GB, 19 GiB) copied, 300.019 s, 69.2 MB=
/s
[  339.594260]=20
[  339.603612] 5876154+0 records in
[  339.603613]=20
[  339.609342] 5876153+0 records out
[  339.609343]=20
[  339.615656] 24068722688 bytes (24 GB, 22 GiB) copied, 300.011 s, 80.2 MB=
/s
[  339.615657]=20
[  339.625012] 5090713+0 records in
[  339.625013]=20
[  339.630737] 5090712+0 records out
[  339.630738]=20
[  339.637055] 20851556352 bytes (21 GB, 19 GiB) copied, 300.012 s, 69.5 MB=
/s
[  339.637056]=20
[  339.646406] 4928737+0 records in
[  339.646407]=20
[  339.652140] 4928736+0 records out
[  339.652140]=20
[  339.658473] 20188102656 bytes (20 GB, 19 GiB) copied, 300.017 s, 67.3 MB=
/s
[  339.658475]=20
[  339.667825] 4911291+0 records in
[  339.667825]=20
[  339.673552] 4911290+0 records out
[  339.673553]=20
[  339.679874] 20116643840 bytes (20 GB, 19 GiB) copied, 300.014 s, 67.1 MB=
/s
[  339.679875]=20
[  339.689224] 4736366+0 records in
[  339.689225]=20
[  339.694946] 4736365+0 records out
[  339.694947]=20
[  339.701272] 19400151040 bytes (19 GB, 18 GiB) copied, 300.026 s, 64.7 MB=
/s
[  339.701273]=20
[  339.710626] 4905099+0 records in
[  339.710626]=20
[  339.716359] 4905098+0 records out
[  339.716360]=20
[  339.722680] 20091281408 bytes (20 GB, 19 GiB) copied, 300.004 s, 67.0 MB=
/s
[  339.722681]=20
[  339.732036] 6846796+0 records in
[  339.732038]=20
[  339.737766] 6846795+0 records out
[  339.737766]=20
[  339.744053] 28044472320 bytes (28 GB, 26 GiB) copied, 300 s, 93.5 MB/s
[  339.744055]=20
[  339.753066] 5077559+0 records in
[  339.753067]=20
[  339.758788] 5077558+0 records out
[  339.758788]=20
[  339.765115] 20797677568 bytes (21 GB, 19 GiB) copied, 300.042 s, 69.3 MB=
/s
[  339.765116]=20
[  339.774465] 5013625+0 records in
[  339.774466]=20
[  339.780193] 5013624+0 records out
[  339.780194]=20
[  339.786519] 20535803904 bytes (21 GB, 19 GiB) copied, 300.003 s, 68.5 MB=
/s
[  339.786521]=20
[  339.795868] 4827712+0 records in
[  339.795868]=20
[  339.801597] 4827711+0 records out
[  339.801598]=20
[  339.807917] 19774304256 bytes (20 GB, 18 GiB) copied, 300.023 s, 65.9 MB=
/s
[  339.807918]=20
[  339.817260] 5120645+0 records in
[  339.817261]=20
[  339.822982] 5120644+0 records out
[  339.822983]=20
[  339.829307] 20974157824 bytes (21 GB, 20 GiB) copied, 300.02 s, 69.9 MB/s
[  339.829308]=20
[  339.838565] 4860741+0 records in
[  339.838566]=20
[  339.844290] 4860740+0 records out
[  339.844291]=20
[  339.850613] 19909591040 bytes (20 GB, 19 GiB) copied, 300.009 s, 66.4 MB=
/s
[  339.850614]=20
[  339.859960] 5290097+0 records in
[  339.859961]=20
[  339.865686] 5290096+0 records out
[  339.865687]=20
[  339.872003] 21668233216 bytes (22 GB, 20 GiB) copied, 300.002 s, 72.2 MB=
/s
[  339.872004]=20
[  339.881357] 4761481+0 records in
[  339.881358]=20
[  339.887084] 4761480+0 records out
[  339.887085]=20
[  339.893412] 19503022080 bytes (20 GB, 18 GiB) copied, 300.004 s, 65.0 MB=
/s
[  339.893413]=20
[  339.902757] 4795201+0 records in
[  339.902757]=20
[  339.908487] 4795200+0 records out
[  339.908487]=20
[  339.914804] 19641139200 bytes (20 GB, 18 GiB) copied, 300.007 s, 65.5 MB=
/s
[  339.914805]=20
[  339.924158] 4913699+0 records in
[  339.924159]=20
[  339.929886] 4913698+0 records out
[  339.929887]=20
[  339.936207] 20126507008 bytes (20 GB, 19 GiB) copied, 300.001 s, 67.1 MB=
/s
[  339.936208]=20
[  339.945559] 6861086+0 records in
[  339.945559]=20
[  339.951293] 6861085+0 records out
[  339.951294]=20
[  339.957614] 28103004160 bytes (28 GB, 26 GiB) copied, 299.999 s, 93.7 MB=
/s
[  339.957615]=20
[  339.966956] 4732863+0 records in
[  339.966956]=20
[  339.972687] 4732862+0 records out
[  339.972688]=20
[  339.979013] 19385802752 bytes (19 GB, 18 GiB) copied, 300.011 s, 64.6 MB=
/s
[  339.979014]=20
[  339.988362] 6841955+0 records in
[  339.988362]=20
[  339.994091] 6841954+0 records out
[  339.994092]=20
[  340.000422] 28024643584 bytes (28 GB, 26 GiB) copied, 299.999 s, 93.4 MB=
/s
[  340.000423]=20
[  340.009768] 6741398+0 records in
[  340.009769]=20
[  340.015493] 6741398+0 records out
[  340.015494]=20
[  340.021807] 27612766208 bytes (28 GB, 26 GiB) copied, 299.999 s, 92.0 MB=
/s
[  340.021808]=20
[  340.031165] 5111388+0 records in
[  340.031166]=20
[  340.036888] 5111387+0 records out
[  340.036888]=20
[  340.043207] 20936241152 bytes (21 GB, 19 GiB) copied, 300.002 s, 69.8 MB=
/s
[  340.043208]=20
[  340.052557] 4898525+0 records in
[  340.052558]=20
[  340.058286] 4898524+0 records out
[  340.058287]=20
[  340.064625] 20064354304 bytes (20 GB, 19 GiB) copied, 300.011 s, 66.9 MB=
/s
[  340.064626]=20
[  340.073971] 5075041+0 records in
[  340.073972]=20
[  340.079697] 5075040+0 records out
[  340.079697]=20
[  340.086006] 20787363840 bytes (21 GB, 19 GiB) copied, 300.01 s, 69.3 MB/s
[  340.086007]=20
[  340.095272] 5741377+0 records in
[  340.095273]=20
[  340.101011] 5741376+0 records out
[  340.101012]=20
[  340.107329] 23516676096 bytes (24 GB, 22 GiB) copied, 299.999 s, 78.4 MB=
/s
[  340.107330]=20
[  340.116675] 4798911+0 records in
[  340.116676]=20
[  340.122407] 4798910+0 records out
[  340.122408]=20
[  340.128742] 19656335360 bytes (20 GB, 18 GiB) copied, 300.015 s, 65.5 MB=
/s
[  340.128743]=20
[  340.138096] 5341377+0 records in
[  340.138097]=20
[  340.143825] 5341376+0 records out
[  340.143825]=20
[  340.150159] 21878276096 bytes (22 GB, 20 GiB) copied, 300.017 s, 72.9 MB=
/s
[  340.150160]=20
[  340.159508] 5975094+0 records in
[  340.159509]=20
[  340.165242] 5975093+0 records out
[  340.165243]=20
[  340.171557] 24473980928 bytes (24 GB, 23 GiB) copied, 300.02 s, 81.6 MB/s
[  340.171558]=20
[  340.180827] 4658885+0 records in
[  340.180828]=20
[  340.186557] 4658884+0 records out
[  340.186558]=20
[  340.192882] 19082788864 bytes (19 GB, 18 GiB) copied, 300.011 s, 63.6 MB=
/s
[  340.192883]=20
[  340.202240] 6841369+0 records in
[  340.202241]=20
[  340.207970] 6841368+0 records out
[  340.207971]=20
[  340.214291] 28022243328 bytes (28 GB, 26 GiB) copied, 300.009 s, 93.4 MB=
/s
[  340.214292]=20
[  340.223638] 4867119+0 records in
[  340.223639]=20
[  340.229367] 4867118+0 records out
[  340.229368]=20
[  340.235702] 19935715328 bytes (20 GB, 19 GiB) copied, 300.006 s, 66.5 MB=
/s
[  340.235703]=20
[  340.245063] 5041674+0 records in
[  340.245064]=20
[  340.250786] 5041673+0 records out
[  340.250787]=20
[  340.257106] 20650692608 bytes (21 GB, 19 GiB) copied, 299.999 s, 68.8 MB=
/s
[  340.257107]=20
[  340.266456] 6932320+0 records in
[  340.266456]=20
[  340.272199] 6932319+0 records out
[  340.272200]=20
[  340.278472] 28394778624 bytes (28 GB, 26 GiB) copied, 300 s, 94.6 MB/s
[  340.278473]=20
[  340.287468] 5012043+0 records in
[  340.287469]=20
[  340.293199] 5012042+0 records out
[  340.293200]=20
[  340.299521] 20529324032 bytes (21 GB, 19 GiB) copied, 299.999 s, 68.4 MB=
/s
[  340.299522]=20
[  340.308865] 6701451+0 records in
[  340.308866]=20
[  340.314592] 6701450+0 records out
[  340.314593]=20
[  340.320873] 27449139200 bytes (27 GB, 26 GiB) copied, 300 s, 91.5 MB/s
[  340.320874]=20
[  340.329885] 5272172+0 records in
[  340.329885]=20
[  340.335614] 5272171+0 records out
[  340.335615]=20
[  340.341872] 21594812416 bytes (22 GB, 20 GiB) copied, 300 s, 72.0 MB/s
[  340.341873]=20
[  340.350869] 4793865+0 records in
[  340.350869]=20
[  340.356598] 4793864+0 records out
[  340.356599]=20
[  340.362913] 19635666944 bytes (20 GB, 18 GiB) copied, 300.022 s, 65.4 MB=
/s
[  340.362914]=20
[  340.372259] 5153608+0 records in
[  340.372260]=20
[  340.377984] 5153607+0 records out
[  340.377985]=20
[  340.384306] 21109174272 bytes (21 GB, 20 GiB) copied, 300.004 s, 70.4 MB=
/s
[  340.384307]=20
[  340.393650] 5051909+0 records in
[  340.393650]=20
[  340.399383] 5051908+0 records out
[  340.399383]=20
[  340.405702] 20692615168 bytes (21 GB, 19 GiB) copied, 299.998 s, 69.0 MB=
/s
[  340.405703]=20
[  340.415047] 5270767+0 records in
[  340.415048]=20
[  340.420774] 5270766+0 records out
[  340.420775]=20
[  340.427051] 21589057536 bytes (22 GB, 20 GiB) copied, 299.999 s, 72.0 MB=
/s
[  340.427051]=20
[  340.436313] 6275825+0 records in
[  340.436313]=20
[  340.441878] 6275824+0 records out
[  340.441879]=20
[  340.447960] 25705775104 bytes (26 GB, 24 GiB) copied, 300.065 s, 85.7 MB=
/s
[  340.447961]=20
[  340.457154] 4836339+0 records in
[  340.457155]=20
[  340.462731] 4836338+0 records out
[  340.462732]=20
[  340.468816] 19809640448 bytes (20 GB, 18 GiB) copied, 300.029 s, 66.0 MB=
/s
[  340.468816]=20
[  340.478018] 5215339+0 records in
[  340.478019]=20
[  340.483589] 5215338+0 records out
[  340.483590]=20
[  340.489670] 21362024448 bytes (21 GB, 20 GiB) copied, 299.998 s, 71.2 MB=
/s
[  340.489671]=20
[  340.498858] 4892210+0 records in
[  340.498859]=20
[  340.504430] 4892209+0 records out
[  340.504430]=20
[  340.510522] 20038488064 bytes (20 GB, 19 GiB) copied, 299.997 s, 66.8 MB=
/s
[  340.510523]=20
[  340.519714] 5902994+0 records in
[  340.519714]=20
[  340.525282] 5902993+0 records out
[  340.525283]=20
[  340.531385] 24178659328 bytes (24 GB, 23 GiB) copied, 299.999 s, 80.6 MB=
/s
[  340.531386]=20
[  340.540579] 6843744+0 records in
[  340.540579]=20
[  340.546148] 6843743+0 records out
[  340.546149]=20
[  340.552237] 28031971328 bytes (28 GB, 26 GiB) copied, 300.005 s, 93.4 MB=
/s
[  340.552238]=20
[  340.561430] 6025042+0 records in
[  340.561430]=20
[  340.567027] 6025041+0 records out
[  340.567028]=20
[  340.573123] 24678567936 bytes (25 GB, 23 GiB) copied, 299.998 s, 82.3 MB=
/s
[  340.573124]=20
[  340.582317] 4952318+0 records in
[  340.582318]=20
[  340.587888] 4952317+0 records out
[  340.587889]=20
[  340.593973] 20284690432 bytes (20 GB, 19 GiB) copied, 300.013 s, 67.6 MB=
/s
[  340.593973]=20
[  340.603166] 5103532+0 records in
[  340.603167]=20
[  340.608731] 5103531+0 records out
[  340.608731]=20
[  340.614807] 20904062976 bytes (21 GB, 19 GiB) copied, 299.99 s, 69.7 MB/s
[  340.614807]=20
[  340.623919] 5568438+0 records in
[  340.623920]=20
[  340.629491] 5568437+0 records out
[  340.629492]=20
[  340.635570] 22808317952 bytes (23 GB, 21 GiB) copied, 299.983 s, 76.0 MB=
/s
[  340.635571]=20
[  340.644760] 4860560+0 records in
[  340.644761]=20
[  340.650328] 4860559+0 records out
[  340.650329]=20
[  340.656369] 19908849664 bytes (20 GB, 19 GiB) copied, 300 s, 66.4 MB/s
[  340.656370]=20
[  340.665221] 4995705+0 records in
[  340.665221]=20
[  340.670782] 4995704+0 records out
[  340.670783]=20
[  340.676864] 20462403584 bytes (20 GB, 19 GiB) copied, 300.006 s, 68.2 MB=
/s
[  340.676865]=20
[  340.686059] 5112148+0 records in
[  340.686060]=20
[  340.691632] 5112147+0 records out
[  340.691632]=20
[  340.697701] 20939354112 bytes (21 GB, 20 GiB) copied, 300.01 s, 69.8 MB/s
[  340.697701]=20
[  340.706818] 6779143+0 records in
[  340.706819]=20
[  340.712392] 6779142+0 records out
[  340.712393]=20
[  340.718476] 27767365632 bytes (28 GB, 26 GiB) copied, 299.981 s, 92.6 MB=
/s
[  340.718477]=20
[  340.727667] 5428681+0 records in
[  340.727668]=20
[  340.733237] 5428680+0 records out
[  340.733238]=20
[  340.739326] 22235873280 bytes (22 GB, 21 GiB) copied, 299.992 s, 74.1 MB=
/s
[  340.739327]=20
[  340.748534] 6717335+0 records in
[  340.748534]=20
[  340.754104] 6717334+0 records out
[  340.754105]=20
[  340.760242] 27514200064 bytes (28 GB, 26 GiB) copied, 299.997 s, 91.7 MB=
/s
[  340.760243]=20
[  340.769437] 4907922+0 records in
[  340.769438]=20
[  340.775007] 4907921+0 records out
[  340.775008]=20
[  340.781089] 20102844416 bytes (20 GB, 19 GiB) copied, 299.989 s, 67.0 MB=
/s
[  340.781090]=20
[  340.790286] 4808908+0 records in
[  340.790286]=20
[  340.795857] 4808907+0 records out
[  340.795857]=20
[  340.801933] 19697283072 bytes (20 GB, 18 GiB) copied, 299.985 s, 65.7 MB=
/s
[  340.801934]=20
[  340.811131] 5021784+0 records in
[  340.811132]=20
[  340.816699] 5021783+0 records out
[  340.816699]=20
[  340.822775] 20569223168 bytes (21 GB, 19 GiB) copied, 299.983 s, 68.6 MB=
/s
[  340.822776]=20
[  340.831965] 5065596+0 records in
[  340.831966]=20
[  340.837558] 5065595+0 records out
[  340.837559]=20
[  340.843649] 20748677120 bytes (21 GB, 19 GiB) copied, 299.993 s, 69.2 MB=
/s
[  340.843650]=20
[  340.852839] 4881799+0 records in
[  340.852839]=20
[  340.858410] 4881798+0 records out
[  340.858411]=20
[  340.864510] 19995844608 bytes (20 GB, 19 GiB) copied, 300.005 s, 66.7 MB=
/s
[  340.864511]=20
[  340.873717] 4671511+0 records in
[  340.873717]=20
[  340.879309] 4671510+0 records out
[  340.879310]=20
[  340.885396] 19134504960 bytes (19 GB, 18 GiB) copied, 299.99 s, 63.8 MB/s
[  340.885397]=20
[  340.894527] 6794254+0 records in
[  340.894527]=20
[  340.900104] 6794253+0 records out
[  340.900105]=20
[  340.906191] 27829260288 bytes (28 GB, 26 GiB) copied, 300.008 s, 92.8 MB=
/s
[  340.906192]=20
[  340.915398] 6219661+0 records in
[  340.915398]=20
[  340.920970] 6219660+0 records out
[  340.920971]=20
[  340.927060] 25475727360 bytes (25 GB, 24 GiB) copied, 299.992 s, 84.9 MB=
/s
[  340.927061]=20
[  340.936258] 5066337+0 records in
[  340.936259]=20
[  340.941827] 5066336+0 records out
[  340.941827]=20
[  340.947918] 20751712256 bytes (21 GB, 19 GiB) copied, 299.979 s, 69.2 MB=
/s
[  340.947919]=20
[  340.957117] 5230742+0 records in
[  340.957118]=20
[  340.962690] 5230741+0 records out
[  340.962690]=20
[  340.968772] 21425115136 bytes (21 GB, 20 GiB) copied, 299.992 s, 71.4 MB=
/s
[  340.968773]=20
[  340.977993] 4823916+0 records in
[  340.977997]=20
[  340.983588] 4823915+0 records out
[  340.983589]=20
[  340.989680] 19758755840 bytes (20 GB, 18 GiB) copied, 299.988 s, 65.9 MB=
/s
[  340.989681]=20
[  340.998881] 6748285+0 records in
[  340.998882]=20
[  341.004456] 6748284+0 records out
[  341.004457]=20
[  341.010543] 27640971264 bytes (28 GB, 26 GiB) copied, 299.991 s, 92.1 MB=
/s
[  341.010544]=20
[  341.019755] 6702985+0 records in
[  341.019756]=20
[  341.025330] 6702984+0 records out
[  341.025331]=20
[  341.031412] 27455422464 bytes (27 GB, 26 GiB) copied, 299.984 s, 91.5 MB=
/s
[  341.031413]=20
[  341.031613] 4871731+0 records in
[  341.031613]=20
[  341.031823] 4871730+0 records out
[  341.031823]=20
[  341.032516] 19954606080 bytes (20 GB, 19 GiB) copied, 299.995 s, 66.5 MB=
/s
[  341.032517]=20
[  341.032735] 6649295+0 records in
[  341.032736]=20
[  341.032944] 6649294+0 records out
[  341.032944]=20
[  341.033581] 27235508224 bytes (27 GB, 25 GiB) copied, 299.983 s, 90.8 MB=
/s
[  341.033582]=20
[  341.033784] 6757688+0 records in
[  341.033785]=20
[  341.033993] 6757687+0 records out
[  341.033994]=20
[  341.034631] 27679485952 bytes (28 GB, 26 GiB) copied, 299.986 s, 92.3 MB=
/s
[  341.034631]=20
[  341.034831] 4975329+0 records in
[  341.034832]=20
[  341.035070] 4975328+0 records out
[  341.035070]=20
[  341.035731] 20378943488 bytes (20 GB, 19 GiB) copied, 299.987 s, 67.9 MB=
/s
[  341.035732]=20
[  341.035930] 6855523+0 records in
[  341.035931]=20
[  341.036141] 6855522+0 records out
[  341.036142]=20
[  341.036786] 28080218112 bytes (28 GB, 26 GiB) copied, 300.004 s, 93.6 MB=
/s
[  341.036786]=20
[  341.036987] 6789295+0 records in
[  341.036988]=20
[  341.037231] 6789294+0 records out
[  341.037231]=20
[  341.037892] 27808948224 bytes (28 GB, 26 GiB) copied, 299.984 s, 92.7 MB=
/s
[  341.037892]=20
[  341.038097] 6772113+0 records in
[  341.038098]=20
[  341.038302] 6772112+0 records out
[  341.038302]=20
[  341.038933] 27738570752 bytes (28 GB, 26 GiB) copied, 299.991 s, 92.5 MB=
/s
[  341.038934]=20
[  341.039134] 5448082+0 records in
[  341.039135]=20
[  341.039343] 5448081+0 records out
[  341.039343]=20
[  341.039976] 22315339776 bytes (22 GB, 21 GiB) copied, 299.977 s, 74.4 MB=
/s
[  341.039977]=20
[  341.040208] 4678946+0 records in
[  341.040209]=20
[  341.040439] 4678945+0 records out
[  341.040440]=20
[  341.041100] 19164958720 bytes (19 GB, 18 GiB) copied, 299.991 s, 63.9 MB=
/s
[  341.041101]=20
[  341.041314] 4705435+0 records in
[  341.041315]=20
[  341.041537] 4705434+0 records out
[  341.041537]=20
[  341.042181] 19273457664 bytes (19 GB, 18 GiB) copied, 299.994 s, 64.2 MB=
/s
[  341.042181]=20
[  341.042384] 6841072+0 records in
[  341.042384]=20
[  341.042595] 6841071+0 records out
[  341.042596]=20
[  341.043233] 28021026816 bytes (28 GB, 26 GiB) copied, 299.987 s, 93.4 MB=
/s
[  341.043234]=20
[  341.043430] 4890967+0 records in
[  341.043431]=20
[  341.043640] 4890966+0 records out
[  341.043640]=20
[  341.044277] 20033396736 bytes (20 GB, 19 GiB) copied, 299.984 s, 66.8 MB=
/s
[  341.044277]=20
[  341.044476] 6371750+0 records in
[  341.044477]=20
[  341.044683] 6371750+0 records out
[  341.044684]=20
[  341.045393] 26098688000 bytes (26 GB, 24 GiB) copied, 299.982 s, 87.0 MB=
/s
[  341.045393]=20
[  341.045592] 4822012+0 records in
[  341.045592]=20
[  341.045799] 4822011+0 records out
[  341.045799]=20
[  341.046438] 19750957056 bytes (20 GB, 18 GiB) copied, 299.978 s, 65.8 MB=
/s
[  341.046438]=20
[  341.046637] 6821380+0 records in
[  341.046638]=20
[  341.046845] 6821379+0 records out
[  341.046845]=20
[  341.047482] 27940368384 bytes (28 GB, 26 GiB) copied, 299.989 s, 93.1 MB=
/s
[  341.047483]=20
[  341.047681] 6787783+0 records in
[  341.047681]=20
[  341.047890] 6787782+0 records out
[  341.047891]=20
[  341.048525] 27802755072 bytes (28 GB, 26 GiB) copied, 300.003 s, 92.7 MB=
/s
[  341.048526]=20
[  341.048724] 4776154+0 records in
[  341.048724]=20
[  341.048933] 4776153+0 records out
[  341.048933]=20
[  341.049638] 19563122688 bytes (20 GB, 18 GiB) copied, 299.985 s, 65.2 MB=
/s
[  341.049638]=20
[  341.049836] 4767258+0 records in
[  341.049837]=20
[  341.050045] 4767257+0 records out
[  341.050045]=20
[  341.050680] 19526684672 bytes (20 GB, 18 GiB) copied, 299.981 s, 65.1 MB=
/s
[  341.050680]=20
[  341.050881] 6899736+0 records in
[  341.050881]=20
[  341.051089] 6899735+0 records out
[  341.051089]=20
[  341.051734] 28261314560 bytes (28 GB, 26 GiB) copied, 299.991 s, 94.2 MB=
/s
[  341.051735]=20
[  341.051934] 4875642+0 records in
[  341.051934]=20
[  341.052143] 4875641+0 records out
[  341.052144]=20
[  341.052785] 19970625536 bytes (20 GB, 19 GiB) copied, 299.985 s, 66.6 MB=
/s
[  341.052785]=20
[  341.052984] 5059860+0 records in
[  341.052985]=20
[  341.053233] 5059859+0 records out
[  341.053233]=20
[  341.053892] 20725182464 bytes (21 GB, 19 GiB) copied, 299.987 s, 69.1 MB=
/s
[  341.053892]=20
[  341.054093] 6772920+0 records in
[  341.054093]=20
[  341.054303] 6772919+0 records out
[  341.054304]=20
[  341.054948] 27741876224 bytes (28 GB, 26 GiB) copied, 299.988 s, 92.5 MB=
/s
[  341.054948]=20
[  341.055149] 4843389+0 records in
[  341.055150]=20
[  341.055360] 4843388+0 records out
[  341.055361]=20
[  341.055999] 19838517248 bytes (20 GB, 18 GiB) copied, 299.991 s, 66.1 MB=
/s
[  341.056000]=20
[  341.056203] 4998230+0 records in
[  341.056203]=20
[  341.056409] 4998229+0 records out
[  341.056409]=20
[  341.057061] 20472745984 bytes (20 GB, 19 GiB) copied, 299.98 s, 68.2 MB/s
[  341.057061]=20
[  341.057274] 4885722+0 records in
[  341.057274]=20
[  341.057501] 4885721+0 records out
[  341.057502]=20
[  341.058139] 20011913216 bytes (20 GB, 19 GiB) copied, 299.991 s, 66.7 MB=
/s
[  341.058139]=20
[  341.058340] 5085917+0 records in
[  341.058340]=20
[  341.058549] 5085916+0 records out
[  341.058549]=20
[  341.059206] 20831911936 bytes (21 GB, 19 GiB) copied, 299.986 s, 69.4 MB=
/s
[  341.059207]=20
         Starting watchdog daemon...
         Starting Update UTMP about System Runlevel Changes...
[  352.148503] 2017-11-29 10:07:22  umount /tmp/vm-scalability-tmp/vm-scala=
bility
[  352.148504]=20
[  352.163710] XFS (loop0): Unmounting Filesystem
[  352.181937] 2017-11-29 10:07:22  rm /tmp/vm-scalability-tmp/vm-scalabili=
ty.img
[  352.181938]=20
[  352.191314] 2017-11-29 10:07:22  umount /tmp/vm-scalability-tmp
[  352.191314]=20
[  390.083956] Unknown type (Reserved) while parsing /sys/firmware/memmap/1=
5/type. Please report this as bug. Using RANGE_RESERVED now.
[  390.083958]=20
[  390.098961] Unknown type (Reserved) while parsing /sys/firmware/memmap/1=
3/type. Please report this as bug. Using RANGE_RESERVED now.
[  390.098962]=20
[  390.113964] Unknown type (Reserved) while parsing /sys/firmware/memmap/3=
/type. Please report this as bug. Using RANGE_RESERVED now.
[  390.113965]=20
[  390.128812] Unknown type (Reserved) while parsing /sys/firmware/memmap/1=
/type. Please report this as bug. Using RANGE_RESERVED now.
[  390.128813]=20
[  390.143633] Unknown type (Reserved) while parsing /sys/firmware/memmap/2=
0/type. Please report this as bug. Using RANGE_RESERVED now.
[  390.143634]=20
[  390.158545] Unknown type (Reserved) while parsing /sys/firmware/memmap/1=
9/type. Please report this as bug. Using RANGE_RESERVED now.
[  390.158546]=20
[  392.867396] umount: /tmp: target is busy
[  392.867399]=20
[  392.873602]         (In some cases useful info about processes that
[  392.873603]=20
[  392.882155]          use the device is found by lsof(8) or fuser(1).)
[  392.882156]=20
[  393.054075] umount: /sys/fs/cgroup/systemd: target is busy
[  393.054077]=20
[  393.062029]         (In some cases useful info about processes that
[  393.062031]=20
[  393.070771]          use the device is found by lsof(8) or fuser(1).)
[  393.070772]=20
[  393.079372] umount: /sys/fs/cgroup: target is busy
[  393.079372]=20
[  393.086593]         (In some cases useful info about processes that
[  393.086594]=20
[  393.095332]          use the device is found by lsof(8) or fuser(1).)
[  393.095333]=20
[  393.103753] umount: /run: target is busy
[  393.103754]=20
[  393.110935]         (In some cases useful info about processes that
[  393.110936]=20
[  393.121251]          use the device is found by lsof(8) or fuser(1).)
[  393.121252]=20
[  393.137549] umount: /dev: target is busy
LKP: kexecing
[  393.137551]=20

[  393.138480] LKP: kexecing
[  393.138483]=20
[  393.142871] kvm: exiting hardware virtualization
[  393.156248]         (In some cases useful info about processes that
[  393.156250]=20
[  393.166410]          use the device is found by lsof(8) or fuser(1).)
[  393.166411]=20
[  393.167416] sd 7:0:0:0: [sdb] Synchronizing SCSI cache
[  393.167493] sd 6:0:0:0: [sda] Synchronizing SCSI cache
[  393.187651] umount: /: not mounted
[  393.187652]=20
[  393.217875] i40e 0000:3d:00.1: Failed to update MAC address registers; c=
annot enable Multicast Magic packet wake up
[  394.229734] i40e 0000:3d:00.0: Failed to update MAC address registers; c=
annot enable Multicast Magic packet wake up
Starting new kernel

--y7hnjbnavwaasi5b
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.15.0-rc1 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
# CONFIG_NO_HZ_FULL_ALL is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
# CONFIG_CPU_ISOLATION is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
CONFIG_USERFAULTFD=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_SYSTEM_DATA_VERIFICATION=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_THIN_ARCHIVES=y
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_DEV_THROTTLING_LOW is not set
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_MQ_IOSCHED_KYBER=y
# CONFIG_IOSCHED_BFQ is not set
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_INTEL_RDT=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_NUMACHIP is not set
# CONFIG_X86_VSMP is not set
CONFIG_X86_UV=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_LPSS=y
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_PARAVIRT_SPINLOCKS=y
# CONFIG_QUEUED_LOCK_STAT is not set
CONFIG_XEN=y
CONFIG_XEN_PV=y
CONFIG_XEN_PV_SMP=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_PVHVM_SMP=y
CONFIG_XEN_512GB=y
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_PERF_EVENTS_AMD_POWER is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=m
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT is not set
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_ZONE_DEVICE=y
CONFIG_ARCH_HAS_HMM=y
# CONFIG_HMM_MIRROR is not set
# CONFIG_DEVICE_PRIVATE is not set
# CONFIG_DEVICE_PUBLIC is not set
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=m
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
# CONFIG_X86_INTEL_MPX is not set
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_EFI_MIXED is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
# CONFIG_LIVEPATCH is not set
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=m
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=m
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=m
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=m
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
CONFIG_ACPI_APEI_EINJ=m
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_DPTF_POWER is not set
CONFIG_ACPI_EXTLOG=m
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_AMD_FREQ_SENSITIVITY=m
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
# CONFIG_PCIE_PTM is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
# CONFIG_XEN_PCIDEV_FRONTEND is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_PCI_HYPERV is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=m

#
# DesignWare PCI Core Support
#
# CONFIG_PCIE_DW_PLAT is not set

#
# PCI host controller drivers
#
# CONFIG_VMD is not set

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
# CONFIG_TLS is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IP_TUNNEL=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=m
CONFIG_NET_UDP_TUNNEL=m
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
# CONFIG_INET_ESP_OFFLOAD is not set
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_INET_UDP_DIAG=m
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
# CONFIG_TCP_CONG_NV is not set
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
# CONFIG_TCP_CONG_DCTCP is not set
# CONFIG_TCP_CONG_CDG is not set
# CONFIG_TCP_CONG_BBR is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
# CONFIG_INET6_ESP_OFFLOAD is not set
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=m
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_FOU is not set
# CONFIG_IPV6_FOU_TUNNEL is not set
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=m

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_ACCT=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_LOG_COMMON=m
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_SNMP=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_SIP=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_REDIRECT=m
CONFIG_NETFILTER_SYNPROXY=m
CONFIG_NF_TABLES=m
# CONFIG_NF_TABLES_INET is not set
# CONFIG_NF_TABLES_NETDEV is not set
CONFIG_NFT_EXTHDR=m
CONFIG_NFT_META=m
# CONFIG_NFT_RT is not set
# CONFIG_NFT_NUMGEN is not set
CONFIG_NFT_CT=m
# CONFIG_NFT_SET_RBTREE is not set
# CONFIG_NFT_SET_HASH is not set
# CONFIG_NFT_SET_BITMAP is not set
CONFIG_NFT_COUNTER=m
CONFIG_NFT_LOG=m
CONFIG_NFT_LIMIT=m
# CONFIG_NFT_MASQ is not set
# CONFIG_NFT_REDIR is not set
CONFIG_NFT_NAT=m
# CONFIG_NFT_OBJREF is not set
# CONFIG_NFT_QUEUE is not set
# CONFIG_NFT_QUOTA is not set
# CONFIG_NFT_REJECT is not set
CONFIG_NFT_COMPAT=m
CONFIG_NFT_HASH=m
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_SET=m

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_CT=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
CONFIG_NETFILTER_XT_TARGET_HMARK=m
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
CONFIG_NETFILTER_XT_TARGET_LED=m
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_NAT=m
CONFIG_NETFILTER_XT_TARGET_NETMAP=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_REDIRECT=m
CONFIG_NETFILTER_XT_TARGET_TEE=m
CONFIG_NETFILTER_XT_TARGET_TPROXY=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_BPF=m
# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_CPU=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ECN=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_L2TP=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_NFACCT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_IP_SET=m
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=m
CONFIG_IP_SET_BITMAP_IPMAC=m
CONFIG_IP_SET_BITMAP_PORT=m
CONFIG_IP_SET_HASH_IP=m
# CONFIG_IP_SET_HASH_IPMARK is not set
CONFIG_IP_SET_HASH_IPPORT=m
CONFIG_IP_SET_HASH_IPPORTIP=m
CONFIG_IP_SET_HASH_IPPORTNET=m
# CONFIG_IP_SET_HASH_IPMAC is not set
# CONFIG_IP_SET_HASH_MAC is not set
# CONFIG_IP_SET_HASH_NETPORTNET is not set
CONFIG_IP_SET_HASH_NET=m
# CONFIG_IP_SET_HASH_NETNET is not set
CONFIG_IP_SET_HASH_NETPORT=m
CONFIG_IP_SET_HASH_NETIFACE=m
CONFIG_IP_SET_LIST_SET=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
# CONFIG_IP_VS_FO is not set
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
# CONFIG_NF_SOCKET_IPV4 is not set
CONFIG_NF_TABLES_IPV4=m
CONFIG_NFT_CHAIN_ROUTE_IPV4=m
# CONFIG_NFT_REJECT_IPV4 is not set
# CONFIG_NFT_DUP_IPV4 is not set
# CONFIG_NFT_FIB_IPV4 is not set
# CONFIG_NF_TABLES_ARP is not set
CONFIG_NF_DUP_IPV4=m
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=m
CONFIG_NF_REJECT_IPV4=m
CONFIG_NF_NAT_IPV4=m
CONFIG_NFT_CHAIN_NAT_IPV4=m
CONFIG_NF_NAT_MASQUERADE_IPV4=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_RPFILTER=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_SYNPROXY=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=m
CONFIG_NF_CONNTRACK_IPV6=m
# CONFIG_NF_SOCKET_IPV6 is not set
CONFIG_NF_TABLES_IPV6=m
CONFIG_NFT_CHAIN_ROUTE_IPV6=m
# CONFIG_NFT_REJECT_IPV6 is not set
# CONFIG_NFT_DUP_IPV6 is not set
# CONFIG_NFT_FIB_IPV6 is not set
CONFIG_NF_DUP_IPV6=m
CONFIG_NF_REJECT_IPV6=m
CONFIG_NF_LOG_IPV6=m
CONFIG_NF_NAT_IPV6=m
CONFIG_NFT_CHAIN_NAT_IPV6=m
# CONFIG_NF_NAT_MASQUERADE_IPV6 is not set
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RPFILTER=m
CONFIG_IP6_NF_MATCH_RT=m
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_TARGET_SYNPROXY=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m
# CONFIG_IP6_NF_NAT is not set
CONFIG_NF_TABLES_BRIDGE=m
# CONFIG_NFT_BRIDGE_META is not set
# CONFIG_NF_LOG_BRIDGE is not set
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
# CONFIG_NET_DCCPPROBE is not set
CONFIG_IP_SCTP=m
CONFIG_NET_SCTPPROBE=m
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=m
# CONFIG_RDS is not set
CONFIG_TIPC=m
CONFIG_TIPC_MEDIA_UDP=y
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=m
CONFIG_L2TP_DEBUGFS=m
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=m
CONFIG_L2TP_ETH=m
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_MRP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
CONFIG_IEEE802154=m
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
CONFIG_IEEE802154_SOCKET=m
CONFIG_MAC802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
# CONFIG_NET_SCH_CBS is not set
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=m
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
# CONFIG_NET_SCH_FQ is not set
# CONFIG_NET_SCH_HHF is not set
# CONFIG_NET_SCH_PIE is not set
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_SCH_PLUG=m
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=m
# CONFIG_NET_CLS_FLOWER is not set
# CONFIG_NET_CLS_MATCHALL is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
# CONFIG_NET_EMATCH_CANID is not set
CONFIG_NET_EMATCH_IPSET=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
# CONFIG_NET_ACT_SAMPLE is not set
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_ACT_SKBEDIT=m
CONFIG_NET_ACT_CSUM=m
# CONFIG_NET_ACT_VLAN is not set
# CONFIG_NET_ACT_BPF is not set
# CONFIG_NET_ACT_CONNMARK is not set
# CONFIG_NET_ACT_SKBMOD is not set
# CONFIG_NET_ACT_IFE is not set
# CONFIG_NET_ACT_TUNNEL_KEY is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=m
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_VSOCKETS=m
CONFIG_VSOCKETS_DIAG=m
CONFIG_VMWARE_VMCI_VSOCKETS=m
# CONFIG_VIRTIO_VSOCKETS is not set
# CONFIG_HYPERV_VSOCKETS is not set
CONFIG_NETLINK_DIAG=m
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=m
# CONFIG_MPLS_ROUTING is not set
CONFIG_NET_NSH=m
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m
CONFIG_CAN_GW=m

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=m
# CONFIG_CAN_VXCAN is not set
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=m
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set
# CONFIG_CAN_IFI_CANFD is not set
# CONFIG_CAN_M_CAN is not set
# CONFIG_CAN_PEAK_PCIEFD is not set
# CONFIG_CAN_SJA1000 is not set
# CONFIG_CAN_SOFTING is not set

#
# CAN SPI interfaces
#
# CONFIG_CAN_HI311X is not set
# CONFIG_CAN_MCP251X is not set

#
# CAN USB interfaces
#
# CONFIG_CAN_EMS_USB is not set
# CONFIG_CAN_ESD_USB2 is not set
# CONFIG_CAN_GS_USB is not set
# CONFIG_CAN_KVASER_USB is not set
# CONFIG_CAN_PEAK_USB is not set
# CONFIG_CAN_8DEV_USB is not set
# CONFIG_CAN_MCBA_USB is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_XEN is not set
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=200
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
# CONFIG_MTD_BLOCK_RO is not set
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_MCHP23K256 is not set
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=m
CONFIG_BLK_DEV_FD=m
CONFIG_CDROM=m
# CONFIG_PARIDE is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=m
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=0
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_XEN_BLKDEV_FRONTEND=m
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_VIRTIO_BLK_SCSI is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=m

#
# NVME Support
#
CONFIG_NVME_CORE=m
CONFIG_BLK_DEV_NVME=m
# CONFIG_NVME_MULTIPATH is not set
# CONFIG_NVME_FC is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_SGI_XP=m
CONFIG_HP_ILO=m
CONFIG_SGI_GRU=m
# CONFIG_SGI_GRU_DEBUG is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
CONFIG_ISL29020=m
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
CONFIG_VMWARE_BALLOON=m
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_EEPROM_IDT_89HPESX is not set
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=m

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
# CONFIG_CXL_LIB is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
CONFIG_SCSI_CXGB4_ISCSI=m
CONFIG_SCSI_BNX2_ISCSI=m
CONFIG_SCSI_BNX2X_FCOE=m
CONFIG_BE2ISCSI=m
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_HPSA=m
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_3W_SAS=m
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=m
# CONFIG_SCSI_AIC7XXX is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_SCSI_MVUMI=m
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=m
# CONFIG_SCSI_SMARTPQI is not set
CONFIG_SCSI_UFSHCD=m
CONFIG_SCSI_UFSHCD_PCI=m
# CONFIG_SCSI_UFS_DWC_TC_PCI is not set
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
CONFIG_SCSI_HPTIOP=m
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_VMWARE_PVSCSI=m
# CONFIG_XEN_SCSI_FRONTEND is not set
CONFIG_HYPERV_STORAGE=m
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
# CONFIG_SCSI_SNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
CONFIG_SCSI_STEX=m
# CONFIG_SCSI_SYM53C8XX_2 is not set
CONFIG_SCSI_IPR=m
CONFIG_SCSI_IPR_TRACE=y
CONFIG_SCSI_IPR_DUMP=y
# CONFIG_SCSI_QLOGIC_1280 is not set
CONFIG_SCSI_QLA_FC=m
# CONFIG_TCM_QLA2XXX is not set
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=m
CONFIG_SCSI_PMCRAID=m
CONFIG_SCSI_PM8001=m
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=m
CONFIG_SCSI_CHELSIO_FCOE=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=m
CONFIG_SCSI_OSD_ULD=m
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_AHCI_PLATFORM=m
# CONFIG_SATA_INIC162X is not set
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
# CONFIG_SATA_DWC is not set
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=m
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
CONFIG_PATA_ATP867X=m
CONFIG_PATA_CMD64X=m
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=m
CONFIG_PATA_HPT37X=m
CONFIG_PATA_HPT3X2N=m
CONFIG_PATA_HPT3X3=m
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=m
CONFIG_PATA_IT821X=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=m
CONFIG_PATA_NINJA32=m
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=m
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
CONFIG_PATA_SCH=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_TOSHIBA=m
# CONFIG_PATA_TRIFLEX is not set
CONFIG_PATA_VIA=m
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=m
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
# CONFIG_MD_CLUSTER is not set
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_MQ_DEFAULT is not set
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=m
# CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING is not set
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_THIN_PROVISIONING=m
CONFIG_DM_CACHE=m
CONFIG_DM_CACHE_SMQ=m
# CONFIG_DM_ERA is not set
CONFIG_DM_MIRROR=m
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_RAID=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
CONFIG_DM_VERITY=m
# CONFIG_DM_VERITY_FEC is not set
CONFIG_DM_SWITCH=m
# CONFIG_DM_LOG_WRITES is not set
# CONFIG_DM_INTEGRITY is not set
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
# CONFIG_TCM_USER2 is not set
CONFIG_LOOPBACK_TARGET=m
CONFIG_TCM_FC=m
CONFIG_ISCSI_TARGET=m
# CONFIG_ISCSI_TARGET_CXGB4 is not set
# CONFIG_SBP_TARGET is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
# CONFIG_FUSION_FC is not set
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NET=m
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=m
CONFIG_DUMMY=m
# CONFIG_EQUALIZER is not set
CONFIG_NET_FC=y
CONFIG_IFB=m
CONFIG_NET_TEAM=m
CONFIG_NET_TEAM_MODE_BROADCAST=m
CONFIG_NET_TEAM_MODE_ROUNDROBIN=m
CONFIG_NET_TEAM_MODE_RANDOM=m
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=m
CONFIG_NET_TEAM_MODE_LOADBALANCE=m
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
CONFIG_VXLAN=m
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=m
CONFIG_TAP=m
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=m
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=m
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
# CONFIG_ENA_ETHERNET is not set
# CONFIG_NET_VENDOR_AMD is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=m
CONFIG_ATL1=m
CONFIG_ATL1E=m
CONFIG_ATL1C=m
CONFIG_ALX=m
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_TIGON3=y
CONFIG_TIGON3_HWMON=y
# CONFIG_BNX2X is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=m
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3=m
CONFIG_CHELSIO_T4=m
# CONFIG_CHELSIO_T4_DCB is not set
CONFIG_CHELSIO_T4VF=m
CONFIG_CHELSIO_LIB=m
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=m
# CONFIG_CX_ECAT is not set
CONFIG_DNET=m
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=m
CONFIG_BE2NET_HWMON=y
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_HUAWEI=y
# CONFIG_HINIC is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGBVF=m
CONFIG_IXGB=m
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=m
CONFIG_I40E=m
# CONFIG_I40E_DCB is not set
# CONFIG_I40EVF is not set
# CONFIG_FM10K is not set
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_JME=m
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=m
CONFIG_SKGE=m
CONFIG_SKGE_DEBUG=y
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=m
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=m
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
CONFIG_MLX4_CORE_GEN2=y
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=m
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_ETHOC=m
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=m
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=m
CONFIG_QLCNIC=m
CONFIG_QLCNIC_SRIOV=y
CONFIG_QLCNIC_DCB=y
CONFIG_QLCNIC_HWMON=y
CONFIG_QLGE=m
CONFIG_NETXEN_NIC=m
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RENESAS=y
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_SFC_MCDI_LOGGING=y
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_EPIC100=m
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=m
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
# CONFIG_MDIO_THUNDER is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=m
# CONFIG_AQUANTIA_PHY is not set
CONFIG_AT803X_PHY=m
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=m
CONFIG_BCM_NET_PHYLIB=m
CONFIG_BROADCOM_PHY=m
CONFIG_CICADA_PHY=m
# CONFIG_CORTINA_PHY is not set
CONFIG_DAVICOM_PHY=m
# CONFIG_DP83822_PHY is not set
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=m
# CONFIG_INTEL_XWAY_PHY is not set
CONFIG_LSI_ET1011C_PHY=m
CONFIG_LXT_PHY=m
CONFIG_MARVELL_PHY=m
# CONFIG_MARVELL_10G_PHY is not set
CONFIG_MICREL_PHY=m
# CONFIG_MICROCHIP_PHY is not set
# CONFIG_MICROSEMI_PHY is not set
CONFIG_NATIONAL_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_REALTEK_PHY=m
# CONFIG_RENESAS_PHY is not set
# CONFIG_ROCKCHIP_PHY is not set
CONFIG_SMSC_PHY=m
CONFIG_STE10XP=m
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=m
# CONFIG_XILINX_GMII2RGMII is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=m
CONFIG_PPPOE=m
CONFIG_PPTP=m
CONFIG_PPPOL2TP=m
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_SLIP=m
CONFIG_SLHC=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_RTL8152=m
# CONFIG_USB_LAN78XX is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=m
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=m
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
# CONFIG_USB_NET_SR9800 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET_ENABLE=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
CONFIG_USB_NET_QMI_WWAN=m
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=m
# CONFIG_USB_NET_CH9200 is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
# CONFIG_ADM8211 is not set
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
# CONFIG_ATH9K is not set
# CONFIG_ATH9K_HTC is not set
# CONFIG_CARL9170 is not set
# CONFIG_ATH6KL is not set
# CONFIG_AR5523 is not set
# CONFIG_WIL6210 is not set
# CONFIG_ATH10K is not set
# CONFIG_WCN36XX is not set
CONFIG_WLAN_VENDOR_ATMEL=y
# CONFIG_ATMEL is not set
# CONFIG_AT76C50X_USB is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
# CONFIG_B43 is not set
# CONFIG_B43LEGACY is not set
# CONFIG_BRCMSMAC is not set
# CONFIG_BRCMFMAC is not set
CONFIG_WLAN_VENDOR_CISCO=y
# CONFIG_AIRO is not set
CONFIG_WLAN_VENDOR_INTEL=y
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
# CONFIG_IWLWIFI is not set
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_HERMES is not set
# CONFIG_P54_COMMON is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
# CONFIG_LIBERTAS is not set
# CONFIG_LIBERTAS_THINFIRM is not set
# CONFIG_MWIFIEX is not set
# CONFIG_MWL8K is not set
CONFIG_WLAN_VENDOR_MEDIATEK=y
# CONFIG_MT7601U is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
CONFIG_WLAN_VENDOR_REALTEK=y
# CONFIG_RTL8180 is not set
# CONFIG_RTL8187 is not set
CONFIG_RTL_CARDS=m
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8723BE is not set
# CONFIG_RTL8188EE is not set
# CONFIG_RTL8192EE is not set
# CONFIG_RTL8821AE is not set
# CONFIG_RTL8192CU is not set
# CONFIG_RTL8XXXU is not set
CONFIG_WLAN_VENDOR_RSI=y
# CONFIG_RSI_91X is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
CONFIG_WLAN_VENDOR_TI=y
# CONFIG_WL1251 is not set
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
# CONFIG_WLCORE is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
# CONFIG_USB_ZD1201 is not set
# CONFIG_ZD1211RW is not set
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_QTNFMAC_PEARL_PCIE is not set
CONFIG_MAC80211_HWSIM=m
# CONFIG_USB_NET_RNDIS_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=m
CONFIG_HDLC_RAW=m
# CONFIG_HDLC_RAW_ETH is not set
CONFIG_HDLC_CISCO=m
CONFIG_HDLC_FR=m
CONFIG_HDLC_PPP=m

#
# X.25/LAPB support is disabled
#
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
# CONFIG_DSCC4 is not set
CONFIG_DLCI=m
CONFIG_DLCI_MAX=8
# CONFIG_SBNI is not set
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKELB=m
# CONFIG_IEEE802154_AT86RF230 is not set
# CONFIG_IEEE802154_MRF24J40 is not set
# CONFIG_IEEE802154_CC2520 is not set
# CONFIG_IEEE802154_ATUSB is not set
# CONFIG_IEEE802154_ADF7242 is not set
# CONFIG_IEEE802154_CA8210 is not set
CONFIG_XEN_NETDEV_FRONTEND=m
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=m
# CONFIG_FUJITSU_ES is not set
CONFIG_HYPERV_NET=m
CONFIG_ISDN=y
CONFIG_ISDN_I4L=m
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
CONFIG_ISDN_MPP=y
CONFIG_IPPP_FILTER=y
# CONFIG_ISDN_PPP_BSDCOMP is not set
CONFIG_ISDN_AUDIO=y
CONFIG_ISDN_TTY_FAX=y

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=m

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
# CONFIG_ISDN_DRV_HISAX is not set
CONFIG_ISDN_CAPI=m
# CONFIG_CAPI_TRACE is not set
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPIDRV=m
# CONFIG_ISDN_CAPI_CAPIDRV_VERBOSE is not set

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=m
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=m
CONFIG_ISDN_DRV_AVMB1_C4=m
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=m
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_I4L is not set
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=m
CONFIG_GIGASET_M105=m
CONFIG_GIGASET_M101=m
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
CONFIG_MISDN_AVMFRITZ=m
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
CONFIG_MISDN_NETJET=m
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m
CONFIG_ISDN_HDLC=m
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_APPLETOUCH=m
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_CYAPA=m
# CONFIG_MOUSE_ELAN_I2C is not set
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
CONFIG_MOUSE_SYNAPTICS_USB=m
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=m
# CONFIG_TABLET_USB_PEGASUS is not set
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_ADS7846 is not set
# CONFIG_TOUCHSCREEN_AD7877 is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_EXC3000 is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
# CONFIG_TOUCHSCREEN_HIDEEP is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_S6SY761 is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=m
CONFIG_TOUCHSCREEN_WACOM_I2C=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2004 is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
# CONFIG_TOUCHSCREEN_RM_TS is not set
# CONFIG_TOUCHSCREEN_SILEAD is not set
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_STMFTS is not set
# CONFIG_TOUCHSCREEN_SUR40 is not set
# CONFIG_TOUCHSCREEN_SURFACE3_SPI is not set
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_TOUCHSCREEN_ZET6223 is not set
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=m
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
# CONFIG_INPUT_GPIO_DECODER is not set
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
CONFIG_INPUT_CM109=m
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_PWM_BEEPER is not set
# CONFIG_INPUT_PWM_VIBRA is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=m
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=m
CONFIG_HYPERV_KEYBOARD=m
# CONFIG_SERIO_GPIO_PS2 is not set
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=m
CONFIG_MOXA_SMARTIO=m
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_NOZOMI=m
# CONFIG_ISI is not set
CONFIG_N_HDLC=m
CONFIG_N_GSM=m
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
CONFIG_IPMI_DMI_DECODE=y
CONFIG_IPMI_PROC_INTERFACE=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=m
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=8192
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HPET_MMAP_DEFAULT is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_UV_MMTIMER=m
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
# CONFIG_TCG_XEN is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_VTPM_PROXY is not set
# CONFIG_TCG_TIS_ST33ZP24_I2C is not set
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_REG is not set
# CONFIG_I2C_MUX_MLXCPLD is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=m
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
CONFIG_I2C_DESIGNWARE_PCI=m
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
# CONFIG_SPI_AXI_SPI_ENGINE is not set
# CONFIG_SPI_BITBANG is not set
# CONFIG_SPI_BUTTERFLY is not set
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=m
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_PXA2XX=m
CONFIG_SPI_PXA2XX_PCI=m
# CONFIG_SPI_ROCKCHIP is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
# CONFIG_SPI_LOOPBACK_TEST is not set
# CONFIG_SPI_TLE62X0 is not set
# CONFIG_SPI_SLAVE is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=m
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_MCP23S08 is not set
# CONFIG_PINCTRL_SX150X is not set
CONFIG_PINCTRL_BAYTRAIL=y
# CONFIG_PINCTRL_CHERRYVIEW is not set
# CONFIG_PINCTRL_BROXTON is not set
# CONFIG_PINCTRL_CANNONLAKE is not set
# CONFIG_PINCTRL_CEDARFORK is not set
# CONFIG_PINCTRL_DENVERTON is not set
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_LEWISBURG is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=m
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
# CONFIG_GPIO_MAX3191X is not set
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set
# CONFIG_GPIO_XRA1403 is not set

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
# CONFIG_MANAGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_LTC3651 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_FTSTEUTATES is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=m
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX31722 is not set
# CONFIG_SENSORS_MAX6621 is not set
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=m
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_TC654 is not set
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=m
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
CONFIG_SENSORS_PMBUS=m
CONFIG_SENSORS_ADM1275=m
# CONFIG_SENSORS_IBM_CFFPS is not set
# CONFIG_SENSORS_IR35221 is not set
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=m
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=m
# CONFIG_SENSORS_MAX20751 is not set
# CONFIG_SENSORS_MAX31785 is not set
CONFIG_SENSORS_MAX34440=m
CONFIG_SENSORS_MAX8688=m
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_TPS53679 is not set
CONFIG_SENSORS_UCD9000=m
CONFIG_SENSORS_UCD9200=m
CONFIG_SENSORS_ZL6100=m
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=m
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
# CONFIG_SENSORS_STTS751 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=m
CONFIG_X86_PKG_TEMP_THERMAL=m
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=m
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
# CONFIG_WDAT_WDT is not set
# CONFIG_XILINX_WATCHDOG is not set
# CONFIG_ZIIRAVE_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
CONFIG_F71808E_WDT=m
CONFIG_SP5100_TCO=m
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=m
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=m
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
CONFIG_HP_WATCHDOG=m
CONFIG_HPWDT_NMI_DECODING=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
CONFIG_NV_TCO=m
# CONFIG_60XX_WDT is not set
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
# CONFIG_SMSC37B787_WDT is not set
CONFIG_VIA_WDT=m
CONFIG_W83627HF_WDT=m
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_INTEL_MEI_WDT is not set
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
# CONFIG_MEN_A21_WDT is not set
CONFIG_XEN_WDT=m

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_BD9571MWV is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=m
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=m
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=m
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RTSX_USB is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=m
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_TI_LMU is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS68470 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=m
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
CONFIG_RC_CORE=m
CONFIG_RC_MAP=m
CONFIG_RC_DECODERS=y
CONFIG_LIRC=m
CONFIG_IR_LIRC_CODEC=m
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_SANYO_DECODER=m
CONFIG_IR_SHARP_DECODER=m
CONFIG_IR_MCE_KBD_DECODER=m
CONFIG_IR_XMP_DECODER=m
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=m
CONFIG_IR_ENE=m
CONFIG_IR_IMON=m
CONFIG_IR_MCEUSB=m
CONFIG_IR_ITE_CIR=m
CONFIG_IR_FINTEK=m
CONFIG_IR_NUVOTON=m
CONFIG_IR_REDRAT3=m
CONFIG_IR_STREAMZAP=m
CONFIG_IR_WINBOND_CIR=m
# CONFIG_IR_IGORPLUGUSB is not set
CONFIG_IR_IGUANA=m
CONFIG_IR_TTUSBIR=m
# CONFIG_RC_LOOPBACK is not set
# CONFIG_IR_SERIAL is not set
# CONFIG_IR_SIR is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_CEC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF_DVB=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEOBUF2_DMA_SG=m
CONFIG_VIDEOBUF2_DVB=m
CONFIG_DVB_CORE=m
CONFIG_DVB_NET=y
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
CONFIG_USB_GSPCA_CPIA1=m
# CONFIG_USB_GSPCA_DTCS033 is not set
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
CONFIG_USB_GSPCA_JL2005BCD=m
# CONFIG_USB_GSPCA_KINECT is not set
CONFIG_USB_GSPCA_KONICA=m
CONFIG_USB_GSPCA_MARS=m
CONFIG_USB_GSPCA_MR97310A=m
CONFIG_USB_GSPCA_NW80X=m
CONFIG_USB_GSPCA_OV519=m
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
CONFIG_USB_GSPCA_PAC207=m
CONFIG_USB_GSPCA_PAC7302=m
CONFIG_USB_GSPCA_PAC7311=m
CONFIG_USB_GSPCA_SE401=m
CONFIG_USB_GSPCA_SN9C2028=m
CONFIG_USB_GSPCA_SN9C20X=m
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
CONFIG_USB_GSPCA_SPCA1528=m
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
# CONFIG_USB_GSPCA_STK1135 is not set
CONFIG_USB_GSPCA_STV0680=m
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TOPRO=m
# CONFIG_USB_GSPCA_TOUPTEK is not set
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
CONFIG_USB_GSPCA_VICAM=m
CONFIG_USB_GSPCA_XIRLINK_CIT=m
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_USB_PWC=m
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_VIDEO_USBTV is not set

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_USBVISION=m
# CONFIG_VIDEO_STK1160_COMMON is not set
# CONFIG_VIDEO_GO7007 is not set

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_AU0828_V4L2=y
# CONFIG_VIDEO_AU0828_RC is not set
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_CX231XX_DVB=m
CONFIG_VIDEO_TM6000=m
CONFIG_VIDEO_TM6000_ALSA=m
CONFIG_VIDEO_TM6000_DVB=m

#
# Digital TV USB devices
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_DIB3000MC=m
CONFIG_DVB_USB_A800=m
CONFIG_DVB_USB_DIBUSB_MB=m
# CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
CONFIG_DVB_USB_DIBUSB_MC=m
CONFIG_DVB_USB_DIB0700=m
CONFIG_DVB_USB_UMT_010=m
CONFIG_DVB_USB_CXUSB=m
CONFIG_DVB_USB_M920X=m
CONFIG_DVB_USB_DIGITV=m
CONFIG_DVB_USB_VP7045=m
CONFIG_DVB_USB_VP702X=m
CONFIG_DVB_USB_GP8PSK=m
CONFIG_DVB_USB_NOVA_T_USB2=m
CONFIG_DVB_USB_TTUSB2=m
CONFIG_DVB_USB_DTT200U=m
CONFIG_DVB_USB_OPERA1=m
CONFIG_DVB_USB_AF9005=m
CONFIG_DVB_USB_AF9005_REMOTE=m
CONFIG_DVB_USB_PCTV452E=m
CONFIG_DVB_USB_DW2102=m
CONFIG_DVB_USB_CINERGY_T2=m
CONFIG_DVB_USB_DTV5100=m
CONFIG_DVB_USB_FRIIO=m
CONFIG_DVB_USB_AZ6027=m
CONFIG_DVB_USB_TECHNISAT_USB2=m
CONFIG_DVB_USB_V2=m
CONFIG_DVB_USB_AF9015=m
CONFIG_DVB_USB_AF9035=m
CONFIG_DVB_USB_ANYSEE=m
CONFIG_DVB_USB_AU6610=m
CONFIG_DVB_USB_AZ6007=m
CONFIG_DVB_USB_CE6230=m
CONFIG_DVB_USB_EC168=m
CONFIG_DVB_USB_GL861=m
CONFIG_DVB_USB_LME2510=m
CONFIG_DVB_USB_MXL111SF=m
CONFIG_DVB_USB_RTL28XXU=m
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_USB_ZD1301 is not set
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
CONFIG_SMS_USB_DRV=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
# CONFIG_DVB_AS102 is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
# CONFIG_VIDEO_EM28XX_V4L2 is not set
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
CONFIG_VIDEO_EM28XX_RC=m
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_MEYE is not set
# CONFIG_VIDEO_SOLO6X10 is not set
# CONFIG_VIDEO_TW5864 is not set
# CONFIG_VIDEO_TW68 is not set
# CONFIG_VIDEO_TW686X is not set
# CONFIG_VIDEO_ZORAN is not set

#
# Media capture/analog TV support
#
CONFIG_VIDEO_IVTV=m
# CONFIG_VIDEO_IVTV_DEPRECATED_IOCTLS is not set
# CONFIG_VIDEO_IVTV_ALSA is not set
CONFIG_VIDEO_FB_IVTV=m
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_MXB is not set
# CONFIG_VIDEO_DT3155 is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX18=m
CONFIG_VIDEO_CX18_ALSA=m
CONFIG_VIDEO_CX23885=m
CONFIG_MEDIA_ALTERA_CI=m
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_ENABLE_VP3054=y
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_BT848=m
CONFIG_DVB_BT8XX=m
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_SAA7164=m

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=y
CONFIG_DVB_AV7110=m
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=m
CONFIG_DVB_BUDGET=m
CONFIG_DVB_BUDGET_CI=m
CONFIG_DVB_BUDGET_AV=m
CONFIG_DVB_BUDGET_PATCH=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
# CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG is not set
CONFIG_DVB_PLUTO2=m
CONFIG_DVB_DM1105=m
CONFIG_DVB_PT1=m
# CONFIG_DVB_PT3 is not set
CONFIG_MANTIS_CORE=m
CONFIG_DVB_MANTIS=m
CONFIG_DVB_HOPPER=m
CONFIG_DVB_NGENE=m
CONFIG_DVB_DDBRIDGE=m
# CONFIG_DVB_DDBRIDGE_MSIENABLE is not set
# CONFIG_DVB_SMIPCIE is not set
# CONFIG_DVB_NETUP_UNIDVB is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=m
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=m
# CONFIG_RADIO_SI470X is not set
# CONFIG_RADIO_SI4713 is not set
# CONFIG_USB_MR800 is not set
# CONFIG_USB_DSBR is not set
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_RADIO_SHARK is not set
# CONFIG_RADIO_SHARK2 is not set
# CONFIG_USB_KEENE is not set
# CONFIG_USB_RAREMONO is not set
# CONFIG_USB_MA901 is not set
# CONFIG_RADIO_TEA5764 is not set
# CONFIG_RADIO_SAA7706H is not set
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_CYPRESS_FIRMWARE=m
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_SMS_SIANO_MDTV=m
CONFIG_SMS_SIANO_RC=y
# CONFIG_SMS_SIANO_DEBUGFS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS3308=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_M52790=m

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=m
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2063=m
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
CONFIG_MEDIA_TUNER_FC0011=m
CONFIG_MEDIA_TUNER_FC0012=m
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=m
CONFIG_MEDIA_TUNER_M88RS6000T=m
CONFIG_MEDIA_TUNER_TUA9001=m
CONFIG_MEDIA_TUNER_SI2157=m
CONFIG_MEDIA_TUNER_IT913X=m
CONFIG_MEDIA_TUNER_R820T=m
CONFIG_MEDIA_TUNER_QM1D1C0042=m

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV0910=m
CONFIG_DVB_STV6110x=m
CONFIG_DVB_STV6111=m
CONFIG_DVB_MXL5XX=m
CONFIG_DVB_M88DS3103=m

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=m
CONFIG_DVB_TDA18271C2DD=m
CONFIG_DVB_SI2165=m
CONFIG_DVB_MN88472=m
CONFIG_DVB_MN88473=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_CX24117=m
CONFIG_DVB_CX24120=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_TS2020=m
CONFIG_DVB_DS3000=m
CONFIG_DVB_MB86A16=m
CONFIG_DVB_TDA10071=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_DRXD=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_AF9013=m
CONFIG_DVB_EC100=m
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=m
CONFIG_DVB_CXD2841ER=m
CONFIG_DVB_RTL2830=m
CONFIG_DVB_RTL2832=m
CONFIG_DVB_SI2168=m
# CONFIG_DVB_AS102_FE is not set
CONFIG_DVB_GP8PSK_FE=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
CONFIG_DVB_TDA10023=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_LGDT3306A=m
CONFIG_DVB_LG2160=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_AU8522_DTV=m
CONFIG_DVB_AU8522_V4L=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=m
CONFIG_DVB_LNBH25=m
CONFIG_DVB_LNBP21=m
CONFIG_DVB_LNBP22=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m
CONFIG_DVB_A8293=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m
CONFIG_DVB_TDA665x=m
CONFIG_DVB_IX2505V=m
CONFIG_DVB_M88RS2000=m
CONFIG_DVB_AF9033=m

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=64
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
# CONFIG_DRM_DEBUG_MM_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
# CONFIG_CHASH is not set
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_I915=m
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
CONFIG_DRM_I915_CAPTURE_ERROR=y
CONFIG_DRM_I915_COMPRESS_ERROR=y
CONFIG_DRM_I915_USERPTR=y
# CONFIG_DRM_I915_GVT is not set

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
# CONFIG_DRM_I915_SELFTEST is not set
# CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS is not set
# CONFIG_DRM_I915_DEBUG_VBLANK_EVADE is not set
CONFIG_DRM_VGEM=m
CONFIG_DRM_VMWGFX=m
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=m
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=m
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
# CONFIG_DRM_BOCHS is not set
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_LEGACY is not set
# CONFIG_DRM_LIB_RANDOM is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
# CONFIG_FB_DDC is not set
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
# CONFIG_FB_MODE_HELPERS is not set
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_SM501 is not set
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_XEN_FBDEV_FRONTEND is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_HYPERV=m
# CONFIG_FB_SIMPLE is not set
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
# CONFIG_LCD_ILI922X is not set
# CONFIG_LCD_ILI9320 is not set
# CONFIG_LCD_TDO24M is not set
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=m
# CONFIG_LCD_S6E63M0 is not set
# CONFIG_LCD_LD9040 is not set
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
# CONFIG_LCD_HX8357 is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_APPLE=m
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_BACKLIGHT_ARCXCNN is not set
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
# CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_SEQ_DEVICE=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_HRTIMER=m
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_SEQUENCER_OSS=m
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_SEQ_MIDI_EVENT=m
CONFIG_SND_SEQ_MIDI=m
CONFIG_SND_SEQ_MIDI_EMUL=m
CONFIG_SND_SEQ_VIRMIDI=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_OPL3_LIB_SEQ=m
# CONFIG_SND_OPL4_LIB_SEQ is not set
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=5
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_ES1968_RADIO=y
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=m
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=m
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
# CONFIG_SND_HDA_RECONFIG is not set
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=0
# CONFIG_SND_HDA_PATCH_LOADER is not set
CONFIG_SND_HDA_CODEC_REALTEK=m
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
CONFIG_SND_HDA_CODEC_VIA=m
CONFIG_SND_HDA_CODEC_HDMI=m
CONFIG_SND_HDA_CODEC_CIRRUS=m
CONFIG_SND_HDA_CODEC_CONEXANT=m
CONFIG_SND_HDA_CODEC_CA0110=m
CONFIG_SND_HDA_CODEC_CA0132=m
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=m
CONFIG_SND_HDA_CODEC_SI3054=m
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=m
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_PREALLOC_SIZE=512
CONFIG_SND_SPI=y
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_UA101=m
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
CONFIG_SND_USB_6FIRE=m
# CONFIG_SND_USB_HIFACE is not set
# CONFIG_SND_BCD2000 is not set
# CONFIG_SND_USB_POD is not set
# CONFIG_SND_USB_PODHD is not set
# CONFIG_SND_USB_TONEPORT is not set
# CONFIG_SND_USB_VARIAX is not set
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
# CONFIG_SND_DICE is not set
# CONFIG_SND_OXFW is not set
CONFIG_SND_ISIGHT=m
# CONFIG_SND_FIREWORKS is not set
# CONFIG_SND_BEBOB is not set
# CONFIG_SND_FIREWIRE_DIGI00X is not set
# CONFIG_SND_FIREWIRE_TASCAM is not set
# CONFIG_SND_FIREWIRE_MOTU is not set
# CONFIG_SND_FIREFACE is not set
# CONFIG_SND_SOC is not set
CONFIG_SND_X86=y
# CONFIG_HDMI_LPE_AUDIO is not set
CONFIG_SND_SYNTH_EMUX=m
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=m
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACCUTOUCH is not set
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=m
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_PRODIKEYS=m
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=m
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELECOM=m
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_GT683R is not set
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=m
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
# CONFIG_HID_ITE is not set
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=m
CONFIG_HID_LED=m
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_HID_LOGITECH_HIDPP=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=m
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=m
# CONFIG_HID_RETRODE is not set
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=m
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=m
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_UDRAW_PS3 is not set
CONFIG_HID_WACOM=m
CONFIG_HID_WIIMOTE=m
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=m
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=m

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=m
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=m
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
CONFIG_USB_DWC3_GADGET=y
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_F8153X is not set
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=m
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
CONFIG_USB_SERIAL_QCAUX=m
CONFIG_USB_SERIAL_QUALCOMM=m
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
CONFIG_USB_SERIAL_XSENS_MT=m
# CONFIG_USB_SERIAL_WISHBONE is not set
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_UPD78F0730 is not set
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=m
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=m
# CONFIG_USB_HSIC_USB4604 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
# CONFIG_USB_GR_UDC is not set
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_MV_U3D is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_BDC_UDC is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_MASS_STORAGE=m
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
CONFIG_USB_MASS_STORAGE=m
# CONFIG_USB_GADGET_TARGET is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_TYPEC_TCPM is not set
# CONFIG_TYPEC_UCSI is not set
# CONFIG_TYPEC_TPS6598X is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_SDIO_UART=m
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_ACPI=m
CONFIG_MMC_SDHCI_PLTFM=m
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_VUB300=m
CONFIG_MMC_USHC=m
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_REALTEK_PCI=m
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
# CONFIG_MMC_SDHCI_XENON is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
CONFIG_MEMSTICK_R592=m
CONFIG_MEMSTICK_REALTEK_PCI=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_APU is not set
CONFIG_LEDS_LM3530=m
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=m
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_DAC124S085 is not set
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=m
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m
# CONFIG_LEDS_MLXCPLD is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=m
# CONFIG_LEDS_TRIGGER_DISK is not set
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=m
# CONFIG_EDAC_GHES is not set
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I3200=m
# CONFIG_EDAC_IE31200 is not set
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=m
CONFIG_EDAC_I7CORE=m
CONFIG_EDAC_I5000=m
CONFIG_EDAC_I5100=m
CONFIG_EDAC_I7300=m
CONFIG_EDAC_SBRIDGE=m
# CONFIG_EDAC_SKX is not set
# CONFIG_EDAC_PND2 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set
CONFIG_RTC_NVMEM=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
CONFIG_RTC_DRV_DS1307=m
CONFIG_RTC_DRV_DS1307_HWMON=y
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=m
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=m
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
CONFIG_RTC_DRV_ISL12022=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8523=m
# CONFIG_RTC_DRV_PCF85063 is not set
# CONFIG_RTC_DRV_PCF85363 is not set
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=m
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=m
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=m
# CONFIG_RTC_DRV_RX8010 is not set
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1302 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6916 is not set
# CONFIG_RTC_DRV_R9701 is not set
# CONFIG_RTC_DRV_RX4581 is not set
# CONFIG_RTC_DRV_RX6110 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
# CONFIG_RTC_DRV_PCF2123 is not set
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=m
CONFIG_RTC_DRV_DS3232_HWMON=y
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_RV3029C2=m
CONFIG_RTC_DRV_RV3029_HWMON=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_DS2404=m
CONFIG_RTC_DRV_STK17TA8=m
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=m
CONFIG_RTC_DRV_M48T59=m
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=m

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_FTRTC010 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
# CONFIG_ALTERA_MSGDMA is not set
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_QCOM_HIDMA_MGMT is not set
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
CONFIG_AUXDISPLAY=y
# CONFIG_HD44780 is not set
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=m
CONFIG_CFAG12864B_RATE=20
# CONFIG_IMG_ASCII_LCD is not set
# CONFIG_PANEL is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=m
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_UIO_HV_GENERIC is not set
CONFIG_VFIO_IOMMU_TYPE1=m
CONFIG_VFIO_VIRQFD=m
CONFIG_VFIO=m
# CONFIG_VFIO_NOIOMMU is not set
CONFIG_VFIO_PCI=m
# CONFIG_VFIO_PCI_VGA is not set
CONFIG_VFIO_PCI_MMAP=y
CONFIG_VFIO_PCI_INTX=y
CONFIG_VFIO_PCI_IGD=y
# CONFIG_VFIO_MDEV is not set
CONFIG_IRQ_BYPASS_MANAGER=m
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=m
CONFIG_HYPERV_TSCPAGE=y
CONFIG_HYPERV_UTILS=m
CONFIG_HYPERV_BALLOON=m

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SELFBALLOONING is not set
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=m
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
# CONFIG_XEN_GNTDEV is not set
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=m
CONFIG_XEN_PCIDEV_BACKEND=m
# CONFIG_XEN_PVCALLS_FRONTEND is not set
# CONFIG_XEN_PVCALLS_BACKEND is not set
# CONFIG_XEN_SCSI_BACKEND is not set
CONFIG_XEN_PRIVCMD=m
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_SYMS=y
CONFIG_XEN_HAVE_VPMU=y
CONFIG_STAGING=y
# CONFIG_IRDA is not set
# CONFIG_PRISM2_USB is not set
# CONFIG_COMEDI is not set
# CONFIG_RTL8192U is not set
CONFIG_RTLLIB=m
CONFIG_RTLLIB_CRYPTO_CCMP=m
CONFIG_RTLLIB_CRYPTO_TKIP=m
CONFIG_RTLLIB_CRYPTO_WEP=m
CONFIG_RTL8192E=m
# CONFIG_RTL8723BS is not set
CONFIG_R8712U=m
# CONFIG_R8188EU is not set
# CONFIG_R8822BE is not set
# CONFIG_RTS5208 is not set
# CONFIG_VT6655 is not set
# CONFIG_VT6656 is not set
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_LTE_GDM724X is not set
CONFIG_FIREWIRE_SERIAL=m
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
# CONFIG_LNET is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
# CONFIG_CRYPTO_SKEIN is not set
# CONFIG_UNISYSSPAR is not set
# CONFIG_FB_TFT is not set
# CONFIG_WILC1000_SDIO is not set
# CONFIG_WILC1000_SPI is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_DRM_VBOXVIDEO is not set
# CONFIG_PI433 is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
CONFIG_ACERHDF=m
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=m
# CONFIG_DELL_SMBIOS_WMI is not set
# CONFIG_DELL_SMBIOS_SMM is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
CONFIG_DELL_WMI_AIO=m
# CONFIG_DELL_WMI_LED is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
CONFIG_FUJITSU_LAPTOP=m
CONFIG_FUJITSU_TABLET=m
CONFIG_AMILO_RFKILL=m
CONFIG_HP_ACCEL=m
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=m
CONFIG_MSI_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=m
# CONFIG_SURFACE3_WMI is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=m
CONFIG_ASUS_WMI=m
CONFIG_ASUS_NB_WMI=m
CONFIG_EEEPC_WMI=m
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=m
CONFIG_WMI_BMOF=m
# CONFIG_INTEL_WMI_THUNDERBOLT is not set
CONFIG_MSI_WMI=m
# CONFIG_PEAQ_WMI is not set
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_TOSHIBA_BT_RFKILL=m
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_TOSHIBA_WMI is not set
CONFIG_ACPI_CMPC=m
# CONFIG_INTEL_INT0002_VGPIO is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
CONFIG_INTEL_IPS=m
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_INTEL_OAKTRAIL=m
CONFIG_SAMSUNG_Q10=m
CONFIG_APPLE_GMUX=m
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
CONFIG_PVPANIC=y
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_INTEL_PUNIT_IPC is not set
# CONFIG_MLX_PLATFORM is not set
# CONFIG_MLX_CPLD_PLATFORM is not set
# CONFIG_INTEL_TURBO_MAX_3 is not set
CONFIG_PMC_ATOM=y
# CONFIG_CHROME_PLATFORMS is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_NXP is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=m
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set
# CONFIG_RPMSG_VIRTIO is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX3355 is not set
# CONFIG_EXTCON_RT8973A is not set
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=m
# CONFIG_NTB_AMD is not set
# CONFIG_NTB_IDT is not set
# CONFIG_NTB_INTEL is not set
# CONFIG_NTB_SWITCHTEC is not set
# CONFIG_NTB_PINGPONG is not set
# CONFIG_NTB_TOOL is not set
# CONFIG_NTB_PERF is not set
# CONFIG_NTB_TRANSPORT is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_ARM_GIC_V3_ITS is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=m
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_RAS_CEC is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=m
CONFIG_BLK_DEV_PMEM=m
CONFIG_ND_BLK=m
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=m
CONFIG_BTT=y
CONFIG_ND_PFN=m
CONFIG_NVDIMM_PFN=y
CONFIG_NVDIMM_DAX=y
CONFIG_DAX=y
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_PMEM=m
CONFIG_NVMEM=y
# CONFIG_STM is not set
# CONFIG_INTEL_TH is not set
# CONFIG_FPGA is not set

#
# FSI support
#
# CONFIG_FSI is not set
CONFIG_PM_OPP=y

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
CONFIG_EFI_VARS_PSTORE=y
CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE=y
CONFIG_EFI_RUNTIME_MAP=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
# CONFIG_EFI_BOOTLOADER_CONTROL is not set
# CONFIG_EFI_CAPSULE_LOADER is not set
# CONFIG_EFI_TEST is not set
# CONFIG_APPLE_PROPERTIES is not set
# CONFIG_RESET_ATTACK_MITIGATION is not set
CONFIG_UEFI_CPER=y
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_ONLINE_SCRUB is not set
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
# CONFIG_BTRFS_FS_REF_VERIFY is not set
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=m
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
# CONFIG_F2FS_FS_SECURITY is not set
# CONFIG_F2FS_CHECK_FS is not set
# CONFIG_F2FS_FS_ENCRYPTION is not set
# CONFIG_F2FS_IO_TRACE is not set
# CONFIG_F2FS_FAULT_INJECTION is not set
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_OVERLAY_FS=m
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set
# CONFIG_OVERLAY_FS_INDEX is not set

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_EFIVAR_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
CONFIG_CRAMFS=m
CONFIG_CRAMFS_BLOCKDEV=y
# CONFIG_CRAMFS_MTD is not set
CONFIG_SQUASHFS=m
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_ZSTD is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_ZLIB_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=m
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_EXOFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_FLEXFILE_LAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_NFS_V4_SECURITY_LABEL=y
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_BLOCKLAYOUT is not set
# CONFIG_NFSD_SCSILAYOUT is not set
# CONFIG_NFSD_FLEXFILELAYOUT is not set
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_SUNRPC_DEBUG=y
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
CONFIG_CIFS_STATS=y
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_SMB311 is not set
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=m
CONFIG_NLS_MAC_GAELIC=m
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=m
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_TORTURE_TEST=m
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=m
CONFIG_PM_NOTIFIER_ERROR_INJECT=m
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_PREEMPTIRQ_EVENTS is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENTS=y
CONFIG_UPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=m
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_EVAL_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set

#
# Runtime Testing
#
CONFIG_LKDTM=m
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_ASYNC_RAID6_TEST=m
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=m
CONFIG_TEST_PRINTF=m
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
CONFIG_TEST_LKM=m
CONFIG_TEST_USER_COPY=m
CONFIG_TEST_BPF=m
# CONFIG_TEST_FIND_BIT is not set
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_SYSCTL=m
CONFIG_TEST_UDELAY=m
CONFIG_TEST_STATIC_KEYS=m
CONFIG_TEST_KMOD=m
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_EFI is not set
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
# CONFIG_X86_PTDUMP_CORE is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_EFI_PGT_DUMP is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_X86_DECODER_SELFTEST=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set
# CONFIG_UNWINDER_GUESS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITY_WRITABLE_HOOKS=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
# CONFIG_SECURITY_PATH is not set
CONFIG_INTEL_TXT=y
CONFIG_LSM_MMAP_MIN_ADDR=65535
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_LOADPIN is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y
CONFIG_INTEGRITY_TRUSTED_KEYRING=y
CONFIG_INTEGRITY_AUDIT=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_LSM_RULES=y
# CONFIG_IMA_TEMPLATE is not set
CONFIG_IMA_NG_TEMPLATE=y
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima-ng"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
# CONFIG_IMA_DEFAULT_HASH_SHA256 is not set
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
# CONFIG_IMA_READ_POLICY is not set
CONFIG_IMA_APPRAISE=y
CONFIG_IMA_APPRAISE_BOOTPARAM=y
CONFIG_IMA_TRUSTED_KEYRING=y
# CONFIG_IMA_BLACKLIST_KEYRING is not set
# CONFIG_IMA_LOAD_X509 is not set
CONFIG_EVM=y
CONFIG_EVM_ATTR_FSUUID=y
# CONFIG_EVM_LOAD_X509 is not set
CONFIG_DEFAULT_SECURITY_SELINUX=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="selinux"
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=m
# CONFIG_CRYPTO_MCRYPTD is not set
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=m
CONFIG_CRYPTO_SIMD=m
CONFIG_CRYPTO_GLUE_HELPER_X86=m
CONFIG_CRYPTO_ENGINE=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_POLY1305 is not set
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256_SSSE3=m
CONFIG_CRYPTO_SHA512_SSSE3=m
# CONFIG_CRYPTO_SHA1_MB is not set
# CONFIG_CRYPTO_SHA256_MB is not set
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=m
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_SM3 is not set
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_BLOWFISH_X86_64=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_X86_64=m
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
# CONFIG_CRYPTO_DEV_FSL_CAAM_CRYPTO_API_DESC is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_NITROX_CNN55XX is not set
# CONFIG_CRYPTO_DEV_CHELSIO is not set
CONFIG_CRYPTO_DEV_VIRTIO=m
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y
# CONFIG_PKCS7_TEST_KEY is not set
# CONFIG_SIGNED_PE_FILE_VERIFICATION is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_KVM_COMPAT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
CONFIG_KVM_AMD=m
CONFIG_KVM_MMU_AUDIT=y
CONFIG_VHOST_NET=m
# CONFIG_VHOST_SCSI is not set
# CONFIG_VHOST_VSOCK is not set
CONFIG_VHOST=m
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC4 is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
CONFIG_XXHASH=m
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=m
CONFIG_ZSTD_DECOMPRESS=m
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_BTREE=y
CONFIG_INTERVAL_TREE=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
# CONFIG_DMA_NOOP_OPS is not set
# CONFIG_DMA_VIRT_OPS is not set
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_SBITMAP=y
# CONFIG_STRING_SELFTEST is not set

--y7hnjbnavwaasi5b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
