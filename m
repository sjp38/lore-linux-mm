Date: Fri, 3 Oct 2008 00:33:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/4] cpu alloc: The allocator
Message-Id: <20081003003342.4d592c1f.akpm@linux-foundation.org>
In-Reply-To: <20080929193516.278278446@quilx.com>
References: <20080929193500.470295078@quilx.com>
	<20080929193516.278278446@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Mon, 29 Sep 2008 12:35:03 -0700 Christoph Lameter <cl@linux-foundation.org> wrote:

> The per cpu allocator allows dynamic allocation of memory on all
> processors simultaneously. A bitmap is used to track used areas.
> The allocator implements tight packing to reduce the cache footprint
> and increase speed since cacheline contention is typically not a concern
> for memory mainly used by a single cpu. Small objects will fill up gaps
> left by larger allocations that required alignments.
> 
> The size of the cpu_alloc area can be changed via the percpu=xxx
> kernel parameter.
> 
>
> ...
>
> +static void set_map(int start, int length)
> +{
> +	while (length-- > 0)
> +		__set_bit(start++, cpu_alloc_map);
> +}

Can we use bitmap_fill() here?

> +/*
> + * Mark an area as freed.
> + *
> + * Must hold cpu_alloc_map_lock
> + */
> +static void clear_map(int start, int length)
> +{
> +	while (length-- > 0)
> +		__clear_bit(start++, cpu_alloc_map);
> +}

And bitmap_etc().  We have a pretty complete suite there.

> +/*
> + * Allocate an object of a certain size
> + *
> + * Returns a special pointer that can be used with CPU_PTR to find the
> + * address of the object for a certain cpu.
> + */
> +void *cpu_alloc(unsigned long size, gfp_t gfpflags, unsigned long align)
> +{
> +	unsigned long start;
> +	int units = size_to_units(size);
> +	void *ptr;
> +	int first;
> +	unsigned long flags;
> +
> +	if (!size)
> +		return ZERO_SIZE_PTR;
> +
> +	WARN_ON(align > PAGE_SIZE);
> +
> +	if (align < UNIT_SIZE)
> +		align = UNIT_SIZE;
> +
> +	spin_lock_irqsave(&cpu_alloc_map_lock, flags);
> +
> +	first = 1;
> +	start = first_free;
> +
> +	for ( ; ; ) {
> +
> +		start = find_next_zero_bit(cpu_alloc_map, nr_units, start);
> +		if (start >= nr_units)
> +			goto out_of_memory;
> +
> +		if (first)
> +			first_free = start;
> +
> +		/*
> +		 * Check alignment and that there is enough space after
> +		 * the starting unit.
> +		 */
> +		if (start % (align / UNIT_SIZE) == 0 &&
> +			find_next_bit(cpu_alloc_map, nr_units, start + 1)
> +					>= start + units)
> +				break;
> +		start++;
> +		first = 0;
> +	}

Might be able to use bitmap_find_free_region() here, if we try hard enough.

But as a general thing, it would be better to add any missing
functionality to the bitmap API and then to use the bitmap API
consistently, rather than partly using it, or ignoring it altogether.

> +	if (first)
> +		first_free = start + units;
> +
> +	if (start + units > nr_units)
> +		goto out_of_memory;
> +
> +	set_map(start, units);
> +	__count_vm_events(CPU_BYTES, units * UNIT_SIZE);
> +
> +	spin_unlock_irqrestore(&cpu_alloc_map_lock, flags);
> +
> +	ptr = (int *)__per_cpu_end + start;
> +
> +	if (gfpflags & __GFP_ZERO) {
> +		int cpu;
> +
> +		for_each_possible_cpu(cpu)
> +			memset(CPU_PTR(ptr, cpu), 0, size);
> +	}
> +
> +	return ptr;
> +
> +out_of_memory:
> +	spin_unlock_irqrestore(&cpu_alloc_map_lock, flags);
> +	return NULL;
> +}
> +EXPORT_SYMBOL(cpu_alloc);
> +

Apart from that the interface, intent and implementation seem reasonable.

But I'd have though that it would be possible to only allocate the
storage for online CPUs.  That would be a pretty significant win for
some system configurations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
