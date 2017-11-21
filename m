Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 393E16B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 19:28:25 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id l13so9952752qtc.9
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 16:28:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u64sor7932626qkd.47.2017.11.20.16.28.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 16:28:23 -0800 (PST)
Date: Mon, 20 Nov 2017 19:28:21 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct pcpu_alloc_info
 (crisv32 hang)
In-Reply-To: <20171120211114.GA25984@roeck-us.net>
Message-ID: <nycvar.YSQ.7.76.1711201918180.16045@knanqh.ubzr>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr> <20171118182542.GA23928@roeck-us.net> <nycvar.YSQ.7.76.1711191525450.16045@knanqh.ubzr> <a4fd87d4-c183-682d-9fd9-a9ff6d04f63e@roeck-us.net> <nycvar.YSQ.7.76.1711192230000.16045@knanqh.ubzr>
 <62a3b680-6dde-d308-3da8-9c9a2789b114@roeck-us.net> <nycvar.YSQ.7.76.1711201305160.16045@knanqh.ubzr> <20171120185138.GB23789@roeck-us.net> <nycvar.YSQ.7.76.1711201512300.16045@knanqh.ubzr> <20171120211114.GA25984@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

On Mon, 20 Nov 2017, Guenter Roeck wrote:

> On Mon, Nov 20, 2017 at 03:21:32PM -0500, Nicolas Pitre wrote:
> > On Mon, 20 Nov 2017, Guenter Roeck wrote:
> > 
> > > On Mon, Nov 20, 2017 at 01:18:38PM -0500, Nicolas Pitre wrote:
> > > > On Sun, 19 Nov 2017, Guenter Roeck wrote:
> > > > 
> > > > > On 11/19/2017 08:08 PM, Nicolas Pitre wrote:
> > > > > > On Sun, 19 Nov 2017, Guenter Roeck wrote:
> > > > > > > On 11/19/2017 12:36 PM, Nicolas Pitre wrote:
> > > > > > > > On Sat, 18 Nov 2017, Guenter Roeck wrote:
> > > > > > > > > On Tue, Oct 03, 2017 at 06:29:49PM -0400, Nicolas Pitre wrote:
> > > > > > > > > > @@ -2295,6 +2295,7 @@ void __init setup_per_cpu_areas(void)
> > > > > > > > > >      	if (pcpu_setup_first_chunk(ai, fc) < 0)
> > > > > > > > > >    		panic("Failed to initialize percpu areas.");
> > > > > > > > > > +	pcpu_free_alloc_info(ai);
> > > > > > > > > 
> > > > > > > > > This is the culprit. Everything works fine if I remove this line.
> > > > > > > > 
> > > > > > > > Without this line, the memory at the ai pointer is leaked. Maybe this is
> > > > > > > > modifying the memory allocation pattern and that triggers a bug later on
> > > > > > > > in your case.
> > > > > > > > 
> > > > > > > > At that point the console driver is not yet initialized and any error
> > > > > > > > message won't be printed. You should enable the early console mechanism
> > > > > > > > in your kernel (see arch/cris/arch-v32/kernel/debugport.c) and see what
> > > > > > > > that might tell you.
> > > > > > > > 
> > > > > > > 
> > > > > > > The problem is that BUG() on crisv32 does not yield useful output.
> > > > > > > Anyway, here is the culprit.
> > > > > > > 
> > > > > > > diff --git a/mm/bootmem.c b/mm/bootmem.c
> > > > > > > index 6aef64254203..2bcc8901450c 100644
> > > > > > > --- a/mm/bootmem.c
> > > > > > > +++ b/mm/bootmem.c
> > > > > > > @@ -382,7 +382,8 @@ static int __init mark_bootmem(unsigned long start,
> > > > > > > unsigned long end,
> > > > > > >                          return 0;
> > > > > > >                  pos = bdata->node_low_pfn;
> > > > > > >          }
> > > > > > > -       BUG();
> > > > > > > +       WARN(1, "mark_bootmem(): memory range 0x%lx-0x%lx not found\n",
> > > > > > > start,
> > > > > > > end);
> > > > > > > +       return -ENOMEM;
> > > > > > >   }
> > > > > > > 
> > > > > > >   /**
> > > > > > > diff --git a/mm/percpu.c b/mm/percpu.c
> > > > > > > index 79e3549cab0f..c75622d844f1 100644
> > > > > > > --- a/mm/percpu.c
> > > > > > > +++ b/mm/percpu.c
> > > > > > > @@ -1881,6 +1881,7 @@ struct pcpu_alloc_info * __init
> > > > > > > pcpu_alloc_alloc_info(int nr_groups,
> > > > > > >    */
> > > > > > >   void __init pcpu_free_alloc_info(struct pcpu_alloc_info *ai)
> > > > > > >   {
> > > > > > > +       printk("pcpu_free_alloc_info(%p (0x%lx))\n", ai, __pa(ai));
> > > > > > >          memblock_free_early(__pa(ai), ai->__ai_size);
> > > > > > >
> > > > > > > results in:
> > > > > > > 
> > > > > > > pcpu_free_alloc_info(c0534000 (0x40534000))
> > > > > > > ------------[ cut here ]------------
> > > > > > > WARNING: CPU: 0 PID: 0 at mm/bootmem.c:385 mark_bootmem+0x9a/0xaa
> > > > > > > mark_bootmem(): memory range 0x2029a-0x2029b not found
> > > > > > 
> > > > > > Well... PFN_UP(0x40534000) should give 0x40534. How you might end up
> > > > > > with 0x2029a in mark_bootmem(), let alone not exit on the first "if (max
> > > > > > == end) return 0;" within the loop is rather weird.
> > > > > > 
> > > > > pcpu_free_alloc_info: ai=c0536000, __pa(ai)=0x40536000,
> > > > > PFN_UP(__pa(ai))=0x2029b, PFN_UP(ai)=0x6029b
> > > > > 
> > > > > bootmem range is 0x60000..0x61000. It doesn't get to "if (max == end)"
> > > > > because "pos (=0x2029b) < bdata->node_min_pfn (=0x60000)".
> > > > 
> > > > OK. the 0x2029b is the result of PAGE_SIZE being 8192 in your case.
> > > > However the bootmem allocator deals with physical addresses not virtual 
> > > > ones. So it shouldn't give you a 0x60000..0x61000 range.
> > > > 
> > > > Would be interesting to see what result you get on line 860 of 
> > > > mm/bootmem.c.
> > > > 
> > > Nothing; __alloc_bootmem_low_node() is not called.
> > > 
> > > Call chain is:
> > >   pcpu_alloc_alloc_info
> > >     memblock_virt_alloc_nopanic
> > >       __alloc_bootmem_nopanic
> > >         ___alloc_bootmem_nopanic
> > 
> > But from there it should continue with: 
> > 
> > 	alloc_bootmem_core() -->
> > 	  alloc_bootmem_bdata() -->
> > 	    [...]
> > 	    region = phys_to_virt(PFN_PHYS(bdata->node_min_pfn) + start_off);
> > 
> > That's line 585, not 860 as I mentioned. Sorry for the confusion.
> > 
> bdata->node_min_pfn=60000 PFN_PHYS(bdata->node_min_pfn)=c0000000 start_off=536000 region=c0536000

If PFN_PHYS(bdata->node_min_pfn)=c0000000 and
region=c0536000 that means phys_to_virt() is a no-op.

However, from your result above, __pa(0xc0534000) = 0x40534000.

So, why is it that phys_to_virt() is a no-op and __pa() is not?

virt_to_phys() and __pa() are meant to be the reverse of phys_to_virt() 
and __va().


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
