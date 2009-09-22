Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 181D96B004D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 20:02:35 -0400 (EDT)
Message-ID: <4AB813F3.8060102@kernel.org>
Date: Tue, 22 Sep 2009 09:01:55 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] powerpc: Allocate per-cpu areas for node IDs for
 SLQB to use as per-node areas
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <1253549426-917-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1253549426-917-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hello,

Mel Gorman wrote:
> diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
> index 1f68160..a5f52d4 100644
> --- a/arch/powerpc/kernel/setup_64.c
> +++ b/arch/powerpc/kernel/setup_64.c
> @@ -588,6 +588,26 @@ void __init setup_per_cpu_areas(void)
>  		paca[i].data_offset = ptr - __per_cpu_start;
>  		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
>  	}
> +#ifdef CONFIG_SLQB
> +	/* 
> +	 * SLQB abuses DEFINE_PER_CPU to setup a per-node area. This trick
> +	 * assumes that ever node ID will have a CPU of that ID to match.
> +	 * On systems with memoryless nodes, this may not hold true. Hence,
> +	 * we take a second pass initialising a "per-cpu" area for node-ids
> +	 * that SLQB can use
> +	 */
> +	for_each_node_state(i, N_NORMAL_MEMORY) {
> +
> +		/* Skip node IDs that a valid CPU id exists for */
> +		if (paca[i].data_offset)
> +			continue;
> +
> +		ptr = alloc_bootmem_pages_node(NODE_DATA(cpu_to_node(i)), size);
> +
> +		paca[i].data_offset = ptr - __per_cpu_start;
> +		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
> +	}
> +#endif /* CONFIG_SLQB */
>  }
>  #endif

Eh... I don't know.  This seems too hacky to me.  Why not just
allocate pointer array of MAX_NUMNODES and allocate per-node memory
there?  This will be slightly more expensive but I doubt it will be
noticeable.  The only extra overhead is the cachline footprint for the
extra array.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
