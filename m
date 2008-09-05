Date: Fri, 5 Sep 2008 19:44:49 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080905174449.GC27395@elte.hu>
References: <20080905172132.GA11692@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080905172132.GA11692@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

* Gary Hade <garyhade@us.ibm.com> wrote:

> Add memory hotremove config option to x86_64
> 
> Memory hotremove functionality can currently be configured into the 
> ia64, powerpc, and s390 kernels.  This patch makes it possible to 
> configure the memory hotremove functionality into the x86_64 kernel as 
> well.

hm, why is it for 64-bit only?

> +++ linux-2.6.27-rc5/arch/x86/Kconfig	2008-09-03 13:34:55.000000000 -0700
> @@ -1384,6 +1384,9 @@
>  	def_bool y
>  	depends on X86_64 || (X86_32 && HIGHMEM)
> 
> +config ARCH_ENABLE_MEMORY_HOTREMOVE
> +	def_bool y

so this will break the build on 32-bit, if CONFIG_MEMORY_HOTREMOVE=y? 
mm/memory_hotplug.c assumes that remove_memory() is provided by the 
architecture.

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

hm, nothing appears to be arch-specific about this trivial wrapper 
around offline_pages().

Shouldnt this be moved to the CONFIG_MEMORY_HOTREMOVE portion of 
mm/memory_hotplug.c instead, as a weak function? That way architectures 
only have to enable ARCH_ENABLE_MEMORY_HOTREMOVE - and architectures 
with different/special needs can override it.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
