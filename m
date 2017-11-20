Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6DD6B0038
	for <linux-mm@kvack.org>; Sun, 19 Nov 2017 23:08:18 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v137so3899015qkb.3
        for <linux-mm@kvack.org>; Sun, 19 Nov 2017 20:08:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f56sor6395762qtk.93.2017.11.19.20.08.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 Nov 2017 20:08:16 -0800 (PST)
Date: Sun, 19 Nov 2017 23:08:14 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: mm/percpu.c: use smarter memory allocation for struct pcpu_alloc_info
 (crisv32 hang)
In-Reply-To: <a4fd87d4-c183-682d-9fd9-a9ff6d04f63e@roeck-us.net>
Message-ID: <nycvar.YSQ.7.76.1711192230000.16045@knanqh.ubzr>
References: <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr> <20171118182542.GA23928@roeck-us.net> <nycvar.YSQ.7.76.1711191525450.16045@knanqh.ubzr> <a4fd87d4-c183-682d-9fd9-a9ff6d04f63e@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com

On Sun, 19 Nov 2017, Guenter Roeck wrote:
> On 11/19/2017 12:36 PM, Nicolas Pitre wrote:
> > On Sat, 18 Nov 2017, Guenter Roeck wrote:
> > > On Tue, Oct 03, 2017 at 06:29:49PM -0400, Nicolas Pitre wrote:
> > > > @@ -2295,6 +2295,7 @@ void __init setup_per_cpu_areas(void)
> > > >     	if (pcpu_setup_first_chunk(ai, fc) < 0)
> > > >   		panic("Failed to initialize percpu areas.");
> > > > +	pcpu_free_alloc_info(ai);
> > > 
> > > This is the culprit. Everything works fine if I remove this line.
> > 
> > Without this line, the memory at the ai pointer is leaked. Maybe this is
> > modifying the memory allocation pattern and that triggers a bug later on
> > in your case.
> > 
> > At that point the console driver is not yet initialized and any error
> > message won't be printed. You should enable the early console mechanism
> > in your kernel (see arch/cris/arch-v32/kernel/debugport.c) and see what
> > that might tell you.
> > 
> 
> The problem is that BUG() on crisv32 does not yield useful output.
> Anyway, here is the culprit.
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 6aef64254203..2bcc8901450c 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -382,7 +382,8 @@ static int __init mark_bootmem(unsigned long start,
> unsigned long end,
>                         return 0;
>                 pos = bdata->node_low_pfn;
>         }
> -       BUG();
> +       WARN(1, "mark_bootmem(): memory range 0x%lx-0x%lx not found\n", start,
> end);
> +       return -ENOMEM;
>  }
> 
>  /**
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 79e3549cab0f..c75622d844f1 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1881,6 +1881,7 @@ struct pcpu_alloc_info * __init
> pcpu_alloc_alloc_info(int nr_groups,
>   */
>  void __init pcpu_free_alloc_info(struct pcpu_alloc_info *ai)
>  {
> +       printk("pcpu_free_alloc_info(%p (0x%lx))\n", ai, __pa(ai));
>         memblock_free_early(__pa(ai), ai->__ai_size);

The problem here is that there is two possibilities for 
memblock_free_early(). From include/linux/bootmem.h:

#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)

static inline void __init memblock_free_early(
                                        phys_addr_t base, phys_addr_t size)
{
        __memblock_free_early(base, size);
}

#else

static inline void __init memblock_free_early(
                                        phys_addr_t base, phys_addr_t size)
{
        free_bootmem(base, size);
}

#endif

It looks like most architectures use the memblock variant, including all 
the ones I have access to.

> results in:
> 
> pcpu_free_alloc_info(c0534000 (0x40534000))
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 0 at mm/bootmem.c:385 mark_bootmem+0x9a/0xaa
> mark_bootmem(): memory range 0x2029a-0x2029b not found

Well... PFN_UP(0x40534000) should give 0x40534. How you might end up 
with 0x2029a in mark_bootmem(), let alone not exit on the first "if (max 
== end) return 0;" within the loop is rather weird.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
