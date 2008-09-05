Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85IEpnB016497
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 14:14:51 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85IEYbP195974
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 12:14:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85IEXfT030708
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 12:14:34 -0600
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080905174449.GC27395@elte.hu>
References: <20080905172132.GA11692@us.ibm.com>
	 <20080905174449.GC27395@elte.hu>
Content-Type: text/plain
Date: Fri, 05 Sep 2008 11:14:38 -0700
Message-Id: <1220638478.25932.20.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-09-05 at 19:44 +0200, Ingo Molnar wrote:
> * Gary Hade <garyhade@us.ibm.com> wrote:
> 
> > Add memory hotremove config option to x86_64
> > 
> > Memory hotremove functionality can currently be configured into the 
> > ia64, powerpc, and s390 kernels.  This patch makes it possible to 
> > configure the memory hotremove functionality into the x86_64 kernel as 
> > well.
> 
> hm, why is it for 64-bit only?
> 
> > +++ linux-2.6.27-rc5/arch/x86/Kconfig	2008-09-03 13:34:55.000000000 -0700
> > @@ -1384,6 +1384,9 @@
> >  	def_bool y
> >  	depends on X86_64 || (X86_32 && HIGHMEM)
> > 
> > +config ARCH_ENABLE_MEMORY_HOTREMOVE
> > +	def_bool y
> 
> so this will break the build on 32-bit, if CONFIG_MEMORY_HOTREMOVE=y? 
> mm/memory_hotplug.c assumes that remove_memory() is provided by the 
> architecture.
> 
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +int remove_memory(u64 start, u64 size)
> > +{
> > +	unsigned long start_pfn, end_pfn;
> > +	unsigned long timeout = 120 * HZ;
> > +	int ret;
> > +	start_pfn = start >> PAGE_SHIFT;
> > +	end_pfn = start_pfn + (size >> PAGE_SHIFT);
> > +	ret = offline_pages(start_pfn, end_pfn, timeout);
> > +	if (ret)
> > +		goto out;
> > +	/* Arch-specific calls go here */
> > +out:
> > +	return ret;
> > +}
> > +EXPORT_SYMBOL_GPL(remove_memory);
> > +#endif /* CONFIG_MEMORY_HOTREMOVE */
> 
> hm, nothing appears to be arch-specific about this trivial wrapper 
> around offline_pages().

Yes. All the archs (ppc64, ia64, s390, x86_64) have exact same
function. No architecture needed special handling so far (initial
versions of ppc64 needed extra handling, but I moved the code
to different place). 

We can make this generic and kill all arch-specific ones.
Initially, we didn't know if any arch needs special handling -
so ended up having private functions for each arch.  
I think its time to merge them all.

> 
> Shouldnt this be moved to the CONFIG_MEMORY_HOTREMOVE portion of 
> mm/memory_hotplug.c instead, as a weak function? That way architectures 
> only have to enable ARCH_ENABLE_MEMORY_HOTREMOVE - and architectures 
> with different/special needs can override it.

Yes. We should do that. I will send out a patch.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
