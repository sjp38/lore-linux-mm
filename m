Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA08791
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 01:53:10 -0400
Date: Tue, 6 Apr 1999 01:52:55 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904060128120.447-100000@laser.random>
Message-ID: <Pine.BSF.4.03.9904060124390.12767-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Andrea Arcangeli wrote:
> Cool! ;)) But could you tell me _how_ do you design an hash function? Are
> you doing math or do you use instinct?

math.  i'll post something about this soon.
 
> >but also the page hash function uses the hash table size as a shift value
> >when computing the index, so it may combine the interesting bits in a
> >different (worse) way when you change the hash table size.  i'm planning
> >to instrument the page hash to see exactly what's going on.
> 
> Agreed. This is true. I thought about that and I am resizing the hash
> table size to the original 11 bit now (since you are confirming that I
> broken the hash function).

i looked at doug's patch too, and it changes the "page_shift" value
depending on the size of the hash table.  again, this *may* cause unwanted
interactions making the hash function degenerate for certain table sizes.
but i'd like to instrument the hash to watch what really happens.


i ran some simple benchmarks on our 4-way Xeon PowerEdge to see what are
the effects of your patches.  here were the original patches against
2.2.5.

the page struct alignment patch:

> --- linux/include/linux/mm.h	Tue Mar  9 01:55:28 1999
> +++ mm.h	Tue Apr  6 02:00:22 1999
> @@ -131,0 +133,6 @@
> +#ifdef __SMP__
> +	/* cacheline alignment */
> +	char dummy[(sizeof(void *) * 7 +
> +		    sizeof(unsigned long) * 2 +
> +		    sizeof(atomic_t)) % L1_CACHE_BYTES];
> +#endif
> Index: linux/mm/page_alloc.c
> diff -u linux/mm/page_alloc.c:1.1.1.3 linux/mm/page_alloc.c:1.1.2.28
> --- linux/mm/page_alloc.c:1.1.1.3	Tue Jan 26 19:32:27 1999
> +++ linux/mm/page_alloc.c	Fri Apr  2 01:12:37 1999
> @@ -315,7 +318,7 @@
>  	freepages.min = i;
>  	freepages.low = i * 2;
>  	freepages.high = i * 3;
> -	mem_map = (mem_map_t *) LONG_ALIGN(start_mem);
> +	mem_map = (mem_map_t *) L1_CACHE_ALIGN(start_mem);
>  	p = mem_map + MAP_NR(end_mem);
>  	start_mem = LONG_ALIGN((unsigned long) p);
>  	memset(mem_map, 0, start_mem - (unsigned long) mem_map);

and the irq alignment patch:

> Index: arch/i386/kernel/irq.c
> ===================================================================
> RCS file: /var/cvs/linux/arch/i386/kernel/irq.c,v
> retrieving revision 1.1.1.3
> retrieving revision 1.1.2.11
> diff -u -r1.1.1.3 -r1.1.2.11
> --- irq.c	1999/02/20 15:38:00	1.1.1.3
> +++ linux/arch/i386/kernel/irq.c	1999/04/04 01:22:53	1.1.2.11
> @@ -139,7 +139,7 @@
>  /*
>   * Controller mappings for all interrupt sources:
>   */
> -irq_desc_t irq_desc[NR_IRQS] = { [0 ... NR_IRQS-1] = { 0, &no_irq_type, }};
> +irq_desc_t irq_desc[NR_IRQS] __cacheline_aligned = { [0 ... NR_IRQS-1] = { 0, &no_irq_type, }};
>  
>  /*
> Index: arch/i386/kernel/irq.h
> ===================================================================
> RCS file: /var/cvs/linux/arch/i386/kernel/irq.h,v
> retrieving revision 1.1.1.3
> diff -u -r1.1.1.3 irq.h
> --- irq.h	1999/02/20 15:38:01	1.1.1.3
> +++ linux/arch/i386/kernel/irq.h	1999/04/01 22:53:07
> @@ -39,6 +39,9 @@
>  	struct hw_interrupt_type *handler;	/* handle/enable/disable functions */
>  	struct irqaction *action;		/* IRQ action list */
>  	unsigned int depth;			/* Disable depth for nested irq disables */
> +#ifdef __SMP__
> +	unsigned int unused[4];
> +#endif
>  } irq_desc_t;
>  
>  /*

i ran 128 concurrent scripts on our 512M PowerEdge.  each instantiation of
the script runs the same programs in the same sequence.  the script is
designed to emulate a software development workload, so it contains
commands like cpio, cc, nroff, and ed. the VM+file working set was
contained in less than 150M, so this benchmark was CPU and memory bound.

i tested 4 different kernels:

ref:  a stock 2.2.5 kernel

p-al: a stock 2.2.5 kernel with your page struct alignment patch applied

irq:  a stock 2.2.5 kernel with your irq alignment patch applied

both: a stock 2.2.5 kernel with both patches applied

all kernels were compiled using egcs-1.1.1 with the same .config and
compiler optimizations.

the benchmark numbers are average throughput in "scripts per hour" for 4
consecutive runs.  this value is computed by measuring the elapsed time
for all scripts to complete, then multiplying by the number of concurrent
scripts.  (s= is standard deviation; it indicates roughly the inter-run
variance)

ref:    4176.4  (s=27.45)

p-al:	4207.9  (s=8.1)

irq:	4228.8  (s=11.70)

both:	4207.9  (s=13.34)

the irq patch is a clear win over the reference kernel: it shows a
consistent 1.25% improvement in overall throughput, and the performance
difference is more than a standard deviation.  also, the variance appears
to be less with the irq kernel.  i would bet on a more I/O bound load the
improvement would be even more stark.

i'm not certain why the combination kernel performance was worse than the
irq-only kernel.

> >Lynch, William, "The Interaction of Virtual Memory and Cache Memory,"
> >Technical Report CSL-TR-93-587, Stanford University Department of
> >Electrical Engineering and Computer Science, October 1993.
> 
> Thanks!! but sigh, I don't have too much money to buy them right now...
> But I'll save them and I'll buy them ASAP. In the meantime I'll be in the
> hope of GPL'd docs...

"Lynch" is a PhD thesis available in postscript at Stanford's web site for
free.  it's a study of different coloring methodologies, so it's fairly
broad.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/citi-netscape/

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
