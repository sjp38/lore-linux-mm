Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6F1A06B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 20:45:35 -0400 (EDT)
Message-ID: <1340930720.2563.5.camel@pasglop>
Subject: Re: [PATCH powerpc 2/2] kfree the cache name  of pgtable cache if
 SLUB is used
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 29 Jun 2012 10:45:20 +1000
In-Reply-To: <1340618099.13778.39.camel@ThinkPad-T420>
References: <1340617984.13778.37.camel@ThinkPad-T420>
	 <1340618099.13778.39.camel@ThinkPad-T420>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

On Mon, 2012-06-25 at 17:54 +0800, Li Zhong wrote:

> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index 620b7ac..c9d2a7f 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -130,6 +130,9 @@ void pgtable_cache_add(unsigned shift, void
> (*ctor)(void *))
>  	align = max_t(unsigned long, align, minalign);
>  	name = kasprintf(GFP_KERNEL, "pgtable-2^%d", shift);
>  	new = kmem_cache_create(name, table_size, align, 0, ctor);
> +#ifdef CONFIG_SLUB
> +	kfree(name); /* SLUB duplicates the cache name */
> +#endif
>  	PGT_CACHE(shift) = new;
>  
>  	pr_debug("Allocated pgtable cache for order %d\n", shift);

This is very gross ... and fragile. Also the subtle difference in
semantics between SLUB and SLAB is a VERY BAD IDEA.

I reckon you should make the other allocators all copy the name
instead.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
