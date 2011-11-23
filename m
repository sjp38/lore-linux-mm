Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 86DD46B00A7
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 01:23:51 -0500 (EST)
Received: by faas10 with SMTP id s10so1726751faa.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:23:47 -0800 (PST)
Date: Wed, 23 Nov 2011 08:23:31 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH v4 4/5] slub: Only IPI CPUs that have per cpu obj to
 flush
In-Reply-To: <1321960128-15191-5-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.LFD.2.02.1111230822270.1773@tux.localdomain>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com> <1321960128-15191-5-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, apkm@linux-foundation.org

On Tue, 22 Nov 2011, Gilad Ben-Yossef wrote:
> static void flush_all(struct kmem_cache *s)
> {
> -	on_each_cpu(flush_cpu_slab, s, 1);
> +	cpumask_var_t cpus;
> +	struct kmem_cache_cpu *c;
> +	int cpu;
> +
> +	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {

__GFP_NOWARN too maybe?

> +		for_each_online_cpu(cpu) {
> +			c = per_cpu_ptr(s->cpu_slab, cpu);
> +			if (c->page)
> +				cpumask_set_cpu(cpu, cpus);
> +		}
> +		on_each_cpu_mask(cpus, flush_cpu_slab, s, 1);
> +		free_cpumask_var(cpus);
> +	} else
> +		on_each_cpu(flush_cpu_slab, s, 1);
> }

Acked-by: Pekka Enberg <penberg@kernel.org>

I can't take the patch because it depends on a new API introduced in the 
first patch.

I'm CC'ing Andrew.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
