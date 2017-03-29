Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82B816B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 15:11:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p5so8128089qtb.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 12:11:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n29si6970014qtc.29.2017.03.29.12.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 12:11:54 -0700 (PDT)
Date: Wed, 29 Mar 2017 21:11:44 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: in_irq_or_nmi()
Message-ID: <20170329211144.3e362ac9@redhat.com>
In-Reply-To: <20170329181226.GA8256@bombadil.infradead.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org, brouer@redhat.com


On Wed, 29 Mar 2017 11:12:26 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> On Wed, Mar 29, 2017 at 11:19:49AM +0200, Peter Zijlstra wrote:
> > On Wed, Mar 29, 2017 at 10:59:28AM +0200, Jesper Dangaard Brouer wrote:  
> > > On Wed, 29 Mar 2017 10:12:19 +0200
> > > Peter Zijlstra <peterz@infradead.org> wrote:  
> > > > No, that's horrible. Also, wth is this about? A memory allocator that
> > > > needs in_nmi()? That sounds beyond broken.  
> > > 
> > > It is the other way around. We want to exclude NMI and HARDIRQ from
> > > using the per-cpu-pages (pcp) lists "order-0 cache" (they will
> > > fall-through using the normal buddy allocator path).  
> > 
> > Any in_nmi() code arriving at the allocator is broken. No need to fix
> > the allocator.  
> 
> That's demonstrably true.  You can't grab a spinlock in NMI code and
> the first thing that happens if this in_irq_or_nmi() check fails is ...
>         spin_lock_irqsave(&zone->lock, flags);
> so this patch should just use in_irq().
> 
> (the concept of NMI code needing to allocate memory was blowing my mind
> a little bit)

Regardless or using in_irq() (or in combi with in_nmi()) I get the
following warning below:

[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.11.0-rc3-net-next-page-alloc-softirq+ root=UUID=2e8451ff-6797-49b5-8d3a-eed5a42d7dc9 ro rhgb quiet LANG=en_DK.UTF
-8
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at kernel/softirq.c:161 __local_bh_enable_ip+0x70/0x90
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.11.0-rc3-net-next-page-alloc-softirq+ #235
[    0.000000] Hardware name: MSI MS-7984/Z170A GAMING PRO (MS-7984), BIOS 1.60 12/16/2015
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x4f/0x73
[    0.000000]  __warn+0xcb/0xf0
[    0.000000]  warn_slowpath_null+0x1d/0x20
[    0.000000]  __local_bh_enable_ip+0x70/0x90
[    0.000000]  free_hot_cold_page+0x1a4/0x2f0
[    0.000000]  __free_pages+0x1f/0x30
[    0.000000]  __free_pages_bootmem+0xab/0xb8
[    0.000000]  __free_memory_core+0x79/0x91
[    0.000000]  free_all_bootmem+0xaa/0x122
[    0.000000]  mem_init+0x71/0xa4
[    0.000000]  start_kernel+0x1e5/0x3f1
[    0.000000]  x86_64_start_reservations+0x2a/0x2c
[    0.000000]  x86_64_start_kernel+0x178/0x18b
[    0.000000]  start_cpu+0x14/0x14
[    0.000000]  ? start_cpu+0x14/0x14
[    0.000000] ---[ end trace a57944bec8fc985c ]---
[    0.000000] Memory: 32739472K/33439416K available (7624K kernel code, 1528K rwdata, 3168K rodata, 1860K init, 2260K bss, 699944K reserved, 0K cma-reserved)

And kernel/softirq.c:161 contains:

 WARN_ON_ONCE(in_irq() || irqs_disabled());

Thus, I don't think the change in my RFC-patch[1] is safe.
Of changing[2] to support softirq allocations by replacing
preempt_disable() with local_bh_disable().

[1] http://lkml.kernel.org/r/20170327143947.4c237e54@redhat.com

[2] commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
 https://git.kernel.org/torvalds/c/374ad05ab64d

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
