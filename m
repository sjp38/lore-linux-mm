Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id CF2396B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 08:33:40 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id ba1so149081713obb.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 05:33:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s4si1732247obf.20.2016.02.02.05.33.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 05:33:39 -0800 (PST)
Subject: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation from IRQ context.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201602022233.FFF65148.QVOLOtOMFJHSFF@I-love.SAKURA.ne.jp>
Date: Tue, 2 Feb 2016 22:33:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org, jstancek@redhat.com
Cc: linux-mm@kvack.org

>From 20b3c1c9ef35547395c3774c6208a867cf0046d4 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 2 Feb 2016 16:50:45 +0900
Subject: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation from IRQ context.

Jan Stancek hit a hard lockup problem due to flood of memory allocation
failure messages which lasted for 10 seconds with IRQ disabled. Printing
traces using warn_alloc_failed() is very slow (which can take up to about
1 second for each warn_alloc_failed() call). The caller used GFP_NOWARN
inside a loop. If the caller used __GFP_NOWARN, it would not have lasted
for 10 seconds.

While currently it is likely that only GFP_NOWAIT hits this problem
because GFP_ATOMIC is likely able to satisfy allocation request using
memory reserves, it will be likely that GFP_ATOMIC as well hits this
problem because David Rientjes is planning to allow global access to
memory reserves upon OOM livelock (before selecting next OOM victim)
which will lead to depletion of memory reserves.

This patch emits warning messages that suggest to add __GFP_NOWARN
if memory allocation from hard IRQ context does not have __GFP_NOWARN.

----------
[  359.314701] ------------[ cut here ]------------
[  359.318787] WARNING: CPU: 2 PID: 0 at mm/page_alloc.c:3226 __alloc_pages_nodemask+0x219/0xbc0()
[  359.325195] Please consider adding __GFP_NOWARN to allocations from hard IRQ context.
[  359.330813] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat
nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
iptable_raw iptable_filter ppdev parport_pc parport coretemp vmw_balloon pcspkr vmw_vmci shpchp i2c_piix4 ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi mptspi scsi_transport_spi
mptscsih vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ata_piix serio_raw e1000 mptbase i2c_core libata
[  359.378128] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.5.0-rc2+ #45
[  359.382879] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  359.390591]  0000000000000000 d397b1bf5df34331 ffffffff81248044 ffff88003f643af0
[  359.396156]  ffffffff81067b87 0000000002204020 ffff88003f643b48 0000000000000000
[  359.401747]  00000000022c0220 ffff88003ffdfe20 ffffffff81067c17 ffffffff816ec0a0
[  359.407327] Call Trace:
[  359.409478]  <IRQ>  [<ffffffff81248044>] ? dump_stack+0x40/0x5c
[  359.414003]  [<ffffffff81067b87>] ? warn_slowpath_common+0x77/0xb0
[  359.418745]  [<ffffffff81067c17>] ? warn_slowpath_fmt+0x57/0x80
[  359.423275]  [<ffffffff81114f69>] ? __alloc_pages_nodemask+0x219/0xbc0
[  359.428171]  [<ffffffff814acd90>] ? arp_process+0x80/0x760
[  359.432382]  [<ffffffff8147cfd1>] ? ip_local_deliver+0x51/0xf0
[  359.436808]  [<ffffffff8115e480>] ? kmem_getpages+0x50/0x180
[  359.441119]  [<ffffffff8115fa71>] ? fallback_alloc+0x1c1/0x200
[  359.445552]  [<ffffffff81161093>] ? kmem_cache_alloc+0x163/0x1a0
[  359.450275]  [<ffffffff81071d40>] ? __sigqueue_alloc+0x40/0xc0
[  359.454727]  [<ffffffff81072ee5>] ? __send_signal+0x1b5/0x370
[  359.459082]  [<ffffffff81073b26>] ? do_send_sig_info+0x46/0x90
[  359.463492]  [<ffffffff81073e81>] ? kill_pid_info+0x31/0x50
[  359.467882]  [<ffffffff810c05c3>] ? it_real_fn+0x13/0x20
[  359.472156]  [<ffffffff810bf65d>] ? __hrtimer_run_queues+0x9d/0x110
[  359.476877]  [<ffffffff810bfb94>] ? hrtimer_interrupt+0x94/0x190
[  359.481386]  [<ffffffff810450e5>] ? smp_apic_timer_interrupt+0x35/0x50
[  359.486378]  [<ffffffff81537b5c>] ? apic_timer_interrupt+0x8c/0xa0
[  359.491347]  [<ffffffff8106b3b7>] ? __do_softirq+0x77/0x220
[  359.496170]  [<ffffffff810caa5c>] ? clockevents_program_event+0x6c/0x110
[  359.501229]  [<ffffffff8106b7c7>] ? irq_exit+0xd7/0xf0
[  359.505186]  [<ffffffff810450ea>] ? smp_apic_timer_interrupt+0x3a/0x50
[  359.510297]  [<ffffffff81537b5c>] ? apic_timer_interrupt+0x8c/0xa0
[  359.515124]  <EOI>  [<ffffffff81018850>] ? hard_enable_TSC+0x30/0x30
[  359.519948]  [<ffffffff81051782>] ? native_safe_halt+0x2/0x10
[  359.524396]  [<ffffffff81018855>] ? default_idle+0x5/0x10
[  359.528742]  [<ffffffff810a07fb>] ? cpu_startup_entry+0x22b/0x2a0
[  359.533370]  [<ffffffff8104324a>] ? start_secondary+0x14a/0x170
[  359.537889] ---[ end trace 3a6c6dbd7c58378f ]---
----------

This patch is incomplete because this check should as well be done at
kmem_cache_alloc() etc. which do not always call __alloc_pages_nodemask().
Also, this patch is incomplete because this check should be enabled only
when some debug config option is enabled, for this check will not be
needed once __GFP_NOWARN is added to callers.

What do you think?

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63358d9..669be9c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3183,6 +3183,11 @@ got_pg:
 	return page;
 }

+static void timer_reset(unsigned long arg)
+{
+}
+static DEFINE_TIMER(no_gfp_nowarn_timer, timer_reset, 0, 0);
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -3207,6 +3212,20 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,

 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);

+	/*
+	 * Suggest memory allocations from hard IRQ context to use __GFP_NOWARN
+	 * in order to reduce possibility of hitting hard lockup problem
+	 * because warn_alloc_failed() is very slow. Though, from the point of
+	 * view of minimizing latency, use of __GFP_NOWARN would be preferable
+	 * for any memory allocations from interrupt context (i.e. use
+	 * in_interrupt() rather than in_irq())...
+	 */
+	if (!(gfp_mask & __GFP_NOWARN) && in_irq() &&
+	    !timer_pending(&no_gfp_nowarn_timer)) {
+		mod_timer(&no_gfp_nowarn_timer, jiffies + 30 * HZ);
+		WARN(1, "Please consider adding __GFP_NOWARN to allocations from hard IRQ context.\n");
+	}
+
 	if (should_fail_alloc_page(gfp_mask, order))
 		return NULL;

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
