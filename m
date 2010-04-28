Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 451AB6B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 18:40:37 -0400 (EDT)
Date: Wed, 28 Apr 2010 15:40:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] - Randomize node rotor used in
 cpuset_mem_spread_node()
Message-Id: <20100428154034.fb823484.akpm@linux-foundation.org>
In-Reply-To: <20100428150432.GA3137@sgi.com>
References: <20100428131158.GA2648@sgi.com>
	<20100428150432.GA3137@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 10:04:32 -0500
Jack Steiner <steiner@sgi.com> wrote:

> Some workloads that create a large number of small files tend to assign
> too many pages to node 0 (multi-node systems). Part of the reason is that
> the rotor (in cpuset_mem_spread_node()) used to assign nodes starts
> at node 0 for newly created tasks.

And, presumably, your secret testcase forks lots of subprocesses which
do the file creation?

> This patch changes the rotor to be initialized to a random node number
> of the cpuset.

Why random as opposed to, say, inherit-rotor-from-parent?

> Index: linux/arch/x86/mm/numa.c
> ===================================================================
> --- linux.orig/arch/x86/mm/numa.c	2010-04-28 09:44:52.422898844 -0500
> +++ linux/arch/x86/mm/numa.c	2010-04-28 09:49:39.282899779 -0500
> @@ -2,6 +2,7 @@
>  #include <linux/topology.h>
>  #include <linux/module.h>
>  #include <linux/bootmem.h>
> +#include <linux/random.h>
>  
>  #ifdef CONFIG_DEBUG_PER_CPU_MAPS
>  # define DBG(x...) printk(KERN_DEBUG x)
> @@ -65,3 +66,19 @@ const struct cpumask *cpumask_of_node(in
>  }
>  EXPORT_SYMBOL(cpumask_of_node);
>  #endif
> +
> +/*
> + * Return the bit number of a random bit set in the nodemask.
> + *   (returns -1 if nodemask is empty)
> + */
> +int __node_random(const nodemask_t *maskp)
> +{
> +	int w, bit = -1;
> +
> +	w = nodes_weight(*maskp);
> +	if (w)
> +		bit = bitmap_find_nth_bit(maskp->bits,
> +			get_random_int() % w, MAX_NUMNODES);
> +	return bit;
> +}
> +EXPORT_SYMBOL(__node_random);

I suspect random32() would suffice here.  It avoids depleting the
entropy pool altogether.

> +
> +/**
> + * bitmap_find_nth_bit(buf, ord, bits)
> + *	@buf: pointer to bitmap
> + *	@n: ordinal bit position (n-th set bit, n >= 0)
> + * @nbits: number of bits in the bitmap
> + *
> + * find the Nth bit that is set in the bitmap
> + * Value of @n should be in range 0 <= @n < weight(buf), else
> + * results are undefined.
> + *
> + * The bit positions 0 through @bits are valid positions in @buf.
> + */
> +int bitmap_find_nth_bit(const unsigned long *bitmap, int n, int bits)
> +{
> +	return bitmap_ord_to_pos(bitmap, n, bits);
> +}
> +EXPORT_SYMBOL(bitmap_find_nth_bit);

This does nothing apart from consume more stack?  Better to rename
bitmap_ord_to_pos() and export it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
