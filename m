Date: Tue, 29 Apr 2008 10:48:54 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [2/2] vmallocinfo: Add caller information
Message-ID: <20080429084854.GA14913@elte.hu>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080318222827.519656153@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> Add caller information so that /proc/vmallocinfo shows where the 
> allocation request for a slice of vmalloc memory originated.

i _specifically_ objected to the uglification that this patch brings 
with itself to the modified arch/x86 files (see the diff excerpt below), 
in:

    http://lkml.org/lkml/2008/3/19/450

i pointed out how it should be done _much cleaner_ (and much smaller - 
only a single patch needed) via stack-trace, without changing a dozen 
architectures, and even gave a patch to make it all easier for you:

    http://lkml.org/lkml/2008/3/19/568
    http://lkml.org/lkml/2008/3/21/88

in fact, a stacktrace printout is much more informative as well to 
users, than a punny __builtin_return_address(0)!

but you did not reply to my objections in substance, hence i considered 
the issue closed - but you apparently went ahead without addressing my 
concerns (which are rather obvious to anyone doing debug code) and now 
this ugly code is upstream.

If lockdep can get stacktrace samples from all around the kernel without 
adding "caller" info parameters to widely used APIs, then the MM is 
evidently able to do it too. _Saving_ a stacktrace is relatively fast 
[printing it to the console is what is slow], and vmalloc() is an utter 
slowpath anyway [and 1 million file descriptors does not count as a 
fastpath].

If performance is of any concern then make it dependent on 
CONFIG_DEBUG_VM or whatever debug switch in the MM - that will be 
_faster_ in the default case than the current 
pass-parameter-deep-down-the-arch crap you've pushed here. I dont 
remember the last time i genuinely needed the allocation site of a 
vmalloc().

I any case, do _NOT_ pollute any architectures with stack debugging 
hacks (and that holds for future similar patches too), that's why we 
wrote stacktrace. This needs to be reverted or fixed properly.

	Ingo

> Index: linux-2.6.25-rc5-mm1/arch/x86/mm/ioremap.c
> ===================================================================
> --- linux-2.6.25-rc5-mm1.orig/arch/x86/mm/ioremap.c	2008-03-18 12:20:10.803827969 -0700
> +++ linux-2.6.25-rc5-mm1/arch/x86/mm/ioremap.c	2008-03-18 12:22:09.744570798 -0700
> @@ -118,8 +118,8 @@ static int ioremap_change_attr(unsigned 
>   * have to convert them into an offset in a page-aligned mapping, but the
>   * caller shouldn't need to know that small detail.
>   */
> -static void __iomem *__ioremap(unsigned long phys_addr, unsigned long size,
> -			       enum ioremap_mode mode)
> +static void __iomem *__ioremap_caller(unsigned long phys_addr,
> +	unsigned long size, enum ioremap_mode mode, void *caller)
>  {
>  	unsigned long pfn, offset, last_addr, vaddr;
>  	struct vm_struct *area;
> @@ -176,7 +176,7 @@ static void __iomem *__ioremap(unsigned 
>  	/*
>  	 * Ok, go for it..
>  	 */
> -	area = get_vm_area(size, VM_IOREMAP);
> +	area = get_vm_area_caller(size, VM_IOREMAP, caller);
>  	if (!area)
>  		return NULL;
>  	area->phys_addr = phys_addr;
> @@ -217,13 +217,15 @@ static void __iomem *__ioremap(unsigned 
>   */
>  void __iomem *ioremap_nocache(unsigned long phys_addr, unsigned long size)
>  {
> -	return __ioremap(phys_addr, size, IOR_MODE_UNCACHED);
> +	return __ioremap_caller(phys_addr, size, IOR_MODE_UNCACHED,
> +						__builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(ioremap_nocache);
>  
>  void __iomem *ioremap_cache(unsigned long phys_addr, unsigned long size)
>  {
> -	return __ioremap(phys_addr, size, IOR_MODE_CACHED);
> +	return __ioremap_caller(phys_addr, size, IOR_MODE_CACHED,
> +						__builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(ioremap_cache);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
