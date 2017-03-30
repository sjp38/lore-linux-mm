Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 848622806DF
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 11:07:20 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p5so17413587qtb.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:07:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l45si2044506qtf.37.2017.03.30.08.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 08:07:18 -0700 (PDT)
Date: Thu, 30 Mar 2017 17:07:08 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: in_irq_or_nmi() and RFC patch
Message-ID: <20170330170708.084bd16c@redhat.com>
In-Reply-To: <20170330130436.l37yazbxlrkvcbf3@techsingularity.net>
References: <20170327143947.4c237e54@redhat.com>
	<20170327141518.GB27285@bombadil.infradead.org>
	<20170327171500.4beef762@redhat.com>
	<20170327165817.GA28494@bombadil.infradead.org>
	<20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
	<20170329105928.609bc581@redhat.com>
	<20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
	<20170329181226.GA8256@bombadil.infradead.org>
	<20170329211144.3e362ac9@redhat.com>
	<20170329214441.08332799@redhat.com>
	<20170330130436.l37yazbxlrkvcbf3@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org, brouer@redhat.com

On Thu, 30 Mar 2017 14:04:36 +0100
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Mar 29, 2017 at 09:44:41PM +0200, Jesper Dangaard Brouer wrote:
> > > Regardless or using in_irq() (or in combi with in_nmi()) I get the
> > > following warning below:
> > > 
> > > [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.11.0-rc3-net-next-page-alloc-softirq+ root=UUID=2e8451ff-6797-49b5-8d3a-eed5a42d7dc9 ro rhgb quiet LANG=en_DK.UTF
> > > -8
> > > [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> > > [    0.000000] ------------[ cut here ]------------
> > > [    0.000000] WARNING: CPU: 0 PID: 0 at kernel/softirq.c:161 __local_bh_enable_ip+0x70/0x90
> > > [    0.000000] Modules linked in:
> > > [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.11.0-rc3-net-next-page-alloc-softirq+ #235
> > > [    0.000000] Hardware name: MSI MS-7984/Z170A GAMING PRO (MS-7984), BIOS 1.60 12/16/2015
> > > [    0.000000] Call Trace:
> > > [    0.000000]  dump_stack+0x4f/0x73
> > > [    0.000000]  __warn+0xcb/0xf0
> > > [    0.000000]  warn_slowpath_null+0x1d/0x20
> > > [    0.000000]  __local_bh_enable_ip+0x70/0x90
> > > [    0.000000]  free_hot_cold_page+0x1a4/0x2f0
> > > [    0.000000]  __free_pages+0x1f/0x30
> > > [    0.000000]  __free_pages_bootmem+0xab/0xb8
> > > [    0.000000]  __free_memory_core+0x79/0x91
> > > [    0.000000]  free_all_bootmem+0xaa/0x122
> > > [    0.000000]  mem_init+0x71/0xa4
> > > [    0.000000]  start_kernel+0x1e5/0x3f1
> > > [    0.000000]  x86_64_start_reservations+0x2a/0x2c
> > > [    0.000000]  x86_64_start_kernel+0x178/0x18b
> > > [    0.000000]  start_cpu+0x14/0x14
> > > [    0.000000]  ? start_cpu+0x14/0x14
> > > [    0.000000] ---[ end trace a57944bec8fc985c ]---
> > > [    0.000000] Memory: 32739472K/33439416K available (7624K kernel code, 1528K rwdata, 3168K rodata, 1860K init, 2260K bss, 699944K reserved, 0K cma-reserved)
> > > 
> > > And kernel/softirq.c:161 contains:
> > > 
> > >  WARN_ON_ONCE(in_irq() || irqs_disabled());
> > > 
> > > Thus, I don't think the change in my RFC-patch[1] is safe.
> > > Of changing[2] to support softirq allocations by replacing
> > > preempt_disable() with local_bh_disable().
> > > 
> > > [1] http://lkml.kernel.org/r/20170327143947.4c237e54@redhat.com
> > > 
> > > [2] commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> > >  https://git.kernel.org/torvalds/c/374ad05ab64d  
> > 
> > A patch that avoids the above warning is inlined below, but I'm not
> > sure if this is best direction.  Or we should rather consider reverting
> > part of commit 374ad05ab64d to avoid the softirq performance regression?
> >    
> 
> At the moment, I'm not seeing a better alternative. If this works, I
> think it would still be far superior in terms of performance than a
> revert. 

Started performance benchmarking:
 163 cycles = current state
 183 cycles = with BH disable + in_irq
 218 cycles = with BH disable + in_irq + irqs_disabled

Thus, the performance numbers unfortunately looks bad, once we add the
test for irqs_disabled().  The slowdown by replacing preempt_disable
with BH-disable is still a win (we saved 29 cycles before, and loose
20, I was expecting regression to be only 10 cycles).

Bad things happen when adding the test for irqs_disabled().  This
likely happens because it uses the "pushfq + pop" to read CPU flags.  I
wonder if X86-experts know if e.g. using "lahf" would be faster (and if
it also loads the interrupt flag X86_EFLAGS_IF)?

We basically lost more (163-218=-55) than we gained (29) :-(


> As before, if there are bad consequences to adding a BH
> rescheduling point then we'll have to revert. However, I don't like a
> revert being the first option as it'll keep encouraging drivers to build
> sub-allocators to avoid the page allocator.

I'm also motivated by speeding up the page allocator to avoid this
happening in all the drivers.

> > [PATCH] mm, page_alloc: re-enable softirq use of per-cpu page allocator
> > 
> > From: Jesper Dangaard Brouer <brouer@redhat.com>
> >   
> 
> Other than the slightly misleading comments about NMI which could
> explain "this potentially misses an NMI but an NMI allocating pages is
> brain damaged", I don't see a problem. The irqs_disabled() check is a
> subtle but it's not earth shattering and it still helps the 100GiB cases
> with the limited cycle budget to process packets.


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
