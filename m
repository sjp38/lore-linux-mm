Date: Tue, 13 Feb 2007 00:04:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
Message-Id: <20070213000411.a6d76e0c.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Feb 2007 10:16:23 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> +static unsigned long determine_dirtyable_memory(void)
> +{
> +	unsigned long x;
> +
> +#ifndef CONFIG_HIGHMEM
> +	x = global_page_state(NR_FREE_PAGES)
> +		+ global_page_state(NR_INACTIVE)
> +		+ global_page_state(NR_ACTIVE);
> +#else
> +	/*
> +	 * We always exclude high memory from our count
> +	 */
> +#if defined(CONFIG_NUMA) && defined(CONFIG_X86_32)
> +	/*
> +	 * i386 32 bit NUMA configurations have all non HIGHMEM zones on
> +	 * node 0. So its easier to just add up the lowmemt zones on node 0.
> +	 */
> +	struct zone * z;
> +
> +	x = 0;
> +	for (z = NODE_DATA(0)->node_zones;
> +			z < NODE_DATA(0)->node_zones + ZONE_HIGHMEM;
> +			z++)
> +		x = zone_page_state(z, NR_FREE_PAGES)
> +			+ zone_page_state(z, NR_INACTIVE)
> +			+ zone_page_state(z, NR_ACTIVE);
> +
> +#else
> +	/*
> +	 * Just subtract the HIGHMEM zones.
> +	 */
> +	int node;
> +
> +	x = global_page_state(NR_FREE_PAGES)
> +		+ global_page_state(NR_INACTIVE)
> +		+ global_page_state(NR_ACTIVE);
> +
> +	for_each_online_node(node) {
> +		struct zone *z =
> +			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
> +
> +		x -= zone_page_state(z, NR_FREE_PAGES)
> +			+ zone_page_state(z, NR_INACTIVE)
> +			+ zone_page_state(z, NR_ACTIVE);
> +	}
> +
> +#endif
> +#endif /* CONFIG_HIGHMEM */
> +	return x;
> +}

gaaack.

If CONFIG_HIGHMEM=n and CONFIG_NUMA=n, that definition of `node' is going
to come after the calculation of `x' and is going to spit a warning.

And we'll run global_page_state() six times where three would have
sufficed.

Also I think you'll be wanting a += in that first loop.

I believe i386 NUMA is rare as hen's teeth and perhaps we can just forget
about optimising for it.

Wanna have another go at this?  Perhaps split it into separate functions or
something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
