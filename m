Received: from midway.site ([71.117.233.155]) by xenotime.net for <linux-mm@kvack.org>; Tue, 29 Aug 2006 17:34:35 -0700
Date: Tue, 29 Aug 2006 17:37:58 -0700
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
Message-Id: <20060829173758.07c9a3eb.rdunlap@xenotime.net>
In-Reply-To: <1156865354.5408.51.camel@localhost.localdomain>
References: <20060828154413.E05721BD@localhost.localdomain>
	<20060828154417.D9D3FB1F@localhost.localdomain>
	<20060828154413.E05721BD@localhost.localdomain>
	<20060828154416.09E64946@localhost.localdomain>
	<20060828154413.E05721BD@localhost.localdomain>
	<20060828154414.38AEDAA2@localhost.localdomain>
	<20060828154413.E05721BD@localhost.localdomain>
	<20060829024618.GA8660@localhost.hsdv.com>
	<1156865354.5408.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Aug 2006 08:29:14 -0700 Dave Hansen wrote:

> On Tue, 2006-08-29 at 11:46 +0900, Paul Mundt wrote:
> > On Mon, Aug 28, 2006 at 08:44:13AM -0700, Dave Hansen wrote:
> > > diff -puN include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure include/asm-generic/page.h
> > > --- threadalloc/include/asm-generic/page.h~generic-PAGE_SIZE-infrastructure	2006-08-25 11:34:22.000000000 -0700
> > > +++ threadalloc-dave/include/asm-generic/page.h	2006-08-25 11:34:22.000000000 -0700
> > [snip]
> > > + */
> > > +#define PAGE_MASK      (~((1 << PAGE_SHIFT) - 1))
> > > +#endif /* CONFIG_ARCH_GENERIC_PAGE_SIZE */
> > >  
> > >  /* Pure 2^n version of get_order */
> > >  static __inline__ __attribute_const__ int get_order(unsigned long size)
> > > @@ -20,7 +48,6 @@ static __inline__ __attribute_const__ in
> > >  	return order;
> > >  }
> > >  
> > You've not handled the case for platforms that have their own
> > get_order()
> ...
> > You may wish to consider the HAVE_ARCH_GET_ORDER patch I sent to
> > linux-arch, it was intended to handle this.
> 
> Gah.  I managed to leave that one off of the end of my series.  However,
> I don't think this is a case where HAVE_ARCH_GET_ORDER is too much of a
> disease.
> 
> Linus requested these:
> 
> > >       /*
> > >        * We have a very complex xyzzy, we don't even want to
> > >        * inline it!
> > >        */
> > >       extern void xyxxy(...);
> > >
> > >       /* Tell the rest of the world that we do it! */
> > >       #define xyzzy xyzzy
> 
> And I find them really hard to follow.  But, maybe those were just done
> badly.  Here's the patch that I have for now.  I'll go back and try to
> Linusify it. ;)
> 
> I think get_order() is going to have to move out of generic/page.h,
> though.
> 
> -- Dave
> 
> diff -puN include/asm-generic/page.h~Re-_RFC_PATCH_unify_all_architecture_PAGE_SIZE_definitions include/asm-generic/page.h
> --- threadalloc/include/asm-generic/page.h~Re-_RFC_PATCH_unify_all_architecture_PAGE_SIZE_definitions	2006-08-28 09:15:31.000000000 -0700
> +++ threadalloc-dave/include/asm-generic/page.h	2006-08-28 09:15:35.000000000 -0700
> @@ -33,6 +33,7 @@
>  #define PAGE_MASK      (~((1 << PAGE_SHIFT) - 1))
>  
>  #ifndef __ASSEMBLY__
> +#ifndef CONFIG_ARCH_HAVE_GET_ORDER
>  /* Pure 2^n version of get_order */
>  static __inline__ __attribute_const__ int get_order(unsigned long size)
>  {
> @@ -46,6 +47,7 @@ static __inline__ __attribute_const__ in
>  	} while (size);
>  	return order;
>  }
> +#endif /* CONFIG_ARCH_HAVE_GET_ORDER */
>  #endif /* __ASSEMBLY__ */
>  
>  #endif	/* __KERNEL__ */
> diff -puN mm/Kconfig~Re-_RFC_PATCH_unify_all_architecture_PAGE_SIZE_definitions mm/Kconfig
> --- threadalloc/mm/Kconfig~Re-_RFC_PATCH_unify_all_architecture_PAGE_SIZE_definitions	2006-08-28 09:15:31.000000000 -0700
> +++ threadalloc-dave/mm/Kconfig	2006-08-28 09:39:00.000000000 -0700
> @@ -56,6 +56,10 @@ config PAGE_SHIFT
>  	default "12" # arm(26) || h8300 || i386 || m68knommu || m32r || ppc(32)
>  		     # s390 || sh/64 || um || v850 || xtensa || x86_64
>  
> +config ARCH_HAVE_GET_ORDER
> +	def_bool y
> +	depends on IA64 || PPC || XTENSA
> +
>  config SELECT_MEMORY_MODEL
>  	def_bool y
>  	depends on EXPERIMENTAL || ARCH_SELECT_MEMORY_MODEL
> _

fwiw, I believe that the HAVE_ARCH* or ARCH_HAS* thingies
are (hidden) config options/flags.  But they are not as hidden
as burying them in include/linux/*.h files.

I posted 9 (iirc) patches to convert <disease> to Kconfig variables,
but hch nacked them.  He apparently wants to see Linus's solution.  :(
I looked into using that and it was too ugly for me.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
