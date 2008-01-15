Subject: Re: [PATCH 08/10] x86: Change NR_CPUS arrays in numa_64 V2
From: Andi Kleen <andi@firstfloor.org>
References: <20080115021735.779102000@sgi.com>
	<20080115021737.228970000@sgi.com>
Date: Tue, 15 Jan 2008 11:54:12 +0100
In-Reply-To: <20080115021737.228970000@sgi.com> (travis@sgi.com's message of "Mon\, 14 Jan 2008 18\:17\:43 -0800")
Message-ID: <p73wsqbl5pn.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

travis@sgi.com writes:
> +
>  /* Returns the number of the node containing CPU 'cpu' */
>  static inline int cpu_to_node(int cpu)
>  {
> -	return cpu_to_node_map[cpu];
> +	u16 *cpu_to_node_map = x86_cpu_to_node_map_early_ptr;
> +
> +	if (cpu_to_node_map)
> +		return cpu_to_node_map[cpu];
> +	else if(per_cpu_offset(cpu))
> +		return per_cpu(x86_cpu_to_node_map, cpu);
> +	else
> +		return NUMA_NO_NODE;

Seems a little big now to be still inlined.

Also I wonder if there are really that many early callers that it
isn't feasible to just convert them to a early_cpu_to_node(). Also
early_cpu_to_node() should really not be speed critical, so just
linearly searching some other table instead of setting up an explicit
array should be fine for that.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
