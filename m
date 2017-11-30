Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC3FA6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:01:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so4984388pfi.2
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:01:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k190si3094230pgc.12.2017.11.30.06.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 06:01:07 -0800 (PST)
Date: Thu, 30 Nov 2017 22:01:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: dd: page allocation failure: order:0,
 mode:0x1080020(GFP_ATOMIC), nodemask=(null)
Message-ID: <20171130140103.arapa4qphgtmjyqm@wfg-t540p.sh.intel.com>
References: <20171130133840.6yz4774274e5scpi@wfg-t540p.sh.intel.com>
 <20171130135016.dfzj2s7ngz55tfws@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zok5mvkwj5pmyc5z"
Content-Disposition: inline
In-Reply-To: <20171130135016.dfzj2s7ngz55tfws@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, lkp@01.org


--zok5mvkwj5pmyc5z
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

On Thu, Nov 30, 2017 at 02:50:16PM +0100, Michal Hocko wrote:
>On Thu 30-11-17 21:38:40, Wu Fengguang wrote:
>> Hello,
>>
>> It looks like a regression in 4.15.0-rc1 -- the test case simply run a
>> set of parallel dd's and there seems no reason to run into memory problem.
>>
>> It occurs in 1 out of 4 tests.
>
>This is an atomic allocations. So the failure really depends on the
>state of the free memory and that can vary between runs depending on
>timing I guess. So I am not really sure this is a regression. But maybe
>there is something reclaim related going on here.

Yes, it does depend on how the drivers rely on atomic allocations.
I just wonder if any changes make the pressure more tight than before.
It may not even be a MM change -- in theory drivers might also use atomic
allocations more aggressively than before.

>[...]
>> [   71.088242] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC), nodemask=(null)
>> [   71.098654] dd cpuset=/ mems_allowed=0-1
>> [   71.104460] CPU: 0 PID: 6016 Comm: dd Tainted: G           O     4.15.0-rc1 #1
>> [   71.113553] Call Trace:
>> [   71.117886]  <IRQ>
>> [   71.121749]  dump_stack+0x5c/0x7b:
>> 						dump_stack at lib/dump_stack.c:55
>> [   71.126785]  warn_alloc+0xbe/0x150:
>> 						preempt_count at arch/x86/include/asm/preempt.h:23
>> 						 (inlined by) should_suppress_show_mem at mm/page_alloc.c:3244
>> 						 (inlined by) warn_alloc_show_mem at mm/page_alloc.c:3254
>> 						 (inlined by) warn_alloc at mm/page_alloc.c:3293
>> [   71.131939]  __alloc_pages_slowpath+0xda7/0xdf0:
>> 						__alloc_pages_slowpath at mm/page_alloc.c:4151
>> [   71.138110]  ? xhci_urb_enqueue+0x23d/0x580:
>> 						xhci_urb_enqueue at drivers/usb/host/xhci.c:1389
>> [   71.143941]  __alloc_pages_nodemask+0x269/0x280:
>> 						__alloc_pages_nodemask at mm/page_alloc.c:4245
>> [   71.150167]  page_frag_alloc+0x11c/0x150:
>> 						__page_frag_cache_refill at mm/page_alloc.c:4335
>> 						 (inlined by) page_frag_alloc at mm/page_alloc.c:4364
>> [   71.155668]  __netdev_alloc_skb+0xa0/0x110:
>> 						__netdev_alloc_skb at net/core/skbuff.c:415
>> [   71.161386]  rx_submit+0x3b/0x2e0:
>> 						rx_submit at drivers/net/usb/usbnet.c:488
>> [   71.166232]  rx_complete+0x196/0x2d0:
>> 						rx_complete at drivers/net/usb/usbnet.c:659
>> [   71.171354]  __usb_hcd_giveback_urb+0x86/0x100:
>> 						arch_local_irq_restore at arch/x86/include/asm/paravirt.h:777
>> 						 (inlined by) __usb_hcd_giveback_urb at drivers/usb/core/hcd.c:1769
>> [   71.177281]  xhci_giveback_urb_in_irq+0x86/0x100
>> [   71.184107]  xhci_td_cleanup+0xe7/0x170:
>> 						xhci_td_cleanup at drivers/usb/host/xhci-ring.c:1924
>> [   71.189457]  handle_tx_event+0x297/0x1190:
>> 						process_bulk_intr_td at drivers/usb/host/xhci-ring.c:2267
>> 						 (inlined by) handle_tx_event at drivers/usb/host/xhci-ring.c:2598
>> [   71.194905]  ? reweight_entity+0x145/0x180:
>> 						enqueue_runnable_load_avg at kernel/sched/fair.c:2742
>> 						 (inlined by) reweight_entity at kernel/sched/fair.c:2810
>> [   71.200466]  xhci_irq+0x300/0xb80:
>> 						xhci_handle_event at drivers/usb/host/xhci-ring.c:2676
>> 						 (inlined by) xhci_irq at drivers/usb/host/xhci-ring.c:2777
>> [   71.205195]  ? scheduler_tick+0xb2/0xe0:
>> 						rq_last_tick_reset at kernel/sched/sched.h:1643
>> 						 (inlined by) scheduler_tick at kernel/sched/core.c:3036
>> [   71.210407]  ? run_timer_softirq+0x73/0x460:
>> 						__collect_expired_timers at kernel/time/timer.c:1375
>> 						 (inlined by) collect_expired_timers at kernel/time/timer.c:1609
>> 						 (inlined by) __run_timers at kernel/time/timer.c:1656
>> 						 (inlined by) run_timer_softirq at kernel/time/timer.c:1688
>> [   71.215905]  __handle_irq_event_percpu+0x3a/0x1a0:
>> 						__handle_irq_event_percpu at kernel/irq/handle.c:147
>> [   71.221975]  handle_irq_event_percpu+0x20/0x50:
>> 						handle_irq_event_percpu at kernel/irq/handle.c:189
>> [   71.227641]  handle_irq_event+0x3d/0x60:
>> 						handle_irq_event at kernel/irq/handle.c:206
>> [   71.232682]  handle_edge_irq+0x71/0x190:
>> 						handle_edge_irq at kernel/irq/chip.c:796
>> [   71.237715]  handle_irq+0xa5/0x100:
>> 						handle_irq at arch/x86/kernel/irq_64.c:78
>> [   71.242326]  do_IRQ+0x41/0xc0:
>> 						do_IRQ at arch/x86/kernel/irq.c:241
>> [   71.246472]  common_interrupt+0x96/0x96:
>> 						ret_from_intr at arch/x86/entry/entry_64.S:611
>> [   71.251509]  </IRQ>
>
>Ugh, this looks unreadable... Inlining information can be helpful
>sometime, alright but I find the below much more readable.

Heh, agreed.

>> [   78.848629] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC), nodemask=(null)
>> [   78.857841] dd cpuset=/ mems_allowed=0-1
>> [   78.862502] CPU: 0 PID: 6131 Comm: dd Tainted: G           O     4.15.0-rc1 #1
>> [   78.870437] Call Trace:
>> [   78.873610]  <IRQ>
>> [   78.876342]  dump_stack+0x5c/0x7b
>> [   78.880414]  warn_alloc+0xbe/0x150
>> [   78.884550]  __alloc_pages_slowpath+0xda7/0xdf0
>> [   78.889822]  ? xhci_urb_enqueue+0x23d/0x580
>> [   78.894713]  __alloc_pages_nodemask+0x269/0x280
>> [   78.899891]  page_frag_alloc+0x11c/0x150
>> [   78.904471]  __netdev_alloc_skb+0xa0/0x110
>> [   78.909277]  rx_submit+0x3b/0x2e0
>> [   78.913256]  rx_complete+0x196/0x2d0
>> [   78.917560]  __usb_hcd_giveback_urb+0x86/0x100
>> [   78.922681]  xhci_giveback_urb_in_irq+0x86/0x100
>> [   78.928769]  ? ip_rcv+0x261/0x390
>> [   78.932739]  xhci_td_cleanup+0xe7/0x170
>> [   78.937308]  handle_tx_event+0x297/0x1190
>> [   78.941990]  xhci_irq+0x300/0xb80
>> [   78.945968]  ? pciehp_isr+0x46/0x320
>> [   78.950870]  __handle_irq_event_percpu+0x3a/0x1a0
>> [   78.956311]  handle_irq_event_percpu+0x20/0x50
>> [   78.961466]  handle_irq_event+0x3d/0x60
>> [   78.965962]  handle_edge_irq+0x71/0x190
>> [   78.970480]  handle_irq+0xa5/0x100
>> [   78.974565]  do_IRQ+0x41/0xc0
>> [   78.978206]  ? pagevec_move_tail_fn+0x350/0x350
>> [   78.983412]  common_interrupt+0x96/0x96
>
>Unfortunatelly we are missing the most imporatant information, the
>meminfo. We cannot tell much without it. Maybe collecting /proc/vmstat
>during the test will tell us more.

Attached the JSON format per-second vmstat records.
It feels more readable than the raw dumps.

Thanks,
Fengguang

--zok5mvkwj5pmyc5z
Content-Type: application/gzip
Content-Disposition: attachment; filename="proc-vmstat.json.gz"
Content-Transfer-Encoding: base64

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
v92tqwN++Ks5//4qB87A3/7v/wFZHJ7qFKkAAA==

--zok5mvkwj5pmyc5z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
