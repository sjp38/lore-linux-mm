Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA06145
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 20:54:14 -0400
Date: Tue, 6 Apr 1999 02:15:46 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.BSF.4.03.9904051658150.25730-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.05.9904060128120.447-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Chuck Lever wrote:

>buckets out of 32K buckets have hundreds of buffers).  i have a new hash
>function that works very well, and even helps inter-run variance and
>perceived interactive response.  i'll post more on this soon.

Cool! ;)) But could you tell me _how_ do you design an hash function? Are
you doing math or do you use instinct? I never gone into the details of
benchmarking or designing an hash function simply because I don't like
fuzzy hash and instead I want to replace them with RB-trees all over the
place (and I know the math about RB-trees), but I like to learn how to
design an hash function anyway (even if I don't want to discover that
myself without reading docs as usual ;).

>but also the page hash function uses the hash table size as a shift value
>when computing the index, so it may combine the interesting bits in a
>different (worse) way when you change the hash table size.  i'm planning
>to instrument the page hash to see exactly what's going on.

Agreed. This is true. I thought about that and I am resizing the hash
table size to the original 11 bit now (since you are confirming that I
broken the hash function).

>IMHO, i'd think if the buffer cache has a large hash table, you'd want the
>page cache to have a table as large or larger.  both track roughly the
>same number of objects...  and the page cache is probably used more often

Agreed.

>than the buffer cache.  i can experiment with this; i've already been
>looking at this behavior for a couple of weeks.

Sure!! page cache is far more used than the buffer cache!! Also think that
most of the time with the page cache we have to do a _double_ query in
order to insert a new entry in the page cache.

>a good reason to try this is to get immediate scalability gains in terms
>of the number of objects these hash functions can handle before lookup
>time becomes unacceptible.

I am not going to spend time on fuzzy hash because my instinct tells me to
drop them.

>i agree that the whole point of the modification is to help the system
>choose the best page to get rid of -- swapping a superblock is probably a
>bad idea.  :)

The point is not to swapout it (it's not possible to swapout a buffer),
but the point is that if the unfreeable buffer will stay at the end of the
lru list, it will increase the swapping pressure because when we'll probe
the lru list we'll notice a fixed amount of unfreeable pages (and a fixed
unfreeable amount of lru_cache will mean that we have to go in swap_out()
in order to free them or to swapout something else. As just said my new
shrink_mmap() is been completly redesigned and reimplemented by me and has
nothing to do with the old one. It made perfect sense to me but I think
it's not so obvious as the old shrink_mmap()...

>someone mentioned putting these on a separate LRU list, or something like
>that.  maybe you should try that instead?  i suspect it might be cleaner
>logic?

Theorically yes, but it won't be a cleaner coding according to me. Always
putting them at the top of the lru list when we catch them browsing the
end of lru list (as I am doing now) will remove the issue without
inserting special code. And the superblock thing is not the only reason I
am handling the special "buffer-in_use" case in my shrink_mmap().

>if i can, i'd like to separate out the individual modifications and try
>them each compared to a stock kernel.  that usually shows exactly which
>changes are useful.

Fine, I can't do that myself simply because I don't have the time , but if
you want to do the finegrined testing I'll be glad to send you my code
separated and backported to 2.2.5. ;)) Thanks!!

The first thing I am interested to bench is the pagemap struct cacheline
aligned. If it won't improve performances I want to drop it because it's
causing a relevant waste of memory.

here is the pagemap L1-aligned patch against 2.2.5 (I hope to have adapted
it correctly to 2.2.5 even if it's a bit late and I drunk some beer before
came back to home ;):

--- linux/include/linux/mm.h	Tue Mar  9 01:55:28 1999
+++ mm.h	Tue Apr  6 02:00:22 1999
@@ -131,0 +133,6 @@
+#ifdef __SMP__
+	/* cacheline alignment */
+	char dummy[(sizeof(void *) * 7 +
+		    sizeof(unsigned long) * 2 +
+		    sizeof(atomic_t)) % L1_CACHE_BYTES];
+#endif
Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.3 linux/mm/page_alloc.c:1.1.2.28
--- linux/mm/page_alloc.c:1.1.1.3	Tue Jan 26 19:32:27 1999
+++ linux/mm/page_alloc.c	Fri Apr  2 01:12:37 1999
@@ -315,7 +318,7 @@
 	freepages.min = i;
 	freepages.low = i * 2;
 	freepages.high = i * 3;
-	mem_map = (mem_map_t *) LONG_ALIGN(start_mem);
+	mem_map = (mem_map_t *) L1_CACHE_ALIGN(start_mem);
 	p = mem_map + MAP_NR(end_mem);
 	start_mem = LONG_ALIGN((unsigned long) p);
 	memset(mem_map, 0, start_mem - (unsigned long) mem_map);



And here instead I extracted from my CVS tree the other thing I am not
sure about and that you was asking for (this will cause less waste of
memory but I am very courious to know how it will make differences on a
4-way SMP):

Index: arch/i386/kernel/irq.c
===================================================================
RCS file: /var/cvs/linux/arch/i386/kernel/irq.c,v
retrieving revision 1.1.1.3
retrieving revision 1.1.2.11
diff -u -r1.1.1.3 -r1.1.2.11
--- irq.c	1999/02/20 15:38:00	1.1.1.3
+++ linux/arch/i386/kernel/irq.c	1999/04/04 01:22:53	1.1.2.11
@@ -139,7 +139,7 @@
 /*
  * Controller mappings for all interrupt sources:
  */
-irq_desc_t irq_desc[NR_IRQS] = { [0 ... NR_IRQS-1] = { 0, &no_irq_type, }};
+irq_desc_t irq_desc[NR_IRQS] __cacheline_aligned = { [0 ... NR_IRQS-1] = { 0, &no_irq_type, }};
 
:wq
 
 /*
Index: arch/i386/kernel/irq.h
===================================================================
RCS file: /var/cvs/linux/arch/i386/kernel/irq.h,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 irq.h
--- irq.h	1999/02/20 15:38:01	1.1.1.3
+++ linux/arch/i386/kernel/irq.h	1999/04/01 22:53:07
@@ -39,6 +39,9 @@
 	struct hw_interrupt_type *handler;	/* handle/enable/disable functions */
 	struct irqaction *action;		/* IRQ action list */
 	unsigned int depth;			/* Disable depth for nested irq disables */
+#ifdef __SMP__
+	unsigned int unused[4];
+#endif
 } irq_desc_t;
 
 /*

>if you want to learn more about page coloring, here are some excellent
>references:
>
>Hennessy & Patterson, "Computer Architecture: A Quantitative Approach,"
>2nd edition, Morgan Kaufman Publishers, 1998.  look in the chapter on CPU
>caches (i'd cite the page number here, but my copy is at home).
>
>Lynch, William, "The Interaction of Virtual Memory and Cache Memory,"
>Technical Report CSL-TR-93-587, Stanford University Department of
>Electrical Engineering and Computer Science, October 1993.

Thanks!! but sigh, I don't have too much money to buy them right now...
But I'll save them and I'll buy them ASAP. In the meantime I'll be in the
hope of GPL'd docs...

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
