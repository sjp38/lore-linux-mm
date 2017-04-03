Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96B6A6B03A5
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 08:06:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z109so23772807wrb.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 05:06:12 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id k127si14985546wmb.49.2017.04.03.05.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 05:06:11 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 7364B99351
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 12:06:10 +0000 (UTC)
Date: Mon, 3 Apr 2017 13:05:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: in_irq_or_nmi() and RFC patch
Message-ID: <20170403120506.y7z3cncyi65bcgen@techsingularity.net>
References: <20170327171500.4beef762@redhat.com>
 <20170327165817.GA28494@bombadil.infradead.org>
 <20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
 <20170329105928.609bc581@redhat.com>
 <20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
 <20170329181226.GA8256@bombadil.infradead.org>
 <20170329211144.3e362ac9@redhat.com>
 <20170329214441.08332799@redhat.com>
 <20170330130436.l37yazbxlrkvcbf3@techsingularity.net>
 <20170330170708.084bd16c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170330170708.084bd16c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org

On Thu, Mar 30, 2017 at 05:07:08PM +0200, Jesper Dangaard Brouer wrote:
> On Thu, 30 Mar 2017 14:04:36 +0100
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > On Wed, Mar 29, 2017 at 09:44:41PM +0200, Jesper Dangaard Brouer wrote:
> > > > Regardless or using in_irq() (or in combi with in_nmi()) I get the
> > > > following warning below:
> > > > 
> > > > [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.11.0-rc3-net-next-page-alloc-softirq+ root=UUID=2e8451ff-6797-49b5-8d3a-eed5a42d7dc9 ro rhgb quiet LANG=en_DK.UTF
> > > > -8
> > > > [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> > > > [    0.000000] ------------[ cut here ]------------
> > > > [    0.000000] WARNING: CPU: 0 PID: 0 at kernel/softirq.c:161 __local_bh_enable_ip+0x70/0x90
> > > > [    0.000000] Modules linked in:
> > > > [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.11.0-rc3-net-next-page-alloc-softirq+ #235
> > > > [    0.000000] Hardware name: MSI MS-7984/Z170A GAMING PRO (MS-7984), BIOS 1.60 12/16/2015
> > > > [    0.000000] Call Trace:
> > > > [    0.000000]  dump_stack+0x4f/0x73
> > > > [    0.000000]  __warn+0xcb/0xf0
> > > > [    0.000000]  warn_slowpath_null+0x1d/0x20
> > > > [    0.000000]  __local_bh_enable_ip+0x70/0x90
> > > > [    0.000000]  free_hot_cold_page+0x1a4/0x2f0
> > > > [    0.000000]  __free_pages+0x1f/0x30
> > > > [    0.000000]  __free_pages_bootmem+0xab/0xb8
> > > > [    0.000000]  __free_memory_core+0x79/0x91
> > > > [    0.000000]  free_all_bootmem+0xaa/0x122
> > > > [    0.000000]  mem_init+0x71/0xa4
> > > > [    0.000000]  start_kernel+0x1e5/0x3f1
> > > > [    0.000000]  x86_64_start_reservations+0x2a/0x2c
> > > > [    0.000000]  x86_64_start_kernel+0x178/0x18b
> > > > [    0.000000]  start_cpu+0x14/0x14
> > > > [    0.000000]  ? start_cpu+0x14/0x14
> > > > [    0.000000] ---[ end trace a57944bec8fc985c ]---
> > > > [    0.000000] Memory: 32739472K/33439416K available (7624K kernel code, 1528K rwdata, 3168K rodata, 1860K init, 2260K bss, 699944K reserved, 0K cma-reserved)
> > > > 
> > > > And kernel/softirq.c:161 contains:
> > > > 
> > > >  WARN_ON_ONCE(in_irq() || irqs_disabled());
> > > > 
> > > > Thus, I don't think the change in my RFC-patch[1] is safe.
> > > > Of changing[2] to support softirq allocations by replacing
> > > > preempt_disable() with local_bh_disable().
> > > > 
> > > > [1] http://lkml.kernel.org/r/20170327143947.4c237e54@redhat.com
> > > > 
> > > > [2] commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> > > >  https://git.kernel.org/torvalds/c/374ad05ab64d  
> > > 
> > > A patch that avoids the above warning is inlined below, but I'm not
> > > sure if this is best direction.  Or we should rather consider reverting
> > > part of commit 374ad05ab64d to avoid the softirq performance regression?
> > >    
> > 
> > At the moment, I'm not seeing a better alternative. If this works, I
> > think it would still be far superior in terms of performance than a
> > revert. 
> 
> Started performance benchmarking:
>  163 cycles = current state
>  183 cycles = with BH disable + in_irq
>  218 cycles = with BH disable + in_irq + irqs_disabled
> 
> Thus, the performance numbers unfortunately looks bad, once we add the
> test for irqs_disabled().  The slowdown by replacing preempt_disable
> with BH-disable is still a win (we saved 29 cycles before, and loose
> 20, I was expecting regression to be only 10 cycles).
> 

This surprises me because I'm not seeing the same severity of problems
with irqs_disabled. Your path is slower than what's currently upstream
but it's still far better than a revert. The softirq column in the
middle is your patch versus a full revert which is the last columnm

                                          4.11.0-rc5                 4.11.0-rc5                 4.11.0-rc5
                                             vanilla               softirq-v2r1                revert-v2r1
Amean    alloc-odr0-1               217.00 (  0.00%)           223.00 ( -2.76%)           280.54 (-29.28%)
Amean    alloc-odr0-2               162.23 (  0.00%)           174.46 ( -7.54%)           210.54 (-29.78%)
Amean    alloc-odr0-4               144.15 (  0.00%)           150.38 ( -4.32%)           182.38 (-26.52%)
Amean    alloc-odr0-8               126.00 (  0.00%)           132.15 ( -4.88%)           282.08 (-123.87%)
Amean    alloc-odr0-16              117.00 (  0.00%)           122.00 ( -4.27%)           253.00 (-116.24%)
Amean    alloc-odr0-32              113.00 (  0.00%)           118.00 ( -4.42%)           145.00 (-28.32%)
Amean    alloc-odr0-64              110.77 (  0.00%)           114.31 ( -3.19%)           143.00 (-29.10%)
Amean    alloc-odr0-128             109.00 (  0.00%)           107.69 (  1.20%)           179.54 (-64.71%)
Amean    alloc-odr0-256             121.00 (  0.00%)           125.00 ( -3.31%)           232.23 (-91.93%)
Amean    alloc-odr0-512             123.46 (  0.00%)           129.46 ( -4.86%)           148.08 (-19.94%)
Amean    alloc-odr0-1024            123.23 (  0.00%)           128.92 ( -4.62%)           142.46 (-15.61%)
Amean    alloc-odr0-2048            125.92 (  0.00%)           129.62 ( -2.93%)           147.46 (-17.10%)
Amean    alloc-odr0-4096            133.85 (  0.00%)           139.77 ( -4.43%)           155.69 (-16.32%)
Amean    alloc-odr0-8192            138.08 (  0.00%)           142.92 ( -3.51%)           159.00 (-15.15%)
Amean    alloc-odr0-16384           133.08 (  0.00%)           140.08 ( -5.26%)           157.38 (-18.27%)
Amean    alloc-odr1-1               390.27 (  0.00%)           401.53 ( -2.89%)           389.73 (  0.14%)
Amean    alloc-odr1-2               306.33 (  0.00%)           311.07 ( -1.55%)           304.07 (  0.74%)
Amean    alloc-odr1-4               250.87 (  0.00%)           258.00 ( -2.84%)           256.53 ( -2.26%)
Amean    alloc-odr1-8               221.00 (  0.00%)           231.07 ( -4.56%)           221.20 ( -0.09%)
Amean    alloc-odr1-16              212.07 (  0.00%)           223.07 ( -5.19%)           208.00 (  1.92%)
Amean    alloc-odr1-32              210.07 (  0.00%)           215.20 ( -2.44%)           208.20 (  0.89%)
Amean    alloc-odr1-64              197.00 (  0.00%)           203.00 ( -3.05%)           203.00 ( -3.05%)
Amean    alloc-odr1-128             204.07 (  0.00%)           189.27 (  7.25%)           200.00 (  1.99%)
Amean    alloc-odr1-256             193.33 (  0.00%)           190.53 (  1.45%)           193.80 ( -0.24%)
Amean    alloc-odr1-512             180.60 (  0.00%)           190.33 ( -5.39%)           183.13 ( -1.40%)
Amean    alloc-odr1-1024            176.93 (  0.00%)           182.40 ( -3.09%)           176.33 (  0.34%)
Amean    alloc-odr1-2048            184.60 (  0.00%)           191.33 ( -3.65%)           180.60 (  2.17%)
Amean    alloc-odr1-4096            184.80 (  0.00%)           182.60 (  1.19%)           182.27 (  1.37%)
Amean    alloc-odr1-8192            183.60 (  0.00%)           180.93 (  1.45%)           181.07 (  1.38%)

I revisisted having an irq-safe list but it's excessively complex and
there are significant problems where it's not clear it can be handled
safely so it's not a short-term option.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
