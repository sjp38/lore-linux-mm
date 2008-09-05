Date: Fri, 05 Sep 2008 12:02:31 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Add memory hotremove config option to x86_64
In-Reply-To: <20080904202153.GA26795@us.ibm.com>
References: <20080904202153.GA26795@us.ibm.com>
Message-Id: <20080905115721.6758.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Looks good to me.

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Thanks.

> 
> Add memory hotremove config option to x86_64
> 
> Memory hotremove functionality can currently be configured into
> the ia64, powerpc, and s390 kernels.  This patch makes it possible
> to configure the memory hotremove functionality into the x86_64
> kernel as well. 
> 
> Signed-off-by: Gary Hade <garyhade@us.ibm.com>
> 
> ---
>  arch/x86/Kconfig      |    3 +++
>  arch/x86/mm/init_64.c |   18 ++++++++++++++++++
>  2 files changed, 21 insertions(+)
> 
> Index: linux-2.6.27-rc5/arch/x86/Kconfig
> ===================================================================
> --- linux-2.6.27-rc5.orig/arch/x86/Kconfig	2008-09-03 13:33:59.000000000 -0700
> +++ linux-2.6.27-rc5/arch/x86/Kconfig	2008-09-03 13:34:55.000000000 -0700
> @@ -1384,6 +1384,9 @@
>  	def_bool y
>  	depends on X86_64 || (X86_32 && HIGHMEM)
>  
> +config ARCH_ENABLE_MEMORY_HOTREMOVE
> +	def_bool y
> +
>  config HAVE_ARCH_EARLY_PFN_TO_NID
>  	def_bool X86_64
>  	depends on NUMA
> Index: linux-2.6.27-rc5/arch/x86/mm/init_64.c
> ===================================================================
> --- linux-2.6.27-rc5.orig/arch/x86/mm/init_64.c	2008-09-03 13:34:08.000000000 -0700
> +++ linux-2.6.27-rc5/arch/x86/mm/init_64.c	2008-09-03 13:34:55.000000000 -0700
> @@ -740,6 +740,24 @@
>  EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>  #endif
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int remove_memory(u64 start, u64 size)
> +{
> +	unsigned long start_pfn, end_pfn;
> +	unsigned long timeout = 120 * HZ;
> +	int ret;
> +	start_pfn = start >> PAGE_SHIFT;
> +	end_pfn = start_pfn + (size >> PAGE_SHIFT);
> +	ret = offline_pages(start_pfn, end_pfn, timeout);
> +	if (ret)
> +		goto out;
> +	/* Arch-specific calls go here */
> +out:
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(remove_memory);
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
> +
>  #endif /* CONFIG_MEMORY_HOTPLUG */
>  
>  /*

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
