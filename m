Message-ID: <47AA2955.50502@cosmosbay.com>
Date: Wed, 06 Feb 2008 22:40:37 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: SLUB: statistics improvements
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com> <20080206001948.6f749aa8.akpm@linux-foundation.org> <Pine.LNX.4.64.0802061259490.26108@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802061259490.26108@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> SLUB: statistics improvements
> 
> - Fix indentation in unfreeze_slab
> 
> - FREE_SLAB/ALLOC_SLAB counters were slightly misplaced and counted
>   even if the slab was kept because we were below the mininum of
>   partial slabs.
> 
> - Export per cpu statistics to user space (follow numa convention
>   but change the n character to c (no slabinfo support for display yet)
> 
> F.e.
> 
> christoph@stapp:/sys/kernel/slab/kmalloc-8$ cat alloc_fastpath
> 9968 c0=4854 c1=1050 c2=468 c3=190 c4=116 c5=1779 c6=185 c7=1326

nice :)

> 
> 
> +static int show_stat(struct kmem_cache *s, char *buf, enum stat_item si)
> +{
> +	unsigned long sum  = 0;
> +	int cpu;
> +	int len;
> +	int *data = kmalloc(nr_cpu_ids * sizeof(int), GFP_KERNEL);
> +
> +	if (!data)
> +		return -ENOMEM;
> +
> +	for_each_online_cpu(cpu) {
> +		int x = get_cpu_slab(s, cpu)->stat[si];

unsigned int x = ...

> +
> +		data[cpu] = x;
> +		sum += x;

or else x will sign extend here on 64 bit arches ?

> +	}
> +
> +	len = sprintf(buf, "%lu", sum);
> +
> +	for_each_online_cpu(cpu) {
> +		if (data[cpu] && len < PAGE_SIZE - 20)
> +			len += sprintf(buf + len, " c%d=%u", cpu, data[cpu]);
> +	}
> +	kfree(data);
> +	return len + sprintf(buf + len, "\n");
> +}
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
