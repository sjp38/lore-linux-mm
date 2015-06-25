Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id CC25B6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 07:48:27 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so73315190wib.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 04:48:27 -0700 (PDT)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id bn1si8193697wib.38.2015.06.25.04.48.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 04:48:25 -0700 (PDT)
Received: by wgck11 with SMTP id k11so60397659wgc.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 04:48:24 -0700 (PDT)
Date: Thu, 25 Jun 2015 13:48:20 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150625114819.GA20478@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <5577078B.2000503@intel.com>
 <20150621202231.GB6766@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150621202231.GB6766@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Jun 09, 2015 at 08:34:35AM -0700, Dave Hansen wrote:
> > On 06/09/2015 05:43 AM, Ingo Molnar wrote:
> > > +static char tlb_flush_target[PAGE_SIZE] __aligned(4096);
> > > +static void fn_flush_tlb_one(void)
> > > +{
> > > +	unsigned long addr = (unsigned long)&tlb_flush_target;
> > > +
> > > +	tlb_flush_target[0]++;
> > > +	__flush_tlb_one(addr);
> > > +}
> > 
> > So we've got an increment of a variable in kernel memory (which is
> > almost surely in the L1), then we flush that memory location, and repeat
> > the increment.
> 
> BTW, Ingo, have you disabled direct mapping of kernel memory with 2M/1G
> pages for the test? 

No, the kernel was using gbpages.

> I'm just thinking if there is chance that the test shooting out 1G tlb entry. In 
> this case we're measure wrong thing.

Yeah, you are right, it's slightly wrong, but still gave us the right numbers to 
work with.

I've updated the benchmarks with 4K flushes as well. Changes to the previous 
measurement:

 - I've refined the testing methodology. (It now looks at the true distribution of
   delays, not just the minimum or an average: this is especially important for
   cache-cold numbers were perturbations (such as irq or SMI events) can generate 
   outliers in both directions.)

 - Added tests to attempt to measure the TLB miss costs, I've split the INVLPG 
   measurements into over a dozen separate variants, which should help measure the 
   overall impact of TLB flushes and should help quantify the 'hidden' cost cost 
   associated with TLB flushes as well.

Here are the numbers:

Old 64-bit CPU (AMD) using 2MB/4K pages:

[    8.122002] x86/bench: Running x86 benchmarks:              cache-    hot  /   cold cycles
[   12.269003] x86/bench:########  MM methods:        #######################################
[   12.369003] x86/bench: __flush_tlb()               fn            :    127  /    273
[   12.469003] x86/bench: __flush_tlb_global()        fn            :    589  /   1501
[   12.568003] x86/bench: access           2M page    fn            :      0  /    440
[   12.668003] x86/bench: invlpg           2M page    fn            :     93  /    512
[   12.768003] x86/bench: access+invlpg    2M page    fn            :    107  /    512
[   12.868003] x86/bench: invlpg+access    2M page    fn            :     94  /    535
[   12.972003] x86/bench: flush+access     2M page    fn            :    113  /   1060
[   13.070003] x86/bench: access        1x 4K page    fn            :      0  /      5
[   13.166003] x86/bench: access        2x 4K page    fn            :      1  /    150
[   13.264003] x86/bench: access        3x 4K page    fn            :      1  /    331
[   13.360003] x86/bench: access        4x 4K page    fn            :      1  /    360
[   13.463003] x86/bench: invlpg+access 1x 4K page    fn            :     95  /    247
[   13.566003] x86/bench: invlpg+access 2x 4K page    fn            :    188  /    543
[   13.668003] x86/bench: invlpg+access 3x 4K page    fn            :    281  /    836
[   13.774003] x86/bench: invlpg+access 4x 4K page    fn            :    374  /   1165
[   13.878003] x86/bench: flush+access  1x 4K page    fn            :    114  /    275
[   13.981003] x86/bench: flush+access  2x 4K page    fn            :    115  /    480
[   14.083003] x86/bench: flush+access  3x 4K page    fn            :    115  /    671
[   14.183003] x86/bench: flush+access  4x 4K page    fn            :    116  /    670
[   14.286003] x86/bench: flush            4K page    fn            :    108  /    247
[   14.385003] x86/bench: access+invlpg    4K page    fn            :     94  /    287
[   14.502003] x86/bench: __flush_tlb_range()         fn            :    280  /   5173

Newer 64-bit CPU (Intel) using gbpages/4K pages:

[            ] x86/bench: Running x86 benchmarks:              cache-    hot  /   cold cycles
[            ] x86/bench:########  MM methods:        #######################################
[  124.362251] x86/bench: __flush_tlb()               fn            :    152  /    168
[  125.287283] x86/bench: __flush_tlb_global()        fn            :    936  /   1312
[  126.227641] x86/bench: access           GB page    fn            :     12  /    304
[  127.152369] x86/bench: invlpg           GB page    fn            :    280  /    584
[  128.084376] x86/bench: access+invlpg    GB page    fn            :    280  /    592
[  129.018430] x86/bench: invlpg+access    GB page    fn            :    280  /    596
[  129.939640] x86/bench: flush+access     GB page    fn            :    152  /    396
[  130.849827] x86/bench: access        1x 4K page    fn            :      0  /      0
[  131.796836] x86/bench: access        2x 4K page    fn            :     12  /    432
[  132.738849] x86/bench: access        3x 4K page    fn            :     16  /    736
[  133.661315] x86/bench: access        4x 4K page    fn            :     12  /    736
[  134.575238] x86/bench: invlpg+access 1x 4K page    fn            :    280  /    356
[  135.506638] x86/bench: invlpg+access 2x 4K page    fn            :    500  /   1152
[  136.432645] x86/bench: invlpg+access 3x 4K page    fn            :    728  /   1920
[  137.355536] x86/bench: invlpg+access 4x 4K page    fn            :    956  /   3084
[  138.296174] x86/bench: flush+access  1x 4K page    fn            :    148  /    280
[  139.229264] x86/bench: flush+access  2x 4K page    fn            :    152  /    728
[  140.165103] x86/bench: flush+access  3x 4K page    fn            :    136  /    736
[  141.088691] x86/bench: flush+access  4x 4K page    fn            :    152  /    820
[  141.994946] x86/bench: flush            4K page    fn            :    280  /    328
[  142.902499] x86/bench: access+invlpg    4K page    fn            :    280  /    352
[  143.814408] x86/bench: __flush_tlb_range()         fn            :    424  /   2100

Notes:

 - 'access' means an ACCESS_ONCE() load.

 - 'flush'  means a CR3 based full flush

 - 'invlpg' means an __flush_tlb_one() INVLPG flush

 - the 4K pages are vmalloc()-ed pages. 

 - 1x, 2x, 3x, 4x means up to 4 adjacent 4K vmalloc()-ed pages are accessed, the 
   first byte in each

 - PGE is turned off in the CR4 for these measuremnts, to make sure the 
  vmalloc()-ed page(s) get flushed by the CR3 method as well.

 - there's a bit of a jitter in the numbers, for example the 'flush+access 3x 4K' 
   number is lower - but the jitter is in the 10 cycles range max

As you can see (assuming the numbers are correct), the 'full' CR3 based flushing 
is superior to any __flush_tlb_one() method:

[  134.575238] x86/bench: invlpg+access 1x 4K page    fn            :    280  /    356
[  135.506638] x86/bench: invlpg+access 2x 4K page    fn            :    500  /   1152
[  136.432645] x86/bench: invlpg+access 3x 4K page    fn            :    728  /   1920
[  137.355536] x86/bench: invlpg+access 4x 4K page    fn            :    956  /   3084

[  138.296174] x86/bench: flush+access  1x 4K page    fn            :    148  /    280
[  139.229264] x86/bench: flush+access  2x 4K page    fn            :    152  /    728
[  140.165103] x86/bench: flush+access  3x 4K page    fn            :    136  /    736
[  141.088691] x86/bench: flush+access  4x 4K page    fn            :    152  /    820

In the cache-hot case: with the CR3 based method the _full_ cost of flushing (i.e. 
the cost of the flush plus the cost of the access) is roughly constant. With 
INVLPG it's both higher, and increases linearly.

In the cache-cold case: the costs are increasing linearly, but it's much higher in 
the INVLPG case. 

So in fact I'd argue that, somewhat counter-intuitively, we should consider doing 
a full flush even for single-page flushes, for example for page faults...

I'll do more measurements (and will publish the latest patches) to increase 
confidence in the numbers.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
