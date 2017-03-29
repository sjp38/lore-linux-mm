Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1466B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 15:44:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id r140so8553211qke.11
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 12:44:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v62si7037144qkd.32.2017.03.29.12.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 12:44:51 -0700 (PDT)
Date: Wed, 29 Mar 2017 21:44:41 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: in_irq_or_nmi() and RFC patch
Message-ID: <20170329214441.08332799@redhat.com>
In-Reply-To: <20170329211144.3e362ac9@redhat.com>
References: <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
	<2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
	<20170327105514.1ed5b1ba@redhat.com>
	<20170327143947.4c237e54@redhat.com>
	<20170327141518.GB27285@bombadil.infradead.org>
	<20170327171500.4beef762@redhat.com>
	<20170327165817.GA28494@bombadil.infradead.org>
	<20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
	<20170329105928.609bc581@redhat.com>
	<20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
	<20170329181226.GA8256@bombadil.infradead.org>
	<20170329211144.3e362ac9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org, brouer@redhat.com

On Wed, 29 Mar 2017 21:11:44 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Wed, 29 Mar 2017 11:12:26 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Wed, Mar 29, 2017 at 11:19:49AM +0200, Peter Zijlstra wrote:  
> > > On Wed, Mar 29, 2017 at 10:59:28AM +0200, Jesper Dangaard Brouer wrote:    
> > > > On Wed, 29 Mar 2017 10:12:19 +0200
> > > > Peter Zijlstra <peterz@infradead.org> wrote:    
> > > > > No, that's horrible. Also, wth is this about? A memory allocator that
> > > > > needs in_nmi()? That sounds beyond broken.    
> > > > 
> > > > It is the other way around. We want to exclude NMI and HARDIRQ from
> > > > using the per-cpu-pages (pcp) lists "order-0 cache" (they will
> > > > fall-through using the normal buddy allocator path).    
> > > 
> > > Any in_nmi() code arriving at the allocator is broken. No need to fix
> > > the allocator.    
> > 
> > That's demonstrably true.  You can't grab a spinlock in NMI code and
> > the first thing that happens if this in_irq_or_nmi() check fails is ...
> >         spin_lock_irqsave(&zone->lock, flags);
> > so this patch should just use in_irq().
> > 
> > (the concept of NMI code needing to allocate memory was blowing my mind
> > a little bit)  
> 
> Regardless or using in_irq() (or in combi with in_nmi()) I get the
> following warning below:
> 
> [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.11.0-rc3-net-next-page-alloc-softirq+ root=UUID=2e8451ff-6797-49b5-8d3a-eed5a42d7dc9 ro rhgb quiet LANG=en_DK.UTF
> -8
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] WARNING: CPU: 0 PID: 0 at kernel/softirq.c:161 __local_bh_enable_ip+0x70/0x90
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.11.0-rc3-net-next-page-alloc-softirq+ #235
> [    0.000000] Hardware name: MSI MS-7984/Z170A GAMING PRO (MS-7984), BIOS 1.60 12/16/2015
> [    0.000000] Call Trace:
> [    0.000000]  dump_stack+0x4f/0x73
> [    0.000000]  __warn+0xcb/0xf0
> [    0.000000]  warn_slowpath_null+0x1d/0x20
> [    0.000000]  __local_bh_enable_ip+0x70/0x90
> [    0.000000]  free_hot_cold_page+0x1a4/0x2f0
> [    0.000000]  __free_pages+0x1f/0x30
> [    0.000000]  __free_pages_bootmem+0xab/0xb8
> [    0.000000]  __free_memory_core+0x79/0x91
> [    0.000000]  free_all_bootmem+0xaa/0x122
> [    0.000000]  mem_init+0x71/0xa4
> [    0.000000]  start_kernel+0x1e5/0x3f1
> [    0.000000]  x86_64_start_reservations+0x2a/0x2c
> [    0.000000]  x86_64_start_kernel+0x178/0x18b
> [    0.000000]  start_cpu+0x14/0x14
> [    0.000000]  ? start_cpu+0x14/0x14
> [    0.000000] ---[ end trace a57944bec8fc985c ]---
> [    0.000000] Memory: 32739472K/33439416K available (7624K kernel code, 1528K rwdata, 3168K rodata, 1860K init, 2260K bss, 699944K reserved, 0K cma-reserved)
> 
> And kernel/softirq.c:161 contains:
> 
>  WARN_ON_ONCE(in_irq() || irqs_disabled());
> 
> Thus, I don't think the change in my RFC-patch[1] is safe.
> Of changing[2] to support softirq allocations by replacing
> preempt_disable() with local_bh_disable().
> 
> [1] http://lkml.kernel.org/r/20170327143947.4c237e54@redhat.com
> 
> [2] commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
>  https://git.kernel.org/torvalds/c/374ad05ab64d

A patch that avoids the above warning is inlined below, but I'm not
sure if this is best direction.  Or we should rather consider reverting
part of commit 374ad05ab64d to avoid the softirq performance regression?
 

[PATCH] mm, page_alloc: re-enable softirq use of per-cpu page allocator

From: Jesper Dangaard Brouer <brouer@redhat.com>

IRQ context were excluded from using the Per-Cpu-Pages (PCP) lists
caching of order-0 pages in commit 374ad05ab64d ("mm, page_alloc: only
use per-cpu allocator for irq-safe requests").

This unfortunately also included excluded SoftIRQ.  This hurt the
performance for the use-case of refilling DMA RX rings in softirq
context.

This patch re-allow softirq context, which should be safe by disabling
BH/softirq, while accessing the list.  PCP-lists access from both
hard-IRQ and NMI context must not be allowed.  Peter Zijlstra says
in_nmi() code never access the page allocator, thus it should be
sufficient to only test for !in_irq().

One concern with this change is adding a BH (enable) scheduling point
at both PCP alloc and free.

Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/page_alloc.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6cbde310abed..d7e986967910 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2351,9 +2351,9 @@ static void drain_local_pages_wq(struct work_struct *work)
 	 * cpu which is allright but we also have to make sure to not move to
 	 * a different one.
 	 */
-	preempt_disable();
+	local_bh_disable();
 	drain_local_pages(NULL);
-	preempt_enable();
+	local_bh_enable();
 }
 
 /*
@@ -2481,7 +2481,11 @@ void free_hot_cold_page(struct page *page, bool cold)
 	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
 
-	if (in_interrupt()) {
+	/*
+	 * Exclude (hard) IRQ and NMI context from using the pcplists.
+	 * But allow softirq context, via disabling BH.
+	 */
+	if (in_irq() || irqs_disabled()) {
 		__free_pages_ok(page, 0);
 		return;
 	}
@@ -2491,7 +2495,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	set_pcppage_migratetype(page, migratetype);
-	preempt_disable();
+	local_bh_disable();
 
 	/*
 	 * We only track unmovable, reclaimable and movable on pcp lists.
@@ -2522,7 +2526,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	}
 
 out:
-	preempt_enable();
+	local_bh_enable();
 }
 
 /*
@@ -2647,7 +2651,7 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 {
 	struct page *page;
 
-	VM_BUG_ON(in_interrupt());
+	VM_BUG_ON(in_irq() || irqs_disabled());
 
 	do {
 		if (list_empty(list)) {
@@ -2680,7 +2684,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 	struct page *page;
 
-	preempt_disable();
+	local_bh_disable();
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	list = &pcp->lists[migratetype];
 	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
@@ -2688,7 +2692,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone);
 	}
-	preempt_enable();
+	local_bh_enable();
 	return page;
 }
 
@@ -2704,7 +2708,11 @@ struct page *rmqueue(struct zone *preferred_zone,
 	unsigned long flags;
 	struct page *page;
 
-	if (likely(order == 0) && !in_interrupt()) {
+	/*
+	 * Exclude (hard) IRQ and NMI context from using the pcplists.
+	 * But allow softirq context, via disabling BH.
+	 */
+	if (likely(order == 0) && !(in_irq() || irqs_disabled()) ) {
 		page = rmqueue_pcplist(preferred_zone, zone, order,
 				gfp_flags, migratetype);
 		goto out;


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
