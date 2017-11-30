Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC7216B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:50:19 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a45so3927577wra.14
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:50:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si4394528edr.56.2017.11.30.05.50.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 05:50:18 -0800 (PST)
Date: Thu, 30 Nov 2017 14:50:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dd: page allocation failure: order:0,
 mode:0x1080020(GFP_ATOMIC), nodemask=(null)
Message-ID: <20171130135016.dfzj2s7ngz55tfws@dhcp22.suse.cz>
References: <20171130133840.6yz4774274e5scpi@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130133840.6yz4774274e5scpi@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, lkp@01.org

On Thu 30-11-17 21:38:40, Wu Fengguang wrote:
> Hello,
> 
> It looks like a regression in 4.15.0-rc1 -- the test case simply run a
> set of parallel dd's and there seems no reason to run into memory problem.
> 
> It occurs in 1 out of 4 tests.

This is an atomic allocations. So the failure really depends on the
state of the free memory and that can vary between runs depending on
timing I guess. So I am not really sure this is a regression. But maybe
there is something reclaim related going on here.
[...]
> [   71.088242] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC), nodemask=(null)
> [   71.098654] dd cpuset=/ mems_allowed=0-1
> [   71.104460] CPU: 0 PID: 6016 Comm: dd Tainted: G           O     4.15.0-rc1 #1
> [   71.113553] Call Trace:
> [   71.117886]  <IRQ>
> [   71.121749]  dump_stack+0x5c/0x7b:
> 						dump_stack at lib/dump_stack.c:55
> [   71.126785]  warn_alloc+0xbe/0x150:
> 						preempt_count at arch/x86/include/asm/preempt.h:23
> 						 (inlined by) should_suppress_show_mem at mm/page_alloc.c:3244
> 						 (inlined by) warn_alloc_show_mem at mm/page_alloc.c:3254
> 						 (inlined by) warn_alloc at mm/page_alloc.c:3293
> [   71.131939]  __alloc_pages_slowpath+0xda7/0xdf0:
> 						__alloc_pages_slowpath at mm/page_alloc.c:4151
> [   71.138110]  ? xhci_urb_enqueue+0x23d/0x580:
> 						xhci_urb_enqueue at drivers/usb/host/xhci.c:1389
> [   71.143941]  __alloc_pages_nodemask+0x269/0x280:
> 						__alloc_pages_nodemask at mm/page_alloc.c:4245
> [   71.150167]  page_frag_alloc+0x11c/0x150:
> 						__page_frag_cache_refill at mm/page_alloc.c:4335
> 						 (inlined by) page_frag_alloc at mm/page_alloc.c:4364
> [   71.155668]  __netdev_alloc_skb+0xa0/0x110:
> 						__netdev_alloc_skb at net/core/skbuff.c:415
> [   71.161386]  rx_submit+0x3b/0x2e0:
> 						rx_submit at drivers/net/usb/usbnet.c:488
> [   71.166232]  rx_complete+0x196/0x2d0:
> 						rx_complete at drivers/net/usb/usbnet.c:659
> [   71.171354]  __usb_hcd_giveback_urb+0x86/0x100:
> 						arch_local_irq_restore at arch/x86/include/asm/paravirt.h:777
> 						 (inlined by) __usb_hcd_giveback_urb at drivers/usb/core/hcd.c:1769
> [   71.177281]  xhci_giveback_urb_in_irq+0x86/0x100
> [   71.184107]  xhci_td_cleanup+0xe7/0x170:
> 						xhci_td_cleanup at drivers/usb/host/xhci-ring.c:1924
> [   71.189457]  handle_tx_event+0x297/0x1190:
> 						process_bulk_intr_td at drivers/usb/host/xhci-ring.c:2267
> 						 (inlined by) handle_tx_event at drivers/usb/host/xhci-ring.c:2598
> [   71.194905]  ? reweight_entity+0x145/0x180:
> 						enqueue_runnable_load_avg at kernel/sched/fair.c:2742
> 						 (inlined by) reweight_entity at kernel/sched/fair.c:2810
> [   71.200466]  xhci_irq+0x300/0xb80:
> 						xhci_handle_event at drivers/usb/host/xhci-ring.c:2676
> 						 (inlined by) xhci_irq at drivers/usb/host/xhci-ring.c:2777
> [   71.205195]  ? scheduler_tick+0xb2/0xe0:
> 						rq_last_tick_reset at kernel/sched/sched.h:1643
> 						 (inlined by) scheduler_tick at kernel/sched/core.c:3036
> [   71.210407]  ? run_timer_softirq+0x73/0x460:
> 						__collect_expired_timers at kernel/time/timer.c:1375
> 						 (inlined by) collect_expired_timers at kernel/time/timer.c:1609
> 						 (inlined by) __run_timers at kernel/time/timer.c:1656
> 						 (inlined by) run_timer_softirq at kernel/time/timer.c:1688
> [   71.215905]  __handle_irq_event_percpu+0x3a/0x1a0:
> 						__handle_irq_event_percpu at kernel/irq/handle.c:147
> [   71.221975]  handle_irq_event_percpu+0x20/0x50:
> 						handle_irq_event_percpu at kernel/irq/handle.c:189
> [   71.227641]  handle_irq_event+0x3d/0x60:
> 						handle_irq_event at kernel/irq/handle.c:206
> [   71.232682]  handle_edge_irq+0x71/0x190:
> 						handle_edge_irq at kernel/irq/chip.c:796
> [   71.237715]  handle_irq+0xa5/0x100:
> 						handle_irq at arch/x86/kernel/irq_64.c:78
> [   71.242326]  do_IRQ+0x41/0xc0:
> 						do_IRQ at arch/x86/kernel/irq.c:241
> [   71.246472]  common_interrupt+0x96/0x96:
> 						ret_from_intr at arch/x86/entry/entry_64.S:611
> [   71.251509]  </IRQ>

Ugh, this looks unreadable... Inlining information can be helpful
sometime, alright but I find the below much more readable.

> [   78.848629] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC), nodemask=(null)
> [   78.857841] dd cpuset=/ mems_allowed=0-1
> [   78.862502] CPU: 0 PID: 6131 Comm: dd Tainted: G           O     4.15.0-rc1 #1
> [   78.870437] Call Trace:
> [   78.873610]  <IRQ>
> [   78.876342]  dump_stack+0x5c/0x7b
> [   78.880414]  warn_alloc+0xbe/0x150
> [   78.884550]  __alloc_pages_slowpath+0xda7/0xdf0
> [   78.889822]  ? xhci_urb_enqueue+0x23d/0x580
> [   78.894713]  __alloc_pages_nodemask+0x269/0x280
> [   78.899891]  page_frag_alloc+0x11c/0x150
> [   78.904471]  __netdev_alloc_skb+0xa0/0x110
> [   78.909277]  rx_submit+0x3b/0x2e0
> [   78.913256]  rx_complete+0x196/0x2d0
> [   78.917560]  __usb_hcd_giveback_urb+0x86/0x100
> [   78.922681]  xhci_giveback_urb_in_irq+0x86/0x100
> [   78.928769]  ? ip_rcv+0x261/0x390
> [   78.932739]  xhci_td_cleanup+0xe7/0x170
> [   78.937308]  handle_tx_event+0x297/0x1190
> [   78.941990]  xhci_irq+0x300/0xb80
> [   78.945968]  ? pciehp_isr+0x46/0x320
> [   78.950870]  __handle_irq_event_percpu+0x3a/0x1a0
> [   78.956311]  handle_irq_event_percpu+0x20/0x50
> [   78.961466]  handle_irq_event+0x3d/0x60
> [   78.965962]  handle_edge_irq+0x71/0x190
> [   78.970480]  handle_irq+0xa5/0x100
> [   78.974565]  do_IRQ+0x41/0xc0
> [   78.978206]  ? pagevec_move_tail_fn+0x350/0x350
> [   78.983412]  common_interrupt+0x96/0x96

Unfortunatelly we are missing the most imporatant information, the
meminfo. We cannot tell much without it. Maybe collecting /proc/vmstat
during the test will tell us more.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
