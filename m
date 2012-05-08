Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6D2DD6B00E9
	for <linux-mm@kvack.org>; Tue,  8 May 2012 10:08:57 -0400 (EDT)
Date: Tue, 8 May 2012 09:08:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Using judgement !!c  to judge per cpu has obj in
 fucntion has_cpu_slab().
In-Reply-To: <201205080931539844949@gmail.com>
Message-ID: <alpine.DEB.2.00.1205080905040.25669@router.home>
References: <201205080931539844949@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: gilad <gilad@benyossef.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>

On Tue, 8 May 2012, majianpeng wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index ffe13fd..6fce08f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
>  	struct kmem_cache *s = info;
>  	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
>
> -	return !!(c->page);
> +	return !!c;
>  }

Dont do that. This will always return true since c will never be NULL. The
check is pointless then and you have essentially reverted the patch to
slub that avoids the IPI. Reverting
commit a8364d5555b2030d093cde0f07951628e55454e1 should have the same
effect.

This issue suggests some sort of race condition that results in not
releasing the per cpu slab or the population of the per cpu slab after
the check was done.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
