Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 08BF18D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 18:41:39 -0500 (EST)
Subject: Re: [PATCH 3/4]Define memory_block_size_bytes for powerpc/pseries
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4D3866A0.6010803@austin.ibm.com>
References: <4D386498.9080201@austin.ibm.com>
	 <4D3866A0.6010803@austin.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Feb 2011 10:39:23 +1100
Message-ID: <1297035563.14982.15.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: Greg KH <greg@kroah.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>

On Thu, 2011-01-20 at 10:45 -0600, Nathan Fontenot wrote:
> Define a version of memory_block_size_bytes() for powerpc/pseries such that
> a memory block spans an entire lmb.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> Reviewed-by: Robin Holt <holt@sgi.com>

Hi Nathan !

Is somebody from -mm picking the rest of the series ? This patch as well
or shall I wait for the first two to go in and then pick that one in
-powerpc ?

Cheers,
Ben.

> ---
>  arch/powerpc/platforms/pseries/hotplug-memory.c |   66 +++++++++++++++++++-----
>  1 file changed, 53 insertions(+), 13 deletions(-)
> 
> Index: linux-2.6/arch/powerpc/platforms/pseries/hotplug-memory.c
> ===================================================================
> --- linux-2.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2011-01-20 08:18:21.000000000 -0600
> +++ linux-2.6/arch/powerpc/platforms/pseries/hotplug-memory.c	2011-01-20 08:21:07.000000000 -0600
> @@ -17,6 +17,54 @@
>  #include <asm/pSeries_reconfig.h>
>  #include <asm/sparsemem.h>
>  
> +static unsigned long get_memblock_size(void)
> +{
> +	struct device_node *np;
> +	unsigned int memblock_size = 0;
> +
> +	np = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
> +	if (np) {
> +		const unsigned long *size;
> +
> +		size = of_get_property(np, "ibm,lmb-size", NULL);
> +		memblock_size = size ? *size : 0;
> +
> +		of_node_put(np);
> +	} else {
> +		unsigned int memzero_size = 0;
> +		const unsigned int *regs;
> +
> +		np = of_find_node_by_path("/memory@0");
> +		if (np) {
> +			regs = of_get_property(np, "reg", NULL);
> +			memzero_size = regs ? regs[3] : 0;
> +			of_node_put(np);
> +		}
> +
> +		if (memzero_size) {
> +			/* We now know the size of memory@0, use this to find
> +			 * the first memoryblock and get its size.
> +			 */
> +			char buf[64];
> +
> +			sprintf(buf, "/memory@%x", memzero_size);
> +			np = of_find_node_by_path(buf);
> +			if (np) {
> +				regs = of_get_property(np, "reg", NULL);
> +				memblock_size = regs ? regs[3] : 0;
> +				of_node_put(np);
> +			}
> +		}
> +	}
> +
> +	return memblock_size;
> +}
> +
> +unsigned long memory_block_size_bytes(void)
> +{
> +	return get_memblock_size();
> +}
> +
>  static int pseries_remove_memblock(unsigned long base, unsigned int memblock_size)
>  {
>  	unsigned long start, start_pfn;
> @@ -127,30 +175,22 @@ static int pseries_add_memory(struct dev
>  
>  static int pseries_drconf_memory(unsigned long *base, unsigned int action)
>  {
> -	struct device_node *np;
> -	const unsigned long *lmb_size;
> +	unsigned long memblock_size;
>  	int rc;
>  
> -	np = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
> -	if (!np)
> +	memblock_size = get_memblock_size();
> +	if (!memblock_size)
>  		return -EINVAL;
>  
> -	lmb_size = of_get_property(np, "ibm,lmb-size", NULL);
> -	if (!lmb_size) {
> -		of_node_put(np);
> -		return -EINVAL;
> -	}
> -
>  	if (action == PSERIES_DRCONF_MEM_ADD) {
> -		rc = memblock_add(*base, *lmb_size);
> +		rc = memblock_add(*base, memblock_size);
>  		rc = (rc < 0) ? -EINVAL : 0;
>  	} else if (action == PSERIES_DRCONF_MEM_REMOVE) {
> -		rc = pseries_remove_memblock(*base, *lmb_size);
> +		rc = pseries_remove_memblock(*base, memblock_size);
>  	} else {
>  		rc = -EINVAL;
>  	}
>  
> -	of_node_put(np);
>  	return rc;
>  }
>  
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
