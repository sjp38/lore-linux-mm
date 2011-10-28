Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 82C616B002E
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 00:06:46 -0400 (EDT)
Date: Thu, 27 Oct 2011 23:06:41 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH v2 5/6] slub: Only IPI CPUs that have per cpu obj to
 flush
In-Reply-To: <1319385413-29665-6-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1110272257040.14619@router.home>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com> <1319385413-29665-6-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Sun, 23 Oct 2011, Gilad Ben-Yossef wrote:

> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index f58d641..b130f61 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -102,6 +102,9 @@ struct kmem_cache {
>  	 */
>  	int remote_node_defrag_ratio;
>  #endif
> +
> +	/* Which CPUs hold local slabs for this cache. */
> +	cpumask_var_t cpus_with_slabs;
>  	struct kmem_cache_node *node[MAX_NUMNODES];
>  };

Please do not add fields to structures for passing parameters to
functions. This just increases the complexity of the patch and extends a
structures needlessly.

> diff --git a/mm/slub.c b/mm/slub.c
> index 7c54fe8..f8cbf2d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1948,7 +1948,18 @@ static void flush_cpu_slab(void *d)
>
>  static void flush_all(struct kmem_cache *s)
>  {
> -	on_each_cpu(flush_cpu_slab, s, 1);
> +	struct kmem_cache_cpu *c;
> +	int cpu;
> +
> +	for_each_online_cpu(cpu) {
> +		c = per_cpu_ptr(s->cpu_slab, cpu);
> +		if (c && c->page)
> +			cpumask_set_cpu(cpu, s->cpus_with_slabs);
> +		else
> +			cpumask_clear_cpu(cpu, s->cpus_with_slabs);
> +	}
> +
> +	on_each_cpu_mask(s->cpus_with_slabs, flush_cpu_slab, s, 1);
>  }


You do not need s->cpus_with_slabs to be in kmem_cache. Make it a local
variable instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
