Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E1AE6B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:57:49 -0400 (EDT)
Date: Fri, 1 Oct 2010 13:57:46 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 8/9] v3 Define memory_block_size_bytes for x86_64 with
 CONFIG_X86_UV set
Message-ID: <20101001185746.GO14064@sgi.com>
References: <4CA62700.7010809@austin.ibm.com>
 <4CA62A51.70807@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA62A51.70807@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2010 at 01:37:05PM -0500, Nathan Fontenot wrote:
> Define a version of memory_block_size_bytes for x86_64 when CONFIG_X86_UV is
> set.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
> Signed-off-by: Jack Steiner <steiner@sgi.com>

I think this technically needs a Signed-off-by: <you> since you
are passing it upstream.

> 
> ---
>  arch/x86/mm/init_64.c |   14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> Index: linux-next/arch/x86/mm/init_64.c
> ===================================================================
> --- linux-next.orig/arch/x86/mm/init_64.c	2010-09-29 14:56:25.000000000 -0500
> +++ linux-next/arch/x86/mm/init_64.c	2010-10-01 13:00:50.000000000 -0500
> @@ -51,6 +51,7 @@
>  #include <asm/numa.h>
>  #include <asm/cacheflush.h>
>  #include <asm/init.h>
> +#include <asm/uv/uv.h>
>  #include <linux/bootmem.h>
>  
>  static int __init parse_direct_gbpages_off(char *arg)
> @@ -902,6 +903,19 @@
>  	return NULL;
>  }
>  
> +#ifdef CONFIG_X86_UV
> +#define MIN_MEMORY_BLOCK_SIZE   (1 << SECTION_SIZE_BITS)
> +
> +unsigned long memory_block_size_bytes(void)
> +{
> +	if (is_uv_system()) {
> +		printk(KERN_INFO "UV: memory block size 2GB\n");
> +		return 2UL * 1024 * 1024 * 1024;
> +	}
> +	return MIN_MEMORY_BLOCK_SIZE;
> +}
> +#endif
> +
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
>  /*
>   * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
