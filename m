Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DEC4D6B022A
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 16:08:49 -0400 (EDT)
Date: Thu, 29 Apr 2010 15:08:46 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH v2] - Randomize node rotor used in
	cpuset_mem_spread_node()
Message-ID: <20100429200846.GA8929@sgi.com>
References: <20100428131158.GA2648@sgi.com> <20100428150432.GA3137@sgi.com> <20100428154034.fb823484.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428154034.fb823484.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 03:40:34PM -0700, Andrew Morton wrote:
> On Wed, 28 Apr 2010 10:04:32 -0500
> Jack Steiner <steiner@sgi.com> wrote:
> 
> > Some workloads that create a large number of small files tend to assign
> > too many pages to node 0 (multi-node systems). Part of the reason is that
> > the rotor (in cpuset_mem_spread_node()) used to assign nodes starts
> > at node 0 for newly created tasks.
> 
> And, presumably, your secret testcase forks lots of subprocesses which
> do the file creation?

We've seen this on several workloads. None were contrived - just standard benchmarks
that use tasks/scripts to create a large number of files. I have not looked
in detail at the tasks/scripts. It seemed desirable to have each new
task start with a random value in the rotor. That would provide
the best randomness.


> 
> > This patch changes the rotor to be initialized to a random node number
> > of the cpuset.
> 
> Why random as opposed to, say, inherit-rotor-from-parent?

I was concerned that inherit-from-parant might not be effective if the
files were created using a single task that forked child processes to create
the files. Each child would inherit the same rotor value.


> 
> > Index: linux/arch/x86/mm/numa.c
> > ===================================================================
> > --- linux.orig/arch/x86/mm/numa.c	2010-04-28 09:44:52.422898844 -0500
> > +++ linux/arch/x86/mm/numa.c	2010-04-28 09:49:39.282899779 -0500
> > @@ -2,6 +2,7 @@
> >  #include <linux/topology.h>
> >  #include <linux/module.h>
> >  #include <linux/bootmem.h>
> > +#include <linux/random.h>
> >  
> >  #ifdef CONFIG_DEBUG_PER_CPU_MAPS
> >  # define DBG(x...) printk(KERN_DEBUG x)
> > @@ -65,3 +66,19 @@ const struct cpumask *cpumask_of_node(in
> >  }
> >  EXPORT_SYMBOL(cpumask_of_node);
> >  #endif
> > +
> > +/*
> > + * Return the bit number of a random bit set in the nodemask.
> > + *   (returns -1 if nodemask is empty)
> > + */
> > +int __node_random(const nodemask_t *maskp)
> > +{
> > +	int w, bit = -1;
> > +
> > +	w = nodes_weight(*maskp);
> > +	if (w)
> > +		bit = bitmap_find_nth_bit(maskp->bits,
> > +			get_random_int() % w, MAX_NUMNODES);
> > +	return bit;
> > +}
> > +EXPORT_SYMBOL(__node_random);
> 
> I suspect random32() would suffice here.  It avoids depleting the
> entropy pool altogether.
> 
> > +
> > +/**
> > + * bitmap_find_nth_bit(buf, ord, bits)
> > + *	@buf: pointer to bitmap
> > + *	@n: ordinal bit position (n-th set bit, n >= 0)
> > + * @nbits: number of bits in the bitmap
> > + *
> > + * find the Nth bit that is set in the bitmap
> > + * Value of @n should be in range 0 <= @n < weight(buf), else
> > + * results are undefined.
> > + *
> > + * The bit positions 0 through @bits are valid positions in @buf.
> > + */
> > +int bitmap_find_nth_bit(const unsigned long *bitmap, int n, int bits)
> > +{
> > +	return bitmap_ord_to_pos(bitmap, n, bits);
> > +}
> > +EXPORT_SYMBOL(bitmap_find_nth_bit);
> 
> This does nothing apart from consume more stack?  Better to rename
> bitmap_ord_to_pos() and export it.

Agree. Not sure why I did it that way. Fixed in next version of the patch.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
